package com.example.enprive

import com.google.firebase.ai.InferenceMode
import com.google.firebase.ai.InferenceSource
import com.google.firebase.ai.type.PublicPreviewAPI
import com.google.firebase.ai.type.ThinkingLevel
import java.util.concurrent.atomic.AtomicBoolean
import kotlinx.coroutines.CancellationException

/**
 * Pure routing and provenance helpers for hybrid Firebase AI Logic execution.
 * Kept Android-framework-free so JVM unit tests verify consent and provenance
 * guarantees without emulator dependencies.
 */
@OptIn(PublicPreviewAPI::class)
object HybridAiPolicy {
    /**
     * Validated default thinking level for Gemini 3.8 cloud requests.
     * Note: `gemini-3.8-flash` does not support `ThinkingLevel.MINIMAL`.
     */
    val CLOUD_THINKING_LEVEL: ThinkingLevel = ThinkingLevel.LOW

    /**
     * Upfront decision for attaching explicit `thinkingConfig` before the sole
     * model-generation attempt. Gemini 3.x models always use dynamic thinking;
     * [OMIT_THINKING_CONFIG] leaves out explicit `thinkingConfig` rather than
     * disabling model thinking.
     */
    enum class ThinkingPolicyDecision {
        ENABLE_THINKING_LEVEL,
        OMIT_THINKING_CONFIG,
        UNSUPPORTED_CONFIGURATION
    }

    /**
     * Normalized non-cancellation failure metadata mapped only for ordinary
     * exceptions after cancellation propagation has already short-circuited.
     */
    data class TerminalFailureInfo(
        val status: String,
        val isUnavailable: Boolean,
        val errorCode: String,
        val message: String
    )

    /**
     * Per-operation guard ensuring at most one native model-generation invocation
     * can execute for a single approved request.
     */
    class SingleGenerationGuard {
        private val invoked = AtomicBoolean(false)

        fun acquireSingleAttempt() {
            check(invoked.compareAndSet(false, true)) {
                "Only one native model-generation invocation is permitted per operation."
            }
        }
    }

    /**
     * Rejects any request attempting cloud-capable routing when explicit user
     * consent has not been granted.
     */
    fun isRequestPermitted(cloudConsent: Boolean, requestedMode: String?): Boolean {
        if (!cloudConsent && requestedMode != null && requestedMode != "ONLY_ON_DEVICE") {
            return false
        }
        return true
    }

    /**
     * Resolves the effective [InferenceMode]. Without [cloudConsent], this
     * unconditionally locks to [InferenceMode.ONLY_ON_DEVICE].
     */
    fun resolveInferenceMode(cloudConsent: Boolean, requestedMode: String?): InferenceMode {
        if (!cloudConsent) return InferenceMode.ONLY_ON_DEVICE
        return when (requestedMode) {
            "ONLY_IN_CLOUD" -> InferenceMode.ONLY_IN_CLOUD
            "ONLY_ON_DEVICE" -> InferenceMode.ONLY_ON_DEVICE
            else -> InferenceMode.PREFER_ON_DEVICE
        }
    }

    /**
     * Returns whether [modelName] supports [ThinkingLevel] configuration
     * upfront before submitting any generation request.
     */
    fun supportsThinkingLevel(modelName: String): Boolean =
        isThinkingLevelSupported(modelName, CLOUD_THINKING_LEVEL)

    /**
     * Returns whether [modelName] supports the specific [thinkingLevel] upfront.
     * Gemini 3.x models always use dynamic thinking; `gemini-3.8-flash` and
     * `gemini-3.7-flash` do not support `ThinkingLevel.MINIMAL`.
     */
    fun isThinkingLevelSupported(
        modelName: String,
        thinkingLevel: ThinkingLevel = CLOUD_THINKING_LEVEL
    ): Boolean {
        val normalized = modelName.trim().lowercase()
        if (normalized.isEmpty()) return false
        val unsupportedSuffixes = listOf(
            "-image",
            "-tts",
            "-audio",
            "-live",
            "embedding",
            "imagen",
            "veo",
            "nano",
            "aicore"
        )
        if (unsupportedSuffixes.any { normalized.contains(it) }) {
            return false
        }
        if (!normalized.startsWith("gemini-3")) {
            return false
        }
        if (thinkingLevel == ThinkingLevel.MINIMAL &&
            (normalized.startsWith("gemini-3.8") || normalized.startsWith("gemini-3.7"))
        ) {
            return false
        }
        return true
    }

    /**
     * Determines `thinkingConfig` compatibility strictly before sending the
     * first request. Only guaranteed cloud Gemini 3+ models with a supported
     * [thinkingLevel] enable explicit `ThinkingLevel`; on-device or hybrid modes
     * and incompatible models omit explicit `thinkingConfig` up front when
     * optional, or fail preflight when [requireThinking] is true.
     */
    fun resolveThinkingPolicy(
        mode: InferenceMode,
        modelName: String,
        requireThinking: Boolean = false,
        thinkingLevel: ThinkingLevel = CLOUD_THINKING_LEVEL
    ): ThinkingPolicyDecision {
        if (mode == InferenceMode.ONLY_IN_CLOUD &&
            isThinkingLevelSupported(modelName, thinkingLevel)
        ) {
            return ThinkingPolicyDecision.ENABLE_THINKING_LEVEL
        }
        return if (requireThinking) {
            ThinkingPolicyDecision.UNSUPPORTED_CONFIGURATION
        } else {
            ThinkingPolicyDecision.OMIT_THINKING_CONFIG
        }
    }

    /**
     * Executes an operation with unconditional structured-concurrency cancellation
     * propagation before any ordinary error fallback mapping. Every
     * [CancellationException] (parent, child, or timeout) invokes [onCancel]
     * and rethrows cleanly regardless of parent coroutine `isActive` state.
     */
    suspend fun <T> executeSingleOperation(
        onRun: suspend () -> T,
        onCancel: suspend (CancellationException) -> Unit = {},
        onFailure: suspend (TerminalFailureInfo, Throwable) -> T
    ): T {
        return try {
            onRun()
        } catch (e: CancellationException) {
            onCancel(e)
            throw e
        } catch (e: Exception) {
            val isUnavailable =
                e.javaClass.simpleName.contains("NotAvailable", ignoreCase = true) ||
                    (e.message?.contains("not available", ignoreCase = true) == true)
            val info = TerminalFailureInfo(
                status = if (isUnavailable) "unavailable" else "failed",
                isUnavailable = isUnavailable,
                errorCode = e.javaClass.simpleName,
                message = e.message ?: "Analysis unavailable on this device"
            )
            onFailure(info, e)
        }
    }

    /**
     * Executes at most one model-generation invocation for a permitted operation.
     * Any failure (HTTP 429 quota, Airplane mode/network, App Check, auth, timeout,
     * cancellation, unsupported thinking config, or generic failure) propagates
     * directly without retrying.
     */
    suspend fun <T> executeSingleGenerationAttempt(
        cloudConsent: Boolean,
        requestedMode: String?,
        modelName: String,
        requireThinking: Boolean = false,
        thinkingLevel: ThinkingLevel = CLOUD_THINKING_LEVEL,
        guard: SingleGenerationGuard = SingleGenerationGuard(),
        onBlocked: (String) -> T,
        onAttempt: suspend (mode: InferenceMode, enableThoughts: Boolean) -> T
    ): T {
        if (!isRequestPermitted(cloudConsent, requestedMode)) {
            return onBlocked("Cloud analysis requires explicit permission for this check.")
        }
        val mode = resolveInferenceMode(cloudConsent, requestedMode)
        val decision = resolveThinkingPolicy(
            mode = mode,
            modelName = modelName,
            requireThinking = requireThinking,
            thinkingLevel = thinkingLevel
        )
        if (decision == ThinkingPolicyDecision.UNSUPPORTED_CONFIGURATION) {
            throw IllegalStateException(
                "Thinking configuration '$thinkingLevel' is not supported for model '$modelName' in mode '$mode'."
            )
        }
        guard.acquireSingleAttempt()
        val enableThoughts = decision == ThinkingPolicyDecision.ENABLE_THINKING_LEVEL
        return onAttempt(mode, enableThoughts)
    }

    /**
     * Attaches `OnDeviceConfig` only when on-device execution can be used.
     */
    fun shouldAttachOnDeviceConfig(mode: InferenceMode): Boolean =
        mode != InferenceMode.ONLY_IN_CLOUD

    /**
     * Maps SDK [InferenceSource] strictly from observed response chunks and
     * returns `"UNKNOWN"` whenever the source could not be established.
     */
    fun mapInferenceSource(src: InferenceSource?): String = when (src) {
        InferenceSource.ON_DEVICE -> "ON_DEVICE"
        InferenceSource.IN_CLOUD -> "IN_CLOUD"
        else -> "UNKNOWN"
    }

    fun initialStreamLabel(mode: InferenceMode): String = when (mode) {
        InferenceMode.ONLY_ON_DEVICE -> "Reading policy text on this phone"
        InferenceMode.ONLY_IN_CLOUD -> "Streaming reasoning via App Check"
        InferenceMode.PREFER_ON_DEVICE -> "Checking on-device or App Check engine"
        else -> "Checking analysis engine"
    }

    fun initialStreamSource(mode: InferenceMode): String? = when (mode) {
        InferenceMode.ONLY_ON_DEVICE -> "ON_DEVICE"
        InferenceMode.ONLY_IN_CLOUD -> "IN_CLOUD"
        else -> null
    }
}
