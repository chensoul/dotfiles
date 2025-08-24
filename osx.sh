#!/usr/bin/env bash

# ~/.macos — https://mths.be/macos
readonly COMPUTER_NAME="chensoul-mac"
readonly TIMEZONE="Asia/Shanghai"

sudo scutil --set ComputerName "$COMPUTER_NAME"
sudo scutil --set HostName "$COMPUTER_NAME"
sudo scutil --set LocalHostName "$COMPUTER_NAME"

sudo systemsetup -settimezone "$TIMEZONE"

########### system ###########

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

# 重启相关服务
killall Dock
killall Finder


########### finder ###########

# 显示隐藏文件
defaults write com.apple.finder AppleShowAllFiles -bool true

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