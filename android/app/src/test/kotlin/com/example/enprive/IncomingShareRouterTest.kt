package com.example.enprive

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class IncomingShareRouterTest {

    @Test
    fun `1 chrome style URL share with EXTRA_TEXT and PNG preview clipData routes to TextOrUrl`() {
        val route = IncomingShareRouter.classifySendShare(
            SendShareInput(
                declaredMimeType = "text/plain",
                extraText = "https://ululab.com/privacy-policy/",
                subject = "Privacy Policy - Ululab",
                candidateUris = listOf(
                    SendShareCandidateUri(
                        uriString = "content://com.android.chrome.FileProvider/screenshot/17948518560005596943773200990247.png",
                        scheme = "content",
                        resolvedMime = "image/png",
                        fileName = "17948518560005596943773200990247.png",
                        fromExtraStream = false,
                    ),
                ),
            ),
        )

        assertTrue("Expected TextOrUrl for Chrome link share", route is SendShareRoute.TextOrUrl)
        val textRoute = route as SendShareRoute.TextOrUrl
        assertEquals("https://ululab.com/privacy-policy/", textRoute.text)
        assertEquals("Privacy Policy - Ululab", textRoute.subject)
    }

    @Test
    fun `2 plain text URL share without preview URI routes to TextOrUrl`() {
        val route = IncomingShareRouter.classifySendShare(
            SendShareInput(
                declaredMimeType = "text/plain",
                extraText = "Knowunity Privacy Policy - https://knowunity.com/legal/privacy",
                subject = "Knowunity Privacy",
                candidateUris = emptyList(),
            ),
        )

        assertTrue(route is SendShareRoute.TextOrUrl)
        val textRoute = route as SendShareRoute.TextOrUrl
        assertEquals("Knowunity Privacy Policy - https://knowunity.com/legal/privacy", textRoute.text)
        assertEquals(
            "https://knowunity.com/legal/privacy",
            IncomingShareRouter.extractSharedPublicHttpUrl(textRoute.text),
        )
    }

    @Test
    fun `3 plain text policy excerpt routes to TextOrUrl`() {
        val excerpt =
            "We collect your device type and crash logs to diagnose errors and never sell student data."
        val route = IncomingShareRouter.classifySendShare(
            SendShareInput(
                declaredMimeType = "text/plain",
                extraText = excerpt,
                subject = null,
                candidateUris = emptyList(),
            ),
        )

        assertTrue(route is SendShareRoute.TextOrUrl)
        assertEquals(excerpt, (route as SendShareRoute.TextOrUrl).text)
    }

    @Test
    fun `4 PDF share with EXTRA_STREAM stays DocumentUri`() {
        val route = IncomingShareRouter.classifySendShare(
            SendShareInput(
                declaredMimeType = "application/pdf",
                extraText = "Attached privacy notice",
                subject = "App Privacy PDF",
                candidateUris = listOf(
                    SendShareCandidateUri(
                        uriString = "content://com.google.android.apps.nbu.files.provider/1/policy.pdf",
                        scheme = "content",
                        resolvedMime = "application/pdf",
                        fileName = "policy.pdf",
                        fromExtraStream = true,
                    ),
                ),
            ),
        )

        assertTrue(route is SendShareRoute.DocumentUri)
        val docRoute = route as SendShareRoute.DocumentUri
        assertEquals("application/pdf", docRoute.declaredMimeType)
        assertEquals("policy.pdf", docRoute.fileName)
    }

    @Test
    fun `5 DOCX share with EXTRA_STREAM stays DocumentUri`() {
        val docxMime = DocumentTextExtractor.MIME_DOCX
        val route = IncomingShareRouter.classifySendShare(
            SendShareInput(
                declaredMimeType = docxMime,
                extraText = null,
                subject = null,
                candidateUris = listOf(
                    SendShareCandidateUri(
                        uriString = "content://com.example.docs/provider/terms.docx",
                        scheme = "content",
                        resolvedMime = docxMime,
                        fileName = "terms.docx",
                        fromExtraStream = true,
                    ),
                ),
            ),
        )

        assertTrue(route is SendShareRoute.DocumentUri)
        val docRoute = route as SendShareRoute.DocumentUri
        assertEquals(docxMime, docRoute.declaredMimeType)
        assertEquals("terms.docx", docRoute.fileName)
    }

    @Test
    fun `6 unsupported PNG only share routes to DocumentUri so MIME guard rejects safely`() {
        val route = IncomingShareRouter.classifySendShare(
            SendShareInput(
                declaredMimeType = "image/png",
                extraText = null,
                subject = null,
                candidateUris = listOf(
                    SendShareCandidateUri(
                        uriString = "content://media/external/images/media/1234",
                        scheme = "content",
                        resolvedMime = "image/png",
                        fileName = "screenshot.png",
                        fromExtraStream = true,
                    ),
                ),
            ),
        )

        assertTrue(route is SendShareRoute.DocumentUri)
        val docRoute = route as SendShareRoute.DocumentUri
        assertEquals("image/png", docRoute.declaredMimeType)
    }

    @Test
    fun `7 malformed or empty shares are safely rejected with actionable guidance`() {
        val emptyShare = IncomingShareRouter.classifySendShare(
            SendShareInput(
                declaredMimeType = "text/plain",
                extraText = "   ",
                subject = null,
                candidateUris = emptyList(),
            ),
        )
        assertTrue(emptyShare is SendShareRoute.Rejected)
        assertTrue((emptyShare as SendShareRoute.Rejected).userMessage.contains("PDF, TXT, or DOCX"))

        val malformedUriShare = IncomingShareRouter.classifySendShare(
            SendShareInput(
                declaredMimeType = "text/plain",
                extraText = null,
                subject = null,
                candidateUris = listOf(
                    SendShareCandidateUri(
                        uriString = "ftp://internal-host/secret.pdf",
                        scheme = "ftp",
                        resolvedMime = null,
                        fileName = "secret.pdf",
                        fromExtraStream = true,
                    ),
                ),
            ),
        )
        assertTrue(malformedUriShare is SendShareRoute.Rejected)
    }

    @Test
    fun `8 genuine TXT document share with EXTRA_STREAM is never downgraded to text-only intake`() {
        val route = IncomingShareRouter.classifySendShare(
            SendShareInput(
                declaredMimeType = "text/plain",
                extraText = "policy.txt",
                subject = "policy.txt",
                candidateUris = listOf(
                    SendShareCandidateUri(
                        uriString = "content://com.google.android.apps.nbu.files.provider/2/policy.txt",
                        scheme = "content",
                        resolvedMime = "text/plain",
                        fileName = "policy.txt",
                        fromExtraStream = true,
                    ),
                ),
            ),
        )

        assertTrue(
            "Genuine .txt document share must stay DocumentUri",
            route is SendShareRoute.DocumentUri,
        )
        assertEquals("policy.txt", (route as SendShareRoute.DocumentUri).fileName)
    }
}
