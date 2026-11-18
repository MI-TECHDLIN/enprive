# Test Matrix — Enprive Quick Settings Companion & Evidence Hardening

## 1. Automated Verification Summary (Final Pre-Commit Hardening State)
- **`flutter analyze`:** **0 issues found** (`3.9s`)
- **`flutter test`:** **102 / 102 passed (`All tests passed!`)** — includes `quick_settings_companion_test.dart` (`6` tests / `9` variant executions) and `m3e_custom_cards_test.dart` (`10` tests)
- **`cd android && ./gradlew :app:testDebugUnitTest --rerun-tasks --console=plain`:** **43 / 43 passed (`0` failures, `0` skipped, `0` errors)**

---

## 2. Kotlin JVM Unit Suite (`43 / 43` Passing)

### [CompanionTileAndResolverTest.kt](../../android/app/src/test/kotlin/com/example/enprive/CompanionTileAndResolverTest.kt) (`14 / 14`)
1. Selects most recent visible foreground app from recent `UsageEvents` (`identified`, `high` confidence).
2. Excludes Enprive's own package (`com.example.enprive`) from candidate resolution.
3. Returns `usageAccessDenied` cleanly when Usage Access is missing.
4. Returns `noRecentApplication` when events are empty or beyond stale cutoff (`120s`).
5. Marks candidates older than the `30s` active window (within `120s`) as `stale` (`low` confidence) with accurate `eventAgeMillis`.
6. Returns `ambiguous` (`medium` confidence) when multiple non-transient apps resume within `8s`.
7. Skips `com.android.systemui` and `com.google.android.permissioncontroller` without discarding preinstalled user apps (`com.android.chrome`).
8. Returns `packageNotVisible` when `PackageManager` hides the newest candidate under package visibility rules.
9. Surfaces `permissionMetadataAvailable = false` when metadata is missing.
10. Rejects invalid/malformed package names before calling `PackageManager` (`invalid_package`).
11. Distinguishes `granted`, `denied`, `unavailable` (missing flags / pre-API runtime level), and `manifestDeclaredOnly` (`AD_ID`), while filtering out install-level noise (`INTERNET`).
12. Builds explicit `OPEN_COMPANION` `CompanionLaunchSpec` (`SINGLE_TOP`, `NEW_TASK`, `CLEAR_TOP`, `quick_settings`) without fabricating any foreground package extra.
13. Parses cold-start invocation extras and enforces `deviceLocked` boolean separation (`MAIN`/`SEND` ignored).
14. Deduplicates repeated `invocationId` deliveries in `InvocationTracker` while allowing distinct new taps and accurately maps `StatusBarManager` result integers.

### Existing Retained Kotlin Suites (`29 / 29`)
- `DocumentTextExtractorTest` (`4 / 4`)
- `HybridAiPolicyTest` (`17 / 17`)
- `IncomingShareRouterTest` (`8 / 8`)

---

## 3. Flutter Domain, Privacy, Evidence Hardening & Widget Tests (`102 / 102` Passing)

| Scenario | Suite | Result |
|---|---|---|
| Package-to-policy verification & separation (`sourceMatched` vs `deviceObserved`) | `quick_settings_companion_test.dart` | **Passed** |
| Zero cloud leakage & `packageName` / `READ_CONTACTS` stripping in verified Q&A | `quick_settings_companion_test.dart` | **Passed** |
| **P1 Hardening #1 — Quotation Fallback & Disclosure Distinction:** Missing disclosure returns `missingDisclosure` & empty excerpts; unrelated opening sentence never appears as `Quoted Clause:` or deterministic `'Policy quote:'`; conditional wording classifies as `ambiguousDisclosure`; verified camera clause cites verbatim `Quoted Clause:` | `quick_settings_companion_test.dart` | **Passed** |
| Cold start (`showSplashOnLaunch: true`), warm start (`onCompanionInvocation`), duplicate `invocationId` guard, permission selection, guided `"I'm not sure"`, `"Done · Return to Math Makers"` | `quick_settings_companion_test.dart` | **Passed** |
| `usageAccessDenied` fallback, `0` declared permissions (`Quiet Notes`), `CloudConsentSheet`, `TIMED_OUT`, and live `review_progress_cancel_btn` | `quick_settings_companion_test.dart` | **Passed** |
| `SettingsScreen` Quick Settings onboarding UI | `quick_settings_companion_test.dart` | **Passed** |
| **P1 Hardening #2 — Evidence Predicate & Receipt Metric Separation:** `VerifiedFinding` (`isSourceMatched`, `isDeviceObserved`, `isVerified`) and `PolicyReviewReceipt.sourceMatchedCount` strictly exclude `deviceObserved` while preserving `verifiedEvidenceCount`; `EnpriveFindingM3ECard`, `EnpriveReceiptCard`, `WhyThisFindingSheet`, and `ReviewResultScreen` render `DEVICE_OBSERVED` without policy-quote styling and display broken-out counts | `m3e_custom_cards_test.dart` (`10 / 10`) | **Passed** |
| Theme / M3E invariant | `theme_and_deni_lod_test.dart` | **Passed** |
