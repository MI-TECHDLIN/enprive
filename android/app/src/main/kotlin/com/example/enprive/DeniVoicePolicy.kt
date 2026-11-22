package com.example.enprive

import com.google.firebase.ai.type.PublicPreviewAPI
import java.nio.ByteBuffer
import java.nio.ByteOrder
import kotlinx.coroutines.CancellationException

/**
 * Pure policy, validation, consent-gating, and PCM-decoding utilities for
 * Enprive's Deni Voice synthesis pipeline.
 *
 * Kept strictly Android-framework-free so JVM unit tests verify consent,
 * single-attempt enforcement, prompt-tag sanitization, and PCM extraction
 * without emulator dependencies.
 *
 * Verified against official Firebase AI Logic docs (2026-11-21):
 * - https://firebase.google.com/docs/ai-logic/models.md.txt
 * - https://firebase.google.com/docs/ai-logic/generate-speech.md.txt
 * - https://firebase.google.com/support/release-notes/android
 */
@OptIn(PublicPreviewAPI::class)
object DeniVoicePolicy {
    /** Current Gemini TTS model (billing not required; replaces shut-down 3.1 preview). */
    const val CLOUD_TTS_MODEL_NAME: String = "gemini-3.8-flash-tts"

    /** One expressive multilingual core prebuilt voice reserved for Deni. */
    const val DENI_PREBUILT_VOICE_NAME: String = "Puck"

    /** Concise turn-level style passed via SpeechMetadata.style (never inline text). */
    const val DENI_SPEECH_STYLE: String =
        "warm, calm, clear, friendly, and reassuring, speaking at a steady conversational pace"

    const val PCM_SAMPLE_RATE_HZ: Int = 24_000
    const val PCM_CHANNELS: Int = 1
    const val PCM_BITS_PER_SAMPLE: Int = 16
    const val PCM_BYTES_PER_SECOND: Int = PCM_SAMPLE_RATE_HZ * PCM_CHANNELS * (PCM_BITS_PER_SAMPLE / 8)

    /** Upper bound on spoken script characters sent to TTS to bound quota & audio buffers. */
    const val MAX_TTS_INPUT_CHARS: Int = 3_200

    /** Timeout budgets aligned with HybridAiPolicy D2 remediation. */
    const val CLOUD_TTS_FIRST_CHUNK_TIMEOUT_MS: Long = HybridAiPolicy.CLOUD_FIRST_RESPONSE_TIMEOUT_MS
    const val CLOUD_TTS_TOTAL_TIMEOUT_MS: Long = HybridAiPolicy.CLOUD_TOTAL_TIMEOUT_MS

    const val DEFAULT_LOCAL_TTS_SPEECH_RATE: Float = 0.96f
    const val MIN_LOCAL_TTS_SPEECH_RATE: Float = 0.6f
    const val MAX_LOCAL_TTS_SPEECH_RATE: Float = 1.6f

    private val angleTagPattern = Regex("<[^>]{1,64}>")
    private val legacyDirectiveBracketPattern = Regex(
        "\\[(?:Audio Profile|Scene|Director's Note|whispers|laughs|chuckles|sighs|slowly|excited|pause)[^\\]]*\\]",
        RegexOption.IGNORE_CASE,
    )
    private val controlCharsPattern = Regex("[\\u0000-\\u0008\\u000B\\u000C\\u000E-\\u001F\\u007F]")
    private val multiWhitespacePattern = Regex("\\s+")

    /**
     * Explicit per-operation consent gate for Gemini Cloud TTS.
     * Cloud speech synthesis MUST NEVER execute when [cloudConsent] is false.
     */
    fun isCloudTtsPermitted(cloudConsent: Boolean): Boolean = cloudConsent

    /**
     * Clamps local Android TextToSpeech rate to a safe, intelligible range.
     */
    fun clampLocalSpeechRate(rate: Float?): Float {
        val candidate = rate ?: DEFAULT_LOCAL_TTS_SPEECH_RATE
        if (candidate.isNaN() || candidate.isInfinite()) return DEFAULT_LOCAL_TTS_SPEECH_RATE
        return candidate.coerceIn(MIN_LOCAL_TTS_SPEECH_RATE, MAX_LOCAL_TTS_SPEECH_RATE)
    }

    /**
     * Maps Enprive's supported language codes to the exact BCP-47 tags documented
     * for `gemini-3.8-flash-tts` in Firebase AI Logic docs.
     */
    fun resolveGeminiTtsLanguageCode(languageCode: String): String {
        val base = languageCode.trim().lowercase().split('-', '_').firstOrNull() ?: "en"
        return when (base) {
            "ko" -> "ko-KR"
            "es" -> "es-ES"
            "fr" -> "fr-FR"
            "de" -> "de-DE"
            "ar" -> "ar-XA"
            "ja" -> "ja-JP"
            "zh" -> "cmn-CN"
            "hi" -> "hi-IN"
            "pt" -> "pt-BR"
            "it" -> "it-IT"
            "ru" -> "ru-RU"
            else -> "en-US"
        }
    }

    /**
     * Sanitizes and bounds text before sending to TTS:
     * - Strips control characters.
     * - Strips angle-bracket vocal-burst tags (`<...>`) and legacy `[Audio Profile:...]`
     *   directives so untrusted policy text cannot inject vocal-performance commands.
     * - Normalizes whitespace and caps cleanly at [maxChars].
     */
    fun normalizeSpeechText(rawText: String, maxChars: Int = MAX_TTS_INPUT_CHARS): String {
        if (rawText.isBlank()) return ""
        val sanitized = rawText
            .replace(controlCharsPattern, " ")
            .replace(angleTagPattern, " ")
            .replace(legacyDirectiveBracketPattern, " ")
            .replace(multiWhitespacePattern, " ")
            .trim()
        if (sanitized.length <= maxChars) return sanitized

        val hardCap = maxChars.coerceAtLeast(32)
        val slice = sanitized.substring(0, hardCap)
        val lastSentenceEnd = maxOf(
            slice.lastIndexOf('.'),
            slice.lastIndexOf('!'),
            slice.lastIndexOf('?'),
        )
        if (lastSentenceEnd >= hardCap / 2) {
            return slice.substring(0, lastSentenceEnd + 1).trim()
        }
        val lastSpace = slice.lastIndexOf(' ')
        return if (lastSpace >= hardCap / 2) {
            slice.substring(0, lastSpace).trim()
        } else {
            slice.trim()
        }
    }

    /**
     * Extracts raw 16-bit little-endian mono PCM bytes from a Gemini TTS
     * `InlineDataPart`. Supports both streaming headerless `audio/l16` chunks
     * and unary `audio/wav` RIFF containers (including WAV headers with extra
     * metadata subchunks before `data`), ensuring an even byte count for 16-bit frames.
     */
    fun extractPcm16Bytes(rawAudioBytes: ByteArray, mimeType: String? = null): ByteArray {
        if (rawAudioBytes.isEmpty()) return ByteArray(0)

        val isWavHeader = rawAudioBytes.size >= 12 &&
            rawAudioBytes[0] == 'R'.code.toByte() &&
            rawAudioBytes[1] == 'I'.code.toByte() &&
            rawAudioBytes[2] == 'F'.code.toByte() &&
            rawAudioBytes[3] == 'F'.code.toByte() &&
            rawAudioBytes[8] == 'W'.code.toByte() &&
            rawAudioBytes[9] == 'A'.code.toByte() &&
            rawAudioBytes[10] == 'V'.code.toByte() &&
            rawAudioBytes[11] == 'E'.code.toByte()

        val payload = if (isWavHeader) {
            extractWavDataSubchunk(rawAudioBytes)
        } else if (mimeType?.lowercase()?.contains("wav") == true && rawAudioBytes.size > 44) {
            rawAudioBytes.copyOfRange(44, rawAudioBytes.size)
        } else {
            rawAudioBytes
        }

        // 16-bit PCM requires 2 bytes per sample frame.
        val alignedLen = payload.size - (payload.size % 2)
        return if (alignedLen <= 0) {
            ByteArray(0)
        } else if (alignedLen == payload.size) {
            payload
        } else {
            payload.copyOfRange(0, alignedLen)
        }
    }

    private fun extractWavDataSubchunk(wavBytes: ByteArray): ByteArray {
        var offset = 12
        while (offset + 8 <= wavBytes.size) {
            val isDataChunk = wavBytes[offset] == 'd'.code.toByte() &&
                wavBytes[offset + 1] == 'a'.code.toByte() &&
                wavBytes[offset + 2] == 't'.code.toByte() &&
                wavBytes[offset + 3] == 'a'.code.toByte()
            val chunkSize = ByteBuffer.wrap(wavBytes, offset + 4, 4)
                .order(ByteOrder.LITTLE_ENDIAN)
                .int
                .coerceAtLeast(0)
            val dataStart = offset + 8
            if (isDataChunk) {
                val dataEnd = if (chunkSize > 0) {
                    minOf(wavBytes.size, dataStart + chunkSize)
                } else {
                    wavBytes.size
                }
                return if (dataEnd > dataStart) {
                    wavBytes.copyOfRange(dataStart, dataEnd)
                } else {
                    ByteArray(0)
                }
            }
            // RIFF subchunks are word-aligned (padded by 1 byte if odd size).
            val paddedSize = chunkSize + (chunkSize and 1)
            val nextOffset = dataStart.toLong() + paddedSize.toLong()
            if (nextOffset <= offset.toLong() || nextOffset > wavBytes.size.toLong()) {
                break
            }
            offset = nextOffset.toInt()
        }
        return if (wavBytes.size > 44) {
            wavBytes.copyOfRange(44, wavBytes.size)
        } else {
            ByteArray(0)
        }
    }

    /**
     * Estimates playback duration in milliseconds for 16-bit mono PCM audio.
     */
    fun estimatePcmDurationMs(
        byteCount: Int,
        sampleRateHz: Int = PCM_SAMPLE_RATE_HZ,
    ): Long {
        if (byteCount <= 0 || sampleRateHz <= 0) return 0L
        val bytesPerSecond = sampleRateHz.toLong() * PCM_CHANNELS * (PCM_BITS_PER_SAMPLE / 8)
        return (byteCount.toLong() * 1000L) / bytesPerSecond
    }

    /**
     * Executes at most ONE Gemini Cloud TTS invocation for a consented operation.
     * Enforces:
     * 1. Explicit [cloudConsent] == true (blocks with 0 invocations otherwise).
     * 2. Non-empty sanitized speech text (blocks with 0 invocations otherwise).
     * 3. Per-operation [HybridAiPolicy.SingleGenerationGuard] (0 retries).
     * 4. Unconditional [CancellationException] propagation via [HybridAiPolicy.executeSingleOperation].
     */
    suspend fun <T> executeSingleCloudTtsAttempt(
        cloudConsent: Boolean,
        rawText: String,
        guard: HybridAiPolicy.SingleGenerationGuard = HybridAiPolicy.SingleGenerationGuard(),
        onBlocked: (errorCode: String, reason: String) -> T,
        onCancel: suspend (CancellationException) -> Unit = {},
        onFailure: suspend (HybridAiPolicy.TerminalFailureInfo, Throwable) -> T,
        onAttempt: suspend (normalizedText: String) -> T,
    ): T {
        if (!isCloudTtsPermitted(cloudConsent)) {
            return onBlocked(
                "CLOUD_CONSENT_REQUIRED",
                "Expressive cloud voice requires explicit permission for this check.",
            )
        }
        val normalized = normalizeSpeechText(rawText)
        if (normalized.isEmpty()) {
            return onBlocked(
                "EMPTY_TEXT",
                "Summary text to read aloud cannot be empty.",
            )
        }
        return HybridAiPolicy.executeSingleOperation(
            onRun = {
                guard.acquireSingleAttempt()
                onAttempt(normalized)
            },
            onCancel = onCancel,
            onFailure = onFailure,
        )
    }
}
