#!/bin/bash

###############################################################################
# Ubuntu Must-Have Applications Installer
# 
# This script installs essential applications for Ubuntu:
# - Google Chrome (web browser)
# - LibreOffice (office suite)
# - Visual Studio Code (code editor)
# - VLC Media Player (video player)
# - Remmina (remote desktop client)
# - Spotify (music streaming)
#
# Usage: bash ubuntu-must-haves.sh
###############################################################################

# Removed: set -e
# We want to continue installing other apps even if one fails

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_info() {
    echo -e "${YELLOW}[i]${NC} $1"
}

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    print_error "Please do not run this script as root or with sudo"
    exit 1
fi

# Track which apps were successfully installed
chrome_installed=false
libreoffice_installed=false
vscode_installed=false
vlc_installed=false
remmina_installed=false
spotify_installed=false

echo "=========================================="
echo "Ubuntu Must-Have Applications Installer"
echo "=========================================="
echo ""

# Ask user about Chrome installation
echo ""
echo "Google Chrome installation requires adding third-party repositories (extrepo)."
read -p "Do you want to install Google Chrome? (y/n): " install_chrome
echo ""

# Update package lists
print_info "Updating package lists..."
if ! sudo apt update; then
    print_error "Failed to update package lists. Check your internet connection."
    exit 1
fi

# Check if snapd is available (needed for VS Code and Spotify)
if ! command -v snap &> /dev/null; then
    print_info "Snapd not found. Installing snapd..."
    if sudo apt install -y snapd; then
        print_status "Snapd installed successfully"
    else
        print_error "Failed to install snapd. VS Code and Spotify will be skipped."
    fi
fi

# Install Google Chrome if user wants it
if [[ "$install_chrome" =~ ^[Yy]$ ]]; then
    # Install prerequisites for Chrome
    print_info "Installing prerequisites for Chrome..."
    if sudo apt install -y ca-certificates curl extrepo; then
        print_status "Prerequisites installed successfully"
    else
        print_error "Failed to install prerequisites"
    fi

    # Install Google Chrome via extrepo
    print_info "Installing Google Chrome..."

    # Enable non-free policy for extrepo (more robust approach)
    if [ -f /etc/extrepo/config.yaml ]; then
        # Check if non-free is already enabled
        if grep -q "^- non-free" /etc/extrepo/config.yaml; then
            print_info "Non-free policy already enabled"
        elif grep -q "^# - non-free" /etc/extrepo/config.yaml || grep -q "^#- non-free" /etc/extrepo/config.yaml; then
            # Try to enable it (handles various comment formats)
            if sudo sed -i 's/^#[[:space:]]*-[[:space:]]*non-free/- non-free/' /etc/extrepo/config.yaml; then
                print_status "Non-free policy enabled"
            else
                print_error "Failed to enable non-free policy"
            fi
        else
            print_info "Non-free policy not found in config, extrepo will handle it"
        fi
    else
        print_info "Extrepo config not found, will attempt installation anyway"
    fi

    # Enable Google Chrome repository
    if sudo extrepo enable google_chrome 2>/dev/null; then
        print_status "Chrome repository enabled"
        
        # Update package lists again
        if ! sudo apt update; then
            print_error "Failed to update package lists after adding Chrome repository"
        fi
        
        # Install Chrome
        if sudo apt install -y google-chrome-stable; then
            print_status "Google Chrome installed successfully"
            chrome_installed=true
            
            # Remove duplicate .list files created by Chrome's postinstall script
            # Extrepo uses .sources format, Chrome's installer creates .list files
            sudo rm -f /etc/apt/sources.list.d/google-chrome*.list 2>/dev/null
            print_status "Cleaned up duplicate repository files"
        else
            print_error "Failed to install Google Chrome"
        fi
    else
        print_error "Failed to enable Chrome repository"
    fi
else
    print_info "Skipping Google Chrome installation"
fi

# Install LibreOffice
print_info "Installing LibreOffice..."
if sudo apt install -y libreoffice; then
    print_status "LibreOffice installed successfully"
    libreoffice_installed=true
else
    print_error "Failed to install LibreOffice"
fi

# Install Visual Studio Code (via Snap - easier and auto-updates)
print_info "Installing Visual Studio Code..."
if command -v snap &> /dev/null; then
    if sudo snap install code --classic; then
        print_status "VS Code installed successfully"
        vscode_installed=true
    else
        print_error "Failed to install VS Code"
    fi
else
    print_error "Snapd not available, skipping VS Code installation"
fi

# Install VLC Media Player
print_info "Installing VLC Media Player..."
if sudo apt install -y vlc; then
    print_status "VLC installed successfully"
    vlc_installed=true
else
    print_error "Failed to install VLC"
fi

# Install Remmina
print_info "Installing Remmina..."
if sudo apt install -y remmina; then
    print_status "Remmina installed successfully"
    remmina_installed=true
else
    print_error "Failed to install Remmina"
fi

# Install Spotify (via Snap - easier and auto-updates)
print_info "Installing Spotify..."
if command -v snap &> /dev/null; then
    if sudo snap install spotify; then
        print_status "Spotify installed successfully"
        spotify_installed=true
    else
        print_error "Failed to install Spotify"
    fi
else
    print_error "Snapd not available, skipping Spotify installation"
fi

# Clean up
print_info "Cleaning up..."
sudo apt autoremove -y
sudo apt autoclean

echo ""
echo "=========================================="
print_status "Installation complete!"
echo "=========================================="
echo ""
echo "Successfully installed applications:"
if [ "$chrome_installed" = true ]; then
    echo "  • Google Chrome"
fi
if [ "$libreoffice_installed" = true ]; then
    echo "  • LibreOffice"
fi
if [ "$vscode_installed" = true ]; then
    echo "  • Visual Studio Code"
fi
if [ "$vlc_installed" = true ]; then
    echo "  • VLC Media Player"
fi
if [ "$remmina_installed" = true ]; then
    echo "  • Remmina"
fi
if [ "$spotify_installed" = true ]; then
    echo "  • Spotify"
fi
echo ""

# Show failed installations if any
failed=false
if [[ "$install_chrome" =~ ^[Yy]$ ]] && [ "$chrome_installed" = false ]; then
    if [ "$failed" = false ]; then
        echo "Failed to install:"
        failed=true
    fi
    echo "  ✗ Google Chrome"
fi
if [ "$libreoffice_installed" = false ]; then
    if [ "$failed" = false ]; then
        echo "Failed to install:"
        failed=true
    fi
    echo "  ✗ LibreOffice"
fi
if [ "$vscode_installed" = false ]; then
    if [ "$failed" = false ]; then
        echo "Failed to install:"
        failed=true
    fi
    echo "  ✗ Visual Studio Code"
fi
if [ "$vlc_installed" = false ]; then
    if [ "$failed" = false ]; then
        echo "Failed to install:"
        failed=true
    fi
    echo "  ✗ VLC Media Player"
fi
if [ "$remmina_installed" = false ]; then
    if [ "$failed" = false ]; then
        echo "Failed to install:"
        failed=true
    fi
    echo "  ✗ Remmina"
fi
if [ "$spotify_installed" = false ]; then
    if [ "$failed" = false ]; then
        echo "Failed to install:"
        failed=true
    fi
    echo "  ✗ Spotify"
fi

if [ "$failed" = true ]; then
    echo ""
fi

echo "You can now launch these applications from your application menu."
