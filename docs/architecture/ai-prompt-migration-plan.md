# Enprive AI Prompt Management Migration Plan & Final Decision Report

- **Date**: 2026-11-13
- **Companion Documents**:
  - [ai-prompt-management-investigation.md](./ai-prompt-management-investigation.md)
  - [ai-prompt-management-architecture.md](./ai-prompt-management-architecture.md)
- **Execution Constraint**: This document specifies the approved implementation plan for review **before** modifying application code or Firebase Console/Remote Config state.

---

## 1. Execution Principles

1. **Privacy & Consent First**: The silent cloud escalation regression in `ReviewCoordinator` must be fixed *before* introducing any Server Prompt Template. No cloud template call may execute unless `cloudConsent == true` was granted via an explicit per-check user transition (`CloudConsentSheet`).
2. **Independent Local Hybrid Pipeline**: Gemini Nano 4 `ONLY_ON_DEVICE` and deterministic offline scanning remain fully functional offline at every phase, completely decoupled from Firebase Server Prompt Templates and Remote Config availability.
3. **Incremental Rollout**: Begin with a single low-risk cloud-only proof of concept (`enprive-finding-explanation-cloud-v1-0-0`) behind Kotlin `TemplateGenerativeModel`, leaving `PREFER_ON_DEVICE` and `GenerativeModel` cloud fallback intact until later phases verify stability.
4. **Never Enable Global Template-Only Mode**: Keep Firebase AI Logic project-wide Template-Only mode **OFF** as long as any hybrid `GenerativeModel` or future `LiveGenerativeModel` path remains active.

---

## 2. Phased Migration Plan (Phases A–G)

### Phase A — Architecture Discovery & Privacy Boundary Baseline
*(Discovery portion completed in `ai-prompt-management-investigation.md`; Phase A.1 remediates observed privacy/consent bugs before any cloud template is created.)*

- **Files Expected to Change**:
  - `lib/domain/review/review_coordinator.dart` (remove silent `cloudConsent: true` fallback on comprehensive/unavailable policies; surface `ReviewExecutionResult.requiresConsentChoice` in `runPolicyReview` and explicit consent error/choice in `askDeniAboutFinding`)
  - `lib/domain/review/review_models.dart` (add `InferenceSource.offlineDeterministic`)
  - `lib/main.dart` & `lib/screens/review_result_screen.dart` & `lib/widgets/why_this_finding_sheet.dart` (wire existing `lib/widgets/cloud_consent_sheet.dart` when `requiresConsentChoice == true`)
  - `android/app/src/main/kotlin/com/example/enprive/MainActivity.kt` (clean `OnDeviceConfig.IN_CLOUD` vs `ONLY_ON_DEVICE`, avoid attaching `OnDeviceModelOption.PREVIEW` when mode is `ONLY_IN_CLOUD`)
  - `test/review_coordinator_test.dart`, `test/widget_test.dart`
- **Dependencies**:
  - None (zero new Gradle or `pubspec.yaml` packages required).
- **Required Firebase Configuration**:
  - Add a **Google Cloud Logging `_Default` sink exclusion filter** (`resource.type="firebasevertexai.googleapis.com/Client"`) or turn off prompt-body capture in Firebase AI Logic monitoring so no raw policy/user payloads persist in Cloud Logging.
  - Verify Play Integrity SHA-256 certificates are registered in Firebase Console App Check settings.
- **Tests**:
  - Update `test/review_coordinator_test.dart` to assert that `runPolicyReview` and `askDeniAboutFinding` **block** cloud escalation (`needsCloudConsentOrManual == true`) when `cloudConsent == false` and only call cloud after explicit consent.
  - Assert `buildDeterministicLocalReceipt` emits `InferenceSource.offlineDeterministic` rather than mimicking Gemini Nano 4 `InferenceSource.onDevice`.
  - Widget test confirming `CloudConsentSheet` renders redacted preview and respects cancel / manual / cloud-once choices.
- **Acceptance Criteria**:
  - `0` unconsented `IN_CLOUD` calls possible from `PROCESS_TEXT`, `SEND`, paste modal, or `WhyThisFindingSheet`.
  - `flutter analyze` passes with `0` issues; `100%` of `flutter test` pass.
  - `Cloud Logging` verified not to retain raw prompt text.
- **Rollback Procedure**:
  - Pure Git PR revert on feature branch (`feature/consent-gate-hardening`) restoring pre-change branch state; no Firebase resources modified.
- **Dependencies on Earlier Phases**:
  - None (entry gate for the entire roadmap).

---

### Phase B — Prompt Standardization & Local Prompt Registry
*(Decouple local Gemini Nano 4 prompts from Kotlin code, wire `ExplanationDepth`, and add provenance/token metadata.)*

- **Files Expected to Change**:
  - `prompts/registry.yaml` *(new)*, `prompts/shared/deni-persona-spec.yaml` *(new)*, `prompts/schemas/*.schema.json` *(new)*
  - `prompts/local/enprive-policy-local-nano4-v1-0-0.json` *(new)* & `prompts/local/enprive-deni-local-nano4-v1-0-0.json` *(new)*
  - `android/app/src/main/assets/prompts/local/` *(new asset bundle)*
  - `android/app/src/main/kotlin/com/example/enprive/ai/LocalPromptRegistry.kt` *(new modular helper)*
  - `android/app/src/main/kotlin/com/example/enprive/MainActivity.kt` (load local prompts via `LocalPromptRegistry`, pass `systemInstruction` cleanly instead of string concatenation, call `countTokens()` for Nano ceiling check, attach `UsageMetadata` + `promptId` + `promptVersion` + `latencyMs` to result map)
  - `lib/services/platform/hybrid_ai_bridge.dart` (forward `explanationDepth` parameter; parse `promptId`, `promptVersion`, `modelVersion`, `latencyMs`, `tokenUsage`)
  - `lib/domain/review/review_models.dart`, `lib/domain/review/review_coordinator.dart`, `lib/services/storage/receipt_repository.dart` (persist prompt metadata & add `evidenceIds`, `sourceReference` spans, `reviewTimestamp` to findings safely with backward-compatible JSON defaults)
  - `lib/main.dart` (pass `_explanationDepth.name` into `ReviewCoordinator` calls)
- **Dependencies**:
  - Existing `com.google.firebase:firebase-ai:18.2.0` (`GenerativeModel.countTokens`, `UsageMetadata`) and `org.jetbrains.kotlinx:kotlinx-coroutines-android:1.8.1`.
  - Gradle/JVM unit test task (`./gradlew testDebugUnitTest`) verifying JSON asset parsing.
- **Required Firebase Configuration**:
  - None (local prompts and schemas live inside the Git repo and Android APK assets).
- **Tests**:
  - Android Kotlin JVM unit test (`LocalPromptRegistryTest`) asserting valid JSON, semver format, placeholder completeness, and sync with `prompts/registry.yaml`.
  - Dart unit tests verifying `explanationDepth` propagates across `HybridAiBridge`, backward-compatible `PolicyReviewReceipt.fromJson()` on old SQLite rows, and population of all 9 required finding fields (`evidenceIds`, `sourceReference`, `reviewTimestamp`).
- **Acceptance Criteria**:
  - Zero raw prompt strings left hardcoded inside `MainActivity.kt` (`L414-457` retired).
  - Switching `ExplanationDepth` in Settings (`simple` / `balanced` / `detailed`) alters the instruction variable cleanly and is recorded in local receipt metadata.
  - All local analysis works 100% offline with Gemini Nano 4 using separated `systemInstruction`.
- **Rollback Procedure**:
  - Revert Kotlin asset loader PR to restore previous Kotlin constants; nullable receipt metadata columns guarantee no local SQLite database corruption.
- **Dependencies on Earlier Phases**:
  - Requires **Phase A** (`OfflineDeterministic` distinction and consent baseline).

---

### Phase C — First Cloud Template POC (`enprive-finding-explanation-cloud-v1-0-0`)
*(Smallest safe Server Prompt Template proof of concept for consented finding explanation only.)*

- **Files Expected to Change**:
  - `prompts/cloud/enprive-finding-explanation-cloud-v1-0-0.prompt` *(new canonical Dotprompt source in Git)*
  - `android/app/src/main/kotlin/com/example/enprive/ai/CloudTemplateExecutor.kt` *(new Kotlin class wrapping `Firebase.ai(backend = GenerativeBackend.googleAI(), useLimitedUseAppCheckTokens = true).templateGenerativeModel()`, executing `generateContentStream(templateId, inputs)`)*
  - `android/app/src/main/kotlin/com/example/enprive/ai/HybridInferenceRouter.kt` *(new or extracted router enforcing `cloudConsent == true && requestedMode == "ONLY_IN_CLOUD"` before calling `CloudTemplateExecutor`)*
  - `android/app/src/main/kotlin/com/example/enprive/MainActivity.kt` (route consented `explain_finding_cloud` calls to `CloudTemplateExecutor` with compiled fallback ID `"enprive-finding-explanation-cloud-v1-0-0"`, keeping local `ONLY_ON_DEVICE` `explain_finding` intact via `LocalPromptRegistry`)
  - `lib/widgets/why_this_finding_sheet.dart` & `lib/domain/review/review_coordinator.dart` (allow user on a finding card to explicitly consent to cloud-enriched Deni explanation when offline/local explanation is limited or unavailable)
- **Dependencies**:
  - Uses **`com.google.firebase:firebase-ai:18.2.0`** already declared in `android/app/build.gradle.kts` (no Flutter plugin changes needed!).
- **Required Firebase Configuration**:
  1. In Firebase Console -> **AI Services > AI Logic > Prompt templates**, create **`enprive-finding-explanation-cloud-v1-0-0`** matching the reviewed `.prompt` specification.
  2. Test inside Firebase Console interactive prompt runner using sample golden findings across EN/KO/AR/ES and `simple`/`balanced`/`detailed`.
  3. **Lock** template `enprive-finding-explanation-cloud-v1-0-0` before Android integration tests.
  4. **Explicitly leave global "Template-Only Mode" DISABLED**.
- **Tests**:
  - Android manual/instrumented integration test against `enprive-hybrid-ai` staging/dev with `useLimitedUseAppCheckTokens = true` verifying `templateGenerateContentStream`, JSON parsing, `UsageMetadata`, and clean handling of HTTP `400`/`403`/`404` errors (no silent local-or-cloud cross-routing).
  - Dart unit tests mocking channel responses verifying `CloudConsentSheet` gating before template execution, non-null `whyEvidenceMatters`, and refusal to alter canonical `exactExcerpt`.
- **Acceptance Criteria**:
  - Consented "Explain this finding in detail / in selected language" works end-to-end via `TemplateGenerativeModel` (`enprive-finding-explanation-cloud-v1-0-0`) with `InferenceSource.inCloud` provenance and App Check replay protection.
  - `ONLY_ON_DEVICE` policy scanning continues untouched and functional without network.
- **Rollback Procedure**:
  - Disable template routing via Kotlin feature flag / revert Phase C PR to fall back to Phase B `LocalPromptRegistry` + `GenerativeModel` cloud prompt. Do **not** delete locked template in Console until clients expire.
- **Dependencies on Earlier Phases**:
  - Requires **Phase A** (strict consent gate) and **Phase B** (standardized local prompts, schemas, and metadata propagation).

---

### Phase D — Controlled Firebase Remote Config Integration
*(Add server-controlled template ID switching and emergency kill-switch with strict client allowlist safety.)*

- **Files Expected to Change**:
  - `android/app/build.gradle.kts` (add `implementation("com.google.firebase:firebase-config")` under `firebase-bom:33.7.0` — explicitly **without** `firebase-analytics`)
  - `android/app/src/main/res/xml/remote_config_defaults.xml` *(new compile-time safe defaults)*
  - `android/app/src/main/kotlin/com/example/enprive/ai/RemoteConfigRegistry.kt` *(new singleton handling `setDefaultsAsync`, `minimumFetchIntervalInSeconds` [43200s release / 0s debug], non-blocking startup `fetch()`, session-boundary activation, regex validator `^enprive-[a-z0-9-]+-v\d+-\d+-\d+$` [`<= 63` chars], and kill-switch `remote_prompt_templates_enabled`)*
  - `android/app/src/main/kotlin/com/example/enprive/ai/HybridInferenceRouter.kt` & `MainActivity.kt` (read template ID + kill-switch from `RemoteConfigRegistry`, inject `prompt_registry_version` metadata into results)
- **Dependencies**:
  - `com.google.firebase:firebase-config` (resolved cleanly by `firebase-bom:33.7.0`; verify Gradle sync on CI).
- **Required Firebase Configuration**:
  - Publish initial Remote Config parameters in Firebase Console (`enprive-hybrid-ai`):
    - `finding_explanation_template_id`: `"enprive-finding-explanation-cloud-v1-0-0"`
    - `deni_template_id`: `""` (empty until Phase E)
    - `translation_passage_template_id`: `""` (empty until Phase F)
    - `translation_explanation_template_id`: `""` (empty until Phase F)
    - `policy_cloud_template_id`: `""` (empty until cloud analysis template promotion)
    - `remote_prompt_templates_enabled`: `true`
    - `prompt_registry_version`: `"2026.11.v1"`
- **Tests**:
  - Kotlin unit tests for `RemoteConfigRegistry` verifying:
    - Regex validator rejects malformed template IDs (underscores, uppercase, `>63` chars, SQL/path chars, empty strings) and restores safe default ID.
    - When `remote_prompt_templates_enabled == false`, cloud template route stops or uses safe non-template fallback cleanly without ever suppressing consent checks.
    - Activation waits cleanly until session boundary instead of mutating mid-review.
    - Offline startup uses XML defaults cleanly within `< 10ms`.
- **Acceptance Criteria**:
  - Swapping `finding_explanation_template_id` from `...-v1-0-0` to `...-v1-0-1` in Console takes effect on next session launch with zero APK rebuild.
  - Flipping `remote_prompt_templates_enabled = false` shuts off remote template invocation safely.
  - Zero Analytics SDK added; zero PII or secrets in Remote Config.
- **Rollback Procedure**:
  - **1-Minute Server Rollback**: Open Firebase Console -> **Remote Config > Change History -> Roll back** to prior version (or flip `remote_prompt_templates_enabled = false`), bypassing app store release cycles.
  - **Code Rollback**: Revert Phase D PR and remove `firebase-config` Gradle dependency.
- **Dependencies on Earlier Phases**:
  - Requires **Phase C** (`CloudTemplateExecutor` and at least one live server prompt template).

---

### Phase E — Deni Companion Template Integration
*(Upgrade Deni from 3 static single-turn chips to bounded multi-turn `TemplateChat` under explicit cloud consent while keeping local 1-turn Nano 4 intact.)*

- **Files Expected to Change**:
  - `prompts/cloud/enprive-deni-companion-cloud-v1-0-0.prompt` *(new)*
  - `prompts/shared/deni-persona-spec.yaml` (expand with conversational turn rules)
  - `android/app/src/main/res/xml/remote_config_defaults.xml` (add `deni_template_id` default)
  - `android/app/src/main/kotlin/com/example/enprive/ai/CloudTemplateExecutor.kt` & `MainActivity.kt` (manage bounded ephemeral session `TemplateChat` history in memory keyed by review ID, calling `TemplateGenerativeModel.startChat(templateId, inputs, history)`)
  - `lib/services/platform/hybrid_ai_bridge.dart`, `lib/domain/review/review_coordinator.dart` (new `askDeniFollowUp` method checking `cloudConsent`, validating `referencedFindingIds` defensively against current `PolicyReviewReceipt` findings)
  - `lib/widgets/why_this_finding_sheet.dart` (add optional free-form question input gated behind explicit cloud consent when multi-turn chat is requested; preserve 1-tap offline chips)
- **Dependencies**:
  - `TemplateChat` & `TemplateGenerativeModel.startChat` in `firebase-ai:18.2.0` (verified in SDK bytecode).
- **Required Firebase Configuration**:
  - Create, stage-test, and **lock** `enprive-deni-companion-cloud-v1-0-0` in Firebase Console.
  - Update Remote Config `deni_template_id` -> `"enprive-deni-companion-cloud-v1-0-0"`.
- **Tests**:
  - Dart tests asserting Deni cannot add new `VerifiedFinding` records, alter `overallState`, invent unverified `referencedFindingIds` (validator strips unknown IDs), or receive app inventory / sibling receipts.
  - Behavioral eval across shared local + cloud Deni fixtures ensuring identical non-certification guarantees and matched `ExplanationDepth`.
- **Acceptance Criteria**:
  - Parents/educators can ask free-form follow-up questions about the open review under explicit cloud consent with accurate citations to existing findings and clear uncertainty statements.
  - Local 1-turn Nano 4 chips continue working offline without `TemplateChat`.
- **Rollback Procedure**:
  - Clear `deni_template_id` / revert Remote Config version to hide multi-turn template channel or fall back cleanly to Phase B/C 1-turn Q&A.
- **Dependencies on Earlier Phases**:
  - Requires **Phase B** (`deni-persona-spec.yaml` + local Deni registry), **Phase C**, and **Phase D** (Remote Config pointer + kill-switch).

---

### Phase F — Consent-Based Cloud Translation & Policy Analysis Expansion
*(Introduce split passage-translation and explanation-translation templates—and optionally wire consented cloud `enprive-policy-analysis-cloud-v1-0-0` behind `CloudConsentSheet`.)*

- **Files Expected to Change**:
  - `prompts/cloud/enprive-translation-passage-cloud-v1-0-0.prompt` *(new)*
  - `prompts/cloud/enprive-translation-explanation-cloud-v1-0-0.prompt` *(new)*
  - `prompts/cloud/enprive-policy-analysis-cloud-v1-0-0.prompt` *(new, consented cloud policy reviews only)*
  - `android/app/src/main/res/xml/remote_config_defaults.xml` (default IDs for split translation & cloud policy templates)
  - `MainActivity.kt` / `CloudTemplateExecutor.kt`, `HybridAiBridge.dart`, `ReviewCoordinator.dart` (translation methods + derived translation storage)
  - `lib/domain/review/review_models.dart` (optional derived `TranslatedPolicyPassage` / localized `PolicyTranslationView` keeping canonical `snapshotText` and original quotes immutable)
  - `lib/screens/review_result_screen.dart` & ARB files (`app_*.arb` generated via `flutter gen-l10n`) (side-by-side original vs. machine-translation view with clear *"Machine translation — original excerpt preserved"* notice)
- **Dependencies**:
  - `TemplateGenerativeModel` (`firebase-ai:18.2.0`), `RemoteConfigRegistry`. (Note: any future offline ML Kit Translation remains separate pending `#BuildHybridAI` organizer rules per *Master Spec v3*.)
- **Required Firebase Configuration**:
  - Create, test against 12-language fixtures, and **lock** `enprive-translation-passage-cloud-v1-0-0`, `enprive-translation-explanation-cloud-v1-0-0`, and (if promoted) `enprive-policy-analysis-cloud-v1-0-0`.
  - Publish template IDs in Remote Config.
- **Tests**:
  - Cross-language fidelity tests verifying legal modal verbs (*"may"*, *"shall not"*, *"unless"*) are not dropped in `translation-passage`, canonical `PolicyReviewReceipt.snapshotText` and `VerifiedFinding.exactExcerpt` remain byte-identical before and after translation, and defensive enum normalization handles OpenAPI string responses from `policy-analysis-cloud` (`OVERALL_STATE`, `CATEGORY`, `SEVERITY`).
  - Explicit consent test confirming source text never reaches translation templates without `CloudConsentSheet` approval.
- **Acceptance Criteria**:
  - Users can view side-by-side translated policy passages and depth-adapted translated findings in all 12 Enprive languages after explicit per-check consent, with original English/source quotes intact for evidence auditability.
- **Rollback Procedure**:
  - Repoint Remote Config `translation_*_template_id` or `policy_cloud_template_id` to `""` (empty) to gracefully disable cloud translation UI entry or revert to pinned Phase B cloud `GenerativeModel` prompt while preserving all saved receipts.
- **Dependencies on Earlier Phases**:
  - Requires **Phase A–D** (and **Phase E** if translation shares Deni UI surfaces).

---

### Phase G — Automated Evaluation, CI Release Gates & Rollout Operations
*(Institutionalize repeatable 10-category evaluation, staging template REST tests, release gating, and rollback drills.)*

- **Files Expected to Change**:
  - `prompts/eval/fixtures/*.json` *(new golden fixtures spanning all 10 required categories + multilingual + injection test cases)*
  - `prompts/eval/run_eval.dart` or `tool/eval_prompts.py` *(new CI evaluation runner calling staging Firebase endpoints / Dart `EvidenceValidator` offline checks and emitting 10-metric JSON report)*
  - `.github/workflows/prompt-eval.yml` *(new CI workflow running `flutter analyze`, `flutter test`, `./gradlew testDebugUnitTest`, JSON/Dotprompt schema validation, and golden regression checks)*
  - `prompts/eval/CHANGELOG.md` *(new template promotion log tracking IDs, model versions, metric deltas, and Console lock confirmations)*
- **Dependencies**:
  - Staging Firebase AI Logic project or isolated test environment + service credentials stored strictly in CI secrets (never in Git or client code), Firebase REST API (`firebasevertexai.googleapis.com` `v1beta`), and Dart test harness.
- **Required Firebase Configuration**:
  - Separate staging vs. production template promotion checklist in Firebase Console (`roles/firebasevertexai.admin` restricted to maintainers; mandatory **Lock** step prior to updating Remote Config production template IDs).
  - Quarterly drill verifying Cloud Logging exclusion filter (`resource.type="firebasevertexai.googleapis.com/Client"`) and quota alert thresholds (`RPM`/`TPM`/`429`).
- **Tests**:
  - Automated run of all **10 test categories** verifying all **10 quantitative gates** (including `100%` privacy-routing correctness and `< 2%` unsupported claims).
  - Simulated rollback drill proving broken template ID -> regex catch -> Remote Config rollback completes in `< 5` minutes without data loss or privacy leak.
- **Acceptance Criteria**:
  - No prompt PR or Remote Config template promotion can merge without passing CI metrics against golden baselines.
  - Complete traceability from receipt `promptVersion` -> `CHANGELOG.md` -> Git `.prompt` commit -> locked Firebase Console template.
- **Rollback Procedure**:
  - CI blocks promotion automatically on metric regression; in live incidents, Remote Config Change History rollback reverts active IDs to previous locked baseline immediately while failing prompt versions stay unlocked/archived in staging.
- **Dependencies on Earlier Phases**:
  - Consolidates artifacts from **Phases A–F** (can begin building fixtures as early as Phase B and expand incrementally alongside Phases C–F).

---

## 3. Explicit Recommendations & Rejected / Deferred Alternatives

| Candidate / Alternative | Verdict | Rationale |
|---|---|---|
| **Server Prompt Templates for consented cloud tasks (`TemplateGenerativeModel` in Kotlin)** | **ADOPT WITH MODIFICATIONS** | Already present in `firebase-ai:18.2.0`; removes hardcoded cloud strings and couples safely with locked immutable IDs (`...-v1-0-0`). Requires defensive client enum normalization and strict consent gating first. |
| **Small initial POC (`enprive-finding-explanation-cloud-v1-0-0`)** | **ADOPT** | Lowest evidence risk (explains already validated findings only), directly unlocks unused `ExplanationDepth`, and validates Kotlin `TemplateGenerativeModel` end-to-end without touching core local scanning. |
| **Firebase Remote Config (`firebase-config` standalone)** | **ADOPT WITH MODIFICATIONS** | Add without `firebase-analytics` to preserve zero tracking; strictly validate IDs with allowlist regex; activate at session boundaries; keep strictly as routing pointer + kill-switch, never consent/auth. |
| **Local prompt versioning (`LocalPromptRegistry` + `prompts/local/*.json`)** | **ADOPT** | Required because Server Prompt Templates cannot run on `ONLY_ON_DEVICE` Gemini Nano 4. Gives clean Git versioning, separated `systemInstruction`, `countTokens()` routing, and CI fixtures. |
| **Split translation templates (`passage` vs. `explanation`)** | **ADOPT WITH MODIFICATIONS** | Prevents casual parent-level summarization from altering literal legal clauses or canonical `snapshotText` / `exactExcerpt` strings. |
| **Moving cloud prompts + Remote Config into Dart (`firebase_ai` + `firebase_core` + `firebase_remote_config`)** | **REJECT (now)** | Would split Firebase initialization & App Check across Kotlin and Dart while exposing `@experimental` Dart `TemplateGenerativeModel` churn—all for zero benefit while `firebase-ai:18.2.0` already runs cleanly behind Kotlin's single security gate. Reconsider only alongside a dedicated multi-platform iOS architecture decision. |
| **Enabling Firebase "Template-Only Mode" globally** | **REJECT** | Would return `403 Unauthorized` on `GenerativeModel` cloud fallback calls (`PREFER_ON_DEVICE`, non-template `ONLY_IN_CLOUD`, and future `LiveGenerativeModel`), breaking hybrid AI execution. |
| **Removing or relaxing `EvidenceValidator` because templates define `outputSchema`** | **REJECT** | `outputSchema` in Dotprompt only shapes JSON structure (and does not support enum constraints in preview). It cannot prove a quote exists verbatim in `snapshotText` or match Android `PackageManager` observations. |
| **Immediate migration of `policy-analysis` to Server Templates before Consent Gate fix** | **REJECT** | Today's `ReviewCoordinator` silently escalates long/unavailable policies with `cloudConsent: true`. Wiring cloud templates directly behind that bug would create an immediate privacy regression. |
| **`prompt_experiment_group` & Firebase Analytics A/B Testing** | **DEFER** | Unnecessary until Enprive adds an opt-in, privacy-preserving experiment framework; Remote Config server-side conditions can already stage rollouts without tracking users via `firebase-analytics`. |
| **Replacing Android `TextToSpeech` with Gemini Live API templates** | **DEFER / N/A** | Official docs confirm Server Prompt Templates **do not support Gemini Live API models**, and local Android TTS already fulfills accessible playback offline across 12 languages without cloud audio egress. |

---

## 4. Final Decision Report (Section 13 Mandatory Responses)

1. **Should Enprive adopt Firebase Server Prompt Templates?**
   - **Verdict**: **`ADOPT WITH MODIFICATIONS`**
   - **Why**: Enprive's Kotlin SDK (`com.google.firebase:firebase-ai:18.2.0`) already includes `TemplateGenerativeModel`, enabling server-side prompt iteration, model updates, and `input.schema` bounds without APK rebuilds. However, Server Prompt Templates are **Public Preview**, cloud-only, and lack enum-list schema enforcement—so adoption must strictly target consented cloud workflows behind Enprive's Kotlin security gate, keep global Template-Only mode **OFF**, exclude raw prompt payloads from Google Cloud Logging, and never replace local validation.

2. **Which AI responsibilities should use them?**
   - **Verdict**: **`ADOPT WITH MODIFICATIONS`** (Consented cloud-only workflows only)
   - **Why**: Ideal candidates are: (1) **Consented Finding Explanations** (`enprive-finding-explanation-cloud-v1-0-0`), (2) **Consented Multi-Turn Deni Q&A** (`enprive-deni-companion-cloud-v1-0-0` via `TemplateChat`), (3) **Consented Policy & Explanation Translation** (split into `enprive-translation-passage-cloud-v1-0-0` and `enprive-translation-explanation-cloud-v1-0-0`), and (4) **Explicitly Consented Cloud Policy Analysis** (`enprive-policy-analysis-cloud-v1-0-0`) *after* `CloudConsentSheet` gating is restored.

3. **Which must remain locally managed?**
   - **Verdict**: **`REJECT`** server management for on-device & deterministic trust cores; **`ADOPT`** local source-controlled management (`LocalPromptRegistry`)
   - **Why**: `ONLY_ON_DEVICE` Gemini Nano 4 prompts **cannot** execute via Server Prompt Templates and must run offline from Git-tracked Kotlin assets (`prompts/local/`). `EvidenceValidator`, `PermissionComparator`, `PiiRedactor`, Android `PackageManager` inspection, `ReceiptRepository` (SQLite), and Android `TextToSpeech` **must** remain 100% local in client code so no cloud prompt change can ever weaken evidence verification, expose installed apps, or invent safety certifications.

4. **Should Remote Config control template selection?**
   - **Verdict**: **`ADOPT WITH MODIFICATIONS`**
   - **Why**: Adopting standalone Android `firebase-config` (without `firebase-analytics`) allows safe instant rollback of immutable template IDs (`...-v1-0-0` -> `...-v1-0-1`) and an emergency cloud-template kill-switch (`remote_prompt_templates_enabled`). **Mandatory modifications**: enforce strict regex allowlist validation on every template ID, keep 12h production caching (`minimumFetchIntervalInSeconds = 43200`) with XML compile-time defaults, activate updates only at session boundaries, defer `prompt_experiment_group`, and enforce in code that Remote Config **never** acts as an authorization or consent bypass.

5. **What is the smallest safe proof of concept?**
   - **Verdict**: **`ADOPT`** — **`enprive-finding-explanation-cloud-v1-0-0`** (`WhyThisFindingSheet` consented detailed explanation)
   - **Why**: Explaining an *already locally validated finding* carries zero risk of introducing unverified claims or altering receipt verdicts, directly puts the currently unused `ExplanationDepth` preference (`simple`/`balanced`/`detailed`) into practice, exercises Kotlin's already-available `TemplateGenerativeModel` with App Check `useLimitedUseAppCheckTokens = true`, and leaves `runPolicyReview` local/hybrid flows completely untouched.

6. **What existing code should be preserved?**
   - **Verdict**: **`ADOPT`** (Preserve core trust architecture)
   - **Why**: Keep `EvidenceValidator` (`lib/domain/evidence/evidence_validator.dart`), `PermissionComparator` (`lib/domain/permissions/permission_comparator.dart`), `PiiRedactor` (`lib/domain/privacy/pii_redactor.dart`, enhanced for non-English patterns), `HybridAiBridge` (`lib/services/platform/hybrid_ai_bridge.dart`), `ReceiptRepository` & `UserPreferencesRepository` (`lib/services/storage/receipt_repository.dart`), `MainActivity.kt`'s native App Check (`useLimitedUseAppCheckTokens = true`), `OnDeviceExtension` / `ONLY_ON_DEVICE` Gemini Nano 4 integration, `PackageManager` app inspection, `TextToSpeech` voice playback, and the currently unwired `CloudConsentSheet` (`lib/widgets/cloud_consent_sheet.dart` — preserve and wire into production!).

7. **What implementation risks must be resolved first?**
   - **Verdict**: **`ADOPT`** as mandatory Phase A prerequisites (block cloud template rollout until cleared)
   - **Why**: Five observed risks must be resolved before shipping cloud templates:
     1. **Silent cloud fallback regression** in `ReviewCoordinator.runPolicyReview` (`L160-256`) & `askDeniAboutFinding` (`L441-465`) where `cloudConsent: true` bypasses `CloudConsentSheet`.
     2. **Default Google Cloud prompt/response capture** in Firebase AI Monitoring (apply `_Default` sink exclusion filter `resource.type="firebasevertexai.googleapis.com/Client"`).
     3. **Global Template-Only mode breakage risk** (verify project keeps it **OFF** while hybrid `GenerativeModel` calls exist).
     4. **Deterministic offline fallback mislabeling** (`buildDeterministicLocalReceipt` currently emits `InferenceSource.onDevice` instead of a distinct `offlineDeterministic` provenance).
     5. **Lack of server-side enum constraints** in Preview Server Prompt Templates and currently unused `ExplanationDepth` wiring (ensure defensive normalization in Dart `ReviewCoordinator` and pass depth explicitly).
