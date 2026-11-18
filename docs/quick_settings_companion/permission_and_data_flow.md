# Permission Model, Usage Access & Data Flow Guarantees

## 1. Android Manifest Declarations ([AndroidManifest.xml](../../android/app/src/main/AndroidManifest.xml))

| Declaration | Scope & Purpose | Guardrail Verified |
|---|---|---|
| `<uses-permission android:name="android.permission.INTERNET" />` | Public developer privacy-policy HTTP(S) retrieval & consented cloud AI calls | Pre-existing (D1–D4 baseline); zero new network permissions |
| `<uses-permission android:name="android.permission.PACKAGE_USAGE_STATS" tools:ignore="ProtectedPermissions" />` | One-time `UsageStatsManager.queryEvents()` lookup ONLY when user invokes `Enprive Check` or taps retry | Special Settings-granted access (`AppOpsManager.OPSTR_GET_USAGE_STATS`), optional, never requested automatically at launch |
| `<service android:name=".EnpriveCheckTileService" android:exported="true" android:permission="android.permission.BIND_QUICK_SETTINGS_TILE">` | System Quick Settings tile binding (`android.service.quicksettings.action.QS_TILE`, `ACTIVE_TILE=false`) | Bound solely by Android SystemUI; NOT declared as a `<uses-permission>` |
| `<queries>` (`MAIN/LAUNCHER`, `MAIN/HOME`, `PROCESS_TEXT`, `TTS_SERVICE`) | Narrow intent visibility for launcher apps, text selection, TTS, and filtering home launcher from foreground candidates | **No `QUERY_ALL_PACKAGES`**, no `AccessibilityService`, no `SYSTEM_ALERT_WINDOW`, no `MediaProjection` |

## 2. Usage Access Lifecycle & Honest State Machine

1. **Checking Access (`checkUsageAccess`)**:
   - Inspects `AppOpsManager.unsafeCheckOpNoThrow` (API 29+) / `checkOpNoThrow` (API 26–28) for `android:get_usage_stats`. When `MODE_DEFAULT`, falls back to `checkCallingOrSelfPermission(PACKAGE_USAGE_STATS)`.
   - Also checks `KeyguardManager.isKeyguardLocked` so lock-screen invocations hide app context until unlocked.
2. **Onboarding & Explicit Settings Launch**:
   - Never triggered on first launch without user explanation.
   - Explained transparently on both `SettingsScreen` and `CompanionScreen` (`usageAccessDenied` state):
     *"Enprive uses Usage Access only when you tap Enprive Check to identify the app you were just using. This helps Deni find the correct app and its privacy information. Enprive does not continuously monitor your screen."*
   - Tapping `"Open Usage Access Settings"` fires `Settings.ACTION_USAGE_ACCESS_SETTINGS` (package-specific URI first, falling back to generic `ACTION_USAGE_ACCESS_SETTINGS` on OEM ROMs where package URIs throw `ActivityNotFoundException`).
   - Returning to Enprive triggers `WidgetsBindingObserver.didChangeAppLifecycleState(AppLifecycleState.resumed)`, refreshing `checkUsageAccess()` cleanly without prompting repeatedly.
3. **Revocation Handling**:
   - If the user revokes Usage Access in Android Settings, the next Quick Settings tap immediately presents the non-blocking manual selection fallback (`"Choose app manually"` + `"Continue without app context"` + `"Open Usage Access Settings"`).

## 3. Foreground Confidence Contract

`ForegroundAppResolver.resolveFromEvents()` evaluates only `ACTIVITY_RESUMED` (and legacy `MOVE_TO_FOREGROUND`) events inside bounded windows relative to the tile tap timestamp:

| Condition | `resolutionStatus` | `confidence` | User Copy & Fallback |
|---|---|---|---|
| Device locked (`KeyguardManager`) | `deviceLocked` | `none` | Hides all app names, permissions, and evidence until unlocked |
| `AppOps` Usage Access denied | `usageAccessDenied` | `none` | Usage Access optional explanation + manual picker + continue without app |
| Future-skewed (`> +5s`) or all events `> 120s` / empty | `noRecentApplication` | `none` | Explains no recent app event (or transient system UI only) + manual picker |
| Newest non-transient app `NameNotFoundException` | `packageNotVisible` | `none` | Discloses Android package visibility limitation + manual picker |
| Newest event `30s < age <= 120s` | `stale` | `low` | Discloses age (`"We saw X Ns ago..."`) + confirm / choose another app |
| Multiple visible apps resumed within `8s` | `ambiguous` | `medium` | Lists recent candidates cleanly + Choose another app |
| Single recent visible app within `<= 30s` | `identified` | `high` | `"We think you're using X. Is this correct?"` -> Confirm / Choose another / Without app |

## 4. Separation of Declared vs Runtime Permission Semantics

`AppPackageInspector.inspectDeclaredSensitivePermissionsFromRaw()` maps declared permissions across Android APIs without claiming active screen prompting:

- **Runtime sensitive permissions** (Location, Camera, Microphone, Contacts, Calendar, Phone, SMS, Photos & media, Nearby devices, Notifications):
  - `REQUESTED_PERMISSION_GRANTED` set -> **`Declared · Currently granted`**
  - `REQUESTED_PERMISSION_GRANTED` unset -> **`Declared · Currently denied`**
  - `requestedPermissionsFlags == null` or `Build.VERSION.SDK_INT < minRuntimeApiLevel` (e.g., `POST_NOTIFICATIONS` on API < 33) -> **`Declared · Status unavailable`**
- **Platform identifier declarations** (`com.google.android.gms.permission.AD_ID`):
  - **`Declared in manifest · Platform ID`** (`isRuntimePermission = false`, explicitly never presented as an Android allow/deny runtime dialog).
- **Non-sensitive install permissions** (`INTERNET`, `VIBRATE`, `WAKE_LOCK`, etc.): filtered out of Companion selection.

## 5. Cloud & Evidence Privacy Boundary (`askDeniAboutPermission`)

1. **No policy verified yet**: `ReviewCoordinator.askDeniAboutPermission()` runs `0` model or network calls, answering locally from Android permission semantics and disclosing `"We couldn't verify this application's privacy policy yet."`
2. **Verified policy attached**: Routes through `askDeniAboutFinding()`:
   - Runs `ONLY_ON_DEVICE` Gemini Nano first.
   - If cloud is offered via `CloudConsentSheet`, `PiiRedactor` scrubs policy excerpts, user feature context, and questions, AND `_stripPackageIdentifier` replaces `confirmedPackageName` with `[APP_ID]`.
   - **Zero `packageName` values and zero installed-app permission inventories are included in `CloudConsentSheet` previews or `analyseText` payloads.**
   - Bounded timeouts (`20s` first-response, `45s` total) and user cancellation propagate `HybridOperationCancelledException` with 0 retries and 0 fabricated receipts.
3. **Strict local usage telemetry rule**: UsageStats `UsageEventRecord` lists exist solely transiently in memory inside `resolveCurrentForegroundApp()` and are never persisted to SQLite/SharedPreferences or uploaded to any server.
