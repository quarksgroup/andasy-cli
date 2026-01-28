#!/bin/sh
set -e  # Exit on any error

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

CLI_REPO="quarksgroup/andasy-cli"
ARCH="$(uname -m)"

# Check for required dependencies
for cmd in curl tar grep; do
    if ! command -v $cmd >/dev/null 2>&1; then
        printf "${RED}Error: Required command '$cmd' not found${RESET}\n"
        printf "Please install $cmd and try again\n"
        exit 1
    fi
done

# Detect architecture
case $ARCH in
    x86_64)
        ARCH="amd64"
        ;;
    arm64 | aarch64)
        ARCH="arm64"
        ;;
    *)
        printf "${RED}Error: Unsupported architecture: $ARCH${RESET}\n"
        exit 1
        ;;
esac

# Detect OS system type. (Windows not supported.)
OSTYPE="$(uname -s)"
case $OSTYPE in
    Darwin)
        OSTYPE="darwin"
        INSTALL_PATH="$HOME/.andasy/bin"
        ;;
    Linux)
        OSTYPE="linux"
        INSTALL_PATH="$HOME/.andasy/bin"
        ;;
    *)
        printf "${RED}Error: Unsupported operating system: $OSTYPE${RESET}\n"
        exit 1
        ;;
esac

# Detect shell configuration file
TERM_CONFIG=""
SHELL_TYPE="posix"  # Default to POSIX shell syntax

case $SHELL in
    */zsh)
        TERM_CONFIG="$HOME/.zshrc"
        ;;
    */bash)
        # Prefer .bashrc, fallback to .bash_profile
        if [ -f "$HOME/.bashrc" ]; then
            TERM_CONFIG="$HOME/.bashrc"
        elif [ -f "$HOME/.bash_profile" ]; then
            TERM_CONFIG="$HOME/.bash_profile"
        else
            TERM_CONFIG="$HOME/.bashrc"
        fi
        ;;
    */fish)
        TERM_CONFIG="$HOME/.config/fish/config.fish"
        SHELL_TYPE="fish"
        ;;
    *)
        TERM_CONFIG="$HOME/.profile"
        ;;
esac

printf "${CYAN}Detecting system: ${BOLD}$OSTYPE $ARCH${RESET}\n"
printf "${CYAN}Downloading Andasy CLI...${RESET}\n"

# Fetch latest release and extract download URL
ASSET_URL=$(curl -fsSL https://api.github.com/repos/$CLI_REPO/releases/latest | \
    grep '"browser_download_url":' | \
    grep "${OSTYPE}-${ARCH}" | \
    cut -d '"' -f 4 | \
    head -n 1)

if [ -z "$ASSET_URL" ]; then
    printf "${RED}Error: Could not find a binary for $OSTYPE $ARCH${RESET}\n"
    printf "Please visit https://github.com/$CLI_REPO/releases for manual installation\n"
    exit 1
fi

# Create installation directory
mkdir -p "$INSTALL_PATH"

printf "${CYAN}Installing to ${BOLD}$INSTALL_PATH${RESET}${CYAN}...${RESET}\n"

# Download and extract with cleanup on failure
if ! curl -fsSL "$ASSET_URL" | tar -xz -C "$INSTALL_PATH"; then
    printf "${RED}Error: Failed to download or extract CLI binary${RESET}\n"
    # Cleanup on failure
    rm -rf "$INSTALL_PATH/andasy" 2>/dev/null || true
    exit 1
fi

chmod +x "$INSTALL_PATH/andasy"

# Verify installation
printf "${CYAN}Verifying installation...${RESET}\n"
if ! "$INSTALL_PATH/andasy" version >/dev/null 2>&1; then
    printf "${RED}Error: Installation succeeded but CLI is not functional${RESET}\n"
    exit 1
fi

# Add to PATH if not already present
PATH_UPDATED=0
if [ -n "$TERM_CONFIG" ]; then
    if [ ! -f "$TERM_CONFIG" ]; then
        mkdir -p "$(dirname "$TERM_CONFIG")"
        touch "$TERM_CONFIG"
    fi
    
    # Check if PATH already contains install directory
    if ! grep -qF "$INSTALL_PATH" "$TERM_CONFIG" 2>/dev/null; then
        # Add PATH export with shell-specific syntax
        case $SHELL_TYPE in
            fish)
                echo "set -gx PATH \"$INSTALL_PATH\" \$PATH" >> "$TERM_CONFIG"
                ;;
            *)
                echo "export PATH=\"$INSTALL_PATH:\$PATH\"" >> "$TERM_CONFIG"
                ;;
        esac
        PATH_UPDATED=1
    fi
fi

# Display success message
printf "\n"
printf "${GREEN}${BOLD}✓ Installation successful!${RESET}\n"

# Extract version with fallback
VERSION=$("$INSTALL_PATH/andasy" version 2>/dev/null | sed 's/andasy //' || echo "installed")
printf "${CYAN}Version: ${BOLD}${VERSION}${RESET}\n"
printf "\n"

if [ $PATH_UPDATED -eq 1 ]; then
    printf "${GREEN}PATH updated in: ${BOLD}$TERM_CONFIG${RESET}\n"
    printf "  ${CYAN}Run:${RESET} source $TERM_CONFIG\n"
    printf "  ${CYAN}Or:${RESET} open a new terminal to use 'andasy' command\n"
else
    if [ -n "$TERM_CONFIG" ]; then
        printf "${GREEN}PATH already configured in: ${BOLD}$TERM_CONFIG${RESET}\n"
    else
        printf "${YELLOW}Warning: Could not detect shell configuration file${RESET}\n"
        printf "  Add '${BOLD}$INSTALL_PATH${RESET}' to your PATH manually\n"
    fi
fi

printf "\n"
printf "${CYAN}Get started with: ${BOLD}andasy --help${RESET}\n"
printf "\n"
printf "${CYAN}To uninstall, run:${RESET}\n"
printf "  rm -rf $HOME/.andasy\n"
if [ -n "$TERM_CONFIG" ]; then
    printf "  ${CYAN}(and remove the PATH line from %s)${RESET}\n" "$TERM_CONFIG"
else
    printf "  ${CYAN}(and remove the PATH line from your shell config)${RESET}\n"
fi