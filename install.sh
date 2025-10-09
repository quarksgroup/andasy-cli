#!/bin/sh
set -e  # Exit on any error

CLI_REPO="quarksgroup/andasy-cli"
ARCH="$(uname -m)"

# Detect architecture
case $ARCH in
    x86_64)
        ARCH="amd64"
        ;;
    arm64 | aarch64)
        ARCH="arm64"
        ;;
    *)
        echo "Error: Unsupported architecture: $ARCH"
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
        echo "Error: Unsupported operating system: $OSTYPE"
        exit 1
        ;;
esac

TERM_CONFIG=""
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
        ;;
    *)
        TERM_CONFIG="$HOME/.profile"
        ;;
esac

echo "Detecting system: $OSTYPE $ARCH"
echo "Downloading Andasy CLI..."

ASSET_URL=$(curl -fsSL https://api.github.com/repos/$CLI_REPO/releases/latest | \
    grep -o "https://github\.com/$CLI_REPO/releases/download/.*${OSTYPE}-${ARCH}.*" | \
    tr -d '"' | head -n 1)

if [ -z "$ASSET_URL" ]; then
    echo "Error: Could not find a binary for $OSTYPE $ARCH"
    echo "Please visit https://github.com/$CLI_REPO/releases for manual installation"
    exit 1
fi

mkdir -p "$INSTALL_PATH"

echo "Installing to $INSTALL_PATH..."
if ! curl -fsSL "$ASSET_URL" | tar -xz -C "$INSTALL_PATH"; then
    echo "Error: Failed to download or extract CLI binary"
    exit 1
fi

chmod +x "$INSTALL_PATH/andasy"

# Verify installation
echo "Verifying installation..."
if ! "$INSTALL_PATH/andasy" version >/dev/null 2>&1; then
    echo "Error: Installation succeeded but CLI is not functional"
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
    if ! grep -q "$INSTALL_PATH" "$TERM_CONFIG" 2>/dev/null; then
        # Add PATH export with shell-specific syntax
        if [ "$SHELL" = "${SHELL%fish}" ]; then
            # POSIX shells (bash, zsh, sh)
            echo "export PATH=\"$INSTALL_PATH:\$PATH\"" >> "$TERM_CONFIG"
        else
            # Fish shell
            echo "set -gx PATH \"$INSTALL_PATH\" \$PATH" >> "$TERM_CONFIG"
        fi
        PATH_UPDATED=1
    fi
fi

# Display success message
echo ""
echo "Installation successful!"
echo "Version: $("$INSTALL_PATH/andasy" version)"
echo ""

if [ $PATH_UPDATED -eq 1 ]; then
    echo "PATH updated in: $TERM_CONFIG"
    echo "Run: source $TERM_CONFIG"
    echo "Or open a new terminal to use 'andasy' command"
else
    if [ -n "$TERM_CONFIG" ]; then
        echo "PATH already configured in: $TERM_CONFIG"
    else
        echo "Warning: Could not detect shell configuration file"
        echo "Add '$INSTALL_PATH' to your PATH manually"
    fi
fi

echo ""
echo "🚀 Get started with: andasy --help"
