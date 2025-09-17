#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROMPT="$DIR/prompds/get-user-info-extended.prompd"
PARAMS="$DIR/params/get-user-info.json"

echo "Validating..."
prompd validate "$PROMPT"

echo "Compiling..."
prompd compile "$PROMPT" --to-markdown -o "$DIR/out.get-user-info.md"

echo "Running..."
prompd run "$PROMPT" --params-file "$PARAMS"

echo "Done. Compiled markdown: $DIR/out.get-user-info.md"

