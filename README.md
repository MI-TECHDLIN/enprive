# Enprive

**Understand what an app's privacy policy says, and compare it with what your phone shows, without handing over your app list.**

Privacy policies are long, full of legal words, and hard to read on a phone. Yet children use new learning apps, games, and classroom tools every week. Parents and teachers are often left guessing what an app asks to collect or share.

Enprive is a calm Android privacy companion built for **Google #BuildHybridAI 2026**. It reads a policy with you, highlights the exact sentences that matter, puts them beside the permissions Android reports on your phone, and tells you plainly what is still unknown.

---

## Who it is for

- **Parents and guardians** checking an app before or after a child uses it at home.
- **Teachers and school staff** doing a quick first look at classroom and learning apps.
- **Children and young learners** exploring simple, offline privacy habits alongside an adult.

---

## What Enprive does

- **Check an installed app or any privacy policy**: Pick an app already on your phone, paste policy text, enter a public policy web link, import a local PDF, TXT, or DOCX file, or share text, a link, or a file straight from another Android app.
- **See policy text next to phone permissions**: Compare quotes from the policy against the Android permissions the app requests or is allowed to use on your phone, kept clearly separate from each other.
- **Link an app and a policy from either direction**: Start from an installed app and attach its policy, or start from a policy and link an installed app later. Enprive checks for name or App ID clues and warns you clearly when a policy may belong to a different app, while reminding you that text and web links never prove who owns a policy.
- **Ask Deni and listen aloud**: Deni, Enprive's protective pebble companion, explains individual findings in plain language and summarizes what stood out. You can read on screen, listen offline using your phone's voice, or choose an expressive cloud voice for a single check after giving consent.
- **Save receipts only when you choose**: Keep a local history of reviews on your phone in SQLite (`enprive_receipts.db`) only when you press **Save**. Nothing is saved silently in the background.
- **Learn offline with 8 illustrated lessons**: Open the Learn tab for eight short, offline lessons with custom diagrams, quick checks, and offline audio covering privacy policies, Android permissions, ads and third parties, reading Enprive's evidence, data collection, retention and deletion, unclear policies, and safe-sharing habits for kids.
- **Quick Settings Companion**: Add the **Enprive Check** tile to Android Quick Settings to check the app on screen when a permission prompt appears.

---

## What Enprive will never do

- **Never calls an app "safe", "approved", or "compliant".** When nothing concerning appears in the text reviewed, Enprive says: *"No concern identified in the reviewed evidence. This is not a safety certification."*
- **Never claims a phone permission proves data use.** An allowed permission shows what an app can access, not what it actually collects or sends.
- **Never sends anything to the cloud without asking first.** Every cloud review or expressive voice call requires your explicit, one-check-at-a-time consent.
- **Never saves a review behind your back.** Drafts stay temporary until you tap **Save**, and you are prompted before an unsaved review is discarded.
- **Never sends your installed app list or phone permissions to the cloud.** App inspection and permission comparisons happen strictly on your phone.
- **No ads, no data brokers, and no selling your review activity.**

---

## How it works

Enprive keeps four kinds of information separate so you can always see where a statement came from: **Matched in policy** (exact quote), **Seen on this phone** (local Android permission state), **Deni's explanation** (plain-language interpretation), and **Not found in policy / Still unknown**.

```text
  Policy text / URL / PDF / TXT / DOCX              Installed app permissions
                  |                                    (Android PackageManager)
                  v                                               |
   1. Try on-device AI first                                      |
      (Gemini Nano 4, ONLY_ON_DEVICE)                             |
                  |                                               |
       Available? +-- Yes --> Structured findings                 |
                  |                                               |
                 No                                               |
                  v                                               |
   2. Ask your consent (one check at a time)                      |
      - Stay offline --> Local offline clause scanner             |
      - Use cloud    --> Hide personal details locally            |
                         ([EMAIL], [PHONE], [ADDRESS],            |
                          [PERSON], [ID], [IP_ADDRESS])           |
                         Show exact text to be sent               |
                         Send once via Firebase AI Logic          |
                         + App Check limited-use token            |
                  |                                               |
                  v                                               |
   3. EvidenceValidator checks every quote word-for-word          |
      against the captured policy text                            |
      (unmatched quotes are never shown as verified)              |
                  |                                               |
                  +-------------------+---------------------------+
                                      v
                 Calm Evidence Review Screen + Document Fingerprint
                 (saved locally in SQLite only if you press Save)
```

- **On-device first, cloud only with consent**: Enprive tries on-device **Gemini Nano 4** first. If on-device AI is unavailable, it shows you a consent sheet with **Review on this phone** (offline local clause scan) as the primary choice. If you choose cloud analysis for that check, Enprive hides personal details locally first, shows you the exact text that would be sent, and sends a single request protected by **Firebase App Check** (`useLimitedUseAppCheckTokens = true`) with zero automatic retries.
- **Verified quotes only**: Every policy quote returned by a model is checked by `EvidenceValidator` against the captured policy text. Any claim whose quote does not match is downgraded instead of shown as verified.
- **Document fingerprint**: Enprive calculates a unique fingerprint from the exact text it checked (an FNV-1a 64-bit digest and a SHA-256 hash, visible under **Advanced details**). If even one letter of the policy changes later, that fingerprint changes too.

---

## Where things stand

Enprive is currently **paused while waiting for a real Gemini Nano 4 phone** for physical-device testing. Here is an honest view of what is verified today and what is still pending:

| Area | Current status |
| --- | --- |
| Core app, Calm Evidence UI, intake (Paste, URL, PDF, TXT, DOCX, Android share), two-way linking, Deni hand poses, 8 illustrated Learn lessons, Quick Settings Companion, explicit SQLite receipts | Built and merged on `main`; verified by automated suites (**391/391** Dart/Flutter tests, **75/75** Android Kotlin JVM tests, `flutter analyze` 0 issues) and live walkthroughs on the Android 16 emulator (`Pixel_9` AVD). |
| Firebase App Check (enforced on `firebaseml.googleapis.com`) | Debug App Check limited-use token minting verified on emulator with zero attestation rejections (`0` HTTP 403 errors). Production Play Integrity on a signed release build still needs a physical device. |
| On-device Gemini Nano 4 inference | Wired via Firebase AI Logic `ONLY_ON_DEVICE` (`OnDeviceModelOption.PREVIEW`), **not yet proven on physical Gemini Nano 4 hardware** (waiting for a supported phone). |
| Accessibility on a real phone | Pending (waiting for the phone to verify live TalkBack, Switch Access, and audio playback). |
| Live cloud summary (`gemini-3.8-flash`) and expressive voice (`gemini-3.8-flash-tts`) | Consent gating, local redaction, single-attempt enforcement, and offline fallback are verified. Recent free-tier (`Spark`) emulator runs hit upstream capacity limits (`503` high demand / stream timeouts) and fell back honestly to local scan and offline phone speech. |
| Translations (12 languages) | English (`en`) is complete (548 keys). AI-drafted Stage 1 translations for Arabic (`ar`), Spanish (`es`), French (`fr`), and Hindi (`hi`) are complete on `main` (548/548 keys) with an in-app draft notice in Settings while native speakers review them. Seven languages (`de`, `it`, `pt`, `ru`, `ja`, `ko`, `zh`) have 142/548 keys on `main`, with remaining stages held on separate work branches. |

---

## Try it

### Requirements

- Flutter SDK supporting Dart `^3.13.7` (see [`pubspec.yaml`](pubspec.yaml))
- Android SDK with `minSdk = 26` and JDK 17 (see [`android/app/build.gradle.kts`](android/app/build.gradle.kts))
- An Android phone (Android 8.0+) or an Android emulator

The Android application ID is `com.mitechdlin.enprive` (Kotlin package namespace `com.example.enprive`).

### Build, run, and test

```bash
# Install Dart and Flutter packages
flutter pub get

# Static analysis (expected: 0 issues)
flutter analyze

# Full Dart and Flutter unit and widget test suite
flutter test

# Native Android Kotlin JVM unit tests
( cd android && ./gradlew :app:testDebugUnitTest --console=plain )

# Run a debug build on a connected Android device or emulator
flutter run

# Build an arm64 debug APK
flutter build apk --debug --target-platform android-arm64
```

### Signing and secrets

Release signing keys (`android/key.properties`), private keystores, and Firebase App Check debug tokens are never committed to this repository. Without local signing credentials provided via `android/key.properties` or `ENPRIVE_RELEASE_*` environment variables, `flutter build apk --release` produces an unsigned artifact. If you want to test cloud calls on your own debug device against Firebase App Check, register your device's debug token locally in your Firebase Console rather than committing any token to the repo.

---

## For hackathon judges (#BuildHybridAI 2026)

A quick map of where the hybrid AI and privacy-boundary mechanics live in the codebase:

| Capability | Where to look |
| --- | --- |
| On-device Gemini Nano 4 (`ONLY_ON_DEVICE`, `OnDeviceModelOption.PREVIEW`) & hybrid routing | [`MainActivity.kt`](android/app/src/main/kotlin/com/example/enprive/MainActivity.kt), [`HybridAiPolicy.kt`](android/app/src/main/kotlin/com/example/enprive/HybridAiPolicy.kt) |
| Consented cloud analysis (`gemini-3.8-flash`), per-check consent UI & local PII redaction | [`review_coordinator.dart`](lib/domain/review/review_coordinator.dart), [`pii_redactor.dart`](lib/domain/privacy/pii_redactor.dart), [`cloud_consent_sheet.dart`](lib/widgets/cloud_consent_sheet.dart) |
| Expressive Gemini TTS (`gemini-3.8-flash-tts`, voice `Puck`) + offline Android TTS fallback | [`DeniVoicePlayer.kt`](android/app/src/main/kotlin/com/example/enprive/DeniVoicePlayer.kt), [`DeniVoicePolicy.kt`](android/app/src/main/kotlin/com/example/enprive/DeniVoicePolicy.kt), [`deni_voice_summary.dart`](lib/domain/voice/deni_voice_summary.dart) |
| Firebase App Check (`useLimitedUseAppCheckTokens = true`, debug vs Play Integrity isolation) | [`EnpriveApplication.kt`](android/app/src/main/kotlin/com/example/enprive/EnpriveApplication.kt), [debug installer](android/app/src/debug/kotlin/com/example/enprive/AppCheckProviderInstaller.kt), [release installer](android/app/src/release/kotlin/com/example/enprive/AppCheckProviderInstaller.kt) |
| Deterministic quote validation, policy sufficiency & offline clause scanner | [`evidence_validator.dart`](lib/domain/evidence/evidence_validator.dart), [`policy_sufficiency.dart`](lib/domain/review/policy_sufficiency.dart), [`deterministic_clause_scanner.dart`](lib/domain/review/deterministic_clause_scanner.dart) |
| Local-only Android permission inspection & comparison | [`AppPackageInspector.kt`](android/app/src/main/kotlin/com/example/enprive/AppPackageInspector.kt), [`permission_comparator.dart`](lib/domain/permissions/permission_comparator.dart) |
| Explicit local SQLite receipt storage | [`receipt_repository.dart`](lib/services/storage/receipt_repository.dart) |
| Full engineering history & pause checkpoint | [`journal.md`](journal.md) |

---

## Accessibility and languages

- **Readable and calm by design**: Built with Material 3 Expressive tonal surfaces in light and dark themes, bundled offline fonts (`Nunito`, `Inter`, and `Source Serif 4`, with runtime font fetching disabled), and plain-language labels across core flows.
- **Built for assistive tools**: Checked in automated tests and on an Android 16 emulator: text scaling up to 200%, reduced motion (`disableAnimations`), right-to-left (RTL) layout in Arabic, screen-reader labels, and keyboard focus. Live checks with TalkBack and Switch Access on a real phone are still pending.
- **12 languages**: English (`en`), Arabic (`ar`), Spanish (`es`), French (`fr`), Hindi (`hi`), German (`de`), Italian (`it`), Portuguese (`pt`), Russian (`ru`), Japanese (`ja`), Korean (`ko`), and Simplified Chinese (`zh`). Where translations are AI-drafted, Settings displays a clear notice while native speakers review them (see [`docs/l10n_glossary.md`](docs/l10n_glossary.md)).

---

## Privacy and safety principles

1. **Local by default**: App lists, permission snapshots, document parsing (PDF/TXT/DOCX), and saved receipts stay on your phone.
2. **Consent is per check, never silent**: Cloud analysis and expressive cloud voice are always opt-in, one request at a time, with zero automatic retries.
3. **Evidence over scores**: Every finding is tied to an exact quote or a local Android permission observation, alongside what remains unknown.
4. **Honest wording**: Enprive never certifies safety, never gives legal advice, and marks sample classroom apps clearly as sample apps.

---

## What this README does not promise

Enprive is an informational privacy reading companion, **not** legal advice, **not** a school compliance certification tool, and **not** a network traffic monitor. Reading a policy and checking Android permissions cannot prove what an app's servers do in the background. Any item marked pending in **Where things stand** (including live Gemini Nano 4 on-device inference and physical-device Play Integrity) has not yet been proven on real hardware.

---

## Roadmap

- **Resume on a Gemini Nano 4 phone**: Verify real on-device Gemini Nano 4 inference, Play Integrity on a signed release build, physical TalkBack and audio quality, and real-device intake flows.
- **Finish translations**: Land the remaining language batches (`de`, `it`, `pt`, `ru`, `ja`, `ko`, `zh`) and incorporate native-speaker reviews across all 12 locales.
- **#BuildHybridAI 2026 submission**: Complete pre-freeze checks (28 November 2026) and record the real-device demo before the 30 November 2026 deadline.
- **After the competition**: Validate an education-focused workflow with parents and teachers before expanding checklists or institutional tools.

---

## Feedback and contributing

Bug reports, plain-language suggestions, and native-speaker translation reviews are very welcome. Please open an issue or pull request against `main`, and read [`AGENTS.md`](AGENTS.md) and [`journal.md`](journal.md) to match the project's privacy guardrails and engineering log conventions.

---

## License

Enprive is released under the **MIT License**. See [`LICENSE`](LICENSE) for the full license text and [`THIRD_PARTY_NOTICES.md`](THIRD_PARTY_NOTICES.md) for bundled font and open-source library attributions.
