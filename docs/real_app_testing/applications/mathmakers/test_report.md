# Math Makers (`com.ululab.numbers`) — Test Report

## 1. Application Metadata & Device Permissions (`RMX5303`)

| Field | Observed Value |
|---|---|
| **Display Name** | `Math Makers` |
| **Package Name** | `com.ululab.numbers` |
| **Installed Version** | `01.30.00` (`versionCode=13000003`) |
| **Installer / Source** | `com.android.vending` (`firstInstallTime=2026-11-15 19:43:27`) |
| **Official Policy URL** | `https://ululab.com/privacy-policy/` (Updated `10/09/2024`; names `Math Makers, Slice Fractions series`) |
| **Declared / Granted Perms** | **`17` declared / `13` granted** |
| **Runtime Perms (`granted=false`)** | `CAMERA`, `POST_NOTIFICATIONS` |
| **Install Perms (`granted=true`)** | `AD_ID`, `ACCESS_ADSERVICES_AD_ID`, `ACCESS_ADSERVICES_ATTRIBUTION`, `INTERNET`, `BILLING`, `ACCESS_NETWORK_STATE`, `ACCESS_WIFI_STATE` (observed in Enprive) |
| **App Disambiguation** | Picker cleanly showed both `How Math Works` (`com.chooyan.maths`, `v1.7.0`) and `Math Makers` (`com.ululab.numbers`) with distinct native icons ([`17_mathmakers_in_picker.png`](screenshots/17_mathmakers_in_picker.png)) |

---

## 2. Journeys Executed

### Journey 5A — Real Privacy Policy Discovery (`PASS`, High UX Friction)
- **Navigation Sequence**: Launched `com.ululab.numbers` (`UnityPlayerActivity`, OpenGL canvas `01_launch.png`..`04_account_screen.png`) → `Get Started` → 4-screen interactive parent onboarding (`Watch this`, age selection, topic selection, social proof `02`..`08`) → `Create your account` ([`09_create_account_privacy_link.png`](screenshots/09_create_account_privacy_link.png)) → tapped inline `Privacy Policy` → solved COPPA `"FOR GROWN-UPS ONLY! Please enter your year of birth"` (`1985`, [`05_signin_screen.png`](screenshots/05_signin_screen.png)) → Chrome launched [`https://ululab.com/privacy-policy/`](screenshots/10_privacy_policy_browser.png).
- **Identity Establishment**: Policy text explicitly states *"the Ululab mobile applications for kids (Math Makers, Slice Fractions series)"*, matching developer Ululab (`info@ululab.com`).

### Journey 5B — URL Retrieval & Enprive Analysis (`PARTIAL PASS` — Offline **PASS**, Cloud **FAIL [D2]**)
- Pasted `https://ululab.com/privacy-policy/` into Enprive `Policy link` → Enprive retrieved live HTML and opened `CloudConsentSheet` ([`14_url_retrieval_consent_or_result.png`](screenshots/14_url_retrieval_consent_or_result.png)), masking `info@ululab.com` → `[EMAIL]` (`Masked (1)`).
- **Cloud Path (`Use cloud for this check`) — FAIL (`Defect 2`)**: Tapped primary teal CTA → Enprive returned to Home with `ReviewProgressCard` stuck at `0%, Reviewing on this phone… | ululab.com | App Check | Streaming reasoning via App Check | 3 of 4` (`enp_ululab_res.xml` at `19:04`) due to missing `APP_CHECK_DEBUG_TOKEN` and absent `withTimeout` around `generateContentStream` (`MainActivity.kt:830`), before eventually failing into `Offline local scan` (`4 steps`) at `19:06` ([`15b_cloud_hang_defect.png`](screenshots/15b_cloud_hang_defect.png)).
- **Offline Local Path (`Review on this phone`) — PASS**: Completed immediately ([`15_ululab_review_result.png`](screenshots/15_ululab_review_result.png), `2 steps`): `Review recommended`, `7 Findings / 7 Verified / 0 Unverified`, `Offline local scan`.
- **Provenance & Snapshot Hash**: Inspected via `Source` ([`16_ululab_source_provenance.png`](screenshots/16_ululab_source_provenance.png)):
  - Canonical URL: `https://ululab.com/privacy-policy/`
  - Retrieval timestamp: `Public URL (2026-11-16 18:09 UTC)` (`Reviewed · 2026-11-16 19:09` local)
  - SHA-256 source hash: `c0f2da890ce17163757d6c54ede8b665da3c3ba0fa2fe894fc750ff86e3aa956`
  - FNV-1a snapshot digest: `#5bc2f641cfdc5f60`
  - Limitation notice displayed verbatim: *"Retrieved from user-supplied URL; this does not prove app ownership of the page."*
- Saved receipt (`2` receipts badge visible on Home) and opened offline `Ask Deni` sheet on Finding 04 (AppsFlyer `Android Advertising ID`).

### Journey 5C — Share Integration from Chrome (`FAIL` — `Defect 1`)
- Tapped Chrome `Share…` on `ululab.com/privacy-policy/` → selected `enprive` in Android Sharesheet ([`12_sharesheet_with_enprive.png`](screenshots/12_sharesheet_with_enprive.png)).
- **Failure Observed ([`13_enprive_received_share.png`](screenshots/13_enprive_received_share.png))**: Chrome attached a page preview PNG (`clipData`) alongside `EXTRA_TEXT="https://ululab.com/privacy-policy/"`. `MainActivity.kt:166` checked `readStreamUri(incomingIntent)` before `EXTRA_TEXT`, so Enprive treated the share as `17948518560005596943773200990247.png` and rejected it with `Insufficient evidence` (`Unsupported document format (image/png)` / `status: unsupportedMime`), offering no one-tap fallback to paste/fetch the URL instead.

### Journey 5D — In-App Text Selection (`NOT SUPPORTED`)
- Inside `Math Makers` (`UnityPlayerActivity` OpenGL `SurfaceView`), native Android text selection (`ACTION_PROCESS_TEXT`) is **not supported**. Chrome text selection toolbar was separately confirmed ([`11_text_selection_menu.png`](screenshots/11_text_selection_menu.png)).

### Journey 5F — Installed App Inspection & Policy Comparison (`PARTIAL PASS`)
- Opened `Check an app` → searched `"Math"` → selected `Math Makers` ([`17_mathmakers_in_picker.png`](screenshots/17_mathmakers_in_picker.png)) → viewed `Device Permission Inspection` ([`18_mathmakers_permissions.png`](screenshots/18_mathmakers_permissions.png)):
  - `17 Android permissions declared (13 granted)`.
  - Displayed `Camera & Photo Capture (Not granted)`, `Google Advertising ID (AD_ID) (Granted)`, `Access Adservices Ad Id (Granted)`, `Access Adservices Attribution (Granted)`, `Access Network State (Granted)`, `Access Wifi State (Granted)`.
  - Bottom `Math Makers · com.ululab.numbers` card overlapped visually with the Android gesture navigation pill ([`18_mathmakers_permissions.png`](screenshots/18_mathmakers_permissions.png)).
- Attached `https://ululab.com/privacy-policy/` via `Add this app's privacy policy` → `Review on this phone` → [`19_mathmakers_combined_review.png`](screenshots/19_mathmakers_combined_review.png) updated to `Offline local scan` + `Review recommended` with Findings `01`–`04` visible (note: full scroll below Finding `07` to verify the bottom permission-comparison cards was not completed before moving to Knowunity).

---

## 3. Evidence Inventory (`22` Screenshots)

[`01_launch.png`](screenshots/01_launch.png), [`02_get_started.png`](screenshots/02_get_started.png), [`03_onboarding_next.png`](screenshots/03_onboarding_next.png), [`03b_step.png`](screenshots/03b_step.png), [`04_account_screen.png`](screenshots/04_account_screen.png), [`05_signin_screen.png`](screenshots/05_signin_screen.png), [`06_after_age.png`](screenshots/06_after_age.png), [`07_parent_gate_or_terms.png`](screenshots/07_parent_gate_or_terms.png), [`08_legal_links.png`](screenshots/08_legal_links.png), [`09_create_account_privacy_link.png`](screenshots/09_create_account_privacy_link.png), [`10_privacy_policy_browser.png`](screenshots/10_privacy_policy_browser.png), [`11_text_selection_menu.png`](screenshots/11_text_selection_menu.png), [`11b_process_text_overflow.png`](screenshots/11b_process_text_overflow.png), [`12_sharesheet_with_enprive.png`](screenshots/12_sharesheet_with_enprive.png), [`13_enprive_received_share.png`](screenshots/13_enprive_received_share.png), [`14_url_retrieval_consent_or_result.png`](screenshots/14_url_retrieval_consent_or_result.png), [`15_ululab_review_result.png`](screenshots/15_ululab_review_result.png), [`15b_cloud_hang_defect.png`](screenshots/15b_cloud_hang_defect.png), [`16_ululab_source_provenance.png`](screenshots/16_ululab_source_provenance.png), [`17_mathmakers_in_picker.png`](screenshots/17_mathmakers_in_picker.png), [`18_mathmakers_permissions.png`](screenshots/18_mathmakers_permissions.png), [`19_mathmakers_combined_review.png`](screenshots/19_mathmakers_combined_review.png).
