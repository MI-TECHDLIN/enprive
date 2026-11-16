# Physical Device & Target Application Profile

## 1. Test Device Specification

Verified live via ADB against physical hardware (`no emulator substitution`):

| Property | Observed Value |
|---|---|
| **ADB Transport / Serial** | `007446c410310e84` (`usb:1048576X product:RMX5303RU model:RMX5303 device:RE60B8`) |
| **Manufacturer / Model** | `realme` / `RMX5303` |
| **Android Version / API** | Android `15` (`ro.build.version.release=15`), SDK `35` (`ro.build.version.sdk=35`) |
| **Security Patch** | `2026-02-01` |
| **ABI / SoC / Hardware** | `arm64-v8a` / `UMS9230E` / `ums9230_dhaka` |
| **Screen Size / Density** | `720x1604` px (`wm density=320`, `Override density: 272`) |
| `/data` Free Space at Run | `9.2G` available of `104G` (`92%` used, `95G` used) after user cleanup |
| **Google AICore (`Gemini Nano`)** | `pm path com.google.android.aicore` → **AICore not installed** |
| **Disconnection Timestamp** | `2026-11-16 19:31:36` (USB disconnected mid Knowunity text selection) |

---

## 2. Enprive Build Under Test (`com.example.enprive`)

| Property | Observed Detail |
|---|---|
| **Git Commit / Branch** | `fe3b99d` on `feature/m3-expressive-rebrand` |
| **Manifest Application Label** | `enprive` lowercase (`android/app/src/main/AndroidManifest.xml:5`) |
| **Installed APK** | `flutter build apk --debug --target-platform android-arm64` (`151M`), installed via `adb -s 007446c410310e84 install -r` |
| **Update Timestamp / Version** | `lastUpdateTime=2026-11-16 18:38:27`, `versionCode=1`, `versionName=1.0.0` |
| **Granted Permissions** | `android.permission.INTERNET` (`granted=true`) |
| **Registered Intents** | `ACTION_PROCESS_TEXT` (`text/plain`), `ACTION_SEND` (`text/plain`, `application/pdf`, DOCX) |
| **Profile Build (`--profile`)** | `app-profile.apk` (`48M`) built cleanly |
| **Release Build (`--release`)** | **FAILED** in `:app:minifyReleaseWithR8` (`ERROR: R8: Missing class com.gemalto.jp2.JP2Decoder` in `build/app/outputs/mapping/release/missing_rules.txt`) |
| **Release Signing Config** | `android/app/build.gradle.kts:44` still assigns `signingConfigs.getByName("debug")` |
| **App Check Config** | `android/local.properties` defines `sdk.dir`, `flutter.sdk`, `flutter.buildMode`, `flutter.versionName`, `flutter.versionCode`; **no `APP_CHECK_DEBUG_TOKEN`**. Debug APK installs `DebugAppCheckProviderFactory` (`MainActivity.kt:84-90`). |
| **Readiness Check on RMX5303** | [`enprive_readiness_rmx5303.png`](screenshots/enprive_readiness_rmx5303.png): *"Local scanner active — This phone uses Enprive’s built-in local clause scanner by default."* |

---

## 3. Target Third-Party Applications Observed on `RMX5303`

### 3.1 Math Makers (`com.ululab.numbers`)
- **Category / Developer**: Education / Ululab
- **Version**: `01.30.00` (`versionCode=13000003`)
- **Installer / First Install**: `com.android.vending` / `2026-11-15 19:43:27`
- **Official Privacy URL**: `https://ululab.com/privacy-policy/` (last updated `10/09/2024`, explicitly names `Math Makers, Slice Fractions series`)
- **Permission Summary**: `17` declared / `13` granted
  - Runtime denied (`granted=false`): `CAMERA`, `POST_NOTIFICATIONS`
  - Install granted (`granted=true`): `AD_ID`, `ACCESS_ADSERVICES_AD_ID`, `ACCESS_ADSERVICES_ATTRIBUTION`, `INTERNET`, `BILLING`, `ACCESS_NETWORK_STATE`, `ACCESS_WIFI_STATE`
- **Disambiguation Check**: Picker cleanly separated `Math Makers` (`com.ululab.numbers`) from `How Math Works` (`com.chooyan.maths`, `v1.7.0`) ([`17_mathmakers_in_picker.png`](applications/mathmakers/screenshots/17_mathmakers_in_picker.png)).

### 3.2 Knowunity (`de.knowunity.app`)
- **Category / Developer**: Education / Knowunity GmbH (EEA) & Knowunity Inc. (US)
- **Version**: `6.44.4` (`versionCode=130915421`)
- **Installer / First Install**: `com.android.vending` / `2026-07-31 03:10:06`
- **Official Privacy URL**: `https://knowunity.com/legal/privacy` (last updated `02/12/2026`; also links EEA policy `https://knowunity.de/legal/privacy`)
- **Permission Summary**: `33` declared / `24` granted
  - Runtime denied (`granted=false`): `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`, `CAMERA`, `RECORD_AUDIO`, `READ_CONTACTS`, `WRITE_CONTACTS`, `READ_PHONE_STATE`, `BLUETOOTH_CONNECT`, `POST_NOTIFICATIONS`
  - Install granted (subset observed): `AD_ID`, `ACCESS_ADSERVICES_AD_ID`, `ACCESS_ADSERVICES_TOPICS`, `ACCESS_ADSERVICES_CUSTOM_AUDIENCE`, `DETECT_SCREEN_CAPTURE`, `FOREGROUND_SERVICE_MICROPHONE`, `USE_BIOMETRIC`, `USE_FINGERPRINT`, `INTERNET`, `BILLING`

### 3.3 Quizlet (`com.quizlet.quizletandroid`)
- **Category / Developer**: Education
- **Version**: `10.60` (`versionCode=2601827`), `minSdk=32`, `targetSdk=36`
- **Installer / First Install**: `com.android.vending` / `2026-11-15 19:41:43`
- **Launch Activity**: `com.quizlet.quizletandroid/.ui.RootActivity`
- **Permissions Observed (Pre-Flight Dump)**:
  - Runtime denied (`granted=false`): `POST_NOTIFICATIONS`, `CAMERA`, `RECORD_AUDIO`
  - Install granted (`granted=true`): `AD_ID`, `ACCESS_ADSERVICES_AD_ID`, `ACCESS_ADSERVICES_TOPICS`, `ACCESS_ADSERVICES_CUSTOM_AUDIENCE`, `ACCESS_ADSERVICES_ATTRIBUTION`, `READ_BASIC_PHONE_STATE`, `FOREGROUND_SERVICE_MICROPHONE`, `FOREGROUND_SERVICE_MEDIA_PLAYBACK`, `USE_FINGERPRINT`, `USE_BIOMETRIC`, `INTERNET`, `BILLING`, `ACCESS_NETWORK_STATE`, `ACCESS_WIFI_STATE`, `VIBRATE`, `WAKE_LOCK`, `com.amazon.privacypass.ATTEST`

### 3.4 Transave (`com.transave.mobileapp`)
- **Category**: Finance
- **Version**: `1.0.73` (`versionCode=38`), `minSdk=32`, `targetSdk=36`
- **Installer / First Install / Last Update**: `com.android.vending` / `2026-09-11 23:59:45` / `2026-11-15 18:02:51`
- **Launch Activity**: `com.transave.mobileapp/.MainActivity`
- **Permissions Observed (Pre-Flight Dump)**:
  - Runtime denied (`granted=false`): `POST_NOTIFICATIONS`, `CAMERA`, `RECORD_AUDIO`
  - Install granted (`granted=true`): `INTERNET`, `ACCESS_NETWORK_STATE`, `USE_FINGERPRINT`, `USE_BIOMETRIC`, `VIBRATE`, `WAKE_LOCK`, `CHECK_LICENSE`, `c2dm.RECEIVE`
  - Notable declared permission: `android.permission.SYSTEM_ALERT_WINDOW`
