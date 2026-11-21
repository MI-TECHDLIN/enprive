package com.example.enprive

import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Verifies process-level App Check initialization ordering and upgraded
 * limited-use token provider support on a real Android runtime.
 */
@RunWith(AndroidJUnit4::class)
class AppCheckInitializationInstrumentedTest {

    @Test
    fun enpriveApplicationInitializesAppCheckOnceBeforeActivityLaunch() {
        val targetContext = InstrumentationRegistry.getInstrumentation().targetContext
        val appContext = targetContext.applicationContext

        assertTrue(
            "Expected EnpriveApplication to be active Application, got ${appContext.javaClass.name}",
            appContext is EnpriveApplication,
        )
        assertTrue(
            "AppCheckProviderInstaller must already be installed by EnpriveApplication.onCreate()",
            AppCheckProviderInstaller.isInstalled,
        )
        assertFalse(
            "Subsequent installIfNeeded call must be an idempotent no-op",
            AppCheckProviderInstaller.installIfNeeded(appContext),
        )
    }

    @Test
    fun upgradedAppCheckProvidersOverrideGetLimitedUseToken() {
        val debugProviderClass =
            Class.forName("com.google.firebase.appcheck.debug.internal.DebugAppCheckProvider")
        val debugMethod = debugProviderClass.getDeclaredMethod("getLimitedUseToken")
        assertTrue(debugMethod.declaringClass == debugProviderClass)

        val playIntegrityProviderClass =
            Class.forName("com.google.firebase.appcheck.playintegrity.internal.PlayIntegrityAppCheckProvider")
        val playIntegrityMethod = playIntegrityProviderClass.getDeclaredMethod("getLimitedUseToken")
        assertTrue(playIntegrityMethod.declaringClass == playIntegrityProviderClass)
    }
}
