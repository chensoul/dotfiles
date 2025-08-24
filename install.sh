#!/bin/bash
# Optimized macOS setup script
# inspired by chris sev @chris__sev https://gist.github.com/chris-sev/45a92f4356eaf4d68519d396ef42dd99

set -euo pipefail

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
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
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

# SDKMAN installation and setup
setup_sdkman() {
    log_info "Setting up SDKMAN..."

    # Source SDKMAN
    if [[ -f "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
        source "$HOME/.sdkman/bin/sdkman-init.sh"

        # Install Java development tools
        local tools=("springboot" "maven" "mvnd" "gradle")
        for tool in "${tools[@]}"; do
            if ! sdk list "$tool" 2>/dev/null | grep -q "installed" || ! sdk current "$tool" >/dev/null 2>&1; then
                log_info "Installing $tool..."
                sdk install "$tool" || log_warning "Failed to install $tool"
            else
                log_info "$tool already installed"
            fi
        done

        log_success "SDKMAN setup complete"
    else
        log_error "SDKMAN installation failed"
        return 1
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
    setup_sdkman
    setup_dotfiles
    setup_ssh

    log_success "macOS setup complete! 🎉"
    log_info "Please restart your terminal or run 'source ~/.zshrc' to apply changes"
}

# Run main function
main "$@"
