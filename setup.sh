#!/bin/bash
# =============================================================================
# Mac Dev Setup — 一键 macOS 开发环境配置脚本
# 支持: macOS 13+ (Apple Silicon & Intel)
# 用法: curl -fsSL https://raw.githubusercontent.com/kunwu8/mac-dev-setup/main/setup.sh | bash
# =============================================================================

set -euo pipefail

# ─── 颜色 ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

info()  { echo -e "${BLUE}[INFO]${NC} $1"; }
ok()    { echo -e "${GREEN}[OK]${NC} $1"; }
warn()  { echo -e "${YELLOW}[WARN]${NC} $1"; }
err()   { echo -e "${RED}[ERROR]${NC} $1"; }
section() { echo -e "\n${CYAN}═══════════════════════════════════════════${NC}"; echo -e "${CYAN}  $1${NC}"; echo -e "${CYAN}═══════════════════════════════════════════${NC}\n"; }

# ─── 加载 .env ────────────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"

if [ -f "$ENV_FILE" ]; then
  source "$ENV_FILE"
  info "已加载 .env 配置文件"
fi

# 默认配置（可通过 .env 覆盖）
INSTALL_BREW=${INSTALL_BREW:-true}
INSTALL_PYTHON=${INSTALL_PYTHON:-true}
INSTALL_NODE=${INSTALL_NODE:-true}
INSTALL_DOCKER=${INSTALL_DOCKER:-false}
INSTALL_SHELL=${INSTALL_SHELL:-false}
INSTALL_TOOLS=${INSTALL_TOOLS:-true}
INSTALL_CLOUD=${INSTALL_CLOUD:-false}

# ─── 命令行参数解析 ──────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --only)
      IFS=',' read -ra MODULES <<< "$2"
      INSTALL_BREW=false; INSTALL_PYTHON=false; INSTALL_NODE=false
      INSTALL_DOCKER=false; INSTALL_SHELL=false; INSTALL_TOOLS=false; INSTALL_CLOUD=false
      for m in "${MODULES[@]}"; do
        case "$m" in
          brew)    INSTALL_BREW=true ;;
          python)  INSTALL_PYTHON=true ;;
          node)    INSTALL_NODE=true ;;
          docker)  INSTALL_DOCKER=true ;;
          shell)   INSTALL_SHELL=true ;;
          tools)   INSTALL_TOOLS=true ;;
          cloud)   INSTALL_CLOUD=true ;;
        esac
      done
      shift 2 ;;
    --skip)
      IFS=',' read -ra SKIP <<< "$2"
      for s in "${SKIP[@]}"; do
        case "$s" in
          brew)    INSTALL_BREW=false ;;
          python)  INSTALL_PYTHON=false ;;
          node)    INSTALL_NODE=false ;;
          docker)  INSTALL_DOCKER=false ;;
          shell)   INSTALL_SHELL=false ;;
          tools)   INSTALL_TOOLS=false ;;
          cloud)   INSTALL_CLOUD=false ;;
        esac
      done
      shift 2 ;;
    --help|-h)
      echo "用法: ./setup.sh [选项]"
      echo "  --only brew,python     只安装指定模块"
      echo "  --skip docker          跳过指定模块"
      echo "  --help, -h             显示帮助"
      exit 0 ;;
    *)
      err "未知参数: $1"
      echo "用法: ./setup.sh [--only module1,module2] [--skip module1]"
      exit 1 ;;
  esac
done

# ─── Banner ─────────────────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}"
echo "  ╔══════════════════════════════════════╗"
echo "  ║      Mac Dev Setup  v1.0             ║"
echo "  ║  一键 macOS 开发环境配置              ║"
echo "  ╚══════════════════════════════════════╝"
echo -e "${NC}"
echo "  系统: $(sw_vers -productName) $(sw_vers -productVersion)"
echo "  架构: $(uname -m)"
echo "  时间: $(date)"
echo ""

# ─── 1. 检测 macOS ──────────────────────────────────────────────────────────
section "🔍 系统检测"

OS="$(uname -s)"
if [ "$OS" != "Darwin" ]; then
  err "这个脚本仅支持 macOS。当前系统: $OS"
  exit 1
fi
ok "macOS $(sw_vers -productVersion)"

# ─── 2. Homebrew ────────────────────────────────────────────────────────────
if [ "$INSTALL_BREW" = true ]; then
  section "🍺 安装 Homebrew"

  if command -v brew &>/dev/null; then
    ok "Homebrew 已安装 ($(brew --version | head -1))"
  else
    info "正在安装 Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || {
      err "Homebrew 安装失败"
      exit 1
    }

    # 添加 Homebrew 到 PATH
    if [ "$(uname -m)" = "arm64" ]; then
      echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
      eval "$(/opt/homebrew/bin/brew shellenv)"
    else
      echo 'eval "$(/usr/local/bin/brew shellenv)"' >> "$HOME/.zprofile"
      eval "$(/usr/local/bin/brew shellenv)"
    fi
    ok "Homebrew 安装完成"
  fi

  # 更新 Homebrew
  info "更新 Homebrew..."
  brew update --quiet
  ok "Homebrew 已更新"
fi

# ─── 3. 基础工具 ────────────────────────────────────────────────────────────
if [ "$INSTALL_TOOLS" = true ]; then
  section "🧰 安装基础工具"

  TOOLS=(git wget curl jq tree ripgrep htop tmux bat)

  for tool in "${TOOLS[@]}"; do
    if command -v "$tool" &>/dev/null; then
      ok "$tool 已安装"
    else
      info "安装 $tool..."
      brew install "$tool" --quiet 2>/dev/null || warn "$tool 安装失败（非必需）"
    fi
  done
  ok "基础工具安装完成"
fi

# ─── 4. Python ──────────────────────────────────────────────────────────────
if [ "$INSTALL_PYTHON" = true ]; then
  section "🐍 安装 Python"

  # pyenv
  if command -v pyenv &>/dev/null; then
    ok "pyenv 已安装"
  else
    info "安装 pyenv..."
    brew install pyenv --quiet
    echo 'export PYENV_ROOT="$HOME/.pyenv"' >> "$HOME/.zprofile"
    echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> "$HOME/.zprofile"
    echo 'eval "$(pyenv init -)"' >> "$HOME/.zprofile"
    ok "pyenv 安装完成"
  fi

  # 安装最新 Python
  PYTHON_LATEST=$(pyenv install --list | grep -E '^\s*3\.1[0-9]\.[0-9]+$' | tail -1 | tr -d ' ')
  if [ -n "$PYTHON_LATEST" ]; then
    if pyenv versions | grep -q "$PYTHON_LATEST"; then
      ok "Python $PYTHON_LATEST 已安装"
    else
      info "安装 Python $PYTHON_LATEST（可能需要几分钟）..."
      pyenv install "$PYTHON_LATEST" -s
      pyenv global "$PYTHON_LATEST"
      ok "Python $PYTHON_LATEST 安装完成"
    fi
  fi

  python --version 2>/dev/null && ok "Python: $(python --version 2>&1)" || warn "Python 未在 PATH 中"
fi

# ─── 5. Node.js ─────────────────────────────────────────────────────────────
if [ "$INSTALL_NODE" = true ]; then
  section "🟢 安装 Node.js"

  # nvm
  if [ -d "$HOME/.nvm" ]; then
    ok "nvm 已安装"
  else
    info "安装 nvm..."
    curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
    ok "nvm 安装完成"
  fi

  # 加载 nvm
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

  # 安装最新的 LTS Node
  if command -v node &>/dev/null; then
    ok "Node.js: $(node --version)"
  else
    info "安装 Node.js LTS..."
    nvm install --lts --default
    ok "Node.js $(node --version) 安装完成"
  fi
fi

# ─── 6. Docker ──────────────────────────────────────────────────────────────
if [ "$INSTALL_DOCKER" = true ]; then
  section "🐳 安装 Docker"

  if command -v docker &>/dev/null; then
    ok "Docker 已安装"
  else
    info "正在安装 Docker Desktop..."
    brew install --cask docker --quiet
    warn "Docker Desktop 已安装，请手动打开应用完成首次设置"
    warn "打开后: 启动 Docker → 同意条款 → 等待引擎启动"
  fi
fi

# ─── 7. Shell 增强 ──────────────────────────────────────────────────────────
if [ "$INSTALL_SHELL" = true ]; then
  section "🔧 Shell 增强"

  # Oh My Zsh
  if [ -d "$HOME/.oh-my-zsh" ]; then
    ok "Oh My Zsh 已安装"
  else
    info "安装 Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    ok "Oh My Zsh 安装完成"
  fi

  # 实用插件
  ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  # zsh-autosuggestions
  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    info "安装 zsh-autosuggestions..."
    git clone --quiet https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  fi

  # zsh-syntax-highlighting
  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    info "安装 zsh-syntax-highlighting..."
    git clone --quiet https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
  fi

  # 启用插件
  sed -i '' 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$HOME/.zshrc" 2>/dev/null || true

  ok "Shell 增强配置完成"
fi

# ─── 8. 云工具（可选） ──────────────────────────────────────────────────────
if [ "$INSTALL_CLOUD" = true ]; then
  section "☁️ 安装云/容器工具"

  TOOLS_CLI=(kubectl kind terraform)
  for tool in "${TOOLS_CLI[@]}"; do
    if command -v "$tool" &>/dev/null; then
      ok "$tool 已安装"
    else
      info "安装 $tool..."
      brew install "$tool" --quiet 2>/dev/null || warn "$tool 安装失败"
    fi
  done
fi

# ─── 完成 ────────────────────────────────────────────────────────────────────
section "✅ 安装完成！"

echo ""
echo -e "  已安装模块:"
$INSTALL_BREW   && echo -e "  ${GREEN}✔${NC} Homebrew"   || echo -e "  ${RED}✘${NC} Homebrew"
$INSTALL_TOOLS  && echo -e "  ${GREEN}✔${NC} 基础工具"    || echo -e "  ${RED}✘${NC} 基础工具"
$INSTALL_PYTHON && echo -e "  ${GREEN}✔${NC} Python"     || echo -e "  ${RED}✘${NC} Python"
$INSTALL_NODE   && echo -e "  ${GREEN}✔${NC} Node.js"     || echo -e "  ${RED}✘${NC} Node.js"
$INSTALL_DOCKER && echo -e "  ${GREEN}✔${NC} Docker"      || echo -e "  ${RED}✘${NC} Docker"
$INSTALL_SHELL  && echo -e "  ${GREEN}✔${NC} Shell 增强"  || echo -e "  ${RED}✘${NC} Shell 增强"
$INSTALL_CLOUD  && echo -e "  ${GREEN}✔${NC} 云工具"      || echo -e "  ${RED}✘${NC} 云工具"

echo ""
echo -e "  ${YELLOW}🔄 请重启终端 或 运行: source ~/.zprofile${NC}"
echo ""
echo -e "  ${YELLOW}☕ 觉得好用？请我喝杯咖啡:${NC}"
echo -e "  ${CYAN}  https://buymeacoffee.com/kunwu8${NC}"
echo ""
