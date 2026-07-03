#!/usr/bin/env bash
set -euo pipefail

FUNCTION_NAME="${1:-send-push-notification}"
SOURCE_FILE="${2:-docs/supabase/edge-functions/send-push-notification.ts}"
PROJECT_ID="${3:-}"

if ! command -v supabase &> /dev/null; then
    echo "Error: Supabase CLI no encontrado. Instálalo desde https://supabase.com/docs/guides/cli"
    exit 1
fi

if [ ! -f "$SOURCE_FILE" ]; then
    echo "Error: No se encontró el archivo fuente: $SOURCE_FILE"
    exit 1
fi

FUNCTION_DIR="supabase/functions/$FUNCTION_NAME"
mkdir -p "$FUNCTION_DIR"
cp "$SOURCE_FILE" "$FUNCTION_DIR/index.ts"
echo "Archivo fuente copiado a $FUNCTION_DIR/index.ts"

DEPLOY_ARGS=("functions" "deploy" "$FUNCTION_NAME")
if [ -n "$PROJECT_ID" ]; then
    DEPLOY_ARGS+=("--project-ref" "$PROJECT_ID")
fi

echo "Ejecutando: supabase ${DEPLOY_ARGS[*]}"
supabase "${DEPLOY_ARGS[@]}"

echo ""
echo "Edge Function '$FUNCTION_NAME' desplegada correctamente."
echo "Recuerda configurar los secrets:"
echo "  supabase secrets set FCM_SERVICE_ACCOUNT='<JSON>'"
echo "  supabase secrets set FCM_PROJECT_ID='<ID>'"
