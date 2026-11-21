package com.example.enprive

import com.tom_roush.pdfbox.pdmodel.PDDocument
import com.tom_roush.pdfbox.pdmodel.PDPage
import com.tom_roush.pdfbox.pdmodel.PDPageContentStream
import com.tom_roush.pdfbox.pdmodel.encryption.AccessPermission
import com.tom_roush.pdfbox.pdmodel.encryption.StandardProtectionPolicy
import com.tom_roush.pdfbox.pdmodel.font.PDType1Font
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertThrows
import org.junit.Assert.assertTrue
import org.junit.Test
import org.xmlpull.v1.XmlPullParser
import org.xmlpull.v1.XmlPullParserException
import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream
import java.io.InputStream
import java.util.zip.ZipEntry
import java.util.zip.ZipOutputStream

class DocumentTextExtractorTest {
    private companion object {
        const val WORD_NS = "http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    }

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

        // 5. PDF containing JPXDecode image reference extracts text cleanly without JP2Decoder on classpath,
        // and invoking JPXFilter.decode safely throws IOException (MissingImageReaderException), never crashing.
        val jpxReferencingPdf = createPdfWithJpxStreamAndText(
            "Students under age 13 do not see behavioral advertising.",
        )
        val jpxOutcome = DocumentTextExtractor.extractFromBytes(
            bytes = jpxReferencingPdf,
            mimeType = DocumentTextExtractor.MIME_PDF,
            fileName = "jpx_policy.pdf",
        )
        assertEquals("ok", jpxOutcome.status)
        assertTrue(jpxOutcome.extractedText.contains("behavioral advertising"))

        val jpxFilter = com.tom_roush.pdfbox.filter.FilterFactory.INSTANCE
            .getFilter(com.tom_roush.pdfbox.cos.COSName.JPX_DECODE)
        var missingReaderThrown = false
        try {
            jpxFilter.decode(
                ByteArrayInputStream(byteArrayOf(0x00, 0x00, 0x00, 0x0C)),
                ByteArrayOutputStream(),
                com.tom_roush.pdfbox.cos.COSDictionary(),
                0,
            )
        } catch (e: com.tom_roush.pdfbox.filter.MissingImageReaderException) {
            missingReaderThrown = true
        }
        assertTrue(
            "JPXFilter without optional jp2-android dependency must fail via MissingImageReaderException, not crash",
            missingReaderThrown,
        )
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
            xmlPullParserFactory = ::SaxXmlPullParser,
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
            xmlPullParserFactory = ::SaxXmlPullParser,
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
    fun extractDocxKeepsParagraphTableTabAndBreakLayout() {
        val result = extractDocx(
            wordDocument(
                """
                <w:p><w:r><w:t>Effective date:</w:t><w:tab/><w:t>1 November 2026</w:t></w:r></w:p>
                <w:p><w:r><w:t>Line one</w:t><w:br/><w:t>Line two</w:t><w:cr/><w:t>Line three</w:t></w:r></w:p>
                <w:tbl>
                  <w:tr>
                    <w:tc><w:p><w:r><w:t>Data type</w:t></w:r></w:p></w:tc>
                    <w:tc><w:p><w:r><w:t>Retention</w:t></w:r></w:p></w:tc>
                  </w:tr>
                  <w:tr>
                    <w:tc><w:p><w:r><w:t>Email</w:t></w:r></w:p></w:tc>
                    <w:tc><w:p><w:r><w:t>Until deletion</w:t></w:r></w:p></w:tc>
                  </w:tr>
                </w:tbl>
                <w:p><w:r><w:t xml:space="preserve">Tom &amp; Jerry&#160;&lt;support&gt;</w:t></w:r></w:p>
                """
            ),
        )
        assertEquals("ok", result.status)
        assertEquals(
            listOf(
                "Effective date: 1 November 2026",
                "Line one",
                "Line two",
                "Line three",
                "Data type",
                "Retention",
                "Email",
                "Until deletion",
                "Tom & Jerry <support>",
            ),
            result.extractedText.lines(),
        )
    }

    @Test
    fun extractDocxMatchesElementsByLocalNameInAnyNamespacePrefix() {
        val defaultNamespace = extractDocx(
            docxBytes("""<document xmlns="$WORD_NS"><body><p><r><t>Default namespace text</t></r></p></body></document>"""),
        )
        assertEquals("ok", defaultNamespace.status)
        assertEquals("Default namespace text", defaultNamespace.extractedText)

        val otherPrefix = extractDocx(
            docxBytes(
                """<ns0:document xmlns:ns0="$WORD_NS"><ns0:body>""" +
                    """<ns0:p><ns0:r><ns0:t>First</ns0:t></ns0:r></ns0:p><ns0:p><ns0:r><ns0:t>Second</ns0:t></ns0:r></ns0:p>""" +
                    """</ns0:body></ns0:document>""",
            ),
        )
        assertEquals("ok", otherPrefix.status)
        assertEquals("First\nSecond", otherPrefix.extractedText)
    }

    @Test
    fun extractDocxSkipsDeletedTextAndFieldInstructions() {
        val result = extractDocx(
            wordDocument(
                """
                <w:p><w:r><w:t xml:space="preserve">We keep data for 30 days. </w:t></w:r><w:del w:id="1" w:author="QA"><w:r><w:delText>We sell location data.</w:delText></w:r></w:del><w:r><w:fldChar w:fldCharType="begin"/></w:r><w:r><w:instrText xml:space="preserve"> HYPERLINK "https://tracker.example" </w:instrText></w:r><w:r><w:fldChar w:fldCharType="separate"/></w:r><w:r><w:t>Contact us</w:t></w:r><w:r><w:fldChar w:fldCharType="end"/></w:r></w:p>
                """
            ),
        )
        assertEquals("ok", result.status)
        assertEquals("We keep data for 30 days. Contact us", result.extractedText)
    }

    @Test
    fun extractDocxRejectsDoctypeWithoutReadingTheBody() {
        val result = extractDocx(
            docxBytes(
                """<?xml version="1.0" encoding="UTF-8"?>
                <!DOCTYPE w:document [<!ELEMENT w:document ANY>]>
                <w:document xmlns:w="$WORD_NS"><w:body><w:p><w:r><w:t>Visible text</w:t></w:r></w:p></w:body></w:document>
                """.trimIndent()
            ),
        )
        assertDocxXmlRejected(result)
    }

    @Test
    fun extractDocxRejectsExternalEntity() {
        val result = extractDocx(
            docxBytes(
                """<?xml version="1.0" encoding="UTF-8"?>
                <!DOCTYPE w:document [<!ENTITY xxe SYSTEM "file:///etc/hosts">]>
                <w:document xmlns:w="$WORD_NS"><w:body><w:p><w:r><w:t>&xxe;</w:t></w:r></w:p></w:body></w:document>
                """.trimIndent()
            ),
        )
        assertDocxXmlRejected(result)
    }

    @Test
    fun extractDocxRejectsBillionLaughs() {
        val result = extractDocx(docxBytes(billionLaughsXml()))
        assertDocxXmlRejected(result)
    }

    @Test
    fun extractDocxEnforcesElementDepthCapWithoutRecursion() {
        val atCap = extractDocx(nestedDocx(DocumentTextExtractor.MAX_DOCX_ELEMENT_DEPTH))
        assertEquals("ok", atCap.status)
        assertEquals("Nested text", atCap.extractedText)

        assertDocxXmlRejected(extractDocx(nestedDocx(DocumentTextExtractor.MAX_DOCX_ELEMENT_DEPTH + 1)))
        // 60,000 levels overflowed the stack in the old recursive DOM walk.
        assertDocxXmlRejected(extractDocx(nestedDocx(60_000)))
    }

    @Test
    fun readDocxTextStopsAtOutputCap() {
        val parser = SaxXmlPullParser().apply {
            setFeature(XmlPullParser.FEATURE_PROCESS_NAMESPACES, true)
            setInput(
                ByteArrayInputStream(wordDocumentXml("<w:p><w:r><w:t>0123456789AB</w:t></w:r></w:p>").toByteArray()),
                null,
            )
        }
        assertThrows(DocumentTextExtractor.DocxTextLimitException::class.java) {
            DocumentTextExtractor.readDocxText(parser, maxChars = 10)
        }
    }

    @Test
    fun extractDocxFailsClosedOnDoctypeAndUndeclaredEntityTokens() {
        val doctype = extractDocx(
            docxBytes(wordDocumentXml("")),
            parserFactory = {
                ScriptedXmlPullParser(
                    listOf(
                        ScriptedXmlPullParser.Token(XmlPullParser.DOCDECL),
                        ScriptedXmlPullParser.Token(XmlPullParser.START_TAG, name = "t"),
                        ScriptedXmlPullParser.Token(XmlPullParser.TEXT, text = "Visible text"),
                        ScriptedXmlPullParser.Token(XmlPullParser.END_TAG, name = "t"),
                    ),
                )
            },
        )
        assertDocxXmlRejected(doctype)

        val customEntity = extractDocx(
            docxBytes(wordDocumentXml("")),
            parserFactory = {
                ScriptedXmlPullParser(
                    listOf(
                        ScriptedXmlPullParser.Token(XmlPullParser.START_TAG, name = "t"),
                        ScriptedXmlPullParser.Token(XmlPullParser.ENTITY_REF, name = "leak", text = "secret"),
                        ScriptedXmlPullParser.Token(XmlPullParser.END_TAG, name = "t"),
                    ),
                )
            },
        )
        assertDocxXmlRejected(customEntity)

        // KXmlParser ends truncated input with END_DOCUMENT instead of throwing.
        val truncated = extractDocx(
            docxBytes(wordDocumentXml("")),
            parserFactory = {
                ScriptedXmlPullParser(
                    listOf(
                        ScriptedXmlPullParser.Token(XmlPullParser.START_TAG, name = "document"),
                        ScriptedXmlPullParser.Token(XmlPullParser.START_TAG, name = "t"),
                        ScriptedXmlPullParser.Token(XmlPullParser.TEXT, text = "Partial text"),
                    ),
                )
            },
        )
        assertDocxXmlRejected(truncated)

        val noRoot = extractDocx(docxBytes(wordDocumentXml("")), parserFactory = { ScriptedXmlPullParser(emptyList()) })
        assertDocxXmlRejected(noRoot)

        val predefined = extractDocx(
            docxBytes(wordDocumentXml("")),
            parserFactory = {
                ScriptedXmlPullParser(
                    listOf(
                        ScriptedXmlPullParser.Token(XmlPullParser.START_TAG, name = "t"),
                        ScriptedXmlPullParser.Token(XmlPullParser.TEXT, text = "Tom "),
                        ScriptedXmlPullParser.Token(XmlPullParser.ENTITY_REF, name = "amp", text = "&"),
                        ScriptedXmlPullParser.Token(XmlPullParser.TEXT, text = " Jerry"),
                        ScriptedXmlPullParser.Token(XmlPullParser.ENTITY_REF, name = "#33", text = "!"),
                        ScriptedXmlPullParser.Token(XmlPullParser.END_TAG, name = "t"),
                    ),
                )
            },
        )
        assertEquals("ok", predefined.status)
        assertEquals("Tom & Jerry!", predefined.extractedText)
    }

    @Test
    fun extractDocxConfiguresParserAndSeparatesSetupFailuresFromCorruption() {
        val created = mutableListOf<SaxXmlPullParser>()
        val ok = extractDocx(
            docxBytes(wordDocumentXml("<w:p><w:r><w:t>Hello</w:t></w:r></w:p>")),
            parserFactory = { SaxXmlPullParser().also(created::add) },
        )
        assertEquals("ok", ok.status)
        assertEquals(true, created.single().features[XmlPullParser.FEATURE_PROCESS_NAMESPACES])
        assertEquals(false, created.single().features[XmlPullParser.FEATURE_PROCESS_DOCDECL])

        val factoryFailure = extractDocx(
            docxBytes(wordDocumentXml("<w:p><w:r><w:t>Hello</w:t></w:r></w:p>")),
            parserFactory = { throw XmlPullParserException("no parser") },
        )
        assertEquals("read_error", factoryFailure.status)
        assertEquals("Could not extract DOCX document locally.", factoryFailure.userMessage)

        val featureFailure = extractDocx(
            docxBytes(wordDocumentXml("<w:p><w:r><w:t>Hello</w:t></w:r></w:p>")),
            parserFactory = {
                object : HostXmlPullParser() {
                    override fun setFeature(name: String, state: Boolean) {
                        throw XmlPullParserException("unsupported feature")
                    }
                    override fun setInput(inputStream: InputStream, inputEncoding: String?) {}
                    override fun nextToken(): Int = XmlPullParser.END_DOCUMENT
                }
            },
        )
        assertEquals("read_error", featureFailure.status)

        val malformed = extractDocx(docxBytes("<w:document xmlns:w=\"$WORD_NS\"><w:body>"))
        assertDocxXmlRejected(malformed)
        assertDocxXmlRejected(extractDocx(docxBytes("")))
    }

    @Test
    fun extractDocxKeepsArchiveLimitsAndEncryptionDetection() {
        val tooManyEntries = extractDocx(
            docxBytes(
                wordDocumentXml("<w:p><w:r><w:t>Hello</w:t></w:r></w:p>"),
                extraEntries = (1..250).map { "customXml/item$it.xml" to "<x/>".toByteArray() },
            ),
        )
        assertEquals("corrupt", tooManyEntries.status)
        assertEquals("DOCX archive exceeded entry safety limits.", tooManyEntries.userMessage)

        val oversizedDocumentXml = extractDocx(
            docxBytes(
                wordDocumentXml("<w:p><w:r><w:t>Hello</w:t></w:r></w:p>") +
                    " ".repeat(DocumentTextExtractor.MAX_DOCUMENT_BYTES),
            ),
        )
        assertEquals("too_large", oversizedDocumentXml.status)
        assertEquals("DOCX text stream exceeds local safety limits.", oversizedDocumentXml.userMessage)

        val oversizedArchive = extractDocx(
            docxBytes(
                wordDocumentXml("<w:p><w:r><w:t>Hello</w:t></w:r></w:p>"),
                extraEntries = listOf("word/media/padding.bin" to ByteArray(21 * 1024 * 1024)),
            ),
        )
        assertEquals("too_large", oversizedArchive.status)
        assertEquals("DOCX uncompressed contents exceed local safety limits.", oversizedArchive.userMessage)

        val encryptedPackage = extractDocx(
            docxBytes(
                wordDocumentXml("<w:p><w:r><w:t>Hello</w:t></w:r></w:p>"),
                extraEntries = listOf("EncryptedPackage" to ByteArray(16)),
            ),
        )
        assertEquals("password_protected", encryptedPackage.status)

        val missingDocument = extractDocx(
            docxBytes(null, extraEntries = listOf("word/styles.xml" to "<w:styles/>".toByteArray())),
        )
        assertEquals("corrupt", missingDocument.status)
        assertEquals(
            "DOCX archive is missing readable document content (word/document.xml).",
            missingDocument.userMessage,
        )
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

    private fun createDocxBytes(documentXml: String): ByteArray = docxBytes(documentXml)

    private fun extractDocx(
        bytes: ByteArray,
        parserFactory: () -> XmlPullParser = ::SaxXmlPullParser,
    ) = DocumentTextExtractor.extractDocx(bytes, parserFactory)

    private fun assertDocxXmlRejected(result: DocumentTextExtractor.ExtractionResult) {
        assertEquals("corrupt", result.status)
        assertEquals("Could not parse DOCX XML content cleanly.", result.userMessage)
        assertEquals("", result.extractedText)
    }

    private fun wordDocumentXml(bodyXml: String): String =
        """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>""" +
            """<w:document xmlns:w="$WORD_NS"><w:body>$bodyXml</w:body></w:document>"""

    private fun wordDocument(bodyXml: String): ByteArray = docxBytes(wordDocumentXml(bodyXml.trimIndent()))

    private fun nestedDocx(depth: Int): ByteArray {
        // w:document and w:body take two levels; w:t adds the last one.
        val wrappers = depth - 3
        val xml = StringBuilder()
            .append("""<w:document xmlns:w="$WORD_NS"><w:body>""")
            .append("<w:sdt>".repeat(wrappers))
            .append("<w:t>Nested text</w:t>")
            .append("</w:sdt>".repeat(wrappers))
            .append("</w:body></w:document>")
        return docxBytes(xml.toString())
    }

    private fun billionLaughsXml(): String {
        val entities = StringBuilder("""<!ENTITY lol0 "lol">""")
        for (i in 1..9) {
            val previous = "&lol${i - 1};"
            entities.append("""<!ENTITY lol$i "${previous.repeat(10)}">""")
        }
        return """<?xml version="1.0"?>""" +
            """<!DOCTYPE w:document [$entities]>""" +
            """<w:document xmlns:w="$WORD_NS"><w:body><w:p><w:r><w:t>&lol9;</w:t></w:r></w:p></w:body></w:document>"""
    }

    private fun docxBytes(
        documentXml: String?,
        extraEntries: List<Pair<String, ByteArray>> = emptyList(),
    ): ByteArray {
        val out = ByteArrayOutputStream()
        ZipOutputStream(out).use { zos ->
            zos.putNextEntry(ZipEntry("[Content_Types].xml"))
            zos.write("<Types/>".toByteArray(Charsets.UTF_8))
            zos.closeEntry()

            if (documentXml != null) {
                zos.putNextEntry(ZipEntry("word/document.xml"))
                zos.write(documentXml.toByteArray(Charsets.UTF_8))
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

    private fun createPdfWithJpxStreamAndText(text: String): ByteArray {
        val escaped = text.replace("\\", "\\\\").replace("(", "\\(").replace(")", "\\)")
        val contentStream = "BT /F1 12 Tf 50 700 Td ($escaped) Tj ET"
        val objects = listOf(
            "1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n",
            "2 0 obj\n<< /Type /Pages /Kids [3 0 R] /Count 1 >>\nendobj\n",
            "3 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Resources << /Font << /F1 4 0 R >> /XObject << /Im1 6 0 R >> >> /Contents 5 0 R >>\nendobj\n",
            "4 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>\nendobj\n",
            "5 0 obj\n<< /Length ${contentStream.toByteArray(Charsets.US_ASCII).size} >>\nstream\n$contentStream\nendstream\nendobj\n",
            "6 0 obj\n<< /Type /XObject /Subtype /Image /Width 1 /Height 1 /BitsPerComponent 8 /ColorSpace /DeviceRGB /Filter /JPXDecode /Length 4 >>\nstream\n\u0000\u0000\u0000\u000C\nendstream\nendobj\n",
        )
        val header = "%PDF-1.4\n"
        val sb = StringBuilder(header)
        val offsets = mutableListOf<Int>()
        for (obj in objects) {
            offsets.add(sb.toString().toByteArray(Charsets.US_ASCII).size)
            sb.append(obj)
        }
        val xrefOffset = sb.toString().toByteArray(Charsets.US_ASCII).size
        sb.append("xref\n0 ${objects.size + 1}\n0000000000 65535 f \n")
        for (off in offsets) {
            sb.append(String.format("%010d 00000 n \n", off))
        }
        sb.append("trailer\n<< /Size ${objects.size + 1} /Root 1 0 R >>\nstartxref\n$xrefOffset\n%%EOF\n")
        return sb.toString().toByteArray(Charsets.US_ASCII)
    }
}
