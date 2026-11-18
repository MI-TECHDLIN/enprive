package com.example.enprive

import android.app.PendingIntent
import android.graphics.drawable.Icon
import android.os.Build
import android.service.quicksettings.Tile
import android.service.quicksettings.TileService
import android.util.Log

/**
 * Normal (non-active) Quick Settings action tile launching Enprive's contextual
 * Deni companion into the existing `singleTop` [MainActivity].
 *
 * Security & privacy invariants:
 * - Zero continuous monitoring, overlays, or Accessibility bindings.
 * - Zero network calls or AI inference inside [TileService] callbacks.
 * - Lock-screen gated via [isLocked] + [unlockAndRun] before exposing any
 *   application context or evidence.
 * - Uses the API 34+ [PendingIntent] `startActivityAndCollapse` overload on
 *   Android 14+ and preserves compatibility on Android 8–13.
 */
class EnpriveCheckTileService : TileService() {

    override fun onTileAdded() {
        super.onTileAdded()
        QuickSettingsTileStateStore.markTileAdded(applicationContext)
        refreshTilePresentation(qsTile)
    }

    override fun onStartListening() {
        super.onStartListening()
        refreshTilePresentation(qsTile)
    }

    override fun onStopListening() {
        super.onStopListening()
    }

    override fun onTileRemoved() {
        super.onTileRemoved()
        QuickSettingsTileStateStore.markTileRemoved(applicationContext)
    }

    override fun onClick() {
        super.onClick()
        if (isLocked) {
            unlockAndRun {
                launchEnpriveCompanionSafely()
            }
            return
        }
        launchEnpriveCompanionSafely()
    }

    private fun refreshTilePresentation(tile: Tile?) {
        tile ?: return
        try {
            tile.state = Tile.STATE_INACTIVE
            tile.label = getString(R.string.qs_tile_label)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                tile.subtitle = getString(R.string.qs_tile_subtitle)
            }
            tile.icon = Icon.createWithResource(this, R.drawable.ic_qs_enprive_check)
            tile.updateTile()
        } catch (e: Throwable) {
            Log.w(TAG, "Quick Settings tile refresh fallback (${e.javaClass.simpleName})")
        }
    }

    private fun launchEnpriveCompanionSafely() {
        try {
            val timestampMs = System.currentTimeMillis()
            val launchIntent = CompanionContract.buildCompanionLaunchIntent(
                context = applicationContext,
                invocationSource = CompanionContract.SOURCE_QUICK_SETTINGS,
                invocationTimestampMs = timestampMs,
            )
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
                val requestCode = (timestampMs and 0x7FFFFFFFL).toInt()
                val pendingIntent = PendingIntent.getActivity(
                    this,
                    requestCode,
                    launchIntent,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                )
                startActivityAndCollapse(pendingIntent)
            } else {
                @Suppress("DEPRECATION")
                startActivityAndCollapse(launchIntent)
            }
        } catch (e: Throwable) {
            Log.w(TAG, "Quick Settings launch fallback (${e.javaClass.simpleName})")
        }
    }

    companion object {
        private const val TAG = "EnpriveCheckTile"
    }
}
