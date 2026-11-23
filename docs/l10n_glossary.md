# Enprive Localization Glossary & Style Guide (D5.3-F)

This glossary defines the fixed terminology, register, punctuation, and ICU plural rules across all 12 Enprive locales (`en`, `ar`, `es`, `fr`, `hi`, `de`, `it`, `pt`, `ru`, `ja`, `ko`, `zh`).

All terms preserve and extend the 142 keys already translated in each secondary `.arb` file so older and newer screens stay consistent.

---

## 1. Global Non-Translatable Invariants

Never translate or alter:
- **Product and mascot names**: `Enprive`, `Deni`, `Enprive Check`
  - *Note for native reviewers*: Earlier 142-key bundles in `ar`, `ru`, and `ko` used phonetic forms (`ديني`, `Дени`, `데니`). All new keys keep `Deni` in Latin script per D5.3-F rules (which in Arabic also avoids ambiguity with `ديني`, meaning "religious"). Existing keys are flagged for native-speaker decision on unification.
- **Technical & platform identifiers**: `App ID`, `Android`, `Google Play Store` (or local official Play Store name where natural), `Wi-Fi`, package names (e.g. `com.example.app`), URLs (e.g. `https://example.com/privacy-policy`), placeholder email addresses (`privacy@example.com`), and file formats (`PDF`, `TXT`, `DOCX`).
- **ICU placeholders**: Keep every `{placeholder}` name verbatim (`{appName}`, `{count}`, `{current}`, `{total}`, `{index}`, `{title}`, `{packageName}`, `{otherApps}`, `{requestedCount}`, `{grantedCount}`, `{sourceMatched}`, `{deviceObserved}`, `{interpretation}`, `{unverified}`, `{reviewRecommended}`, `{noConcern}`, `{insufficientEvidence}`, `{dataCollection}`, `{sharing}`, `{tracking}`, `{retention}`, `{parentalControls}`).
- **Honesty & calibration rules**:
  - Never claim an app is "safe", "approved", "verified safe", or "compliant".
  - Preserve the exact meaning of *"No concern identified in the reviewed evidence. This is not a safety certification."*
  - Preserve the distinction between *"the policy does not mention X"* / *"silence in a policy is not a promise"* and *"the app does not do X"*.
  - Preserve the distinction between an allowed phone permission (capability) and proof that data was uploaded or sent.
  - Keep cloud consent disclosures exact: only the previewed text (with personal details hidden) is sent for that one request; installed apps and phone permissions are never sent.
- **Punctuation & reading level**:
  - Target roughly a 10-12 year old reading level in core flows (clear, warm, non-alarmist language for parents, teachers, and children).
  - **No em dashes (`\u2014`)** in any ARB value. Use the locale's natural punctuation (`:`, `,`, `.`, parentheses, or locale-standard equivalents).

---

## 2. Locale Register, Script, Punctuation & CLDR Plurals

| Locale | BCP-47 | Register & Tone | Punctuation & Digits | CLDR Plural Categories |
|---|---|---|---|---|
| `en` | `en-US` | Plain, calm, direct (`you`) | Standard English, no em dashes | `=0` (when needed), `=1`, `other` |
| `ar` | `ar-SA` | Modern Standard Arabic, direct (`أنتَ/ك`, `هاتفك`) | Arabic `،` and `؟`, Western digits `0-9` (per existing `app_ar.arb`), RTL | `=0`, `=1`, `=2`, `few`, `many`, `other` |
| `es` | `es-ES` | Neutral international Spanish, friendly `tú` (`tu teléfono`) | Inverted `¿...?`, standard quotes | `=0` (when needed), `=1`, `other` |
| `fr` | `fr-FR` | Polite neutral `vous` (`votre téléphone`) | Space before `?` and `:`, apostrophe `'` | `=0` (when needed), `=1`, `other` |
| `hi` | `hi-IN` | Polite `आप` (`आपका फ़ोन`) | Devanagari `।` for full stop, `?`, Western digits `0-9` | `=0` (when needed), `=1`, `other` |
| `de` | `de-DE` | Formal-neutral `Sie` (`Ihr`, `dieses Gerät` / `dieses Telefon`) | Standard German capitalization and punctuation | `=0` (when needed), `=1`, `other` |
| `it` | `it-IT` | Friendly-neutral `tu` (`il tuo telefono`) | Standard Italian punctuation | `=0` (when needed), `=1`, `other` |
| `pt` | `pt-BR` | Brazilian Portuguese, neutral `você` (`seu telefone`) | Standard Brazilian Portuguese punctuation | `=0` (when needed), `=1`, `other` |
| `ru` | `ru-RU` | Polite `вы` (`ваш телефон`), keep `ё` where standard | Standard Russian punctuation (`«...»` or `"..."`) | `=0` (when needed), `one`, `few`, `many`, `other` |
| `ja` | `ja-JP` | Polite `です・ます` | Full-width `。`, `、`, `？`, `「…」` | `=0` (when needed), `other` |
| `ko` | `ko-KR` | Polite 해요체 / 합니다체 (`~하세요`, `~입니다`) | Standard Korean spacing and punctuation | `=0` (when needed), `other` |
| `zh` | `zh-CN` | Simplified Chinese, polite `您`/`你` (`此手机`) | Full-width `。`, `，`, `？`, `：`, `“...”` | `=0` (when needed), `other` |

---

## 3. Core Product Glossary

### Stage 1 Locales (`ar`, `es`, `fr`, `hi`)

| English Term | `ar` | `es` | `fr` | `hi` |
|---|---|---|---|---|
| privacy policy | سياسة الخصوصية | política de privacidad | politique de confidentialité | गोपनीयता नीति |
| permission / permissions | إذن / أذونات | permiso / permisos | autorisation / autorisations | अनुमति / अनुमतियाँ |
| evidence | دليل / أدلة | pruebas | preuves | साक्ष्य |
| Matched in policy | مطابق في السياسة | Coincide con la política | Trouvé dans la politique | नीति में मिला |
| Seen on this phone | مرصود على هذا الهاتف | Visto en este teléfono | Observé sur ce téléphone | इस फ़ोन पर दिखा |
| Deni's explanation | شرح Deni | Explicación de Deni | Explication de Deni | Deni की व्याख्या |
| Not found in policy | غير موجود في السياسة | No encontrado en la política | Introuvable dans la politique | नीति में नहीं मिला |
| receipt / Receipts | إيصال / الإيصالات | recibo / Recibos | reçu / Reçus | रसीद / रसीदें |
| review | مراجعة | revisión | analyse / vérification | समीक्षा |
| Check | فحص | Revisar | Vérifier | जाँचें |
| Learn | تعلّم | Aprender | Apprendre | सीखें |
| Companion | المرافق | Asistente | Compagnon | साथी |
| App ID | App ID | App ID | App ID | App ID |
| Advanced details | تفاصيل متقدمة | Detalles avanzados | Détails avancés | उन्नत विवरण |
| lesson | درس | lección | leçon | पाठ |
| quick check | اختبار سريع | comprobación rápida | vérification rapide | त्वरित जाँच |
| Listen | استمع | Escuchar | Écouter | सुनें |

### Stage 2 Locales (`de`, `it`, `pt`, `ru`)

| English Term | `de` | `it` | `pt` | `ru` |
|---|---|---|---|---|
| privacy policy | Datenschutzerklärung | informativa sulla privacy | política de privacidade | политика конфиденциальности |
| permission / permissions | Berechtigung / Berechtigungen | permesso / permessi | permissão / permissões | разрешение / разрешения |
| evidence | Belege | prove | evidências | факты / данные |
| Matched in policy | In der Erklärung gefunden | Trovato nell'informativa | Encontrado na política | Найдено в политике |
| Seen on this phone | Auf diesem Gerät gesehen | Rilevato su questo telefono | Visto neste telefone | Замечено на этом телефоне |
| Deni's explanation | Erklärung von Deni | Spiegazione di Deni | Explicação do Deni | Пояснение Deni |
| Not found in policy | Nicht in der Erklärung gefunden | Non trovato nell'informativa | Não encontrado na política | Не найдено в политике |
| receipt / Receipts | Beleg / Belege | ricevuta / Ricevute | recibo / Recibos | чек / Чеки |
| review | Prüfung | verifica | análise | проверка |
| Check | Prüfen | Verifica | Verificar | Проверка |
| Learn | Lernen | Impara | Aprender | Обучение |
| Companion | Begleiter | Assistente | Assistente | Помощник |
| App ID | App ID | App ID | App ID | App ID |
| Advanced details | Erweiterte Details | Dettagli avanzati | Detalhes avançados | Расширенные сведения |
| lesson | Lektion | lezione | lição | урок |
| quick check | Kurzcheck | controllo rapido | verificação rápida | быстрая проверка |
| Listen | Anhören | Ascolta | Ouvir | Слушать |

### Stage 3 Locales (`ja`, `ko`, `zh`)

| English Term | `ja` | `ko` | `zh` |
|---|---|---|---|
| privacy policy | プライバシーポリシー | 개인정보 처리방침 | 隐私政策 |
| permission / permissions | 権限 | 권한 | 权限 |
| evidence | 根拠 | 근거 | 证据 |
| Matched in policy | ポリシーと一致 | 방침에서 일치 | 政策原文匹配 |
| Seen on this phone | この端末で確認 | 이 휴대폰에서 확인 | 在此手机上看到 |
| Deni's explanation | Deniの説明 | Deni의 설명 | Deni 的说明 |
| Not found in policy | ポリシーに記載なし | 방침에서 찾을 수 없음 | 政策中未找到 |
| receipt / Receipts | レシート | 영수증 | 收据 |
| review | 確認 | 검토 | 审查 |
| Check | チェック | 확인 | 检查 |
| Learn | 学ぶ | 배우기 | 学习 |
| Companion | コンパニオン | 도우미 | 助手 |
| App ID | App ID | App ID | App ID |
| Advanced details | 詳細情報 | 고급 세부정보 | 高级详情 |
| lesson | レッスン | 레슨 | 课程 |
| quick check | クイックチェック | 퀵 체크 | 快速自测 |
| Listen | 聴く | 듣기 | 收听 |

---

## 4. Existing Evidence Category Labels (Fixed from 142-Key Baseline)

Always reuse these exact category names (including when referenced inside Learn Lesson 4):

| Key | `en` | `ar` | `es` | `fr` | `hi` | `de` | `it` | `pt` | `ru` | `ja` | `ko` | `zh` |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| `categoryDataCollection` | Data Collection | جمع البيانات | Recopilación de datos | Collecte de données | डेटा संग्रहण | Datenerhebung | Raccolta dati | Coleta de dados | Сбор данных | データ収集 | 데이터 수집 | 数据收集 |
| `categorySharing` | Third-Party Sharing | المشاركة مع أطراف ثالثة | Uso compartido con terceros | Partage avec des tiers | तृतीय-पक्ष साझाकरण | Weitergabe an Dritte | Condivisione con terzi | Compartilhamento com terceiros | Передача третьим лицам | 第三者への共有 | 제3자 공유 | 第三方共享 |
| `categoryTracking` | Location & Tracking | الموقع والتتبع | Ubicación y seguimiento | Localisation et suivi | स्थान और ट्रैकिंग | Standort & Tracking | Posizione e tracciamento | Localização e rastreamento | Геолокация и отслеживание | 位置情報と追跡 | 위치 및 추적 | 定位与追踪 |
| `categoryRetention` | Retention & Voice | الاحتفاظ والصوت | Retención y voz | Conservation et voix | संग्रहण और वॉइस | Speicherung & Sprache | Conservazione e voce | Retenção e voz | Хранение и голос | 保管と音声 | 보관 및 음성 | 数据保留与语音 |
| `categoryParentalControls` | Parental Controls | رقابة الوالدين | Controles parentales | Contrôle parental | अभिभावक नियंत्रण | Kindersicherung | Controllo genitori | Controles parentais | Родительский контроль | 保護者管理 | 보호자 관리 | 家长控制 |

---

## 5. Delta Workflow for Late English Changes

Before the feature freeze, run:

```bash
python3 tool/l10n_status.py --changed-since <git-ref>
```

This lists every key added, modified, or removed in `lib/l10n/app_en.arb` since `<git-ref>` so secondary locales can be updated cheaply without re-auditing unchanged keys.
