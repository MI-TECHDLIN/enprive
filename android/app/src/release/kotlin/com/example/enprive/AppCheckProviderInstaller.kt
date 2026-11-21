package com.example.enprive

import android.content.Context
import android.util.Log
import com.google.firebase.Firebase
import com.google.firebase.appcheck.appCheck
import com.google.firebase.appcheck.playintegrity.PlayIntegrityAppCheckProviderFactory

/**
 * Release source-set App Check provider installer.
 *
 * Unconditionally installs [PlayIntegrityAppCheckProviderFactory] once per process
 * with zero compile-time or runtime reference to `firebase-appcheck-debug`.
 */
internal object AppCheckProviderInstaller {
    private const val TAG = "EnpriveHybridAi"
    private val lock = Any()

    @Volatile
    private var installed = false

    val isInstalled: Boolean
        get() = installed

    fun installIfNeeded(context: Context): Boolean {
        return installIfNeeded {
            Firebase.appCheck.installAppCheckProviderFactory(
                PlayIntegrityAppCheckProviderFactory.getInstance(),
            )
            Log.d(TAG, "Firebase App Check initialized (debug=false)")
        }
    }

    internal fun installIfNeeded(installFactory: () -> Unit): Boolean {
        synchronized(lock) {
            if (installed) {
                return false
            }
            return try {
                installFactory()
                installed = true
                true
            } catch (e: Exception) {
                Log.w(TAG, "Firebase App Check initialization note (${e.javaClass.simpleName})")
                false
            }
        }
    }

    internal fun resetForTesting() {
        synchronized(lock) {
            installed = false
        }
    }
}
