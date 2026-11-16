package com.example.enprive

import com.tom_roush.pdfbox.pdmodel.PDDocument
import com.tom_roush.pdfbox.pdmodel.encryption.InvalidPasswordException
import com.tom_roush.pdfbox.text.PDFTextStripper
import org.w3c.dom.Element
import org.w3c.dom.Node
import java.io.ByteArrayInputStream
import java.io.ByteArrayOutputStream
import java.io.InputStream
import java.nio.charset.Charset
import java.util.zip.ZipException
import java.util.zip.ZipInputStream
import javax.xml.XMLConstants
import javax.xml.parsers.DocumentBuilderFactory

/**
 * Pure-Kotlin local document extractor for supported privacy-policy documents
 * (PDF, plain text TXT/MD, and DOCX). Runs 100% locally on device bytes without
 * uploading binaries or making network requests.
 */
object DocumentTextExtractor {
    const val MAX_DOCUMENT_BYTES: Int = 10 * 1024 * 1024 // 10 MiB
    private const val MAX_ZIP_ENTRIES: Int = 250
    private const val MAX_ZIP_UNCOMPRESSED_BYTES: Long = 20L * 1024L * 1024L

    const val MIME_PDF = "application/pdf"
    const val MIME_TXT = "text/plain"
    const val MIME_MARKDOWN = "text/markdown"
    const val MIME_DOCX =
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document"

    val SUPPORTED_PICKER_MIMES: Array<String> = arrayOf(
        MIME_PDF,
        MIME_TXT,
        MIME_DOCX,
    )

    data class ExtractionResult(
        val status: String, // ok | unsupported_mime | too_large | empty | corrupt | password_protected | read_error
        val documentType: String?, // pdf | txt | docx
        val extractedText: String,
        val userMessage: String,
        val byteLength: Int = 0,
        val pageCount: Int? = null,
    ) {
        fun toChannelMap(fileName: String?, mimeType: String?): Map<String, Any?> = mapOf(
            "status" to status,
            "documentType" to documentType,
            "fileName" to fileName,
            "mimeType" to mimeType,
            "byteLength" to byteLength,
            "pageCount" to pageCount,
            "extractedText" to extractedText,
            "userMessage" to userMessage,
        )
    }

    enum class DetectedFormat {
        PDF,
        TXT,
        DOCX,
        UNSUPPORTED,
    }

    /**
     * Reads at most [maxBytes] + 1 bytes from [input] so oversized files are
     * rejected before full buffering in memory.
     */
    fun readBoundedBytes(
        input: InputStream,
        maxBytes: Int = MAX_DOCUMENT_BYTES,
    ): ByteArray? {
        val buffer = ByteArray(8192)
        val out = ByteArrayOutputStream()
        var total = 0
        while (true) {
            val read = input.read(buffer)
            if (read <= 0) break
            total += read
            if (total > maxBytes) {
                return null
            }
            out.write(buffer, 0, read)
        }
        return out.toByteArray()
    }

    fun resolveFormat(
        mimeType: String?,
        fileName: String?,
    ): DetectedFormat {
        val cleanMime = mimeType?.substringBefore(';')?.trim()?.lowercase()
        val ext = fileName?.substringAfterLast('.', "")?.trim()?.lowercase()

        return when (cleanMime) {
            MIME_PDF -> DetectedFormat.PDF
            MIME_TXT, MIME_MARKDOWN, "text/x-markdown" -> DetectedFormat.TXT
            MIME_DOCX -> DetectedFormat.DOCX
            null, "", "application/octet-stream", "binary/octet-stream" -> when (ext) {
                "pdf" -> DetectedFormat.PDF
                "txt", "md", "text" -> DetectedFormat.TXT
                "docx" -> DetectedFormat.DOCX
                else -> DetectedFormat.UNSUPPORTED
            }
            else -> DetectedFormat.UNSUPPORTED
        }
    }

    fun extractFromBytes(
        bytes: ByteArray,
        mimeType: String?,
        fileName: String?,
    ): ExtractionResult {
        if (bytes.size > MAX_DOCUMENT_BYTES) {
            return ExtractionResult(
                status = "too_large",
                documentType = null,
                extractedText = "",
                byteLength = bytes.size,
                userMessage = "Selected document exceeds the 10 MB local extraction limit.",
            )
        }
        if (bytes.isEmpty()) {
            return ExtractionResult(
                status = "empty",
                documentType = null,
                extractedText = "",
                byteLength = 0,
                userMessage = "Selected file is empty (0 bytes).",
            )
        }

        return when (resolveFormat(mimeType, fileName)) {
            DetectedFormat.PDF -> extractPdf(bytes)
            DetectedFormat.TXT -> extractPlainText(bytes)
            DetectedFormat.DOCX -> extractDocx(bytes)
            DetectedFormat.UNSUPPORTED -> ExtractionResult(
                status = "unsupported_mime",
                documentType = null,
                extractedText = "",
                byteLength = bytes.size,
                userMessage = "Unsupported file format. Enprive supports local PDF, TXT, and DOCX policy documents.",
            )
        }
    }

    fun extractPdf(bytes: ByteArray): ExtractionResult {
        if (bytes.size < 5 || !startsWithAscii(bytes, "%PDF-")) {
            return ExtractionResult(
                status = "corrupt",
                documentType = "pdf",
                extractedText = "",
                byteLength = bytes.size,
                userMessage = "File does not appear to be a valid PDF document.",
            )
        }

        var doc: PDDocument? = null
        return try {
            doc = PDDocument.load(ByteArrayInputStream(bytes))
            val pageCount = doc.numberOfPages
            if (pageCount <= 0) {
                return ExtractionResult(
                    status = "empty",
                    documentType = "pdf",
                    extractedText = "",
                    byteLength = bytes.size,
                    pageCount = 0,
                    userMessage = "PDF contains no readable pages.",
                )
            }
            val stripper = PDFTextStripper().apply {
                sortByPosition = true
            }
            val raw = stripper.getText(doc) ?: ""
            val normalized = normalizeExtractedText(raw)
            if (normalized.isEmpty()) {
                ExtractionResult(
                    status = "empty",
                    documentType = "pdf",
                    extractedText = "",
                    byteLength = bytes.size,
                    pageCount = pageCount,
                    userMessage = "This PDF contains no selectable text (it may consist only of scanned images). Paste the privacy policy text directly instead.",
                )
            } else {
                ExtractionResult(
                    status = "ok",
                    documentType = "pdf",
                    extractedText = normalized,
                    byteLength = bytes.size,
                    pageCount = pageCount,
                    userMessage = "Extracted text locally from $pageCount PDF page${if (pageCount == 1) "" else "s"}.",
                )
            }
        } catch (_: InvalidPasswordException) {
            ExtractionResult(
                status = "password_protected",
                documentType = "pdf",
                extractedText = "",
                byteLength = bytes.size,
                userMessage = "This PDF is password-protected or encrypted and cannot be read automatically. Export an unlocked copy or paste the text directly.",
            )
        } catch (_: SecurityException) {
            ExtractionResult(
                status = "password_protected",
                documentType = "pdf",
                extractedText = "",
                byteLength = bytes.size,
                userMessage = "This PDF restricts text extraction.",
            )
        } catch (_: LinkageError) {
            ExtractionResult(
                status = "corrupt",
                documentType = "pdf",
                extractedText = "",
                byteLength = bytes.size,
                userMessage = "This PDF uses an unsupported image codec or stream that cannot be extracted locally. Paste the privacy policy text directly instead.",
            )
        } catch (_: Exception) {
            ExtractionResult(
                status = "corrupt",
                documentType = "pdf",
                extractedText = "",
                byteLength = bytes.size,
                userMessage = "Could not parse this PDF document locally. The file may be corrupted or unsupported.",
            )
        } finally {
            try {
                doc?.close()
            } catch (_: Exception) {}
        }
    }

    fun extractPlainText(bytes: ByteArray): ExtractionResult {
        // Detect mislabelled binary files (e.g. PDF/ZIP renamed to .txt)
        if (startsWithAscii(bytes, "%PDF-") || startsWithBytes(bytes, byteArrayOf(0x50, 0x4B, 0x03, 0x04))) {
            return ExtractionResult(
                status = "corrupt",
                documentType = "txt",
                extractedText = "",
                byteLength = bytes.size,
                userMessage = "File contents appear binary despite a plain-text extension.",
            )
        }

        val (charset, offset) = detectTextEncoding(bytes)
        if (charset == Charsets.UTF_8) {
            val sampleLen = minOf(bytes.size, 512)
            for (i in offset until sampleLen) {
                if (bytes[i].toInt() == 0) {
                    return ExtractionResult(
                        status = "corrupt",
                        documentType = "txt",
                        extractedText = "",
                        byteLength = bytes.size,
                        userMessage = "Binary data detected inside plain-text file.",
                    )
                }
            }
        }

        val decoded = String(bytes, offset, bytes.size - offset, charset)
        val normalized = normalizeExtractedText(decoded)
        if (normalized.isEmpty()) {
            return ExtractionResult(
                status = "empty",
                documentType = "txt",
                extractedText = "",
                byteLength = bytes.size,
                userMessage = "Text document contained no readable text.",
            )
        }
        return ExtractionResult(
            status = "ok",
            documentType = "txt",
            extractedText = normalized,
            byteLength = bytes.size,
            userMessage = "Extracted plain-text policy locally.",
        )
    }

    fun extractDocx(bytes: ByteArray): ExtractionResult {
        // Encrypted Office docs are stored in an OLE2 Compound File container
        if (startsWithBytes(
                bytes,
                byteArrayOf(0xD0.toByte(), 0xCF.toByte(), 0x11.toByte(), 0xE0.toByte()),
            )
        ) {
            return ExtractionResult(
                status = "password_protected",
                documentType = "docx",
                extractedText = "",
                byteLength = bytes.size,
                userMessage = "This Word document is encrypted or password-protected and cannot be extracted automatically.",
            )
        }

        if (!startsWithBytes(bytes, byteArrayOf(0x50, 0x4B, 0x03, 0x04))) {
            return ExtractionResult(
                status = "corrupt",
                documentType = "docx",
                extractedText = "",
                byteLength = bytes.size,
                userMessage = "File does not appear to be a valid DOCX archive.",
            )
        }

        var documentXmlBytes: ByteArray? = null
        var sawEncryptedPackage = false

        try {
            ZipInputStream(ByteArrayInputStream(bytes)).use { zis ->
                var entryCount = 0
                var totalUncompressed = 0L
                val buf = ByteArray(8192)

                while (true) {
                    val entry = zis.nextEntry ?: break
                    entryCount++
                    if (entryCount > MAX_ZIP_ENTRIES) {
                        return ExtractionResult(
                            status = "corrupt",
                            documentType = "docx",
                            extractedText = "",
                            byteLength = bytes.size,
                            userMessage = "DOCX archive exceeded entry safety limits.",
                        )
                    }
                    val entryName = entry.name.lowercase()
                    if (entryName == "encryptedpackage" || entryName == "encryptioninfo") {
                        sawEncryptedPackage = true
                    }

                    val collectXml = entryName == "word/document.xml"
                    val xmlOut = if (collectXml) ByteArrayOutputStream() else null

                    while (true) {
                        val n = zis.read(buf)
                        if (n <= 0) break
                        totalUncompressed += n
                        if (totalUncompressed > MAX_ZIP_UNCOMPRESSED_BYTES) {
                            return ExtractionResult(
                                status = "too_large",
                                documentType = "docx",
                                extractedText = "",
                                byteLength = bytes.size,
                                userMessage = "DOCX uncompressed contents exceed local safety limits.",
                            )
                        }
                        if (collectXml && xmlOut != null) {
                            if (xmlOut.size() + n > MAX_DOCUMENT_BYTES) {
                                return ExtractionResult(
                                    status = "too_large",
                                    documentType = "docx",
                                    extractedText = "",
                                    byteLength = bytes.size,
                                    userMessage = "DOCX text stream exceeds local safety limits.",
                                )
                            }
                            xmlOut.write(buf, 0, n)
                        }
                    }

                    if (collectXml && xmlOut != null) {
                        documentXmlBytes = xmlOut.toByteArray()
                    }
                    zis.closeEntry()
                }
            }
        } catch (_: ZipException) {
            return ExtractionResult(
                status = "corrupt",
                documentType = "docx",
                extractedText = "",
                byteLength = bytes.size,
                userMessage = "Could not open DOCX archive; file may be corrupted.",
            )
        } catch (_: Exception) {
            return ExtractionResult(
                status = "corrupt",
                documentType = "docx",
                extractedText = "",
                byteLength = bytes.size,
                userMessage = "Could not extract DOCX document locally.",
            )
        }

        if (sawEncryptedPackage) {
            return ExtractionResult(
                status = "password_protected",
                documentType = "docx",
                extractedText = "",
                byteLength = bytes.size,
                userMessage = "This DOCX file is password-protected or encrypted.",
            )
        }

        val xmlBytes = documentXmlBytes
            ?: return ExtractionResult(
                status = "corrupt",
                documentType = "docx",
                extractedText = "",
                byteLength = bytes.size,
                userMessage = "DOCX archive is missing readable document content (word/document.xml).",
            )

        return try {
            val factory = DocumentBuilderFactory.newInstance().apply {
                isNamespaceAware = true
                isExpandEntityReferences = false
                setFeature(XMLConstants.FEATURE_SECURE_PROCESSING, true)
                setFeature("http://apache.org/xml/features/disallow-doctype-decl", true)
                setFeature("http://xml.org/sax/features/external-general-entities", false)
                setFeature("http://xml.org/sax/features/external-parameter-entities", false)
                setFeature("http://apache.org/xml/features/nonvalidating/load-external-dtd", false)
            }
            val doc = factory.newDocumentBuilder().parse(ByteArrayInputStream(xmlBytes))
            val builder = StringBuilder()
            appendDocxNodeText(doc.documentElement, builder)
            val normalized = normalizeExtractedText(builder.toString())
            if (normalized.isEmpty()) {
                ExtractionResult(
                    status = "empty",
                    documentType = "docx",
                    extractedText = "",
                    byteLength = bytes.size,
                    userMessage = "DOCX document contained no readable text.",
                )
            } else {
                ExtractionResult(
                    status = "ok",
                    documentType = "docx",
                    extractedText = normalized,
                    byteLength = bytes.size,
                    userMessage = "Extracted DOCX privacy policy text locally.",
                )
            }
        } catch (_: Exception) {
            ExtractionResult(
                status = "corrupt",
                documentType = "docx",
                extractedText = "",
                byteLength = bytes.size,
                userMessage = "Could not parse DOCX XML content cleanly.",
            )
        }
    }

    private fun appendDocxNodeText(node: Node, out: StringBuilder) {
        if (node.nodeType == Node.TEXT_NODE) {
            out.append(node.nodeValue ?: "")
            return
        }
        val local = node.localName ?: node.nodeName.substringAfter(':')
        when (local) {
            "p", "tr" -> {
                if (out.isNotEmpty() && !out.endsWith("\n")) {
                    out.append('\n')
                }
            }
            "br", "cr" -> out.append('\n')
            "tab" -> out.append(' ')
            "tc" -> {
                if (out.isNotEmpty() && !out.endsWith(" ") && !out.endsWith("\n")) {
                    out.append(' ')
                }
            }
            // Skip deleted text or field instructions if present
            "delText", "instrText" -> return
        }

        if (node is Element || node.hasChildNodes()) {
            val children = node.childNodes
            for (i in 0 until children.length) {
                appendDocxNodeText(children.item(i), out)
            }
        }
        if (local == "p" || local == "tr") {
            if (!out.endsWith("\n")) {
                out.append('\n')
            }
        }
    }

    private fun detectTextEncoding(bytes: ByteArray): Pair<Charset, Int> {
        if (bytes.size >= 3 &&
            bytes[0] == 0xEF.toByte() &&
            bytes[1] == 0xBB.toByte() &&
            bytes[2] == 0xBF.toByte()
        ) {
            return Charsets.UTF_8 to 3
        }
        if (bytes.size >= 2 && bytes[0] == 0xFE.toByte() && bytes[1] == 0xFF.toByte()) {
            return Charsets.UTF_16BE to 2
        }
        if (bytes.size >= 2 && bytes[0] == 0xFF.toByte() && bytes[1] == 0xFE.toByte()) {
            return Charsets.UTF_16LE to 2
        }
        return Charsets.UTF_8 to 0
    }

    private fun normalizeExtractedText(raw: String): String {
        return raw
            .replace("\r\n", "\n")
            .replace('\r', '\n')
            .lineSequence()
            .map { line -> line.replace(Regex("[ \\t\\u00A0]+"), " ").trim() }
            .filter { it.isNotEmpty() }
            .joinToString("\n")
            .trim()
    }

    private fun startsWithAscii(bytes: ByteArray, prefix: String): Boolean {
        val prefixBytes = prefix.toByteArray(Charsets.US_ASCII)
        return startsWithBytes(bytes, prefixBytes)
    }

    private fun startsWithBytes(bytes: ByteArray, prefix: ByteArray): Boolean {
        if (bytes.size < prefix.size) return false
        for (i in prefix.indices) {
            if (bytes[i] != prefix[i]) return false
        }
        return true
    }
}
