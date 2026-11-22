package com.example.enprive

import android.content.Context
import android.content.pm.ApplicationInfo
import android.util.Log
import com.google.firebase.Firebase
import com.google.firebase.appcheck.AppCheckProviderFactory
import com.google.firebase.appcheck.appCheck
import com.google.firebase.appcheck.debug.DebugAppCheckProviderFactory
import com.google.firebase.appcheck.playintegrity.PlayIntegrityAppCheckProviderFactory

/**
 * Debug source-set App Check provider installer.
 *
 * Installs [DebugAppCheckProviderFactory] strictly when [ApplicationInfo.FLAG_DEBUGGABLE]
 * is set on the running process, falling back to [PlayIntegrityAppCheckProviderFactory]
 * as defense-in-depth if ever invoked without `FLAG_DEBUGGABLE`.
 *
 * Scoped to the `debug` source set so `profile` and `release` builds never compile
 * against or package `firebase-appcheck-debug`.
 */
internal object AppCheckProviderInstaller {
    private const val TAG = "EnpriveHybridAi"
    private val lock = Any()

    @Volatile
    private var installed = false

    internal enum class SelectedProvider {
        DEBUG,
        PLAY_INTEGRITY,
    }

    val isInstalled: Boolean
        get() = installed

    fun installIfNeeded(context: Context): Boolean {
        val debuggable = isDebuggableFlags(context.applicationInfo.flags)
        return installIfNeeded(
            isDebuggable = debuggable,
            installFactory = { provider ->
                val factory: AppCheckProviderFactory = when (provider) {
                    SelectedProvider.DEBUG -> DebugAppCheckProviderFactory.getInstance()
                    SelectedProvider.PLAY_INTEGRITY -> PlayIntegrityAppCheckProviderFactory.getInstance()
                }
                Firebase.appCheck.installAppCheckProviderFactory(factory)
                Log.d(
                    TAG,
                    "Firebase App Check initialized (debug=${provider == SelectedProvider.DEBUG})",
                )
            },
        )
    }

    internal fun isDebuggableFlags(flags: Int): Boolean {
        return (flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0
    }

    internal fun selectProvider(isDebuggable: Boolean): SelectedProvider {
        if (!isDebuggable) {
            Log.w(
                TAG,
                "FLAG_DEBUGGABLE not set; refusing DebugAppCheckProviderFactory and falling back to Play Integrity.",
            )
            return SelectedProvider.PLAY_INTEGRITY
        }
        return SelectedProvider.DEBUG
    }

    internal fun installIfNeeded(
        isDebuggable: Boolean,
        installFactory: (SelectedProvider) -> Unit,
    ): Boolean {
        synchronized(lock) {
            if (installed) {
                return false
            }
            val provider = selectProvider(isDebuggable)
            return try {
                installFactory(provider)
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
