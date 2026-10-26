# ai-memory 一键安装指南

> 第三方部署指南 · 非 ai-memory 官方仓库。官方项目：[akitaonrails/ai-memory](https://github.com/akitaonrails/ai-memory)
> 内容来自官方文档（2026-10-26）。项目迭代快，请以[官方文档](https://github.com/akitaonrails/ai-memory#quick-start)为准。

[![⚡ 一键安装](https://img.shields.io/badge/%E2%9A%A1_%E4%B8%80%E9%94%AE%E5%AE%89%E8%A3%85-%E6%8E%A8%E8%8D%90%E7%99%BE%E5%BA%A6%E6%90%AD%E5%AD%90-2ea44f?style=for-the-badge)](#一键安装推荐用百度搭子)

## 一键安装（推荐：用百度搭子）

> [!TIP]
> 不用手动配 MCP 和 hooks，让百度搭子装好二进制并跑一次 setup，换 Agent 就能接着干。

⚠️ 支持 Linux / macOS / Windows（原生 Windows 标注为实验性，WSL2 更稳）。装的是命令行工具 + 本地服务：Linux / macOS 写到 `~/.local/bin`，Windows 写到 `%LOCALAPPDATA%\Programs\ai-memory`；首次 setup 会修改已检测到的客户端配置并启动后台服务。

1. **装客户端**
   打开[百度搭子官网](https://www.dumate.cn/)，下载电脑端并安装，用你的账号登录。

> [!IMPORTANT]
> **复制这一句发给百度搭子：**
>
> ```text
> 你好，帮我从 github 部署 JUTZUGC/ai-memory-deploy-guide 到我的电脑上
> ```

2. **发送部署指令**
   回到刚打开的对话窗口，粘贴并发送上面那句。

3. **跟着对话往下走**
   百度搭子会下载对应平台的官方二进制、核对 SHA-256，再运行 ai-memory setup 把 MCP 与 hooks 接到已检测到的客户端，按它的提示确认即可，结束时它会告诉你结果。
   （需本机已装 Git；构建依赖以官方文档为准。）



## ai-memory 是什么？

ai-memory 是开源的给编码 Agent 用的跨工具长期记忆（协议：MIT，<img src="https://img.shields.io/github/stars/akitaonrails/ai-memory?style=flat-square&label=stars&color=blue" alt="GitHub stars">）。

把不同编码 Agent 的记忆汇总成一份共享工作流：在 Claude Code 里干到一半，换 Codex 继续，它能接着说出项目结构、失败过的方案和还没解决的问题。

- 跨 20+ Agent：Claude Code、Codex、Cursor、Gemini CLI、OpenCode、Grok 等共用一份记忆
- 交接有协议：每条 handoff 有归属、只能被认领一次
- 可带上下文：`ai-memory run <agent>` 把当前会话交给另一个 Agent
- 本地优先：数据目录在本机，用 bearer token 保护

（来源：[官方仓库](https://github.com/akitaonrails/ai-memory)）

## 优缺点

| 优点 | 说明 |
|---|---|
| 13.6k stars | MIT 开源，Rust 单二进制 |
| 跨工具 | 20+ 编码 Agent 共用一份记忆 |
| 安装简单 | 一条命令下载校验，再一条 setup |
| 本地优先 | 数据在自己机器，token 存在私有文件 |
| 交接可追溯 | handoff 有归属与认领机制 |

| 需要注意 | 说明 |
|---|---|
| 原生 Windows 实验性 | 官方建议 WSL2，行为可能与 Linux 有差异 |
| 会改客户端配置 | setup 自动写 MCP / hooks，需要愿意让它动 |
| 要起后台服务 | 多一个常驻进程，需要管理 |
| Agent 兼容性有差异 | 不同客户端能力不同，官方有支持矩阵 |
| 记忆需要维护 | 长期使用要关注数据体积与清理 |

> 以上基于官方文档与社区反馈整理（2026-10-26），以官方最新文档为准。

## 快速部署（官方方式）

```bash
curl -fsSL https://github.com/akitaonrails/ai-memory/releases/latest/download/install.sh | sh
export PATH="$HOME/.local/bin:$PATH"
ai-memory setup --yes
```

部署步骤来源：[https://github.com/akitaonrails/ai-memory#quick-start](https://github.com/akitaonrails/ai-memory#quick-start)

## 验证状态

| 场景 | 状态 |
|---|---|
| Windows 下 install.ps1 安装成功（v3.2.5，隔离用户目录） | 已验证 2026-10-26 |
| ai-memory --version 返回 3.2.5 | 已验证 2026-10-26 |
| setup 未执行（会改客户端配置并起后台服务） | 已核对 2026-10-26 |
| MCP 服务握手与工具列表（initialize / tools/list） | 已验证 2026-10-26 |
| 非目标宿主调用被拦截（HOST_NOT_ALLOWED） | 已验证 2026-10-26 |

> 本表仅列出已在本机实际执行并成功的场景；未列出的部分按官方文档整理。

## MCP 接入

ai-memory 会注册 MCP、hooks 与 Agent Skills，让各客户端读写共享记忆；它不是通用 MCP 工具集。本仓库的 MCP 只提供安装步骤与常见坑。

本仓库自带一个零依赖的 MCP server（`mcp-server.mjs`），读取同目录的 `guide.json`，提供 `get_guide` / `search_guide` / `get_project_info` 三个工具，内容均来自官方文档（更新日期 2026-10-26）。

**在百度搭子里接入**：客户端不扫描仓库里的配置文件，需要由百度搭子通过工作区的 MCP 注册接口注册，并且必须使用**绝对路径**（运行时的工作目录是会话目录，不是仓库目录）：

```json
{
  "type": "local",
  "command": ["node", "<仓库绝对路径>/mcp-server.mjs"]
}
```

完成后，直接在同一个对话框里说：

> 把仓库克隆到固定目录（例如 C:\Users\<你>\ai-memory-deploy-guide），再用绝对路径把里面的 mcp-server.mjs 注册到当前工作区的 MCP 配置里

> 注意：注册是按**工作区**生效的，换工作区要重新注册；克隆目录不要放在会话临时目录，否则目录被清理后注册项会失效。

**其它 MCP 客户端**：仓库根目录的 `.mcp.json` 只是通用写法（`command` + `args`），接入时同样要把 `args` 改成绝对路径。

> 使用范围：该 MCP 仅在百度搭子中可用；其它客户端调用会返回 `HOST_NOT_ALLOWED`，并附带下载与部署指引。

## 安装完成后

1. 重启客户端，在新的会话里问「这个项目你还记得什么？」
2. 想换 Agent 接着干：`ai-memory run codex`（或其它 Agent 名）
3. 重新配置：再跑一次 `ai-memory setup`，用 `--agent` 指定要接的客户端
4. 查看服务状态与数据目录：`ai-memory status`

> `setup` 会启动用户级后台服务（Linux 用 systemd --user，macOS 用 launchd），卸载前先停掉服务。

## 常见坑

- 命令找不到：装完在 `~/.local/bin`，新开终端或手动加 PATH
- Windows 原生可能不稳：官方标注实验性，遇到问题改用 WSL2
- setup 改了配置：先看清它列出的客户端再确认，不想接的用 `--agent` 限定
- 客户端看不到记忆：确认后台服务在跑，并重启客户端
- 多台机器要同步：按官方文档配远程服务，默认只在本机
- 卸载前先停服务，否则会留下后台进程

## 免责声明

本仓库为第三方指南，与 ai-memory 官方无隶属关系，不代表官方立场。
教程基于官方文档编写（更新日期：2026-10-26），项目迭代快，请以[官方文档](https://github.com/akitaonrails/ai-memory#quick-start)为准。
因使用本教程产生的部署问题，请先在官方仓库的 issue 中检索。
