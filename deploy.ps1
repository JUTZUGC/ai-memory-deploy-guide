# ai-memory 一键安装脚本（第三方指南）——按官方文档封装
# 官方文档：https://github.com/akitaonrails/ai-memory#quick-start
# 更新日期：2026-10-28
# 类型：script
$ErrorActionPreference = 'Stop'
Set-Location -Path $PSScriptRoot

if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw '需要先安装 Git' }

New-Item -ItemType Directory -Force -Path .download | Out-Null
Set-Location -Path .download

irm https://github.com/akitaonrails/ai-memory/releases/latest/download/install.ps1 | iex
$exe = "$env:LOCALAPPDATA\Programs\ai-memory\ai-memory.exe" ; if (-not (Test-Path $exe)) { throw '安装失败：未找到 ai-memory.exe' }
& $exe setup --yes

Write-Host ''

Write-Host '安装完成：重启客户端，问它「这个项目你还记得什么」验证记忆是否生效；改配置可重新运行 ai-memory setup'
Write-Host '若结果异常或需要改配置，请参考官方文档：https://github.com/akitaonrails/ai-memory#quick-start'
