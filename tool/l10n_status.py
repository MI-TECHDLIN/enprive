#!/usr/bin/env python3
"""Enprive localization audit, untranslated-file generator, and delta tracker.

Uses Python standard library only.

Examples:
  python3 tool/l10n_status.py
  python3 tool/l10n_status.py --locales ar,es,fr,hi --strict
  python3 tool/l10n_status.py --write-untranslated
  python3 tool/l10n_status.py --changed-since origin/main
"""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
from pathlib import Path
from typing import Dict, List, Optional, Set, Tuple

REPO_ROOT = Path(__file__).resolve().parent.parent
L10N_DIR = REPO_ROOT / "lib" / "l10n"
TEMPLATE_ARB = L10N_DIR / "app_en.arb"
UNTRANSLATED_FILE = REPO_ROOT / "untranslated_messages.json"

ALL_SECONDARY_LOCALES = [
    "ar",
    "de",
    "es",
    "fr",
    "hi",
    "it",
    "ja",
    "ko",
    "pt",
    "ru",
    "zh",
]

CJK_LOCALES = {"ja", "ko", "zh"}

# Strings that are legitimately identical to English across locales.
ALLOWED_IDENTICAL_KEYS = {
    "appTitle",
    "appIdPrefix",
    "intakeUrlHint",
}

ALLOWED_IDENTICAL_VALUES = {
    "Enprive",
    "Deni",
    "App ID",
    "URL",
    "Home",
    "System",
    "PDF",
    "TXT",
    "DOCX",
}

# Expected CLDR plural keywords per locale (exact =N selectors are always allowed).
# For ar, =0/=1/=2 or zero/one/two + few/many/other are required.
REQUIRED_PLURAL_RULES: Dict[str, List[Set[str]]] = {
    "ar": [{"=0", "zero"}, {"=1", "one"}, {"=2", "two"}, {"few"}, {"many"}, {"other"}],
    "ru": [{"one"}, {"few"}, {"many"}, {"other"}],
    "ja": [{"other"}],
    "ko": [{"other"}],
    "zh": [{"other"}],
    "es": [{"=1", "one"}, {"other"}],
    "fr": [{"=1", "one"}, {"other"}],
    "hi": [{"=1", "one"}, {"other"}],
    "de": [{"=1", "one"}, {"other"}],
    "it": [{"=1", "one"}, {"other"}],
    "pt": [{"=1", "one"}, {"other"}],
}

VALID_PLURAL_KEYWORDS = {"zero", "one", "two", "few", "many", "other"}
EXACT_SELECTOR_RE = re.compile(r"^=\d+$")
ICU_HEADER_RE = re.compile(r"^\{\s*([A-Za-z_][A-Za-z0-9_]*)\s*,\s*(plural|select)\s*,")


def load_arb(path: Path) -> Dict[str, object]:
    with path.open("r", encoding="utf-8") as f:
        return json.load(f)


def message_keys(arb: Dict[str, object]) -> List[str]:
    return [k for k in arb.keys() if not k.startswith("@")]


def parse_icu_blocks(text: str) -> Tuple[List[str], List[Tuple[str, str, Dict[str, str]]]]:
    """Parse top-level ICU plural/select blocks and validate brace balance.

    Returns (errors, blocks) where each block is (var_name, kind, {selector: body}).
    """
    errors: List[str] = []
    blocks: List[Tuple[str, str, Dict[str, str]]] = []
    n = len(text)
    i = 0
    depth = 0
    while i < n:
        ch = text[i]
        if ch == "{":
            depth += 1
            m = ICU_HEADER_RE.match(text[i:])
            if m and depth == 1:
                var_name = m.group(1)
                kind = m.group(2)
                j = i + m.end()
                forms: Dict[str, str] = {}
                while j < n:
                    while j < n and text[j].isspace():
                        j += 1
                    if j >= n:
                        errors.append("unclosed ICU block")
                        return errors, blocks
                    if text[j] == "}":
                        depth -= 1
                        i = j
                        break
                    sel_start = j
                    while j < n and not text[j].isspace() and text[j] not in "{}":
                        j += 1
                    selector = text[sel_start:j]
                    while j < n and text[j].isspace():
                        j += 1
                    if j >= n or text[j] != "{":
                        errors.append(f"expected '{{' after selector '{selector}'")
                        return errors, blocks
                    j += 1
                    body_start = j
                    sub_depth = 1
                    while j < n and sub_depth > 0:
                        if text[j] == "{":
                            sub_depth += 1
                        elif text[j] == "}":
                            sub_depth -= 1
                        j += 1
                    if sub_depth != 0:
                        errors.append(f"unclosed branch '{selector}'")
                        return errors, blocks
                    forms[selector] = text[body_start : j - 1]
                blocks.append((var_name, kind, forms))
        elif ch == "}":
            depth -= 1
            if depth < 0:
                errors.append("unmatched closing '}'")
                return errors, blocks
        i += 1
    if depth != 0:
        errors.append("unbalanced curly braces")
    return errors, blocks


def extract_placeholders(text: str) -> Set[str]:
    """Extract all ICU placeholder names from plain or plural/select strings."""
    placeholders: Set[str] = set()
    errors, blocks = parse_icu_blocks(text)
    if blocks:
        for var_name, _kind, forms in blocks:
            placeholders.add(var_name)
            for body in forms.values():
                for m in re.finditer(r"\{([A-Za-z_][A-Za-z0-9_]*)\}", body):
                    placeholders.add(m.group(1))
    else:
        for m in re.finditer(r"\{([A-Za-z_][A-Za-z0-9_]*)\}", text):
            placeholders.add(m.group(1))
    return placeholders


def check_plural_validity(
    locale: str, key: str, en_val: str, loc_val: str
) -> List[str]:
    issues: List[str] = []
    en_errs, en_blocks = parse_icu_blocks(en_val)
    loc_errs, loc_blocks = parse_icu_blocks(loc_val)
    if loc_errs:
        issues.append(f"{key}: ICU syntax error ({', '.join(loc_errs)})")
        return issues
    if en_errs:
        issues.append(f"{key}: template EN ICU syntax error ({', '.join(en_errs)})")
        return issues

    en_plurals = [b for b in en_blocks if b[1] == "plural"]
    loc_plurals = [b for b in loc_blocks if b[1] == "plural"]

    if len(en_plurals) != len(loc_plurals):
        issues.append(
            f"{key}: plural block count mismatch (EN={len(en_plurals)}, {locale}={len(loc_plurals)})"
        )
        return issues

    req_groups = REQUIRED_PLURAL_RULES.get(locale, [{"other"}])
    for (en_var, _, en_forms), (loc_var, _, loc_forms) in zip(en_plurals, loc_plurals):
        if en_var != loc_var:
            issues.append(
                f"{key}: plural variable mismatch (EN={en_var}, {locale}={loc_var})"
            )
        selectors = set(loc_forms.keys())
        for sel in selectors:
            if sel not in VALID_PLURAL_KEYWORDS and not EXACT_SELECTOR_RE.match(sel):
                issues.append(f"{key}: invalid plural selector '{sel}'")
        if "other" not in selectors:
            issues.append(f"{key}: missing mandatory 'other' plural branch")
        if "=0" in en_forms and "=0" not in selectors and "zero" not in selectors:
            issues.append(f"{key}: EN has '=0' branch missing in {locale}")
        for group in req_groups:
            if not (selectors & group):
                issues.append(
                    f"{key}: missing CLDR plural category for {locale} (expected one of {sorted(group)})"
                )
    return issues


def audit_locale(
    en_arb: Dict[str, object],
    locale: str,
    loc_arb: Dict[str, object],
    max_ratio: float,
    min_ratio: float,
) -> Dict[str, object]:
    en_keys = message_keys(en_arb)
    loc_keys = message_keys(loc_arb)
    en_key_set = set(en_keys)
    loc_key_set = set(loc_keys)

    missing = [k for k in en_keys if k not in loc_key_set]
    extra = [k for k in loc_keys if k not in en_key_set]

    placeholder_mismatches: List[str] = []
    plural_issues: List[str] = []
    em_dashes: List[str] = []
    identical_to_en: List[str] = []
    length_outliers: List[str] = []
    empty_values: List[str] = []

    is_cjk = locale in CJK_LOCALES
    eff_min = 0.22 if is_cjk else min_ratio
    eff_max = 1.65 if is_cjk else max_ratio

    for k in en_keys:
        if k not in loc_key_set:
            continue
        en_val = str(en_arb[k])
        loc_val = str(loc_arb[k])

        if not loc_val.strip():
            empty_values.append(k)
            continue

        if "\u2014" in loc_val:
            em_dashes.append(k)

        en_ph = extract_placeholders(en_val)
        loc_ph = extract_placeholders(loc_val)
        if en_ph != loc_ph:
            placeholder_mismatches.append(
                f"{k}: EN={sorted(en_ph)} vs {locale}={sorted(loc_ph)}"
            )

        plural_issues.extend(check_plural_validity(locale, k, en_val, loc_val))

        if (
            loc_val.strip() == en_val.strip()
            and k not in ALLOWED_IDENTICAL_KEYS
            and en_val.strip() not in ALLOWED_IDENTICAL_VALUES
        ):
            identical_to_en.append(k)

        # Skip short strings (< 12 chars) and ICU plural blocks for raw char ratio checks
        if len(en_val) >= 12 and "plural," not in en_val:
            ratio = len(loc_val) / len(en_val)
            if ratio > eff_max or ratio < eff_min:
                length_outliers.append(
                    f"{k}: ratio={ratio:.2f} (en={len(en_val)}, {locale}={len(loc_val)})"
                )

    return {
        "locale": locale,
        "translated": len(loc_key_set & en_key_set),
        "total": len(en_keys),
        "missing": missing,
        "extra": extra,
        "empty_values": empty_values,
        "placeholder_mismatches": placeholder_mismatches,
        "plural_issues": plural_issues,
        "em_dashes": em_dashes,
        "identical_to_en": identical_to_en,
        "length_outliers": length_outliers,
    }


def write_untranslated(en_arb: Dict[str, object], locales: List[str]) -> Dict[str, List[str]]:
    en_keys = message_keys(en_arb)
    data: Dict[str, List[str]] = {}
    for loc in sorted(locales):
        arb_path = L10N_DIR / f"app_{loc}.arb"
        if not arb_path.exists():
            continue
        loc_arb = load_arb(arb_path)
        missing = [k for k in en_keys if k not in loc_arb]
        if missing:
            data[loc] = missing
    with UNTRANSLATED_FILE.open("w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
        f.write("\n")
    return data


def diff_english_since(git_ref: str) -> int:
    rel_template = TEMPLATE_ARB.relative_to(REPO_ROOT).as_posix()
    proc = subprocess.run(
        ["git", "-C", str(REPO_ROOT), "show", f"{git_ref}:{rel_template}"],
        capture_output=True,
        text=True,
        check=False,
    )
    if proc.returncode != 0:
        print(
            f"Error reading {rel_template} at git ref '{git_ref}': {proc.stderr.strip()}",
            file=sys.stderr,
        )
        return 2

    old_arb = json.loads(proc.stdout)
    new_arb = load_arb(TEMPLATE_ARB)

    old_keys = set(message_keys(old_arb))
    new_keys = set(message_keys(new_arb))

    added = [k for k in message_keys(new_arb) if k not in old_keys]
    removed = [k for k in message_keys(old_arb) if k not in new_keys]
    changed = [
        k
        for k in message_keys(new_arb)
        if k in old_keys and str(old_arb[k]) != str(new_arb[k])
    ]

    print(f"English ARB delta since {git_ref}:")
    print(f"  Added ({len(added)}): {', '.join(added) if added else 'none'}")
    print(f"  Changed ({len(changed)}): {', '.join(changed) if changed else 'none'}")
    print(f"  Removed ({len(removed)}): {', '.join(removed) if removed else 'none'}")
    for k in changed:
        print(f"  ~ {k}:")
        print(f"      old: {old_arb[k]!r}")
        print(f"      new: {new_arb[k]!r}")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Audit Enprive ARB localizations and track English deltas."
    )
    parser.add_argument(
        "--locales",
        help="Comma-separated locale codes to audit (default: all 11 secondary locales).",
    )
    parser.add_argument(
        "--strict",
        action="store_true",
        help="Exit non-zero if any audited locale has missing/extra/empty keys, placeholder mismatches, plural errors, or em dashes.",
    )
    parser.add_argument(
        "--write-untranslated",
        action="store_true",
        help="Regenerate untranslated_messages.json across all secondary locales.",
    )
    parser.add_argument(
        "--changed-since",
        metavar="GIT_REF",
        help="List keys added, changed, or removed in lib/l10n/app_en.arb since GIT_REF.",
    )
    parser.add_argument(
        "--max-ratio",
        type=float,
        default=2.4,
        help="Upper length ratio outlier threshold for non-CJK locales (default: 2.4).",
    )
    parser.add_argument(
        "--min-ratio",
        type=float,
        default=0.4,
        help="Lower length ratio outlier threshold for non-CJK locales (default: 0.4).",
    )
    parser.add_argument(
        "--verbose",
        action="store_true",
        help="Print detailed lists of identical strings and length ratio outliers.",
    )
    args = parser.parse_args()

    if args.changed_since:
        return diff_english_since(args.changed_since)

    en_arb = load_arb(TEMPLATE_ARB)
    en_em_dashes = [
        k for k in message_keys(en_arb) if "\u2014" in str(en_arb[k])
    ]
    if en_em_dashes:
        print(f"WARNING: app_en.arb contains em dashes in: {en_em_dashes}")

    if args.locales:
        locales = [s.strip() for s in args.locales.split(",") if s.strip()]
    else:
        locales = list(ALL_SECONDARY_LOCALES)

    if args.write_untranslated:
        untranslated = write_untranslated(en_arb, ALL_SECONDARY_LOCALES)
        total_missing = sum(len(v) for v in untranslated.values())
        print(
            f"Wrote {UNTRANSLATED_FILE.name}: {len(untranslated)} locale(s) with missing keys ({total_missing} total)."
        )

    print(f"Template: app_en.arb ({len(message_keys(en_arb))} keys)")
    print("-" * 88)
    print(
        f"{'Locale':<6} {'Done':>9} {'Miss':>5} {'Extra':>5} {'PH':>4} {'Plur':>4} {'EmD':>4} {'SameEN':>6} {'LenOut':>6}"
    )
    print("-" * 88)

    strict_failures = 0
    reports = []
    for loc in locales:
        arb_path = L10N_DIR / f"app_{loc}.arb"
        if not arb_path.exists():
            print(f"{loc:<6} MISSING FILE: {arb_path}")
            strict_failures += 1
            continue
        loc_arb = load_arb(arb_path)
        rep = audit_locale(en_arb, loc, loc_arb, args.max_ratio, args.min_ratio)
        reports.append(rep)
        print(
            f"{loc:<6} "
            f"{rep['translated']:>4}/{rep['total']:<4} "
            f"{len(rep['missing']):>5} "
            f"{len(rep['extra']):>5} "
            f"{len(rep['placeholder_mismatches']):>4} "
            f"{len(rep['plural_issues']):>4} "
            f"{len(rep['em_dashes']):>4} "
            f"{len(rep['identical_to_en']):>6} "
            f"{len(rep['length_outliers']):>6}"
        )
        hard_errors = (
            len(rep["missing"])
            + len(rep["extra"])
            + len(rep["empty_values"])
            + len(rep["placeholder_mismatches"])
            + len(rep["plural_issues"])
            + len(rep["em_dashes"])
        )
        if hard_errors > 0:
            strict_failures += 1

    print("-" * 88)
    for rep in reports:
        loc = rep["locale"]
        for label in ("empty_values", "extra", "placeholder_mismatches", "plural_issues", "em_dashes"):
            items = rep[label]
            if items:
                print(f"[{loc}] {label} ({len(items)}):")
                for item in items[:25]:
                    print(f"  - {item}")
                if len(items) > 25:
                    print(f"  ... and {len(items) - 25} more")
        if args.verbose:
            for label in ("identical_to_en", "length_outliers"):
                items = rep[label]
                if items:
                    print(f"[{loc}] {label} ({len(items)}):")
                    for item in items[:40]:
                        print(f"  - {item}")
                    if len(items) > 40:
                        print(f"  ... and {len(items) - 40} more")

    if args.strict and (strict_failures > 0 or en_em_dashes):
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
