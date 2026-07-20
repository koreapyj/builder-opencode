#!/bin/sh
set -eu

# opencode's web UI uses the server's cwd as the default project directory,
# and the UI itself has no way to create one — so ensure it exists before start.
: "${OPENCODE_PROJECT_DIR:=$HOME/workspace/default}"

mkdir -p "$OPENCODE_PROJECT_DIR"
cd "$OPENCODE_PROJECT_DIR"

# Install image-provided global slash commands (e.g. /restart). Copied on every
# start because the PVC mounted at $HOME shadows anything baked into the image.
if [ -d /usr/local/share/opencode/commands ]; then
  mkdir -p "$HOME/.config/opencode/commands"
  cp /usr/local/share/opencode/commands/*.md "$HOME/.config/opencode/commands/"
fi

# Supervisor loop: opencode runs as a child, not PID 1, so anything inside the
# container (including an opencode agent) can restart the server without the
# container exiting:
#   restart-opencode        -> kill + auto-restart in ~1s
#   touch /tmp/opencode.exit; restart-opencode -> stop loop, container exits
EXIT_SENTINEL=/tmp/opencode.exit
rm -f "$EXIT_SENTINEL"

# Forward pod termination (SIGTERM from kubelet) to opencode and exit the loop.
trap 'touch "$EXIT_SENTINEL"; [ -n "${child:-}" ] && kill "$child" 2>/dev/null' TERM INT

while :; do
  opencode "$@" &
  child=$!
  wait "$child" || true
  [ -e "$EXIT_SENTINEL" ] && exit 0
  echo "opencode exited; restarting in 1s (touch $EXIT_SENTINEL to stop)" >&2
  sleep 1
done
