#!/usr/bin/env bash
set -ex

# Function to detect OS
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VER=$VERSION_ID
    elif type lsb_release >/dev/null 2>&1; then
        OS=$(lsb_release -si | tr '[:upper:]' '[:lower:]')
        VER=$(lsb_release -sr)
    elif [ -f /etc/redhat-release ]; then
        OS="rhel"
    else
        OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    fi
}

# Function to detect architecture
detect_arch() {
    ARCH=$(uname -m)
    case $ARCH in
        x86_64) ZED_ARCH="x86_64" ;;
        aarch64|arm64) ZED_ARCH="aarch64" ;;
        *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
    esac
}

# Function to install dependencies for Ubuntu/Debian
install_ubuntu_deps() {
    apt-get update
    apt-get install -y wget curl tar gzip ca-certificates
}

# Function to install dependencies for Alpine
install_alpine_deps() {
    apk update
    apk add --no-cache wget curl tar gzip ca-certificates
}

# Function to install Zed via binary download
install_zed_binary() {
    echo "Installing Zed editor via binary download..."

    # Create temporary directory
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"

    # Download latest Zed release
    if [ "$ZED_ARCH" = "x86_64" ]; then
        ZED_URL="https://zed.dev/api/releases/stable/latest/zed-linux-x86_64.tar.gz"
        echo "Downloading Zed from: $ZED_URL"
        wget -O zed-linux.tar.gz "$ZED_URL"

        # Extract and install
        tar -xzf zed-linux.tar.gz

        # Debug: Show what was extracted
        echo "Extracted contents:"
        ls -la

        # Find the zed binary using find command
        ZED_BINARY=$(find . -name "zed" -type f | head -1)
        
        if [ -z "$ZED_BINARY" ]; then
            echo "Error: Could not find zed binary in extracted files"
            echo "Available files:"
            find . -type f
            exit 1
        fi

        echo "Found Zed binary at: $ZED_BINARY"

        # Install to /usr/local/bin
        mkdir -p /usr/local/bin
        cp "$ZED_BINARY" /usr/local/bin/zed
        chmod +x /usr/local/bin/zed

        # Create desktop entry if we're on a desktop system
        if [ -d /usr/share/applications ]; then
            mkdir -p /usr/share/applications
            cat > /usr/share/applications/zed.desktop <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Zed
Comment=A high-performance, multiplayer code editor
Exec=/usr/local/bin/zed %F
Icon=zed
Terminal=false
MimeType=text/plain;text/x-chdr;text/x-csrc;text/x-c++hdr;text/x-c++src;text/x-java;text/x-dsrc;text/x-pascal;text/x-perl;text/x-python;application/x-php;application/x-httpd-php3;application/x-httpd-php4;application/x-httpd-php5;application/x-ruby;text/x-tcl;text/x-tex;application/x-sh;text/x-chdr;text/x-csrc;text/x-dtd;text/css;text/html;text/xml;text/javascript;application/javascript;application/json;text/x-markdown;text/x-sql;
Categories=Development;TextEditor;
StartupNotify=true
EOF
        fi

        # Copy to Desktop if user desktop exists
        if [ -d "$HOME/Desktop" ]; then
            cp /usr/share/applications/zed.desktop "$HOME/Desktop/" 2>/dev/null || true
            chown 1000:1000 "$HOME/Desktop/zed.desktop" 2>/dev/null || true
            chmod +x "$HOME/Desktop/zed.desktop" 2>/dev/null || true
        fi

    else
        echo "ARM64/aarch64 support for Zed is limited. Installing via alternative method..."
        echo "Please check Zed's official documentation for ARM64 installation"
        exit 1
    fi

    # Cleanup
    cd /
    rm -rf "$TEMP_DIR"
}

# Function to install Zed via curl script (alternative method)
install_zed_curl() {
    echo "Installing Zed via official curl script..."
    curl -f https://zed.dev/install.sh | sh

    # Move from user local to system-wide if needed
    if [ -f "$HOME/.local/bin/zed" ]; then
        cp "$HOME/.local/bin/zed" /usr/local/bin/
        chmod +x /usr/local/bin/zed
    fi
}

# Main installation function
main() {
    echo "Starting Zed editor installation..."

    # Detect OS and architecture
    detect_os
    detect_arch

    echo "Detected OS: $OS"
    echo "Detected Architecture: $ZED_ARCH"

    # Install dependencies based on OS
    case $OS in
        ubuntu|debian)
            echo "Installing dependencies for Ubuntu/Debian..."
            install_ubuntu_deps
            ;;
        alpine)
            echo "Installing dependencies for Alpine..."
            install_alpine_deps
            ;;
        *)
            echo "Unsupported OS: $OS"
            echo "Attempting to install with minimal dependencies..."
            ;;
    esac

    # Try binary installation first, fallback to curl script
    if install_zed_binary; then
        echo "Zed installed successfully via binary download"
    else
        echo "Binary installation failed, trying curl script..."
        install_zed_curl
    fi

    # Verify installation
    if command -v zed >/dev/null 2>&1; then
        echo "Zed editor installed successfully!"
        echo "Zed location: $(which zed)"
        zed --version || echo "Zed installed but version check failed (this is normal for some versions)"
    else
        echo "Zed installation failed!"
        exit 1
    fi

    # Cleanup
    if [ -z ${SKIP_CLEAN+x} ]; then
        case $OS in
            ubuntu|debian)
                apt-get autoremove -y
                apt-get autoclean
                rm -rf /var/lib/apt/lists/* /var/tmp/*
                ;;
            alpine)
                rm -rf /var/cache/apk/* /tmp/*
                ;;
        esac
    fi

    # Fix permissions
    chown -R 1000:0 $HOME 2>/dev/null || true

    echo "Zed editor installation completed!"
}

# Run main function
main "$@"