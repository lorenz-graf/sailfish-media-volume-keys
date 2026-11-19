#!/bin/sh
# Build the Patchmanager patch from the difference between stock/ and work/.
#   stock/ = unmodified files from the phone (read-only, not in git: proprietary)
#   work/  = the same tree with our homescreen change (not in git)
#   settings/ = our own Settings page, Top menu toggle and entry (in git); copied
#               into work/ here, so the patch adds them as new files
# Output: patch/sailfish-media-volume-keys/{patch.json,unified_diff.patch} (in git)
# Recreate work/ from it: cp -a stock work && patch -p1 -d work < patch/sailfish-media-volume-keys/unified_diff.patch
set -eu
cd "$(dirname "$0")"

NAME=sailfish-media-volume-keys
VERSION=2.0
OUT=patch/$NAME
SETTINGS=work/usr/share/jolla-settings

mkdir -p "$SETTINGS/entries" "$SETTINGS/pages/$NAME"
cp settings/$NAME.json "$SETTINGS/entries/"
cp settings/*.qml "$SETTINGS/pages/$NAME/"

rm -rf "$OUT"
mkdir -p "$OUT"

# Lint every changed or new QML file first
changed=$(diff -rqN stock work | awk '{print $4}' | grep '\.qml$' || true)
if [ -z "$changed" ]; then
    echo "No changes between stock/ and work/" >&2
    exit 1
fi
qmllint-qt5 $changed

# Missing imports only fail at runtime ("X is not a type"; in lipstick Patchmanager
# then turns all patches off), so check them against the modules on the phone (SSH).
# Phone: $PHONE, or the git-ignored file phone.conf (one line, defaultuser@<ip>)
if [ -z "${PHONE:-}" ] && [ -f phone.conf ]; then
    PHONE=$(head -n 1 phone.conf)
fi
if [ -z "${PHONE:-}" ]; then
    echo "Set PHONE=defaultuser@<phone address> or put it in phone.conf" >&2
    exit 1
fi
./check-imports.py "$PHONE" stock $changed

# a/ and b/ prefixes, no timestamps, so `patch -p1 -d /` applies it
diff -ruN stock work \
    | sed -e 's#^--- stock/[^\t]*\t1970-01-01.*#--- /dev/null#' \
          -e 's#^--- stock/\([^\t]*\).*#--- a/\1#' \
          -e 's#^+++ work/\([^\t]*\).*#+++ b/\1#' \
          -e 's#^diff -ruN stock/\([^ ]*\) work/.*#diff -ruN a/\1 b/\1#' \
    > "$OUT/unified_diff.patch" || true

cat > "$OUT/patch.json" <<EOF
{
    "name": "$NAME",
    "display_name": "Volume keys",
    "description": "Choose what the volume keys control (ringtone, media or alarm volume) and control the alarm volume while the Clock app is open. Adds an alarm and timer volume slider and these options to Settings > Sounds and feedback, plus Alarm volume and Media keys for the Top menu.",
    "category": "homescreen",
    "author": "lorenz-graf",
    "version": "$VERSION",
    "compatible": ["5.2.0.22"]
}
EOF
echo "built: $OUT ($(grep -c '^+++ ' "$OUT/unified_diff.patch") files)"
