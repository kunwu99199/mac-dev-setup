# 🚀 Mac Dev Setup — 一键配置你的 macOS 开发环境

> 一条命令搞定 Homebrew + Python + Node.js + Docker + 更多开发工具

```bash
curl -fsSL https://raw.githubusercontent.com/kunwu8/mac-dev-setup/main/setup.sh | bash
```

[![USDT (TRC-20)](https://img.shields.io/badge/USDT_TRC20-26A17B?style=for-the-badge&logo=tether&logoColor=white)](https://github.com/kunwu99199/mac-dev-setup#%E6%94%AF%E6%8C%81%E8%BF%99%E4%B8%AA%E9%A1%B9%E7%9B%AE)

---

## ✨ 功能

| 模块 | 内容 |
|------|------|
| 🍺 **Homebrew** | 包管理器 + 自动安装 Command Line Tools |
| 🐍 **Python** | pyenv + 最新 Python（3.12/3.13） |
| 🟢 **Node.js** | nvm + 最新 LTS Node |
| 🐳 **Docker** | Docker Desktop（可选） |
| 🔧 **Shell** | Oh My Zsh + 实用插件 |
| 🧰 **实用工具** | git, wget, jq, tree, ripgrep, htop, tmux 等 |
| ☁️ **云/容器** | kubectl, kind, terraform（可选） |

## 🚀 快速开始

### 一键安装（推荐）

```bash
curl -fsSL https://raw.githubusercontent.com/kunwu8/mac-dev-setup/main/setup.sh | bash
```

### 分步安装

```bash
# 1. 克隆仓库
git clone https://github.com/kunwu8/mac-dev-setup.git
cd mac-dev-setup

# 2. 给权限
chmod +x setup.sh

# 3. 运行
./setup.sh
```

### 仅安装特定模块

```bash
# 只装 Homebrew + Python
./setup.sh --only brew,python

# 跳过 Docker（快速安装）
./setup.sh --skip docker
```

## 📋 支持的 macOS 版本

- macOS 13 (Ventura) ✅
- macOS 14 (Sonoma) ✅
- macOS 15 (Sequoia) ✅
- 支持 Apple Silicon (M1/M2/M3/M4) 和 Intel

## ⚙️ 自定义

复制 `env.example` 为 `.env`，按需配置：

```bash
# 选择要安装的模块
INSTALL_BREW=true
INSTALL_PYTHON=true
INSTALL_NODE=true
INSTALL_DOCKER=false
INSTALL_SHELL=true
INSTALL_TOOLS=true
INSTALL_CLOUD=false
```

## 🧪 安装后验证

```bash
brew --version          # Homebrew
python --version        # Python
node --version          # Node.js
docker --version        # Docker
```

## ❤️ 支持这个项目

如果这个脚本帮你省了配置环境的 30 分钟，欢迎投喂 ☕

**USDT (TRC-20):**
```
TPt188ET91SCS9wJCk6C27sAqzKEB4CLfn
```

[![USDT (TRC-20)](https://img.shields.io/badge/donate-USDT_TRC20-26A17B?style=for-the-badge&logo=tether&logoColor=white)](https://github.com/kunwu99199/mac-dev-setup#%E6%94%AF%E6%8C%81%E8%BF%99%E4%B8%AA%E9%A1%B9%E7%9B%AE)

## 📄 许可证

MIT
