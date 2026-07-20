#!/bin/sh
set -eu

# opencode's web UI uses the server's cwd as the default project directory,
# and the UI itself has no way to create one — so ensure it exists before start.
: "${OPENCODE_PROJECT_DIR:=$HOME/workspace/default}"

mkdir -p "$OPENCODE_PROJECT_DIR"
cd "$OPENCODE_PROJECT_DIR"

exec opencode "$@"
