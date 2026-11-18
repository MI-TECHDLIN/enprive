package com.example.enprive

import android.Manifest
import android.app.StatusBarManager
import android.app.usage.UsageEvents
import android.content.Intent
import android.content.pm.PackageInfo
import android.provider.Settings
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class CompanionTileAndResolverTest {

    private val ownPkg = "com.example.enprive"

    @Test
    fun `1 selects most recent visible foreground app from recent UsageEvents`() {
        val now = 1_760_000_000_000L
        val events = listOf(
            ForegroundAppResolver.UsageEventRecord("com.quizlet.quizletandroid", UsageEvents.Event.ACTIVITY_RESUMED, now - 25_000L),
            ForegroundAppResolver.UsageEventRecord("com.ululab.numbers", UsageEvents.Event.ACTIVITY_RESUMED, now - 4_000L),
        )

        val result = ForegroundAppResolver.resolveFromEvents(
            events = events,
            queryEndTimeMs = now,
            ownPackageName = ownPkg,
            usageAccessGranted = true,
            packageVisibilityLookup = { pkg ->
                when (pkg) {
                    "com.ululab.numbers" -> ForegroundAppResolver.PackageVisibilityInfo(true, "Math Makers")
                    "com.quizlet.quizletandroid" -> ForegroundAppResolver.PackageVisibilityInfo(true, "Quizlet")
                    else -> ForegroundAppResolver.PackageVisibilityInfo(false, null, false)
                }
            },
        )

        assertEquals(ForegroundAppResolver.ResolutionStatus.IDENTIFIED, result.resolutionStatus)
        assertEquals("com.ululab.numbers", result.packageName)
        assertEquals("Math Makers", result.applicationLabel)
        assertEquals(4_000L, result.eventAgeMillis)
        assertEquals("high", result.confidence)
        assertTrue(result.permissionMetadataAvailable)
        assertEquals(2, result.candidates.size)
    }

    @Test
    fun `2 excludes Enprive own package from candidates`() {
        val now = 1_760_000_000_000L
        val events = listOf(
            ForegroundAppResolver.UsageEventRecord("de.knowunity.app", UsageEvents.Event.ACTIVITY_RESUMED, now - 5_000L),
            ForegroundAppResolver.UsageEventRecord(ownPkg, UsageEvents.Event.ACTIVITY_RESUMED, now - 200L),
        )

        val result = ForegroundAppResolver.resolveFromEvents(
            events = events,
            queryEndTimeMs = now,
            ownPackageName = ownPkg,
            usageAccessGranted = true,
            packageVisibilityLookup = { pkg ->
                ForegroundAppResolver.PackageVisibilityInfo(true, if (pkg == "de.knowunity.app") "Knowunity" else pkg)
            },
        )

        assertEquals(ForegroundAppResolver.ResolutionStatus.IDENTIFIED, result.resolutionStatus)
        assertEquals("de.knowunity.app", result.packageName)
        assertFalse(result.candidates.any { it.packageName == ownPkg })
    }

    @Test
    fun `3 returns usageAccessDenied when Usage Access permission is missing`() {
        val now = 1_760_000_000_000L
        val events = listOf(
            ForegroundAppResolver.UsageEventRecord("com.ululab.numbers", UsageEvents.Event.ACTIVITY_RESUMED, now - 2_000L),
        )

        val result = ForegroundAppResolver.resolveFromEvents(
            events = events,
            queryEndTimeMs = now,
            ownPackageName = ownPkg,
            usageAccessGranted = false,
            packageVisibilityLookup = { ForegroundAppResolver.PackageVisibilityInfo(true, "Math Makers") },
        )

        assertEquals(ForegroundAppResolver.ResolutionStatus.USAGE_ACCESS_DENIED, result.resolutionStatus)
        assertNull(result.packageName)
        assertEquals("none", result.confidence)
        assertTrue(result.candidates.isEmpty())
    }

    @Test
    fun `4 returns noRecentApplication when events are empty or beyond stale cutoff`() {
        val now = 1_760_000_000_000L

        val emptyResult = ForegroundAppResolver.resolveFromEvents(
            events = emptyList(),
            queryEndTimeMs = now,
            ownPackageName = ownPkg,
            usageAccessGranted = true,
            packageVisibilityLookup = { ForegroundAppResolver.PackageVisibilityInfo(true, it) },
        )
        assertEquals(ForegroundAppResolver.ResolutionStatus.NO_RECENT_APPLICATION, emptyResult.resolutionStatus)
        assertNull(emptyResult.packageName)

        val expiredResult = ForegroundAppResolver.resolveFromEvents(
            events = listOf(
                ForegroundAppResolver.UsageEventRecord("com.ululab.numbers", UsageEvents.Event.ACTIVITY_RESUMED, now - 150_000L),
            ),
            queryEndTimeMs = now,
            ownPackageName = ownPkg,
            usageAccessGranted = true,
            packageVisibilityLookup = { ForegroundAppResolver.PackageVisibilityInfo(true, it) },
        )
        assertEquals(ForegroundAppResolver.ResolutionStatus.NO_RECENT_APPLICATION, expiredResult.resolutionStatus)
    }

    @Test
    fun `5 marks candidate older than 30s window but within stale cutoff as stale`() {
        val now = 1_760_000_000_000L
        val events = listOf(
            ForegroundAppResolver.UsageEventRecord("com.ululab.numbers", UsageEvents.Event.ACTIVITY_RESUMED, now - 45_000L),
        )

        val result = ForegroundAppResolver.resolveFromEvents(
            events = events,
            queryEndTimeMs = now,
            ownPackageName = ownPkg,
            usageAccessGranted = true,
            windowMs = 30_000L,
            staleCutoffMs = 120_000L,
            packageVisibilityLookup = { ForegroundAppResolver.PackageVisibilityInfo(true, "Math Makers") },
        )

        assertEquals(ForegroundAppResolver.ResolutionStatus.STALE, result.resolutionStatus)
        assertEquals("com.ululab.numbers", result.packageName)
        assertEquals("Math Makers", result.applicationLabel)
        assertEquals(45_000L, result.eventAgeMillis)
        assertEquals("low", result.confidence)
    }

    @Test
    fun `6 returns ambiguous when multiple foreground apps resume within tie window`() {
        val now = 1_760_000_000_000L
        val events = listOf(
            ForegroundAppResolver.UsageEventRecord("de.knowunity.app", UsageEvents.Event.ACTIVITY_RESUMED, now - 5_500L),
            ForegroundAppResolver.UsageEventRecord("com.quizlet.quizletandroid", UsageEvents.Event.ACTIVITY_RESUMED, now - 2_000L),
        )

        val result = ForegroundAppResolver.resolveFromEvents(
            events = events,
            queryEndTimeMs = now,
            ownPackageName = ownPkg,
            usageAccessGranted = true,
            ambiguityTieWindowMs = 8_000L,
            packageVisibilityLookup = { pkg ->
                when (pkg) {
                    "de.knowunity.app" -> ForegroundAppResolver.PackageVisibilityInfo(true, "Knowunity")
                    "com.quizlet.quizletandroid" -> ForegroundAppResolver.PackageVisibilityInfo(true, "Quizlet")
                    else -> ForegroundAppResolver.PackageVisibilityInfo(false, null, false)
                }
            },
        )

        assertEquals(ForegroundAppResolver.ResolutionStatus.AMBIGUOUS, result.resolutionStatus)
        assertEquals("medium", result.confidence)
        assertEquals(2, result.candidates.size)
        assertEquals("com.quizlet.quizletandroid", result.candidates[0].packageName)
        assertEquals("de.knowunity.app", result.candidates[1].packageName)
    }

    @Test
    fun `7 skips transient systemui and permissioncontroller without discarding preinstalled Chrome`() {
        val now = 1_760_000_000_000L
        val events = listOf(
            ForegroundAppResolver.UsageEventRecord("com.android.chrome", UsageEvents.Event.ACTIVITY_RESUMED, now - 7_000L),
            ForegroundAppResolver.UsageEventRecord("com.google.android.permissioncontroller", UsageEvents.Event.ACTIVITY_RESUMED, now - 3_000L),
            ForegroundAppResolver.UsageEventRecord("com.android.systemui", UsageEvents.Event.ACTIVITY_RESUMED, now - 1_000L),
        )

        val result = ForegroundAppResolver.resolveFromEvents(
            events = events,
            queryEndTimeMs = now,
            ownPackageName = ownPkg,
            usageAccessGranted = true,
            packageVisibilityLookup = { pkg ->
                ForegroundAppResolver.PackageVisibilityInfo(
                    isVisible = pkg == "com.android.chrome",
                    applicationLabel = if (pkg == "com.android.chrome") "Chrome" else null,
                )
            },
        )

        assertEquals(ForegroundAppResolver.ResolutionStatus.IDENTIFIED, result.resolutionStatus)
        assertEquals("com.android.chrome", result.packageName)
        assertEquals("Chrome", result.applicationLabel)
        assertTrue(result.sawTransientSystemUiEvent)
    }

    @Test
    fun `8 returns packageNotVisible when PackageManager hides most recent app`() {
        val now = 1_760_000_000_000L
        val events = listOf(
            ForegroundAppResolver.UsageEventRecord("com.hidden.vendorapp", UsageEvents.Event.ACTIVITY_RESUMED, now - 3_000L),
        )

        val result = ForegroundAppResolver.resolveFromEvents(
            events = events,
            queryEndTimeMs = now,
            ownPackageName = ownPkg,
            usageAccessGranted = true,
            packageVisibilityLookup = { ForegroundAppResolver.PackageVisibilityInfo(false, null, false) },
        )

        assertEquals(ForegroundAppResolver.ResolutionStatus.PACKAGE_NOT_VISIBLE, result.resolutionStatus)
        assertEquals("com.hidden.vendorapp", result.packageName)
        assertNull(result.applicationLabel)
        assertFalse(result.permissionMetadataAvailable)
        assertEquals("none", result.confidence)
    }

    @Test
    fun `9 surfaces permissionMetadataAvailable false when package lacks permission metadata`() {
        val now = 1_760_000_000_000L
        val events = listOf(
            ForegroundAppResolver.UsageEventRecord("com.transave.mobileapp", UsageEvents.Event.ACTIVITY_RESUMED, now - 4_000L),
        )

        val result = ForegroundAppResolver.resolveFromEvents(
            events = events,
            queryEndTimeMs = now,
            ownPackageName = ownPkg,
            usageAccessGranted = true,
            packageVisibilityLookup = {
                ForegroundAppResolver.PackageVisibilityInfo(
                    isVisible = true,
                    applicationLabel = "Transave",
                    hasPermissionsMetadata = false,
                )
            },
        )

        assertEquals(ForegroundAppResolver.ResolutionStatus.IDENTIFIED, result.resolutionStatus)
        assertEquals("com.transave.mobileapp", result.packageName)
        assertFalse(result.permissionMetadataAvailable)
    }

    @Test
    fun `10 validates package names strictly and rejects malformed inputs`() {
        assertTrue(CompanionContract.isValidAndroidPackageName("com.ululab.numbers"))
        assertTrue(CompanionContract.isValidAndroidPackageName("de.knowunity.app"))
        assertFalse(CompanionContract.isValidAndroidPackageName(""))
        assertFalse(CompanionContract.isValidAndroidPackageName("   "))
        assertFalse(CompanionContract.isValidAndroidPackageName("singleword"))
        assertFalse(CompanionContract.isValidAndroidPackageName("../etc/passwd"))
        assertFalse(CompanionContract.isValidAndroidPackageName("com.example app"))

        val inspected = AppPackageInspector.inspectDeclaredSensitivePermissionsFromRaw(
            packageName = "not a valid pkg!",
            applicationLabel = "Invalid",
            versionName = null,
            versionCode = null,
            requestedPermissions = arrayOf(Manifest.permission.CAMERA),
            requestedPermissionsFlags = intArrayOf(PackageInfo.REQUESTED_PERMISSION_GRANTED),
            sdkInt = 35,
        )
        assertEquals("invalid_package", inspected.status)
        assertTrue(inspected.permissions.isEmpty())
    }

    @Test
    fun `11 separates declared runtime grant states, filters install perms, and handles missing flags`() {
        val inspectedWithMissingFlags = AppPackageInspector.inspectDeclaredSensitivePermissionsFromRaw(
            packageName = "com.example.learning",
            applicationLabel = "Learning App",
            versionName = "2.1.0",
            versionCode = 21L,
            requestedPermissions = arrayOf(
                Manifest.permission.INTERNET,
                Manifest.permission.CAMERA,
                Manifest.permission.READ_CONTACTS,
                "android.permission.POST_NOTIFICATIONS",
                "com.google.android.gms.permission.AD_ID",
            ),
            requestedPermissionsFlags = null,
            sdkInt = 35,
        )

        assertEquals("ok", inspectedWithMissingFlags.status)
        assertEquals(4, inspectedWithMissingFlags.permissions.size)
        assertFalse(inspectedWithMissingFlags.permissions.any { it.permission == Manifest.permission.INTERNET })
        val cameraMissing = inspectedWithMissingFlags.permissions.first { it.permission == Manifest.permission.CAMERA }
        assertEquals("unavailable", cameraMissing.grantStatus)
        val adId = inspectedWithMissingFlags.permissions.first { it.permission == "com.google.android.gms.permission.AD_ID" }
        assertEquals("manifestDeclaredOnly", adId.grantStatus)
        assertFalse(adId.isRuntimePermission)

        val inspectedWithFlags = AppPackageInspector.inspectDeclaredSensitivePermissionsFromRaw(
            packageName = "com.example.learning",
            applicationLabel = "Learning App",
            versionName = "2.1.0",
            versionCode = 21L,
            requestedPermissions = arrayOf(
                Manifest.permission.CAMERA,
                Manifest.permission.READ_CONTACTS,
                "android.permission.POST_NOTIFICATIONS",
            ),
            requestedPermissionsFlags = intArrayOf(
                0,
                PackageInfo.REQUESTED_PERMISSION_GRANTED,
                PackageInfo.REQUESTED_PERMISSION_GRANTED,
            ),
            sdkInt = 35,
        )
        assertEquals("denied", inspectedWithFlags.permissions[0].grantStatus)
        assertEquals("granted", inspectedWithFlags.permissions[1].grantStatus)
        assertEquals("granted", inspectedWithFlags.permissions[2].grantStatus)

        val emptyDeclared = AppPackageInspector.inspectDeclaredSensitivePermissionsFromRaw(
            packageName = "com.example.minimal",
            applicationLabel = "Minimal",
            versionName = "1.0",
            versionCode = 1L,
            requestedPermissions = null,
            requestedPermissionsFlags = null,
            sdkInt = 35,
        )
        assertEquals("ok", emptyDeclared.status)
        assertTrue(emptyDeclared.permissions.isEmpty())
    }

    @Test
    fun `12 builds explicit tile launch intent spec without fabricating foreground package`() {
        val spec = CompanionContract.buildCompanionLaunchSpec(
            targetPackage = ownPkg,
            invocationTimestampMs = 1_760_000_000_123L,
            invocationId = "qs-tap-123",
        )

        assertEquals(CompanionContract.ACTION_OPEN_COMPANION, spec.action)
        assertEquals(ownPkg, spec.targetPackage)
        assertEquals(MainActivity::class.java.name, spec.targetClassName)
        assertTrue((spec.flags and Intent.FLAG_ACTIVITY_SINGLE_TOP) != 0)
        assertTrue((spec.flags and Intent.FLAG_ACTIVITY_NEW_TASK) != 0)
        assertEquals(CompanionContract.SOURCE_QUICK_SETTINGS, spec.invocationSource)
        assertEquals(1_760_000_000_123L, spec.invocationTimestampMs)
        assertEquals("qs-tap-123", spec.invocationId)
    }

    @Test
    fun `13 parses cold-start companion invocation extras cleanly and enforces lock-screen state`() {
        val unlocked = CompanionContract.parseCompanionInvocationData(
            data = CompanionContract.RawCompanionIntentData(
                action = CompanionContract.ACTION_OPEN_COMPANION,
                invocationSource = "quick_settings",
                invocationTimestampMs = 1_760_000_000_555L,
                invocationId = "inv-abc",
            ),
            isDeviceLocked = false,
        )
        assertNotNull(unlocked)
        assertEquals("inv-abc", unlocked!!.invocationId)
        assertEquals("quick_settings", unlocked.source)
        assertFalse(unlocked.deviceLocked)

        val locked = CompanionContract.parseCompanionInvocationData(
            data = CompanionContract.RawCompanionIntentData(
                action = CompanionContract.ACTION_OPEN_COMPANION,
                invocationSource = "quick_settings",
                invocationTimestampMs = 1_760_000_000_555L,
                invocationId = "inv-locked",
            ),
            isDeviceLocked = true,
        )
        assertNotNull(locked)
        assertTrue(locked!!.deviceLocked)

        val nonCompanion = CompanionContract.parseCompanionInvocationData(
            data = CompanionContract.RawCompanionIntentData(
                action = Intent.ACTION_SEND,
                invocationSource = null,
                invocationTimestampMs = null,
                invocationId = null,
            ),
            isDeviceLocked = false,
        )
        assertNull(nonCompanion)
    }

    @Test
    fun `14 invocation tracker deduplicates repeated deliveries while allowing new taps and maps StatusBar results`() {
        val tracker = CompanionContract.InvocationTracker(maxSize = 3)
        assertTrue(tracker.consumeIfUnprocessed("tap-1"))
        assertFalse(tracker.consumeIfUnprocessed("tap-1"))
        assertTrue(tracker.consumeIfUnprocessed("tap-2"))
        assertTrue(tracker.consumeIfUnprocessed("tap-3"))
        assertTrue(tracker.consumeIfUnprocessed("tap-4"))
        // Distinct new tap still accepted, duplicate tap-4 rejected
        assertFalse(tracker.consumeIfUnprocessed("tap-4"))

        assertEquals(
            "tile_added",
            CompanionContract.mapTileAddRequestResult(StatusBarManager.TILE_ADD_REQUEST_RESULT_TILE_ADDED),
        )
        assertEquals(
            "already_added",
            CompanionContract.mapTileAddRequestResult(StatusBarManager.TILE_ADD_REQUEST_RESULT_TILE_ALREADY_ADDED),
        )
        assertEquals(
            "declined",
            CompanionContract.mapTileAddRequestResult(StatusBarManager.TILE_ADD_REQUEST_RESULT_TILE_NOT_ADDED),
        )
        assertEquals("failed", CompanionContract.mapTileAddRequestResult(1002))
    }

    @Test
    fun `15 buildPlayStoreLaunchSpecs constructs market and web fallback specs cleanly`() {
        val specs = CompanionContract.buildPlayStoreLaunchSpecs(" com.example.focusreader ")
        assertEquals(2, specs.size)

        assertEquals(Intent.ACTION_VIEW, specs[0].action)
        assertEquals("market://details?id=com.example.focusreader", specs[0].uriString)
        assertEquals(Intent.FLAG_ACTIVITY_NEW_TASK, specs[0].flags)

        assertEquals(Intent.ACTION_VIEW, specs[1].action)
        assertEquals(
            "https://play.google.com/store/apps/details?id=com.example.focusreader",
            specs[1].uriString,
        )
        assertEquals(Intent.FLAG_ACTIVITY_NEW_TASK, specs[1].flags)
    }

    @Test
    fun `16 executeOpenPlayStoreListing opens store directly and falls back to HTTPS when market missing`() {
        val launchedUris = mutableListOf<String>()
        val directResult = CompanionContract.executeOpenPlayStoreListing(
            packageName = "com.example.focusreader",
        ) { spec ->
            launchedUris.add(spec.uriString)
            CompanionContract.ExternalLaunchOutcome.LAUNCHED
        }

        assertEquals(CompanionContract.ExternalNavigationStatus.OPENED_STORE, directResult.status)
        assertTrue(directResult.isSuccess)
        assertEquals("market://details?id=com.example.focusreader", directResult.launchedUri)
        assertEquals(CompanionContract.PLAY_STORE_SHARE_BACK_INSTRUCTION, directResult.guidanceTip)
        assertEquals(listOf("market://details?id=com.example.focusreader"), launchedUris)
        val directMap = directResult.toMap()
        assertEquals("opened_store", directMap["status"])
        assertEquals(true, directMap["isSuccess"])
        assertEquals(CompanionContract.PLAY_STORE_SHARE_BACK_INSTRUCTION, directMap["guidanceTip"])

        val fallbackUris = mutableListOf<String>()
        val fallbackResult = CompanionContract.executeOpenPlayStoreListing(
            packageName = "com.example.focusreader",
        ) { spec ->
            fallbackUris.add(spec.uriString)
            if (spec.uriString.startsWith("market://")) {
                CompanionContract.ExternalLaunchOutcome.ACTIVITY_NOT_FOUND
            } else {
                CompanionContract.ExternalLaunchOutcome.LAUNCHED
            }
        }

        assertEquals(
            CompanionContract.ExternalNavigationStatus.OPENED_WEB_FALLBACK,
            fallbackResult.status,
        )
        assertTrue(fallbackResult.isSuccess)
        assertEquals(
            "https://play.google.com/store/apps/details?id=com.example.focusreader",
            fallbackResult.launchedUri,
        )
        assertEquals(CompanionContract.PLAY_STORE_SHARE_BACK_INSTRUCTION, fallbackResult.guidanceTip)
        val fallbackMap = fallbackResult.toMap()
        assertEquals("opened_web_fallback", fallbackMap["status"])
        assertEquals(true, fallbackMap["isSuccess"])
        assertEquals(
            listOf(
                "market://details?id=com.example.focusreader",
                "https://play.google.com/store/apps/details?id=com.example.focusreader",
            ),
            fallbackUris,
        )
    }

    @Test
    fun `17 executeOpenPlayStoreListing reports activity_not_found with calm guidance when store and browser absent`() {
        val result = CompanionContract.executeOpenPlayStoreListing(
            packageName = "com.example.focusreader",
        ) {
            CompanionContract.ExternalLaunchOutcome.ACTIVITY_NOT_FOUND
        }

        assertEquals(CompanionContract.ExternalNavigationStatus.ACTIVITY_NOT_FOUND, result.status)
        assertFalse(result.isSuccess)
        assertNull(result.launchedUri)
        assertEquals(CompanionContract.PLAY_STORE_GUIDANCE_TIP, result.guidanceTip)

        val map = result.toMap()
        assertEquals("activity_not_found", map["status"])
        assertEquals("com.example.focusreader", map["packageName"])
        assertEquals(false, map["isSuccess"])
        assertEquals(CompanionContract.PLAY_STORE_GUIDANCE_TIP, map["guidanceTip"])
    }

    @Test
    fun `18 executeOpenAppSystemSettings constructs ACTION_APPLICATION_DETAILS_SETTINGS and handles missing activity`() {
        val spec = CompanionContract.buildAppSettingsLaunchSpec(" com.example.focusreader ")
        assertEquals(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, spec.action)
        assertEquals("package:com.example.focusreader", spec.uriString)
        assertEquals(Intent.FLAG_ACTIVITY_NEW_TASK, spec.flags)

        val okResult = CompanionContract.executeOpenAppSystemSettings(
            packageName = "com.example.focusreader",
        ) { launchedSpec ->
            assertEquals(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, launchedSpec.action)
            assertEquals("package:com.example.focusreader", launchedSpec.uriString)
            CompanionContract.ExternalLaunchOutcome.LAUNCHED
        }
        assertEquals(CompanionContract.ExternalNavigationStatus.OPENED_SETTINGS, okResult.status)
        assertTrue(okResult.isSuccess)
        assertEquals("package:com.example.focusreader", okResult.launchedUri)
        assertNull(okResult.guidanceTip)
        val okMap = okResult.toMap()
        assertEquals("opened_settings", okMap["status"])
        assertEquals(true, okMap["isSuccess"])
        assertEquals("package:com.example.focusreader", okMap["launchedUri"])

        val missingResult = CompanionContract.executeOpenAppSystemSettings(
            packageName = "com.example.focusreader",
        ) {
            CompanionContract.ExternalLaunchOutcome.ACTIVITY_NOT_FOUND
        }
        assertEquals(
            CompanionContract.ExternalNavigationStatus.ACTIVITY_NOT_FOUND,
            missingResult.status,
        )
        assertFalse(missingResult.isSuccess)
        assertEquals(CompanionContract.APP_SETTINGS_GUIDANCE_TIP, missingResult.guidanceTip)
    }

    @Test
    fun `19 external navigation helpers reject invalid package names without invoking launcher`() {
        var launcherInvoked = false
        for (invalid in listOf(null, "", "   ", "singleword", "com.example.app!", "bad/pkg")) {
            val storeRes = CompanionContract.executeOpenPlayStoreListing(invalid) {
                launcherInvoked = true
                CompanionContract.ExternalLaunchOutcome.LAUNCHED
            }
            assertEquals(CompanionContract.ExternalNavigationStatus.INVALID_PACKAGE, storeRes.status)
            assertFalse(storeRes.isSuccess)
            assertEquals("invalid_package", storeRes.toMap()["status"])
            assertEquals(false, storeRes.toMap()["isSuccess"])

            val settingsRes = CompanionContract.executeOpenAppSystemSettings(invalid) {
                launcherInvoked = true
                CompanionContract.ExternalLaunchOutcome.LAUNCHED
            }
            assertEquals(CompanionContract.ExternalNavigationStatus.INVALID_PACKAGE, settingsRes.status)
            assertFalse(settingsRes.isSuccess)
            assertEquals("invalid_package", settingsRes.toMap()["status"])
            assertEquals(false, settingsRes.toMap()["isSuccess"])
        }
        assertFalse(launcherInvoked)
    }
}
