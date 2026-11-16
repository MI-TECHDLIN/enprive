# Enprive — Consolidated Real-App Validation Acceptance Report (`RMX5303`)

**Application Under Test**: Enprive (`com.example.enprive`, version `1.0.0`, commit `fe3b99d` on `feature/m3-expressive-rebrand`)  
**Physical Test Device**: Realme `RMX5303` (`007446c410310e84`), Android 15 (SDK 35), **no Google AICore installed**  
**Validation Window**: `2026-11-16 18:38 – 19:31` *(halted at `19:31:36` by physical USB disconnection)*  
**Overall Verdict**: **`PARTIALLY PASSED / BLOCKED ON DEFECTS D1, D2, D4 & INCOMPLETE USB SESSION`**

---

## 1. Executive Summary

Real-device testing on the physical **Realme RMX5303** proved that Enprive's core **P0 privacy boundaries and local-first architecture work with genuine third-party Android apps**, while exposing **four technical/UX defects** (`D1`–`D4`) plus **substantial multi-app navigation friction** (`D5`) that would stress or stall a parent or judge attempting an end-to-end review directly on a non-AICore phone.

Because the USB device disconnected mid-validation during Knowunity's Chrome text-selection step, live compatibility execution covers **Math Makers** (near-complete), **Knowunity** (picker, permissions, Play Store policy discovery, and `ACTION_PROCESS_TEXT` menu discovery), **Google Play Protect**, and pre-flight metadata/permissions for **Quizlet** and **Transave**. Live flows for **Knowunity finish (`5B`/`5C`/`5D`/`5F`)**, **Quizlet (`5A`–`5F`)**, **Transave (`5A`–`5F`)**, and the **SAF/Share document intake suite (`5E`)** could not be completed without reconnecting `RMX5303`.

---

## 2. Direct Answers to Acceptance Questions (`Section 11`)

### 1) Can a real user install Enprive and inspect genuinely unfamiliar third-party apps on the Realme device?
**YES — with caveats.** Enprive installed cleanly onto Android 15 with Play Protect enabled (`151M` single-ABI arm64 debug build), listed genuinely installed third-party apps with authentic adaptive icons (`Math Makers`, `How Math Works`, `Knowunity`), inspected real Android `PackageManager` permission states locally, and fetched/analyzed Ululab's real public privacy policy URL (`ululab.com/privacy-policy/`). However, completing a combined review requires working around broken Chrome link sharing (`D1`) and stalled App Check cloud inference (`D2`).

### 2) Which privacy-policy intake paths worked end-to-end for Mathmakers, Knowunity, Quizlet, and Transave?
- **Manual Public URL (`Policy link`) + Offline Local Scan**: **Worked end-to-end** on **Math Makers** (`https://ululab.com/privacy-policy/`, `SHA-256: c0f2da...`, `7 Verified` findings), with false positives from deterministic negation bugs (`D3`).
- **Installed App Permission Inspection (`Check an app`)**: **Worked** on **Math Makers** (`17` declared / `13` granted + policy attach) and **Knowunity** (`33` declared / `24` granted, attach interrupted).
- **Android Chrome `Share…` (`ACTION_SEND`)**: **FAILED (`D1`)** on Chrome-shared URL (`ululab.com/privacy-policy/`), where Chrome's screenshot `clipData` PNG overrode `EXTRA_TEXT` and caused `Unsupported document format (image/png)`.
- **`ACTION_PROCESS_TEXT` (`5D`)**: **NOT SUPPORTED** natively inside `Math Makers` (Unity OpenGL game); located inside Chrome overflow (`⋮ → enprive`) on **Knowunity** (`07b_process_text_menu.png`), submission interrupted by USB disconnect.
- **Document Intake (`5E`: PDF/TXT/DOCX) + Quizlet (`5A`–`5F`) + Transave (`5A`–`5F`)**: **NOT EXECUTED** on physical `RMX5303` due to USB disconnect at `19:31:36`.

### 3) Did Chrome / browser / Android Sharesheet / `ACTION_PROCESS_TEXT` behave as designed?
- **Sharesheet (`ACTION_SEND`)**: **No — `Defect 1` (High)**. Appears properly in Android Sharesheet (`12_sharesheet_with_enprive.png`), but `MainActivity.kt:166` prioritizes `readStreamUri(incomingIntent)` over `text/plain` `EXTRA_TEXT`, so Chrome's URL+thumbnail link share hits `unsupportedMime` (`image/png`) instead of fetching the URL (`13_enprive_received_share.png`).
- **`ACTION_PROCESS_TEXT`**: **Partially** — registered on Android 15 Chrome under `⋮` overflow (`07b_process_text_menu.png`), but renders lowercase **`"enprive"`** (`AndroidManifest.xml:5`) rather than `"Enprive Check"` advertised on Home (`app_en.arb:55`). End-to-end modal submission was cut off by USB drop.

### 4) Did document intake (`PDF`, `TXT`, `DOCX`) work with real files?
**Partially observed (negative check only on `RMX5303`).** On `RMX5303`, receiving Chrome's `image/png` URI triggered the local MIME guard cleanly (`status: unsupportedMime`, `Insufficient evidence`, zero fabricated findings). Real local **PDF, TXT, and DOCX** intake via SAF picker and `ACTION_SEND` (`5E`), plus `corrupt.pdf` / `empty.txt`, remains **NOT EXECUTED on `RMX5303`** due to USB disconnect. *(Prior Iteration 30 verified `live_doc_policy.txt` SAF only on Pixel 9 emulator.)*

### 5) Did Google Play Protect flag, block, or impede Enprive?
**No blocking observed (`Section 6` PASS).** Tested under active **Google Play Protect** (`Scan apps with Play Protect: ON`, `Improve harmful app detection: ON`). Manual scan (`18:41`, `play_protect_rmx5303.png`) inspected `131` installed apps (`enprive`, `Math Makers`, `Quizlet`, `+124 more`) and reported **`No harmful apps found`**. *(Note: `--release` builds currently fail R8 (`D4`) and use debug keystore.)*

### 6) Did `RMX5303` support on-device Gemini Nano or fall back cleanly?
**Clean local fallback — AICore is absent on `RMX5303`.** `pm path com.google.android.aicore` returned `AICore not installed`. Settings `Check readiness` accurately reported **`Local scanner active — This phone uses Enprive’s built-in local clause scanner by default`** (`enprive_readiness_rmx5303.png`). `Review on this phone` executed strictly locally without invoking network inference.

### 7) Did Cloud AI work safely when consented, or expose timeout / App Check / failure modes?
**Exposed a High-severity hang & copy bug (`Defect 2`).** On `CloudConsentSheet`, PII redaction (`info@ululab.com` → `[EMAIL]`, `14_url_retrieval_consent_or_result.png`) worked properly before any network call. However, selecting **`Use cloud for this check`** on this debug build (no `APP_CHECK_DEBUG_TOKEN` in `android/local.properties` and no `withTimeout` around `generateContentStream(prompt).collect` at `MainActivity.kt:830`) hung at **`0%, Reviewing on this phone… | ululab.com | App Check | Streaming reasoning via App Check | 3 of 4`** (`enp_ululab_res.xml`) across multiple minutes with no Cancel button, before timing out internally into a `4 steps` `Offline local scan` without an explicit cloud-failure notice (`15b_cloud_hang_defect.png`). Copy `"Reviewing on this phone…"` during cloud streaming is also factually contradictory.

### 8) Were provenance, timestamps, SHA-256 hashes, calibrated disclaimers, and permission boundaries preserved?
**YES — verified cleanly on `Math Makers` and `Knowunity`.**
- Real `SHA-256 source hash` (`c0f2da890ce17163757d6c54ede8b665da3c3ba0fa2fe894fc750ff86e3aa956`), UTC retrieval timestamp (`Public URL (2026-11-16 18:09 UTC)`), canonical URL (`https://ululab.com/privacy-policy/`), FNV-1a snapshot digest (`#5bc2f641cfdc5f60`), and unverified-ownership notice rendered accurately in `Source` (`16_ululab_source_provenance.png`).
- Permission inspection (`18_mathmakers_permissions.png`, `02_knowunity_permissions.png`) displayed clear non-certification disclaimers (`Permission inspection only — no privacy policy has been reviewed...`), kept app lists offline, and never fabricated compliance claims.
- **Caveat**: Deterministic local findings (`D3`) falsely elevated negated advertising phrasing and coarse IP-location phrasing into scary warnings (`"Shares ad IDs"`, `"exact GPS location"`).

### 9) What defects were found, and which are P0 blockers vs P1 improvements?
- **P0 Blockers (Fix Before Competition Demo / Re-Validation)**:
  1. **`D1` (`MainActivity.kt:166`)**: Chrome link `ACTION_SEND` reads thumbnail `clipData` PNG instead of `EXTRA_TEXT` URL (`unsupportedMime`).
  2. **`D2` (`MainActivity.kt:830`, `review_progress_sheet.dart:144`, App Check)**: Unbounded `ONLY_IN_CLOUD` stream hang without `withTimeout` or Cancel + missing `APP_CHECK_DEBUG_TOKEN` + wrong `"Reviewing on this phone…"` label.
  3. **`D4` (`build.gradle.kts` / R8)**: Release APK fails R8 on `com.gemalto.jp2.JP2Decoder` from `pdfbox-android`.
- **P1 Improvements (Important Accuracy & UX Flow Fixes)**:
  4. **`D3` (`review_coordinator.dart:1022-1075`)**: Deterministic local clause scanner negation blindness (*"do not include any third party advertising"*) and severity overclaim (*"masked IP... imprecise location"* → *"exact GPS location in background"*).
  5. **`D5` (Navigation / UX Stress — see [ux_friction_and_recommendations.md](ux_friction_and_recommendations.md))**: Smart single URL/Text field, Play Store quick-open helper from permission screen, two-way `"Compare with installed app"` from policy results, remove sample cards crowding picker & silent 25-app cap, preserve app icon on hero card, capitalize `Enprive` manifest label, clear dock/gesture-bar overlap, recoverable dead-end CTAs.

### 10) Was any privacy guardrail violated during real-app testing?
**No.** Installed app inventories (`com.ululab.numbers`, `de.knowunity.app`, etc.) and Android permissions stayed strictly on-device (`PermissionComparator`), `CloudConsentSheet` required per-operation tap and redacted `info@ululab.com` → `[EMAIL]`, no raw user data or credentials were submitted or stored in screenshots, and Play Protect stayed enabled throughout.

### 11) Final Verdict
**`PARTIALLY PASSED / BLOCKED PENDING P0 FIXES (D1, D2, D4) & DEVICE RECONNECTION`**

Enprive's on-device permission inspection, live URL fetcher, SHA-256 provenance, PII scrubbing, and Play Protect safety held up cleanly on physical hardware, **but** Chrome share brokenness (`D1`), App Check cloud stall (`D2`), release R8 failure (`D4`), negation false positives (`D3`), strenuous navigation UX (`D5`), and incomplete execution on Knowunity (`5B`–`5D`/`5F`), Quizlet, Transave, and `5E` documents prevent full acceptance until repaired and re-verified on `RMX5303`.
