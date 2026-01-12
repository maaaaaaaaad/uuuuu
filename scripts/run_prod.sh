#!/bin/bash
# Run app with production environment

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

ENV_FILE="$PROJECT_ROOT/.env.prod"

if [ ! -f "$ENV_FILE" ]; then
    echo "Error: $ENV_FILE not found"
    echo "Please copy .env.example to .env.prod and fill in the values"
    exit 1
fi

source "$ENV_FILE"

DART_DEFINES=""
DART_DEFINES+="--dart-define=ENV=$ENV "
DART_DEFINES+="--dart-define=API_BASE_URL=$API_BASE_URL "
DART_DEFINES+="--dart-define=KAKAO_NATIVE_APP_KEY=$KAKAO_NATIVE_APP_KEY "

echo "Running in $ENV environment..."
echo "API_BASE_URL: $API_BASE_URL"

flutter run --release $DART_DEFINES "$@"
