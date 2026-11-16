package com.example.enprive

import com.tom_roush.pdfbox.pdmodel.PDDocument
import com.tom_roush.pdfbox.pdmodel.PDPage
import com.tom_roush.pdfbox.pdmodel.PDPageContentStream
import com.tom_roush.pdfbox.pdmodel.encryption.AccessPermission
import com.tom_roush.pdfbox.pdmodel.encryption.StandardProtectionPolicy
import com.tom_roush.pdfbox.pdmodel.font.PDType1Font
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test
import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream
import java.util.zip.ZipEntry
import java.util.zip.ZipOutputStream

class DocumentTextExtractorTest {

    @Test
    fun extractPlainTextReadsUtf8PolicyAndRejectsEmptyOrBinary() {
        val text = "We collect account email for login and retain billing records for 90 days."
        val ok = DocumentTextExtractor.extractFromBytes(
            bytes = text.toByteArray(Charsets.UTF_8),
            mimeType = DocumentTextExtractor.MIME_TXT,
            fileName = "policy.txt",
        )
        assertEquals("ok", ok.status)
        assertEquals("txt", ok.documentType)
        assertEquals(text, ok.extractedText)

        val empty = DocumentTextExtractor.extractFromBytes(
            bytes = "   \n  ".toByteArray(Charsets.UTF_8),
            mimeType = DocumentTextExtractor.MIME_TXT,
            fileName = "empty.txt",
        )
        assertEquals("empty", empty.status)

        val binaryInTxt = DocumentTextExtractor.extractFromBytes(
            bytes = byteArrayOf(0x00, 0x01, 0x02, 0x03, 0x00, 0x41),
            mimeType = DocumentTextExtractor.MIME_TXT,
            fileName = "binary.txt",
        )
        assertEquals("corrupt", binaryInTxt.status)
    }

    @Test
    fun extractPdfExtractsTextAndHandlesEmptyCorruptAndPasswordProtected() {
        // 1. Valid single-page text PDF created locally with PDFBox
        val validBytes = createTestPdfBytes(
            "We collect diagnostic crash reports and retain session data for 14 days."
        )
        val ok = DocumentTextExtractor.extractFromBytes(
            bytes = validBytes,
            mimeType = DocumentTextExtractor.MIME_PDF,
            fileName = "privacy.pdf",
        )
        assertEquals("ok", ok.status)
        assertEquals("pdf", ok.documentType)
        assertEquals(1, ok.pageCount)
        assertTrue(ok.extractedText.contains("diagnostic crash reports"))

        // 2. Empty page PDF (no selectable text)
        val blankBytes = createTestPdfBytes(null)
        val blank = DocumentTextExtractor.extractFromBytes(
            bytes = blankBytes,
            mimeType = DocumentTextExtractor.MIME_PDF,
            fileName = "scanned.pdf",
        )
        assertEquals("empty", blank.status)

        // 3. Corrupt PDF
        val corrupt = DocumentTextExtractor.extractFromBytes(
            bytes = "not a real pdf".toByteArray(Charsets.UTF_8),
            mimeType = DocumentTextExtractor.MIME_PDF,
            fileName = "broken.pdf",
        )
        assertEquals("corrupt", corrupt.status)

        // 4. Password-protected PDF
        val protectedBytes = createPasswordProtectedPdfBytes("Hidden policy")
        assertNotNull("Encrypted PDF fixture should be created on JVM", protectedBytes)
        val locked = DocumentTextExtractor.extractFromBytes(
            bytes = protectedBytes!!,
            mimeType = DocumentTextExtractor.MIME_PDF,
            fileName = "locked.pdf",
        )
        assertEquals("password_protected", locked.status)
    }

    @Test
    fun extractDocxReadsParagraphsAndHandlesEmptyEncryptedAndCorruptArchives() {
        val validDocx = createDocxBytes(
            """
            <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
              <w:body>
                <w:p><w:r><w:t>Privacy Notice</w:t></w:r></w:p>
                <w:p><w:r><w:t>We do not sell student information to advertising brokers.</w:t></w:r></w:p>
              </w:body>
            </w:document>
            """.trimIndent()
        )
        val ok = DocumentTextExtractor.extractFromBytes(
            bytes = validDocx,
            mimeType = DocumentTextExtractor.MIME_DOCX,
            fileName = "policy.docx",
        )
        assertEquals("ok", ok.status)
        assertEquals("docx", ok.documentType)
        assertTrue(ok.extractedText.contains("Privacy Notice"))
        assertTrue(ok.extractedText.contains("We do not sell student information"))

        val emptyDocx = createDocxBytes(
            """
            <w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">
              <w:body><w:p/></w:body>
            </w:document>
            """.trimIndent()
        )
        val empty = DocumentTextExtractor.extractFromBytes(
            bytes = emptyDocx,
            mimeType = DocumentTextExtractor.MIME_DOCX,
            fileName = "empty.docx",
        )
        assertEquals("empty", empty.status)

        val encryptedOle2 = DocumentTextExtractor.extractFromBytes(
            bytes = byteArrayOf(
                0xD0.toByte(), 0xCF.toByte(), 0x11.toByte(), 0xE0.toByte(),
                0xA1.toByte(), 0xB1.toByte(), 0x1A.toByte(), 0xE1.toByte(),
            ),
            mimeType = DocumentTextExtractor.MIME_DOCX,
            fileName = "locked.docx",
        )
        assertEquals("password_protected", encryptedOle2.status)

        val corruptDocx = DocumentTextExtractor.extractFromBytes(
            bytes = byteArrayOf(0x50, 0x4B, 0x03, 0x04, 0x00, 0x00),
            mimeType = DocumentTextExtractor.MIME_DOCX,
            fileName = "broken.docx",
        )
        assertEquals("corrupt", corruptDocx.status)
    }

    @Test
    fun rejectsUnsupportedFormatsAndOversizedStreams() {
        val unsupported = DocumentTextExtractor.extractFromBytes(
            bytes = "<html>hi</html>".toByteArray(),
            mimeType = "application/zip",
            fileName = "archive.zip",
        )
        assertEquals("unsupported_mime", unsupported.status)

        val oversized = ByteArray(1024) { 0x41 }
        val bounded = DocumentTextExtractor.readBoundedBytes(
            ByteArrayInputStream(oversized),
            maxBytes = 512,
        )
        assertEquals(null, bounded)
    }

    private fun createTestPdfBytes(text: String?): ByteArray {
        val doc = PDDocument()
        doc.use { pdf ->
            val page = PDPage()
            pdf.addPage(page)
            if (text != null) {
                PDPageContentStream(pdf, page).use { stream ->
                    stream.beginText()
                    stream.setFont(PDType1Font.HELVETICA, 12f)
                    stream.newLineAtOffset(50f, 700f)
                    stream.showText(text)
                    stream.endText()
                }
            }
            val out = ByteArrayOutputStream()
            pdf.save(out)
            return out.toByteArray()
        }
    }

    private fun createPasswordProtectedPdfBytes(text: String): ByteArray? {
        return try {
            val doc = PDDocument()
            doc.use { pdf ->
                val page = PDPage()
                pdf.addPage(page)
                PDPageContentStream(pdf, page).use { stream ->
                    stream.beginText()
                    stream.setFont(PDType1Font.HELVETICA, 12f)
                    stream.newLineAtOffset(50f, 700f)
                    stream.showText(text)
                    stream.endText()
                }
                val policy = StandardProtectionPolicy("owner123", "user123", AccessPermission())
                policy.encryptionKeyLength = 128
                pdf.protect(policy)
                val out = ByteArrayOutputStream()
                pdf.save(out)
                out.toByteArray()
            }
        } catch (_: Throwable) {
            null
        }
    }

    private fun createDocxBytes(documentXml: String): ByteArray {
        val out = ByteArrayOutputStream()
        ZipOutputStream(out).use { zos ->
            zos.putNextEntry(ZipEntry("[Content_Types].xml"))
            zos.write("<Types/>".toByteArray(Charsets.UTF_8))
            zos.closeEntry()

            zos.putNextEntry(ZipEntry("word/document.xml"))
            zos.write(documentXml.toByteArray(Charsets.UTF_8))
            zos.closeEntry()
        }
        return out.toByteArray()
    }
}
