# Enprive — Real-World Android Compatibility & UX Validation (`RMX5303`)

**Branch**: `feature/m3-expressive-rebrand`  
**Tested Commit**: `fe3b99d` (*feat(intake,integrity): close P0 blockers for URL retrieval, local documents, and payload parity (Iterations 29-30)*)  
**Target Physical Device**: Realme `RMX5303` (`007446c410310e84`), Android 15 (SDK 35)  
**Validation Date**: 2026-11-16 (Interrupted by physical USB disconnect at `19:31:36`)

> [!IMPORTANT]
> **Session Boundary & Integrity Note**: This directory documents what was **actually executed and observed** on the physical Realme RMX5303 before the USB connection dropped at `19:31:36`. Live testing for **Math Makers** (near-complete) and **Knowunity** (discovery, permissions, and `ACTION_PROCESS_TEXT` menu) plus **Google Play Protect** ran on-device. Live UI journeys for **Quizlet**, **Transave**, the **SAF/DOCX/PDF (`5E`)** document matrix, and finishing **Knowunity (`5B`/`5C`/`5D`/`5F`)** remain **NOT EXECUTED** pending USB reconnection (no emulator substitution was used). **No application source code was modified during this validation pass.**

---

## Report Directory Map

| Document | Scope & Contents |
|---|---|
| [consolidated_acceptance_report.md](consolidated_acceptance_report.md) | Executive verdict, Section 11 Q&A (Questions 1–11), release readiness, and prioritized fix roadmap |
| [ux_friction_and_recommendations.md](ux_friction_and_recommendations.md) | Deep UX teardown explaining why navigating a real app review felt stressful + concrete redesign recommendations |
| [device_profile.md](device_profile.md) | Physical RMX5303 specs, AICore absence, APK build details, R8 release blocker, and package metadata dumps |
| [test_matrix.md](test_matrix.md) | Journey-by-journey (`5A`–`5F`), Play Protect (`Section 6`), and Defect (`D1`–`D5`) compatibility matrix |
| [play_protect_observations.md](play_protect_observations.md) | Google Play Protect live scan (`131` scanned apps) and installation behavior |
| **App Reports** | |
| [Math Makers — Test Report](applications/mathmakers/test_report.md) & [Findings](applications/mathmakers/findings.md) | `com.ululab.numbers` (`v01.30.00`) — COPPA gate discovery, URL retrieval, Chrome PNG share bug (`D1`), App Check cloud hang (`D2`), deterministic false positives (`D3`), permission inspection (`17`/`13`), `22` screenshots |
| [Knowunity — Test Report](applications/knowunity/test_report.md) & [Findings](applications/knowunity/findings.md) | `de.knowunity.app` (`v6.44.4`) — permission inspection (`33`/`24`), Play Store discovery (`knowunity.com/legal/privacy`), Chrome `ACTION_PROCESS_TEXT` overflow (`enprive`), `11` screenshots (`5B`/`5C`/`5D`/`5F` finish interrupted) |
| [Quizlet — Test Report](applications/quizlet/test_report.md) & [Findings](applications/quizlet/findings.md) | `com.quizlet.quizletandroid` (`v10.60`) — ADB metadata, Play Protect scan entry, runtime/install permissions; live UI flows **NOT EXECUTED (USB disconnect)** |
| [Transave — Test Report](applications/transave/test_report.md) & [Findings](applications/transave/findings.md) | `com.transave.mobileapp` (`v1.0.73`) — ADB metadata & `SYSTEM_ALERT_WINDOW`/biometric permissions; live UI flows **NOT EXECUTED (USB disconnect)** |

---

## Executive Snapshot

1. **Verdict**: **`PARTIALLY PASSED / BLOCKED BY P0/P1 DEFECTS & USB DISCONNECT`**
2. **Core Architectural Strengths Confirmed on Physical Hardware**:
   - Real third-party Play Store apps (`Math Makers`, `Knowunity`) appear cleanly with authentic adaptive/launcher icons and Android `PackageManager` permission reports strictly on-device (`0` upload of app inventory).
   - Genuine public URL retrieval (`https://ululab.com/privacy-policy/`) extracted real HTML prose, redacted `info@ululab.com` → `[EMAIL]` before any cloud prompt (`CloudConsentSheet`), computed genuine `SHA-256 source hash` (`c0f2da...`) and `FNV-1a 64-bit` digest (`#5bc2f641cfdc5f60`), and displayed the unverified-ownership limitation notice.
   - Google Play Protect (`Scan apps with Play Protect` ON) scanned `131` apps including `enprive` with zero warnings or blocks.
3. **Critical Defects Found on Physical Device**:
   - **Defect 1 (High — Broken Chrome Link Sharing)**: `MainActivity.kt:166` checks `readStreamUri(incomingIntent)` before `text/plain` `EXTRA_TEXT`, causing Chrome Share's preview screenshot PNG to shadow `https://ululab.com/privacy-policy/` and fail with `Unsupported document format (image/png)` (`unsupportedMime`).
   - **Defect 2 (High — Unbounded `ONLY_IN_CLOUD` App Check Stall + Misleading Copy)**: Missing `APP_CHECK_DEBUG_TOKEN` in `android/local.properties` + lack of `withTimeout` around `generateContentStream(prompt).collect` (`MainActivity.kt:830`) stalls the UI at `0%` for multiple minutes with no cancel action, while `ReviewProgressCard` misleadingly displays `"Reviewing on this phone…"` even during cloud execution.
   - **Defect 3 (Medium — Deterministic Scanner Negation Blindness)**: Local fallback (`review_coordinator.dart:1022-1075`) flagged `"Our services do not include any third party advertising."` as `"Shares ad IDs with external partners"`, and `"masked IP address... imprecise location"` as High-severity `"Tracks location even in the background — exact GPS location"`.
   - **Defect 4 (High — Release R8 Build Failure)**: `flutter build apk --release --target-platform android-arm64` fails in `:app:minifyReleaseWithR8` (`Missing class com.gemalto.jp2.JP2Decoder`).
   - **Defect 5 (Medium — High Multi-App UX & Navigation Stress)**: Parents/teachers must leave Enprive, hunt across onboarding/COPPA gates/Play Store for a policy URL, manually switch modes across deeply nested modal sheets with dead-end error states, silent 25-app list truncation, lost app icons in results, and floating bottom-dock overlap on small (`720x1604`) screens.
