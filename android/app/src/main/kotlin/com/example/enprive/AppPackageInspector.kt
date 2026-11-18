package com.example.enprive

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.AdaptiveIconDrawable
import android.os.Build
import java.io.ByteArrayOutputStream

/**
 * Single on-device PackageManager inspection component shared by both the
 * `com.enprive/hybrid_ai` bridge (`listLaunchableApps`, `getAppIcon`,
 * `inspectSelectedApp`) and `com.enprive/companion`
 * (`getDeclaredSensitivePermissions`).
 *
 * Privacy guardrails:
 * - Operates strictly on-device without `QUERY_ALL_PACKAGES`.
 * - Validates package names explicitly before calling Android APIs.
 * - Filters companion permission selectors to meaningful sensitive runtime /
 *   privacy categories and distinguishes declared state from Android runtime
 *   grant state (`granted`, `denied`, `unavailable`, `manifestDeclaredOnly`).
 */
object AppPackageInspector {

    data class SensitivePermissionSpec(
        val permission: String,
        val categoryId: String,
        val title: String,
        val whatPermissionMeans: String,
        val isRuntimePermission: Boolean = true,
        val minRuntimeApiLevel: Int = 23,
    )

    data class DeclaredSensitivePermissionRecord(
        val permission: String,
        val categoryId: String,
        val title: String,
        val whatPermissionMeans: String,
        val grantStatus: String,
        val isRuntimePermission: Boolean,
        val statusNote: String,
    ) {
        fun toMap(): Map<String, Any?> = mapOf(
            "permission" to permission,
            "categoryId" to categoryId,
            "title" to title,
            "whatPermissionMeans" to whatPermissionMeans,
            "grantStatus" to grantStatus,
            "isRuntimePermission" to isRuntimePermission,
            "statusNote" to statusNote,
        )
    }

    data class InspectedSensitivePermissionsResult(
        val status: String,
        val packageName: String,
        val applicationLabel: String?,
        val versionName: String?,
        val versionCode: Long?,
        val permissions: List<DeclaredSensitivePermissionRecord>,
        val errorMessage: String? = null,
    ) {
        fun toMap(): Map<String, Any?> = mapOf(
            "schemaVersion" to 1,
            "status" to status,
            "packageName" to packageName,
            "applicationLabel" to applicationLabel,
            "versionName" to versionName,
            "versionCode" to versionCode,
            "permissions" to permissions.map { it.toMap() },
            "errorMessage" to errorMessage,
        )
    }

    val SENSITIVE_PERMISSION_SPECS: List<SensitivePermissionSpec> = listOf(
        // Location
        SensitivePermissionSpec(
            permission = Manifest.permission.ACCESS_FINE_LOCATION,
            categoryId = "location",
            title = "Precise location",
            whatPermissionMeans = "Allows the app to read exact GPS or Wi-Fi coordinates of this device while you use it.",
        ),
        SensitivePermissionSpec(
            permission = Manifest.permission.ACCESS_COARSE_LOCATION,
            categoryId = "location",
            title = "Approximate location",
            whatPermissionMeans = "Allows the app to estimate your general city or neighborhood area from network signals.",
        ),
        SensitivePermissionSpec(
            permission = Manifest.permission.ACCESS_BACKGROUND_LOCATION,
            categoryId = "location",
            title = "Background location",
            whatPermissionMeans = "Allows the app to continue reading device location even when closed or not open on screen.",
            minRuntimeApiLevel = 29,
        ),
        // Camera
        SensitivePermissionSpec(
            permission = Manifest.permission.CAMERA,
            categoryId = "camera",
            title = "Camera",
            whatPermissionMeans = "Allows the app to take photos or record video using the device cameras.",
        ),
        // Microphone
        SensitivePermissionSpec(
            permission = Manifest.permission.RECORD_AUDIO,
            categoryId = "microphone",
            title = "Microphone",
            whatPermissionMeans = "Allows the app to capture audio or spoken voice through the device microphone.",
        ),
        // Contacts
        SensitivePermissionSpec(
            permission = Manifest.permission.READ_CONTACTS,
            categoryId = "contacts",
            title = "Contacts",
            whatPermissionMeans = "Allows the app to read names, phone numbers, and email addresses stored in your address book.",
        ),
        SensitivePermissionSpec(
            permission = Manifest.permission.WRITE_CONTACTS,
            categoryId = "contacts",
            title = "Modify contacts",
            whatPermissionMeans = "Allows the app to add or change entries saved in your device contacts.",
        ),
        // Calendar
        SensitivePermissionSpec(
            permission = Manifest.permission.READ_CALENDAR,
            categoryId = "calendar",
            title = "Calendar",
            whatPermissionMeans = "Allows the app to read calendar events, titles, times, and attendee details saved on this device.",
        ),
        SensitivePermissionSpec(
            permission = Manifest.permission.WRITE_CALENDAR,
            categoryId = "calendar",
            title = "Edit calendar",
            whatPermissionMeans = "Allows the app to create, change, or delete calendar events on this device.",
        ),
        // Phone
        SensitivePermissionSpec(
            permission = Manifest.permission.READ_PHONE_STATE,
            categoryId = "phone",
            title = "Phone status",
            whatPermissionMeans = "Allows the app to check cellular network status, ongoing calls, and device phone state.",
        ),
        SensitivePermissionSpec(
            permission = Manifest.permission.READ_PHONE_NUMBERS,
            categoryId = "phone",
            title = "Phone numbers",
            whatPermissionMeans = "Allows the app to read the phone numbers assigned to SIM profiles on this device.",
        ),
        SensitivePermissionSpec(
            permission = Manifest.permission.CALL_PHONE,
            categoryId = "phone",
            title = "Make phone calls",
            whatPermissionMeans = "Allows the app to start phone calls directly without opening the dialer first.",
        ),
        SensitivePermissionSpec(
            permission = Manifest.permission.READ_CALL_LOG,
            categoryId = "phone",
            title = "Call history",
            whatPermissionMeans = "Allows the app to inspect incoming and outgoing call logs on this phone.",
        ),
        // SMS
        SensitivePermissionSpec(
            permission = Manifest.permission.READ_SMS,
            categoryId = "sms",
            title = "SMS messages",
            whatPermissionMeans = "Allows the app to read text messages stored on this device.",
        ),
        SensitivePermissionSpec(
            permission = Manifest.permission.RECEIVE_SMS,
            categoryId = "sms",
            title = "Receive SMS",
            whatPermissionMeans = "Allows the app to monitor incoming text messages such as verification codes.",
        ),
        SensitivePermissionSpec(
            permission = Manifest.permission.SEND_SMS,
            categoryId = "sms",
            title = "Send SMS",
            whatPermissionMeans = "Allows the app to send text messages, which may incur carrier charges.",
        ),
        // Photos & media
        SensitivePermissionSpec(
            permission = "android.permission.READ_MEDIA_IMAGES",
            categoryId = "photos_media",
            title = "Photos and images",
            whatPermissionMeans = "Allows the app to access photos and images saved in your library.",
            minRuntimeApiLevel = 33,
        ),
        SensitivePermissionSpec(
            permission = "android.permission.READ_MEDIA_VIDEO",
            categoryId = "photos_media",
            title = "Videos",
            whatPermissionMeans = "Allows the app to read video files stored on your device.",
            minRuntimeApiLevel = 33,
        ),
        SensitivePermissionSpec(
            permission = "android.permission.READ_MEDIA_AUDIO",
            categoryId = "photos_media",
            title = "Music and audio files",
            whatPermissionMeans = "Allows the app to read audio recordings and music files stored on your device.",
            minRuntimeApiLevel = 33,
        ),
        SensitivePermissionSpec(
            permission = "android.permission.READ_MEDIA_VISUAL_USER_SELECTED",
            categoryId = "photos_media",
            title = "Selected photos & videos",
            whatPermissionMeans = "Reflects Android's partial photo/video selection grant to only items you picked.",
            minRuntimeApiLevel = 34,
        ),
        SensitivePermissionSpec(
            permission = Manifest.permission.READ_EXTERNAL_STORAGE,
            categoryId = "photos_media",
            title = "Files and media storage",
            whatPermissionMeans = "Allows the app to read files, photos, or media stored on shared device storage.",
        ),
        // Nearby devices
        SensitivePermissionSpec(
            permission = "android.permission.BLUETOOTH_CONNECT",
            categoryId = "nearby_devices",
            title = "Nearby Bluetooth devices",
            whatPermissionMeans = "Allows the app to connect to paired Bluetooth accessories such as headphones or sensors.",
            minRuntimeApiLevel = 31,
        ),
        SensitivePermissionSpec(
            permission = "android.permission.BLUETOOTH_SCAN",
            categoryId = "nearby_devices",
            title = "Scan for nearby devices",
            whatPermissionMeans = "Allows the app to discover nearby Bluetooth devices or beacons.",
            minRuntimeApiLevel = 31,
        ),
        SensitivePermissionSpec(
            permission = "android.permission.NEARBY_WIFI_DEVICES",
            categoryId = "nearby_devices",
            title = "Nearby Wi-Fi devices",
            whatPermissionMeans = "Allows the app to find and connect to nearby devices over local Wi-Fi Direct or Wi-Fi Aware.",
            minRuntimeApiLevel = 33,
        ),
        // Notifications
        SensitivePermissionSpec(
            permission = "android.permission.POST_NOTIFICATIONS",
            categoryId = "notifications",
            title = "Notifications",
            whatPermissionMeans = "Allows the app to display alerts, reminders, or badges in the Android notification shade.",
            minRuntimeApiLevel = 33,
        ),
        // Advertising ID (manifest-declared platform identifier, not a runtime permission prompt)
        SensitivePermissionSpec(
            permission = "com.google.android.gms.permission.AD_ID",
            categoryId = "advertising_id",
            title = "Google Advertising ID",
            whatPermissionMeans = "Allows the app to read Android's resettable advertising identifier often used for attribution or ads.",
            isRuntimePermission = false,
        ),
    )

    private val specByPermission: Map<String, SensitivePermissionSpec> =
        SENSITIVE_PERMISSION_SPECS.associateBy { it.permission }

    fun listLaunchableApps(context: Context): List<Map<String, Any>> {
        val pm = context.packageManager
        val mainIntent = Intent(Intent.ACTION_MAIN, null).apply {
            addCategory(Intent.CATEGORY_LAUNCHER)
        }
        val resolveInfos = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            pm.queryIntentActivities(mainIntent, PackageManager.ResolveInfoFlags.of(0L))
        } else {
            @Suppress("DEPRECATION")
            pm.queryIntentActivities(mainIntent, 0)
        }

        val seen = mutableSetOf<String>()
        return resolveInfos.mapNotNull { info ->
            val pkg = info.activityInfo?.packageName ?: return@mapNotNull null
            if (pkg == context.packageName || !seen.add(pkg)) {
                return@mapNotNull null
            }
            val appInfo = info.activityInfo?.applicationInfo
            val label = info.loadLabel(pm).toString().takeIf { it.isNotBlank() }
                ?: appInfo?.loadLabel(pm)?.toString()
                ?: pkg
            val isSystem = ((appInfo?.flags ?: 0) and ApplicationInfo.FLAG_SYSTEM) != 0
            mapOf(
                "packageName" to pkg,
                "appName" to label,
                "isSystemApp" to isSystem,
            )
        }.sortedWith(
            compareBy<Map<String, Any>> { it["isSystemApp"] as Boolean }
                .thenBy { (it["appName"] as String).lowercase() },
        )
    }

    fun loadAppIconPngBytes(context: Context, packageName: String, sizePx: Int): ByteArray? {
        if (!CompanionContract.isValidAndroidPackageName(packageName)) return null
        return try {
            val drawable = context.packageManager.getApplicationIcon(packageName)
            val bitmap = Bitmap.createBitmap(sizePx, sizePx, Bitmap.Config.ARGB_8888)
            try {
                val canvas = Canvas(bitmap)
                if (drawable is AdaptiveIconDrawable) {
                    val bleed = (sizePx * 0.18f).toInt()
                    drawable.setBounds(-bleed, -bleed, sizePx + bleed, sizePx + bleed)
                } else {
                    val intrinsicW = drawable.intrinsicWidth
                    val intrinsicH = drawable.intrinsicHeight
                    if (intrinsicW > 0 && intrinsicH > 0 && intrinsicW != intrinsicH) {
                        val scale = minOf(
                            sizePx.toFloat() / intrinsicW,
                            sizePx.toFloat() / intrinsicH,
                        )
                        val drawW = (intrinsicW * scale).toInt().coerceAtLeast(1)
                        val drawH = (intrinsicH * scale).toInt().coerceAtLeast(1)
                        val left = (sizePx - drawW) / 2
                        val top = (sizePx - drawH) / 2
                        drawable.setBounds(left, top, left + drawW, top + drawH)
                    } else {
                        drawable.setBounds(0, 0, sizePx, sizePx)
                    }
                }
                drawable.draw(canvas)
                val stream = ByteArrayOutputStream()
                bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
                stream.toByteArray()
            } finally {
                bitmap.recycle()
            }
        } catch (_: Throwable) {
            null
        }
    }

    fun inspectRawPermissionSnapshot(
        packageManager: PackageManager,
        packageName: String,
    ): Map<String, Any>? {
        if (!CompanionContract.isValidAndroidPackageName(packageName)) return null
        val pkgInfo = getPackageInfoWithPermissions(packageManager, packageName) ?: return null
        val appName = pkgInfo.applicationInfo?.loadLabel(packageManager)?.toString() ?: packageName
        val requested = pkgInfo.requestedPermissions?.toList() ?: emptyList()
        val granted = mutableListOf<String>()

        pkgInfo.requestedPermissions?.forEachIndexed { index, perm ->
            val flag = pkgInfo.requestedPermissionsFlags?.getOrNull(index) ?: 0
            if ((flag and PackageInfo.REQUESTED_PERMISSION_GRANTED) != 0) {
                granted.add(perm)
            }
        }

        return mapOf(
            "packageName" to packageName,
            "appName" to appName,
            "requestedPermissions" to requested,
            "grantedPermissions" to granted,
        )
    }

    fun inspectDeclaredSensitivePermissions(
        packageManager: PackageManager,
        packageName: String,
        sdkInt: Int = Build.VERSION.SDK_INT,
    ): InspectedSensitivePermissionsResult {
        if (!CompanionContract.isValidAndroidPackageName(packageName)) {
            return InspectedSensitivePermissionsResult(
                status = "invalid_package",
                packageName = packageName,
                applicationLabel = null,
                versionName = null,
                versionCode = null,
                permissions = emptyList(),
                errorMessage = "Invalid Android package name.",
            )
        }

        val pkgInfo = try {
            getPackageInfoWithPermissions(packageManager, packageName)
        } catch (_: SecurityException) {
            null
        } catch (_: Exception) {
            return InspectedSensitivePermissionsResult(
                status = "metadata_unavailable",
                packageName = packageName,
                applicationLabel = null,
                versionName = null,
                versionCode = null,
                permissions = emptyList(),
                errorMessage = "Application permission metadata could not be read on this device.",
            )
        }

        if (pkgInfo == null) {
            return InspectedSensitivePermissionsResult(
                status = "package_not_visible",
                packageName = packageName,
                applicationLabel = null,
                versionName = null,
                versionCode = null,
                permissions = emptyList(),
                errorMessage = "Android package visibility prevented inspecting this app's metadata.",
            )
        }

        val label = pkgInfo.applicationInfo?.loadLabel(packageManager)?.toString()
            ?.takeIf { it.isNotBlank() }
        val versionCode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            pkgInfo.longVersionCode
        } else {
            @Suppress("DEPRECATION")
            pkgInfo.versionCode.toLong()
        }

        return inspectDeclaredSensitivePermissionsFromRaw(
            packageName = packageName,
            applicationLabel = label,
            versionName = pkgInfo.versionName,
            versionCode = versionCode,
            requestedPermissions = pkgInfo.requestedPermissions,
            requestedPermissionsFlags = pkgInfo.requestedPermissionsFlags,
            sdkInt = sdkInt,
        )
    }

    /**
     * Pure JVM-testable permission mapper separating manifest declarations from
     * Android runtime grant status and filtering non-sensitive install permissions.
     */
    fun inspectDeclaredSensitivePermissionsFromRaw(
        packageName: String,
        applicationLabel: String?,
        versionName: String?,
        versionCode: Long?,
        requestedPermissions: Array<out String>?,
        requestedPermissionsFlags: IntArray?,
        sdkInt: Int = Build.VERSION.SDK_INT,
    ): InspectedSensitivePermissionsResult {
        if (!CompanionContract.isValidAndroidPackageName(packageName)) {
            return InspectedSensitivePermissionsResult(
                status = "invalid_package",
                packageName = packageName,
                applicationLabel = null,
                versionName = null,
                versionCode = null,
                permissions = emptyList(),
                errorMessage = "Invalid Android package name.",
            )
        }

        val declared = requestedPermissions?.toList().orEmpty()
        val seenPermissions = mutableSetOf<String>()
        val items = mutableListOf<DeclaredSensitivePermissionRecord>()

        declared.forEachIndexed { index, perm ->
            val spec = specByPermission[perm] ?: return@forEachIndexed
            if (!seenPermissions.add(perm)) return@forEachIndexed

            val rawFlag = requestedPermissionsFlags?.getOrNull(index)
            val (grantStatus, statusNote) = when {
                !spec.isRuntimePermission -> {
                    "manifestDeclaredOnly" to
                        "Declared in APK manifest · Not controlled by an Android runtime allow/deny toggle"
                }
                sdkInt < spec.minRuntimeApiLevel -> {
                    "unavailable" to
                        "Declared in APK manifest · Runtime status unavailable on Android API $sdkInt"
                }
                rawFlag == null -> {
                    "unavailable" to
                        "Declared in APK manifest · Grant status unavailable"
                }
                (rawFlag and PackageInfo.REQUESTED_PERMISSION_GRANTED) != 0 -> {
                    "granted" to "Declared · Currently granted"
                }
                else -> {
                    "denied" to "Declared · Currently denied"
                }
            }

            items.add(
                DeclaredSensitivePermissionRecord(
                    permission = spec.permission,
                    categoryId = spec.categoryId,
                    title = spec.title,
                    whatPermissionMeans = spec.whatPermissionMeans,
                    grantStatus = grantStatus,
                    isRuntimePermission = spec.isRuntimePermission,
                    statusNote = statusNote,
                ),
            )
        }

        return InspectedSensitivePermissionsResult(
            status = "ok",
            packageName = packageName,
            applicationLabel = applicationLabel ?: packageName,
            versionName = versionName,
            versionCode = versionCode,
            permissions = items,
        )
    }

    private fun getPackageInfoWithPermissions(
        pm: PackageManager,
        packageName: String,
    ): PackageInfo? {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                pm.getPackageInfo(
                    packageName,
                    PackageManager.PackageInfoFlags.of(PackageManager.GET_PERMISSIONS.toLong()),
                )
            } else {
                @Suppress("DEPRECATION")
                pm.getPackageInfo(packageName, PackageManager.GET_PERMISSIONS)
            }
        } catch (_: PackageManager.NameNotFoundException) {
            null
        }
    }
}
