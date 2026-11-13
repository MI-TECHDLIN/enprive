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
- **Active Feature Branch**: `feature/onboarding-and-process-text-flow` (Iteration 10 complete, verified, ready to merge)
- **Competition Deadline**: 30 November 2026, 2:00 PM PT (Feature Freeze target: 24 November 2026)
- **Next Queued Branch**: `main` consolidation & final release verification

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

## Upcoming Iterations Queue (From Docs & Architecture Review)

1. **Final Release & PR Consolidation (`main` merge & APK verification)**
   - **Assigned Model**: **Gemini 4 Argon / Hydrogen**
   - **Scope**: Merge feature branch chain into `main`, verify release/debug APK build, and prepare #BuildHybridAI 2026 submission walkthrough.
