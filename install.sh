#!/bin/sh

CLI_REPO="quarksgroup/andasy-cli"
ARCH="$(uname -m)"

# Detect architecture
case $ARCH in
    x86_64)
        ARCH="amd64"
        ;;
    arm64)
        ARCH="arm64"
        ;;
    *)
        echo "Unsupported architecture"
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
        echo "Unsupported operating system: $OSTYPE"
        exit 1
        ;;
esac

case $SHELL in
    */zsh)
        TERM_CONFIG="$HOME/.zshrc"
        ;;
    */bash)
        TERM_CONFIG="$HOME/.bashrc"
        ;;
    *)
        TERM_CONFIG="$HOME/.profile"
        ;;
esac

# Fetch download URL for the architecture from the GitHub API
ASSET_URL=$(curl -s https://api.github.com/repos/$CLI_REPO/releases/latest | \
    grep -o "https:\/\/github\.com\/$CLI_REPO\/releases\/download\/.*${OSTYPE}-${ARCH}.*" | \
    tr -d '\"')

if [ -z "$ASSET_URL" ]; then
    echo "Could not find a binary for latest version of andasy cli release and architecture ${ARCH} on OS type ${OSTYPE}"
    exit 1
fi

# Create bin directory if it doesn't exist
mkdir -p "$INSTALL_PATH"

# Download and install
curl -fSL ${ASSET_URL} | tar -xz -C $INSTALL_PATH
chmod +x $INSTALL_PATH/andasy

# Add to PATH
if ! grep -q "$INSTALL_PATH" $TERM_CONFIG; then
    echo "export PATH=$INSTALL_PATH:\$PATH" >> $TERM_CONFIG
fi

echo
echo "Andasy CLI has been installed to $INSTALL_PATH"
echo "$($INSTALL_PATH/andasy version)"

echo
echo "Run 'source $TERM_CONFIG' to update your terminal environment."
