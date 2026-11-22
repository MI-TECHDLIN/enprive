package com.example.enprive

import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import com.google.firebase.FirebaseApp
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Verifies process-level App Check initialization ordering, application ID
 * binding, and upgraded limited-use token provider support on a real Android
 * runtime.
 */
@RunWith(AndroidJUnit4::class)
class AppCheckInitializationInstrumentedTest {

    @Test
    fun enpriveApplicationInitializesAppCheckOnceBeforeActivityLaunch() {
        val targetContext = InstrumentationRegistry.getInstrumentation().targetContext
        val appContext = targetContext.applicationContext

        assertEquals(
            "Expected production Android applicationId com.mitechdlin.enprive",
            "com.mitechdlin.enprive",
            targetContext.packageName,
        )
        assertEquals(
            "Expected Firebase Android app ID for com.mitechdlin.enprive",
            "1:71373777460:android:b8983622f3315d6d3d7861",
            FirebaseApp.getInstance().options.applicationId,
        )
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
