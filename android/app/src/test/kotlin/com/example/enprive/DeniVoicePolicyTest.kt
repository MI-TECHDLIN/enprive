package com.example.enprive

import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.util.concurrent.atomic.AtomicInteger
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.TimeoutCancellationException
import kotlinx.coroutines.delay
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withTimeout
import org.junit.Assert.assertArrayEquals
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Assert.fail
import org.junit.Test

class DeniVoicePolicyTest {

    @Test
    fun `verified Gemini 3_8 Flash TTS model and Deni prebuilt voice constants match docs`() {
        assertEquals("gemini-3.8-flash-tts", DeniVoicePolicy.CLOUD_TTS_MODEL_NAME)
        assertEquals("Puck", DeniVoicePolicy.DENI_PREBUILT_VOICE_NAME)
        assertEquals(24_000, DeniVoicePolicy.PCM_SAMPLE_RATE_HZ)
        assertEquals(1, DeniVoicePolicy.PCM_CHANNELS)
        assertEquals(16, DeniVoicePolicy.PCM_BITS_PER_SAMPLE)
        assertEquals(20_000L, DeniVoicePolicy.CLOUD_TTS_FIRST_CHUNK_TIMEOUT_MS)
        assertEquals(45_000L, DeniVoicePolicy.CLOUD_TTS_TOTAL_TIMEOUT_MS)
        assertFalse(HybridAiPolicy.supportsThinkingLevel(DeniVoicePolicy.CLOUD_TTS_MODEL_NAME))
    }

    @Test
    fun `unconsented cloud TTS request is blocked with zero network attempts`() = runBlocking {
        val attempts = AtomicInteger(0)
        var blockedCode: String? = null

        val result = DeniVoicePolicy.executeSingleCloudTtsAttempt(
            cloudConsent = false,
            rawText = "Here is a plain summary of what stood out.",
            onBlocked = { code, _ ->
                blockedCode = code
                "BLOCKED"
            },
            onFailure = { _, _ ->
                fail("Unconsented request should block before failure handler")
                "FAILED"
            },
            onAttempt = {
                attempts.incrementAndGet()
                "SHOULD_NOT_EXECUTE"
            },
        )

        assertEquals("BLOCKED", result)
        assertEquals("CLOUD_CONSENT_REQUIRED", blockedCode)
        assertEquals(0, attempts.get())
    }

    @Test
    fun `blank or tag-only text blocks before invoking cloud TTS`() = runBlocking {
        val attempts = AtomicInteger(0)
        var blockedCode: String? = null

        val result = DeniVoicePolicy.executeSingleCloudTtsAttempt(
            cloudConsent = true,
            rawText = "   <whispers> [Audio Profile: pirate]   ",
            onBlocked = { code, _ ->
                blockedCode = code
                "BLOCKED"
            },
            onFailure = { _, _ ->
                fail("Empty sanitized text should block before failure handler")
                "FAILED"
            },
            onAttempt = {
                attempts.incrementAndGet()
                "SHOULD_NOT_EXECUTE"
            },
        )

        assertEquals("BLOCKED", result)
        assertEquals("EMPTY_TEXT", blockedCode)
        assertEquals(0, attempts.get())
    }

    @Test
    fun `consented cloud TTS executes strictly once and never retries on errors`() = runBlocking {
        val attempts = AtomicInteger(0)
        val failures = AtomicInteger(0)

        val result = DeniVoicePolicy.executeSingleCloudTtsAttempt(
            cloudConsent = true,
            rawText = "Plain summary sentence.",
            onBlocked = { _, _ -> fail("Consented call must not block"); "" },
            onFailure = { info, _ ->
                failures.incrementAndGet()
                info.errorCode
            },
            onAttempt = {
                attempts.incrementAndGet()
                throw RuntimeException("HTTP 429 quota exceeded")
            },
        )

        assertEquals("RuntimeException", result)
        assertEquals(1, attempts.get())
        assertEquals(1, failures.get())
    }

    @Test
    fun `cloud TTS timeout and user cancellation propagate via onCancel without entering failure fallback`() =
        runBlocking {
            val timeoutAttempts = AtomicInteger(0)
            val timeoutCancels = AtomicInteger(0)
            val timeoutFailures = AtomicInteger(0)

            try {
                DeniVoicePolicy.executeSingleCloudTtsAttempt<String>(
                    cloudConsent = true,
                    rawText = "Plain summary sentence.",
                    onBlocked = { _, _ -> fail("Must not block"); "" },
                    onCancel = { ce ->
                        timeoutCancels.incrementAndGet()
                        assertTrue(ce is TimeoutCancellationException)
                    },
                    onFailure = { _, _ ->
                        timeoutFailures.incrementAndGet()
                        "FALLBACK"
                    },
                    onAttempt = {
                        timeoutAttempts.incrementAndGet()
                        withTimeout(15L) {
                            delay(2_000L)
                            "LATE"
                        }
                    },
                )
                fail("Expected TimeoutCancellationException")
            } catch (_: TimeoutCancellationException) {
            }

            assertEquals(1, timeoutAttempts.get())
            assertEquals(1, timeoutCancels.get())
            assertEquals(0, timeoutFailures.get())

            val cancelAttempts = AtomicInteger(0)
            val cancelHooks = AtomicInteger(0)
            val cancelFailures = AtomicInteger(0)

            try {
                DeniVoicePolicy.executeSingleCloudTtsAttempt<String>(
                    cloudConsent = true,
                    rawText = "Plain summary sentence.",
                    onBlocked = { _, _ -> fail("Must not block"); "" },
                    onCancel = { cancelHooks.incrementAndGet() },
                    onFailure = { _, _ ->
                        cancelFailures.incrementAndGet()
                        "FALLBACK"
                    },
                    onAttempt = {
                        cancelAttempts.incrementAndGet()
                        throw HybridAiPolicy.UserAnalysisCancelledException()
                    },
                )
                fail("Expected UserAnalysisCancelledException")
            } catch (_: CancellationException) {
            }

            assertEquals(1, cancelAttempts.get())
            assertEquals(1, cancelHooks.get())
            assertEquals(0, cancelFailures.get())
        }

    @Test
    fun `single generation guard rejects duplicate attempt on same TTS operation`() = runBlocking {
        val guard = HybridAiPolicy.SingleGenerationGuard()
        guard.acquireSingleAttempt()
        val failures = AtomicInteger(0)
        val result = DeniVoicePolicy.executeSingleCloudTtsAttempt(
            cloudConsent = true,
            rawText = "Plain summary text.",
            guard = guard,
            onBlocked = { _, _ -> fail("Should hit single-attempt guard"); "" },
            onFailure = { info, _ ->
                failures.incrementAndGet()
                info.errorCode
            },
            onAttempt = {
                fail("Second attempt must be prevented by guard")
                ""
            },
        )
        assertEquals("IllegalStateException", result)
        assertEquals(1, failures.get())
    }

    @Test
    fun `normalizeSpeechText strips vocal tags and legacy directives and bounds length cleanly`() {
        val dirty =
            "[Audio Profile: dramatic] <whispers>Hello parents.<sigh> This app keeps recordings.\u0007  [Scene: dark room]"
        val cleaned = DeniVoicePolicy.normalizeSpeechText(dirty)
        assertEquals("Hello parents. This app keeps recordings.", cleaned)
        assertFalse(cleaned.contains("<"))
        assertFalse(cleaned.contains("Audio Profile"))

        val longText = "First clear sentence. " + "Word ".repeat(40) + "Last sentence."
        val capped = DeniVoicePolicy.normalizeSpeechText(longText, maxChars = 60)
        assertTrue(capped.length <= 60)
        assertTrue(capped.startsWith("First clear sentence."))
    }

    @Test
    fun `resolveGeminiTtsLanguageCode maps all 12 Enprive locales to official BCP-47 tags`() {
        assertEquals("en-US", DeniVoicePolicy.resolveGeminiTtsLanguageCode("en"))
        assertEquals("ko-KR", DeniVoicePolicy.resolveGeminiTtsLanguageCode("ko"))
        assertEquals("es-ES", DeniVoicePolicy.resolveGeminiTtsLanguageCode("es"))
        assertEquals("fr-FR", DeniVoicePolicy.resolveGeminiTtsLanguageCode("fr"))
        assertEquals("de-DE", DeniVoicePolicy.resolveGeminiTtsLanguageCode("de"))
        assertEquals("ar-XA", DeniVoicePolicy.resolveGeminiTtsLanguageCode("ar"))
        assertEquals("ja-JP", DeniVoicePolicy.resolveGeminiTtsLanguageCode("ja"))
        assertEquals("cmn-CN", DeniVoicePolicy.resolveGeminiTtsLanguageCode("zh"))
        assertEquals("hi-IN", DeniVoicePolicy.resolveGeminiTtsLanguageCode("hi"))
        assertEquals("pt-BR", DeniVoicePolicy.resolveGeminiTtsLanguageCode("pt"))
        assertEquals("it-IT", DeniVoicePolicy.resolveGeminiTtsLanguageCode("it"))
        assertEquals("ru-RU", DeniVoicePolicy.resolveGeminiTtsLanguageCode("ru"))
        assertEquals("en-US", DeniVoicePolicy.resolveGeminiTtsLanguageCode("unknown"))
    }

    @Test
    fun `extractPcm16Bytes handles raw PCM, odd-byte alignment, and WAV containers with extra subchunks`() {
        // 1. Raw PCM bytes unchanged (even length)
        val rawPcm = byteArrayOf(1, 2, 3, 4, 5, 6)
        assertArrayEquals(rawPcm, DeniVoicePolicy.extractPcm16Bytes(rawPcm, "audio/l16; rate=24000"))

        // 2. Odd-length PCM trims final incomplete byte cleanly
        val oddPcm = byteArrayOf(1, 2, 3, 4, 5)
        assertArrayEquals(byteArrayOf(1, 2, 3, 4), DeniVoicePolicy.extractPcm16Bytes(oddPcm, "audio/l16"))

        // 3. Standard RIFF/WAVE with extra JUNK metadata chunk before data chunk
        val samplePayload = byteArrayOf(10, 20, 30, 40, 50, 60, 70, 80)
        val junkData = byteArrayOf(0, 0, 0, 0)
        val wav = ByteBuffer.allocate(12 + 24 + 12 + 8 + samplePayload.size)
            .order(ByteOrder.LITTLE_ENDIAN)
            .apply {
                put("RIFF".toByteArray())
                putInt(capacity() - 8)
                put("WAVE".toByteArray())
                put("fmt ".toByteArray())
                putInt(16)
                putShort(1) // PCM
                putShort(1) // mono
                putInt(24_000)
                putInt(48_000)
                putShort(2)
                putShort(16)
                put("JUNK".toByteArray())
                putInt(junkData.size)
                put(junkData)
                put("data".toByteArray())
                putInt(samplePayload.size)
                put(samplePayload)
            }
            .array()

        assertArrayEquals(samplePayload, DeniVoicePolicy.extractPcm16Bytes(wav, "audio/wav"))
    }

    @Test
    fun `estimatePcmDurationMs calculates accurate 24kHz mono 16-bit duration`() {
        assertEquals(0L, DeniVoicePolicy.estimatePcmDurationMs(0))
        assertEquals(1000L, DeniVoicePolicy.estimatePcmDurationMs(48_000))
        assertEquals(500L, DeniVoicePolicy.estimatePcmDurationMs(24_000))
    }

    @Test
    fun `clampLocalSpeechRate guards NaN, Infinity, and out-of-range rates`() {
        assertEquals(DeniVoicePolicy.DEFAULT_LOCAL_TTS_SPEECH_RATE, DeniVoicePolicy.clampLocalSpeechRate(null))
        assertEquals(DeniVoicePolicy.DEFAULT_LOCAL_TTS_SPEECH_RATE, DeniVoicePolicy.clampLocalSpeechRate(Float.NaN))
        assertEquals(DeniVoicePolicy.MIN_LOCAL_TTS_SPEECH_RATE, DeniVoicePolicy.clampLocalSpeechRate(0.1f))
        assertEquals(DeniVoicePolicy.MAX_LOCAL_TTS_SPEECH_RATE, DeniVoicePolicy.clampLocalSpeechRate(5.0f))
        assertEquals(1.05f, DeniVoicePolicy.clampLocalSpeechRate(1.05f))
    }
}
