# Transave (`com.transave.mobileapp`) — Test Report

> [!NOTE]
> **Execution Status**: **PRE-FLIGHT ONLY — LIVE FLOWS NOT EXECUTED (USB DISCONNECTED AT `19:31:36`)**. Pre-flight ADB package/permission dumps were verified on physical `RMX5303`. Launching `com.transave.mobileapp`, checking public pre-login / Play Store privacy policy links (without entering any personal credentials or banking data), and running Journeys `5A`–`5F` remain queued upon USB reconnection.

---

## 1. Pre-Flight Application Metadata (`RMX5303`)

| Field | Observed Value (`dumpsys package`) |
|---|---|
| **Package Name** | `com.transave.mobileapp` |
| **Launch Activity** | `com.transave.mobileapp/.MainActivity` |
| **Installed Version** | `1.0.73` (`versionCode=38`) |
| **SDK Targets** | `minSdk=32`, `targetSdk=36` |
| **Installer** | `com.android.vending` |
| **First Install / Last Update** | `2026-09-11 23:59:45` / `2026-11-15 18:02:51` |

---

## 2. Journey Execution Matrix

| Journey | Status | Details |
|---|---|---|
| **5A — Policy Discovery** | **NOT EXECUTED** | Interrupted by USB disconnect before launching `com.transave.mobileapp/.MainActivity` (requires checking pre-auth screen & Play Store `App support` without credential login) |
| **5B — URL Retrieval & Enprive Analysis** | **NOT EXECUTED** | Pending public financial privacy-policy discovery |
| **5C — Share Integration (`ACTION_SEND`)** | **NOT EXECUTED** | Pending USB reconnection |
| **5D — In-App Text Selection** | **NOT EXECUTED** | Pending USB reconnection |
| **5F — Enprive App Picker & Comparison** | **NOT EXECUTED** | Live Enprive permission inspection UI for `com.transave.mobileapp` not yet captured |
