# Native Runtime Permission-Dialog QA Strategy (Isolated Helper APK)

- **Status:** Recommended QA Procedure (Not Yet Executed On-Device)
- **Target Environment:** Android 15 (SDK 35), Physical Hardware (e.g., Realme RMX5303) & Emulator (API 35)
- **Owner:** Enprive Engineering — Quick Settings Companion QA

---

## 1. Why an Isolated Helper APK Is Required

During QS-1 physical validation on Realme RMX5303, Quick Settings invocation was verified over third-party apps (**Math Makers**, **Knowunity**, **Quizlet**, and **TranSave**), alongside cold/warm start and `UsageStats` revocation fallback. However, **an active Android OS runtime permission modal (`GrantPermissionActivity` / system "While using the app" dialog)** was not deterministically open on screen at the moment of the Quick Settings tap on those third-party apps.

Why a minimal standalone QA helper APK solves this safely:

1. **Zero Test-Permission Pollution in Production Enprive**:
   Enprive's production manifest (`android/app/src/main/AndroidManifest.xml`) must **never** add `CAMERA`, `RECORD_AUDIO`, or `ACCESS_FINE_LOCATION` just to trigger system permission prompts during QA.
2. **Deterministic On-Demand Dialog Trigger**:
   Third-party consumer apps only prompt for permissions at specific onboarding moments or after account login, and may already have cached permission state. A clean helper APK can call `requestPermissions(...)` reliably on demand and be reset via `adb shell pm clear`.
3. **Strict Architectural Validation**:
   Confirming that **Enprive does NOT scrape, read, dismiss, or alter the active OS dialog**, does NOT claim to know which exact prompt Android was displaying, and allows the user to resume cleanly back into the helper app with the OS permission dialog still intact (or cleanly re-promptable per Android's activity lifecycle).

---

## 2. Helper Application Specification (External to Enprive Production Build)

Do **not** bundle the QA helper inside Enprive's Flutter/Android binary or release APK. Build it as a separate debug-only Android test tool (e.g., in an external scratch Android project outside `app/` or installed purely over ADB for manual QA):

| Attribute | Required Value |
|---|---|
| `applicationId` | `dev.enprive.qa.permissionprobe` *(distinct from `com.example.enprive` / production ID)* |
| `compileSdk` / `targetSdk` | `35` (Android 15) |
| `minSdk` | `26` |
| Declared Manifest Permissions | `android.permission.CAMERA`, `android.permission.RECORD_AUDIO`, `android.permission.ACCESS_FINE_LOCATION` |
| Signing | Local debug keystore only (`never` store alongside production release secrets) |
| UI Surface | Single Activity with three buttons: **Request Camera**, **Request Microphone**, **Request Precise Location**, plus a live callback status readout showing `onRequestPermissionsResult` outcome and `shouldShowRequestPermissionRationale(...)`. |

---

## 3. Step-by-Step On-Device Verification Procedure

### Preconditions

1. Physical Android 15 device (e.g., Realme RMX5303) with developer USB debugging connected.
2. Enprive debug/profile build installed with **Enprive Check** tile added to Quick Settings and **Usage Access** granted.
3. Helper APK installed and permissions reset prior to each scenario:
   ```bash
   adb install -r permission-probe-debug.apk
   adb shell pm clear dev.enprive.qa.permissionprobe
   ```

### Test Scenarios

#### Scenario A — Tap Quick Settings While System Permission Modal Is Open

1. Launch the helper app (`dev.enprive.qa.permissionprobe`) and tap **Request Camera**.
2. Wait until the Android 15 system permission dialog (*"Allow Permission Probe to take pictures and record video?"*) is visibly displayed on top of the helper app.
3. **Do not tap Allow or Deny.** Pull down Android Quick Settings and tap **Enprive Check**.
4. **Verify**:
   - Enprive opens cleanly to the Quick Settings Companion confirmation state.
   - Foreground detection identifies **Permission Probe** (`dev.enprive.qa.permissionprobe`) — *note: when the system permission controller window sits briefly over the host task, verify whether `UsageStatsManager` attributes foreground focus to `dev.enprive.qa.permissionprobe` or `com.google.android.permissioncontroller` (or ColorOS permission controller) and record the exact `packageName`*.
   - **Important Edge Case Check**: If ColorOS/AOSP `UsageStats` reports `permissioncontroller` as the most recent foreground event when the dialog itself has focus, confirm Enprive's `NativeCompanionBridge` handles or documents that behavior cleanly (or resolves the underlying caller package safely without guessing or reading UI accessibility hierarchy!).
   - Enprive displays **Camera** as `Declared · Not yet granted` (never claiming it knows the OS dialog is currently asking for Camera).
   - No `onRequestPermissionsResult` cancellation/auto-grant side effect occurs inside the helper app before the user responds.

#### Scenario B — Return to Helper App After Reading Deni Explanation

1. With Camera selected in Enprive Companion, open Deni Q&A and tap **Can I use the app without granting this access?**.
2. Tap **Return to previous app** (`moveTaskToBack(true)` / system back) in Enprive.
3. **Verify**:
   - Android returns cleanly to **Permission Probe** without crashing either task.
   - Inspect whether the Android 15 system permission dialog remained intact on resumption or whether `PermissionController` dismissed it when Quick Settings launched (`onRequestPermissionsResult` with `PERMISSION_DENIED`); record the exact OS behavior for Android 15 ColorOS vs AOSP Pixel 9.
   - Repeat **Request Microphone** and **Request Precise Location** after granting **Allow while using the app** to verify `Declared · Allowed` state vs `Declared · Not yet granted`.

#### Scenario C — Helper App With Verified Local Policy vs Unverified App

1. Verify default Companion state for `dev.enprive.qa.permissionprobe`: Enprive must show **No verified privacy policy matched on this phone yet**, rely on zero cloud calls when asking Deni, and display `0 quote verified · N observed on phone` / `DEVICE OBSERVED` badges cleanly without presenting manifest data as policy quotes.

---

## 4. Explicit Release & Security Boundaries

- **Do not** add `CAMERA`, `RECORD_AUDIO`, or `ACCESS_FINE_LOCATION` to `/android/app/src/main/AndroidManifest.xml`.
- **Do not** add `AccessibilityService`, `BIND_ACCESSIBILITY_SERVICE`, or `SYSTEM_ALERT_WINDOW` to inspect system permission dialogs — Enprive deliberately refuses screen/dialog scraping.
- **Do not** claim Scenario A/B/C as passed until physically executed on target hardware with screen captures and `adb logcat` observations recorded in `physical_device_validation.md`.
