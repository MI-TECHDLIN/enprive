# Real-App Compatibility Test Matrix (`RMX5303`)

**Status Legend**:
- **PASS**: Executed live on physical `RMX5303` (`007446c410310e84`) and met functional/integrity criteria.
- **PARTIAL PASS**: Core mechanism worked with minor/medium caveats or incomplete scroll/edge checks.
- **FAIL**: Executed live on physical `RMX5303` and uncovered a defect.
- **NOT SUPPORTED**: Underlying third-party app architecture legitimately lacks the capability (e.g., OpenGL game surface).
- **NOT EXECUTED (USB DISCONNECT)**: Physical device disconnected at `19:31:36` before live execution.

---

## 1. Application Compatibility Matrix

| App | Package & Version | 5A Policy Discovery | 5B URL Retrieval & Review | 5C Share (`ACTION_SEND`) | 5D Text Selection (`PROCESS_TEXT`) | 5E Doc Intake | 5F App Inspection & Policy Compare |
|---|---|---|---|---|---|---|---|
| **Math Makers** | `com.ululab.numbers` (`01.30.00`) | **PASS** (after 4-step onboarding + COPPA birth-year gate → `ululab.com/privacy-policy/`) | **PARTIAL PASS** (Offline local scan **PASS** + real `SHA-256`; Cloud App Check **FAIL** [D2]; Scanner negation overclaims [D3]) | **FAIL** [D1] (Chrome share sent PNG preview `clipData` shadowing URL → `unsupportedMime`) | **NOT SUPPORTED** inside app (`UnityPlayerActivity` OpenGL `SurfaceView`) | See §2 | **PARTIAL PASS** (`17` declared / `13` granted; `AD_ID` + URL attached; bottom permission comparison scroll incomplete) |
| **Knowunity** | `de.knowunity.app` (`6.44.4`) | **PASS** (Play Store `App support` → `knowunity.com/legal/privacy`; tiny pre-auth link also visible on slide 4) | **NOT EXECUTED** *(USB disconnect)* | **NOT EXECUTED** *(USB disconnect)* | **IN PROGRESS / INTERRUPTED** (`enprive` located in Chrome `⋮` overflow [`07b`]; selection drag cut off by USB drop) | See §2 | **PARTIAL PASS** (Picker disambiguation + permission inspection `33`/`24` **PASS**; policy attach **NOT EXECUTED**) |
| **Quizlet** | `com.quizlet.quizletandroid` (`10.60`) | **NOT EXECUTED** *(USB disconnect)* | **NOT EXECUTED** *(USB disconnect)* | **NOT EXECUTED** *(USB disconnect)* | **NOT EXECUTED** *(USB disconnect)* | See §2 | **PRE-FLIGHT ONLY** (ADB metadata & Play Protect clean scan captured; live UI **NOT EXECUTED**) |
| **Transave** | `com.transave.mobileapp` (`1.0.73`) | **NOT EXECUTED** *(USB disconnect)* | **NOT EXECUTED** *(USB disconnect)* | **NOT EXECUTED** *(USB disconnect)* | **NOT EXECUTED** *(USB disconnect)* | See §2 | **PRE-FLIGHT ONLY** (ADB metadata incl. `SYSTEM_ALERT_WINDOW` captured; live UI **NOT EXECUTED**) |

---

## 2. Journey 5E (Document Intake) & Infrastructure Matrix

| Check | Status on `RMX5303` | Notes / Evidence |
|---|---|---|
| **Play Protect Scan (`Section 6`)** | **PASS** | `Scan` ON + `Improve harmful app detection` ON; `131` apps clean (`play_protect_rmx5303.png`) |
| **Device Readiness (`Settings`)** | **PASS** | Correctly reports AICore absent & `Local scanner active` (`enprive_readiness_rmx5303.png`) |
| **Unsupported MIME Reject (`image/png`)** | **PASS (Guard) / FAIL (Routing)** | Rejects PNG cleanly without fabricated findings (`13_enprive_received_share.png`), triggered falsely by Chrome link Share [D1] |
| **Local PDF / TXT / DOCX SAF & `ACTION_SEND`** | **NOT EXECUTED** *(USB disconnect)* | Must be executed live once `RMX5303` is reconnected |
| **Negative Doc Cases (`corrupt.pdf`, `empty.txt`)** | **NOT EXECUTED** *(USB disconnect)* | Must be executed live once `RMX5303` is reconnected |
| **Release APK Build (`--release`)** | **FAIL** [D4] | R8 fails on missing `com.gemalto.jp2.JP2Decoder` from `pdfbox-android` |

---

## 3. Defects Recorded

| ID | Severity | Component | Summary |
|---|---|---|---|
| **D1** | **High** | `MainActivity.kt:166` | `ACTION_SEND` prioritizes Chrome's preview PNG `clipData` over `text/plain` `EXTRA_TEXT` URL, breaking browser link sharing |
| **D2** | **High** | `MainActivity.kt:830`, `review_progress_sheet.dart:144`, `local.properties` | `ONLY_IN_CLOUD` hangs at `0%` (`Streaming reasoning via App Check`) with no `withTimeout`, no Cancel button, no `APP_CHECK_DEBUG_TOKEN`, and contradicts user consent with `"Reviewing on this phone…"` copy |
| **D3** | **Medium** | `review_coordinator.dart:1022-1075` | Deterministic local clause scanner misses common negations (*"do not include any third party advertising"*) and escalates *"masked IP... imprecise location"* into High-severity *"exact GPS location in background"* |
| **D4** | **High** | `android/app/build.gradle.kts`, ProGuard/R8 | `flutter build apk --release` fails `:app:minifyReleaseWithR8` (`Missing class com.gemalto.jp2.JP2Decoder`), blocking signed release validation |
| **D5** | **Medium** | Navigation & M3E Sheets (`main.dart`, `review_result_screen.dart`, picker, dock) | High multi-app UX stress: 9+ manual hops, inconsistent modals, silent 25-app cap, lost app icons, unlinked URL-to-App flows, small-screen dock overlap, lowercase `"enprive"` label |
