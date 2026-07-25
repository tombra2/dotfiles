#!/usr/bin/env bash
set -euo pipefail
ROOT_DIR="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "Fehler: Aktuelles Verzeichnis gehört zu keinem Git-Repository."
  exit 1
}
ENV_FILE="$ROOT_DIR/.env"
if [[ ! -f "$ENV_FILE" ]]; then
  echo "Fehler: $ENV_FILE fehlt. Erstelle sie anhand von .env.example."
  exit 1
fi
set -a
source "$ENV_FILE"
set +a
cd "$ROOT_DIR/backend"
exec ./mvnw spring-boot:run
