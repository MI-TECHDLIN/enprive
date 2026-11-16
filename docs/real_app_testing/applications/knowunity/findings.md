# Knowunity (`de.knowunity.app`) — Privacy & Compatibility Findings

## 1. Device Permission & Identity Observations

1. **Broad Manifest Footprint vs. Runtime Status (`33` declared / `24` granted)**:
   - Play Store listing (`Knowunity: AI Revision App`) explicitly displays **`Contains ads · In-app purchases`** ([`05_playstore_listing.png`](screenshots/05_playstore_listing.png)).
   - Android granted ad-tech permissions at install (`AD_ID`, `ACCESS_ADSERVICES_AD_ID`, `ACCESS_ADSERVICES_TOPICS`, `ACCESS_ADSERVICES_CUSTOM_AUDIENCE`), plus `DETECT_SCREEN_CAPTURE` and `FOREGROUND_SERVICE_MICROPHONE`.
   - High-risk runtime permissions (`ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION`, `CAMERA`, `RECORD_AUDIO`, `READ_CONTACTS`, `WRITE_CONTACTS`, `READ_PHONE_STATE`, `BLUETOOTH_CONNECT`, `POST_NOTIFICATIONS`) remained **not granted** on `RMX5303`.
2. **Corporate & Policy Identity Alignment**:
   - Play Store `App support` identifies **`Knowunity GmbH`** (`Rosenstr. 16, 10178 Berlin`, `support-de@knowunity.com`).
   - `https://knowunity.com/legal/privacy` (verified live in Chrome, last updated `02/12/2026`) covers **`Knowunity Inc.`** (US) and links **`https://knowunity.de/legal/privacy`** (`Knowunity GmbH`), specifically calling out Section 13 for users under age 13 (*"Children"*).

---

## 2. Enprive Integration & UX Observations on Knowunity

1. **System Text-Selection Discoverability Gap (`5D`)**:
   - Enprive's Home card tells users: *"Highlight terms in any app and tap Enprive Check from Android’s menu."* (`app_en.arb:55`).
   - On Android 15 Chrome (`07b_process_text_menu.png`), the menu entry is labeled lowercase **`enprive`** (`AndroidManifest.xml:5`) rather than `"Enprive Check"` and is hidden inside the **`⋮` overflow menu** behind `Copy | Select all | Web search | Share`.
2. **UI Layout Clipping (`02_knowunity_permissions.png`)**:
   - On `ReviewResultScreen`, the Android gesture navigation pill overlaps the bottom `Knowunity · de.knowunity.app` inspection card while scrolling.
3. **Unverified Pending Flows**:
   - Live Enprive intake/analysis of `https://knowunity.com/legal/privacy` (`5B`, `5C`, `5D` submit, and `5F` policy comparison against the `33`/`24` permission snapshot) remains **NOT EXECUTED** pending USB reconnection.
