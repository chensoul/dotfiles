#!/bin/bash
# 新机或重装后：在已克隆的本仓库根目录执行（需先安装 Xcode Command Line Tools）
#
#   bash install.sh
#   ./install.sh
#
# 不要使用: sh install.sh
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if ! xcode-select -p &>/dev/null; then
  echo "请先安装 Command Line Tools，完成后再运行本脚本："
  echo "  xcode-select --install"
  exit 1
fi

readonly COMPUTER_NAME="zhijunio-mac"
readonly TIMEZONE="Asia/Shanghai"
sudo scutil --set ComputerName "$COMPUTER_NAME"
sudo scutil --set HostName "$COMPUTER_NAME"
sudo scutil --set LocalHostName "$COMPUTER_NAME"
sudo systemsetup -settimezone "$TIMEZONE"

# 取消 4 位数密码限制
sudo pwpolicy -clearaccountpolicies
# 允许安装任意来源的应用
sudo spctl --master-disable
# 加快键盘重复速度
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 10
# 显示滚动条
defaults write NSGlobalDomain AppleShowScrollBars -string "WhenScrolling"
# 禁用不必要的动画
defaults write com.apple.dock launchanim -bool false
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false
defaults write com.apple.dock expose-animation-duration -float 0.1
# 加快 Mission Control 动画
defaults write com.apple.dock expose-animation-duration -float 0.1
# 禁用窗口缩放动画
defaults write NSGlobalDomain NSAutomaticWindowAnimationsEnabled -bool false

# 加快对话框显示速度
defaults write NSGlobalDomain NSWindowResizeTime -float 0.001
# 不显示隐藏文件
defaults write com.apple.finder AppleShowAllFiles -bool false
# 显示文件扩展名
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# 显示路径栏
defaults write com.apple.finder ShowPathbar -bool true
# 显示状态栏
defaults write com.apple.finder ShowStatusBar -bool true
# 默认搜索当前文件夹
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
# 禁用创建 .DS_Store 文件
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# 重启相关服务
killall Dock 2>/dev/null || true
killall Finder 2>/dev/null || true

# Homebrew（国内镜像 - USTC）
export HOMEBREW_BREW_GIT_REMOTE="https://mirrors.ustc.edu.cn/brew.git"
export HOMEBREW_CORE_GIT_REMOTE="https://mirrors.ustc.edu.cn/brew.git"
export HOMEBREW_API_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles/api"
export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"
export HOMEBREW_CDN_DOMAIN="https://mirrors.ustc.edu.cn/homebrew-bottles"
export HOMEBREW_PIP_INDEX_URL="https://pypi.mirrors.ustc.edu.cn/simple"

if ! command -v brew &>/dev/null; then
  export HOMEBREW_INSTALL_FROM_ZIP=1
  /bin/bash -c "$(curl -fsSL https://gitee.com/ineo6/homebrew-install/raw/master/install.sh)"
fi

if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -x /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
else
  echo "未找到 brew，请检查安装日志。" >&2
  exit 1
fi

brew bundle install --file "${SCRIPT_DIR}/Brewfile"

# SDKMAN（由 brew 安装 sdkman-cli；版本号请按 sdk list java / sdk list maven 调整）
_sdkman_prefix="$(brew --prefix sdkman-cli 2>/dev/null)" || true
if [[ -n "${_sdkman_prefix}" ]]; then
  export SDKMAN_DIR="${_sdkman_prefix}/libexec"
  # shellcheck disable=SC1091
  [[ -s "${SDKMAN_DIR}/bin/sdkman-init.sh" ]] && source "${SDKMAN_DIR}/bin/sdkman-init.sh"
  export SDKMAN_AUTO_ANSWER=true
  sdk install java 25.0.2-graal
  sdk install java 17.0.12-graal
  sdk install java 8.0.482-zulu
  sdk install maven
fi
unset _sdkman_prefix

# SSH（无密钥时才生成；若已从备份恢复 id_ed25519，不会覆盖）
ssh_key_path="$HOME/.ssh/id_ed25519"
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
if [[ ! -f "$ssh_key_path" ]]; then
  ssh-keygen -t ed25519 -C "$(whoami)@$(hostname)" -f "$ssh_key_path" -N ""
fi
eval "$(ssh-agent -s)"
ssh-add "$ssh_key_path" 2>/dev/null || true

# Chezmoi（从 GitHub 克隆并应用配置）
# 如果有加密文件，会提示输入 GPG 密码
chezmoi init --apply https://github.com/zhijunio/dotfiles.git

# 将 zsh 设为默认 shell
if ! dscl . -read ~/ UserShell | grep -q "/zsh"; then
    echo "将默认 shell 切换为 zsh..."
    chsh -s /opt/homebrew/bin/zsh
fi

echo "安装流程结束。"
