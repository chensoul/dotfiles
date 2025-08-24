# 🚀 ChenSoul's Dotfiles

> A comprehensive macOS development environment setup with modern tools and optimized configurations.

[![macOS](https://img.shields.io/badge/macOS-000000?style=flat-square&logo=apple&logoColor=white)](https://www.apple.com/macos/)
[![Zsh](https://img.shields.io/badge/Shell-Zsh-1f425f.svg?style=flat-square)](https://www.zsh.org/)
[![Homebrew](https://img.shields.io/badge/Package%20Manager-Homebrew-FBB040?style=flat-square&logo=homebrew)](https://brew.sh/)

## ✨ Features

- **🔧 Automated Setup**: One-command installation for complete development environment
- **🎨 Modern Shell**: Zsh with Oh My Zsh, syntax highlighting, and autosuggestions
- **📦 Package Management**: Comprehensive Brewfile with development tools and applications
- **🔀 Git Configuration**: Smart conditional git configs for work/personal projects
- **⚡ Optimized Aliases**: 100+ carefully crafted aliases and functions for productivity
- **🖥️ System Optimization**: macOS tweaks for better performance and usability
- **🌏 China-Friendly**: Optimized with Chinese mirrors for faster downloads
- **🔐 SSH Setup**: Automated SSH key generation and configuration

## 📋 Prerequisites

- **macOS** (tested on macOS 12+)
- **Git** (usually pre-installed)
- **Internet connection** (for downloading packages)

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/chensoul/dotfiles.git
cd dotfiles

# Make the script executable
chmod +x install.sh

# Run the installation script (IMPORTANT: Use bash, not sh)
bash install.sh
# OR
./install.sh

# Optional: Apply macOS system optimizations
bash osx.sh
```

### 🔧 Alternative: Step-by-Step Installation

If you prefer a modular approach or encounter issues with the full script:

```bash
# 1. Install only dotfiles (quick setup)
bash setup-dotfiles.sh

# 2. Install software packages via Homebrew
brew bundle

# 3. Install Java development tools via SDKMAN
sdk install java
sdk install maven
sdk install gradle
sdk install springboot

# 4. Apply macOS optimizations (optional)
bash osx.sh
```

### ⚠️ Important Notes

- **Always use `bash install.sh`** or `./install.sh`
- **Never use `sh install.sh`** - this will cause errors
- The script requires bash features and will not work with basic sh
- **SDKMAN is now managed via Homebrew** for better integration

## 📁 File Structure

```
dotfiles/
├── 📄 .aliases           # Shell aliases and utility functions
├── ⚙️  .gitconfig         # Git configuration with conditional includes
├── 👤 .gitconfig-personal # Personal git identity
├── 🏢 .gitconfig-work     # Work git identity
├── 🚫 .gitignore          # Global git ignore patterns
├── 🐚 .zshrc              # Zsh configuration with Oh My Zsh
├── 🔧 .zprofile           # Zsh profile with Homebrew setup
├── 📦 Brewfile            # Homebrew package definitions
├── 🛠️  install.sh          # Main installation script
├── 🖥️  osx.sh             # macOS system preferences
└── 📖 README.md           # This file
```

## 🛠️ What Gets Installed

### Development Tools
- **Languages**: Java (via Homebrew + SDKMAN), Go, Python 3.12, Rust, Node.js (via fnm)
- **Build Tools**: Maven, Gradle, Spring Boot CLI (all via SDKMAN)
- **Version Control**: Git, GitHub CLI
- **Containers**: Docker, Kubernetes tools (kubectl, k9s, helm)
- **Editors**: Vim, IntelliJ IDEA

### Command Line Tools
- **System**: htop, tree, fastfetch, coreutils, findutils
- **Network**: curl, wget, httpie, nmap
- **File Processing**: jq, pandoc, rename
- **Package Managers**: Homebrew (primary), SDKMAN (Java ecosystem), fnm (Node.js), pyenv (Python), rustup (Rust)

### GUI Applications
- **Development**: IntelliJ IDEA, Insomnia, Ghostty
- **Productivity**: 1Password, Typora, PicGo
- **Communication**: WeChat, Feishu
- **Browsers**: Google Chrome
- **Cloud Storage**: Aliyun Pan, Baidu Netdisk
- **Containers**: OrbStack

## ⚙️ Configuration Details

### Git Configuration
The setup includes a smart git configuration that automatically switches between work and personal identities based on the project directory:

- **Personal projects** (`~/development/personal/`): Uses personal git identity
- **Work projects** (`~/development/work/`): Uses work git identity
- **GitHub proxy**: Configured for Chinese users (socks5://127.0.0.1:7890)

### Shell Enhancements
- **Oh My Zsh** with curated plugins (git, docker, kubectl, etc.)
- **100+ aliases** for common development tasks
- **Utility functions** for system maintenance, git operations, and productivity
- **Auto-completion** for various tools and commands

### Package Management Strategy
- **Homebrew as Primary**: Main package manager for most tools and applications
- **SDKMAN via Homebrew**: Java ecosystem tools (Java, Maven, Gradle, Spring Boot)
- **Language-specific managers**: fnm (Node.js), pyenv (Python), rustup (Rust)
- **Chinese mirrors** for faster downloads in China
- **Unified management** through Brewfile for reproducible setups

## 🎯 Key Aliases & Functions

### Git Workflow
```bash
gs          # git status
gaa         # git add -A
gcm         # git commit -m
gp          # git pull
gg          # git push to current branch
glog        # beautiful git log with graph
grename     # rename branch locally and remotely
```

### Development
```bash
mw          # ./mvnw (Maven wrapper)
mwci        # ./mvnw clean install
gw          # ./gradlew (Gradle wrapper)
d           # docker
dc          # docker compose
k           # kubectl
```

### System & Navigation
```bash
ll          # ls -la (detailed list)
..          # cd ../..
...         # cd ../../..
p           # cd ~/chensoul/Projects
cleanup     # remove build artifacts (.DS_Store, node_modules, etc.)
maintenance # comprehensive system cleanup
```

### Utilities
```bash
killport    # kill process on specific port
extract     # extract any archive format
weather     # get weather info
note        # quick note taking
backup      # create timestamped backup
```

## 🔧 Customization

### Personal Information
Update the following files with your information:

1. **Git Identity** (`.gitconfig-personal`, `.gitconfig-work`):
```bash
[user]
name = Your Name
email = your.email@example.com
```

2. **Project Paths** (`.aliases`):
```bash
alias p='cd ~/your/projects/path'
```

3. **Computer Name** (`osx.sh`):
```bash
readonly COMPUTER_NAME="your-mac-name"
```

### Adding Custom Packages
Edit `Brewfile` to add your preferred tools:
```ruby
# Add command line tools
brew "your-tool"

# Add GUI applications
cask "your-app"
```

### Custom Aliases
Add your personal aliases to `.aliases`:
```bash
# Add at the end of .aliases file
alias myalias='your command here'
```

## 🐛 Troubleshooting

### Common Issues

**1. Script Fails with "sh install.sh"**
```bash
# ❌ Wrong way (will cause errors)
sh install.sh

# ✅ Correct way
bash install.sh
# OR
chmod +x install.sh && ./install.sh
```

**2. Homebrew Installation Fails**
```bash
# For Apple Silicon Macs, ensure Homebrew is in PATH
eval "$(/opt/homebrew/bin/brew shellenv)"
```

**2. SDKMAN Tools Not Found**
```bash
# Check if SDKMAN is installed via Homebrew
brew list sdkman-cli

# Reload shell configuration
source ~/.zshrc

# Check SDKMAN status
sdk version

# If still not working, reinstall via Homebrew
brew reinstall sdkman-cli
```

**3. Oh My Zsh Not Installed**
```bash
# Install Oh My Zsh manually
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

**4. Aliases Not Working**
```bash
# Reload shell configuration
source ~/.zshrc

# If you get "ZSH_VERSION: unbound variable" error
# This is fixed in the current version, but if you encounter it:
unset ZSH_VERSION
source ~/.zshrc
```

**5. Git Proxy Issues**
```bash
# Disable proxy if not needed
git config --global --unset http.proxy
git config --global --unset https.proxy
```

### Reset and Reinstall
```bash
# Clean reinstall
rm -rf ~/.oh-my-zsh
./install.sh
```

## 🔄 Maintenance

### Regular Updates
```bash
# Update all packages and clean system
maintenance

# Or run individual commands
brew update && brew upgrade && brew cleanup
```

### Backup Current Settings
```bash
# Backup important configs before changes
backup ~/.zshrc
backup ~/.gitconfig
```

## 🤝 Contributing

Feel free to fork this repository and customize it for your needs. If you have improvements or bug fixes, pull requests are welcome!

## 📚 Inspiration & References

- [Mathias Bynens' dotfiles](https://github.com/mathiasbynens/dotfiles)
- [Kehrlann's configs](https://github.com/Kehrlann/configs)
- [Oh My Zsh](https://ohmyz.sh/)
- [Homebrew](https://brew.sh/)

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

**Happy coding! 🎉**

> Made with ❤️ by [ChenSoul](https://github.com/chensoul)
