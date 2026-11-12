# AGENTS.md — Enprive Agent Collaboration Guidelines

This document governs engineering journal tracking, model selection, workflow routing, and project-specific constraints for AI agents, subagents, and human collaborators working on the **Enprive** codebase.

---

## 0. Primary Protocol: Engineering Journal (`journal.md`)

`journal.md` at the repository root is the **primary source of truth** for iteration history, architectural decisions, debugging root causes, and next steps.

1. **Before Every Iteration (Mandatory Read)**:
   - Always read [journal.md](journal.md) **before** starting any task, creating a branch, or writing code.
   - Verify the current `main` HEAD, active feature branch, past challenges/fixes, and queued milestones.
2. **After Every Iteration (Mandatory Update)**:
   - Immediately **after** completing an iteration (and before opening a PR, merging, or switching models), record a new entry in [journal.md](journal.md) containing:
     - Date, Iteration number, branch name, and commit hash(es).
     - Active model(s) used.
     - Summary of what was built or modified.
     - Challenges encountered and their exact root-cause fixes.
     - Verification status (`flutter analyze`, `flutter test`, Gradle build).
     - Updated next-step queue and recommended model for the next turn.

---

## 1. Model Selection & Workflow Routing

### Heavy Implementation & Deep Agentic Work (Maximum Iteration)
- **Use Cases**:
  - Writing core architecture, services, and complex widgets.
  - End-to-end feature implementations spanning Dart and native Android Kotlin.
  - High-iteration autonomous debugging, architectural reviews, and multi-file refactoring.
- **Assigned Models**:
  - **Gemini 4 Argon**
  - **Claude Opus 5.5**
- **Action**: Whenever an agent is about to perform heavy code writing or high-iteration agentic tasks, ensure the active model is set to **Argon** or **Opus 5.5**, or explicitly ping the user to switch before proceeding.

### Bug Fixes, Configuration & Mechanical Tasks
- **Use Cases**:
  - Isolated bug fixes, lint/analyzer repairs, test-fix loops.
  - Gradle, Firebase, environment, and build script configurations.
  - Documentation, ARB localization keys, and metadata maintenance.
- **Assigned Models & Tools**:
  - **Devin CLI**
  - **Gemini Flash** (e.g. Gemini 3.8 Flash)
  - **Gemini Hydrogen**
  - **Claude Sonnet** (e.g. 3.5 / 3.7 Sonnet)

### Delegating to Devin CLI
For mechanical, high-volume, or repetitive tasks (e.g. bulk renames, syntax migrations, test-fix loops):
```bash
devin -p "<precise task + acceptance check>" --model <SWE model>
```
- Always execute from the repository root on a clean feature branch.
- Inspect `git diff` and verify passing tests (`flutter analyze` & `flutter test`) before accepting changes.

---

## 2. Branching & Git Discipline

1. **Feature Branches Only**:
   - Every new feature, native bridge change, or UI addition MUST have its own dedicated branch:
     `feature/<feature-name>`
   - Never commit directly to `main`.
2. **Clean Pull Requests**:
   - Before merging, verify `flutter analyze` reports 0 issues and `flutter test` passes 100%.
3. **Protected / Uncommitted Assets**:
   - Never stage or commit `mobile ui and ux inspration/` (kept in `.gitignore` for IP/licensing protection).
   - Never commit real App Check production secrets or private keystores.

---

## 3. Product & Architectural Guardrails (#BuildHybridAI 2026)

1. **Privacy First (Local Inspection)**:
   - Android package inspection and permission queries (`inspectSelectedApp`) are strictly executed on-device.
   - Package lists and device permissions must **never** be passed to cloud endpoints or generative model prompts.
2. **Explicit Cloud Consent**:
   - Privacy analysis defaults strictly to `ONLY_ON_DEVICE` (Gemini Nano).
   - Cloud analysis requires explicit, per-request consent from the user. Without consent, network calls are blocked.
3. **Firebase AI Logic Models**:
   - All generative AI requests in the competition must use Firebase AI Logic.
   - Use current supported models (e.g., on-device Gemini Nano 4, cloud `gemini-2.5-flash` / Gemini 3+). Older Gemini 1.x models are prohibited.
   - Always enforce App Check replay protection on Android (`useLimitedUseAppCheckTokens = true`).
4. **Calibrated Evidence-Based Copy**:
   - Never present a binary "Safe" certification.
   - Always display calibrated copy: *"No concern identified in the reviewed evidence. This is not a safety certification."*
   - Findings must be backed by deterministic quotation matching against the source snapshot (`EvidenceValidator`).
5. **Mascot (Deni)**:
   - Approved Mascot: **Concept C (The Protective Pebble with Paper Tab)**.
   - Must remain smoothly animated (breathing, blinking, squish on tap) and respect `disableAnimations` for reduced-motion accessibility.
   - **Mandatory Skill Reference**: Always reference `.agents/skills/svg-mascot-animator/SKILL.md` (and its `references/creative-directions.md`, `references/rigging.md`, and `references/physics.md`) plus `.agents/skills/mobile-app-ui-design/SKILL.md` whenever creating, refining, or expanding Deni's 6-state animations and action choreography (grounded bottom-centre pivot, area-preserving squash/stretch `squash(sy, 0.55)`, 6–10% phase-lagged secondary motion on the paper tab, damped spring transitions `ζ = 0.32`, and story-driven state actions).
