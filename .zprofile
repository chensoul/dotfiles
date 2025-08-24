eval $(/opt/homebrew/bin/brew shellenv) #brew.idayer.com
export HOMEBREW_API_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles/api #brew.idayer.com
export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles/bottles #brew.idayer.com
export HOMEBREW_PIP_INDEX_URL=https://mirrors.aliyun.com/pypi/simple/ #brew.idayer.com

source ~/.bash_profile

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
