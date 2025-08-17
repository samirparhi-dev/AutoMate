#!/usr/bin/env bash
set -ex

# Install OpenTofu via direct binary download (more reliable)
apt-get update
apt-get install -y wget curl unzip

# Detect architecture
ARCH=$(dpkg --print-architecture)
case $ARCH in
    amd64) TOFU_ARCH="amd64" ;;
    arm64) TOFU_ARCH="arm64" ;;
    armhf) TOFU_ARCH="arm" ;;
    *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

# Get latest version (or specify a specific version)
TOFU_VERSION="1.6.0"  # You can update this to the latest version

# Download and install OpenTofu binary
cd /tmp
wget "https://github.com/opentofu/opentofu/releases/download/v${TOFU_VERSION}/tofu_${TOFU_VERSION}_linux_${TOFU_ARCH}.zip"
unzip "tofu_${TOFU_VERSION}_linux_${TOFU_ARCH}.zip"
chmod +x tofu
mv tofu /usr/local/bin/
rm -f "tofu_${TOFU_VERSION}_linux_${TOFU_ARCH}.zip"

# Verify installation
tofu --version

# Cleanup
if [ -z ${SKIP_CLEAN+x} ]; then
    apt-get autoremove -y
    apt-get autoclean
    rm -rf /var/lib/apt/lists/* /var/tmp/*
fi

# Fix permissions
chown -R 1000:0 $HOME
