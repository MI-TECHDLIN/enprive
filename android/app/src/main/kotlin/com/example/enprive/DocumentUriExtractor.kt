package com.example.enprive

import android.content.ContentResolver
import android.net.Uri
import android.provider.OpenableColumns
import android.util.Log

/**
 * Reads a user-selected or shared content:// document through [ContentResolver]
 * with the size and permission checks applied before local extraction, and
 * returns the method-channel map Dart receives.
 */
object DocumentUriExtractor {
    private const val TAG = "EnpriveHybridAi"

    fun extract(
        contentResolver: ContentResolver,
        uri: Uri,
        declaredMime: String?,
    ): Map<String, Any?> {
        var fileName: String? = null
        var reportedSize: Long? = null

        try {
            contentResolver.query(
                uri,
                arrayOf(OpenableColumns.DISPLAY_NAME, OpenableColumns.SIZE),
                null,
                null,
                null,
            )?.use { cursor ->
                if (cursor.moveToFirst()) {
                    val nameIdx = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                    if (nameIdx >= 0 && !cursor.isNull(nameIdx)) {
                        fileName = cursor.getString(nameIdx)
                    }
                    val sizeIdx = cursor.getColumnIndex(OpenableColumns.SIZE)
                    if (sizeIdx >= 0 && !cursor.isNull(sizeIdx)) {
                        reportedSize = cursor.getLong(sizeIdx)
                    }
                }
            }
        } catch (_: SecurityException) {
            return mapOf(
                "status" to "permission_denied",
                "documentType" to null,
                "fileName" to fileName,
                "mimeType" to declaredMime,
                "byteLength" to 0,
                "extractedText" to "",
                "userMessage" to "Permission to access the selected document was denied by Android.",
            )
        } catch (e: Exception) {
            Log.w(TAG, "Document metadata query fallback (${e.javaClass.simpleName})")
        }

        val resolvedMime = try {
            contentResolver.getType(uri) ?: declaredMime
        } catch (_: Exception) {
            declaredMime
        }

        if (DocumentTextExtractor.resolveFormat(resolvedMime, fileName) ==
            DocumentTextExtractor.DetectedFormat.UNSUPPORTED
        ) {
            return mapOf(
                "status" to "unsupported_mime",
                "documentType" to null,
                "fileName" to fileName,
                "mimeType" to resolvedMime,
                "byteLength" to (reportedSize?.toInt() ?: 0),
                "extractedText" to "",
                "userMessage" to "Unsupported document format (${resolvedMime ?: "unknown"}). Enprive supports local PDF, TXT, and DOCX documents.",
            )
        }

        val maxBytes = DocumentTextExtractor.MAX_DOCUMENT_BYTES.toLong()
        val initialSize = reportedSize
        if (initialSize != null && initialSize > maxBytes) {
            return mapOf(
                "status" to "too_large",
                "documentType" to null,
                "fileName" to fileName,
                "mimeType" to resolvedMime,
                "byteLength" to initialSize.toInt().coerceAtLeast(0),
                "extractedText" to "",
                "userMessage" to "Selected document exceeds the 10 MB local extraction limit.",
            )
        }

        val bytes = try {
            contentResolver.openInputStream(uri)?.use { stream ->
                DocumentTextExtractor.readBoundedBytes(stream)
            }
        } catch (_: SecurityException) {
            return mapOf(
                "status" to "permission_denied",
                "documentType" to null,
                "fileName" to fileName,
                "mimeType" to resolvedMime,
                "byteLength" to 0,
                "extractedText" to "",
                "userMessage" to "Permission to read this document URI expired or was denied.",
            )
        } catch (e: Exception) {
            Log.w(TAG, "Document stream read failed (${e.javaClass.simpleName})")
            return mapOf(
                "status" to "read_error",
                "documentType" to null,
                "fileName" to fileName,
                "mimeType" to resolvedMime,
                "byteLength" to 0,
                "extractedText" to "",
                "userMessage" to "Could not read the selected document from device storage.",
            )
        }

        if (bytes == null) {
            // Either stream returned null or exceeded MAX_DOCUMENT_BYTES during bounded read.
            return mapOf(
                "status" to if (initialSize != null && initialSize > maxBytes) "too_large" else "read_error",
                "documentType" to null,
                "fileName" to fileName,
                "mimeType" to resolvedMime,
                "byteLength" to 0,
                "extractedText" to "",
                "userMessage" to "Document exceeded the 10 MB safety limit or could not be opened.",
            )
        }

        return DocumentTextExtractor
            .extractFromBytes(bytes, mimeType = resolvedMime, fileName = fileName)
            .toChannelMap(fileName = fileName, mimeType = resolvedMime)
    }
}
