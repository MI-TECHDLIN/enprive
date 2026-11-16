# Math Makers (`com.ululab.numbers`) — Privacy & Validation Findings

## 1. Substantive Policy Disclosures Verified (`https://ululab.com/privacy-policy/`)

From the retrieved live snapshot (`SHA-256: c0f2da890ce17163757d6c54ede8b665da3c3ba0fa2fe894fc750ff86e3aa956`, `enp_ul_src.xml`):

1. **Third-Party Ad Attribution & Parent Advertising ID**:
   - Explicitly states `Android Advertising ID` is collected from adults and *"A third party attribution platform called AppsFlyer collects the Android Advertising ID in order to understand which ads shown to parents led to registered users."*
   - States on app launch: IP address is sent to **AppsFlyer** (`Strict Mode`) and shared with **Meta**, alongside **Google Analytics for Firebase** (hashed email on registration, session/device/geography metrics, Unique Player IDs).
   - **OS Permission Alignment**: Matches Android `PackageManager` grants (`AD_ID`, `ACCESS_ADSERVICES_AD_ID`, `ACCESS_ADSERVICES_ATTRIBUTION` granted at install).
2. **Backend & Analytics Subprocessors**: Uses Microsoft Azure, PlayFab, RevenueCat, Amazon Web Services, ActiveCampaign, SurveyMonkey, Google Network / Facebook Pixel (website), and Unity analytics/privacy controls.
3. **Child Data / Creative Mode**: Discloses COPPA/FERPA/GDPR compliance and `kidSAFE Seal Program`; child gameplay collects `Unique PlayerID`, progress, achievements, and **Creative Mode levels** saved on Ululab servers (*"may be shared publicly if they choose"*). Student school accounts retain data up to `90 days` post-termination.
4. **Approximate Location via Masked IP**: Explicitly states *"A masked IP address (with the fourth part hidden) is collected to infer an imprecise location."* APK declares **zero** Android location permissions (`ACCESS_FINE_LOCATION` / `ACCESS_COARSE_LOCATION` absent).

---

## 2. Enprive Defect Findings on Math Makers

### Defect 1 — Chrome Share Fails on Preview PNG (`HIGH`)
- **Location**: [`MainActivity.kt#L165-L189`](../../../../android/app/src/main/kotlin/com/example/enprive/MainActivity.kt#L165-L189)
- **Observed Behavior**: Sharing `https://ululab.com/privacy-policy/` from Chrome to `enprive` fails with `Insufficient evidence` (`Unsupported document format (image/png)` / `unsupportedMime`, [`13_enprive_received_share.png`](screenshots/13_enprive_received_share.png)) because `readStreamUri(incomingIntent)` reads Chrome's screenshot thumbnail `clipData` before checking `text/plain` `EXTRA_TEXT`.

### Defect 2 — `ONLY_IN_CLOUD` Stalls Without Timeout & Contradictory Progress Copy (`HIGH`)
- **Location**: [`MainActivity.kt#L830`](../../../../android/app/src/main/kotlin/com/example/enprive/MainActivity.kt#L830), [`review_progress_sheet.dart#L144`](../../../../lib/widgets/review_progress_sheet.dart#L144), [`android/local.properties`](../../../../android/local.properties)
- **Observed Behavior**: Without `APP_CHECK_DEBUG_TOKEN` registered, tapping `Use cloud for this check` hung at `0%`, displaying `"Reviewing on this phone…"` alongside `"Streaming reasoning via App Check · 3 of 4"` before eventually falling back (`4 steps`, [`15b_cloud_hang_defect.png`](screenshots/15b_cloud_hang_defect.png)) without a clear cloud-fallback banner or user Cancel action.

### Defect 3 — Deterministic Scanner Negation Blindness & Severity Overclaim (`MEDIUM`)
- **Location**: [`review_coordinator.dart#L1022-L1075`](../../../../lib/domain/review/review_coordinator.dart#L1022-L1075)
- **Observed Behavior (`15_ululab_review_result.png` & `19_mathmakers_combined_review.png`)**:
  - **Finding 01 (False Positive)**: Quoted *"Our services do not include any third party advertising."* verbatim and labeled it **`"Shares ad IDs with external partners"`** because `isNegatedReassurance` only excludes `'do not integrate third-party advertising'`.
  - **Finding 03 (False Positive / Overclaim)**: Quoted *"A masked IP address (with the fourth part hidden) is collected to infer an imprecise location."* and flagged it **High (`Review recommended`)** as **`"Tracks location even in the background — The app can read your child’s exact GPS location even when it isn’t open on screen."`** — contradicting both the policy clause and the APK manifest (zero location permissions).
  - **Finding 07**: Flagged *"Ululab will not sell or lease any student data for any advertising..."* for the same `'advertising'` substring trigger without checking `'will not sell or lease'`.
