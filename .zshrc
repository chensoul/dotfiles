# Oh My Zsh 配置
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="muse" #random

# 插件
plugins=(
    git
    mvn
    zsh-autosuggestions
    zsh-syntax-highlighting
    docker
    kubectl
)

source $ZSH/oh-my-zsh.sh

# 加载 SDKMAN
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# 自定义环境变量
export EDITOR=vim
export LANG=en_US.UTF-8

# 开发工具路径
export JAVA_HOME="$HOME/.sdkman/candidates/java/current"
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# 加载 fnm
eval "$(fnm env --use-on-cd)"