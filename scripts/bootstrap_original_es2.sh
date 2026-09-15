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

cat <<EOF
Original ES2 source prepared at: $WORKDIR

Next build steps (Linux):
  cd $WORKDIR/neolith
  cmake --preset linux -DBUILD_TESTING=OFF
  cmake --build --preset dev-linux

Then locate the built neolith executable and run from the ES2 repository root:
  ./neolith/<path-to-built-neolith> -f neolith.conf -c

Do not mark ES2-KING M0 Driver boot as passed until the process actually starts
and the Mudlib loads without a fatal startup error.
EOF
