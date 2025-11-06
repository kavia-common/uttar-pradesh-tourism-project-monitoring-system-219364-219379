#!/usr/bin/env bash
# PUBLIC_INTERFACE
# wait_for_pg.sh - Wait for PostgreSQL readiness on a specific host:port using pg_isready.
# Usage:
#   PGHOST=127.0.0.1 PGPORT=5000 ./wait_for_pg.sh [timeout_seconds]
# Description:
#   Uses environment variables PGHOST (default 127.0.0.1) and PGPORT (default 5000).
#   Exits 0 when ready, non-zero on timeout or error.

set -euo pipefail

HOST="${PGHOST:-127.0.0.1}"
PORT="${PGPORT:-5000}"
TIMEOUT="${1:-30}"

PG_VERSION=$(ls /usr/lib/postgresql/ 2>/dev/null | head -1 || true)
if [ -z "${PG_VERSION}" ]; then
  echo "pg_isready not found: PostgreSQL binaries are not installed"
  exit 2
fi
PG_BIN="/usr/lib/postgresql/${PG_VERSION}/bin"

echo "Waiting for PostgreSQL to be ready at ${HOST}:${PORT} (timeout=${TIMEOUT}s)..."

START=$(date +%s)
while true; do
  if sudo -u postgres "${PG_BIN}/pg_isready" -h "${HOST}" -p "${PORT}" >/dev/null 2>&1; then
    echo "PostgreSQL is ready at ${HOST}:${PORT}"
    exit 0
  fi
  NOW=$(date +%s)
  ELAPSED=$((NOW - START))
  if [ "${ELAPSED}" -ge "${TIMEOUT}" ]; then
    echo "Timed out waiting for PostgreSQL at ${HOST}:${PORT} after ${ELAPSED}s"
    exit 1
  fi
  sleep 1
done
