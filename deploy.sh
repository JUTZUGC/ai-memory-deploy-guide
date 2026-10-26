#!/usr/bin/env bash
set -euo pipefail
# ai-memory 一键安装脚本（第三方指南）——按官方文档封装
# 官方文档：https://github.com/akitaonrails/ai-memory#quick-start
# 更新日期：2026-10-26
# 类型：script
cd "$(dirname "${BASH_SOURCE[0]}")"

command -v git >/dev/null 2>&1 || { echo "需要先安装 Git"; exit 1; }

mkdir -p .download
cd .download

curl -fsSL https://github.com/akitaonrails/ai-memory/releases/latest/download/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"
ai-memory setup --yes

echo ""

echo "安装完成：重启客户端，问它「这个项目你还记得什么」验证记忆是否生效；改配置可重新运行 ai-memory setup"
echo "若结果异常或需要改配置，请参考官方文档：https://github.com/akitaonrails/ai-memory#quick-start"
