# Knowunity (`de.knowunity.app`) — Test Report

> [!NOTE]
> **Execution Status**: **PARTIAL (Interrupted by physical USB disconnect at `19:31:36`)**. Permissions inspection, Play Store discovery, policy webpage load, and Chrome `ACTION_PROCESS_TEXT` menu discovery ran live on `RMX5303`; completing paragraph selection submission (`5D`), Share (`5C`), URL review (`5B`), and policy comparison (`5F`) require reconnecting `007446c410310e84`.

---

## 1. Application Metadata & Device Permissions (`RMX5303`)

| Field | Observed Value |
|---|---|
| **Display Name** | `Knowunity` |
| **Package Name** | `de.knowunity.app` |
| **Installed Version** | `6.44.4` (`versionCode=130915421`) |
| **Installer / First Install** | `com.android.vending` / `2026-07-31 03:10:06` |
| **Developer Support / Address** | `Knowunity GmbH`, `Rosenstr. 16, 10178 Berlin`, `support-de@knowunity.com` ([`05b_playstore_app_support.png`](screenshots/05b_playstore_app_support.png)) |
| **Official Policy URL** | `https://knowunity.com/legal/privacy` (Updated `02/12/2026`; EEA `https://knowunity.de/legal/privacy`) |
| **Declared / Granted Perms** | **`33` declared / `24` granted** ([`02_knowunity_permissions.png`](screenshots/02_knowunity_permissions.png)) |
| **Runtime Perms (`all granted=false`)** | `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`, `CAMERA`, `RECORD_AUDIO`, `READ_CONTACTS`, `WRITE_CONTACTS`, `READ_PHONE_STATE`, `BLUETOOTH_CONNECT`, `POST_NOTIFICATIONS` |
| **Install Perms (`granted=true` subset)** | `AD_ID`, `ACCESS_ADSERVICES_AD_ID`, `ACCESS_ADSERVICES_TOPICS`, `ACCESS_ADSERVICES_CUSTOM_AUDIENCE`, `DETECT_SCREEN_CAPTURE`, `FOREGROUND_SERVICE_MICROPHONE`, `USE_BIOMETRIC`, `USE_FINGERPRINT`, `INTERNET`, `BILLING` |

---

## 2. Journeys Executed & Status

### Journey 5F (Part 1) — Picker & Local Permission Inspection (`PASS`, Attach Pending)
- Picked `Knowunity` in `Check an app` ([`01_knowunity_in_picker.png`](screenshots/01_knowunity_in_picker.png)) → inspected `33 declared / 24 granted` permissions cleanly locally ([`02_knowunity_permissions.png`](screenshots/02_knowunity_permissions.png)), showing `Precise GPS Location · Not granted`, `Mic · Not granted`, `Camera · Not granted`, `Contacts · Not granted`, `AD_ID · Granted`.
- **Policy attachment & mismatch comparison (`5F` Part 2)**: **NOT EXECUTED** *(USB disconnect)*.

### Journey 5A — Real Privacy Policy Discovery (`PASS`)
- Launched `de.knowunity.app`: landing carousel shows `Log In`, `Create new account`, and a small bottom `Privacy Policy` link ([`03_knowunity_launch.png`](screenshots/03_knowunity_launch.png)).
- On subsequent login / country-picker screens ([`04_knowunity_login_options.png`](screenshots/04_knowunity_login_options.png), [`04_knowunity_signup_screen.png`](screenshots/04_knowunity_signup_screen.png)), no direct policy link appears.
- Opened Play Store via `market://details?id=de.knowunity.app` ([`05_playstore_listing.png`](screenshots/05_playstore_listing.png)) → expanded `App support` ([`05b_playstore_app_support.png`](screenshots/05b_playstore_app_support.png)) → tapped `Privacy policy` → Chrome opened `https://knowunity.com/legal/privacy` ([`06_knowunity_privacy_browser.png`](screenshots/06_knowunity_privacy_browser.png)).

### Journey 5D — Chrome `ACTION_PROCESS_TEXT` Integration (`IN PROGRESS / INTERRUPTED`)
- Highlighted text on `https://knowunity.com/legal/privacy` in Chrome → opened floating selection overflow `⋮` → confirmed Enprive appears labeled lowercase **`enprive`** inside `⋮` ([`07b_process_text_menu.png`](screenshots/07b_process_text_menu.png)).
- Re-selected `"value"` ([`07_text_selection.png`](screenshots/07_text_selection.png)); physical USB disconnected right as handle drag to paragraph bounds started. (Note: [`08_enprive_selected_excerpt.png`](screenshots/08_enprive_selected_excerpt.png) captured the Chrome page prior to modal entry.)

### Journeys 5B & 5C — URL Review & Share Integration (`NOT EXECUTED`)
- Submitting `https://knowunity.com/legal/privacy` in Enprive (`5B`) and testing Chrome `Share` (`5C` text vs URL) were **NOT EXECUTED** due to the `19:31:36` USB disconnect.

---

## 3. Evidence Inventory (`11` Screenshots)

[`01_knowunity_in_picker.png`](screenshots/01_knowunity_in_picker.png), [`02_knowunity_permissions.png`](screenshots/02_knowunity_permissions.png), [`03_knowunity_launch.png`](screenshots/03_knowunity_launch.png), [`04_knowunity_signup_screen.png`](screenshots/04_knowunity_signup_screen.png), [`04_knowunity_login_options.png`](screenshots/04_knowunity_login_options.png), [`05_playstore_listing.png`](screenshots/05_playstore_listing.png), [`05b_playstore_app_support.png`](screenshots/05b_playstore_app_support.png), [`06_knowunity_privacy_browser.png`](screenshots/06_knowunity_privacy_browser.png), [`07_text_selection.png`](screenshots/07_text_selection.png), [`07b_process_text_menu.png`](screenshots/07b_process_text_menu.png), [`08_enprive_selected_excerpt.png`](screenshots/08_enprive_selected_excerpt.png) *(pre-selection Chrome state)*.
