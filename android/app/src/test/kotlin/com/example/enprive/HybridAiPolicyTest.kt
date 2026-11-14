package com.example.enprive

import com.google.firebase.ai.InferenceMode
import com.google.firebase.ai.InferenceSource
import com.google.firebase.ai.type.PublicPreviewAPI
import com.google.firebase.ai.type.ServiceConnectionHandshakeFailedException
import com.google.firebase.ai.type.ThinkingLevel
import java.net.SocketTimeoutException
import java.net.UnknownHostException
import java.util.concurrent.CountDownLatch
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicInteger
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.async
import kotlinx.coroutines.delay
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking
import kotlinx.coroutines.withTimeout
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Assert.fail
import org.junit.Test

private class FakeQuotaExceededException(message: String) : RuntimeException(message)
private class FakeAuthException(message: String) : RuntimeException(message)
private class FakeUnsupportedThinkingException(message: String) : RuntimeException(message)

@OptIn(PublicPreviewAPI::class)
class HybridAiPolicyTest {

    @Test
    fun `unconsented requests block cloud and prefer modes while allowing ONLY_ON_DEVICE`() {
        assertTrue(HybridAiPolicy.isRequestPermitted(cloudConsent = false, requestedMode = "ONLY_ON_DEVICE"))
        assertTrue(HybridAiPolicy.isRequestPermitted(cloudConsent = false, requestedMode = null))
        assertFalse(HybridAiPolicy.isRequestPermitted(cloudConsent = false, requestedMode = "ONLY_IN_CLOUD"))
        assertFalse(HybridAiPolicy.isRequestPermitted(cloudConsent = false, requestedMode = "PREFER_ON_DEVICE"))
        assertTrue(HybridAiPolicy.isRequestPermitted(cloudConsent = true, requestedMode = "ONLY_IN_CLOUD"))
    }

    @Test
    fun `resolveInferenceMode never returns cloud when consent is false`() {
        assertEquals(
            InferenceMode.ONLY_ON_DEVICE,
            HybridAiPolicy.resolveInferenceMode(cloudConsent = false, requestedMode = "ONLY_IN_CLOUD")
        )
        assertEquals(
            InferenceMode.ONLY_ON_DEVICE,
            HybridAiPolicy.resolveInferenceMode(cloudConsent = false, requestedMode = "PREFER_ON_DEVICE")
        )
        assertEquals(
            InferenceMode.ONLY_IN_CLOUD,
            HybridAiPolicy.resolveInferenceMode(cloudConsent = true, requestedMode = "ONLY_IN_CLOUD")
        )
        assertEquals(
            InferenceMode.ONLY_ON_DEVICE,
            HybridAiPolicy.resolveInferenceMode(cloudConsent = true, requestedMode = "ONLY_ON_DEVICE")
        )
    }

    @Test
    fun `shouldAttachOnDeviceConfig omits config when ONLY_IN_CLOUD`() {
        assertFalse(HybridAiPolicy.shouldAttachOnDeviceConfig(InferenceMode.ONLY_IN_CLOUD))
        assertTrue(HybridAiPolicy.shouldAttachOnDeviceConfig(InferenceMode.ONLY_ON_DEVICE))
        assertTrue(HybridAiPolicy.shouldAttachOnDeviceConfig(InferenceMode.PREFER_ON_DEVICE))
    }

    @Test
    fun `mapInferenceSource returns UNKNOWN when chunk source cannot be established`() {
        assertEquals("UNKNOWN", HybridAiPolicy.mapInferenceSource(null))
        assertEquals("ON_DEVICE", HybridAiPolicy.mapInferenceSource(InferenceSource.ON_DEVICE))
        assertEquals("IN_CLOUD", HybridAiPolicy.mapInferenceSource(InferenceSource.IN_CLOUD))
    }

    @Test
    fun `initialStreamSource only announces certain backend`() {
        assertEquals("ON_DEVICE", HybridAiPolicy.initialStreamSource(InferenceMode.ONLY_ON_DEVICE))
        assertEquals("IN_CLOUD", HybridAiPolicy.initialStreamSource(InferenceMode.ONLY_IN_CLOUD))
        assertNull(HybridAiPolicy.initialStreamSource(InferenceMode.PREFER_ON_DEVICE))
    }

    @Test
    fun `successful cloud stream executes exactly one model generation invocation`() = runBlocking {
        val calls = AtomicInteger(0)
        var capturedThoughtsFlag: Boolean? = null

        val source = HybridAiPolicy.executeSingleGenerationAttempt(
            cloudConsent = true,
            requestedMode = "ONLY_IN_CLOUD",
            modelName = "gemini-3.8-flash",
            onBlocked = { fail("Permitted cloud operation should not be blocked: $it"); "BLOCKED" },
            onAttempt = { mode, enableThoughts ->
                calls.incrementAndGet()
                capturedThoughtsFlag = enableThoughts
                assertEquals(InferenceMode.ONLY_IN_CLOUD, mode)
                HybridAiPolicy.mapInferenceSource(InferenceSource.IN_CLOUD)
            }
        )

        assertEquals(1, calls.get())
        assertEquals(true, capturedThoughtsFlag)
        assertEquals("IN_CLOUD", source)
    }

    @Test
    fun `HTTP 429 quota error does not retry and stays at one invocation`() = runBlocking {
        val calls = AtomicInteger(0)
        try {
            HybridAiPolicy.executeSingleGenerationAttempt<String>(
                cloudConsent = true,
                requestedMode = "ONLY_IN_CLOUD",
                modelName = "gemini-3.8-flash",
                onBlocked = { fail("Unexpected block"); "" },
                onAttempt = { _, _ ->
                    calls.incrementAndGet()
                    throw FakeQuotaExceededException("Quota exceeded (429)")
                }
            )
            fail("Expected FakeQuotaExceededException")
        } catch (e: FakeQuotaExceededException) {
            assertTrue(e.message?.contains("429") == true)
        }
        assertEquals(1, calls.get())
    }

    @Test
    fun `airplane mode and DNS network failures do not retry`() = runBlocking {
        val airplaneCalls = AtomicInteger(0)
        try {
            HybridAiPolicy.executeSingleGenerationAttempt<String>(
                cloudConsent = true,
                requestedMode = "ONLY_IN_CLOUD",
                modelName = "gemini-3.8-flash",
                onBlocked = { fail("Unexpected block"); "" },
                onAttempt = { _, _ ->
                    airplaneCalls.incrementAndGet()
                    throw UnknownHostException("Unable to resolve host in airplane mode")
                }
            )
            fail("Expected UnknownHostException")
        } catch (_: UnknownHostException) {
        }
        assertEquals(1, airplaneCalls.get())
    }

    @Test
    fun `App Check failure does not retry and stays at one invocation`() = runBlocking {
        val calls = AtomicInteger(0)
        try {
            HybridAiPolicy.executeSingleGenerationAttempt<String>(
                cloudConsent = true,
                requestedMode = "ONLY_IN_CLOUD",
                modelName = "gemini-3.8-flash",
                onBlocked = { fail("Unexpected block"); "" },
                onAttempt = { _, _ ->
                    calls.incrementAndGet()
                    throw ServiceConnectionHandshakeFailedException("App Check verification failed", null)
                }
            )
            fail("Expected App Check handshake failure")
        } catch (_: ServiceConnectionHandshakeFailedException) {
        }
        assertEquals(1, calls.get())
    }

    @Test
    fun `auth timeout cancellation and generic model errors execute at most once without retry`() =
        runBlocking {
            val failures: List<Throwable> = listOf(
                FakeAuthException("Authentication/authorization failed (403)"),
                SocketTimeoutException("Cloud generation timed out"),
                CancellationException("Operation cancelled by caller"),
                RuntimeException("Generic model failure")
            )

            for (failure in failures) {
                val calls = AtomicInteger(0)
                try {
                    HybridAiPolicy.executeSingleGenerationAttempt<String>(
                        cloudConsent = true,
                        requestedMode = "ONLY_IN_CLOUD",
                        modelName = "gemini-3.8-flash",
                        onBlocked = { fail("Unexpected block"); "" },
                        onAttempt = { _, _ ->
                            calls.incrementAndGet()
                            throw failure
                        }
                    )
                    fail("Expected ${failure.javaClass.simpleName}")
                } catch (caught: Throwable) {
                    assertEquals(failure.javaClass, caught.javaClass)
                }
                assertEquals(
                    "Expected exactly 1 invocation for ${failure.javaClass.simpleName}",
                    1,
                    calls.get()
                )
            }
        }

    @Test
    fun `thinking configuration is resolved upfront and never blindly retried`() = runBlocking {
        // Hybrid / on-device modes omit explicit ThinkingLevel upfront because Nano may execute.
        assertEquals(
            HybridAiPolicy.ThinkingPolicyDecision.OMIT_THINKING_CONFIG,
            HybridAiPolicy.resolveThinkingPolicy(InferenceMode.ONLY_ON_DEVICE, "gemini-3.8-flash")
        )
        assertEquals(
            HybridAiPolicy.ThinkingPolicyDecision.OMIT_THINKING_CONFIG,
            HybridAiPolicy.resolveThinkingPolicy(InferenceMode.PREFER_ON_DEVICE, "gemini-3.8-flash")
        )
        // Non-Gemini-3 cloud models omit optional thinkingConfig before sending the first request.
        assertEquals(
            HybridAiPolicy.ThinkingPolicyDecision.OMIT_THINKING_CONFIG,
            HybridAiPolicy.resolveThinkingPolicy(InferenceMode.ONLY_IN_CLOUD, "gemini-2.0-flash")
        )
        assertEquals(
            HybridAiPolicy.ThinkingPolicyDecision.UNSUPPORTED_CONFIGURATION,
            HybridAiPolicy.resolveThinkingPolicy(
                mode = InferenceMode.ONLY_IN_CLOUD,
                modelName = "gemini-2.0-flash",
                requireThinking = true
            )
        )

        // Verified Gemini 3.8 cloud configuration uses ThinkingLevel.LOW and never ThinkingLevel.MINIMAL.
        assertEquals(ThinkingLevel.LOW, HybridAiPolicy.CLOUD_THINKING_LEVEL)
        assertTrue(
            HybridAiPolicy.isThinkingLevelSupported("gemini-3.8-flash", ThinkingLevel.LOW)
        )
        assertFalse(
            HybridAiPolicy.isThinkingLevelSupported("gemini-3.8-flash", ThinkingLevel.MINIMAL)
        )
        assertEquals(
            HybridAiPolicy.ThinkingPolicyDecision.OMIT_THINKING_CONFIG,
            HybridAiPolicy.resolveThinkingPolicy(
                mode = InferenceMode.ONLY_IN_CLOUD,
                modelName = "gemini-3.8-flash",
                requireThinking = false,
                thinkingLevel = ThinkingLevel.MINIMAL
            )
        )
        assertEquals(
            HybridAiPolicy.ThinkingPolicyDecision.UNSUPPORTED_CONFIGURATION,
            HybridAiPolicy.resolveThinkingPolicy(
                mode = InferenceMode.ONLY_IN_CLOUD,
                modelName = "gemini-3.8-flash",
                requireThinking = true,
                thinkingLevel = ThinkingLevel.MINIMAL
            )
        )

        // Attempting strict ThinkingLevel.MINIMAL on gemini-3.8-flash fails preflight with 0 calls.
        val minimalRejectedCalls = AtomicInteger(0)
        try {
            HybridAiPolicy.executeSingleGenerationAttempt<String>(
                cloudConsent = true,
                requestedMode = "ONLY_IN_CLOUD",
                modelName = "gemini-3.8-flash",
                requireThinking = true,
                thinkingLevel = ThinkingLevel.MINIMAL,
                onBlocked = { fail("Unexpected block"); "" },
                onAttempt = { _, _ ->
                    minimalRejectedCalls.incrementAndGet()
                    "OK"
                }
            )
            fail("Expected IllegalStateException for unsupported ThinkingLevel.MINIMAL")
        } catch (_: IllegalStateException) {
        }
        assertEquals(0, minimalRejectedCalls.get())

        // Optional thoughts on an incompatible model execute once cleanly with enableThoughts=false.
        val avoidedCalls = AtomicInteger(0)
        var usedThoughts: Boolean? = null
        HybridAiPolicy.executeSingleGenerationAttempt(
            cloudConsent = true,
            requestedMode = "ONLY_IN_CLOUD",
            modelName = "gemini-2.0-flash",
            requireThinking = false,
            onBlocked = { fail("Unexpected block"); "" },
            onAttempt = { _, enableThoughts ->
                avoidedCalls.incrementAndGet()
                usedThoughts = enableThoughts
                "OK"
            }
        )
        assertEquals(1, avoidedCalls.get())
        assertEquals(false, usedThoughts)

        // Strict thinking requirement on an unsupported model fails preflight with 0 calls.
        val rejectedPreflightCalls = AtomicInteger(0)
        try {
            HybridAiPolicy.executeSingleGenerationAttempt<String>(
                cloudConsent = true,
                requestedMode = "ONLY_IN_CLOUD",
                modelName = "unknown-custom-model",
                requireThinking = true,
                onBlocked = { fail("Unexpected block"); "" },
                onAttempt = { _, _ ->
                    rejectedPreflightCalls.incrementAndGet()
                    "OK"
                }
            )
            fail("Expected IllegalStateException before sending request")
        } catch (_: IllegalStateException) {
        }
        assertEquals(0, rejectedPreflightCalls.get())

        // Even if the backend rejects thinkingConfig unexpectedly, no blind retry happens.
        val serverRejectedCalls = AtomicInteger(0)
        try {
            HybridAiPolicy.executeSingleGenerationAttempt<String>(
                cloudConsent = true,
                requestedMode = "ONLY_IN_CLOUD",
                modelName = "gemini-3.8-flash",
                onBlocked = { fail("Unexpected block"); "" },
                onAttempt = { _, enableThoughts ->
                    serverRejectedCalls.incrementAndGet()
                    assertTrue(enableThoughts)
                    throw FakeUnsupportedThinkingException("Unsupported thinkingConfig for deployment")
                }
            )
            fail("Expected FakeUnsupportedThinkingException")
        } catch (_: FakeUnsupportedThinkingException) {
        }
        assertEquals(1, serverRejectedCalls.get())
    }

    @Test
    fun `cancelled consent prevents any model generation call`() = runBlocking {
        val calls = AtomicInteger(0)
        var blockedReason: String? = null

        val result = HybridAiPolicy.executeSingleGenerationAttempt(
            cloudConsent = false,
            requestedMode = "ONLY_IN_CLOUD",
            modelName = "gemini-3.8-flash",
            onBlocked = { reason ->
                blockedReason = reason
                "BLOCKED"
            },
            onAttempt = { _, _ ->
                calls.incrementAndGet()
                "SHOULD_NOT_RUN"
            }
        )

        assertEquals(0, calls.get())
        assertEquals("BLOCKED", result)
        assertTrue(!blockedReason.isNullOrBlank())
    }

    @Test
    fun `single generation guard rejects duplicate attempt within same operation`() {
        val guard = HybridAiPolicy.SingleGenerationGuard()
        guard.acquireSingleAttempt()
        try {
            guard.acquireSingleAttempt()
            fail("Second attempt must be rejected by SingleGenerationGuard")
        } catch (_: IllegalStateException) {
        }
    }

    @Test
    fun `cancellation propagates even when parent scope remains active without entering failure fallback`() =
        runBlocking {
            val parentScope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
            try {
                // 1. Child-operation CancellationException while parent remains active
                val childCalls = AtomicInteger(0)
                val cancelHookCalls = AtomicInteger(0)
                val fallbackCalls = AtomicInteger(0)
                val childJob = parentScope.async {
                    HybridAiPolicy.executeSingleOperation(
                        onRun = {
                            HybridAiPolicy.executeSingleGenerationAttempt(
                                cloudConsent = true,
                                requestedMode = "ONLY_IN_CLOUD",
                                modelName = "gemini-3.8-flash",
                                onBlocked = { fail("Unexpected block"); "" },
                                onAttempt = { _, _ ->
                                    childCalls.incrementAndGet()
                                    throw CancellationException("Child stream cancelled")
                                }
                            )
                        },
                        onCancel = { cancelHookCalls.incrementAndGet() },
                        onFailure = { _, _ ->
                            fallbackCalls.incrementAndGet()
                            "SHOULD_NOT_FALLBACK"
                        }
                    )
                }

                try {
                    childJob.await()
                    fail("Expected CancellationException to propagate")
                } catch (_: CancellationException) {
                }
                assertTrue("Parent scope must stay active after child cancellation", parentScope.isActive)
                assertEquals(1, childCalls.get())
                assertEquals(1, cancelHookCalls.get())
                assertEquals(0, fallbackCalls.get())

                // 2. Child withTimeout (TimeoutCancellationException) while parent remains active
                val timeoutCalls = AtomicInteger(0)
                val timeoutCancelHooks = AtomicInteger(0)
                val timeoutFallbacks = AtomicInteger(0)
                val timeoutJob = parentScope.async {
                    HybridAiPolicy.executeSingleOperation(
                        onRun = {
                            HybridAiPolicy.executeSingleGenerationAttempt(
                                cloudConsent = true,
                                requestedMode = "ONLY_IN_CLOUD",
                                modelName = "gemini-3.8-flash",
                                onBlocked = { fail("Unexpected block"); "" },
                                onAttempt = { _, _ ->
                                    timeoutCalls.incrementAndGet()
                                    withTimeout(10L) {
                                        delay(1000L)
                                        "TIMED_OUT"
                                    }
                                }
                            )
                        },
                        onCancel = { timeoutCancelHooks.incrementAndGet() },
                        onFailure = { _, _ ->
                            timeoutFallbacks.incrementAndGet()
                            "SHOULD_NOT_FALLBACK"
                        }
                    )
                }

                try {
                    timeoutJob.await()
                    fail("Expected TimeoutCancellationException to propagate")
                } catch (_: CancellationException) {
                }
                assertTrue("Parent scope must stay active after timeout cancellation", parentScope.isActive)
                assertEquals(1, timeoutCalls.get())
                assertEquals(1, timeoutCancelHooks.get())
                assertEquals(0, timeoutFallbacks.get())

                // 3. Ordinary network and HTTP 429 quota failures still map via onFailure once (0 retries)
                val ordinaryErrors = listOf(
                    UnknownHostException("Airplane mode DNS error"),
                    FakeQuotaExceededException("Quota exceeded (429)")
                )
                for (err in ordinaryErrors) {
                    val calls = AtomicInteger(0)
                    val cancels = AtomicInteger(0)
                    val fallbacks = AtomicInteger(0)
                    val result = HybridAiPolicy.executeSingleOperation(
                        onRun = {
                            HybridAiPolicy.executeSingleGenerationAttempt(
                                cloudConsent = true,
                                requestedMode = "ONLY_IN_CLOUD",
                                modelName = "gemini-3.8-flash",
                                onBlocked = { fail("Unexpected block"); "" },
                                onAttempt = { _, _ ->
                                    calls.incrementAndGet()
                                    throw err
                                }
                            )
                        },
                        onCancel = { cancels.incrementAndGet() },
                        onFailure = { info, _ ->
                            fallbacks.incrementAndGet()
                            assertEquals("failed", info.status)
                            "FALLBACK_OK"
                        }
                    )
                    assertEquals("FALLBACK_OK", result)
                    assertEquals(1, calls.get())
                    assertEquals(0, cancels.get())
                    assertEquals(1, fallbacks.get())
                }
            } finally {
                parentScope.coroutineContext[kotlinx.coroutines.Job]?.cancel()
            }
        }

    @Test
    fun `single generation guard is per operation and supports concurrent and separate operations`() =
        runBlocking {
            // 1. Concurrent duplicate entry sharing one SingleGenerationGuard permits strictly 1 attempt
            val sharedGuard = HybridAiPolicy.SingleGenerationGuard()
            val threadCount = 8
            val ready = CountDownLatch(threadCount)
            val start = CountDownLatch(1)
            val winners = AtomicInteger(0)
            val rejections = AtomicInteger(0)
            val pool = Executors.newFixedThreadPool(threadCount)
            try {
                val futures = (0 until threadCount).map {
                    pool.submit {
                        ready.countDown()
                        start.await(5, TimeUnit.SECONDS)
                        try {
                            sharedGuard.acquireSingleAttempt()
                            winners.incrementAndGet()
                        } catch (_: IllegalStateException) {
                            rejections.incrementAndGet()
                        }
                    }
                }
                assertTrue(ready.await(5, TimeUnit.SECONDS))
                start.countDown()
                for (f in futures) {
                    f.get(5, TimeUnit.SECONDS)
                }
                assertEquals(1, winners.get())
                assertEquals(threadCount - 1, rejections.get())
            } finally {
                pool.shutdownNow()
            }

            // 2. Duplicate re-entry inside the same logical operation fails without running a 2nd time
            val op1Guard = HybridAiPolicy.SingleGenerationGuard()
            val op1Calls = AtomicInteger(0)
            op1Guard.acquireSingleAttempt()
            op1Calls.incrementAndGet()
            try {
                op1Guard.acquireSingleAttempt()
                fail("Duplicate attempt on same operation guard must be rejected")
            } catch (_: IllegalStateException) {
            }
            assertEquals(1, op1Calls.get())

            // 3. Separate approved operations (sequential & concurrent) do not block one another
            val sequentialCalls = AtomicInteger(0)
            val firstRes = HybridAiPolicy.executeSingleGenerationAttempt(
                cloudConsent = true,
                requestedMode = "ONLY_IN_CLOUD",
                modelName = "gemini-3.8-flash",
                onBlocked = { fail("Unexpected block"); "" },
                onAttempt = { _, _ -> "OP_${sequentialCalls.incrementAndGet()}" }
            )
            val secondRes = HybridAiPolicy.executeSingleGenerationAttempt(
                cloudConsent = true,
                requestedMode = "ONLY_IN_CLOUD",
                modelName = "gemini-3.8-flash",
                onBlocked = { fail("Unexpected block"); "" },
                onAttempt = { _, _ -> "OP_${sequentialCalls.incrementAndGet()}" }
            )
            assertEquals("OP_1", firstRes)
            assertEquals("OP_2", secondRes)
            assertEquals(2, sequentialCalls.get())

            val concurrentOpCalls = AtomicInteger(0)
            val concurrentResults = listOf(
                async(Dispatchers.Default) {
                    HybridAiPolicy.executeSingleGenerationAttempt(
                        cloudConsent = true,
                        requestedMode = "ONLY_IN_CLOUD",
                        modelName = "gemini-3.8-flash",
                        onBlocked = { fail("Unexpected block"); "" },
                        onAttempt = { _, _ ->
                            delay(20L)
                            "CONC_${concurrentOpCalls.incrementAndGet()}"
                        }
                    )
                },
                async(Dispatchers.Default) {
                    HybridAiPolicy.executeSingleGenerationAttempt(
                        cloudConsent = true,
                        requestedMode = "ONLY_IN_CLOUD",
                        modelName = "gemini-3.8-flash",
                        onBlocked = { fail("Unexpected block"); "" },
                        onAttempt = { _, _ ->
                            delay(20L)
                            "CONC_${concurrentOpCalls.incrementAndGet()}"
                        }
                    )
                }
            )
            val resolved = concurrentResults.map { it.await() }
            assertEquals(2, resolved.size)
            assertEquals(2, concurrentOpCalls.get())
        }
}
