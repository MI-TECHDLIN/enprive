# Transave (`com.transave.mobileapp`) — Pre-Flight Permission Findings

> [!IMPORTANT]
> Only on-device `dumpsys package` permission observations were captured before USB disconnection (`19:31:36`). No Transave screens, financial disclosures, or privacy policy text have been retrieved or analyzed yet.

---

## 1. Observed Permissions on `RMX5303`

1. **Runtime Permissions Declared (all `granted=false` on device)**:
   - `android.permission.POST_NOTIFICATIONS`
   - `android.permission.CAMERA`
   - `android.permission.RECORD_AUDIO`
2. **Install-Time Permissions Observed (`granted=true`)**:
   - `INTERNET`, `ACCESS_NETWORK_STATE`, `USE_FINGERPRINT`, `USE_BIOMETRIC`, `VIBRATE`, `WAKE_LOCK`, `CHECK_LICENSE`, `com.google.android.c2dm.permission.RECEIVE`
3. **Notable High-Sensitivity Declared Permission**:
   - **`android.permission.SYSTEM_ALERT_WINDOW`** appears in Transave's `requested permissions` manifest list (worth inspecting in Enprive's `Permissions on this phone` output and cross-checking against any financial/fraud-prevention policy disclosures).

---

## 2. Focus Areas & Privacy Boundaries Queued Upon Reconnection

1. Respect strict financial-app testing discipline: stop at any login, OTP, PIN, or biometric gate; never capture personal account info, phone numbers, or balances.
2. Locate public pre-login privacy link or Play Store `App support → Privacy policy` (`market://details?id=com.transave.mobileapp`).
3. Verify how Enprive handles financial policy vocabulary (KYC/biometrics/credit-bureau/regulator sharing) and `SYSTEM_ALERT_WINDOW` / `USE_BIOMETRIC` reporting in `PermissionComparator`.
