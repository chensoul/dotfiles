#!/bin/bash
# Optimized macOS setup script
# inspired by chris sev @chris__sev https://gist.github.com/chris-sev/45a92f4356eaf4d68519d396ef42dd99
#
# IMPORTANT: This script requires bash. Run with: bash install.sh or ./install.sh
# Do NOT run with: sh install.sh

set -euo pipefail

# Check if running with bash
if [ -z "${BASH_VERSION:-}" ]; then
    echo "❌ Error: This script requires bash to run."
    echo "Please run with one of these commands:"
    echo "  bash install.sh"
    echo "  ./install.sh"
    echo ""
    echo "Do NOT use: sh install.sh"
    echo ""
    echo "Attempting to restart with bash..."
    exec bash "$0" "$@"
fi

# Variables
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly HOME_DIR="$HOME"
readonly DOTFILES_DIR="$SCRIPT_DIR"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m' # No Color

# Logging functions
log_info() {
    printf "${BLUE}[INFO]${NC} %s\n" "$1"
}

log_success() {
    printf "${GREEN}[SUCCESS]${NC} %s\n" "$1"
}

log_warning() {
    printf "${YELLOW}[WARNING]${NC} %s\n" "$1"
}

log_error() {
    printf "${RED}[ERROR]${NC} %s\n" "$1" >&2
}

# Error handling
cleanup() {
    log_error "Script interrupted. Cleaning up..."
    exit 1
}

trap cleanup INT TERM

# Platform check
check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_error "This script is designed for macOS only."
        exit 1
    fi
    log_success "macOS detected"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Homebrew installation and update
setup_homebrew() {
    log_info "Setting up Homebrew..."

    if ! command_exists brew; then
        log_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    else
        log_info "Homebrew already installed, updating..."
        brew update
    fi

    log_success "Homebrew setup complete"
}

# Setup package managers
setup_package_managers() {
    log_info "Setting up package managers..."

    # Setup fnm (Node.js version manager)
    if command -v fnm >/dev/null 2>&1; then
        log_info "fnm is available for Node.js version management"
        # Install latest LTS Node.js
        fnm install --lts 2>/dev/null || log_warning "Failed to install Node.js LTS"
        fnm use lts-latest 2>/dev/null || true
    else
        log_warning "fnm not found, install it via Homebrew first"
    fi

    # Setup pyenv (Python version manager)
    if command -v pyenv >/dev/null 2>&1; then
        log_info "pyenv is available for Python version management"
        # Python is already installed via Homebrew, pyenv is for additional versions if needed
    else
        log_warning "pyenv not found, install it via Homebrew first"
    fi

    # Setup Rust
    if command -v rustup >/dev/null 2>&1; then
        log_info "rustup is available for Rust management"
        rustup default stable 2>/dev/null || log_warning "Failed to set Rust stable as default"
    else
        log_warning "rustup not found, install it via Homebrew first"
    fi

    log_success "Package managers setup complete"
}

# Install software via Homebrew
install_software() {
    log_info "Installing software packages..."

    if [[ -f "$SCRIPT_DIR/Brewfile" ]]; then
        brew bundle --file="$SCRIPT_DIR/Brewfile"
        log_success "Software installation complete"
    else
        log_warning "Brewfile not found, skipping software installation"
    fi
}

# SDKMAN setup (using Homebrew-installed version)
setup_sdkman() {
    log_info "Setting up SDKMAN..."

    # Check if SDKMAN was installed via Homebrew
    if command -v sdk >/dev/null 2>&1; then
        log_info "SDKMAN (Homebrew version) is available"

        # Install Java development tools
        local tools=("java" "maven" "gradle" "springboot")
        for tool in "${tools[@]}"; do
            log_info "Installing $tool via SDKMAN..."
            if ! sdk list "$tool" 2>/dev/null | grep -q "installed"; then
                case "$tool" in
                    "java")
                        # Install latest LTS Java version
                        sdk install java 21.0.5-tem 2>/dev/null || log_warning "Failed to install Java"
                        ;;
                    "maven")
                        sdk install maven 2>/dev/null || log_warning "Failed to install Maven"
                        ;;
                    "gradle")
                        sdk install gradle 2>/dev/null || log_warning "Failed to install Gradle"
                        ;;
                    "springboot")
                        sdk install springboot 2>/dev/null || log_warning "Failed to install Spring Boot CLI"
                        ;;
                esac
            else
                log_info "$tool already installed"
            fi
        done

        log_success "SDKMAN setup complete"
    else
        log_warning "SDKMAN not found. It should be installed via Homebrew."
        log_info "Make sure 'sdkman/tap/sdkman-cli' is in your Brewfile"
        log_info "You may need to restart your terminal after Homebrew installation"
    fi
}

# Create symlinks for dotfiles
setup_dotfiles() {
    log_info "Setting up dotfiles..."

    local files=(".gitconfig" ".gitconfig-personal" ".gitconfig-work" ".aliases" ".zshrc" ".zprofile")

    for file in "${files[@]}"; do
        local source_file="$DOTFILES_DIR/$file"
        local target_file="$HOME_DIR/$file"

        if [[ -f "$source_file" ]]; then
            log_info "Creating symlink for $file"
            ln -sf "$source_file" "$target_file"
        else
            log_warning "Source file $source_file not found, skipping"
        fi
    done

    log_success "Dotfiles setup complete"
}

# Setup Oh My Zsh and plugins
setup_oh_my_zsh() {
    log_info "Setting up Oh My Zsh..."

    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log_info "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        log_info "Oh My Zsh already installed"
    fi

    # Install zsh-autosuggestions plugin
    local autosuggestions_dir="$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
    if [[ ! -d "$autosuggestions_dir" ]]; then
        log_info "Installing zsh-autosuggestions plugin..."
        git clone https://github.com/zsh-users/zsh-autosuggestions "$autosuggestions_dir"
    else
        log_info "zsh-autosuggestions already installed"
    fi

    # Install zsh-syntax-highlighting plugin
    local syntax_highlighting_dir="$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
    if [[ ! -d "$syntax_highlighting_dir" ]]; then
        log_info "Installing zsh-syntax-highlighting plugin..."
        git clone https://github.com/zsh-users/zsh-syntax-highlighting "$syntax_highlighting_dir"
    else
        log_info "zsh-syntax-highlighting already installed"
    fi

    log_success "Oh My Zsh setup complete"
}

# Configure system settings
configure_system() {
    log_info "Configuring system settings..."

    # Set computer name
    local computer_name="chensoul-mac"
    log_info "Setting computer name to $computer_name"
    sudo scutil --set ComputerName "$computer_name"
    sudo scutil --set HostName "$computer_name"
    sudo scutil --set LocalHostName "$computer_name"

    # Set timezone
    local timezone="Asia/Shanghai"
    log_info "Setting timezone to $timezone"
    sudo systemsetup -settimezone "$timezone"

    log_success "System configuration complete"
}

# Setup SSH keys
setup_ssh() {
    log_info "Setting up SSH keys..."

    local ssh_key_path="$HOME/.ssh/id_ed25519"
    local ssh_pub_key_path="${ssh_key_path}.pub"

    if [[ ! -f "$ssh_pub_key_path" ]]; then
        log_info "Generating SSH keys..."
        mkdir -p "$HOME/.ssh"
        ssh-keygen -t ed25519 -C "$(whoami)@$(hostname)" -f "$ssh_key_path" -N ""

        if [[ -f "$ssh_pub_key_path" ]]; then
            # Start ssh-agent and add key
            eval "$(ssh-agent -s)"
            ssh-add "$ssh_key_path"

            log_info "Copying SSH public key to clipboard..."
            pbcopy < "$ssh_pub_key_path"
            log_success "SSH key generated and copied to clipboard"
            log_info "You can now add it to GitHub/GitLab"
        else
            log_error "SSH key generation failed"
            return 1
        fi
    else
        log_info "SSH key already exists"
        # Still copy to clipboard for convenience
        pbcopy < "$ssh_pub_key_path"
        log_info "Existing SSH key copied to clipboard"
    fi
}

# Main execution
main() {
    log_info "Starting macOS setup..."

    # Request sudo access upfront
    sudo -v

    # Keep sudo alive
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

    # Run setup functions
    check_macos
    setup_homebrew
    install_software
    setup_package_managers
    setup_oh_my_zsh
    setup_sdkman
    setup_dotfiles
    configure_system
    setup_ssh

    log_success "macOS setup complete! 🎉"
    log_info "Please restart your terminal or run 'source ~/.zshrc' to apply changes"
}

# Run main function
main "$@"
