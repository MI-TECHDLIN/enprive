# Quizlet (`com.quizlet.quizletandroid`) — Pre-Flight Permission Findings

> [!IMPORTANT]
> Only on-device `dumpsys package` permission observations and Google Play Protect scan confirmation were captured before USB disconnection (`19:31:36`). No Quizlet privacy policy text was retrieved or analyzed yet.

---

## 1. Observed Permissions on `RMX5303`

1. **Runtime Permissions Declared (all `granted=false` on device)**:
   - `android.permission.POST_NOTIFICATIONS`
   - `android.permission.CAMERA`
   - `android.permission.RECORD_AUDIO`
2. **Install-Time Permissions Observed (`granted=true`)**:
   - **Ad / Attribution Identifiers**: `AD_ID`, `ACCESS_ADSERVICES_AD_ID`, `ACCESS_ADSERVICES_TOPICS`, `ACCESS_ADSERVICES_CUSTOM_AUDIENCE`, `ACCESS_ADSERVICES_ATTRIBUTION`, `com.amazon.privacypass.ATTEST`
   - **Telemetry & Hardware State**: `READ_BASIC_PHONE_STATE`, `FOREGROUND_SERVICE_MICROPHONE`, `FOREGROUND_SERVICE_MEDIA_PLAYBACK`, `USE_FINGERPRINT`, `USE_BIOMETRIC`, `INTERNET`, `BILLING`, `ACCESS_NETWORK_STATE`, `ACCESS_WIFI_STATE`, `VIBRATE`, `WAKE_LOCK`

---

## 2. Focus Areas Queued Upon Reconnection

1. Verify Quizlet's live privacy policy entry point (pre-login screen vs. Play Store `App support`), canonical URL, and policy sufficiency (`PolicySufficiencyValidator`).
2. Compare `CAMERA`, `RECORD_AUDIO`, and `AD_ID` / Privacy Sandbox `ACCESS_ADSERVICES_*` permissions against official Quizlet policy disclosures in Enprive (`5F`).
3. Inspect if Quizlet renders in-app Custom Tabs / WebView for legal links (`5C`/`5D` behavior).
