# ==========================================
# # ==========================================
# FTEK - SUPORTE TECNICO
# Autor: Fabio Araujo
# Uso exclusivo FTEK
# Proibida copia ou redistribuicao sem autorizacao
# ==========================================

# ==========================================

# ---------- AUTOELEVACAO ----------
if (-not ([Security.Principal.WindowsPrincipal] `
    [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {

    Start-Process powershell.exe `
        -ArgumentList "-NoExit -ExecutionPolicy Bypass -File `"$PSCommandPath`"" `
        -Verb RunAs
    exit
}

# ---------- DESKTOP REAL ----------
$Desktop = [Environment]::GetFolderPath("Desktop")
$DataHora = Get-Date -Format "yyyy-MM-dd_HH-mm"
$Relatorio = "$Desktop\FTEK_Relatorio_$DataHora.txt"

function Add-Relatorio {
    param ($Texto)
    Add-Content -Path $Relatorio -Value $Texto
}

# ---------- BANNER ----------
function Mostrar-Banner {
    Clear-Host
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host "        FTEK - SUPORTE TECNICO" -ForegroundColor Green
    Write-Host "==========================================" -ForegroundColor Cyan
    Write-Host ""
}

# ---------- FUNCOES DE EXIBICAO ----------
function Info-Sistema {
    Write-Host "Computador : $env:COMPUTERNAME"
    Write-Host "Usuario    : $env:USERNAME"
    Write-Host "Sistema    : $([System.Environment]::OSVersion.VersionString)"
    Write-Host "Data/Hora  : $(Get-Date)"
}

function Info-Rede {
    $adapters = Get-WmiObject Win32_NetworkAdapterConfiguration |
                Where-Object { $_.IPEnabled -eq $true }

    foreach ($a in $adapters) {
        Write-Host "Adaptador : $($a.Description)"
        Write-Host "MAC       : $($a.MACAddress)"
        Write-Host "IP        : $($a.IPAddress[0])"
        Write-Host "Gateway   : $($a.DefaultIPGateway)"
        Write-Host "DNS       : $($a.DNSServerSearchOrder -join ', ')"
        Write-Host "------------------------------------------"
    }
}

function Info-Disco {
    $discos = Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3"

    foreach ($d in $discos) {
        $total = [math]::Round($d.Size / 1GB, 2)
        $livre = [math]::Round($d.FreeSpace / 1GB, 2)
        $usado = [math]::Round($total - $livre, 2)

        Write-Host "Unidade : $($d.DeviceID)"
        Write-Host "Total   : $total GB"
        Write-Host "Usado   : $usado GB"
        Write-Host "Livre   : $livre GB"
        Write-Host "------------------------------------------"
    }
}

function Limpeza-Cache {
    Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Remove-Item "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue

    Stop-Service wuauserv -Force
    Remove-Item "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue
    Start-Service wuauserv

    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
}

# ---------- GERAR RELATORIO (CORRETO) ----------
function Gerar-Relatorio {

    if (Test-Path $Relatorio) {
        Remove-Item $Relatorio -Force
    }

    Add-Relatorio "RELATORIO FTEK - SUPORTE TECNICO"
    Add-Relatorio "Gerado em: $(Get-Date)"
    Add-Relatorio "=========================================="
    Add-Relatorio ""

    Add-Relatorio "=== INFORMACOES DO SISTEMA ==="
    Add-Relatorio "Computador : $env:COMPUTERNAME"
    Add-Relatorio "Usuario    : $env:USERNAME"
    Add-Relatorio "Sistema    : $([System.Environment]::OSVersion.VersionString)"
    Add-Relatorio "Data/Hora  : $(Get-Date)"
    Add-Relatorio ""

    Add-Relatorio "=== INFORMACOES DE REDE ==="
    $adapters = Get-WmiObject Win32_NetworkAdapterConfiguration |
                Where-Object { $_.IPEnabled -eq $true }

    foreach ($a in $adapters) {
        Add-Relatorio "Adaptador : $($a.Description)"
        Add-Relatorio "MAC       : $($a.MACAddress)"
        Add-Relatorio "IP        : $($a.IPAddress[0])"
        Add-Relatorio "Gateway   : $($a.DefaultIPGateway)"
        Add-Relatorio "DNS       : $($a.DNSServerSearchOrder -join ', ')"
        Add-Relatorio "------------------------------------------"
    }

    Add-Relatorio ""
    Add-Relatorio "=== ESPACO EM DISCO ==="
    $discos = Get-WmiObject Win32_LogicalDisk -Filter "DriveType=3"

    foreach ($d in $discos) {
        $total = [math]::Round($d.Size / 1GB, 2)
        $livre = [math]::Round($d.FreeSpace / 1GB, 2)
        $usado = [math]::Round($total - $livre, 2)

        Add-Relatorio "Unidade : $($d.DeviceID)"
        Add-Relatorio "Total   : $total GB"
        Add-Relatorio "Usado   : $usado GB"
        Add-Relatorio "Livre   : $livre GB"
        Add-Relatorio "------------------------------------------"
    }

    Add-Relatorio ""
    Add-Relatorio "=== LIMPEZA DE CACHE ==="
    Add-Relatorio "Limpeza executada com sucesso"
}

# ---------- MENU ----------
do {
    Mostrar-Banner
    Write-Host "1 - Informações do Sistema"
    Write-Host "2 - Informações de Rede"
    Write-Host "3 - Espaco em Disco"
    Write-Host "4 - Gerar Relatorio Completo"
    Write-Host "5 - Limpeza de Cache"
    Write-Host "0 - Sair"
    Write-Host ""

    $opcao = Read-Host "Escolha uma opção"
    Mostrar-Banner

    switch ($opcao) {
        "1" { Info-Sistema }
        "2" { Info-Rede }
        "3" { Info-Disco }
        "4" {
            Gerar-Relatorio
            Write-Host "Relatorio gerado com sucesso!" -ForegroundColor Green
            Write-Host $Relatorio -ForegroundColor Yellow
        }
        "5" {
            Limpeza-Cache
            Write-Host "Limpeza realizada com sucesso!" -ForegroundColor Green
        }
        "0" {
    Write-Host "Saindo..."
    exit
}

        default { Write-Host "Opcao invalida" -ForegroundColor Red }
    }

    Read-Host "Pressione ENTER para voltar ao menu"
}
while ($true)



