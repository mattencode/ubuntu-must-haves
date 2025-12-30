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

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_header() {
    echo -e "${BLUE}$1${NC}"
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

# Track which apps were already installed
chrome_skipped=false
libreoffice_skipped=false
vscode_skipped=false
vlc_skipped=false
remmina_skipped=false
spotify_skipped=false

echo "=========================================="
echo "Ubuntu Must-Have Applications Installer"
echo "=========================================="
echo ""

# Show what will be installed
print_header "This script will install the following applications:"
echo "  • Google Chrome     (web browser, optional - requires third-party repo)"
echo "  • LibreOffice       (office suite, from apt)"
echo "  • Visual Studio Code (code editor, from snap)"
echo "  • VLC Media Player  (video player, from apt)"
echo "  • Remmina           (remote desktop client, from apt)"
echo "  • Spotify           (music streaming, from snap)"
echo ""
print_info "Note: VS Code and Spotify use snap with 'classic' confinement,"
print_info "which gives them broader system access than regular snaps."
echo ""

read -p "Do you want to continue? (y/n): " continue_install
if [[ ! "$continue_install" =~ ^[Yy]$ ]]; then
    print_info "Installation cancelled."
    exit 0
fi

# Ask user about Chrome installation
echo ""
print_info "Google Chrome installation requires adding third-party repositories (extrepo)."
read -p "Do you want to install Google Chrome? (y/n): " install_chrome
echo ""

# Update package lists
print_info "Updating package lists..."
if ! sudo apt-get update -qq; then
    print_error "Failed to update package lists. Check your internet connection."
    exit 1
fi
print_status "Package lists updated"

# Check if snapd is available (needed for VS Code and Spotify)
snapd_available=false
if command -v snap &> /dev/null; then
    snapd_available=true
else
    print_info "Snapd not found. Installing snapd..."
    if sudo apt-get install -y -qq snapd; then
        print_status "Snapd installed successfully"
        
        # Enable and start snapd socket
        print_info "Enabling snapd service..."
        sudo systemctl enable --now snapd.socket
        
        # Create symlink for classic snap support
        if [ ! -e /snap ]; then
            sudo ln -s /var/lib/snapd/snap /snap
        fi
        
        # Wait for snapd to be ready
        print_info "Waiting for snapd to initialize..."
        sleep 5
        
        # Verify snap is working
        if sudo snap wait system seed.loaded 2>/dev/null; then
            snapd_available=true
            print_status "Snapd is ready"
        else
            # Fallback: just wait a bit more and hope for the best
            sleep 5
            if command -v snap &> /dev/null; then
                snapd_available=true
                print_status "Snapd appears ready"
            else
                print_error "Snapd initialization failed. VS Code and Spotify will be skipped."
            fi
        fi
    else
        print_error "Failed to install snapd. VS Code and Spotify will be skipped."
    fi
fi

# Function to check if a command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Function to check if a snap is installed
snap_installed() {
    snap list "$1" &> /dev/null 2>&1
}

echo ""
print_header "Installing applications..."
echo ""

# Install Google Chrome if user wants it
if [[ "$install_chrome" =~ ^[Yy]$ ]]; then
    if command_exists google-chrome || command_exists google-chrome-stable; then
        print_info "Google Chrome is already installed, skipping"
        chrome_skipped=true
        chrome_installed=true
    else
        # Install prerequisites for Chrome
        print_info "Installing prerequisites for Chrome..."
        if sudo apt-get install -y -qq ca-certificates curl extrepo; then
            print_status "Prerequisites installed"
        else
            print_error "Failed to install prerequisites"
        fi

        # Install Google Chrome via extrepo
        print_info "Installing Google Chrome..."

        # Enable non-free policy for extrepo
        if [ -f /etc/extrepo/config.yaml ]; then
            # Use grep + sed with multiple pattern attempts
            if ! grep -qE "^-[[:space:]]*non-free" /etc/extrepo/config.yaml; then
                # Try to uncomment non-free line (handles various formats)
                sudo sed -i -E 's/^#[[:space:]]*(-[[:space:]]*non-free)/\1/' /etc/extrepo/config.yaml 2>/dev/null
            fi
        fi

        # Enable Google Chrome repository
        if sudo extrepo enable google_chrome 2>/dev/null; then
            print_status "Chrome repository enabled"
            
            # Update package lists again
            sudo apt-get update -qq
            
            # Install Chrome
            if sudo apt-get install -y -qq google-chrome-stable; then
                print_status "Google Chrome installed successfully"
                chrome_installed=true
                
                # Remove duplicate .list files created by Chrome's postinstall script
                # Extrepo uses .sources format, Chrome's installer creates .list files
                sudo rm -f /etc/apt/sources.list.d/google-chrome*.list 2>/dev/null
            else
                print_error "Failed to install Google Chrome"
            fi
        else
            print_error "Failed to enable Chrome repository"
            print_info "You can install Chrome manually from https://www.google.com/chrome/"
        fi
    fi
else
    print_info "Skipping Google Chrome installation"
fi

# Install LibreOffice
if command_exists libreoffice; then
    print_info "LibreOffice is already installed, skipping"
    libreoffice_skipped=true
    libreoffice_installed=true
else
    print_info "Installing LibreOffice..."
    if sudo apt-get install -y -qq libreoffice; then
        print_status "LibreOffice installed successfully"
        libreoffice_installed=true
    else
        print_error "Failed to install LibreOffice"
    fi
fi

# Install Visual Studio Code (via Snap)
if command_exists code || snap_installed code; then
    print_info "Visual Studio Code is already installed, skipping"
    vscode_skipped=true
    vscode_installed=true
elif [ "$snapd_available" = true ]; then
    print_info "Installing Visual Studio Code..."
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
if command_exists vlc; then
    print_info "VLC is already installed, skipping"
    vlc_skipped=true
    vlc_installed=true
else
    print_info "Installing VLC Media Player..."
    if sudo apt-get install -y -qq vlc; then
        print_status "VLC installed successfully"
        vlc_installed=true
    else
        print_error "Failed to install VLC"
    fi
fi

# Install Remmina
if command_exists remmina; then
    print_info "Remmina is already installed, skipping"
    remmina_skipped=true
    remmina_installed=true
else
    print_info "Installing Remmina..."
    if sudo apt-get install -y -qq remmina; then
        print_status "Remmina installed successfully"
        remmina_installed=true
    else
        print_error "Failed to install Remmina"
    fi
fi

# Install Spotify (via Snap)
if snap_installed spotify; then
    print_info "Spotify is already installed, skipping"
    spotify_skipped=true
    spotify_installed=true
elif [ "$snapd_available" = true ]; then
    print_info "Installing Spotify..."
    if sudo snap install spotify; then
        print_status "Spotify installed successfully"
        spotify_installed=true
    else
        print_error "Failed to install Spotify"
    fi
else
    print_error "Snapd not available, skipping Spotify installation"
fi

# Clean up (only if something was installed)
if [ "$chrome_skipped" = false ] || [ "$libreoffice_skipped" = false ] || \
   [ "$vscode_skipped" = false ] || [ "$vlc_skipped" = false ] || \
   [ "$remmina_skipped" = false ] || [ "$spotify_skipped" = false ]; then
    echo ""
    print_info "Cleaning up..."
    sudo apt-get autoremove -y -qq
    sudo apt-get autoclean -qq
fi

echo ""
echo "=========================================="
print_status "Installation complete!"
echo "=========================================="
echo ""

# Show results
newly_installed=false
already_installed=false
failed=false

# Collect newly installed
newly=""
if [ "$chrome_installed" = true ] && [ "$chrome_skipped" = false ]; then
    newly+="  • Google Chrome\n"
    newly_installed=true
fi
if [ "$libreoffice_installed" = true ] && [ "$libreoffice_skipped" = false ]; then
    newly+="  • LibreOffice\n"
    newly_installed=true
fi
if [ "$vscode_installed" = true ] && [ "$vscode_skipped" = false ]; then
    newly+="  • Visual Studio Code\n"
    newly_installed=true
fi
if [ "$vlc_installed" = true ] && [ "$vlc_skipped" = false ]; then
    newly+="  • VLC Media Player\n"
    newly_installed=true
fi
if [ "$remmina_installed" = true ] && [ "$remmina_skipped" = false ]; then
    newly+="  • Remmina\n"
    newly_installed=true
fi
if [ "$spotify_installed" = true ] && [ "$spotify_skipped" = false ]; then
    newly+="  • Spotify\n"
    newly_installed=true
fi

if [ "$newly_installed" = true ]; then
    echo "Newly installed:"
    echo -e "$newly"
fi

# Collect already installed
already=""
if [ "$chrome_skipped" = true ]; then
    already+="  • Google Chrome\n"
    already_installed=true
fi
if [ "$libreoffice_skipped" = true ]; then
    already+="  • LibreOffice\n"
    already_installed=true
fi
if [ "$vscode_skipped" = true ]; then
    already+="  • Visual Studio Code\n"
    already_installed=true
fi
if [ "$vlc_skipped" = true ]; then
    already+="  • VLC Media Player\n"
    already_installed=true
fi
if [ "$remmina_skipped" = true ]; then
    already+="  • Remmina\n"
    already_installed=true
fi
if [ "$spotify_skipped" = true ]; then
    already+="  • Spotify\n"
    already_installed=true
fi

if [ "$already_installed" = true ]; then
    echo "Already installed (skipped):"
    echo -e "$already"
fi

# Collect failures
failures=""
if [[ "$install_chrome" =~ ^[Yy]$ ]] && [ "$chrome_installed" = false ]; then
    failures+="  ✗ Google Chrome\n"
    failed=true
fi
if [ "$libreoffice_installed" = false ]; then
    failures+="  ✗ LibreOffice\n"
    failed=true
fi
if [ "$vscode_installed" = false ] && [ "$snapd_available" = true ]; then
    failures+="  ✗ Visual Studio Code\n"
    failed=true
fi
if [ "$vlc_installed" = false ]; then
    failures+="  ✗ VLC Media Player\n"
    failed=true
fi
if [ "$remmina_installed" = false ]; then
    failures+="  ✗ Remmina\n"
    failed=true
fi
if [ "$spotify_installed" = false ] && [ "$snapd_available" = true ]; then
    failures+="  ✗ Spotify\n"
    failed=true
fi

if [ "$failed" = true ]; then
    echo "Failed to install:"
    echo -e "$failures"
fi

echo "You can launch these applications from your application menu."
