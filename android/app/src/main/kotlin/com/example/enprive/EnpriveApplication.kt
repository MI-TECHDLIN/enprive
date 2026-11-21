package com.example.enprive

import android.app.Application

/**
 * Process-level Application entrypoint that installs the build-type-scoped
 * Firebase App Check provider factory once per process immediately after
 * FirebaseInitProvider and before MainActivity, Quick Settings tile service,
 * or FlutterEngine starts.
 */
class EnpriveApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        AppCheckProviderInstaller.installIfNeeded(this)
    }
}
