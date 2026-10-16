#!/usr/bin/env bash
set -euo pipefail

# ES2-KING executable bootstrap
# This script does NOT replace or rewrite Original ES2. It prepares a clean
# upstream checkout of Annihilator's ES2 Mudlib + Neolith driver for testing.

UPSTREAM_REPO="https://github.com/taedlar/es2_mudlib.git"
WORKDIR="${1:-.runtime/original-es2}"

if [[ -e "$WORKDIR" ]]; then
  echo "ERROR: $WORKDIR already exists. Remove it manually if you intend a fresh bootstrap." >&2
  exit 1
fi

mkdir -p "$(dirname "$WORKDIR")"
git clone --recurse-submodules "$UPSTREAM_REPO" "$WORKDIR"

# Original ES2 keeps account/login data and character/body data separately.
# Prepare both persistent directory trees so a newly created account can be
# saved and then recognized on the next login.
mkdir -p "$WORKDIR/mudlib/data/login"/{a..z}
mkdir -p "$WORKDIR/mudlib/data/login"/{0..9}
mkdir -p "$WORKDIR/mudlib/data/user"/{a..z}
mkdir -p "$WORKDIR/mudlib/data/user"/{0..9}

# ES2-KING design decision: keep the Original source checkout intact as the
# research baseline, but disable the historical anti-spam attribute penalty in
# the prepared executable runtime.
grep -RIl '^[[:space:]]*#define[[:space:]]\+ENABLE_ANTISPAM' "$WORKDIR/mudlib/include" "$WORKDIR/mudlib/adm" 2>/dev/null | while read -r f; do
  sed -i 's/^[[:space:]]*#define[[:space:]]\+ENABLE_ANTISPAM.*/\/\/ ES2-KING: ENABLE_ANTISPAM disabled/' "$f"
done
if grep -R '^[[:space:]]*#define[[:space:]]\+ENABLE_ANTISPAM' "$WORKDIR/mudlib/include" "$WORKDIR/mudlib/adm" 2>/dev/null; then
  echo "ERROR: ENABLE_ANTISPAM is still active in prepared ES2-KING runtime." >&2
  exit 1
fi

cat <<EOF
Original ES2 source prepared at: $WORKDIR
ES2-KING runtime persistence directories prepared: mudlib/data/login/a..z,0..9 and mudlib/data/user/a..z,0..9
ES2-KING runtime policy applied: ENABLE_ANTISPAM disabled

Next build steps (Linux):
  cd $WORKDIR/neolith
  cmake --preset linux-gcc -DBUILD_TESTING=OFF
  cmake --build --preset dev-linux-gcc

Then locate the built neolith executable and run from the ES2 repository root:
  ./neolith/<path-to-built-neolith> -f neolith.conf -c

Do not mark ES2-KING M0 Driver boot as passed until the process actually starts
and the Mudlib loads without a fatal startup error.
EOF
