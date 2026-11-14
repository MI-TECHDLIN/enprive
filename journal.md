# Enprive Engineering Journal (`journal.md`)

> **PRIMARY OPERATIONAL PROTOCOL (MANDATORY)**
> 1. **Before Every Iteration**: Every agent, subagent, or collaborator **MUST** read `journal.md` first to understand the current state, active branch, architectural invariants, past challenges, and next queued milestone.
> 2. **After Every Iteration**: Before closing a task, switching models, or opening a PR, **MUST** append or update the entry in `journal.md` with:
>    - **Date & Iteration ID**
>    - **Branch & Commit(s)**
>    - **Model(s) Used**
>    - **What Was Built / Changed**
>    - **Challenges & Root-Cause Fixes**
>    - **Verification Results (`flutter analyze`, `flutter test`, Gradle)**
>    - **Next Immediate Action & Recommended Model**

---

## Current Project Snapshot
- **Project**: **Enprive** (`com.example.enprive`) — Evidence-First Hybrid AI Privacy Assistant for Parents & Teachers (**Google #BuildHybridAI 2026**)
- **Repository**: `https://github.com/MI-TECHDLIN/enprive`
- **Firebase Project**: `enprive-hybrid-ai` (Project Number: `71373777460`)
- **Current `main` HEAD**: `a5c69d1`
- **Active Feature Branch**: `feature/phase-a-privacy-boundary` (branched from `feature/splash-and-deni-icon` @ `4bbdc28`; Phase A privacy boundary restoration + closure hardening completed, awaiting manual GCP/physical-device verification before PR/Phase B)
- **Competition Deadline**: 30 November 2026, 2:00 PM PT (Feature Freeze target: 24 November 2026)
- **Next Queued Action**: Run manual live Firebase/GCP Cloud Logging audit on `enprive-hybrid-ai` and physical Android AICore/App Check verification; obtain closure sign-off before opening Phase A PR or starting Phase B.

---

## Iteration Log — 2026-11-12

### Iteration 1 — Foundation, Bilingual Design System, `EvidenceValidator` & Deni Concept C
- **Date**: 2026-11-12
- **Branch / Commits**: `55765f9`, `d3996f6`, `4067ff9`
- **Models Used**: Architectural Scout & Implementation + Image Generator Subagent
- **What Was Built**:
  - Defined the **Warm Editorial Utility** design system (`EnpriveColors`, `EnpriveTheme`) with warm paper canvas (`#F7F3EA`), deep ink (`#17212B`), calm forest teal (`#1F6F66`), and tactile `EnprivePrimaryButton` / `ProvenanceChip` components.
  - Added bilingual English (`app_en.arb`) and Korean (`app_ko.arb`) localization with calibrated non-certifying status copy (*"No concern identified in the reviewed evidence. This is not a safety certification."*).
  - Implemented deterministic `EvidenceValidator` (`lib/core/validation/evidence_validator.dart`) to verify LLM-cited quotes against source policy snapshots (`VERIFIED` vs `UNVERIFIED_CITATION`) and block binary "Safe" certification claims.
  - Explored 3 mascot concepts (Folded Note, Bookmark, Protective Pebble) and locked **Concept C: Deni the Protective Pebble with Paper Tab**. Built initial custom-painted `DeniAnimatedMascot` with idle breathing, blinking, and tap squish.
- **Challenges & Fixes**:
  - *Challenge*: Preventing hallucinated privacy claims from ever reaching parent/teacher UI.
  - *Fix*: Designed `EvidenceValidator` so any finding without a verbatim substring match (after whitespace normalization) is stripped from verified findings and downgraded to `UNVERIFIED_CITATION`.
- **Verification**:
  - `flutter analyze`: 0 issues.
  - `flutter test`: 6/6 tests passing (`test/evidence_validator_test.dart`, `test/widget_test.dart`).

---

### Iteration 2 — Firebase AI Logic Provisioning, Native Kotlin Bridge & `AGENTS.md` Governance
- **Date**: 2026-11-12
- **Branch / Commits**: `feature/firebase-hybrid-ai-bridge` (`607d045`, `ed4009f`) → Merged via **PR #1** (`bbce7bb`)
- **Models Used**: Gemini 4 Argon
- **What Was Built**:
  - Provisioned dedicated Firebase project **`enprive-hybrid-ai`** (`71373777460`), registered Android app `com.example.enprive`, downloaded `android/app/google-services.json`, and enabled Firebase AI Logic (`firebase init ailogic`).
  - Configured `android/settings.gradle.kts` (`com.google.gms.google-services:4.4.2`) and `android/app/build.gradle.kts` (`minSdk = 26`, `firebase-bom:33.7.0`, `firebase-ai:18.2.0`, `firebase-ai-ondevice:16.0.0-beta08`, `firebase-appcheck-debug`, `firebase-appcheck-playintegrity`).
  - Created native Kotlin MethodChannel bridge (`com.enprive/hybrid_ai`) in `MainActivity.kt` and Dart wrapper `lib/services/hybrid_ai_bridge.dart`.
  - Created `AGENTS.md` and `.agents/AGENTS.md` codifying model routing (`Gemini 4 Argon` / `Claude Opus 5.5` for heavy implementation; `Devin CLI` / `Gemini Flash` / `Gemini Hydrogen` / `Claude Sonnet` for bugs/config), feature-branch discipline, and #BuildHybridAI guardrails.
- **Challenges & Fixes**:
  - *Challenge 1*: `firebase use` failed with *"must be run from a Firebase project directory"*.
    - *Fix*: Added `.firebaserc` (`default: enprive-hybrid-ai`) and `firebase.json`.
  - *Challenge 2*: `firebase init ailogic` failed in non-interactive mode because `firebase-tools` detects `ANTIGRAVITY_AGENT=1` and disables prompts without defaults.
    - *Fix*: Executed `npx -y firebase-tools@latest init ailogic --project enprive-hybrid-ai -i` inside a Python `pty` harness to complete interactive app binding cleanly.
  - *Challenge 3*: `com.google.firebase:firebase-ai` had no version inside `firebase-bom:33.7.0`, and `Properties` was unresolved in `build.gradle.kts`.
    - *Fix*: Added `import java.util.Properties` and pinned explicit Maven artifacts `com.google.firebase:firebase-ai:18.2.0` and `com.google.firebase:firebase-ai-ondevice:16.0.0-beta08`.
- **Verification**:
  - `flutter analyze`: 0 issues.
  - `flutter test`: 6/6 passing.

---

### Iteration 3 — Core Code Audit, Real `OnDeviceConfig(ONLY_ON_DEVICE)` & Mobile UI Hierarchy
- **Date**: 2026-11-12
- **Branch / Commits**: `feature/mascot-ui-and-core-hardening` (`2774863`)
- **Models Used**: Gemini 4 Argon
- **What Was Built**:
  - Conducted deep inspection of `com.google.firebase.ai.*` bytecode in Gradle cache via `javap` to verify exact public preview signatures in `firebase-ai:18.2.0`.
  - Upgraded `MainActivity.kt` with `@OptIn(PublicPreviewAPI::class)`, migrated from deprecated `FirebaseAIOnDevice` static calls to `createOnDeviceModel().onDeviceExtension` (`checkStatus()`, `download()`), and enforced `OnDeviceConfig(mode = InferenceMode.ONLY_ON_DEVICE)` when `cloudConsent == false` and `PREFER_ON_DEVICE` when `cloudConsent == true`, returning `response.inferenceSource.name`.
  - Added `ACTION_SEND` (`text/plain`) Share Sheet intent filter and `<queries>` `MAIN/LAUNCHER` visibility for Android 11+ local app inspection in `AndroidManifest.xml`.
  - Applied `.agents/skills/mobile-app-ui-design/SKILL.md` to `lib/main.dart` (`HomeScreen`) and upgraded `DeniAnimatedMascot` to a 3D-shaded sculpted pebble with interactive pose switcher pills.
- **Challenges & Fixes**:
  - *Challenge*: Initial `MainActivity.kt` had a comment placeholder instead of passing `OnDeviceConfig` to `Firebase.ai.generativeModel(...)`, and used deprecated `FirebaseAIOnDevice.checkStatus()`.
  - *Fix*: Verified exact Kotlin constructors via `javap` on `firebase-ai-18.2.0-api.jar`, applied `@OptIn(PublicPreviewAPI::class)`, wired `OnDeviceConfig(mode = InferenceMode.ONLY_ON_DEVICE)`, and switched to `generativeModel.onDeviceExtension`.
- **Verification**:
  - `./gradlew compileDebugKotlin --no-daemon`: `BUILD SUCCESSFUL` with 0 warnings/errors.

---

### Iteration 4 — Rig-Aware 6-State Mascot Choreography (`svg-mascot-animator`)
- **Date**: 2026-11-12
- **Branch / Commits**: `feature/mascot-ui-and-core-hardening` (`b6b38bc`)
- **Models Used**: Gemini 4 Argon
- **What Was Built**:
  - Installed `.agents/skills/svg-mascot-animator` (`imMamdouhaboammar/linkedin-animated-infographics`) and codified mandatory reference to `svg-mascot-animator` + `mobile-app-ui-design` in `AGENTS.md`.
  - Re-architected `lib/widgets/deni_animated_mascot.dart` and `deni_pebble_animated.html` using `svg-mascot-animator` rigging & physics:
    - Grounded bottom-centre pivot (`rootPivot`) with height-coupled ground shadow.
    - Area-preserving squash/stretch (`squash(sy, 0.55)` where $s_x = 1 + (1 - s_y) \times 0.55$).
    - Analytical damped spring step response ($\zeta = 0.32, f_n = 5.5\text{ Hz}$) on pose transitions and tap squish.
    - 8% phase-lagged secondary motion (`phase(t, 0.08)`) on the top-right folded cream paper tab.
    - Distinct story-driven actions for all 6 states: `idle` (friendly wave), `thinking` (sweeping magnifying glass + emerald scan line + reading saccades), `explaining` (pointing at floating evidence quote card + multi-syllable mouth cadence), `listening` (rhythmic nod + 3-bar equalizer + sound waves), `support` (clasped hands + floating `?` badge), and `celebrating` (ballistic hop + landing ripple + emerald check badge).
- **Challenges & Fixes**:
  - *Challenge*: Previous mascot states only changed static eyebrows/mouth and bounced uniformly from the centre, making the pebble feel weightless.
  - *Fix*: Anchored all scale/skew transforms to `rootPivot` at the base of the pebble body and decoupled ground shadow scale from body scale so jumping shrinks/softens the shadow while squishing widens it.
- **Verification**:
  - `flutter analyze`: 0 issues; `flutter test`: 6/6 passing.

---

### Iteration 5 — FontBase Secondary Font (`Inter`) & Offline TTF Bundling
- **Date**: 2026-11-12
- **Branch / Commits**: `feature/mascot-ui-and-core-hardening` (`9f27ece`) → Merged via **PR #2** (`a5c69d1`)
- **Models Used**: Gemini 4 Argon
- **What Was Built**:
  - Configured **FontBase `Inter`** (`https://fontba.se/?ref=panda`) as the secondary UI/body font (`EnpriveTheme.secondaryFontFamily = 'Inter'`) paired with **`Source Serif 4`** (`EnpriveTheme.primaryFontFamily = 'Source Serif 4'`) for editorial headings and verbatim policy blockquotes in `lib/core/theme/enprive_theme.dart`.
  - Bundled offline `.ttf` font files in `assets/fonts/` (`Inter-400..800.ttf`, `SourceSerif4-600..700.ttf`) and registered both families in `pubspec.yaml` so Airplane Mode demos never fail on runtime font fetching.
- **Challenges & Fixes**:
  - *Challenge*: `google_fonts` by default attempts runtime HTTP fetches unless matching font family names and weights are registered in `pubspec.yaml` `fonts:`.
  - *Fix*: Bundled exact weight TTFs (`400, 500, 600, 700, 800`) under `assets/fonts/` and declared `Source Serif 4` and `Inter` in `pubspec.yaml`. (Note for Iteration 6: also set `GoogleFonts.config.allowRuntimeFetching = false` in `main()` for hard offline guarantee.)
- **Verification**:
  - `flutter analyze`: 0 issues; `flutter test`: 6/6 passing; merged cleanly to `main` at `a5c69d1`.

---

### Iteration 6 — P0 Core Review Flow, Evidence Result Screen, "Why This Finding?" & Cloud Consent
- **Date**: 2026-11-12
- **Branch / Commits**: `feature/review-flow-and-evidence-results` (`f91be48`)
- **Models Used**: Gemini 4 Argon
- **What Was Built**:
  - **Journal Governance (`journal.md` & `AGENTS.md`)**: Established `journal.md` as Section 0 Primary Protocol in `AGENTS.md` and `.agents/AGENTS.md`.
  - **Native Kotlin Gemini Nano 4 & Gemini 3.8 Flash Upgrade (`MainActivity.kt`)**:
    - Referenced `.agents/skills/firebase-ai-logic-basics/SKILL.md` and live `https://firebase.google.com/docs/ai-logic/models.md.txt`: upgraded model identifier from deprecated `gemini-2.5-flash` to `gemini-3.8-flash` (billing not required, Gemini 3+ series).
    - Bound `OnDeviceModelOption.PREVIEW` inside `OnDeviceConfig(...)` so AICore explicitly targets **Gemini Nano 4**.
    - Added `"warmUpModel"` MethodChannel handler calling `createOnDeviceModel().onDeviceExtension?.warmUp()`.
    - Added task-aware structured JSON prompting for `"summarise_concerns"` and `"explain_finding"` (1-turn Deni Q&A).
  - **Deterministic Evidence Context & Hashing (`lib/domain/evidence/evidence_validator.dart`)**:
    - Added `extractContextWindow` (`before`, `matched`, `after`) to highlight verbatim quotes inside their surrounding policy paragraph.
    - Added `computeSnapshotDigest` (64-bit FNV-1a hex fingerprint) for deterministic policy snapshot traceability.
  - **Domain Models & `ReviewCoordinator` (`lib/domain/review/review_models.dart`, `lib/domain/review/review_coordinator.dart`)**:
    - Coordinates `runPolicyReview` across `HybridAiBridge` and `EvidenceValidator`, stripping/downgrading unverified quotes (`UNVERIFIED`) and enforcing calibrated non-certifying disclaimers.
    - Includes a deterministic on-device clause scanner (`buildDeterministicLocalReceipt`) so offline/emulator sessions without AICore can still perform 100% local verbatim clause reviews when the user selects *"Review manually (On-Device Clause Scan)"*.
    - Added offline synthetic fixtures `assets/fixtures/synthetic_policy_edutrack.txt` (*Review Recommended*) and `assets/fixtures/synthetic_policy_calmmath.txt` (*No Concern Identified*).
  - **Inspiration-Driven Mobile UI (`mobile-app-ui-design` + Brilliant `B19`, `B30` & `Learning App`)**:
    - `lib/widgets/cloud_consent_sheet.dart` (*B19 Permission Priming*): Deni in `DeniPose.support`, exact excerpt preview box, explicit guarantee that installed apps/permissions never leave the phone, and per-check *Use cloud for this check* vs *Review manually* actions.
    - `lib/screens/review_result_screen.dart` (*Learning App + B30*): `×` close + 4-segment verification progress bar + provenance chip, calibrated state header card, 3 pastel metric tiles (*Findings · Source Matched · Unverified*), Deni reactive companion banner, `Source Serif 4` quote cards on `quoteSurface`, and sticky bottom bar (`[Ask Deni] + [Save to Receipts]`).
    - `lib/widgets/why_this_finding_sheet.dart` (*B30 + 4-Part Evidence Card*): Displays `01 What the policy says` (with highlighted context span), `02 Plain-language interpretation`, `03 What Android reports`, `04 What remains unknown`, and an interactive 1-turn **Ask Deni** stage.
    - Enforced `GoogleFonts.config.allowRuntimeFetching = false` in `lib/main.dart`.
- **Challenges & Fixes**:
  - *Challenge*: `firebase-ai-logic-basics/SKILL.md` prohibits Gemini 1.x/2.x model names (`gemini-2.5-flash`), and `OnDeviceConfig` in `firebase-ai:18.2.0` defaults to `OnDeviceModelOption.STABLE` (Nano 3) unless `OnDeviceModelOption.PREVIEW` (Nano 4) is explicitly passed.
  - *Fix*: Inspected `OnDeviceConfig` and `OnDeviceModelOption` constructors via `javap`, fetched `https://firebase.google.com/docs/ai-logic/models.md.txt` to verify `gemini-3.8-flash`, and passed `modelOption = OnDeviceModelOption.PREVIEW`.
- **Verification**:
  - `flutter analyze`: **0 issues found**.
  - `flutter test`: **9/9 tests passing** (`test/evidence_validator_test.dart`, `test/review_coordinator_test.dart`, `test/widget_test.dart`).
  - `cd android && ./gradlew compileDebugKotlin --no-daemon`: **BUILD SUCCESSFUL (0 warnings, 0 errors)**.

---

### Iteration 6.1 — Physically Articulated Mascot Hand-to-Prop Choreography (`thinking`, `explaining`, `listening`)
- **Date**: 2026-11-12
- **Branch / Commits**: `feature/review-flow-and-evidence-results`
- **Models Used**: Gemini 4 Argon
- **What Was Built**:
  - Referenced `.agents/skills/svg-mascot-animator/references/creative-directions.md` and `references/rigging.md` to upgrade Deni's foreground hand-to-prop articulation in `lib/widgets/deni_animated_mascot.dart`:
    - **`thinking` (`_drawThinkingScene`)**: Deni's foreground right arm and sculpted paw physically wrap around and grip the magnifying glass handle (`gripPoint` with overlapping thumb pad and brass ferrule collar), sweeping the lens across a 4-line policy document while magnifying the zoomed clauses inside the lens clip; Deni's left hand taps the chin thoughtfully.
    - **`explaining` (`_drawExplainingScene`)**: Deni's foreground right arm grips a tactile Presentation Pointer Baton whose warm-apricot tip tracks across a larger Floating Evidence Board (`QUOTE VERIFIED` header + pulsing highlight box + target ring), while Deni's left hand gestures palm-up and a floating speech callout bubble bobs above the left shoulder.
    - **`listening` (`_drawListeningScene`)**: Added a sculpted over-the-crown Acoustic Headset Arc with cushioned left/right studio earcups; Deni's right hand reaches up to physically hold/cup the right earcup while Deni's left hand presents a Floating 5-Bar Live Voice Equalizer Card alongside 3 concentric acoustic wave arcs.
  - Fixed `lib/core/theme/enprive_theme.dart` to bind directly to the `pubspec.yaml` bundled font families (`SourceSerif4` and `Inter`) instead of `GoogleFonts.inter()` asset lookups, eliminating runtime `google_fonts` console exceptions on the Android 16 emulator when `allowRuntimeFetching = false`.
- **Challenges & Fixes**:
  - *Challenge 1*: In the initial `thinking` pose, the magnifying glass floated without Deni's hand gripping the handle, and `explaining` / `listening` lacked foreground limb connection to their visual props.
    - *Fix*: Built `_drawArticulatedArm` with shared kinematic anchor points (`gripPoint`, `batonGrip`, `cupGrip`) and layered an overlapping thumb/paw pad over the tool shaft so arm, hand, and prop move as a single connected rig.
  - *Challenge 2*: `GoogleFonts.config.allowRuntimeFetching = false` logged exceptions looking for `Inter-Regular.ttf` / `Inter-SemiBold.ttf` because our bundled files are named `Inter-400.ttf`..`Inter-800.ttf` and registered under `pubspec.yaml` `fonts:`.
    - *Fix*: Bound `TextTheme` styles directly to `fontFamily: primaryDisplayFontFamily` (`SourceSerif4`) and `fontFamily: secondaryFontBaseFamily` (`Inter`).
- **Verification**:
  - Hot-reloaded live onto `emulator-5554` (Pixel 9, Android 16 API 36) in `1,431ms` with 0 runtime font warnings.
  - `flutter analyze`: **0 issues found**.
  - `flutter test`: **9/9 tests passing**.

---

### Iteration 7 — Local Installed App Inspector & Deterministic `PermissionComparator`
- **Date**: 2026-11-12
- **Branch / Commits**: `feature/app-permission-inspector` (`468d99b`)
- **Models Used**: Gemini 4 Argon
- **What Was Built**:
  - **Native Android `listLaunchableApps` (`MainActivity.kt` & `hybrid_ai_bridge.dart`)**:
    - Added `"listLaunchableApps"` MethodChannel handler querying `PackageManager.queryIntentActivities` for `ACTION_MAIN` + `CATEGORY_LAUNCHER` (matching `<queries>` in `AndroidManifest.xml`, no `QUERY_ALL_PACKAGES`), sorting non-system apps first and returning `InstalledAppEntry` records strictly on-device.
    - Added `AppPermissionSnapshot` and `inspectAppSnapshot(packageName)` wrapper on `HybridAiBridge`.
  - **Deterministic `PermissionComparator` (`lib/domain/permissions/permission_comparator.dart`)**:
    - Matches Android OS requested/granted permissions (`ACCESS_FINE_LOCATION`, `ACCESS_BACKGROUND_LOCATION`, `RECORD_AUDIO`, `CAMERA`, `READ_CONTACTS`, `com.google.android.gms.permission.AD_ID`, `READ_MEDIA_IMAGES`) against policy claims and disclaimers without calling any cloud or LLM endpoint.
    - Classifies each capability into `undisclosedInPolicy`, `grantedAndDisclosed`, `disclosedNotGranted`, or `notRequested`.
    - Enriches policy findings with live Android OS observations (`whatAndroidReports`) and emits `EvidenceStatus.deviceObserved` findings for undisclosed OS permissions, always attaching the calibrated limitation notice.
  - **Installed App Picker Sheet & Result Screen Permission Cards (`lib/widgets/installed_app_picker_sheet.dart`, `lib/screens/review_result_screen.dart`)**:
    - Built `InstalledAppPickerSheet` featuring Classroom Benchmark Profiles (*EduTrack* with 4 granted permissions + 1 undisclosed `CAMERA` mismatch; *CalmMath* with 0 sensitive permissions) plus live search/inspection of apps installed on the phone.
    - Added `_PermissionComparisonSection` and `Device observed` status badges to `ReviewResultScreen`.
  - **Unit Tests (`test/permission_comparator_test.dart`)**:
    - Added deterministic test coverage verifying undisclosed `CAMERA` mismatch detection on EduTrack and zero-mismatch alignment on CalmMath.
- **Challenges & Fixes**:
  - *Challenge*: Kotlin compiler emitted `Unnecessary safe call on a non-null receiver of type 'CharSequence'` on `info.loadLabel(pm)?.toString()` in `MainActivity.kt`.
  - *Fix*: Changed to `info.loadLabel(pm).toString().takeIf { it.isNotBlank() }` for 0 warnings.
- **Verification**:
  - `flutter analyze`: **0 issues found**.
  - `flutter test`: **11/11 tests passing** (`test/evidence_validator_test.dart`, `test/permission_comparator_test.dart`, `test/review_coordinator_test.dart`, `test/widget_test.dart`).
  - `cd android && ./gradlew compileDebugKotlin --no-daemon`: **BUILD SUCCESSFUL (0 warnings, 0 errors)**.

---

### Iteration 8 — Local SQLite Receipts Storage, Preferences & 3-Tab Shell
- **Date**: 2026-11-12
- **Branch / Commits**: `feature/local-receipts-storage`
- **Models Used**: Gemini 4 Hydrogen
- **What Was Built**:
  - **JSON Serialization (`lib/domain/review/review_models.dart`, `lib/domain/permissions/permission_comparator.dart`, `lib/services/platform/hybrid_ai_bridge.dart`)**:
    - Added deterministic `toJson()` / `fromJson()` serialization on `PolicyReviewReceipt`, `VerifiedFinding`, `AppPermissionComparisonReport`, `ComparedPermissionItem`, and `AppPermissionSnapshot` (preserving full policy quotes, context windows, and Android OS permission comparison states).
  - **Local Persistence (`lib/services/storage/receipt_repository.dart`)**:
    - Implemented `ReceiptRepository` backed by local `sqflite` (`enprive_receipts.db`, `policy_receipts` table) with newest-first queries, single delete, and clear-all, plus an automatic in-memory fallback for headless unit/widget tests.
    - Implemented `UserPreferencesRepository` using `SharedPreferences` for Deni companion visibility (`showDeni`), explanation depth (`simple`, `balanced`, `detailed`), and locale (`en`/`ko`).
  - **Receipts Archive & Settings Screens (`lib/screens/receipts_screen.dart`, `lib/screens/settings_screen.dart`)**:
    - Built `ReceiptsScreen` (*MyNote inspiration pattern*) with live search, filter chips (`All · Review recommended · No concern · Insufficient`), snapshot digest badges, OS mismatch indicators, and Open/Delete actions.
    - Built `SettingsScreen` (*B19 + B3 choice cards*) featuring a *Private Analysis on This Phone* AICore readiness & warm-up card, 3-tier explanation depth selector, Deni companion toggle, EN/KO switcher, and local storage reset with confirmation dialog.
  - **3-Tab Bottom Navigation Shell (`lib/main.dart`)**:
    - Upgraded `HomeScreen` to an `IndexedStack` + `NavigationBar` (`Home · Receipts · Settings`, *Monday Home inspiration pattern*) with a live receipt count badge and `"See all →"` shortcut.
  - **Unit Tests (`test/receipt_repository_test.dart`)**:
    - Added JSON round-trip and repository CRUD/sorting tests covering `PolicyReviewReceipt` with nested `AppPermissionComparisonReport`.
- **Challenges & Fixes**:
  - *Challenge 1*: Missing color getter names (`stateInsufficientBg` / `stateInsufficientFg`) in initial screen drafts.
    - *Fix*: Updated to the exact WCAG tokens `EnpriveColors.stateInsufficientEvidenceBg` and `EnpriveColors.stateInsufficientEvidenceFg` in `enprive_colors.dart`.
  - *Challenge 2*: Widget tests flagged `ListTile background color or ink splashes may be invisible` when `SettingsScreen` placed `ListTile` / `SwitchListTile.adaptive` inside a colored `Container` under `IndexedStack`.
    - *Fix*: Replaced the outer `Container` in `SettingsScreen` with a `Material` surface wrapper (`RoundedRectangleBorder` + `Clip.antiAlias`) so ripple ink and accessibility checks pass cleanly.
- **Verification**:
  - `flutter analyze`: **0 issues found**.
  - `flutter test`: **13/13 tests passing** (`evidence_validator_test.dart`, `permission_comparator_test.dart`, `receipt_repository_test.dart`, `widget_test.dart`).
  - Restarted fresh native Android + Flutter build on `emulator-5554` (`flutter run -d emulator-5554`).

---

### Iteration 8.1 — Primary `Nunito` Typography & Inspiration-Driven UI/UX De-Noising (`feature/ui-ux-inspiration-polish`)
- **Date**: 2026-11-12
- **Branch / Commits**: `feature/ui-ux-inspiration-polish` (`f912264`)
- **Models Used**: Gemini 4 Argon
- **What Was Built**:
  - **Bundled Primary `Nunito` Font (`assets/fonts/Nunito-400.ttf`..`800.ttf`, `pubspec.yaml`, `lib/core/theme/enprive_theme.dart`)**:
    - Downloaded and bundled Google Fonts `Nunito` (`400`, `600`, `700`, `800`) as the primary font (`EnpriveTheme.primaryDisplayFontFamily = 'Nunito'`), paired with FontBase `Inter` (`secondaryFontBaseFamily`) for secondary body copy and `SourceSerif4` (`quoteFontFamily`) exclusively for verbatim policy quotes.
  - **Visual Audit & De-Noising Across All 6 Screens (referencing `.agents/skills/mobile-app-ui-design/SKILL.md` and `inspo-v2/`)**:
    - **Home & Navigation (`lib/main.dart`)**: Matched Brilliant `b01-welcome.png` + `x-family-splash.jpeg` + Monday `x-monday-home.jpeg`. Removed developer badge clutter (`NANO 4`, status chip rows, raw hash strings); introduced a spacious rounded-3xl hero stage with floating privacy icons, centered `Nunito` display headline, two tactile thumb-zone CTAs, a clean *Recently reviewed* card group, and a floating rounded pill bottom navigation dock (`_FloatingBottomNavDock`).
    - **Evidence Result Screen (`lib/screens/review_result_screen.dart`)**: Matched `x-learning-app.jpeg` (*Lesson Details*) + `b30-lesson-check.png`. Full-bleed state-tinted hero canvas with centered Deni in a soft translucent halo, curved white bottom sheet (`borderRadius: 32`), 3 pastel stat tiles (*Findings · Verified · OS Granted/Unverified*), clean finding cards, and a square bookmark button docked beside the primary CTA.
    - **Why This Finding Sheet (`lib/widgets/why_this_finding_sheet.dart`)**: Matched `b30-lesson-check.png`. Replaced 4 stacked numbered boxes with a single unified Evidence Work Card (status dot header, apricot-highlighted quote canvas, and 3 compact icon rows) plus a docked Deni + primary pill bottom bar.
    - **Receipts Screen (`lib/screens/receipts_screen.dart`)**: Matched `x-mynote.jpeg`. Toggleable search icon, soft flat filter pills (`All · Review · No concern`), and clean paper-note cards with pastel `Open receipt` / `Delete` action strips below each card.
    - **Settings Screen (`lib/screens/settings_screen.dart`)**: Matched `b19-permission-prime.png` + `b03-question-cards.png`. Deni peeks over the *Private analysis on this phone* card, followed by 3 soft B3 choice cards (`Simple · Balanced · Detailed`) and a minimal preferences group without raw API/DB filenames.
    - **Cloud Consent & Installed App Picker Sheets (`lib/widgets/cloud_consent_sheet.dart`, `lib/widgets/installed_app_picker_sheet.dart`)**: Applied B19 peeking-mascot layout and B3 sample app choice cards, removing developer benchmark/package-name clutter.
- **Verification**:
  - `flutter analyze`: **0 issues found**.
  - `flutter test`: **13/13 tests passing**.
  - Hot-restarted live onto `emulator-5554`.

---

### Iteration 9 — Native Android `TextToSpeech` Voice Playback, Private Readiness Sheet & Accessibility (`feature/tts-and-readiness-flow`)
- **Date**: 2026-11-12
- **Branch / Commits**: `feature/tts-and-readiness-flow` (`0c97c04`)
- **Models Used**: Gemini 4 Argon
- **What Was Built**:
  - **Native Android `TextToSpeech` (`MainActivity.kt`, `AndroidManifest.xml`, `hybrid_ai_bridge.dart`)**:
    - Added `android.intent.action.TTS_SERVICE` query intent to `AndroidManifest.xml` for Android 11+ TTS service discovery.
    - Initialized local `TextToSpeech` in `MainActivity.kt` with automatic `Locale.US` / `Locale.KOREAN` switching and cleanup in `onDestroy()`.
    - Added `"speakText"` and `"stopSpeaking"` MethodChannel handlers and exposed `speakText()` / `stopSpeaking()` on `HybridAiBridge`.
    - Refined `"analyseText"` exception handling so `FirebaseAIOnDeviceNotAvailableException` maps cleanly to `status = "unavailable"` without noisy stack traces.
  - **Synced Voice Playback on `ReviewResultScreen` (`lib/screens/review_result_screen.dart`)**:
    - Added a top-bar circular speaker toggle button (*Brilliant B19 top sound icon pattern*) and tap-on-Deni voice trigger.
    - Synced playback with `DeniPose.listening` so Deni puts on the studio headset and animates the 5-bar live voice equalizer while reading the calibrated review summary aloud, stopping automatically on toggle or screen exit.
  - **Private Analysis Readiness Sheet (`lib/widgets/private_readiness_sheet.dart`, `lib/screens/settings_screen.dart`)**:
    - Built `PrivateReadinessSheet` (*Brilliant B19 + `x-welcome-gradient.jpeg` paper→teal bottom wash*) with peeking Deni, live `downloadOrCheckModel()` + `warmUpModel()` check, and honest local scanner fallback status.
  - **Accessibility & Open-Source Attribution (`THIRD_PARTY_NOTICES.md`, `test/widget_test.dart`)**:
    - Added `THIRD_PARTY_NOTICES.md` documenting `Nunito` (OFL-1.1), `Inter` (OFL-1.1 via FontBase), `Source Serif 4` (OFL-1.1), and Flutter/Firebase licenses.
    - Added a 200% text-scale (`TextScaler.linear(2.0)`) + reduced-motion (`disableAnimations: true`) widget test across tabs plus native TTS channel unit tests.
- **Verification**:
  - `flutter analyze`: **0 issues found**.
  - `flutter test`: **15/15 tests passing**.
  - `cd android && ./gradlew compileDebugKotlin --no-daemon`: **BUILD SUCCESSFUL**.

---

### Iteration 10 — Guided 3-Step Onboarding (`B2` → `B3` → `B19`), 4-Segment Progress Card, Policy Link Input & Snapshot Provenance Sheet (`feature/onboarding-and-process-text-flow`)
- **Date**: 2026-11-13
- **Branch / Commits**: `feature/onboarding-and-process-text-flow`
- **Models Used**: Gemini 4 Argon
- **What Was Built**:
  - **3-Step Guided Onboarding Flow (`lib/screens/onboarding_flow_screen.dart`, `lib/services/storage/receipt_repository.dart`)**:
    - **Step 1 (`b02-koji-intro.png`)**: Minimalist centered `DeniAnimatedMascot(size: 132, pose: DeniPose.idle)` on warm paper canvas with subtle bottom gradient, bold `Nunito` headline (*"Hi, I'm Deni! I'll help you read privacy terms."*), non-certifying pledge subtitle, and full-width `Continue` CTA.
    - **Step 2 (`b03-question-cards.png`)**: 3-segment progress bar, Deni (`DeniPose.explaining`) beside *"How should I explain privacy terms?"*, and a 2×2 grid of soft `#F3F1EC` rounded-3xl choice cards (`Simple summary`, `Balanced explanation`, `Detailed clauses`, and `Show Deni / Text-only quiet mode`).
    - **Step 3 (`b19-permission-prime.png`)**: Deni (`DeniPose.celebrating`) peeking over the *Private by default on this phone* guarantee card with 3 icon rows (*On-device analysis first*, *App lists stay on phone*, *No silent cloud calls*) and `Get started` CTA.
    - Persisted `hasCompletedOnboarding` in `UserPreferencesRepository` and added a *"Meet Deni & setup guide"* row in `SettingsScreen` so users and judges can replay the flow anytime.
  - **4-Segment On-Device Analysis Progress Card (`lib/widgets/review_progress_sheet.dart`, `lib/main.dart`)**:
    - Built `ReviewProgressCard` (*Brilliant `b30-lesson-check.png` pattern*) displaying a 4-segment progress bar paired with plain-language step status (*Step 1–4: Fingerprinting snapshot → Reading clauses on-device → Verifying verbatim quotes → Comparing local Android permissions*) whenever a review is in flight.
  - **Policy Link / URL Input Mode (`lib/main.dart`)**:
    - Added a segmented **`Paste text` / `Policy link`** switcher inside the review modal (`_showPasteModal`) with one-tap classroom policy URL chips (`edutrack.example.edu/privacy` and `calmmath.example.org/privacy`) that tag the resulting receipt's `sourceLabel` with the URL.
  - **Reviewed Policy Snapshot & Provenance Sheet (`lib/screens/review_result_screen.dart`)**:
    - Tapping the top `EnpriveProvenanceChip` or *"View reviewed policy snapshot"* at the bottom of `ReviewResultScreen` opens a draggable sheet displaying the source label, timestamp, deterministic FNV-1a snapshot digest, and the full verbatim policy snapshot in `SourceSerif4` on `quoteSurface`.
- **Challenges & Fixes**:
  - *Challenge*: `EnpriveColors.tealSoft` was referenced in `onboarding_flow_screen.dart` and `review_progress_sheet.dart`, whereas the WCAG token in `enprive_colors.dart` is `EnpriveColors.chipOnDeviceBg`.
  - *Fix*: Updated both files to use `EnpriveColors.chipOnDeviceBg`.
- **Verification**:
  - `flutter analyze`: **0 issues found**.
  - `flutter test`: **17/17 tests passing** (including new widget tests for `OnboardingFlowScreen` 3-step navigation and `ReviewProgressCard`).

---

### Iteration 10.1 — Plain-Language Explanation Copy Polish & App Picker `Material` Fix (`feature/onboarding-and-process-text-flow`)
- **Date**: 2026-11-13
- **Branch / Commits**: `feature/onboarding-and-process-text-flow`
- **Models Used**: Gemini 4 Argon + Gemini 4 Hydrogen
- **What Was Built**:
  - **Question-Aware & Human-Centered Explanation Copy (`review_coordinator.dart`, `onboarding_flow_screen.dart`, `settings_screen.dart`, `main.dart`)**:
    - Replaced generic AI-sounding fallback copy in `askDeniAboutFinding` with question-aware answers that directly respond to *"Can we turn this off or opt out?"*, *"What is still unknown here?"*, and *"What does this mean for my child?"*.
    - Rewrote deterministic finding titles, plain-language explanations, unknowns, onboarding steps (`Quick & plain`, `Balanced view`, `Full detail`, *Checked here first*, *Your apps stay yours*, *Never uploaded without asking*), Settings depth cards, and Deni pose dialogues into concise, direct parent/teacher language.
  - **Installed App Picker Surface Fix (`lib/widgets/installed_app_picker_sheet.dart`)**:
    - Wrapped the launchable app `ListTile` list in `Material(color: EnpriveColors.surface, borderRadius: BorderRadius.circular(24), clipBehavior: Clip.antiAlias)` to eliminate the Flutter `ListTile background color or ink splashes may be invisible` framework assertion during emulator testing.
  - **Responsive Top-Right Progress Bar Alignment (`lib/screens/onboarding_flow_screen.dart`, `lib/widgets/why_this_finding_sheet.dart`)**:
    - Moved the segmented onboarding progress bar to the top-right (`Alignment.centerRight`, capped at `maxWidth: 156` inside `Expanded`) with the `<` back button and `EN / 한국어` pill cleanly anchored on the left; aligned the `WhyThisFindingSheet` top bar `LinearProgressIndicator` (`maxWidth: 168`) to `Alignment.centerRight` as well.
- **Verification**:
  - `flutter analyze`: **0 issues found**.
  - `flutter test`: **17/17 tests passing**.

---

### Iteration 10.2 — Single-Button `"Review on this phone"` Abstraction, On-Device `PiiRedactor` & App Check Hybrid Routing (`feature/onboarding-and-process-text-flow`)
- **Date**: 2026-11-13
- **Branch / Commits**: `feature/onboarding-and-process-text-flow`
- **Models Used**: Orchestrator (Argon)
- **What Was Built**:
  - **On-Device PII Placeholder Redactor (`lib/domain/privacy/pii_redactor.dart`, `test/pii_redactor_test.dart`)**:
    - Implemented deterministic `PiiRedactor.redact(...)` scrubbing emails (`[EMAIL]`), phone numbers (`[PHONE]`), IPv4 addresses (`[IP_ADDRESS]`), street addresses (`[ADDRESS]`), student/account IDs (`[ID]`), and labeled child/parent names (`[PERSON]`) strictly on-device before any cloud fallback, plus `isComprehensivePolicy(...)` detection (`> 1400` chars or `> 220` words).
  - **Seamless Hybrid Routing Behind Single `"Review on this phone"` Button (`lib/domain/review/review_coordinator.dart`, `lib/services/platform/hybrid_ai_bridge.dart`)**:
    - Simplified `_executePolicyReview` and `_showPasteModal` in `lib/main.dart` to a single **`Review on this phone`** action and removed step-by-step pipeline narration from `ReviewProgressCard` (`lib/widgets/review_progress_sheet.dart`).
    - Behind the scenes, `runPolicyReview` and `askDeniAboutFinding` try local `ONLY_ON_DEVICE` inference first; when on-device inference is unavailable or the policy contains comprehensive details, they replace personal details with placeholders on-device and send the scrubbed text via Firebase AI Logic `PREFER_ON_DEVICE` protected by App Check (`useLimitedUseAppCheckTokens = true`), with an automatic deterministic local clause-scan offline net and redacted-snapshot fallback citation matching.
  - **Debug + Play Integrity App Check Initialization (`android/app/src/main/kotlin/com/example/enprive/MainActivity.kt`)**:
    - Wired `DebugAppCheckProviderFactory` for debuggable builds and `PlayIntegrityAppCheckProviderFactory` for release builds alongside updated onboarding copy (`lib/screens/onboarding_flow_screen.dart`).
- **Verification**:
  - `flutter analyze`: **0 issues found**.
  - `flutter test`: **21/21 tests passing**.
  - `cd android && ./gradlew compileDebugKotlin --no-daemon`: **BUILD SUCCESSFUL**.

---

### Iteration 10.3 — Live Streaming Thoughts, Thought Signatures & Full Process-Step State (`feature/onboarding-and-process-text-flow`)
- **Date**: 2026-11-13
- **Branch / Commits**: `feature/onboarding-and-process-text-flow`
- **Models Used**: Orchestrator (Argon) + Execution model
- **What Was Built**:
  - **Verified Firebase AI Logic `18.2.0` Thinking & Streaming APIs (`android/app/src/main/kotlin/com/example/enprive/MainActivity.kt`)**:
    - Confirmed via `javap` on `firebase-ai-18.2.0-api.jar` that `GenerativeModel.generateContentStream(String)`, `GenerationConfig.Builder.thinkingConfig`, `ThinkingConfig.Builder` (`includeThoughts = true`, `thinkingLevel = ThinkingLevel.LOW`), `GenerateContentResponse.thoughtSummary`, and `TextPart` (`isThought`, `thoughtSignature`) are supported directly by the SDK.
    - Updated `MainActivity.kt` `"analyseText"` to stream via `model.generateContentStream(prompt)`, configure `thinkingConfig` (with clean fallback if `ONLY_ON_DEVICE` rejects thinking options), forward live `"onAnalysisStreamEvent"` updates to Dart, and return `thoughtSummary`, `thoughtSignature`, and `thoughtSignatures`.
  - **Hybrid Stream & Coordinator Process Trace (`lib/services/platform/hybrid_ai_bridge.dart`, `lib/domain/review/review_models.dart`, `lib/domain/review/review_coordinator.dart`)**:
    - Added `AnalysisStreamEvent` broadcast stream on `HybridAiBridge`, plus `processSteps`, `thoughtSummary`, and `thoughtSignature` persistence on `PolicyReviewReceipt` and `DeniExplanation`.
    - Updated `runPolicyReview` and `askDeniAboutFinding` to emit step-by-step live events covering local Nano checks, on-device PII redaction counts, Firebase App Check `PREFER_ON_DEVICE` streaming thoughts + thought signatures, offline deterministic fallback, and verbatim quote/permission matching.
  - **Shared Process & Thought UI (`lib/widgets/analysis_process_trace.dart`, `lib/widgets/review_progress_sheet.dart`, `lib/screens/review_result_screen.dart`, `lib/widgets/why_this_finding_sheet.dart`, `lib/main.dart`)**:
    - Built `AnalysisLiveProcessView` and `AnalysisSavedTraceCard` so parents/teachers see every live step, streaming `thoughtSummary`, and `thoughtSignature` token while reviewing, asking Deni, and inspecting saved review results.
- **Verification**:
  - `flutter analyze`: **0 issues found**.
  - `flutter test`: **24/24 tests passing** (including new coordinator trace/thought propagation and `ReviewProgressCard` / `AnalysisSavedTraceCard` widget tests).
  - `cd android && ./gradlew compileDebugKotlin --no-daemon`: **BUILD SUCCESSFUL**.

---

### Iteration 10.4 — Production Home Screen Polish & Model-Neutral Process Copy (`feature/onboarding-and-process-text-flow`)
- **Date**: 2026-11-13
- **Branch / Commits**: `feature/onboarding-and-process-text-flow`
- **Models Used**: Orchestrator (Argon) + Execution model
- **What Was Built**:
  - **Removed Mascot State Card & Pose Switcher Buttons (`lib/main.dart`)**:
    - Removed the Home mascot speech bubble card, floating badges, `_cyclePose`, `_poseLabel`, `_poseDialogue`, and the `Welcome / Thinking / Explaining / Listening / Support / Complete` pose buttons.
    - Kept a clean editorial hero header and filled the Home tab with actionable content: **Try a sample app check** one-tap cards (**EduTrack Classroom** and **CalmMath Kids** backed by `PermissionComparator.demoEduTrackSnapshot` / `demoCalmMathSnapshot`) and a **What we check for** 3-row highlight card (**Exact policy quotes**, **Phone permission mismatches**, **Select text anywhere**).
  - **Removed Model-Specific `"Gemini Nano"` References from Process & Thought Labels (`android/app/src/main/kotlin/com/example/enprive/MainActivity.kt`, `lib/domain/review/review_coordinator.dart`, `lib/widgets/review_progress_sheet.dart`, `lib/widgets/why_this_finding_sheet.dart`)**:
    - Replaced technical model names in live process/thought UI labels with clear human copy (`"Reading policy text on this phone"`, `"Streaming reasoning & thought signature"`, `"Preparing privacy-scrubbed check"`, etc.).
- **Verification**:
  - `flutter analyze`: **0 issues found**.
  - `flutter test`: **24/24 tests passing**.
  - `cd android && ./gradlew compileDebugKotlin --no-daemon`: **BUILD SUCCESSFUL**.

---

### Iteration 10.5 — Richer Review Progress Card & Claude-Style Single-Line Thought Ticker (`feature/onboarding-and-process-text-flow`)
- **Date**: 2026-11-13
- **Branch / Commits**: `feature/onboarding-and-process-text-flow`
- **Models Used**: Orchestrator (Argon) + Execution model
- **What Was Built**:
  - **Pub.dev Motion & Shimmer Dependencies (`pubspec.yaml`, `pubspec.lock`)**:
    - Added `loading_animation_widget` (`^1.3.0`) and `shimmer` (`^4.0.0`) after inspecting `pub.dev` and `.agents/skills/mobile-app-ui-design/SKILL.md`.
  - **Claude-Style Single-Line Thought Ticker (`lib/widgets/analysis_process_trace.dart`)**:
    - Replaced the vertical checklist in `AnalysisLiveProcessView` with a single active ticker row powered by `LoadingAnimationWidget.staggeredDotsWave`, `Shimmer.fromColors`, and a vertical slide + fade `AnimatedSwitcher` that smoothly streams thought sentences (`thoughtSummary`) one line at a time before cycling to the next line.
    - Updated `AnalysisSavedTraceCard` to summarize the completed pipeline cleanly on one row alongside the step count badge, `thoughtSignature` pill, and expandable streamed thoughts.
  - **Richer Review Progress Surface (`lib/widgets/review_progress_sheet.dart`)**:
    - Upgraded `ReviewProgressCard` with tinted soft depth shadows, subtle accent border, `LoadingAnimationWidget.threeArchedCircle` leading indicator, shimmering subtitle (`Reviewing on this phone…`), and a rounded shimmer progress bar while respecting `MediaQuery.maybeDisableAnimationsOf`.
- **Verification**:
  - `flutter analyze`: **0 issues found**.
  - `flutter test`: **24/24 tests passing**.
  - `cd android && ./gradlew compileDebugKotlin --no-daemon`: **BUILD SUCCESSFUL**.

---

### Iteration 10.6 — Official Flutter/Dart Skills & `animated_status_card` / `beautiful_timeline` UI Integration (`feature/onboarding-and-process-text-flow`)
- **Date**: 2026-11-13
- **Branch / Commits**: `feature/onboarding-and-process-text-flow`
- **Models Used**: Orchestrator (Argon) + Execution model
- **What Was Built**:
  - **Official Flutter & Dart Agent Skills (`AGENTS.md`, `.agents/AGENTS.md`, `.agents/skills/`)**:
    - Installed the official `flutter/agent-plugins` and `dart-lang/skills` bundles under `.agents/skills/` (`npx skills add flutter/agent-plugins --skill '*' --agent universal --yes` and `npx skills add dart-lang/skills --skill '*' --agent universal --yes`) and updated `AGENTS.md` + `.agents/AGENTS.md` to require inspecting them before every iteration.
  - **`pub.dev` Card & Timeline Dependencies (`pubspec.yaml`, `pubspec.lock`)**:
    - Added `animated_status_card` (`^0.0.1`) and `beautiful_timeline` (`^0.1.0`).
  - **Home Screen Upgrades (`lib/main.dart`)**:
    - Replaced `_HomeSampleCard` with responsive `AnimatedStatusCard` cards (`LayoutBuilder` + `MediaQuery.textScalerOf` / `MediaQuery.maybeDisableAnimationsOf`, stacking vertically when narrow or >1.35× text scale) for **EduTrack Classroom** and **CalmMath Kids**.
    - Replaced `_HomeHighlightRow` under **What we check for** with a themed vertical `BeautifulTimeline` (`IndicatorStyle.icon`, `LineStyle.gradient`, `NeverScrollableScrollPhysics`).
  - **Live Review & Saved Trace Upgrades (`lib/widgets/review_progress_sheet.dart`, `lib/widgets/analysis_process_trace.dart`)**:
    - Replaced the manual top header row in `ReviewProgressCard` with `AnimatedMiniStatusCard` while preserving the shimmer bar and Claude-style single-line `AnalysisLiveProcessView` ticker.
    - Added a static (`showAnimation: false`) `BeautifulTimeline` inside the expanded details view of `AnalysisSavedTraceCard` for completed review steps above saved streamed thoughts.
- **Challenges & Root-Cause Fixes**:
  - `beautiful_timeline`'s `TimelineThemeData` uses `lineGradientStart`, `lineGradientEnd`, `lineWidth`, and `spacingBetweenEvents` rather than `primaryColor`/`secondaryColor`/`connectorWidth`/`nodeSpacing`; aligned theme fields after inspecting the package source.
  - `BeautifulTimeline` schedules a staggered `80ms * index` `Future.delayed` timer when `showAnimation: true`; set `showAnimation: false` for saved historical traces in `AnalysisSavedTraceCard` and bumped the Home widget test pump to `250ms` in `test/widget_test.dart` so staggered entry timers settle cleanly before widget disposal.
- **Verification**:
  - `flutter analyze`: **0 issues found**.
  - `flutter test`: **24/24 tests passing** (including 200% text scale and reduced-motion widget tests).
  - `cd android && ./gradlew compileDebugKotlin --no-daemon`: **BUILD SUCCESSFUL**.
  - `flutter build apk --debug` + `adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-debug.apk` + cold launch: **Complete (`Status: ok`)**.

---

### Iteration 10.7 — Remove `Show Deni companion` Preference & Default Deni Always On (`feature/onboarding-and-process-text-flow`)
- **Date**: 2026-11-13
- **Branch / Commits**: `feature/onboarding-and-process-text-flow`
- **Models Used**: Orchestrator (Argon) + Execution model
- **What Was Built**:
  - **Settings Screen (`lib/screens/settings_screen.dart`)**:
    - Removed `showDeni` / `onShowDeniChanged` parameters and removed the `SwitchListTile.adaptive` preference row (`Show Deni companion` / `Deni 캐릭터 표시`) from the **Preferences** card.
    - Rendered `DeniAnimatedMascot` above the private analysis status card unconditionally by default.
  - **Home, Receipts, Onboarding & Preferences Persistence (`lib/main.dart`, `lib/screens/receipts_screen.dart`, `lib/screens/onboarding_flow_screen.dart`, `lib/services/storage/receipt_repository.dart`)**:
    - Removed `showDeni` / `initialShowDeni` / `_showDeni` / `_keyShowDeni` flags across app state, `UserPreferencesSnapshot`, `UserPreferencesRepository`, `ReceiptsScreen`, and `OnboardingFlowScreen` (including removing the 4th `"Show Deni companion"` / `"Text-only quiet mode"` toggle tile from Onboarding step 1).
    - Deni now renders by default across Home hero, Receipts empty state, and Settings.
  - **Tests (`test/widget_test.dart`)**:
    - Verified `expect(find.text('Show Deni companion'), findsNothing)` in the Settings tab test and updated `OnboardingFlowScreen` test instantiation.
- **Verification**:
  - `flutter analyze`: **0 issues found**.
  - `flutter test`: **24/24 tests passing**.
  - `cd android && ./gradlew compileDebugKotlin --no-daemon`: **BUILD SUCCESSFUL**.
  - `flutter build apk --debug` + `adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-debug.apk`: **Success**.

---

### Iteration 10.8 — Two-Tier Icon System (`lucide_icons_flutter` + Phosphor Duotone `iconify_flutter`) (`feature/onboarding-and-process-text-flow`)
- **Date**: 2026-11-13
- **Branch / Commits**: `feature/onboarding-and-process-text-flow`
- **Models Used**: Gemini 4 Hydrogen
- **What Was Built**:
  - **Pub.dev Dependencies (`pubspec.yaml`, `pubspec.lock`)**:
    - Added `lucide_icons_flutter` (`^4.0.3`) and `iconify_flutter` (`^0.0.7`) and removed `material_symbols_icons` (`4.2960.0`) after verifying zero remaining `Symbols.` references across `lib/` and `test/`.
  - **Reusable Duotone SVG Wrapper (`lib/widgets/enprive_duotone_icon.dart`)**:
    - Added `EnpriveDuotoneIcon` (`ExcludeSemantics` + `Center` + `Iconify`) so Phosphor Duotone SVGs keep exact centered sizing inside fixed-size pastel containers.
  - **Two-Tier Icon Migration Across Screens & Widgets**:
    - **Phosphor Duotone SVGs (`Ph.*_duotone`)** for focal badges, status tiles, finding categories, provenance chips, onboarding guarantees/cards, Settings depth cards, and sheet headers (`lib/main.dart`, `lib/widgets/enprive_provenance_chip.dart`, `lib/screens/review_result_screen.dart`, `lib/screens/settings_screen.dart`, `lib/screens/onboarding_flow_screen.dart`, `lib/widgets/why_this_finding_sheet.dart`, `lib/widgets/installed_app_picker_sheet.dart`, `lib/widgets/cloud_consent_sheet.dart`, `lib/widgets/private_readiness_sheet.dart`).
    - **Geometric Stroke Icons (`LucideIcons` / `LucideIcons500`)** for `IconData`-typed package widgets (`AnimatedStatusCard`, `AnimatedMiniStatusCard`, `BeautifulTimeline`), floating bottom navigation dock (`house`, `receiptText`, `slidersHorizontal`), search/close/chevron/bookmark/trash actions, and process/permission rows (`lib/main.dart`, `lib/screens/receipts_screen.dart`, `lib/screens/review_result_screen.dart`, `lib/widgets/review_progress_sheet.dart`, `lib/widgets/analysis_process_trace.dart`, `lib/screens/onboarding_flow_screen.dart`, `lib/screens/settings_screen.dart`, `lib/widgets/installed_app_picker_sheet.dart`, `lib/widgets/why_this_finding_sheet.dart`, `lib/widgets/cloud_consent_sheet.dart`, `lib/widgets/private_readiness_sheet.dart`).
- **Verification**:
  - `flutter analyze`: **0 issues found**.
  - `flutter test`: **24/24 tests passing**.
  - `cd android && ./gradlew compileDebugKotlin --no-daemon`: **BUILD SUCCESSFUL**.
  - `flutter build apk --debug` + `adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-debug.apk` + cold launch: **Complete (`Status: ok`)**.

---

### Iteration 10.9 — 12-Language Local + Cloud Gemini Support, Onboarding Step 0 Copy & 4-Stage Milestone `ReviewProgressCard` (`feature/onboarding-and-process-text-flow`)
- **Date**: 2026-11-13
- **Branch / Commits**: `feature/onboarding-and-process-text-flow`
- **Models Used**: Orchestrator (Gemini 4 Argon / Hydrogen)
- **What Was Built**:
  - **12-Language Local & Cloud Gemini Localization (`lib/l10n/enprive_languages.dart`, `lib/l10n/app_*.arb`, `lib/widgets/language_picker_sheet.dart`)**:
    - Configured full UI `.arb` bundles (`untranslated_messages.json == {}`), generated `AppLocalizations` delegates, Android TTS BCP-47 locale tags (`resolveBcp47Locale`), and Cloud/On-Device Gemini response-language prompts (`languageDisplayName`) across all 12 requested languages: **English (`en`), Korean (`ko`), Spanish (`es`), French (`fr`), German (`de`), Arabic (`ar` with automatic RTL), Japanese (`ja`), Chinese (`zh`), Hindi (`hi`), Portuguese (`pt`), Italian (`it`), and Russian (`ru`)**.
    - Added `EnpriveLanguagePickerSheet` accessible from Home AppBar, Onboarding top bar, and Settings; updated `HybridAiBridge.analyseText` and `ReviewCoordinator` (`runPolicyReview`, `askDeniAboutFinding`, `buildDeterministicLocalReceipt`) to forward `languageCode` and use `intentHint` for language-independent fallback questions while strictly requiring verbatim source-language `quote` substrings for `EvidenceValidator`.
    - Removed hardcoded `isKorean` branches across `lib/main.dart`, `lib/screens/receipts_screen.dart`, `lib/screens/settings_screen.dart`, `lib/screens/review_result_screen.dart`, `lib/widgets/enprive_provenance_chip.dart`, `lib/widgets/private_readiness_sheet.dart`, `lib/widgets/cloud_consent_sheet.dart`, `lib/widgets/installed_app_picker_sheet.dart`, `lib/widgets/why_this_finding_sheet.dart`, and `lib/widgets/analysis_process_trace.dart`, and switched alignment properties to `AlignmentDirectional.centerStart` / `EdgeInsetsDirectional` for Arabic RTL.
  - **First Onboarding Screen Copy (`lib/screens/onboarding_flow_screen.dart`, `lib/l10n/app_*.arb`)**:
    - Replaced Step 0 intro content with *"Hi, I'm Deni. 👋"*, *"Let's make app privacy easier to understand."*, the two-paragraph explanation card, and the *"Know what you're agreeing to."* footer badge, localized across all 12 languages.
  - **Improvised 4-Stage Milestone `ReviewProgressCard` (`lib/widgets/review_progress_sheet.dart`)**:
    - Built a two-layer progress card with overlapping 3-badge source icons top-right, a dark capsule 4-step milestone stepper (`Read → Privacy Guard → Analyze → Verify Quotes`) with animated rounded connectors, single-line live streaming reasoning ticker bottom-left, and localized tabular `"X of 4"` counter (`progressStepCounter`) bottom-right.
- **Challenges & Root-Cause Fixes**:
  - Moved `resolveBcp47Locale` and `languageDisplayName` out of the `setMethodCallHandler` `when` block in `android/app/src/main/kotlin/com/example/enprive/MainActivity.kt` into class-level `private fun` helpers so Kotlin compiled cleanly.
  - Replaced `pumpAndSettle()` with explicit `pump(...)` + `dragUntilVisible` in `test/widget_test.dart` for `OnboardingFlowScreen` and `ReviewProgressCard` because `DeniAnimatedMascot` runs continuous ambient breathing animations.
- **Verification**:
  - `flutter analyze`: **0 issues found**.
  - `flutter test`: **27/27 tests passing** (including 12-language bundle & `HybridAiBridge`/`ReviewCoordinator` propagation test, Onboarding picker + Arabic RTL test, and 4-step `ReviewProgressCard` stage + 200% text-scale + RTL test).
  - `cd android && ./gradlew compileDebugKotlin --no-daemon`: **BUILD SUCCESSFUL**.
  - `flutter build apk --debug` + `adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-debug.apk` + launch (`com.example.enprive/.MainActivity`): **Success**.

---

### Iteration 11 — Editorial Brand Splash Screen, Onboarding Step 0 Card Removal & `ip-as-logo` Icon Skill Setup (`feature/splash-and-deni-icon`)
- **Date**: 2026-11-13
- **Branch / Commits**: `feature/splash-and-deni-icon` (branched from `feature/onboarding-and-process-text-flow` @ `24c880a`, uncommitted working tree)
- **Models Used**: Orchestrator (Gemini 4 Argon / Hydrogen)
- **What Was Built**:
  - **Editorial Brand Splash Screen (`lib/screens/splash_screen.dart`, `lib/main.dart`, 12 `.arb` files)**:
    - Added `EnpriveSplashScreen` on warm paper (`#FAF8F5`) displaying bold **`enprive`** (`Nunito` w800) with the centered quote **`"Know what you're agreeing to"`** (`SourceSerif4` w600, localized via `splashQuote` across all 12 `.arb` languages), calm 520ms entrance respecting `disableAnimations`, tap-to-dismiss, and automatic cross-fade transition into `HomeScreen`.
    - Deferred first-run onboarding trigger and pending `PROCESS_TEXT` / `SEND` handling cleanly until the splash finishes (skipping fast when an external text-share intent arrives).
    - Updated native Android (`values/colors.xml`, `drawable/splash_blank.xml`, `drawable/launch_background.xml`, `drawable-v21/launch_background.xml`, `values/styles.xml`, `values-night/styles.xml`, `values-v31/styles.xml`, `values-night-v31/styles.xml`) and iOS (`ios/Runner/Base.lproj/LaunchScreen.storyboard`) launch backgrounds to seamless warm paper (`#FAF8F5`) with empty Android 12+ icon drawable to prevent a double logo/flash on cold start.
  - **Onboarding Step 0 Card Removal (`lib/screens/onboarding_flow_screen.dart`)**:
    - Removed the entire explanation body card container, inner paragraphs, and footer badge from `_buildStep0Intro`, keeping only the animated Deni mascot (`DeniPose.idle`), **"Hi, I'm Deni. 👋"**, and **"Let's make app privacy easier to understand."**.
  - **Deni App Icon Skill Installation (`.agents/skills/ip-as-logo/`)**:
    - Installed `s1dashu/ip-as-logo-skill` via `npx -y skills@latest add s1dashu/ip-as-logo-skill`.
    - Designed 3 Deni Concept C directions (`A` Classic Protective Pebble, `B` Warm Shielded Curio, `C` Storybook Companion; 2 IP colors + 1 solid background color, lower-left emergence) and paused before generation per `SKILL.md` governance while awaiting user confirmation to run the 6-candidate (`A1`–`C2`) batch with `image-generator`.
- **Challenges & Root-Cause Fixes**:
  - Re-applied `lib/main.dart` and `test/widget_test.dart` splash wiring after an open IDE editor buffer overwrote the earlier edits; confirmed persistence via test count reaching `28/28` including `EnpriveSplashScreen` tests.
  - Added both `values-v31/styles.xml` and `values-night-v31/styles.xml` on Android so `values-night` does not override Android 12+ splash background properties in dark system theme.
- **Verification**:
  - `flutter gen-l10n`: **Success**.
  - `flutter analyze`: **0 issues found**.
  - `flutter test`: **28/28 tests passing** (`EnpriveSplashScreen` localization + tap dismissal, `EnpriveApp` splash-to-home flow, 200% text scale + reduced motion, and card-free Onboarding Step 0).
  - `cd android && ./gradlew compileDebugKotlin --no-daemon`: **BUILD SUCCESSFUL**.
  - `flutter build apk --debug` + `adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-debug.apk` + launch (`com.example.enprive/.MainActivity`): **Success**.

---

### Iteration 12 — Deni `ip-as-logo` App Icon (`A1` + Dark Smile), Adaptive Launcher Packaging & Home AppBar Logo (`feature/splash-and-deni-icon`)
- **Date**: 2026-11-13
- **Branch / Commits**: `feature/splash-and-deni-icon` (uncommitted working tree ready for review/commit)
- **Models Used**: Orchestrator (Gemini 4 Argon / Hydrogen) + workspace `image-generator` subagents (`ip-as-logo`)
- **What Was Built**:
  - **6-Candidate `ip-as-logo` Exploration & Final `A1` + Smile Variant**:
    - Generated all 6 independent `1024 × 1024` candidates (`A1`, `A2`, `B1`, `B2`, `C1`, `C2`) emerging upright from the lower-left using 2 IP colors + 1 solid background color per candidate via parallel `image-generator` subagents.
    - User selected **`A1`** (Oceanic Teal pebble + Deep Ink Navy blunt folded cap on Warm Paper Cream `#F1ECDC`–`#F4EDDD`) and requested adding a small dark curved smile (`deni_pebble_a1_smile_1794582990774.jpg`).
  - **Cross-Platform App Icon Packaging**:
    - Packaged `assets/images/enprive_logo.png` (`512 × 512`) and declared `assets/images/` in `pubspec.yaml`.
    - Generated all 15 iOS `AppIcon.appiconset` PNGs (`20px` through `1024px`) matching `Contents.json`.
    - Generated Android legacy `mipmap-{mdpi,hdpi,xhdpi,xxhdpi,xxxhdpi}/ic_launcher.png` (`48px`–`192px`) and API 26+ Android Adaptive Icons (`mipmap-anydpi-v26/ic_launcher.xml`, `ic_launcher_round.xml`, `values/colors.xml` `enprive_icon_bg = #F1ECDC`, `android:roundIcon` in `AndroidManifest.xml`, and `mipmap-*/ic_launcher_foreground.png`).
  - **Home Screen AppBar Brand Mark (`lib/main.dart`, `test/widget_test.dart`)**:
    - Replaced the old teal shield placeholder (`Ph.shield_check_duotone`) in `HomeScreen`'s `AppBar` with a crisp `34 × 34` rounded square rendering `assets/images/enprive_logo.png` (`excludeFromSemantics: true` + subtle `EnpriveColors.ink` `0.12` alpha border).
    - Extended `test/widget_test.dart` to verify `AppBar` renders `AssetImage('assets/images/enprive_logo.png')`.
- **Challenges & Root-Cause Fixes**:
  - Pixel-bounds inspection on `deni_pebble_a1_smile` (`minY = 0.122`, `maxX = 0.890`) showed an unpadded full-bleed `108dp` adaptive foreground would clip the cap peak and right brim inside Android's `66–72dp` circular mask. Fixed by using `scale = 0.72` centered placement with `CLAMP_TO_EDGE` border extension for `ic_launcher_foreground.png`, preserving both seamless lower-left teal bleed and unclipped face/cap inside Pixel Launcher circles.
  - Replaced an initial `EnpriveColors.border` reference in `lib/main.dart` with `EnpriveColors.ink.withValues(alpha: 0.12)` per `lib/core/theme/enprive_colors.dart`.
- **Verification**:
  - `flutter pub get`: **Success**.
  - `flutter analyze`: **0 issues found**.
  - `flutter test`: **28/28 tests passing** (including Home `AppBar` `AssetImage` assertion).
  - `cd android && ./gradlew compileDebugKotlin --no-daemon`: **BUILD SUCCESSFUL** (21s).
  - `flutter build apk --debug` + `adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-debug.apk` + live Pixel 9 visual checks (`emulator_home.png` AppBar + `emulator_launcher.png` circular launcher icon): **Verified & clean**.
- **Next Immediate Action & Recommended Model**:
  - Commit and push `feature/splash-and-deni-icon` (excluding untracked local `.docx` / scratch assets) and merge PR into `main`.
  - Recommended Model: **Gemini 4 Argon / Hydrogen**.

---

### Iteration 13 — Read-Only AI Prompt Management, Server Prompt Templates & Remote Config Investigation (`docs/architecture/`)
- **Date**: 2026-11-13
- **Branch / Commits**: `feature/splash-and-deni-icon` (read-only investigation; deliverables written strictly under `docs/architecture/`, zero app code or Firebase project changes)
- **Models Used**: Architectural Investigator (Gemini)
- **What Was Built**:
  - Audited entire Flutter (`lib/`, `pubspec.yaml`, `test/`), iOS (`ios/Runner/`), and Android native Kotlin (`android/app/src/main/kotlin/com/example/enprive/MainActivity.kt`, `build.gradle.kts`, `AndroidManifest.xml`, compiled `firebase-ai-18.2.0-api.jar` bytecode via `javap`) implementation against `docs/*.docx` and live official Firebase documentation.
  - Authored four architecture deliverables:
    1. `docs/architecture/ai-prompt-management-investigation.md` (12-area inventory table with 5-tier status classifications, code-vs-docs discrepancies, Server Prompt Templates compatibility & IAM/logging findings, and Remote Config parameter audit).
    2. `docs/architecture/ai-prompt-management-architecture.md` (target hybrid/cloud Mermaid architecture diagrams, Kotlin-over-Dart SDK decision, `LocalPromptRegistry`, Dotprompt contracts & split translation templates, 4-layer Deni model, 10-category/10-metric evaluation harness, and 9-column before-and-after table).
    3. `docs/architecture/ai-prompt-migration-plan.md` (Phases A–G roadmap, rejected/deferred alternatives, and 7-question Final Decision Report).
    4. `docs/architecture/scout-discover.md` (comprehensive consolidated Scout & Discovery dossier unifying all codebase facts, SDK/bytecode findings, architecture design, evaluation harness, migration roadmap, and Final Decision Report).
- **Key Investigation Findings**:
  - **`firebase-ai:18.2.0` Bytecode Ready**: Native Kotlin already bundles `TemplateGenerativeModel`, `TemplateChat`, `TemplateTool`, and `UsageMetadata`; `pubspec.yaml` contains zero Firebase plugins.
  - **Consent Regression**: `ReviewCoordinator.runPolicyReview` & `askDeniAboutFinding` currently escalate silently via `PiiRedactor.redact` + `PREFER_ON_DEVICE` (`cloudConsent: true`), leaving `CloudConsentSheet` unused (must be fixed in Phase A before cloud templates).
  - **Firebase Constraints**: Server Prompt Templates are Public Preview, cloud-only (no Gemini Nano/hybrid/`LiveGenerativeModel`, no enum-list output schemas), and project-wide `"template-only mode"` must remain **OFF** (`403` conflict with hybrid `GenerativeModel`); Cloud Logging prompt-body exclusion filter (`resource.type="firebasevertexai.googleapis.com/Client"`) is also required.
- **Verification**:
  - `flutter analyze`: **0 issues found**.
  - `flutter test`: **28/28 tests passing** (no code modified).
- **Next Immediate Action & Recommended Model**:
  - User/team review of `docs/architecture/ai-prompt-migration-plan.md` before authorizing Phase A (`CloudConsentSheet` restoration & `InferenceSource.offlineDeterministic`) or Phase B/C (`LocalPromptRegistry` + `enprive-finding-explanation-cloud-v1-0-0` POC).
  - Recommended Model for Phase A/B/C Kotlin+Dart implementation: **Gemini 4 Argon** or **Claude Opus 5.5**.

---

### Iteration 14 — Phase A: Privacy Boundary Restoration (`feature/phase-a-privacy-boundary`)
- **Date**: 2026-11-13
- **Branch / Base Commit**: `feature/phase-a-privacy-boundary` (branched from `feature/splash-and-deni-icon` @ `4bbdc28`)
- **What Was Built**:
  - **Eliminated Silent Cloud Escalation & Wired Per-Check Consent Gate**:
    - Removed automatic `cloudConsent: true` / `PREFER_ON_DEVICE` escalations in `ReviewCoordinator.runPolicyReview` and `ReviewCoordinator.askDeniAboutFinding` (`lib/domain/review/review_coordinator.dart`). Unconsented comprehensive policies (`PiiRedactor.isComprehensivePolicy`) and unavailable/failed `ONLY_ON_DEVICE` checks now pause with `ReviewExecutionResult.requiresConsentChoice` / `DeniExplanation.requiresConsentChoice` (containing scrubbed `redactedPreview` and `consentReason`).
    - Explicitly consented cloud executions pass `requestedMode: 'ONLY_IN_CLOUD'`; PII redaction (`PiiRedactor.redact`) applies strictly for data minimization after consent and preview scrubbing, never as a substitute for consent.
    - Hardened `HybridAiBridge.analyseText` (`lib/services/platform/hybrid_ai_bridge.dart`) to reject non-`ONLY_ON_DEVICE` modes immediately in Dart with `CLOUD_CONSENT_REQUIRED` when `cloudConsent == false`.
    - Wired `CloudConsentSheet.show` (`lib/widgets/cloud_consent_sheet.dart`) into both Home/policy review (`lib/main.dart`) and Deni finding explanation (`lib/widgets/why_this_finding_sheet.dart`), resetting `_isCloudReviewInFlight = false` cleanly on completion and enforcing per-check consent (`cloudConsentGrantedForSession: false`).
  - **Provenance & Localization Fidelity (`OFFLINE_DETERMINISTIC` & `UNKNOWN`)**:
    - Added `InferenceSource.offlineDeterministic` plus shared `parseInferenceSource(String? raw)` (`lib/widgets/enprive_provenance_chip.dart`) and amber theme tokens `chipOfflineFg` / `chipOfflineBg` (`lib/core/theme/enprive_colors.dart`).
    - Added `chipOfflineDeterministic` across all 12 `.arb` files (`lib/l10n/app_{en,ar,de,es,fr,hi,it,ja,ko,pt,ru,zh}.arb`) and regenerated `lib/l10n/app_localizations*.dart`.
    - Updated `ReviewCoordinator` deterministic fallbacks and `PolicyReviewReceipt.fromJson` (`lib/domain/review/review_models.dart`) so offline clause/finding scans record `InferenceSource.offlineDeterministic` and unrecognized/`UNKNOWN`/missing provenance maps to `InferenceSource.locationUnavailable`.
  - **Native Android Kotlin Consent & Provenance Guard (`MainActivity.kt`, `HybridAiPolicy.kt`)**:
    - Extracted testable `HybridAiPolicy` (`android/app/src/main/kotlin/com/example/enprive/HybridAiPolicy.kt`) and enforced `HybridAiPolicy.isRequestPermitted`, `resolveInferenceMode`, `shouldAttachOnDeviceConfig` (omits `OnDeviceConfig` when `ONLY_IN_CLOUD`), and `mapInferenceSource` (`UNKNOWN` when unestablished) in `MainActivity.kt` while keeping `useLimitedUseAppCheckTokens = true`.
    - Added `testImplementation("junit:junit:4.13.2")` in `android/app/build.gradle.kts` and unit tests in `android/app/src/test/kotlin/com/example/enprive/HybridAiPolicyTest.kt`.
  - **Layout Overflow Fixes & Regression Tests**:
    - Fixed `WhyThisFindingSheet` row overflows via `Wrap`, widened `HomeScreen` `AnimatedStatusCard` non-stacked `cardHeight` from `208.0` to `218.0`, and wrapped `EnpriveTactileButton` label row in `FittedBox(fit: BoxFit.scaleDown)` with horizontal padding (`lib/widgets/enprive_tactile_button.dart`).
    - Added unit and widget regression tests across `test/review_coordinator_test.dart`, `test/receipt_repository_test.dart`, and `test/widget_test.dart`.
- **Requirement #8 Investigation — Cloud Logging Prompt/Response Retention**:
  - Host environment has no `gcloud` CLI installed (`gcloud: not found`), `firebase` is not on default `PATH`, and cached `firebase-tools` (`15.36.0`) exposes no Cloud Logging or Firebase AI Monitoring inspection subcommands (`--help` checked). Project `.firebaserc` points to `enprive-hybrid-ai` and `firebase.json` is `{}`.
  - Live Google Cloud Logging `_Default` sink exclusion filter (`resource.type="firebasevertexai.googleapis.com/Client"`) and AI Monitoring trace capture settings remain unverified from this host and must be checked in Google Cloud Console / Firebase Console prior to cloud template rollout.
- **Verification**:
  - `flutter analyze`: **0 issues found**.
  - `flutter test`: **36/36 tests passed**.
  - `cd android && ./gradlew :app:testDebugUnitTest --rerun-tasks`: **BUILD SUCCESSFUL**, `HybridAiPolicyTest` **5/5 passed, 0 skipped, 0 failed**. (Note: unfiltered `./gradlew testDebugUnitTest` earlier hit third-party `:shared_preferences_android:testDebugUnitTest` `SharedPreferencesTest > classMethod` Java 17 vs Robolectric SDK 36 failure outside app test scope.)
  - `flutter build apk --debug`: **Built `build/app/outputs/flutter-apk/app-debug.apk`** cleanly.
- **Next Immediate Action & Recommended Model**:
  - Stop at Phase A boundary; review changes and verify live GCP/Firebase Cloud Logging exclusion filter + physical Android AICore/Gemini Nano hardware before authorizing Phase B (no Server Prompt Templates or Remote Config added yet).
  - Recommended Model: **Gemini 4 Argon / Claude Opus 5.5**.

---

### Iteration 15 — Phase A Closure Review & Hardening (`feature/phase-a-privacy-boundary`)
- **Date**: 2026-11-13
- **Branch / Base Commit**: `feature/phase-a-privacy-boundary` (uncommitted working tree atop `4bbdc28`)
- **What Was Audited & Fixed**:
  - **1. Explicit `InferenceSource.unknown` Provenance State**:
    - Replaced the mapping of `'UNKNOWN'` / missing / unrecognized inference sources from `InferenceSource.locationUnavailable` to explicit `InferenceSource.unknown` across `lib/widgets/enprive_provenance_chip.dart` (`InferenceSource.unknown`, `parseInferenceSource`, and chip rendering), `lib/domain/review/review_models.dart` (`DeniExplanation.requiresConsentChoice`), and `lib/domain/review/review_coordinator.dart` (`_buildInsufficientReceipt`), while preserving legacy `'LOCATION_UNAVAILABLE'` / `'locationUnavailable'` deserialization.
    - Added `"chipUnknown"` (`"Processing source unknown"`) across all 12 `.arb` files (`lib/l10n/app_{en,ar,de,es,fr,hi,it,ja,ko,pt,ru,zh}.arb`) and regenerated `lib/l10n/app_localizations*.dart` via `flutter gen-l10n`.
  - **2. Displayed vs. Submitted Scrubbed Payload Correspondence**:
    - Identified a closure defect in `lib/widgets/cloud_consent_sheet.dart` where `previewSnippet` truncated scrubbed payloads at `180` characters (`maxLines: 3, overflow: TextOverflow.ellipsis`) even though full `redactedText` was submitted to `ONLY_IN_CLOUD`.
    - Removed the 180-character truncation and rendered the full `scrubbedPreview` inside a bounded scrollable `SelectableText` container (`maxHeight: 160`); trimmed `compositeInput` components in `ReviewCoordinator.askDeniAboutFinding` so displayed text in `CloudConsentSheet` matches `args['text']` submitted to `ONLY_IN_CLOUD` character-for-character (verified programmatically in `test/review_coordinator_test.dart` and `test/widget_test.dart`).
  - **3. Consent Flow Re-Entrancy & Single-Cloud-Call Guards**:
    - Added `_isConsentSheetOpen` re-entrancy guards in both `HomeScreen._executePolicyReview` (`lib/main.dart`) and `WhyThisFindingSheet._askDeni` (`lib/widgets/why_this_finding_sheet.dart`), and disabled `DeniAnimatedMascot.onTap` while `_isAskingDeni || _isConsentSheetOpen` so double-taps cannot queue duplicate consent dialogs or cloud calls when choosing "Use cloud for this check".
  - **4. Regression Tests & Full Diff/Gradle Audit**:
    - Updated `test/receipt_repository_test.dart`, `test/review_coordinator_test.dart`, and `test/widget_test.dart` to assert `InferenceSource.unknown`, legacy `locationUnavailable` deserialization, full untruncated `CloudConsentSheet` rendering (`> 200` chars), exact equality between displayed preview and submitted `ONLY_IN_CLOUD` payload, and single-call cloud execution.
    - Confirmed zero skipped tests, no weakened privacy assertions, no unintended Gradle dependency/toolchain changes (only `junit:junit:4.13.2` `testImplementation` in `android/app/build.gradle.kts`), and zero Gemini Nano mislabeling on deterministic fallbacks.
- **Verification**:
  - `flutter gen-l10n`: **Exited 0**.
  - `flutter analyze`: **0 issues found**.
  - `flutter test`: **36/36 tests passed** (`0` failed, `0` skipped).
  - `cd android && ./gradlew :app:testDebugUnitTest --rerun-tasks`: **BUILD SUCCESSFUL**, `HybridAiPolicyTest`: **5/5 passed, 0 skipped, 0 failed**.
  - `flutter build apk --debug`: **Built `build/app/outputs/flutter-apk/app-debug.apk` cleanly**.
- **Next Immediate Action & Recommended Model**:
  - Complete live GCP Cloud Logging audit (`enprive-hybrid-ai`) and physical-device verification checklist before Phase A sign-off or Phase B authorization.
  - Recommended Model: **Gemini 4 Argon / Claude Opus 5.5**.

---

### Iteration 16 — Phase A `generateContentStream` Retry Defect Remediation (`feature/phase-a-privacy-boundary`)
- **Date**: 2026-11-14
- **Branch / Base Commit**: `feature/phase-a-privacy-boundary` (preserving all pre-existing uncommitted Phase A working-tree changes atop `4bbdc28`)
- **What Was Fixed**:
  - **Root Cause**: In `android/app/src/main/kotlin/com/example/enprive/MainActivity.kt`, `collectStream(preferThoughts)` wrapped its cloud stream invocation in a generic `catch (e: Exception)` block checking `if (preferThoughts && !isUnavailable && !hasAnyOutput)`. Because `isUnavailable` only matched `"NotAvailable"` / `"not available"`, every other pre-output exception — including HTTP 429 (`QuotaExceededException`), Airplane-mode/DNS failures, App Check failures, auth errors, timeouts, cancellations, and generic model errors — fell through to `collectStream(false)` and triggered a second `generateContentStream(prompt)` invocation (36 native streaming attempts across 18 failed consented bursts).
  - **Upfront Thinking Configuration & Single-Invocation Enforcement (`HybridAiPolicy.kt`, `MainActivity.kt`)**:
    - Added `HybridAiPolicy.ThinkingPolicyDecision`, `HybridAiPolicy.supportsThinkingLevel`, `HybridAiPolicy.resolveThinkingPolicy`, `HybridAiPolicy.SingleGenerationGuard`, and `HybridAiPolicy.executeSingleGenerationAttempt` in `android/app/src/main/kotlin/com/example/enprive/HybridAiPolicy.kt`.
    - Resolved `thinkingConfig` compatibility strictly **before** submitting any request (`ENABLE_THINKING_LEVEL` only for `InferenceMode.ONLY_IN_CLOUD` with supported Gemini 3+ text models such as `gemini-3.8-flash`; omitted up front when optional on on-device/hybrid or non-Gemini-3 models; rejected preflight when `requireThinking = true` and compatibility cannot be established).
    - Replaced `MainActivity.kt`'s `try { collectStream(preferThoughts) } catch (...) { collectStream(false) }` retry loop with a single-attempt call through `HybridAiPolicy.executeSingleGenerationAttempt`, propagating failures cleanly once with `inferenceSource = "UNKNOWN"` and `status = "failed"` / `"unavailable"` (plus clean rethrow when `CancellationException` occurs on an inactive coroutine scope).
  - **Regression Coverage (`HybridAiPolicyTest.kt`, `test/review_coordinator_test.dart`)**:
    - Expanded `HybridAiPolicyTest.kt` to **13 JVM unit tests** (`0` real Firebase calls) asserting exact model-generation invocation counts (`1` on success, HTTP 429 quota, Airplane mode/DNS, App Check failure, auth/timeout/cancellation/generic errors, or unexpected backend thinking rejection; `0` on cancelled consent or strict preflight rejection).
    - Expanded `test/review_coordinator_test.dart` (`ReviewCoordinator Hybrid & Evidence Tests`) verifying `1` native bridge call without silent retry on HTTP 429, Airplane mode, App Check, unsupported thinking config, and generic errors (recording `InferenceSource.offlineDeterministic`, never `InferenceSource.onDevice`), `1` call on cloud success (`InferenceSource.inCloud`), and `0` cloud calls on cancelled consent / offline fallback.
- **Verification**:
  - `flutter analyze`: **0 issues found**.
  - `flutter test`: **38/38 passed** (`0` failed, `0` skipped).
  - `cd android && ./gradlew :app:testDebugUnitTest --rerun-tasks`: **BUILD SUCCESSFUL**, `HybridAiPolicyTest`: **13/13 passed, 0 failed, 0 skipped**.
  - `flutter build apk --debug`: **Built `build/app/outputs/flutter-apk/app-debug.apk` cleanly**.
- **Next Immediate Action & Recommended Model**:
  - Complete physical Android verification of single-attempt cloud quota/network behavior while preserving Phase A privacy/UI boundaries before Phase B.
  - Recommended Model: **Gemini 4 Argon / Claude Opus 5.5**.

---

### Iteration 17 — Retry Remediation Edge-Case Audit (`feature/phase-a-privacy-boundary`)
- **Date**: 2026-11-14
- **Branch / Base Commit**: `feature/phase-a-privacy-boundary` (preserving all pre-existing uncommitted Phase A working-tree changes atop `4bbdc28`)
- **What Was Audited & Fixed**:
  - **1. Unconditional `CancellationException` Propagation (Kotlin & Dart)**:
    - Confirmed the prior `if (e is CancellationException && !isActive) throw e` check in `MainActivity.kt` could swallow child-operation or `withTimeout` (`TimeoutCancellationException`) cancellation while the parent `lifecycleScope` coroutine remained active, misclassifying cancellation as an ordinary `"failed"` error eligible for deterministic fallback.
    - Added `HybridAiPolicy.TerminalFailureInfo` and `HybridAiPolicy.executeSingleOperation(...)` in `android/app/src/main/kotlin/com/example/enprive/HybridAiPolicy.kt`, and wired `MainActivity.kt` through `executeSingleOperation(...)` so **every** `CancellationException` invokes `onCancel` (sending `result.error("CANCELLED", ...)` via `NonCancellable + Dispatchers.Main` when no reply has been submitted yet) and unconditionally rethrows **before** `catch (e: Exception)` error mapping.
    - Added `HybridOperationCancelledException` in `lib/services/platform/hybrid_ai_bridge.dart` so native `'CANCELLED'` / `'CANCELED'` / cancellation error codes throw and propagate directly out of `HybridAiBridge.analyseText` and `ReviewCoordinator` (`runPolicyReview`, `askDeniAboutFinding`) without becoming `InferenceSource.offlineDeterministic` fallbacks or triggering a second cloud request. Added clean `on HybridOperationCancelledException` state reset handlers in `lib/main.dart` and `lib/widgets/why_this_finding_sheet.dart`.
  - **2. Per-Operation `SingleGenerationGuard` Lifetime & Concurrency**:
    - Confirmed `SingleGenerationGuard` is instantiated per call (`guard: SingleGenerationGuard = SingleGenerationGuard()`) inside `HybridAiPolicy.executeSingleGenerationAttempt(...)` with zero Activity-wide or global singleton state.
    - Verified via JVM tests (`HybridAiPolicyTest.kt`) that concurrent duplicate entry (8 threads racing via `CountDownLatch`) allows strictly `1` execution and rejects `7`, sequential duplicate entry rejects the 2nd attempt, and independent sequential/concurrent operations do not block one another (`test/review_coordinator_test.dart` also verifies independent sequential cloud operations).
  - **3. Thinking Configuration Compatibility (`gemini-3.8-flash` & `OMIT_THINKING_CONFIG`)**:
    - Verified `MainActivity.kt` uses `HybridAiPolicy.CLOUD_THINKING_LEVEL` (`ThinkingLevel.LOW`, never unsupported `ThinkingLevel.MINIMAL`) for `gemini-3.8-flash` in `ONLY_IN_CLOUD`.
    - Renamed `ThinkingPolicyDecision.DISABLE_THINKING_CONFIG` to `ThinkingPolicyDecision.OMIT_THINKING_CONFIG` (reflecting that Gemini 3.x models always use dynamic thinking and omitting explicit `thinkingConfig` does not disable thinking) and added `HybridAiPolicy.isThinkingLevelSupported(modelName, thinkingLevel)` enforcing upfront rejection of `ThinkingLevel.MINIMAL` on `gemini-3.8*` / `gemini-3.7*`.
- **Verification**:
  - `flutter analyze`: **0 issues found**.
  - `flutter test`: **39/39 passed** (`0` failed, `0` skipped).
  - `cd android && ./gradlew :app:testDebugUnitTest --rerun-tasks --console=plain`: **BUILD SUCCESSFUL**, `HybridAiPolicyTest`: **15/15 passed, 0 failed, 0 skipped**.
  - `flutter build apk --debug`: **Built `build/app/outputs/flutter-apk/app-debug.apk` cleanly**.
- **Next Immediate Action & Recommended Model**:
  - Complete manual physical Android device & GCP Cloud Logging audit for Phase A sign-off (Phase B not started).
  - Recommended Model: **Gemini 4 Argon / Claude Opus 5.5**.

---

### Iteration 18 — Material 3 Rebrand Audit, Supplemental M3E/HCT Evaluation & Deni LOD Specification (`feature/phase-a-privacy-boundary`)
- **Date**: 2026-11-14
- **Branch / Base Commit**: `feature/phase-a-privacy-boundary` (read-only design audit & architecture evaluation atop `4bbdc28` + uncommitted Iterations 14–17)
- **What Was Investigated & Specified**:
  - **1. Full Material 3 Design-System Audit & 14-Screen Emulator Capture (`enprive-m3-design-system-audit.md`)**:
    - Audited `lib/core/theme/enprive_colors.dart`, `lib/core/theme/enprive_theme.dart`, `lib/main.dart`, all 5 screens, and all 11 widgets; captured 14 live Android emulator (`sdk_gphone64_arm64`) screenshots across Onboarding, Home, InstalledAppPickerSheet, PasteModal, CloudConsentSheet, ReviewResultScreen, WhyThisFindingSheet (Ask Deni), ReceiptsScreen, and SettingsScreen.
    - Identified core UX/theme bottlenecks: `ReviewResultScreen` requires ~600dp of scrolling before Finding #1; `WhyThisFindingSheet` renders streamed answers below the fold without collapsing the static clause box or scrolling into view; 268 static `EnpriveColors.*` references bypass `Theme.of(context)`; and `DeniAnimatedMascot` renders full-size external floating props at `48–64dp`.
  - **2. Supplemental `material_3_expressive` (`1.2.1`), `material_color_utilities` (`0.13.0`), and Design Skills Evaluation (`enprive-m3e-and-mascot-specification.md`)**:
    - Inspected `material_3_expressive` (`1.2.1`) and `material_color_utilities` (`0.13.0`) against Flutter `3.47.9` / Dart `3.13.7`, plus the `charliesbot/android-design` and `hamen/material-3-skill` references and all 8 visual inspiration files in `mobile ui and ux inspration/`.
    - Approved **Option A**: Native Flutter Material 3 (`package:flutter/material.dart`) + Custom `ThemeExtension`s (`EnpriveSemanticColors`, `EnpriveSurfaceTokens`, `EnpriveMotionTokens`, `EnpriveTypographyExtension`) + Direct `material_color_utilities` HCT palettes & `Blend.harmonize`, avoiding a global `package:material_ui` migration.
    - Specified the **3-Tier Deni LOD Architecture** (`LOD 1: 48–64dp` compact, `LOD 2: 68–112dp` standard companion, `LOD 3: 116dp+` hero) for **Concept C (The Protective Pebble with Paper Tab)** with strict non-certification visual trust guardrails.
- **Verification**:
  - `flutter analyze`: **0 issues found**.
  - `flutter test`: **39/39 passed**.
  - `cd android && ./gradlew :app:testDebugUnitTest --console=plain`: **BUILD SUCCESSFUL**, `HybridAiPolicyTest`: **15/15 passed**.
- **Next Immediate Action & Recommended Model**:
  - Commit the verified Phase A + Audit baseline (`Iterations 14–18`) on `feature/phase-a-privacy-boundary`, branch `feature/m3-expressive-rebrand`, and execute **Design Phase 1 — Theme Foundation and Deni LOD**.
  - Recommended Model: **Gemini 4 Argon / Claude Opus 5.5**.

---

## Upcoming Iterations Queue (From Docs & Architecture Review)

1. **Manual Device & GCP Verification + Phase A Review**
   - **Assigned Model**: Human Product/Tech Lead Verification
   - **Scope**: Verify `enprive-hybrid-ai` Google Cloud Logging `_Default` sink exclusion filter / AI Monitoring settings in Console, plus test physical Android device AICore Gemini Nano & App Check `ONLY_IN_CLOUD` execution before authorizing Phase B.
2. **Phase B/C Planning (`LocalPromptRegistry` & POC Server Prompt Template)**
   - **Assigned Model**: **Gemini 4 Argon / Claude Opus 5.5**
   - **Scope**: Begin Phase B only after explicit user authorization on clean Phase A base.
