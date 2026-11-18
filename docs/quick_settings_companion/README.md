# Enprive Quick Settings Companion — Implementation Index (`docs/quick_settings_companion`)

- **Branch:** `feature/m3-expressive-rebrand`
- **Baseline Commit:** `b8c2169` (`fix(reliability,release): remediate D1-D4 real-device defects and add RMX5303 validation report (Iterations 31-32)`)
- **Working Tree Condition:** Clean baseline at `b8c2169` prior to QS-1..QS-4 implementation; uncommitted Quick Settings Companion native, Dart, test, and documentation changes ready for review without commit/push/merge.
- **Target Android Scope:** Android 15 (SDK 35) primary hardware (`Realme RMX5303`, `arm64-v8a`), compiled against `compileSdk = 36` / `targetSdk = 36` / `minSdk = 26`.
- **Supplementary Verification Device:** Google `Pixel_9` (`sdk_gphone64_arm64`, Android 16 SDK 36, `arm64-v8a`).
- **Physical RMX5303 Hardware Status:** **EXECUTED & VERIFIED** on connected Realme `RMX5303` (`007446c410310e84`, Android 15 SDK 35) across Quick Settings onboarding, Usage Access Settings routing/revocation, live `Enprive Check` invocations over **Math Makers**, **Knowunity**, **Quizlet**, and **Transave**, fixed `DEVICE_OBSERVED` quote filtering, single-instance task reuse, `D1` Chrome share flow, and zero Accessibility/Overlay permissions (see exact boundaries in [physical_device_validation.md](./physical_device_validation.md)).

## Deliverables in This Folder

| Document | Focus |
|---|---|
| [architecture.md](./architecture.md) | Native `TileService`, `ForegroundAppResolver`, `AppPackageInspector`, `com.enprive/companion` channel, cold/warm singleTop routing, and reuse of Enprive Deni/M3E components |
| [permission_and_data_flow.md](./permission_and_data_flow.md) | Manifest declarations, Usage Access AppOps flow, PackageManager separation (`granted` / `denied` / `unavailable` / `manifestDeclaredOnly`), and cloud zero-leakage guarantees |
| [dependency_decisions.md](./dependency_decisions.md) | Stack audit and explicit rationale for rejecting `quick_settings`, `usage_stats`, voice packages, overlay/accessibility libraries, and implementing natively in Kotlin |
| [implementation_report.md](./implementation_report.md) | Exact modified/added file manifest, P1 evidence-classification hardening fixes, build/sign posture (`debug`, `profile`, `release`), cold-start splash fix, and open limitations |
| [test_matrix.md](./test_matrix.md) | Full mapping of Kotlin JUnit cases and Flutter domain/widget/hardening E2E cases |
| [physical_device_validation.md](./physical_device_validation.md) | Physical Realme `RMX5303` (`007446c410310e84`) test report, curated 15-screenshot evidence inventory & boundaries + supplementary `Pixel_9` AVD results |
| [native_permission_dialog_qa_strategy.md](./native_permission_dialog_qa_strategy.md) | Isolated helper-APK protocol (`dev.enprive.qa.permissionprobe`) for safely validating live Android OS permission modals without polluting production manifest permissions |
