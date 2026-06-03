#!/usr/bin/env bash
# Usage: ./update.sh /path/to/WhatsApp\ Chat\ -\ ....zip
# Or just drag the zip onto this script in Finder.
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ZIP="${1:-}"

# ── Validate input ────────────────────────────────────────────────────────────
if [[ -z "$ZIP" ]]; then
  echo "Usage: $0 <WhatsApp-export.zip>"
  echo "Tip: drag the .zip file onto this script icon in Finder."
  exit 1
fi

if [[ ! -f "$ZIP" ]]; then
  echo "Error: file not found: $ZIP"
  exit 1
fi

if [[ "${ZIP##*.}" != "zip" ]]; then
  echo "Error: expected a .zip file, got: $ZIP"
  exit 1
fi

echo "──────────────────────────────────────"
echo "  WhatsApp Chat Updater"
echo "──────────────────────────────────────"
echo "  ZIP : $ZIP"
echo "  DIR : $SCRIPT_DIR"
echo ""

# ── Extract zip (keep scripts, .git, .gitignore) ─────────────────────────────
echo "[1/4] Extracting ZIP..."
cd "$SCRIPT_DIR"

# Remove old media + chat only (preserve repo files)
find . -maxdepth 1 \
  ! -name '.' \
  ! -name '.git' \
  ! -name '.gitignore' \
  ! -name 'update.sh' \
  ! -name 'build_static.py' \
  ! -name 'serve.py' \
  ! -name 'build.py' \
  -delete

unzip -q "$ZIP" -d "$SCRIPT_DIR"
echo "    Done."

# ── Rebuild index.html ────────────────────────────────────────────────────────
echo "[2/4] Building index.html..."
python3 "$SCRIPT_DIR/build_static.py"
echo "    Done."

# ── Git commit ────────────────────────────────────────────────────────────────
echo "[3/4] Committing..."
cd "$SCRIPT_DIR"
git add index.html *.jpg *.webp *.opus _chat.txt 2>/dev/null || true
git add -u
TIMESTAMP="$(date '+%Y-%m-%d %H:%M')"
MSG_COUNT="$(grep -c 'msg-row' index.html || true)"
git commit -m "Update chat — $TIMESTAMP" --quiet
echo "    Done."

# ── Push ─────────────────────────────────────────────────────────────────────
echo "[4/4] Pushing to GitHub Pages..."
git push --quiet
echo "    Done."

echo ""
echo "✅ All done! Changes will be live in ~30 seconds at:"
echo "   https://danielchioro.github.io/tiempo-libre-26/"
