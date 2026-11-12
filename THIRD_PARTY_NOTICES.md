# Third-Party Notices & Open-Source Attributions

Enprive incorporates the following open-source fonts, libraries, and SDKs:

---

## 1. Bundled Typography (`assets/fonts/`)

1. **Nunito**
   - **Copyright**: Copyright 2014 The Nunito Project Authors (Vernon Adams, Cyreal, Jacques Le Bailly).
   - **License**: SIL Open Font License, Version 1.1 (`OFL-1.1`).
   - **Source**: https://fonts.google.com/specimen/Nunito

2. **Inter** (Curated via FontBase)
   - **Copyright**: Copyright 2020 The Inter Project Authors (Rasmus Andersson).
   - **License**: SIL Open Font License, Version 1.1 (`OFL-1.1`).
   - **Source**: https://fontba.se/ / https://github.com/rsms/inter

3. **Source Serif 4**
   - **Copyright**: Copyright 2014–2021 Adobe Systems Incorporated (Frank Grießhammer).
   - **License**: SIL Open Font License, Version 1.1 (`OFL-1.1`).
   - **Source**: https://github.com/adobe-fonts/source-serif

---

## 2. Flutter & Dart Packages (`pubspec.yaml`)

- **Flutter SDK** (`flutter`, `flutter_localizations`, `flutter_test`) — BSD-3-Clause License (Google)
- **material_symbols_icons** — Apache License 2.0
- **shared_preferences** — BSD-3-Clause License
- **sqflite** — BSD-2-Clause License (Tekartik)
- **path** — BSD-3-Clause License
- **intl** — BSD-3-Clause License
- **google_fonts** — Apache License 2.0 (configured with `allowRuntimeFetching = false` for 100% offline bundled rendering)

---

## 3. Native Android & Firebase AI Logic SDKs (`android/app/build.gradle.kts`)

- **Firebase BoM (`com.google.firebase:firebase-bom:34.14.0`)** — Apache License 2.0
- **Firebase AI Logic (`com.google.firebase:firebase-ai`)** — Apache License 2.0
- **Firebase App Check (`com.google.firebase:firebase-appcheck-playintegrity`, `firebase-appcheck-debug`)** — Apache License 2.0
- **Kotlin Coroutines (`org.jetbrains.kotlinx:kotlinx-coroutines-android`)** — Apache License 2.0
