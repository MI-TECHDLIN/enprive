package com.example.enprive

import android.content.ContentValues
import android.net.Uri
import android.os.Build
import android.provider.ContactsContract
import android.provider.MediaStore
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Assume.assumeTrue
import org.junit.Test
import org.junit.runner.RunWith
import java.io.ByteArrayOutputStream
import java.util.zip.ZipEntry
import java.util.zip.ZipOutputStream

/**
 * Runs DOCX extraction on the device's own XmlPullParser (KXmlParser), which
 * host tests cannot load. Every case goes through the production parser
 * factory; nothing here is injected.
 */
@RunWith(AndroidJUnit4::class)
class DocumentTextExtractorInstrumentedTest {
    private val instrumentation = InstrumentationRegistry.getInstrumentation()

    @Test
    fun libreOfficeDocxExtractsParagraphsTableTabBreakAndSkipsTrackedDeletion() {
        val result = extractDocx(asset("docx/enprive_libreoffice_policy.docx"))
        assertEquals(result.userMessage, "ok", result.status)
        val lines = result.extractedText.lines()
        assertEquals("Enprive Sample Privacy Policy", lines.first())
        assertTrue(lines.contains("Effective date: 1 November 2026"))
        assertTrue(lines.contains("We collect your email address to create your account."))
        assertTrue(lines.contains("We never sell your personal information."))
        assertTrue(lines.containsAll(listOf("Data type", "Retention period", "Email address", "Until account deletion")))
        assertFalse(result.extractedText.contains("advertising partners"))
        assertFalse(result.extractedText.contains("PAGE"))
    }

    @Test
    fun minimalQaDocxExtracts() {
        val result = extractDocx(asset("docx/enprive_qa_policy.docx"))
        assertEquals(result.userMessage, "ok", result.status)
        val lines = result.extractedText.lines()
        assertEquals(3, lines.size)
        assertEquals("Math Makers Synthetic DOCX Privacy Policy (com.ululab.numbers).", lines[0])
        assertTrue(lines[2].startsWith("We do not sell personal data"))
    }

    @Test
    fun multipleParagraphsAndTablesKeepTheirLayout() {
        val result = extractDocx(
            docx(
                wordXml(
                    "<w:p><w:r><w:t>First paragraph.</w:t></w:r></w:p>" +
                        "<w:p><w:r><w:t>Second</w:t><w:tab/><w:t>paragraph</w:t><w:br/><w:t>after break.</w:t></w:r></w:p>" +
                        "<w:tbl><w:tr><w:tc><w:p><w:r><w:t>Cell A</w:t></w:r></w:p></w:tc>" +
                        "<w:tc><w:p><w:r><w:t>Cell B</w:t></w:r></w:p></w:tc></w:tr></w:tbl>" +
                        "<w:p><w:r><w:t>Tom &amp; Jerry&#160;&lt;ok&gt;</w:t></w:r></w:p>",
                ),
            ),
        )
        assertEquals("ok", result.status)
        assertEquals(
            listOf("First paragraph.", "Second paragraph", "after break.", "Cell A", "Cell B", "Tom & Jerry <ok>"),
            result.extractedText.lines(),
        )
    }

    @Test
    fun namespacedXmlIsMatchedByLocalName() {
        val defaultNamespace = extractDocx(
            docx("""<document xmlns="$WORD_NS"><body><p><r><t>Default namespace text</t></r></p></body></document>"""),
        )
        assertEquals("ok", defaultNamespace.status)
        assertEquals("Default namespace text", defaultNamespace.extractedText)

        val otherPrefix = extractDocx(
            docx("""<ns0:document xmlns:ns0="$WORD_NS"><ns0:body><ns0:p><ns0:r><ns0:t>Other prefix text</ns0:t></ns0:r></ns0:p></ns0:body></ns0:document>"""),
        )
        assertEquals("ok", otherPrefix.status)
        assertEquals("Other prefix text", otherPrefix.extractedText)
    }

    @Test
    fun emptyDocumentIsEmpty() {
        assertEquals("empty", extractDocx(docx(wordXml("<w:p/>"))).status)
    }

    @Test
    fun malformedXmlIsCorrupt() {
        assertXmlRejected(extractDocx(docx("""<w:document xmlns:w="$WORD_NS"><w:body><w:p>""")))
        assertXmlRejected(extractDocx(docx(wordXml("<w:p><w:r><w:t>&undeclared;</w:t></w:r></w:p>"))))
        assertXmlRejected(extractDocx(docx("")))
    }

    @Test
    fun doctypeIsRejectedEvenWithoutEntities() {
        assertXmlRejected(
            extractDocx(
                docx(
                    """<?xml version="1.0"?><!DOCTYPE w:document [<!ELEMENT w:document ANY>]>""" +
                        wordXml("<w:p><w:r><w:t>Visible text</w:t></w:r></w:p>").substringAfter("?>"),
                ),
            ),
        )
    }

    @Test
    fun externalEntityIsRejected() {
        assertXmlRejected(
            extractDocx(
                docx(
                    """<?xml version="1.0"?><!DOCTYPE w:document [<!ENTITY xxe SYSTEM "file:///proc/self/status">]>""" +
                        """<w:document xmlns:w="$WORD_NS"><w:body><w:p><w:r><w:t>&xxe;</w:t></w:r></w:p></w:body></w:document>""",
                ),
            ),
        )
    }

    @Test
    fun billionLaughsIsRejected() {
        val entities = StringBuilder("""<!ENTITY lol0 "lol">""")
        for (i in 1..9) {
            entities.append("""<!ENTITY lol$i "${"&lol${i - 1};".repeat(10)}">""")
        }
        assertXmlRejected(
            extractDocx(
                docx(
                    """<?xml version="1.0"?><!DOCTYPE w:document [$entities]>""" +
                        """<w:document xmlns:w="$WORD_NS"><w:body><w:p><w:r><w:t>&lol9;</w:t></w:r></w:p></w:body></w:document>""",
                ),
            ),
        )
    }

    @Test
    fun deepNestingIsCappedWithoutStackOverflow() {
        assertEquals("ok", extractDocx(nestedDocx(DocumentTextExtractor.MAX_DOCX_ELEMENT_DEPTH)).status)
        assertXmlRejected(extractDocx(nestedDocx(DocumentTextExtractor.MAX_DOCX_ELEMENT_DEPTH + 1)))
        assertXmlRejected(extractDocx(nestedDocx(60_000)))
    }

    @Test
    fun zipEntryCountOverflowIsRejected() {
        val result = extractDocx(
            docx(wordXml("<w:p><w:r><w:t>Hello</w:t></w:r></w:p>"), (1..250).map { "customXml/item$it.xml" to "<x/>".toByteArray() }),
        )
        assertEquals("corrupt", result.status)
        assertEquals("DOCX archive exceeded entry safety limits.", result.userMessage)
    }

    @Test
    fun uncompressedSizeOverflowIsRejected() {
        val archive = extractDocx(
            docx(wordXml("<w:p><w:r><w:t>Hello</w:t></w:r></w:p>"), listOf("word/media/padding.bin" to ByteArray(21 * 1024 * 1024))),
        )
        assertEquals("too_large", archive.status)
        assertEquals("DOCX uncompressed contents exceed local safety limits.", archive.userMessage)

        val documentXml = extractDocx(
            docx(wordXml("<w:p><w:r><w:t>Hello</w:t></w:r></w:p>") + " ".repeat(DocumentTextExtractor.MAX_DOCUMENT_BYTES)),
        )
        assertEquals("too_large", documentXml.status)
        assertEquals("DOCX text stream exceeds local safety limits.", documentXml.userMessage)
    }

    @Test
    fun passwordProtectedAndUnsupportedArchivesFailSafely() {
        val ole2 = byteArrayOf(
            0xD0.toByte(), 0xCF.toByte(), 0x11.toByte(), 0xE0.toByte(),
            0xA1.toByte(), 0xB1.toByte(), 0x1A.toByte(), 0xE1.toByte(),
        )
        assertEquals("password_protected", extractDocx(ole2).status)
        assertEquals(
            "password_protected",
            extractDocx(docx(wordXml(""), listOf("EncryptedPackage" to ByteArray(16)))).status,
        )
        assertEquals("corrupt", extractDocx(byteArrayOf(0x50, 0x4B, 0x03, 0x04, 0x00, 0x00)).status)
        assertEquals("corrupt", extractDocx("not a zip".toByteArray()).status)
    }

    @Test
    fun missingDocumentXmlIsCorrupt() {
        val result = extractDocx(docx(null, listOf("word/styles.xml" to "<w:styles/>".toByteArray())))
        assertEquals("corrupt", result.status)
        assertEquals("DOCX archive is missing readable document content (word/document.xml).", result.userMessage)
    }

    @Test
    fun contentUriDocxKeepsFileNameMimeAndByteLength() {
        assumeTrue(Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q)
        val bytes = asset("docx/enprive_libreoffice_policy.docx")
        val name = "enprive_androidtest_${System.nanoTime()}.docx"
        withDownload(name, bytes) { uri ->
            val map = DocumentUriExtractor.extract(instrumentation.targetContext.contentResolver, uri, declaredMime = null)
            assertEquals(map["userMessage"] as String, "ok", map["status"])
            assertEquals("docx", map["documentType"])
            assertEquals(name, map["fileName"])
            assertEquals(DocumentTextExtractor.MIME_DOCX, map["mimeType"])
            assertEquals(bytes.size, map["byteLength"])
            assertTrue((map["extractedText"] as String).startsWith("Enprive Sample Privacy Policy"))
            assertEquals(
                setOf("status", "documentType", "fileName", "mimeType", "byteLength", "pageCount", "extractedText", "userMessage"),
                map.keys,
            )
        }
    }

    @Test
    fun contentUriWithoutPermissionReportsPermissionDenied() {
        val map = DocumentUriExtractor.extract(
            instrumentation.targetContext.contentResolver,
            ContactsContract.Contacts.CONTENT_URI,
            declaredMime = DocumentTextExtractor.MIME_DOCX,
        )
        assertEquals("permission_denied", map["status"])
        assertEquals("", map["extractedText"])
    }

    private fun withDownload(name: String, bytes: ByteArray, block: (Uri) -> Unit) {
        val resolver = instrumentation.targetContext.contentResolver
        val values = ContentValues().apply {
            put(MediaStore.Downloads.DISPLAY_NAME, name)
            put(MediaStore.Downloads.MIME_TYPE, DocumentTextExtractor.MIME_DOCX)
            put(MediaStore.Downloads.RELATIVE_PATH, "Download/enprive_androidtest")
        }
        val uri = requireNotNull(resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values))
        try {
            resolver.openOutputStream(uri)!!.use { it.write(bytes) }
            block(uri)
        } finally {
            resolver.delete(uri, null, null)
        }
    }

    private fun extractDocx(bytes: ByteArray) = DocumentTextExtractor.extractFromBytes(
        bytes,
        mimeType = DocumentTextExtractor.MIME_DOCX,
        fileName = "policy.docx",
    )

    private fun assertXmlRejected(result: DocumentTextExtractor.ExtractionResult) {
        assertEquals("corrupt", result.status)
        assertEquals("Could not parse DOCX XML content cleanly.", result.userMessage)
        assertEquals("", result.extractedText)
    }

    private fun asset(path: String): ByteArray =
        instrumentation.context.assets.open(path).use { it.readBytes() }

    private fun wordXml(bodyXml: String): String =
        """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>""" +
            """<w:document xmlns:w="$WORD_NS"><w:body>$bodyXml</w:body></w:document>"""

    private fun nestedDocx(depth: Int): ByteArray {
        // w:document and w:body take two levels; w:t adds the last one.
        val wrappers = depth - 3
        return docx(
            """<w:document xmlns:w="$WORD_NS"><w:body>""" +
                "<w:sdt>".repeat(wrappers) + "<w:t>Nested text</w:t>" + "</w:sdt>".repeat(wrappers) +
                "</w:body></w:document>",
        )
    }

    private fun docx(documentXml: String?, extraEntries: List<Pair<String, ByteArray>> = emptyList()): ByteArray {
        val out = ByteArrayOutputStream()
        ZipOutputStream(out).use { zos ->
            zos.putNextEntry(ZipEntry("[Content_Types].xml"))
            zos.write("<Types/>".toByteArray())
            zos.closeEntry()
            if (documentXml != null) {
                zos.putNextEntry(ZipEntry("word/document.xml"))
                zos.write(documentXml.toByteArray())
                zos.closeEntry()
            }
            for ((name, content) in extraEntries) {
                zos.putNextEntry(ZipEntry(name))
                zos.write(content)
                zos.closeEntry()
            }
        }
        return out.toByteArray()
    }

    private companion object {
        const val WORD_NS = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    }
}
