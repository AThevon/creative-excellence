#!/usr/bin/env bash
set -euo pipefail

DIST="dist"
SKILLS_DIR="skills"

# Prefer zip, fallback to python3 zipfile
if command -v zip &>/dev/null; then
  make_zip() { (cd "$1" && zip -rq "$2" . -x '.*' -x '*/__pycache__/*' -x '*.pyc'); }
elif command -v python3 &>/dev/null; then
  make_zip() {
    python3 -c "
import zipfile, os, sys
src, dst = sys.argv[1], sys.argv[2]
with zipfile.ZipFile(dst, 'w', zipfile.ZIP_DEFLATED) as zf:
    for root, dirs, files in os.walk(src):
        dirs[:] = [d for d in dirs if not d.startswith('.') and d != '__pycache__']
        for f in files:
            if f.startswith('.') or f.endswith('.pyc'): continue
            fp = os.path.join(root, f)
            zf.write(fp, os.path.relpath(fp, src))
" "$1" "$2"
  }
else
  echo "Error: 'zip' or 'python3' is required."
  exit 1
fi

rm -rf "$DIST"
mkdir -p "$DIST"

echo "=== creative-excellence - Packaging pour claude.ai ==="
echo ""

# --- Individual ZIPs per skill ---

# Orchestrators (skills/<name>/ -> <name>.zip, skip _creative/)
for dir in "$SKILLS_DIR"/*/; do
  name=$(basename "$dir")
  [[ "$name" == _* ]] && continue
  zip_path="$(pwd)/${DIST}/${name}.zip"
  make_zip "$dir" "$zip_path"
  echo "  + ${name}.zip"
done

# Sub-skills (_creative/<name>/ -> <name>.zip)
for dir in "$SKILLS_DIR"/_creative/*/; do
  name=$(basename "$dir")
  zip_path="$(pwd)/${DIST}/${name}.zip"
  make_zip "$dir" "$zip_path"
  echo "  + ${name}.zip"
done

# --- Global ZIP (convenience) ---
GLOBAL_ZIP="creative-excellence-all.zip"
make_zip "$SKILLS_DIR" "$(pwd)/${DIST}/${GLOBAL_ZIP}"
echo "  + $GLOBAL_ZIP (global)"

echo ""
echo "=== Résumé ==="
echo ""
ls -lh "$DIST"/*.zip | awk '{print "  " $NF " (" $5 ")"}'
echo ""
echo "Upload les ZIPs sur claude.ai : Customize > Skills > Upload ZIP"
echo "Les orchestrateurs (creative-excellence, design-excellence) ont besoin"
echo "des sous-skills pour fonctionner - uploadez-les aussi."
