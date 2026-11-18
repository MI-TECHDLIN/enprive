# Dependency Decisions — Quick Settings Companion (`QS-0` Audit)

## Baseline Toolchain Verified Prior to Implementation

- **Flutter SDK:** `3.47.9` (stable), **Dart SDK:** `3.13.7`
- **Gradle Wrapper:** `9.3.1` (`android/gradle/wrapper/gradle-wrapper.properties`)
- **Android Gradle Plugin (`com.android.application`):** `9.1.0` (`android/settings.gradle.kts`)
- **Kotlin Android Plugin:** `2.4.0`
- **Google Services Plugin:** `4.4.2`
- **SDK Bounds (`android/app/build.gradle.kts`):** `minSdk = 26`, `compileSdk = 36` (`flutter.compileSdkVersion`), `targetSdk = 36` (`flutter.targetSdkVersion`), `JVM_17`
- **Design System:** `material_3_expressive: 1.2.1` (`pubspec.lock`)

## Dependencies Added

**None (`0` Flutter pub.dev packages added, `0` Android Gradle dependencies added).**

All Quick Settings tile, Usage Access AppOps, `UsageStatsManager`, `StatusBarManager.requestAddTileService`, `KeyguardManager`, and `PackageManager` logic is implemented in tested first-party Kotlin (`EnpriveCheckTileService.kt`, `CompanionContract.kt`, `ForegroundAppResolver.kt`, `AppPackageInspector.kt`, `MainActivity.kt`) behind `MethodChannel('com.enprive/companion')`.

## Candidate Dependencies Rejected & Rationale

| Candidate Package | Version Evaluated | Decision | Reason |
|---|---|---|---|
| `quick_settings` | `^1.0.1` | **Rejected** | Last published ~3 years ago; relies on background Dart callbacks requiring `@pragma("vm:entry-point")`, does not handle Enprive's `KeyguardManager`/App Check invariants cleanly, and native `TileService` with API 34+ `PendingIntent` `startActivityAndCollapse` is ~90 lines of transparent Kotlin directly under our control. |
| `quick_settings_tile` | — | **Rejected** | Unmaintained / lacks verified Android 14–16 API compatibility and R8 guarantees. |
| `usage_stats` | `^2.0.1` | **Rejected** | Pulls in network/storage statistics wrappers unnecessary for Enprive's single narrow one-time `UsageStatsManager.queryEvents()` lookup; native Kotlin avoids external plugin surface completely. |
| `installed_apps` | — | **Rejected** | Adds broad package inventory scanning / risks introducing `QUERY_ALL_PACKAGES` violations; Enprive already has a narrow `<queries>` PackageManager inspector (`AppPackageInspector.kt`). |
| `permission_handler` | — | **Rejected** | Built around ordinary Android runtime permissions; `PACKAGE_USAGE_STATS` is a special Settings-controlled AppOps capability (`Settings.ACTION_USAGE_ACCESS_SETTINGS`), handled cleanly by `AppOpsManager` directly. |
| `thing_sheet` | — | **Rejected** | Unnecessary design-system duplication; project already uses `material_3_expressive: 1.2.1` (`M3EBottomSheet`, `M3ETheme`) and `EnpriveMaterialCardSurface`. |
| `speech_to_text` / `flutter_tts` | `^7.5.0` / `^4.2.5` | **Rejected** | Voice input/output excluded from QS-1..QS-4 MVP; Enprive already has local Android `TextToSpeech` in `MainActivity.kt` without adding `RECORD_AUDIO` permissions. |
| `material_3_expressive` | `1.2.1` | **Retained** | Existing canonical M3E UI dependency; reused directly with zero version churn. |
