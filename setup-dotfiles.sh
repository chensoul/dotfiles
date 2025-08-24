#!/bin/bash
# Simplified dotfiles setup script
# Use this for quick dotfiles setup without full system installation

set -euo pipefail

# Check if running with bash
if [ -z "${BASH_VERSION:-}" ]; then
    echo "❌ Error: This script requires bash to run."
    echo "Please run with: bash setup-dotfiles.sh"
    exit 1
fi

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

# Variables
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly HOME_DIR="$HOME"
readonly DOTFILES_DIR="$SCRIPT_DIR"

# Platform check
check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_error "This script is designed for macOS only."
        exit 1
    fi
    log_success "macOS detected"
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

# Main execution
main() {
    log_info "Starting dotfiles setup..."
    
    # Run basic setup functions
    check_macos
    setup_dotfiles
    
    log_success "Dotfiles setup complete! 🎉"
    log_info "Please restart your terminal or run 'source ~/.zshrc' to apply changes"
    log_info ""
    log_info "To install software packages, run: brew bundle"
    log_info "To install Java tools, run: sdk install java && sdk install maven && sdk install gradle"
    log_info "To apply macOS optimizations, run: bash osx.sh"
}

# Run main function
main "$@"
