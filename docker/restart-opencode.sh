#!/bin/sh
# Restart the opencode server managed by entrypoint.sh's supervisor loop.
# Usable from inside the container by anyone, including opencode agents.
set -eu

pid=$(pgrep -x opencode | head -n 1 || true)
if [ -z "$pid" ]; then
  echo "opencode is not running; supervisor will start it shortly" >&2
  exit 0
fi

kill "$pid"
echo "opencode (pid $pid) signalled; supervisor restarts it in ~1s"
