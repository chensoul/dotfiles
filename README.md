# Dotfiles

面向 macOS 的开发环境：使用 [chezmoi](https://www.chezmoi.io/) 管理主目录下的配置文件，并配合 Homebrew、SDKMAN、fnm、shell 与 [Brewfile](Brewfile) 等工具与清单。

## chezmoi

本仓库是 **chezmoi 的 source state**（例如 `dot_*`、`private_*`、`encrypted_*`、`executable_*` 等命名），日常增删改应在 chezmoi 工作流中完成，而不是直接手写 `~` 下文件。

- 安装：可通过 Homebrew 安装（本仓库 [Brewfile](Brewfile) 已包含 `chezmoi`）。
- 文档：[chezmoi 用户指南](https://www.chezmoi.io/user-guide/command-overview/)

## 使用

### 全新机器（推荐）

1. 安装 Xcode Command Line Tools：`xcode-select --install`
2. 克隆本仓库，在仓库根目录执行：

   ```bash
   bash install.sh
   ```

   脚本会配置系统与 Homebrew、`brew bundle`（含 chezmoi）等，并在末尾执行 `chezmoi init --apply` 应用 dotfiles。

### 仅同步 dotfiles

若本机已安装 chezmoi，可直接从远程仓库初始化并应用：

```bash
chezmoi init --apply https://github.com/chensoul/dotfiles.git
```

## 参考

- [Mac 开发环境配置清单](https://blog.chensoul.cc/posts/mac-development-environment-setup)
- [使用 chezmoi 在 macOS 上管理 dotfiles](https://blog.chensoul.cc/posts/chezmoi-dotfiles-macos)

## 许可

见 [LICENSE](LICENSE)。
