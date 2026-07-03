<#
.SYNOPSIS
  Verifica que el proyecto tenga la configuración mínima para ejecutarse.

.DESCRIPTION
  Revisa la existencia de archivos de entorno y assets necesarios.
  No modifica archivos.
#>

[CmdletBinding()]
param()

$errores = 0
$advertencias = 0

function Test-Requerido {
    param([string]$Ruta, [string]$Descripcion)
    if (-not (Test-Path $Ruta)) {
        Write-Host "[ERROR] Falta $Descripcion`: $Ruta" -ForegroundColor Red
        $script:errores++
    } else {
        Write-Host "[OK]    $Descripcion" -ForegroundColor Green
    }
}

function Test-Opcional {
    param([string]$Ruta, [string]$Descripcion)
    if (-not (Test-Path $Ruta)) {
        Write-Host "[WARN]  Falta $Descripcion`: $Ruta (opcional para desarrollo local)" -ForegroundColor Yellow
        $script:advertencias++
    } else {
        Write-Host "[OK]    $Descripcion" -ForegroundColor Green
    }
}

Write-Host "`n=== Verificación de configuración del proyecto ===`n" -ForegroundColor Cyan

Test-Requerido -Ruta ".env.dev" -Descripcion "Variables de entorno de desarrollo"
Test-Requerido -Ruta ".env.prod" -Descripcion "Variables de entorno de producción"
Test-Requerido -Ruta "assets/animations/medical_anim.json" -Descripcion "Animación Lottie de login"

Write-Host "`n=== Verificación de dependencias de Flutter ===`n" -ForegroundColor Cyan

$pubspec = Get-Content "pubspec.yaml" -Raw
$dependencias = @(
    'supabase_flutter',
    'flutter_bloc',
    'get_it',
    'flutter_dotenv'
)

foreach ($dep in $dependencias) {
    if ($pubspec -match "$dep:\s*\^") {
        Write-Host "[OK]    $dep en pubspec.yaml" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] $dep no encontrado en pubspec.yaml" -ForegroundColor Red
        $errores++
    }
}

Write-Host "`n=== Resumen ===" -ForegroundColor Cyan
if ($errores -eq 0 -and $advertencias -eq 0) {
    Write-Host "Todo correcto. Puedes ejecutar 'flutter run'." -ForegroundColor Green
} else {
    Write-Host "Errores: $errores  Advertencias: $advertencias" -ForegroundColor Yellow
    if ($errores -gt 0) {
        Write-Host "Corrige los errores antes de continuar." -ForegroundColor Red
        exit 1
    }
}
