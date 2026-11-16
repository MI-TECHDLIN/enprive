package com.example.enprive

import android.content.ContentResolver
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.OpenableColumns
import java.net.URI

/**
 * Normalizes incoming Android `ACTION_SEND` metadata before choosing between
 * text/URL analysis and local document extraction.
 */
data class SendShareCandidateUri(
    val uriString: String,
    val scheme: String?,
    val resolvedMime: String?,
    val fileName: String?,
    val fromExtraStream: Boolean,
)

data class SendShareInput(
    val declaredMimeType: String?,
    val extraText: String?,
    val subject: String?,
    val candidateUris: List<SendShareCandidateUri>,
)

sealed class SendShareRoute {
    data class TextOrUrl(
        val text: String,
        val subject: String?,
    ) : SendShareRoute()

    data class DocumentUri(
        val uriString: String,
        val declaredMimeType: String?,
        val fileName: String?,
    ) : SendShareRoute()

    data class Rejected(
        val reasonCode: String,
        val userMessage: String,
    ) : SendShareRoute()
}

/**
 * Deterministic `ACTION_SEND` router fixing Chrome link-share precedence where an
 * incidental screenshot/preview PNG in `clipData` previously shadowed a valid
 * `text/plain` URL in `Intent.EXTRA_TEXT`, while preserving genuine document
 * shares (PDF, TXT, DOCX) and safely rejecting unsupported images or empty shares.
 */
object IncomingShareRouter {
    private val HTTP_URL_REGEX = Regex("""https?://[^\s<>"]+""", RegexOption.IGNORE_CASE)
    private const val TRAILING_URL_PUNCTUATION = ".,;:!?)]}'\""

    fun classifySendShare(input: SendShareInput): SendShareRoute {
        val cleanDeclaredMime = normalizeMime(input.declaredMimeType)
        val trimmedText = input.extraText?.trim()?.takeIf { it.isNotEmpty() }
        val trimmedSubject = input.subject?.trim()?.takeIf { it.isNotEmpty() }
        val sharedPublicUrl = extractSharedPublicHttpUrl(trimmedText)

        // 1. Prioritize genuine supported binary/structured documents (PDF / DOCX).
        val pdfOrDocx = firstMatchingDocumentCandidate(
            candidates = input.candidateUris,
            declaredMime = cleanDeclaredMime,
            hasExtraText = trimmedText != null,
            allowedFormats = setOf(
                DocumentTextExtractor.DetectedFormat.PDF,
                DocumentTextExtractor.DetectedFormat.DOCX,
            ),
        )
        if (pdfOrDocx != null) {
            return SendShareRoute.DocumentUri(
                uriString = pdfOrDocx.uriString,
                declaredMimeType = pdfOrDocx.resolvedMime ?: cleanDeclaredMime,
                fileName = pdfOrDocx.fileName,
            )
        }

        // 2. Preserve genuine TXT/MD document file shares rather than converting them
        // into plain-text paste, except when Chrome attaches a non-stream preview
        // alongside an EXTRA_TEXT link share.
        val txtDocument = firstMatchingDocumentCandidate(
            candidates = input.candidateUris,
            declaredMime = cleanDeclaredMime,
            hasExtraText = trimmedText != null,
            allowedFormats = setOf(DocumentTextExtractor.DetectedFormat.TXT),
        )
        if (txtDocument != null &&
            sharedPublicUrl == null &&
            (txtDocument.fromExtraStream || trimmedText == null)
        ) {
            return SendShareRoute.DocumentUri(
                uriString = txtDocument.uriString,
                declaredMimeType = txtDocument.resolvedMime ?: cleanDeclaredMime,
                fileName = txtDocument.fileName,
            )
        }

        // 3. Browser/link shares carrying a valid HTTP(S) URL in EXTRA_TEXT must
        // route to URL retrieval even when Chrome includes a preview PNG in clipData.
        if (sharedPublicUrl != null) {
            return SendShareRoute.TextOrUrl(
                text = trimmedText!!,
                subject = trimmedSubject,
            )
        }

        // 4. Plain-text shares without a competing explicit media EXTRA_STREAM
        // (or with an incidental preview image thumbnail alongside text/plain MIME)
        // continue into the shared-text flow.
        val explicitMediaStream = input.candidateUris.firstOrNull { candidate ->
            candidate.fromExtraStream && isExplicitlyNonTextMedia(candidate, cleanDeclaredMime)
        }
        if (trimmedText != null && explicitMediaStream == null) {
            return SendShareRoute.TextOrUrl(
                text = trimmedText,
                subject = trimmedSubject,
            )
        }

        // 5. Fallback for explicit non-supported stream shares (e.g. PNG-only share)
        // or standalone HTTP(S) link passed only inside clipData URI list.
        val primaryStream = explicitMediaStream
            ?: input.candidateUris.firstOrNull { it.fromExtraStream }
            ?: input.candidateUris.firstOrNull()
        if (primaryStream != null) {
            val scheme = primaryStream.scheme?.lowercase()
            if (scheme == "http" || scheme == "https") {
                val clipUrl = extractSharedPublicHttpUrl(primaryStream.uriString)
                if (clipUrl != null) {
                    return SendShareRoute.TextOrUrl(
                        text = clipUrl,
                        subject = trimmedSubject,
                    )
                }
            }
            if (scheme == "content" || scheme == "file") {
                return SendShareRoute.DocumentUri(
                    uriString = primaryStream.uriString,
                    declaredMimeType = primaryStream.resolvedMime ?: cleanDeclaredMime,
                    fileName = primaryStream.fileName,
                )
            }
            return SendShareRoute.Rejected(
                reasonCode = "invalid_share",
                userMessage = "This shared link or file address could not be opened safely. Paste the privacy policy text, enter a public https:// link, or choose a PDF, TXT, or DOCX file inside Enprive.",
            )
        }

        // 6. Malformed or empty share payload.
        return SendShareRoute.Rejected(
            reasonCode = "empty_share",
            userMessage = "Nothing readable was included in that share. Paste the privacy policy text, enter a public https:// link, or choose a PDF, TXT, or DOCX file inside Enprive.",
        )
    }

    /**
     * Extracts a single valid public `http://` or `https://` URL when [rawText]
     * represents a browser share ("Title - https://...") rather than full policy prose.
     */
    fun extractSharedPublicHttpUrl(rawText: String?): String? {
        val trimmed = rawText?.trim() ?: return null
        if (trimmed.isEmpty()) return null

        val matches = HTTP_URL_REGEX.findAll(trimmed).toList()
        if (matches.size != 1) return null

        var candidate = matches.first().value
        while (candidate.isNotEmpty() &&
            TRAILING_URL_PUNCTUATION.contains(candidate.last())
        ) {
            candidate = candidate.dropLast(1)
        }

        val parsed = try {
            URI(candidate)
        } catch (_: Exception) {
            return null
        }
        val scheme = parsed.scheme?.lowercase()
        val host = parsed.host?.trim()
        if ((scheme != "http" && scheme != "https") || host.isNullOrEmpty()) {
            return null
        }

        val remainder = trimmed.replaceFirst(matches.first().value, "").trim()
        if (remainder.isEmpty()) return candidate

        val extraWords = remainder.split(Regex("""\s+""")).count { it.isNotBlank() }
        return if (remainder.length <= 140 && extraWords <= 14) candidate else null
    }

    fun fromSendIntent(
        intent: Intent,
        contentResolver: ContentResolver,
    ): SendShareRoute {
        val extraText = intent.getStringExtra(Intent.EXTRA_TEXT)
            ?: intent.getCharSequenceExtra(Intent.EXTRA_TEXT)?.toString()
        val subject = intent.getStringExtra(Intent.EXTRA_SUBJECT)
            ?: intent.getCharSequenceExtra(Intent.EXTRA_SUBJECT)?.toString()
        val declaredMime = intent.type

        val candidates = mutableListOf<SendShareCandidateUri>()
        val seenUris = mutableSetOf<String>()

        fun addUriCandidate(uri: Uri?, fromExtraStream: Boolean) {
            if (uri == null) return
            val uriStr = uri.toString().trim()
            if (uriStr.isEmpty() || !seenUris.add(uriStr)) return

            var resolvedMime: String? = null
            var displayName: String? = null
            if (uri.scheme.equals("content", ignoreCase = true)) {
                resolvedMime = try {
                    contentResolver.getType(uri)
                } catch (_: Exception) {
                    null
                }
                try {
                    contentResolver.query(
                        uri,
                        arrayOf(OpenableColumns.DISPLAY_NAME),
                        null,
                        null,
                        null,
                    )?.use { cursor ->
                        if (cursor.moveToFirst()) {
                            val idx = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                            if (idx >= 0 && !cursor.isNull(idx)) {
                                displayName = cursor.getString(idx)
                            }
                        }
                    }
                } catch (_: Exception) {
                    // Best-effort metadata inspection; extraction enforces SecurityException boundaries.
                }
            } else {
                displayName = uri.lastPathSegment
            }

            candidates.add(
                SendShareCandidateUri(
                    uriString = uriStr,
                    scheme = uri.scheme,
                    resolvedMime = resolvedMime,
                    fileName = displayName,
                    fromExtraStream = fromExtraStream,
                )
            )
        }

        val extraStream: Uri? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            intent.getParcelableExtra(Intent.EXTRA_STREAM, Uri::class.java)
        } else {
            @Suppress("DEPRECATION")
            intent.getParcelableExtra(Intent.EXTRA_STREAM)
        }
        addUriCandidate(extraStream, fromExtraStream = true)

        val clipData = intent.clipData
        if (clipData != null) {
            for (i in 0 until clipData.itemCount) {
                addUriCandidate(clipData.getItemAt(i).uri, fromExtraStream = false)
            }
        }

        return classifySendShare(
            SendShareInput(
                declaredMimeType = declaredMime,
                extraText = extraText,
                subject = subject,
                candidateUris = candidates,
            )
        )
    }

    private fun firstMatchingDocumentCandidate(
        candidates: List<SendShareCandidateUri>,
        declaredMime: String?,
        hasExtraText: Boolean,
        allowedFormats: Set<DocumentTextExtractor.DetectedFormat>,
    ): SendShareCandidateUri? {
        val ordered = candidates.sortedByDescending { it.fromExtraStream }
        for (candidate in ordered) {
            val effectiveMime = candidate.resolvedMime?.let(::normalizeMime)
                ?: if (candidate.fromExtraStream || !hasExtraText) declaredMime else null
            val format = DocumentTextExtractor.resolveFormat(
                mimeType = effectiveMime,
                fileName = candidate.fileName ?: lastSegmentFromUriString(candidate.uriString),
            )
            if (format in allowedFormats &&
                (candidate.scheme.equals("content", ignoreCase = true) ||
                    candidate.scheme.equals("file", ignoreCase = true))
            ) {
                return candidate
            }
        }
        return null
    }

    private fun isExplicitlyNonTextMedia(
        candidate: SendShareCandidateUri,
        cleanDeclaredMime: String?,
    ): Boolean {
        val mime = normalizeMime(candidate.resolvedMime) ?: cleanDeclaredMime ?: ""
        return mime.startsWith("image/") ||
            mime.startsWith("video/") ||
            mime.startsWith("audio/") ||
            mime == "application/zip" ||
            mime == "application/octet-stream"
    }

    private fun lastSegmentFromUriString(uriString: String): String? {
        return try {
            URI(uriString).path?.substringAfterLast('/')
        } catch (_: Exception) {
            uriString.substringAfterLast('/', "").takeIf { it.isNotEmpty() }
        }
    }

    private fun normalizeMime(raw: String?): String? =
        raw?.substringBefore(';')?.trim()?.lowercase()?.takeIf { it.isNotEmpty() }
}
