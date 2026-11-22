package com.example.enprive

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioFormat
import android.media.AudioManager
import android.media.AudioTrack
import android.speech.tts.TextToSpeech
import android.speech.tts.UtteranceProgressListener
import android.util.Log
import com.google.firebase.Firebase
import com.google.firebase.ai.ai
import com.google.firebase.ai.type.GenerativeBackend
import com.google.firebase.ai.type.InlineDataPart
import com.google.firebase.ai.type.PublicPreviewAPI
import com.google.firebase.ai.type.ResponseModality
import com.google.firebase.ai.type.SpeechConfig
import com.google.firebase.ai.type.SpeechMetadata
import com.google.firebase.ai.type.Voice
import com.google.firebase.ai.type.content
import com.google.firebase.ai.type.generationConfig
import java.util.Locale
import java.util.concurrent.atomic.AtomicBoolean
import java.util.concurrent.atomic.AtomicReference
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.Job
import kotlinx.coroutines.NonCancellable
import kotlinx.coroutines.TimeoutCancellationException
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

/**
 * Native Android voice engine for Deni:
 * - Primary expressive route (strictly opt-in per-operation consent):
 *   Firebase AI Logic `gemini-3.8-flash-tts` with prebuilt voice `Puck`,
 *   App Check replay protection (`useLimitedUseAppCheckTokens = true`),
 *   single-attempt guard, bounded timeouts, and in-memory `AudioTrack` PCM streaming
 *   (no audio files written to disk).
 * - Offline / no-consent / error fallback route:
 *   Native Android `TextToSpeech` with runtime locale availability checks,
 *   utterance completion callbacks, and Android audio-focus handling.
 */
@OptIn(PublicPreviewAPI::class)
class DeniVoicePlayer(
    private val context: Context,
    private val scope: CoroutineScope,
    private val resolveLocalLocale: (String) -> Locale,
    private val onPlaybackEvent: (Map<String, Any?>) -> Unit,
) {
    private val tag = "EnpriveDeniVoice"
    private val audioManager: AudioManager? =
        context.getSystemService(Context.AUDIO_SERVICE) as? AudioManager

    @Volatile
    private var localTts: TextToSpeech? = null

    @Volatile
    private var isLocalTtsReady: Boolean = false

    private val activeCloudJob = AtomicReference<Job?>(null)
    private val activeAudioTrack = AtomicReference<AudioTrack?>(null)
    private val activeRequestId = AtomicReference<String?>(null)
    private val userStoppedCurrentJob = AtomicBoolean(false)
    private val currentFocusRequest = AtomicReference<AudioFocusRequest?>(null)
    private val isReleased = AtomicBoolean(false)

    private val speechAudioAttributes: AudioAttributes = AudioAttributes.Builder()
        .setUsage(AudioAttributes.USAGE_MEDIA)
        .setContentType(AudioAttributes.CONTENT_TYPE_SPEECH)
        .build()

    private val focusChangeListener = AudioManager.OnAudioFocusChangeListener { change ->
        if (change == AudioManager.AUDIOFOCUS_LOSS ||
            change == AudioManager.AUDIOFOCUS_LOSS_TRANSIENT ||
            change == AudioManager.AUDIOFOCUS_LOSS_TRANSIENT_CAN_DUCK
        ) {
            stopAll(emitStoppedEvent = true)
        }
    }

    init {
        initializeLocalTts()
    }

    private fun initializeLocalTts() {
        try {
            val engine = TextToSpeech(context.applicationContext) { status ->
                if (isReleased.get()) return@TextToSpeech
                if (status == TextToSpeech.SUCCESS) {
                    isLocalTtsReady = true
                    try {
                        localTts?.language = Locale.US
                        localTts?.setSpeechRate(DeniVoicePolicy.DEFAULT_LOCAL_TTS_SPEECH_RATE)
                        localTts?.setAudioAttributes(speechAudioAttributes)
                        localTts?.setOnUtteranceProgressListener(
                            object : UtteranceProgressListener() {
                                override fun onStart(utteranceId: String?) {
                                    emitEvent(
                                        requestId = utteranceId ?: activeRequestId.get() ?: "",
                                        state = "playing",
                                        route = "ANDROID_LOCAL_TTS",
                                    )
                                }

                                override fun onDone(utteranceId: String?) {
                                    abandonAudioFocus()
                                    emitEvent(
                                        requestId = utteranceId ?: activeRequestId.get() ?: "",
                                        state = "completed",
                                        route = "ANDROID_LOCAL_TTS",
                                    )
                                }

                                @Deprecated("Deprecated in Java")
                                override fun onError(utteranceId: String?) {
                                    abandonAudioFocus()
                                    emitEvent(
                                        requestId = utteranceId ?: activeRequestId.get() ?: "",
                                        state = "error",
                                        route = "ANDROID_LOCAL_TTS",
                                        errorCode = "LOCAL_TTS_ERROR",
                                    )
                                }

                                override fun onError(utteranceId: String?, errorCode: Int) {
                                    abandonAudioFocus()
                                    emitEvent(
                                        requestId = utteranceId ?: activeRequestId.get() ?: "",
                                        state = "error",
                                        route = "ANDROID_LOCAL_TTS",
                                        errorCode = "LOCAL_TTS_ERROR_$errorCode",
                                    )
                                }

                                override fun onStop(utteranceId: String?, interrupted: Boolean) {
                                    abandonAudioFocus()
                                    if (!interrupted) {
                                        emitEvent(
                                            requestId = utteranceId ?: activeRequestId.get() ?: "",
                                            state = "stopped",
                                            route = "ANDROID_LOCAL_TTS",
                                        )
                                    }
                                }
                            },
                        )
                    } catch (e: Exception) {
                        Log.w(tag, "Local TTS setup note (${e.javaClass.simpleName})")
                    }
                }
            }
            localTts = engine
        } catch (e: Exception) {
            Log.w(tag, "TextToSpeech init note (${e.javaClass.simpleName})")
        }
    }

    /**
     * Checks whether Android's installed local TextToSpeech engine supports
     * [languageCode] without claiming availability before checking runtime data.
     */
    fun checkLocalTtsAvailability(languageCode: String): Map<String, Any?> {
        val targetLocale = resolveLocalLocale(languageCode)
        val engine = localTts
        if (!isLocalTtsReady || engine == null) {
            return mapOf(
                "isReady" to false,
                "isLanguageAvailable" to false,
                "resolvedLocale" to targetLocale.toLanguageTag(),
                "message" to "On-device speech engine is still initializing or unavailable.",
            )
        }
        val availability = try {
            engine.isLanguageAvailable(targetLocale)
        } catch (_: Exception) {
            TextToSpeech.LANG_NOT_SUPPORTED
        }
        val supported = availability == TextToSpeech.LANG_AVAILABLE ||
            availability == TextToSpeech.LANG_COUNTRY_AVAILABLE ||
            availability == TextToSpeech.LANG_COUNTRY_VAR_AVAILABLE
        return mapOf(
            "isReady" to true,
            "isLanguageAvailable" to supported,
            "resolvedLocale" to targetLocale.toLanguageTag(),
            "message" to if (supported) {
                "On-device voice is available for ${targetLocale.displayLanguage}."
            } else {
                "No offline Android voice data is installed for ${targetLocale.displayLanguage}."
            },
        )
    }

    /**
     * Speaks [rawText] strictly on-device via Android's local [TextToSpeech].
     * Preserves backwards compatibility with the existing `speakText` MethodChannel.
     */
    fun speakLocally(
        rawText: String,
        languageCode: String = "en",
        requestId: String? = null,
        speechRate: Float? = null,
    ): Boolean {
        val safeText = DeniVoicePolicy.normalizeSpeechText(rawText)
        val engine = localTts
        if (safeText.isEmpty() || !isLocalTtsReady || engine == null || isReleased.get()) {
            return false
        }

        // Stop any running cloud TTS stream before speaking locally.
        stopCloudOnly()

        val utteranceId = requestId?.takeIf { it.isNotBlank() }
            ?: "enprive_utterance_${System.currentTimeMillis()}"
        activeRequestId.set(utteranceId)

        return try {
            val targetLocale = resolveLocalLocale(languageCode)
            val availability = engine.isLanguageAvailable(targetLocale)
            val isSupported = availability == TextToSpeech.LANG_AVAILABLE ||
                availability == TextToSpeech.LANG_COUNTRY_AVAILABLE ||
                availability == TextToSpeech.LANG_COUNTRY_VAR_AVAILABLE
            if (!isSupported) {
                return false
            }
            val langRes = engine.setLanguage(targetLocale)
            if (langRes == TextToSpeech.LANG_MISSING_DATA ||
                langRes == TextToSpeech.LANG_NOT_SUPPORTED
            ) {
                return false
            }
            engine.setSpeechRate(DeniVoicePolicy.clampLocalSpeechRate(speechRate))
            requestAudioFocus()
            val speakRes = engine.speak(
                safeText,
                TextToSpeech.QUEUE_FLUSH,
                null,
                utteranceId,
            )
            if (speakRes != TextToSpeech.SUCCESS) {
                abandonAudioFocus()
                false
            } else {
                true
            }
        } catch (e: Exception) {
            abandonAudioFocus()
            Log.w(tag, "speakLocally error (${e.javaClass.simpleName})")
            false
        }
    }

    /**
     * Synthesizes and streams Deni's expressive voice via Firebase AI Logic
     * (`gemini-3.8-flash-tts`, prebuilt voice `Puck`) strictly after explicit
     * per-operation [cloudConsent], enforcing App Check replay protection,
     * single-attempt guard, timeout budgets, and deterministic local TTS fallback.
     */
    fun speakWithGeminiTts(
        requestId: String,
        rawText: String,
        languageCode: String,
        cloudConsent: Boolean,
        fallbackToLocalOnFailure: Boolean = true,
        onResult: (Map<String, Any?>) -> Unit,
    ) {
        if (isReleased.get()) {
            onResult(
                mapOf(
                    "status" to "cancelled",
                    "route" to "NONE",
                    "message" to "Voice player is closed.",
                ),
            )
            return
        }

        if (!DeniVoicePolicy.isCloudTtsPermitted(cloudConsent)) {
            onResult(
                mapOf(
                    "status" to "blocked",
                    "route" to "NONE",
                    "errorCode" to "CLOUD_CONSENT_REQUIRED",
                    "message" to "Expressive cloud voice requires explicit permission for this check.",
                ),
            )
            return
        }

        val normalizedText = DeniVoicePolicy.normalizeSpeechText(rawText)
        if (normalizedText.isEmpty()) {
            onResult(
                mapOf(
                    "status" to "failed",
                    "route" to "NONE",
                    "errorCode" to "EMPTY_TEXT",
                    "message" to "Summary text to read aloud cannot be empty.",
                ),
            )
            return
        }

        // Cancel any previous speech cleanly before starting this operation.
        stopAll(emitStoppedEvent = false)
        userStoppedCurrentJob.set(false)
        activeRequestId.set(requestId)

        val job = scope.launch(Dispatchers.IO) {
            var replySent = false
            suspend fun deliver(payload: Map<String, Any?>) {
                if (replySent) return
                replySent = true
                withContext(NonCancellable + Dispatchers.Main) {
                    onResult(payload)
                }
            }

            try {
                val resultMap = DeniVoicePolicy.executeSingleCloudTtsAttempt(
                    cloudConsent = cloudConsent,
                    rawText = normalizedText,
                    onBlocked = { code, reason ->
                        mapOf(
                            "status" to "blocked",
                            "route" to "NONE",
                            "errorCode" to code,
                            "message" to reason,
                        )
                    },
                    onCancel = { ce ->
                        releaseActiveAudioTrack()
                        abandonAudioFocus()

                        val wasUserStopped = userStoppedCurrentJob.get() ||
                            ce is HybridAiPolicy.UserAnalysisCancelledException ||
                            ce.cause is HybridAiPolicy.UserAnalysisCancelledException
                        val isTimeout = !wasUserStopped &&
                            (ce is TimeoutCancellationException ||
                                ce is HybridAiPolicy.AnalysisTimeoutCancellationException ||
                                ce.cause is TimeoutCancellationException ||
                                ce.cause is HybridAiPolicy.AnalysisTimeoutCancellationException)

                        if (isTimeout) {
                            Log.w(
                                tag,
                                "Cloud TTS timed out (model=${DeniVoicePolicy.CLOUD_TTS_MODEL_NAME}, chars=${normalizedText.length})",
                            )
                            val fellBack = fallbackToLocalOnFailure && withContext(NonCancellable + Dispatchers.Main) {
                                speakLocally(
                                    rawText = normalizedText,
                                    languageCode = languageCode,
                                    requestId = "${requestId}_local_fallback",
                                )
                            }
                            if (fellBack) {
                                deliver(
                                    mapOf(
                                        "status" to "fallback_local",
                                        "route" to "ANDROID_LOCAL_TTS",
                                        "voiceName" to null,
                                        "modelName" to DeniVoicePolicy.CLOUD_TTS_MODEL_NAME,
                                        "fallbackReason" to "timeout",
                                        "errorCode" to "TIMED_OUT",
                                        "message" to "Expressive cloud voice timed out. Using this phone's offline voice instead.",
                                    ),
                                )
                            } else {
                                emitEvent(
                                    requestId = requestId,
                                    state = "error",
                                    route = "TRANSCRIPT_ONLY",
                                    errorCode = "TIMED_OUT",
                                )
                                deliver(
                                    mapOf(
                                        "status" to "unavailable",
                                        "route" to "TRANSCRIPT_ONLY",
                                        "modelName" to DeniVoicePolicy.CLOUD_TTS_MODEL_NAME,
                                        "fallbackReason" to "timeout",
                                        "errorCode" to "TIMED_OUT",
                                        "message" to "Expressive cloud voice timed out and offline speech is unavailable for this language.",
                                    ),
                                )
                            }
                        } else {
                            emitEvent(
                                requestId = requestId,
                                state = "stopped",
                                route = "NONE",
                            )
                            deliver(
                                mapOf(
                                    "status" to "cancelled",
                                    "route" to "NONE",
                                    "message" to "Voice playback stopped.",
                                ),
                            )
                        }
                    },
                    onFailure = { info, _ ->
                        releaseActiveAudioTrack()
                        abandonAudioFocus()
                        Log.w(
                            tag,
                            "Cloud TTS failed (code=${info.errorCode}, model=${DeniVoicePolicy.CLOUD_TTS_MODEL_NAME}, chars=${normalizedText.length})",
                        )
                        val fellBack = fallbackToLocalOnFailure && withContext(Dispatchers.Main) {
                            speakLocally(
                                rawText = normalizedText,
                                languageCode = languageCode,
                                requestId = "${requestId}_local_fallback",
                            )
                        }
                        if (fellBack) {
                            mapOf(
                                "status" to "fallback_local",
                                "route" to "ANDROID_LOCAL_TTS",
                                "voiceName" to null,
                                "modelName" to DeniVoicePolicy.CLOUD_TTS_MODEL_NAME,
                                "fallbackReason" to "cloud_error",
                                "errorCode" to info.errorCode,
                                "message" to "Expressive cloud voice was unavailable. Using this phone's offline voice instead.",
                            )
                        } else {
                            emitEvent(
                                requestId = requestId,
                                state = "error",
                                route = "TRANSCRIPT_ONLY",
                                errorCode = info.errorCode,
                            )
                            mapOf(
                                "status" to "unavailable",
                                "route" to "TRANSCRIPT_ONLY",
                                "modelName" to DeniVoicePolicy.CLOUD_TTS_MODEL_NAME,
                                "fallbackReason" to "cloud_error",
                                "errorCode" to info.errorCode,
                                "message" to "Expressive cloud voice and offline speech are unavailable right now.",
                            )
                        }
                    },
                    onAttempt = { safeScript ->
                        streamGeminiTtsAudio(
                            requestId = requestId,
                            script = safeScript,
                            languageCode = languageCode,
                        )
                    },
                )
                deliver(resultMap)
            } catch (_: CancellationException) {
                // Already handled inside onCancel; propagate cleanly to finish coroutine.
            } finally {
                activeCloudJob.compareAndSet(kotlin.coroutines.coroutineContext[Job], null)
            }
        }
        activeCloudJob.set(job)
    }

    private suspend fun streamGeminiTtsAudio(
        requestId: String,
        script: String,
        languageCode: String,
    ): Map<String, Any?> {
        val bcp47 = DeniVoicePolicy.resolveGeminiTtsLanguageCode(languageCode)
        emitEvent(
            requestId = requestId,
            state = "synthesizing",
            route = "GEMINI_CLOUD_TTS",
            voiceName = DeniVoicePolicy.DENI_PREBUILT_VOICE_NAME,
            modelName = DeniVoicePolicy.CLOUD_TTS_MODEL_NAME,
        )

        val config = generationConfig {
            responseModalities = listOf(ResponseModality.AUDIO)
            speechConfig = SpeechConfig(
                voice = Voice(DeniVoicePolicy.DENI_PREBUILT_VOICE_NAME),
                languageCode = bcp47,
            )
        }

        // Enforce App Check replay protection (`useLimitedUseAppCheckTokens = true`),
        // matching existing Firebase AI Logic cloud policy.
        val model = Firebase.ai(
            backend = GenerativeBackend.googleAI(),
            useLimitedUseAppCheckTokens = true,
        ).generativeModel(
            modelName = DeniVoicePolicy.CLOUD_TTS_MODEL_NAME,
            generationConfig = config,
        )

        val prompt = content {
            text(
                text = script,
                speechMetadata = SpeechMetadata(style = DeniVoicePolicy.DENI_SPEECH_STYLE),
            )
        }

        var track: AudioTrack? = null
        var totalPcmBytes = 0

        try {
            HybridAiPolicy.collectWithTimeoutBudgets(
                flow = model.generateContentStream(prompt),
                firstResponseTimeoutMs = DeniVoicePolicy.CLOUD_TTS_FIRST_CHUNK_TIMEOUT_MS,
                totalTimeoutMs = DeniVoicePolicy.CLOUD_TTS_TOTAL_TIMEOUT_MS,
            ) { chunk ->
                for (candidate in chunk.candidates) {
                    for (part in candidate.content.parts) {
                        if (part is InlineDataPart && part.inlineData.isNotEmpty()) {
                            val pcmBytes = DeniVoicePolicy.extractPcm16Bytes(
                                rawAudioBytes = part.inlineData,
                                mimeType = part.mimeType,
                            )
                            if (pcmBytes.isEmpty()) continue
                            val activeAudio = track ?: createAndStartPcmTrack().also { created ->
                                track = created
                                activeAudioTrack.set(created)
                                requestAudioFocus()
                                emitEvent(
                                    requestId = requestId,
                                    state = "playing",
                                    route = "GEMINI_CLOUD_TTS",
                                    voiceName = DeniVoicePolicy.DENI_PREBUILT_VOICE_NAME,
                                    modelName = DeniVoicePolicy.CLOUD_TTS_MODEL_NAME,
                                )
                            }
                            writeAllPcmBytes(activeAudio, pcmBytes)
                            totalPcmBytes += pcmBytes.size
                        }
                    }
                }
            }

            if (totalPcmBytes == 0) {
                throw IllegalStateException("Gemini TTS returned empty audio stream.")
            }

            val activeTrack = track
            if (activeTrack != null) {
                awaitAudioTrackDrain(activeTrack, totalPcmBytes)
            }

            emitEvent(
                requestId = requestId,
                state = "completed",
                route = "GEMINI_CLOUD_TTS",
                voiceName = DeniVoicePolicy.DENI_PREBUILT_VOICE_NAME,
                modelName = DeniVoicePolicy.CLOUD_TTS_MODEL_NAME,
            )
            return mapOf(
                "status" to "completed",
                "route" to "GEMINI_CLOUD_TTS",
                "voiceName" to DeniVoicePolicy.DENI_PREBUILT_VOICE_NAME,
                "modelName" to DeniVoicePolicy.CLOUD_TTS_MODEL_NAME,
                "pcmBytes" to totalPcmBytes,
            )
        } finally {
            releaseActiveAudioTrack()
            abandonAudioFocus()
        }
    }

    private fun createAndStartPcmTrack(): AudioTrack {
        val minBuf = AudioTrack.getMinBufferSize(
            DeniVoicePolicy.PCM_SAMPLE_RATE_HZ,
            AudioFormat.CHANNEL_OUT_MONO,
            AudioFormat.ENCODING_PCM_16BIT,
        ).coerceAtLeast(4096)

        val audioTrack = AudioTrack.Builder()
            .setAudioAttributes(speechAudioAttributes)
            .setAudioFormat(
                AudioFormat.Builder()
                    .setEncoding(AudioFormat.ENCODING_PCM_16BIT)
                    .setSampleRate(DeniVoicePolicy.PCM_SAMPLE_RATE_HZ)
                    .setChannelMask(AudioFormat.CHANNEL_OUT_MONO)
                    .build(),
            )
            .setBufferSizeInBytes(minBuf * 2)
            .setTransferMode(AudioTrack.MODE_STREAM)
            .build()
        audioTrack.play()
        return audioTrack
    }

    private suspend fun writeAllPcmBytes(track: AudioTrack, pcmBytes: ByteArray) {
        var offset = 0
        while (offset < pcmBytes.size && kotlin.coroutines.coroutineContext.isActive) {
            val written = track.write(
                pcmBytes,
                offset,
                pcmBytes.size - offset,
                AudioTrack.WRITE_BLOCKING,
            )
            if (written <= 0) break
            offset += written
        }
    }

    private suspend fun awaitAudioTrackDrain(track: AudioTrack, totalPcmBytes: Int) {
        val totalFrames = totalPcmBytes / 2
        val maxWaitMs = (DeniVoicePolicy.estimatePcmDurationMs(totalPcmBytes) + 1_500L)
            .coerceIn(500L, 120_000L)
        val deadline = System.currentTimeMillis() + maxWaitMs
        while (kotlin.coroutines.coroutineContext.isActive && System.currentTimeMillis() < deadline) {
            val playedFrames = try {
                track.playbackHeadPosition
            } catch (_: Exception) {
                totalFrames
            }
            if (playedFrames >= totalFrames) break
            delay(40L)
        }
    }

    private fun stopCloudOnly() {
        userStoppedCurrentJob.set(true)
        activeCloudJob.getAndSet(null)?.cancel(HybridAiPolicy.UserAnalysisCancelledException())
        releaseActiveAudioTrack()
    }

    /**
     * Immediately stops both active Gemini Cloud TTS streaming and local Android
     * TextToSpeech playback and releases audio focus.
     */
    fun stopAll(emitStoppedEvent: Boolean = true): Boolean {
        val reqId = activeRequestId.getAndSet(null)
        stopCloudOnly()
        var stopped = true
        try {
            localTts?.stop()
        } catch (_: Exception) {
            stopped = false
        }
        abandonAudioFocus()
        if (emitStoppedEvent) {
            emitEvent(
                requestId = reqId ?: "",
                state = "stopped",
                route = "NONE",
            )
        }
        return stopped
    }

    fun release() {
        if (!isReleased.compareAndSet(false, true)) return
        stopAll(emitStoppedEvent = false)
        try {
            localTts?.shutdown()
        } catch (_: Exception) {
        }
        localTts = null
        isLocalTtsReady = false
    }

    private fun releaseActiveAudioTrack() {
        val track = activeAudioTrack.getAndSet(null) ?: return
        try {
            if (track.playState == AudioTrack.PLAYSTATE_PLAYING) {
                track.pause()
                track.flush()
            }
            track.stop()
        } catch (_: Exception) {
        }
        try {
            track.release()
        } catch (_: Exception) {
        }
    }

    private fun requestAudioFocus() {
        val am = audioManager ?: return
        try {
            val req = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN_TRANSIENT_MAY_DUCK)
                .setAudioAttributes(speechAudioAttributes)
                .setOnAudioFocusChangeListener(focusChangeListener)
                .build()
            currentFocusRequest.getAndSet(req)?.let { old ->
                try {
                    am.abandonAudioFocusRequest(old)
                } catch (_: Exception) {
                }
            }
            am.requestAudioFocus(req)
        } catch (_: Exception) {
        }
    }

    private fun abandonAudioFocus() {
        val am = audioManager ?: return
        val req = currentFocusRequest.getAndSet(null) ?: return
        try {
            am.abandonAudioFocusRequest(req)
        } catch (_: Exception) {
        }
    }

    private fun emitEvent(
        requestId: String,
        state: String,
        route: String,
        voiceName: String? = null,
        modelName: String? = null,
        errorCode: String? = null,
        message: String? = null,
    ) {
        if (isReleased.get()) return
        scope.launch(Dispatchers.Main) {
            onPlaybackEvent(
                mapOf(
                    "requestId" to requestId,
                    "state" to state,
                    "route" to route,
                    "voiceName" to voiceName,
                    "modelName" to modelName,
                    "errorCode" to errorCode,
                    "message" to message,
                ),
            )
        }
    }
}
