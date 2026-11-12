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
- **Active Feature Branch**: `feature/review-flow-and-evidence-results` (Iteration 6 complete, verified, ready to merge)
- **Competition Deadline**: 30 November 2026, 2:00 PM PT (Feature Freeze target: 24 November 2026)
- **Next Queued Branch**: `feature/app-permission-inspector` (Iteration 7 — Local Android App Inspector & `PermissionComparator`)

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

## Upcoming Iterations Queue (From Docs & Architecture Review)

1. **Iteration 7 (Next) — `feature/app-permission-inspector` [P0]**
   - **Assigned Model**: **Gemini 4 Argon** / **Claude Opus 5.5** (core) + **Devin CLI / Flash** (tests)
   - **Scope**: Local `listLaunchableApps` in `MainActivity.kt`, `PermissionComparator` in Dart, and Installed App Picker + Permission Comparison UI.
2. **Iteration 8 — `feature/local-receipts-storage` [P0/P1]**
   - **Assigned Model**: **Gemini 4 Argon** / **Claude Opus 5.5** (core) + **Devin CLI** (serialization/DB tests)
   - **Scope**: `sqflite` `ReceiptRepository`, SHA-256 snapshot hashing, Receipts list with filter chips, Receipt detail view, and 3-tab bottom navigation (`Home · Receipts · Settings`).
3. **Iteration 9 — `feature/tts-and-readiness-flow` [P0]**
   - **Assigned Model**: **Gemini Flash / Hydrogen / Claude Sonnet / Devin CLI**
   - **Scope**: Native Android `TextToSpeech` (`speakText`/`stopSpeaking`) synced with `DeniPose.listening`, private-analysis model readiness sheet, 200% text-scale & TalkBack audit, and `THIRD_PARTY_NOTICES.md`.
