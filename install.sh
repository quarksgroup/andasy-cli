#!/bin/sh

# This is a convenience script that can be downloaded from GitHub and
# piped into "sh" for conveniently downloading the latest GitHub release
# of the andasy CLI:
#
# curl -fsSL https://raw.githubusercontent.com/quarksgroup/andasy/main/install.sh | sh
#
# Warning: It may not be advisable to pipe scripts from GitHub directly into
# a command line interpreter! If you do not fully trust the source, first
# download the script, inspect it manually to ensure its integrity, and then
# run it:
#
# curl -fsSL https://raw.githubusercontent.com/quarksgroup/andasy/main/install.sh > install.sh
# vim install.sh
# ./install.sh

ANDASYCLI_REPO="quarksgroup/andasy-cli"
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
        INSTALL_PATH="/usr/local/bin"
        ;;
    Linux)
        OSTYPE="linux"
        INSTALL_PATH="/usr/bin"
        ;;
    *)
        echo "Unsupported operating system: $OSTYPE"
        exit 1
        ;;
esac

# Fetch download URL for the architecture from the GitHub API
ASSET_URL=$(curl -s https://api.github.com/repos/$ANDASYCLI_REPO/releases/latest | \
    grep -o "https:\/\/github\.com\/$ANDASYCLI_REPO\/releases\/download\/.*${OSTYPE}-${ARCH}.*" | \
    tr -d '\"')

if [ -z "$ASSET_URL" ]; then
    echo "Could not find a binary for latest version of andasy cli release and architecture ${ARCH} on OS type ${OSTYPE}"
    exit 1
fi

# Download and install
curl -L ${ASSET_URL} | tar xz
chmod +x ./andasy

# Move to appropriate bin directory based on OS
sudo mv ./andasy "$INSTALL_PATH"

echo
echo "You can now run:"
echo "  andasy --help"
echo "to get started."
echo "Enjoy!"
