package com.example.enprive

import android.app.StatusBarManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.provider.Settings
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

    const val PLAY_STORE_SHARE_BACK_INSTRUCTION =
        "Locate the developer's privacy policy on the Play Store listing, " +
            "then share or copy the link back into Enprive to review."

    const val PLAY_STORE_GUIDANCE_TIP =
        "No Play Store app or web browser could open the listing on this device. " +
            "Locate the developer's privacy policy manually and share the link back into Enprive."

    const val APP_SETTINGS_GUIDANCE_TIP =
        "Android's App info screen could not be opened on this device."

    const val INVALID_PACKAGE_GUIDANCE_TIP =
        "The selected package identifier does not match a valid Android package format."

    enum class ExternalLaunchOutcome {
        LAUNCHED,
        ACTIVITY_NOT_FOUND,
        FAILED,
    }

    object ExternalNavigationStatus {
        const val OPENED_STORE = "opened_store"
        const val OPENED_WEB_FALLBACK = "opened_web_fallback"
        const val OPENED_SETTINGS = "opened_settings"
        const val ACTIVITY_NOT_FOUND = "activity_not_found"
        const val INVALID_PACKAGE = "invalid_package"
        const val FAILED = "failed"
    }

    /**
     * Pure-Kotlin external Activity launch specification so URI/action construction
     * and fallback behavior are testable in JVM unit tests without Robolectric.
     */
    data class ExternalLaunchSpec(
        val action: String,
        val uriString: String,
        val flags: Int = Intent.FLAG_ACTIVITY_NEW_TASK,
    )

    /**
     * Structured outcome returned across `com.enprive/companion` for user-initiated
     * external navigation helpers (`openPlayStoreListing`, `openAppSystemSettings`).
     */
    data class ExternalNavigationResult(
        val status: String,
        val packageName: String?,
        val launchedUri: String? = null,
        val guidanceTip: String? = null,
    ) {
        val isSuccess: Boolean
            get() = status == ExternalNavigationStatus.OPENED_STORE ||
                status == ExternalNavigationStatus.OPENED_WEB_FALLBACK ||
                status == ExternalNavigationStatus.OPENED_SETTINGS

        fun toMap(): Map<String, Any?> {
            return mapOf(
                "status" to status,
                "packageName" to packageName,
                "launchedUri" to launchedUri,
                "guidanceTip" to guidanceTip,
                "isSuccess" to isSuccess,
            )
        }
    }

    /**
     * Validates an Android package name strictly before touching PackageManager
     * or building Play Store / Settings intents.
     */
    fun isValidAndroidPackageName(packageName: String?): Boolean {
        val trimmed = packageName?.trim() ?: return false
        if (trimmed.isEmpty() || trimmed.length > 255) return false
        return PACKAGE_NAME_REGEX.matches(trimmed)
    }

    fun buildPlayStoreMarketUri(packageName: String): String {
        val trimmed = packageName.trim()
        return "market://details?id=$trimmed"
    }

    fun buildPlayStoreWebUri(packageName: String): String {
        val trimmed = packageName.trim()
        return "https://play.google.com/store/apps/details?id=$trimmed"
    }

    fun buildAppSystemSettingsUri(packageName: String): String {
        val trimmed = packageName.trim()
        return "package:$trimmed"
    }

    fun buildPlayStoreLaunchSpecs(packageName: String): List<ExternalLaunchSpec> {
        return listOf(
            ExternalLaunchSpec(
                action = Intent.ACTION_VIEW,
                uriString = buildPlayStoreMarketUri(packageName),
                flags = Intent.FLAG_ACTIVITY_NEW_TASK,
            ),
            ExternalLaunchSpec(
                action = Intent.ACTION_VIEW,
                uriString = buildPlayStoreWebUri(packageName),
                flags = Intent.FLAG_ACTIVITY_NEW_TASK,
            ),
        )
    }

    fun buildAppSettingsLaunchSpec(packageName: String): ExternalLaunchSpec {
        return ExternalLaunchSpec(
            action = Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
            uriString = buildAppSystemSettingsUri(packageName),
            flags = Intent.FLAG_ACTIVITY_NEW_TASK,
        )
    }

    /**
     * User-initiated Play Store listing coordinator: validates package syntax,
     * tries `market://details?id=...`, falls back on [ExternalLaunchOutcome.ACTIVITY_NOT_FOUND]
     * to the HTTPS Play Store URL, and returns calm guidance if neither handles it.
     */
    fun executeOpenPlayStoreListing(
        packageName: String?,
        launcher: (ExternalLaunchSpec) -> ExternalLaunchOutcome,
    ): ExternalNavigationResult {
        val trimmed = packageName?.trim()
        if (!isValidAndroidPackageName(trimmed)) {
            return ExternalNavigationResult(
                status = ExternalNavigationStatus.INVALID_PACKAGE,
                packageName = trimmed,
                guidanceTip = INVALID_PACKAGE_GUIDANCE_TIP,
            )
        }

        val specs = buildPlayStoreLaunchSpecs(trimmed!!)
        val marketSpec = specs[0]
        val webSpec = specs[1]

        return when (launcher(marketSpec)) {
            ExternalLaunchOutcome.LAUNCHED -> ExternalNavigationResult(
                status = ExternalNavigationStatus.OPENED_STORE,
                packageName = trimmed,
                launchedUri = marketSpec.uriString,
                guidanceTip = PLAY_STORE_SHARE_BACK_INSTRUCTION,
            )

            ExternalLaunchOutcome.ACTIVITY_NOT_FOUND -> when (launcher(webSpec)) {
                ExternalLaunchOutcome.LAUNCHED -> ExternalNavigationResult(
                    status = ExternalNavigationStatus.OPENED_WEB_FALLBACK,
                    packageName = trimmed,
                    launchedUri = webSpec.uriString,
                    guidanceTip = PLAY_STORE_SHARE_BACK_INSTRUCTION,
                )

                ExternalLaunchOutcome.ACTIVITY_NOT_FOUND -> ExternalNavigationResult(
                    status = ExternalNavigationStatus.ACTIVITY_NOT_FOUND,
                    packageName = trimmed,
                    guidanceTip = PLAY_STORE_GUIDANCE_TIP,
                )

                ExternalLaunchOutcome.FAILED -> ExternalNavigationResult(
                    status = ExternalNavigationStatus.FAILED,
                    packageName = trimmed,
                    guidanceTip = PLAY_STORE_GUIDANCE_TIP,
                )
            }

            ExternalLaunchOutcome.FAILED -> ExternalNavigationResult(
                status = ExternalNavigationStatus.FAILED,
                packageName = trimmed,
                guidanceTip = PLAY_STORE_GUIDANCE_TIP,
            )
        }
    }

    /**
     * User-initiated Android App info screen coordinator (`ACTION_APPLICATION_DETAILS_SETTINGS`).
     */
    fun executeOpenAppSystemSettings(
        packageName: String?,
        launcher: (ExternalLaunchSpec) -> ExternalLaunchOutcome,
    ): ExternalNavigationResult {
        val trimmed = packageName?.trim()
        if (!isValidAndroidPackageName(trimmed)) {
            return ExternalNavigationResult(
                status = ExternalNavigationStatus.INVALID_PACKAGE,
                packageName = trimmed,
                guidanceTip = INVALID_PACKAGE_GUIDANCE_TIP,
            )
        }

        val spec = buildAppSettingsLaunchSpec(trimmed!!)
        return when (launcher(spec)) {
            ExternalLaunchOutcome.LAUNCHED -> ExternalNavigationResult(
                status = ExternalNavigationStatus.OPENED_SETTINGS,
                packageName = trimmed,
                launchedUri = spec.uriString,
            )

            ExternalLaunchOutcome.ACTIVITY_NOT_FOUND -> ExternalNavigationResult(
                status = ExternalNavigationStatus.ACTIVITY_NOT_FOUND,
                packageName = trimmed,
                guidanceTip = APP_SETTINGS_GUIDANCE_TIP,
            )

            ExternalLaunchOutcome.FAILED -> ExternalNavigationResult(
                status = ExternalNavigationStatus.FAILED,
                packageName = trimmed,
                guidanceTip = APP_SETTINGS_GUIDANCE_TIP,
            )
        }
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
