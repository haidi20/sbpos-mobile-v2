#!/usr/bin/env python3
"""
Simple rule-based comment translator (EN -> ID) for Dart files under features/transaction.
- Not a perfect translator; focuses on common phrases and words used in the repo.
- Creates a .bak copy for safety before overwriting.
Usage:
  python tools/translate_comments.py --apply
  python tools/translate_comments.py    # dry-run, shows preview of first few replacements
"""
import re
import sys
import argparse
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
TARGET = ROOT / 'features' / 'transaction'

# Phrase map: longer phrases first
PHRASES = {
    # long phrases
    r"Create new transaction when none exists": "Buat transaksi baru ketika belum ada",
    r"Existing transaction handling": "Penanganan transaksi yang sudah ada",
    r"Load local transaction": "Muat transaksi lokal",
    r"Persist and update state": "Persist dan perbarui state",
    r"Persist detail": "Persist detail",
    r"indicate persistent loading": "tandai pemuatan persistent",
    r"already loaded, skipping": "sudah dimuat, melewatkan",
    r"already in progress, awaiting": "sedang berjalan, menunggu",
    r"clearing isLoadingPersistent": "menghapus isLoadingPersistent",
    r"create succeeded": "pembuatan berhasil",
    r"create failed": "pembuatan gagal",
    r"update succeeded": "pembaruan berhasil",
    r"update failed": "pembaruan gagal",
    r"delete failed": "penghapusan gagal",
    r"no existing local transaction found": "tidak ditemukan transaksi lokal",
    r"finally clearing isLoadingPersistent": "pada akhirnya menghapus isLoadingPersistent",

    # short phrases
    r"Set": "Set",
    r"set": "set",
    r"Update": "Perbarui",
    r"update": "perbarui",
    r"Persist": "Persist",
    r"persist": "persist",
    r"Load": "Muat",
    r"load": "muat",
    r"Create": "Buat",
    r"create": "buat",
    r"Delete": "Hapus",
    r"delete": "hapus",
    r"Existing": "Sudah ada",
    r"existing": "sudah ada",
    r"Fallback": "Cadangan",
    r"fallback": "cadangan",
    r"Guard": "Guard",
    r"guard": "guard",
    r"helper": "helper",
    r"removed": "dihapus",
    r"use": "gunakan",
    r"calling": "memanggil",
    r"background": "latar belakang",
    r"optional": "opsional",
    r"enforce": "tegakkan",
    r"enforced": "ditegakkan",
    r"mark": "tandai",
    r"indicate": "tandai",
    r"starting": "memulai",
    r"starting load": "memulai pemuatan",
    r"skipping": "melewatkan",
    r"awaiting": "menunggu",
    r"in progress": "sedang berjalan",
    r"finally": "pada akhirnya",
    r"clear": "bersihkan",
    r"clearing": "menghapus",
    r"succeeded": "berhasil",
    r"failed": "gagal",
    r"error": "error",
    r"warning": "peringatan",
    r"info": "info",
    r"note": "catatan",
}

WORD_RE = re.compile(r"\\b(" + "|".join([re.escape(k) for k in PHRASES.keys() if len(k) == 1 or k.islower()]) + r")\\b") if any(k.islower() and len(k)==1 for k in PHRASES.keys()) else None

# We'll do a two-pass replacement: phrases (case-sensitive), then words (word-boundary)

def translate_text(text):
    original = text
    # phrases first (descending length)
    for pat, repl in sorted(PHRASES.items(), key=lambda x: -len(x[0])):
        try:
            text = re.sub(re.escape(pat), repl, text)
        except re.error:
            pass

    # word-level replacements (case-sensitive simple approach)
    for pat, repl in PHRASES.items():
        # skip long phrases already handled
        if len(pat.split()) > 1:
            continue
        # replace with word boundaries (case-sensitive)
        text = re.sub(r"\\b" + re.escape(pat) + r"\\b", repl, text)

    return text if text != original else None


def process_file(path: Path, apply: bool=False):
    s = path.read_text(encoding='utf-8')
    changed = False
    out_lines = []
    for line in s.splitlines(keepends=True):
        stripped = line.lstrip()
        if stripped.startswith('///') or stripped.startswith('//') or stripped.startswith('/*') or stripped.startswith('*'):
            translated = translate_text(line)
            if translated:
                changed = True
                # preserve indentation
                indent = line[:len(line)-len(line.lstrip())]
                # keep line ending if any
                if line.endswith('\n') and not translated.endswith('\n'):
                    translated = translated + '\n'
                out_lines.append(translated)
                continue
        out_lines.append(line)
    if not changed:
        return False, []
    if apply:
        backup = path.with_suffix(path.suffix + '.bak')
        path.write_text(''.join(out_lines), encoding='utf-8')
        if not backup.exists():
            backup.write_text(s, encoding='utf-8')
        return True, [str(path)]
    else:
        return True, [str(path)]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--apply', action='store_true', help='Apply changes')
    args = parser.parse_args()

    files = list(TARGET.rglob('*.dart'))
    changed_files = []
    for f in files:
        ok, items = process_file(f, apply=args.apply)
        if ok:
            changed_files.extend(items)

    print(f'Target dir: {TARGET}')
    print(f'Found {len(files)} dart files')
    print(f'Files changed: {len(changed_files)}')
    for i, p in enumerate(changed_files[:50]):
        print(' -', p)
    if len(changed_files) > 50:
        print(' - ... and more')

    if not args.apply:
        print('\nDry-run complete. Re-run with --apply to write changes.')

if __name__ == '__main__':
    main()
