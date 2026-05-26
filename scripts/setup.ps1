# 克隆仓库后于 PowerShell 中执行一次（尽量自动安装 Node.js + npm 依赖）
#   Set-ExecutionPolicy -Scope CurrentUser RemoteSigned   # 若脚本无法运行
#   .\scripts\setup.ps1

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$MinNodeMajor = 18

function Get-NodeMajor {
    $v = (node -v) -replace "^v", ""
    return [int]($v.Split(".")[0])
}

function Test-UsableNode {
    if (-not (Get-Command node -ErrorAction SilentlyContinue)) { return $false }
    if (-not (Get-Command npm -ErrorAction SilentlyContinue)) { return $false }
    return (Get-NodeMajor) -ge $MinNodeMajor
}

function Install-NodeWindows {
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "正在通过 winget 安装 Node.js LTS（可能需要几分钟）…" -ForegroundColor Cyan
        winget install OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("Path", "User")
        return
    }
    if (Get-Command choco -ErrorAction SilentlyContinue) {
        Write-Host "正在通过 Chocolatey 安装 Node.js LTS…" -ForegroundColor Cyan
        choco install nodejs-lts -y
        return
    }
    throw "未检测到 winget 或 Chocolatey。请从 https://nodejs.org/ 安装 Node.js ${MinNodeMajor}+，或安装 winget 后重试。"
}

function Ensure-Node {
    if (Test-UsableNode) {
        Write-Host "Node.js $(node -v) 已就绪" -ForegroundColor Green
        return
    }
    if ($env:AUTO_INSTALL_NODE -ne "0") {
        Install-NodeWindows
    }
    if (-not (Test-UsableNode)) {
        throw "Node.js ${MinNodeMajor}+ 仍不可用。请关闭并重新打开终端后重试，或手动安装：https://nodejs.org/"
    }
    Write-Host "Node.js $(node -v) 已就绪" -ForegroundColor Green
}

function Ensure-NpmDeps {
    $modules = Join-Path $ScriptDir "node_modules\md-to-pdf"
    if (Test-Path $modules) { return }
    Write-Host "正在安装 PDF 导出依赖（约 1–3 分钟，仅需一次）…" -ForegroundColor Cyan
    Push-Location $ScriptDir
    try {
        if (Test-Path "package-lock.json") {
            npm ci --omit=dev --no-fund --no-audit
        } else {
            npm install --omit=dev --no-fund --no-audit
        }
    } finally {
        Pop-Location
    }
}

Write-Host "==> 检查 Node.js …" -ForegroundColor Cyan
Ensure-Node

Write-Host "==> 安装 PDF 导出依赖 …" -ForegroundColor Cyan
Ensure-NpmDeps

Write-Host ""
Write-Host "环境已就绪。导出示例：" -ForegroundColor Green
Write-Host "  node scripts\export-resume.mjs -i 面试官\候选人简历\2026-5-15-丛思羽.md"
Write-Host "或在 Cursor 中使用: /简历导出PDF @你的简历.md"
