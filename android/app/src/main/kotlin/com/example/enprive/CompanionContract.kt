package com.example.enprive

import android.app.StatusBarManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import java.util.Collections
import java.util.UUID

/**
 * Shared contract, intent builders, invocation deduplication, and lightweight
 * Quick Settings tile state persistence between [EnpriveCheckTileService],
 * [MainActivity], and the `com.enprive/companion` MethodChannel.
 */
object CompanionContract {
    const val CHANNEL = "com.enprive/companion"

    const val ACTION_OPEN_COMPANION = "com.example.enprive.action.OPEN_COMPANION"
    const val EXTRA_INVOCATION_SOURCE = "com.example.enprive.extra.INVOCATION_SOURCE"
    const val EXTRA_INVOCATION_TIMESTAMP_MS = "com.example.enprive.extra.INVOCATION_TIMESTAMP_MS"
    const val EXTRA_INVOCATION_ID = "com.example.enprive.extra.INVOCATION_ID"

    const val SOURCE_QUICK_SETTINGS = "quick_settings"

    private const val MAX_TRACKED_INVOCATIONS = 64
    private val PACKAGE_NAME_REGEX = Regex("^[a-zA-Z0-9_]+(\\.[a-zA-Z0-9_]+)+$")

    data class CompanionInvocation(
        val invocationId: String,
        val source: String,
        val timestampMs: Long,
        val deviceLocked: Boolean,
    ) {
        fun toMap(): Map<String, Any?> = mapOf(
            "schemaVersion" to 1,
            "invocationId" to invocationId,
            "source" to source,
            "timestampMs" to timestampMs,
            "deviceLocked" to deviceLocked,
        )
    }

    /**
     * Pure JVM-testable representation of an outbound [ACTION_OPEN_COMPANION] intent.
     * Deliberately carries NO foreground package name so Android intent extras can
     * never fabricate foreground application identity.
     */
    data class CompanionLaunchSpec(
        val action: String,
        val targetPackage: String,
        val targetClassName: String,
        val flags: Int,
        val invocationSource: String,
        val invocationTimestampMs: Long,
        val invocationId: String,
    )

    data class RawCompanionIntentData(
        val action: String?,
        val invocationSource: String?,
        val invocationTimestampMs: Long?,
        val invocationId: String?,
    )

    fun buildCompanionLaunchSpec(
        targetPackage: String,
        targetClassName: String = MainActivity::class.java.name,
        invocationSource: String = SOURCE_QUICK_SETTINGS,
        invocationTimestampMs: Long = System.currentTimeMillis(),
        invocationId: String = UUID.randomUUID().toString(),
    ): CompanionLaunchSpec {
        return CompanionLaunchSpec(
            action = ACTION_OPEN_COMPANION,
            targetPackage = targetPackage,
            targetClassName = targetClassName,
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                Intent.FLAG_ACTIVITY_SINGLE_TOP or
                Intent.FLAG_ACTIVITY_CLEAR_TOP,
            invocationSource = invocationSource.trim().ifEmpty { SOURCE_QUICK_SETTINGS },
            invocationTimestampMs = invocationTimestampMs,
            invocationId = invocationId.trim().ifEmpty { UUID.randomUUID().toString() },
        )
    }

    /**
     * Constructs an explicit launch Intent targeting [MainActivity] without
     * fabricating or passing any assumed foreground application package name.
     */
    fun buildCompanionLaunchIntent(
        context: Context,
        invocationSource: String = SOURCE_QUICK_SETTINGS,
        invocationTimestampMs: Long = System.currentTimeMillis(),
        invocationId: String = UUID.randomUUID().toString(),
    ): Intent {
        val spec = buildCompanionLaunchSpec(
            targetPackage = context.packageName,
            invocationSource = invocationSource,
            invocationTimestampMs = invocationTimestampMs,
            invocationId = invocationId,
        )
        return Intent(spec.action).apply {
            component = ComponentName(spec.targetPackage, spec.targetClassName)
            addFlags(spec.flags)
            putExtra(EXTRA_INVOCATION_SOURCE, spec.invocationSource)
            putExtra(EXTRA_INVOCATION_TIMESTAMP_MS, spec.invocationTimestampMs)
            putExtra(EXTRA_INVOCATION_ID, spec.invocationId)
        }
    }

    fun parseCompanionInvocationData(
        data: RawCompanionIntentData,
        isDeviceLocked: Boolean,
        fallbackTimestampMs: Long = System.currentTimeMillis(),
    ): CompanionInvocation? {
        if (data.action != ACTION_OPEN_COMPANION) return null
        val rawSource = data.invocationSource
            ?.trim()
            ?.takeIf { it.isNotEmpty() }
            ?: SOURCE_QUICK_SETTINGS
        val ts = data.invocationTimestampMs
            ?.takeIf { it > 0L }
            ?: fallbackTimestampMs
        val id = data.invocationId
            ?.trim()
            ?.takeIf { it.isNotEmpty() }
            ?: "${rawSource}_$ts"

        return CompanionInvocation(
            invocationId = id,
            source = rawSource,
            timestampMs = ts,
            deviceLocked = isDeviceLocked,
        )
    }

    /**
     * Parses an incoming [Intent] when its action matches [ACTION_OPEN_COMPANION].
     * Returns null for non-companion actions (such as MAIN, ACTION_SEND, or PROCESS_TEXT).
     */
    fun parseCompanionInvocation(
        intent: Intent?,
        isDeviceLocked: Boolean,
        fallbackTimestampMs: Long = System.currentTimeMillis(),
    ): CompanionInvocation? {
        if (intent == null) return null
        val ts = intent.getLongExtra(EXTRA_INVOCATION_TIMESTAMP_MS, -1L)
            .takeIf { it > 0L }
        return parseCompanionInvocationData(
            data = RawCompanionIntentData(
                action = intent.action,
                invocationSource = intent.getStringExtra(EXTRA_INVOCATION_SOURCE),
                invocationTimestampMs = ts,
                invocationId = intent.getStringExtra(EXTRA_INVOCATION_ID),
            ),
            isDeviceLocked = isDeviceLocked,
            fallbackTimestampMs = fallbackTimestampMs,
        )
    }

    /**
     * Validates an Android package name strictly before touching PackageManager.
     */
    fun isValidAndroidPackageName(packageName: String?): Boolean {
        val trimmed = packageName?.trim() ?: return false
        if (trimmed.isEmpty() || trimmed.length > 255) return false
        return PACKAGE_NAME_REGEX.matches(trimmed)
    }

    /**
     * Maps [StatusBarManager] `requestAddTileService` callback integers into
     * explicit typed status strings for the Flutter UI.
     */
    fun mapTileAddRequestResult(resultCode: Int): String {
        return when (resultCode) {
            StatusBarManager.TILE_ADD_REQUEST_RESULT_TILE_ADDED -> "tile_added"
            StatusBarManager.TILE_ADD_REQUEST_RESULT_TILE_ALREADY_ADDED -> "already_added"
            StatusBarManager.TILE_ADD_REQUEST_RESULT_TILE_NOT_ADDED -> "declined"
            else -> "failed"
        }
    }

    /**
     * Bounded synchronized tracker ensuring repeated activity lifecycle passes
     * or duplicated Intent deliveries never re-trigger the same Quick Settings tap.
     */
    class InvocationTracker(
        private val maxSize: Int = MAX_TRACKED_INVOCATIONS,
    ) {
        private val seenIds: MutableSet<String> = Collections.synchronizedSet(
            object : LinkedHashSet<String>() {},
        )

        @Synchronized
        fun consumeIfUnprocessed(invocationId: String): Boolean {
            if (invocationId.isBlank()) return false
            if (seenIds.contains(invocationId)) return false
            if (seenIds.size >= maxSize) {
                val oldest = seenIds.firstOrNull()
                if (oldest != null) {
                    seenIds.remove(oldest)
                }
            }
            seenIds.add(invocationId)
            return true
        }
    }
}

/**
 * Local-only SharedPreferences store tracking user-initiated tile installation
 * status (`onTileAdded`, `onTileRemoved`, `requestAddTileService` results) so
 * Enprive never nags users who previously declined.
 */
object QuickSettingsTileStateStore {
    private const val PREFS_NAME = "enprive_quick_settings_tile_state"
    private const val KEY_TILE_ADDED = "tile_added"
    private const val KEY_TILE_DECLINED = "tile_declined"

    data class TileState(
        val isTileAdded: Boolean,
        val hasDeclinedBefore: Boolean,
    )

    fun read(context: Context): TileState {
        return try {
            val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
            TileState(
                isTileAdded = prefs.getBoolean(KEY_TILE_ADDED, false),
                hasDeclinedBefore = prefs.getBoolean(KEY_TILE_DECLINED, false),
            )
        } catch (_: Throwable) {
            TileState(isTileAdded = false, hasDeclinedBefore = false)
        }
    }

    fun markTileAdded(context: Context) {
        try {
            context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .edit()
                .putBoolean(KEY_TILE_ADDED, true)
                .putBoolean(KEY_TILE_DECLINED, false)
                .apply()
        } catch (_: Throwable) {
        }
    }

    fun markTileRemoved(context: Context) {
        try {
            context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .edit()
                .putBoolean(KEY_TILE_ADDED, false)
                .apply()
        } catch (_: Throwable) {
        }
    }

    fun markTileDeclined(context: Context) {
        try {
            context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
                .edit()
                .putBoolean(KEY_TILE_DECLINED, true)
                .apply()
        } catch (_: Throwable) {
        }
    }
}
