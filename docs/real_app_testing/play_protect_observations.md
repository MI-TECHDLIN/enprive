# Google Play Protect Observations (`RMX5303`)

**Device**: Physical Realme `RMX5303` (`007446c410310e84`), Android 15  
**Component Observed**: Google Play Store (`com.android.vending`) → Play Protect  
**Timestamp**: `2026-11-16 18:41–18:42`  
**Screenshots**:
- [`play_protect_rmx5303.png`](screenshots/play_protect_rmx5303.png)
- [`play_protect_settings_rmx5303.png`](screenshots/play_protect_settings_rmx5303.png)

---

## 1. Play Protect Configuration Verified Active

Play Protect remained **enabled** throughout installation and testing (never disabled):

| Setting | State Verified |
|---|---|
| `Scan apps with Play Protect` | **ON** (`checked=true`) |
| `Improve harmful app detection` (*Send unknown apps to Google for better detection*) | **ON** (`checked=true`) |

---

## 2. Live Installation & On-Device Scan Results

1. **Sideload Behavior (`adb -s 007446c410310e84 install -r`)**:
   - The `151M` arm64 debug APK (`com.example.enprive`, built at `fe3b99d`) installed cleanly with no Play Protect install block, telemetry warning, or restricted-app quarantine dialog.
2. **Manual Live Rescan (`18:41` / device status bar `6:42`)**:
   - Triggered manual `Scan` in Play Protect UI.
   - Reported result: **`No harmful apps found`** / **`Play Protect scanned moments ago`**.
   - Displayed recently scanned roster led by **`enprive`** (lowercase label from `AndroidManifest.xml:5`), alongside `VLC`, `YouTube Music`, `Edits`, `Nyata`, **`Math Makers`**, **`Quizlet`**, and **`+124 more`** (`131` scanned apps total; `pp.xml` baseline was `+123 more` before Enprive update scan, incrementing to `+124 more` in `pp_done.xml`).
   - Zero security warnings raised for `com.example.enprive` despite querying launchable packages (`listLaunchableApps`) and package permissions (`inspectSelectedApp`) via standard `PackageManager` APIs.

---

## 3. Observations & Release Implications

1. **Standard `PackageManager` Visibility Confirmed Safe**: Enprive reads `ACTION_MAIN`/`CATEGORY_LAUNCHER` activities and `PackageManager.GET_PERMISSIONS` purely locally for user-selected apps; Play Protect flagged zero suspicious behavior.
2. **Release Build Hygiene Gap**: While debug ADB install ran cleanly with Play Protect active, `flutter build apk --release` currently fails R8 minification on `pdfbox-android` (`Missing class com.gemalto.jp2.JP2Decoder`), and `android/app/build.gradle.kts:44` still points `release` signing to `debug` keys—both must be resolved before Play Store or signed Play Integrity testing.
3. **Manifest Brand Label**: Play Protect displays **`enprive`** (all lowercase) because `AndroidManifest.xml:5` specifies `android:label="enprive"`; capitalizing to `"Enprive"` improves visual trust in Play Protect, Launcher, Sharesheet, and `ACTION_PROCESS_TEXT`.
