package com.example.enprive

import android.content.pm.ApplicationInfo
import java.util.concurrent.CountDownLatch
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicInteger
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test

class AppCheckProviderInstallerDebugTest {

    @Before
    fun setUp() {
        AppCheckProviderInstaller.resetForTesting()
    }

    @After
    fun tearDown() {
        AppCheckProviderInstaller.resetForTesting()
    }

    @Test
    fun `debuggable build selects DEBUG provider and installs once`() {
        val providers = mutableListOf<AppCheckProviderInstaller.SelectedProvider>()

        val first = AppCheckProviderInstaller.installIfNeeded(isDebuggable = true) { provider ->
            providers.add(provider)
        }
        val second = AppCheckProviderInstaller.installIfNeeded(isDebuggable = true) { provider ->
            providers.add(provider)
        }

        assertTrue(first)
        assertFalse(second)
        assertTrue(AppCheckProviderInstaller.isInstalled)
        assertEquals(listOf(AppCheckProviderInstaller.SelectedProvider.DEBUG), providers)
    }

    @Test
    fun `missing FLAG_DEBUGGABLE refuses debug provider and falls back to PLAY_INTEGRITY`() {
        val providers = mutableListOf<AppCheckProviderInstaller.SelectedProvider>()

        val installed = AppCheckProviderInstaller.installIfNeeded(isDebuggable = false) { provider ->
            providers.add(provider)
        }

        assertTrue(installed)
        assertTrue(AppCheckProviderInstaller.isInstalled)
        assertEquals(listOf(AppCheckProviderInstaller.SelectedProvider.PLAY_INTEGRITY), providers)
    }

    @Test
    fun `isDebuggableFlags checks FLAG_DEBUGGABLE bit accurately`() {
        assertFalse(AppCheckProviderInstaller.isDebuggableFlags(0))
        assertTrue(AppCheckProviderInstaller.isDebuggableFlags(ApplicationInfo.FLAG_DEBUGGABLE))
        assertTrue(
            AppCheckProviderInstaller.isDebuggableFlags(
                ApplicationInfo.FLAG_DEBUGGABLE or ApplicationInfo.FLAG_HAS_CODE,
            ),
        )
        assertFalse(AppCheckProviderInstaller.isDebuggableFlags(ApplicationInfo.FLAG_HAS_CODE))
    }

    @Test
    fun `failed installation leaves guard open for subsequent retry`() {
        val attempts = AtomicInteger(0)

        val failed = AppCheckProviderInstaller.installIfNeeded(isDebuggable = true) {
            attempts.incrementAndGet()
            throw IllegalStateException("FirebaseApp not initialized")
        }
        assertFalse(failed)
        assertFalse(AppCheckProviderInstaller.isInstalled)

        val succeeded = AppCheckProviderInstaller.installIfNeeded(isDebuggable = true) {
            attempts.incrementAndGet()
        }
        assertTrue(succeeded)
        assertTrue(AppCheckProviderInstaller.isInstalled)
        assertEquals(2, attempts.get())
    }

    @Test
    fun `concurrent installIfNeeded invocations execute factory strictly once`() {
        val threads = 8
        val ready = CountDownLatch(threads)
        val start = CountDownLatch(1)
        val installCalls = AtomicInteger(0)
        val trueReturns = AtomicInteger(0)
        val pool = Executors.newFixedThreadPool(threads)
        try {
            val futures = (0 until threads).map {
                pool.submit {
                    ready.countDown()
                    start.await(5, TimeUnit.SECONDS)
                    val didInstall = AppCheckProviderInstaller.installIfNeeded(isDebuggable = true) {
                        installCalls.incrementAndGet()
                    }
                    if (didInstall) {
                        trueReturns.incrementAndGet()
                    }
                }
            }
            assertTrue(ready.await(5, TimeUnit.SECONDS))
            start.countDown()
            for (f in futures) {
                f.get(5, TimeUnit.SECONDS)
            }
            assertEquals(1, installCalls.get())
            assertEquals(1, trueReturns.get())
            assertTrue(AppCheckProviderInstaller.isInstalled)
        } finally {
            pool.shutdownNow()
        }
    }
}
