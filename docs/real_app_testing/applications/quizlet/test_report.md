# Quizlet (`com.quizlet.quizletandroid`) — Test Report

> [!NOTE]
> **Execution Status**: **PRE-FLIGHT ONLY — LIVE FLOWS NOT EXECUTED (USB DISCONNECTED AT `19:31:36`)**. Pre-flight ADB package/permission dumps and Play Protect scan presence were verified on physical `RMX5303`; launching Quizlet, discovering its privacy policy URL, and running Journeys `5A`–`5F` remain queued upon USB reconnection.

---

## 1. Pre-Flight Application Metadata (`RMX5303`)

| Field | Observed Value (`dumpsys package`) |
|---|---|
| **Package Name** | `com.quizlet.quizletandroid` |
| **Launch Activity** | `com.quizlet.quizletandroid/.ui.RootActivity` |
| **Installed Version** | `10.60` (`versionCode=2601827`) |
| **SDK Targets** | `minSdk=32`, `targetSdk=36` |
| **Installer / First Install** | `com.android.vending` / `2026-11-15 19:41:43` |
| **Play Protect Scan** | Listed under `Recently scanned apps` with zero warnings ([`play_protect_rmx5303.png`](../../screenshots/play_protect_rmx5303.png)) |
| **Android Sharesheet Entry** | Visible as `Quizlet (Open Quizlet)` in `12_sharesheet_with_enprive.png` |

---

## 2. Journey Execution Matrix

| Journey | Status | Details |
|---|---|---|
| **5A — Policy Discovery** | **NOT EXECUTED** | Interrupted by USB disconnect before launching `com.quizlet.quizletandroid/.ui.RootActivity` |
| **5B — URL Retrieval & Enprive Analysis** | **NOT EXECUTED** | Pending official policy URL verification on device |
| **5C — Share Integration (`ACTION_SEND`)** | **NOT EXECUTED** | Blocked by both USB disconnect and known Chrome link-share bug [Defect 1] |
| **5D — In-App Text Selection** | **NOT EXECUTED** | Pending USB reconnection |
| **5F — Enprive App Picker & Comparison** | **NOT EXECUTED** | Live Enprive permission inspection for `com.quizlet.quizletandroid` not yet captured |
