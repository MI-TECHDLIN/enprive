package com.example.enprive

import android.Manifest
import android.app.AppOpsManager
import android.app.usage.UsageEvents
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.os.Process

/**
 * On-demand, strictly one-time foreground application resolver driven by
 * [UsageStatsManager.queryEvents].
 *
 * Security & privacy invariants:
 * - Zero continuous monitoring, background watchers, Accessibility services,
 *   or persistent usage-history storage.
 * - Executes ONLY when invoked explicitly by Quick Settings tile click or user retry.
 * - Never fabricates certainty: surfaces explicit `resolutionStatus` and
 *   `confidence` states (`identified`, `ambiguous`, `stale`, `usageAccessDenied`,
 *   `noRecentApplication`, `packageNotVisible`, `resolutionFailed`).
 */
object ForegroundAppResolver {

    const val DEFAULT_CANDIDATE_WINDOW_MS = 30_000L
    const val DEFAULT_STALE_CUTOFF_MS = 120_000L
    const val DEFAULT_AMBIGUITY_TIE_WINDOW_MS = 8_000L

    private const val MAX_FUTURE_SKEW_MS = 5_000L
    private const val MAX_CANDIDATES = 4

    /**
     * Strictly transient system interaction shells (Quick Settings shade, runtime
     * permission prompt controller, chooser/resolver, package installer) that appear
     * briefly on top of the app the user is actually interacting with.
     * Preinstalled user apps (Chrome, Maps, Settings, Calculator, etc.) are NOT excluded.
     */
    private val TRANSIENT_INTERACTION_PACKAGES = setOf(
        "com.android.systemui",
        "com.android.permissioncontroller",
        "com.google.android.permissioncontroller",
        "com.android.packageinstaller",
        "com.google.android.packageinstaller",
        "android",
    )

    enum class UsageAccessStatus(val wireValue: String) {
        GRANTED("granted"),
        DENIED("denied"),
        UNAVAILABLE("unavailable"),
    }

    enum class ResolutionStatus(val wireValue: String) {
        IDENTIFIED("identified"),
        AMBIGUOUS("ambiguous"),
        STALE("stale"),
        USAGE_ACCESS_DENIED("usageAccessDenied"),
        NO_RECENT_APPLICATION("noRecentApplication"),
        PACKAGE_NOT_VISIBLE("packageNotVisible"),
        RESOLUTION_FAILED("resolutionFailed"),
    }

    data class UsageEventRecord(
        val packageName: String,
        val eventType: Int,
        val timestampMillis: Long,
    )

    data class PackageVisibilityInfo(
        val isVisible: Boolean,
        val applicationLabel: String?,
        val hasPermissionsMetadata: Boolean = true,
    )

    data class CandidateAppRecord(
        val packageName: String,
        val applicationLabel: String?,
        val eventTimestamp: Long,
        val eventAgeMillis: Long,
        val permissionMetadataAvailable: Boolean,
    ) {
        fun toMap(): Map<String, Any?> = mapOf(
            "packageName" to packageName,
            "applicationLabel" to applicationLabel,
            "eventTimestamp" to eventTimestamp,
            "eventAgeMillis" to eventAgeMillis,
            "permissionMetadataAvailable" to permissionMetadataAvailable,
        )
    }

    data class ForegroundAppResolutionResult(
        val resolutionStatus: ResolutionStatus,
        val packageName: String?,
        val applicationLabel: String?,
        val eventTimestamp: Long?,
        val eventAgeMillis: Long?,
        val confidence: String,
        val fallbackReason: String?,
        val candidates: List<CandidateAppRecord> = emptyList(),
        val permissionMetadataAvailable: Boolean = false,
        val sawTransientSystemUiEvent: Boolean = false,
    ) {
        fun toMap(): Map<String, Any?> = mapOf(
            "schemaVersion" to 1,
            "resolutionStatus" to resolutionStatus.wireValue,
            "packageName" to packageName,
            "applicationLabel" to applicationLabel,
            "eventTimestamp" to eventTimestamp,
            "eventAgeMillis" to eventAgeMillis,
            "confidence" to confidence,
            "fallbackReason" to fallbackReason,
            "candidates" to candidates.map { it.toMap() },
            "permissionMetadataAvailable" to permissionMetadataAvailable,
            "sawTransientSystemUiEvent" to sawTransientSystemUiEvent,
        )
    }

    fun checkUsageAccess(context: Context): UsageAccessStatus {
        return try {
            val appOps = context.getSystemService(Context.APP_OPS_SERVICE) as? AppOpsManager
                ?: return UsageAccessStatus.UNAVAILABLE
            @Suppress("DEPRECATION")
            val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                appOps.unsafeCheckOpNoThrow(
                    AppOpsManager.OPSTR_GET_USAGE_STATS,
                    Process.myUid(),
                    context.packageName,
                )
            } else {
                appOps.checkOpNoThrow(
                    AppOpsManager.OPSTR_GET_USAGE_STATS,
                    Process.myUid(),
                    context.packageName,
                )
            }
            when (mode) {
                AppOpsManager.MODE_ALLOWED -> UsageAccessStatus.GRANTED
                AppOpsManager.MODE_DEFAULT -> {
                    val granted = context.checkCallingOrSelfPermission(
                        Manifest.permission.PACKAGE_USAGE_STATS,
                    ) == PackageManager.PERMISSION_GRANTED
                    if (granted) UsageAccessStatus.GRANTED else UsageAccessStatus.DENIED
                }
                else -> UsageAccessStatus.DENIED
            }
        } catch (_: Throwable) {
            UsageAccessStatus.UNAVAILABLE
        }
    }

    /**
     * Executes a single bounded UsageStats event query on Android.
     */
    fun resolveCurrentForegroundApp(
        context: Context,
        queryEndTimeMs: Long = System.currentTimeMillis(),
        windowMs: Long = DEFAULT_CANDIDATE_WINDOW_MS,
        staleCutoffMs: Long = DEFAULT_STALE_CUTOFF_MS,
        ambiguityTieWindowMs: Long = DEFAULT_AMBIGUITY_TIE_WINDOW_MS,
    ): ForegroundAppResolutionResult {
        val access = checkUsageAccess(context)
        if (access != UsageAccessStatus.GRANTED) {
            return ForegroundAppResolutionResult(
                resolutionStatus = ResolutionStatus.USAGE_ACCESS_DENIED,
                packageName = null,
                applicationLabel = null,
                eventTimestamp = null,
                eventAgeMillis = null,
                confidence = "none",
                fallbackReason = if (access == UsageAccessStatus.UNAVAILABLE) {
                    "Usage Access service is unavailable on this device."
                } else {
                    "Usage Access has not been enabled in Android Settings."
                },
            )
        }

        val usm = context.getSystemService(Context.USAGE_STATS_SERVICE) as? UsageStatsManager
            ?: return ForegroundAppResolutionResult(
                resolutionStatus = ResolutionStatus.RESOLUTION_FAILED,
                packageName = null,
                applicationLabel = null,
                eventTimestamp = null,
                eventAgeMillis = null,
                confidence = "none",
                fallbackReason = "Android UsageStatsManager is unavailable.",
            )

        val effectiveCutoff = maxOf(staleCutoffMs, windowMs)
        val beginTimeMs = (queryEndTimeMs - effectiveCutoff).coerceAtLeast(0L)

        val capturedEvents = mutableListOf<UsageEventRecord>()
        try {
            val usageEvents = usm.queryEvents(beginTimeMs, queryEndTimeMs)
            val event = UsageEvents.Event()
            while (usageEvents.hasNextEvent()) {
                usageEvents.getNextEvent(event)
                val pkg = event.packageName ?: continue
                capturedEvents.add(
                    UsageEventRecord(
                        packageName = pkg,
                        eventType = event.eventType,
                        timestampMillis = event.timeStamp,
                    ),
                )
            }
        } catch (e: SecurityException) {
            return ForegroundAppResolutionResult(
                resolutionStatus = ResolutionStatus.USAGE_ACCESS_DENIED,
                packageName = null,
                applicationLabel = null,
                eventTimestamp = null,
                eventAgeMillis = null,
                confidence = "none",
                fallbackReason = "Android denied UsageStats access (${e.javaClass.simpleName}).",
            )
        } catch (e: Throwable) {
            return ForegroundAppResolutionResult(
                resolutionStatus = ResolutionStatus.RESOLUTION_FAILED,
                packageName = null,
                applicationLabel = null,
                eventTimestamp = null,
                eventAgeMillis = null,
                confidence = "none",
                fallbackReason = "Failed querying recent usage events (${e.javaClass.simpleName}).",
            )
        }

        val launcherDefaults = queryDefaultHomePackages(context.packageManager)
        return resolveFromEvents(
            events = capturedEvents,
            queryEndTimeMs = queryEndTimeMs,
            ownPackageName = context.packageName,
            usageAccessGranted = true,
            windowMs = windowMs,
            staleCutoffMs = effectiveCutoff,
            ambiguityTieWindowMs = ambiguityTieWindowMs,
            transientPackages = TRANSIENT_INTERACTION_PACKAGES + launcherDefaults,
            packageVisibilityLookup = { pkg ->
                lookupPackageVisibility(context.packageManager, pkg)
            },
        )
    }

    /**
     * Pure deterministic resolver operating over supplied [UsageEventRecord]s and
     * a mockable [packageVisibilityLookup] lambda for JVM unit tests.
     */
    fun resolveFromEvents(
        events: List<UsageEventRecord>,
        queryEndTimeMs: Long,
        ownPackageName: String,
        usageAccessGranted: Boolean = true,
        windowMs: Long = DEFAULT_CANDIDATE_WINDOW_MS,
        staleCutoffMs: Long = DEFAULT_STALE_CUTOFF_MS,
        ambiguityTieWindowMs: Long = DEFAULT_AMBIGUITY_TIE_WINDOW_MS,
        transientPackages: Set<String> = TRANSIENT_INTERACTION_PACKAGES,
        packageVisibilityLookup: (String) -> PackageVisibilityInfo,
    ): ForegroundAppResolutionResult {
        if (!usageAccessGranted) {
            return ForegroundAppResolutionResult(
                resolutionStatus = ResolutionStatus.USAGE_ACCESS_DENIED,
                packageName = null,
                applicationLabel = null,
                eventTimestamp = null,
                eventAgeMillis = null,
                confidence = "none",
                fallbackReason = "Usage Access has not been enabled in Android Settings.",
            )
        }

        val effectiveWindowMs = windowMs.coerceAtLeast(1_000L)
        val effectiveStaleMs = maxOf(staleCutoffMs, effectiveWindowMs)
        var sawTransientUi = false

        // Keep newest resume event per non-self, non-transient package within staleCutoffMs.
        val latestByPackage = linkedMapOf<String, UsageEventRecord>()

        for (record in events) {
            if (!isForegroundResumeEvent(record.eventType)) continue
            if (!CompanionContract.isValidAndroidPackageName(record.packageName)) continue
            if (record.packageName == ownPackageName) continue

            if (record.packageName in transientPackages) {
                sawTransientUi = true
                continue
            }

            if (record.timestampMillis > queryEndTimeMs + MAX_FUTURE_SKEW_MS) continue
            val ageMs = (queryEndTimeMs - record.timestampMillis).coerceAtLeast(0L)
            if (ageMs > effectiveStaleMs) continue

            val existing = latestByPackage[record.packageName]
            if (existing == null || record.timestampMillis > existing.timestampMillis) {
                latestByPackage[record.packageName] = record
            }
        }

        if (latestByPackage.isEmpty()) {
            return ForegroundAppResolutionResult(
                resolutionStatus = ResolutionStatus.NO_RECENT_APPLICATION,
                packageName = null,
                applicationLabel = null,
                eventTimestamp = null,
                eventAgeMillis = null,
                confidence = "none",
                fallbackReason = if (sawTransientUi) {
                    "Only Android system or permission prompt UI appeared in recent usage events; choose the app manually."
                } else {
                    "No recently active app was found before you tapped Enprive Check."
                },
                sawTransientSystemUiEvent = sawTransientUi,
            )
        }

        val sortedEvents = latestByPackage.values.sortedByDescending { it.timestampMillis }
        val newestEvent = sortedEvents.first()
        val newestAgeMs = (queryEndTimeMs - newestEvent.timestampMillis).coerceAtLeast(0L)

        // Resolve package visibility for candidate apps cleanly.
        val resolvedCandidates = mutableListOf<CandidateAppRecord>()
        var newestVisibility: PackageVisibilityInfo? = null
        for ((index, ev) in sortedEvents.take(MAX_CANDIDATES).withIndex()) {
            val vis = try {
                packageVisibilityLookup(ev.packageName)
            } catch (_: Throwable) {
                PackageVisibilityInfo(isVisible = false, applicationLabel = null, hasPermissionsMetadata = false)
            }
            if (index == 0) newestVisibility = vis
            if (vis.isVisible) {
                resolvedCandidates.add(
                    CandidateAppRecord(
                        packageName = ev.packageName,
                        applicationLabel = vis.applicationLabel ?: ev.packageName,
                        eventTimestamp = ev.timestampMillis,
                        eventAgeMillis = (queryEndTimeMs - ev.timestampMillis).coerceAtLeast(0L),
                        permissionMetadataAvailable = vis.hasPermissionsMetadata,
                    ),
                )
            }
        }

        if (newestVisibility == null || !newestVisibility.isVisible) {
            return ForegroundAppResolutionResult(
                resolutionStatus = ResolutionStatus.PACKAGE_NOT_VISIBLE,
                packageName = newestEvent.packageName,
                applicationLabel = null,
                eventTimestamp = newestEvent.timestampMillis,
                eventAgeMillis = newestAgeMs,
                confidence = "none",
                fallbackReason = "The most recently active app cannot be inspected under Android package visibility restrictions. Please choose an app from the list or paste its policy.",
                candidates = resolvedCandidates,
                permissionMetadataAvailable = false,
                sawTransientSystemUiEvent = sawTransientUi,
            )
        }

        val topCandidate = resolvedCandidates.first()

        // Only stale candidates exist outside the primary candidate window.
        if (newestAgeMs > effectiveWindowMs) {
            return ForegroundAppResolutionResult(
                resolutionStatus = ResolutionStatus.STALE,
                packageName = topCandidate.packageName,
                applicationLabel = topCandidate.applicationLabel,
                eventTimestamp = topCandidate.eventTimestamp,
                eventAgeMillis = topCandidate.eventAgeMillis,
                confidence = "low",
                fallbackReason = "Most recent app activity was ${(topCandidate.eventAgeMillis / 1000L)}s ago and may no longer match what is on screen.",
                candidates = resolvedCandidates,
                permissionMetadataAvailable = topCandidate.permissionMetadataAvailable,
                sawTransientSystemUiEvent = sawTransientUi,
            )
        }

        // Check for ambiguous multiple recent foreground transitions close together.
        val recentVisible = resolvedCandidates.filter { it.eventAgeMillis <= effectiveWindowMs }
        val closePeers = recentVisible.filter { candidate ->
            (topCandidate.eventTimestamp - candidate.eventTimestamp) <= ambiguityTieWindowMs
        }
        if (closePeers.size >= 2) {
            return ForegroundAppResolutionResult(
                resolutionStatus = ResolutionStatus.AMBIGUOUS,
                packageName = topCandidate.packageName,
                applicationLabel = topCandidate.applicationLabel,
                eventTimestamp = topCandidate.eventTimestamp,
                eventAgeMillis = topCandidate.eventAgeMillis,
                confidence = "medium",
                fallbackReason = "Multiple apps were recently active within ${ambiguityTieWindowMs / 1000L}s; please confirm which app you want to inspect.",
                candidates = closePeers,
                permissionMetadataAvailable = topCandidate.permissionMetadataAvailable,
                sawTransientSystemUiEvent = sawTransientUi,
            )
        }

        return ForegroundAppResolutionResult(
            resolutionStatus = ResolutionStatus.IDENTIFIED,
            packageName = topCandidate.packageName,
            applicationLabel = topCandidate.applicationLabel,
            eventTimestamp = topCandidate.eventTimestamp,
            eventAgeMillis = topCandidate.eventAgeMillis,
            confidence = "high",
            fallbackReason = null,
            candidates = resolvedCandidates,
            permissionMetadataAvailable = topCandidate.permissionMetadataAvailable,
            sawTransientSystemUiEvent = sawTransientUi,
        )
    }

    private fun isForegroundResumeEvent(eventType: Int): Boolean {
        if (eventType == UsageEvents.Event.ACTIVITY_RESUMED) return true
        @Suppress("DEPRECATION")
        return eventType == UsageEvents.Event.MOVE_TO_FOREGROUND
    }

    private fun queryDefaultHomePackages(pm: PackageManager): Set<String> {
        return try {
            val homeIntent = Intent(Intent.ACTION_MAIN).apply {
                addCategory(Intent.CATEGORY_HOME)
            }
            val resolved = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                pm.queryIntentActivities(homeIntent, PackageManager.ResolveInfoFlags.of(0L))
            } else {
                @Suppress("DEPRECATION")
                pm.queryIntentActivities(homeIntent, 0)
            }
            resolved.mapNotNull { it.activityInfo?.packageName }.toSet()
        } catch (_: Throwable) {
            emptySet()
        }
    }

    private fun lookupPackageVisibility(
        pm: PackageManager,
        packageName: String,
    ): PackageVisibilityInfo {
        return try {
            val pkgInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                pm.getPackageInfo(
                    packageName,
                    PackageManager.PackageInfoFlags.of(PackageManager.GET_PERMISSIONS.toLong()),
                )
            } else {
                @Suppress("DEPRECATION")
                pm.getPackageInfo(packageName, PackageManager.GET_PERMISSIONS)
            }
            val label = pkgInfo.applicationInfo?.loadLabel(pm)?.toString()
                ?.takeIf { it.isNotBlank() }
                ?: packageName
            PackageVisibilityInfo(
                isVisible = true,
                applicationLabel = label,
                hasPermissionsMetadata = pkgInfo.applicationInfo != null,
            )
        } catch (_: PackageManager.NameNotFoundException) {
            PackageVisibilityInfo(isVisible = false, applicationLabel = null, hasPermissionsMetadata = false)
        } catch (_: SecurityException) {
            PackageVisibilityInfo(isVisible = false, applicationLabel = null, hasPermissionsMetadata = false)
        } catch (_: Throwable) {
            PackageVisibilityInfo(isVisible = false, applicationLabel = null, hasPermissionsMetadata = false)
        }
    }
}
