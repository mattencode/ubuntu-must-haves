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

set -e  # Exit on error

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
sudo apt update

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

    # Enable non-free policy for extrepo
    if sudo sed -i 's/^# - non-free$/- non-free/' /etc/extrepo/config.yaml 2>/dev/null; then
        print_status "Non-free policy enabled"
    else
        print_info "Non-free policy already enabled or config not found"
    fi

    # Enable Google Chrome repository
    if sudo extrepo enable google_chrome 2>/dev/null; then
        print_status "Chrome repository enabled"
        
        # Update package lists again
        sudo apt update
        
        # Install Chrome
        if sudo apt install -y google-chrome-stable; then
            print_status "Google Chrome installed successfully"
            
            # Remove duplicate repository files
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
else
    print_error "Failed to install LibreOffice"
fi

# Install Visual Studio Code (via Snap - easier and auto-updates)
print_info "Installing Visual Studio Code..."
if sudo snap install code --classic; then
    print_status "VS Code installed successfully"
else
    print_error "Failed to install VS Code"
fi

# Install VLC Media Player
print_info "Installing VLC Media Player..."
if sudo apt install -y vlc; then
    print_status "VLC installed successfully"
else
    print_error "Failed to install VLC"
fi

# Install Remmina
print_info "Installing Remmina..."
if sudo apt install -y remmina; then
    print_status "Remmina installed successfully"
else
    print_error "Failed to install Remmina"
fi

# Install Spotify (via Snap - easier and auto-updates)
print_info "Installing Spotify..."
if sudo snap install spotify; then
    print_status "Spotify installed successfully"
else
    print_error "Failed to install Spotify"
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
echo "Installed applications:"
if [[ "$install_chrome" =~ ^[Yy]$ ]]; then
    echo "  • Google Chrome"
fi
echo "  • LibreOffice"
echo "  • Visual Studio Code"
echo "  • VLC Media Player"
echo "  • Remmina"
echo "  • Spotify"
echo ""
echo "You can now launch these applications from your application menu."
