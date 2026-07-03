<#
.SYNOPSIS
  Despliega la Edge Function send-push-notification a Supabase.

.DESCRIPTION
  Requiere que estés autenticado en Supabase CLI (`supabase login`).
  Crea la función si no existe y la despliega.
#>

[CmdletBinding()]
param(
    [string]$FunctionName = 'send-push-notification',
    [string]$SourceFile = 'docs/supabase/edge-functions/send-push-notification.ts',
    [string]$ProjectId = ''
)

function Test-Command {
    param([string]$Name)
    $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

if (-not (Test-Command 'supabase')) {
    Write-Error "Supabase CLI no encontrado. Instálalo desde https://supabase.com/docs/guides/cli"
    exit 1
}

if (-not (Test-Path $SourceFile)) {
    Write-Error "No se encontró el archivo fuente: $SourceFile"
    exit 1
}

$functionDir = "supabase/functions/$FunctionName"
if (-not (Test-Path $functionDir)) {
    Write-Host "Creando función $FunctionName..." -ForegroundColor Cyan
    New-Item -ItemType Directory -Path $functionDir -Force | Out-Null
}

Copy-Item -Path $SourceFile -Destination "$functionDir/index.ts" -Force
Write-Host "Archivo fuente copiado a $functionDir/index.ts" -ForegroundColor Green

$deployArgs = @('functions', 'deploy', $FunctionName)
if ($ProjectId) {
    $deployArgs += '--project-ref'
    $deployArgs += $ProjectId
}

Write-Host "Ejecutando: supabase $deployArgs" -ForegroundColor Cyan
& supabase @deployArgs

if ($LASTEXITCODE -ne 0) {
    Write-Error "El despliegue falló. Revisa los mensajes de error arriba."
    exit $LASTEXITCODE
}

Write-Host "`nEdge Function '$FunctionName' desplegada correctamente." -ForegroundColor Green
Write-Host "Recuerda configurar los secrets:"
Write-Host "  supabase secrets set FCM_SERVICE_ACCOUNT='<JSON>'"
Write-Host "  supabase secrets set FCM_PROJECT_ID='<ID>'"
