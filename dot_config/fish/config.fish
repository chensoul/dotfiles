# -----------------------------------------------------------------------------
# Fish Shell Configuration
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# 用户配置
# -----------------------------------------------------------------------------
if test -f ~/.aliases
    source ~/.aliases
end
if test -f ~/.myrc
    source ~/.myrc
end

# -----------------------------------------------------------------------------
# Homebrew（镜像源与 .zprofile 保持一致，fish 不读取 .zprofile）
# -----------------------------------------------------------------------------
set -gx HOMEBREW_PIP_INDEX_URL "https://pypi.mirrors.ustc.edu.cn/simple"
set -gx HOMEBREW_API_DOMAIN "https://mirrors.ustc.edu.cn/homebrew-bottles/api"
set -gx HOMEBREW_BOTTLE_DOMAIN "https://mirrors.ustc.edu.cn/homebrew-bottles"

if test -x /opt/homebrew/bin/brew
    /opt/homebrew/bin/brew shellenv | source
else if test -x /usr/local/bin/brew
    /usr/local/bin/brew shellenv | source
end

# -----------------------------------------------------------------------------
# PNPM（与 .zprofile 保持一致）
# -----------------------------------------------------------------------------
set -gx PNPM_HOME "$HOME/Library/pnpm"
if not string match -q ":$PNPM_HOME:" ":$PATH:"
    set -gx PATH "$PNPM_HOME" $PATH
end

# -----------------------------------------------------------------------------
# SDKMAN（brew：tap sdkman/tap && brew install sdkman-cli）
# -----------------------------------------------------------------------------
set _sdkman_prefix (brew --prefix sdkman-cli 2>/dev/null)
if test -n "$_sdkman_prefix"
    set -gx SDKMAN_DIR "$_sdkman_prefix/libexec"
    if test -s "$SDKMAN_DIR/bin/sdkman-init.sh"
        source "$SDKMAN_DIR/bin/sdkman-init.sh"
    end
end
set -e _sdkman_prefix

# Java：仅在 SDKMAN 已配置且已安装 java 候选时设置 JAVA_HOME
if test -n "$SDKMAN_DIR" -a -d "$SDKMAN_DIR/candidates/java/current"
    set -gx JAVA_HOME "$SDKMAN_DIR/candidates/java/current"
    set -gx PATH "$JAVA_HOME/bin" $PATH
end

# JVM 参数优化
set -gx JAVA_OPTS "-Xms1g -Xmx1g -XX:+UseG1GC -XX:+UseStringDeduplication"
# Maven 性能优化
set -gx MAVEN_OPTS "-Xms1g -Xmx4g -XX:+TieredCompilation -XX:TieredStopAtLevel=1"

# -----------------------------------------------------------------------------
# Node (fnm) 与 pnpm
# -----------------------------------------------------------------------------
if command -v fnm >/dev/null ^&1
    fnm env --use-on-cd | source
end

set -gx PNPM_HOME "$HOME/Library/pnpm"
if not string match -q ":$PNPM_HOME:" ":$PATH:"
    set -gx PATH "$PNPM_HOME" $PATH
end

# -----------------------------------------------------------------------------
# OrbStack
# -----------------------------------------------------------------------------
if test -f "$HOME/.orbstack/shell/init.fish"
    source "$HOME/.orbstack/shell/init.fish"
end

# -----------------------------------------------------------------------------
# Starship 提示符
# -----------------------------------------------------------------------------
starship init fish | source

# -----------------------------------------------------------------------------
# zoxide (目录跳转)
# -----------------------------------------------------------------------------
zoxide init fish | source

# -----------------------------------------------------------------------------
# 历史记录优化
# -----------------------------------------------------------------------------
set -g fish_history_size 50000
set -g -- fish_history_path "$HOME/.local/share/fish/fish_history"

# -----------------------------------------------------------------------------
# 目录跳转优化
# -----------------------------------------------------------------------------
set -g auto_cd on
set -g autopair true
set -g fish_cursor_default block blink
set -g fish_cursor_insert line blink

# -----------------------------------------------------------------------------
# 别名
# -----------------------------------------------------------------------------
alias ll="ls -lah"
alias la="ls -A"
alias l="ls -CF"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# git 别名
alias g="git"
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gco="git checkout"
alias gb="git branch"
alias gl="git log --oneline -20"
alias gp="git push"
alias gpull="git pull"

# pnpm 别名
alias p="pnpm"
alias pi="pnpm install"
alias pd="pnpm dev"
alias pb="pnpm build"
alias ps="pnpm start"
alias pt="pnpm test"

# -----------------------------------------------------------------------------
# 自定义函数
# -----------------------------------------------------------------------------

# Yazi 文件管理器 (cd 到退出时的目录)
function y
    set cwd (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$cwd"
    if set cwd (cat -- "$cwd") && test -n "$cwd" -a "$cwd" != "$PWD"
        builtin cd -- "$cwd"
    end
    rm -f -- "$cwd"
end

# 快速创建文件
function touchd
    mkdir -p (dirname $argv)
    touch $argv
end

# 快速进入项目目录
function proj
    if set -q argv[1]
        cd ~/github/$argv[1]
    else
        ls ~/github/
    end
end

# 查找并进入目录
function fd
    cd (find . -type d -name "*$argv*" | head -1)
end
