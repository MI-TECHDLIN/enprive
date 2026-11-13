# Enprive — Evidence-First Hybrid AI Privacy Assistant

> Built for **Google #BuildHybridAI 2026** (`enprive-hybrid-ai`)

**Enprive** helps parents and teachers evaluate the privacy terms and Android permissions of apps children use—without sending installed app lists or device telemetry to the cloud, and without ever making unverified binary *"Safe"* claims.

---

## Core Architecture & #BuildHybridAI Guardrails

1. **On-Device First Hybrid AI (`Firebase AI Logic`)**:
   - Defaults strictly to on-device **Gemini Nano 4** via `OnDeviceConfig(mode = InferenceMode.ONLY_ON_DEVICE, modelOption = OnDeviceModelOption.PREVIEW)` in [`MainActivity.kt`](android/app/src/main/kotlin/com/example/enprive/MainActivity.kt).
   - If the on-device model is unavailable or the policy exceeds local token limits, Enprive never silently falls back to the cloud. Instead, it presents an explicit **Per-Check Cloud Consent Sheet** ([`cloud_consent_sheet.dart`](lib/widgets/cloud_consent_sheet.dart)) offering:
     - **Use cloud for this check** (`InferenceMode.PREFER_ON_DEVICE` with `gemini-3.8-flash` and App Check replay protection `useLimitedUseAppCheckTokens = true`), or
     - **Review on this phone** (100% offline deterministic clause scanner in [`review_coordinator.dart`](lib/domain/review/review_models.dart)).
   - Every result displays an honest provenance pill (`Checked on this phone` vs `Checked in cloud (consented)`) derived from `GenerateContentResponse.inferenceSource`.

2. **Deterministic Citation Alignment (`EvidenceValidator`)**:
   - Generative models propose structured candidate findings, but [`EvidenceValidator`](lib/domain/evidence/evidence_validator.dart) deterministically verifies every cited quote (`verbatimQuote`) against the normalized source snapshot before rendering.
   - Any claim whose quote cannot be matched to the source text is stripped from verified findings and downgraded to `Unverified`.
   - Enprive never certifies an app as *"Safe"*; when no concerns are found in the reviewed excerpt, it displays calibrated copy:
     > *"No concern identified in the reviewed evidence. This is not a safety certification."*

3. **Strictly Local Android Permission Comparison (`PermissionComparator`)**:
   - Queries launchable apps and granted/requested Android OS permissions (`ACCESS_FINE_LOCATION`, `ACCESS_BACKGROUND_LOCATION`, `RECORD_AUDIO`, `CAMERA`, `READ_CONTACTS`, `AD_ID`, `READ_MEDIA_IMAGES`) locally via `PackageManager` (`<queries>` `ACTION_MAIN` + `CATEGORY_LAUNCHER`, no `QUERY_ALL_PACKAGES`).
   - [`PermissionComparator`](lib/domain/permissions/permission_comparator.dart) cross-checks OS permissions against policy disclosures entirely on-device—installed app lists and permission snapshots **never** enter cloud endpoints or AI prompts.

4. **Deni — Rig-Aware 6-State Protective Pebble Mascot**:
   - Custom-painted in [`deni_animated_mascot.dart`](lib/widgets/deni_animated_mascot.dart) with grounded bottom-centre pivot, area-preserving squash/stretch (`squash(sy, 0.55)`), damped spring step response ($\zeta = 0.32$), 8% phase-lagged secondary motion on the folded paper tab, and articulated foreground hand-to-prop choreography across 6 states (`idle`, `thinking`, `explaining`, `listening`, `support`, `celebrating`).
   - Respects `MediaQuery.disableAnimations` and pairs with native Android `TextToSpeech` (EN/KO) so users can listen to the review summary aloud.

5. **Local SQLite Receipts & Bilingual UI (EN / KO)**:
   - Saves verifiable review receipts locally in SQLite (`enprive_receipts.db` via [`receipt_repository.dart`](lib/services/storage/receipt_repository.dart)) with 64-bit FNV-1a snapshot digests.
   - Bundled offline typography: **Nunito** (primary display/UI), **Inter** via FontBase (secondary body/labels), and **Source Serif 4** (verbatim policy blockquotes), with `GoogleFonts.config.allowRuntimeFetching = false`.

---

## Verification & Testing

```bash
# Static analysis (0 issues)
flutter analyze

# Unit & widget test suite (17/17 passing)
flutter test

# Native Android Kotlin compilation check
cd android && ./gradlew compileDebugKotlin --no-daemon
```

See [`journal.md`](journal.md) for the full iteration log and [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md) for open-source font and package notices.
