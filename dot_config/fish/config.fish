# -----------------------------------------------------------------------------
# Fish Shell Configuration
# -----------------------------------------------------------------------------

# 个人自定义配置（可选）
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
# SDKMAN
# -----------------------------------------------------------------------------
set _sdkman_prefix (brew --prefix sdkman-cli 2>/dev/null)
if test -n "$_sdkman_prefix" -a -f "$_sdkman_prefix/libexec/bin/sdkman-init.sh"
    set -gx SDKMAN_DIR "$_sdkman_prefix/libexec"
else if test -d "$HOME/.sdkman"
    set -gx SDKMAN_DIR "$HOME/.sdkman"
else if test -d /usr/share/sdkman
    set -gx SDKMAN_DIR "/usr/share/sdkman"
end

if test -n "$SDKMAN_DIR" -a -s "$SDKMAN_DIR/bin/sdkman-init.sh"
    # 使用 bash 初始化 SDKMAN，并导出 sdk 函数到 fish
    function sdk
        set -l bash_sdk (command -s bash)
        if test -n "$bash_sdk"
            bash -c "source \"$SDKMAN_DIR/bin/sdkman-init.sh\" && sdk $argv"
        end
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

# -----------------------------------------------------------------------------
# 实用函数
# -----------------------------------------------------------------------------

# 杀死占用端口的进程
function killport
    if test -z "$argv[1]"
        echo "Usage: killport <port_number>"
        return 1
    end
    set -l pid (lsof -ti tcp:"$argv[1]")
    if test -n "$pid"
        echo "Killing process $pid on port $argv[1]"
        kill -9 $pid
    else
        echo "No process found on port $argv[1]"
    end
end

# 批量拉取代码：在 ~/github、~/work 下对每个一级子目录执行 git pull
# 用法：pullcode [.|--here]
function pullcode
    set -l roots
    if test "$argv[1]" = "." -o "$argv[1]" = "--here"
        set roots (pwd -P)
    else
        set roots "$HOME/github" "$HOME/work"
    end

    for root in $roots
        if not test -d "$root"
            echo "pullcode: 跳过（目录不存在）: $root" >&2
            continue
        end
        echo "━━ "(basename "$root")" ($root) ━━"
        for dir in (find "$root" -maxdepth 1 -mindepth 1 -type d 2>/dev/null)
            if not test -d "$dir/.git"
                continue
            end
            set -l name (basename "$dir")
            echo "📁 $name"
            pushd "$dir" >/dev/null
            git pull >/dev/null && echo "  pull 成功" || echo "  pull 失败：$name" >&2
            popd >/dev/null
        end
    end
end

# 批量提交并推送：add → commit → push
# 用法：pushcode [--here] <提交说明>
function pushcode
    set -l use_here false
    set -l msg

    if test "$argv[1]" = "--here"
        set use_here true
        set argv $argv[2..]
    end
    set msg "$argv[1]"

    if test -z "$msg"
        echo "pushcode: 需要提交说明，例如：pushcode \"chore: sync\"" >&2
        echo "  或：pushcode --here \"说明\"（仅当前目录）" >&2
        return 1
    end

    set -l roots
    if test "$use_here" = true
        set roots (pwd -P)
    else
        set roots "$HOME/github" "$HOME/work"
    end

    for top in $roots
        if not test -d "$top"
            echo "pushcode: 跳过（目录不存在）: $top" >&2
            continue
        end
        echo "━━ "(basename "$top")" ($top) ━━"

        for dir in (find "$top" -maxdepth 1 -mindepth 1 -type d 2>/dev/null)
            if not test -d "$dir/.git"
                continue
            end
            set -l name (basename "$dir")
            echo "📁 $name"
            pushd "$dir" >/dev/null || continue

            git add -A
            if git diff --cached --quiet && git diff --quiet
                echo "  (无变更，跳过)"
                popd >/dev/null
                continue
            end

            if not git commit -m "$msg"
                echo "  commit 失败：$name" >&2
                popd >/dev/null
                continue
            end

            set -l branch (git symbolic-ref -q HEAD 2>/dev/null | sed -e 's|^refs/heads/||')
            if test -z "$branch"
                echo "  非分支 HEAD，跳过 push: $name" >&2
                popd >/dev/null
                continue
            end

            if not git push origin "$branch"
                echo "  push 失败：$name" >&2
            end
            popd >/dev/null
        end
    end
end

# 清理构建产物
# 用法：cleanup [-n|--dry-run]
function cleanup
    set -l dry_run false
    if test "$argv[1]" = "-n"; or test "$argv[1]" = "--dry-run"
        set dry_run true
    end

    if test "(pwd -P)" = "/"
        echo "cleanup: 拒绝在文件系统根目录 / 下执行" >&2
        return 1
    end

    set -l dirs_to_clean "node_modules" "target" "build" "dist" "out" ".next" "__pycache__" ".pytest_cache" ".mypy_cache" ".gradle" ".turbo" "coverage" ".nuxt" "venv" ".venv" "Pods"

    if test "$dry_run" = true
        echo "cleanup: dry-run（不会删除）:"
        for dir in $dirs_to_clean
            fd -t d "$dir" --max-depth 10 2>/dev/null | while read -l d
                not string match -q '*/.git/*' "$d" && echo $d
            end
        end
        fd -t f ".DS_Store" "*.log" --max-depth 10 2>/dev/null | while read -l f
            not string match -q '*/.git/*' "$f" && echo $f
        end
        return 0
    end

    for dir in $dirs_to_clean
        fd -t d "$dir" --max-depth 10 2>/dev/null | while read -l d
            not string match -q '*/.git/*' "$d" && rm -rf "$d" 2>/dev/null
        end
    end

    fd -t f ".DS_Store" "*.log" --max-depth 10 2>/dev/null | while read -l f
        not string match -q '*/.git/*' "$f" && rm -f "$f" 2>/dev/null
    end

    echo "cleanup: 清理完成"
end
