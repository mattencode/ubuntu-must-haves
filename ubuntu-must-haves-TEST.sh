#!/bin/bash

###############################################################################
# Ubuntu Must-Have Applications Installer - TEST/DRY-RUN VERSION
# 
# This script simulates the installation process without actually installing
# anything. Use this to see how the script would behave.
#
# Usage: bash ubuntu-must-haves-test.sh
#
# You can configure which apps are "already installed" and simulate failures
# to test different scenarios.
###############################################################################

# =============================================================================
# TEST CONFIGURATION - Modify these to simulate different scenarios
# =============================================================================

# Simulate these apps as already installed (true/false)
SIM_CHROME_INSTALLED=false
SIM_LIBREOFFICE_INSTALLED=false
SIM_VSCODE_INSTALLED=false
SIM_VLC_INSTALLED=false
SIM_REMMINA_INSTALLED=true      # Example: Remmina is "already installed"
SIM_SPOTIFY_INSTALLED=false

# Simulate installation failures (true/false)
SIM_CHROME_FAIL=false
SIM_LIBREOFFICE_FAIL=false
SIM_VSCODE_FAIL=false
SIM_VLC_FAIL=false
SIM_REMMINA_FAIL=false
SIM_SPOTIFY_FAIL=false

# Simulate snapd availability
SIM_SNAPD_AVAILABLE=true

# Simulate snapd needs to be installed first
SIM_SNAPD_NEEDS_INSTALL=false

# =============================================================================
# END TEST CONFIGURATION
# =============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
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

print_dry_run() {
    echo -e "${MAGENTA}[DRY-RUN]${NC} $1"
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

# Simulated command checks (instead of real command_exists)
command_exists() {
    case "$1" in
        google-chrome|google-chrome-stable)
            [ "$SIM_CHROME_INSTALLED" = true ]
            ;;
        libreoffice)
            [ "$SIM_LIBREOFFICE_INSTALLED" = true ]
            ;;
        code)
            [ "$SIM_VSCODE_INSTALLED" = true ]
            ;;
        vlc)
            [ "$SIM_VLC_INSTALLED" = true ]
            ;;
        remmina)
            [ "$SIM_REMMINA_INSTALLED" = true ]
            ;;
        snap)
            [ "$SIM_SNAPD_AVAILABLE" = true ]
            ;;
        *)
            return 1
            ;;
    esac
}

# Simulated snap check
snap_installed() {
    case "$1" in
        code)
            [ "$SIM_VSCODE_INSTALLED" = true ]
            ;;
        spotify)
            [ "$SIM_SPOTIFY_INSTALLED" = true ]
            ;;
        *)
            return 1
            ;;
    esac
}

echo "=========================================="
echo "Ubuntu Must-Have Applications Installer"
echo -e "${MAGENTA}        *** TEST/DRY-RUN MODE ***${NC}"
echo "=========================================="
echo ""
print_dry_run "No actual installations will be performed"
print_dry_run "Edit the script's TEST CONFIGURATION section to simulate different scenarios"
echo ""

# Show current test configuration
print_header "Current test configuration:"
echo "  Simulated as already installed:"
[ "$SIM_CHROME_INSTALLED" = true ] && echo "    • Google Chrome"
[ "$SIM_LIBREOFFICE_INSTALLED" = true ] && echo "    • LibreOffice"
[ "$SIM_VSCODE_INSTALLED" = true ] && echo "    • VS Code"
[ "$SIM_VLC_INSTALLED" = true ] && echo "    • VLC"
[ "$SIM_REMMINA_INSTALLED" = true ] && echo "    • Remmina"
[ "$SIM_SPOTIFY_INSTALLED" = true ] && echo "    • Spotify"

has_simulated=false
[ "$SIM_CHROME_INSTALLED" = true ] && has_simulated=true
[ "$SIM_LIBREOFFICE_INSTALLED" = true ] && has_simulated=true
[ "$SIM_VSCODE_INSTALLED" = true ] && has_simulated=true
[ "$SIM_VLC_INSTALLED" = true ] && has_simulated=true
[ "$SIM_REMMINA_INSTALLED" = true ] && has_simulated=true
[ "$SIM_SPOTIFY_INSTALLED" = true ] && has_simulated=true
[ "$has_simulated" = false ] && echo "    (none)"

echo "  Simulated failures:"
has_failures=false
[ "$SIM_CHROME_FAIL" = true ] && echo "    • Google Chrome" && has_failures=true
[ "$SIM_LIBREOFFICE_FAIL" = true ] && echo "    • LibreOffice" && has_failures=true
[ "$SIM_VSCODE_FAIL" = true ] && echo "    • VS Code" && has_failures=true
[ "$SIM_VLC_FAIL" = true ] && echo "    • VLC" && has_failures=true
[ "$SIM_REMMINA_FAIL" = true ] && echo "    • Remmina" && has_failures=true
[ "$SIM_SPOTIFY_FAIL" = true ] && echo "    • Spotify" && has_failures=true
[ "$has_failures" = false ] && echo "    (none)"

echo "  Snapd available: $SIM_SNAPD_AVAILABLE"
echo "  Snapd needs install: $SIM_SNAPD_NEEDS_INSTALL"
echo ""

read -p "Press Enter to start the simulated installation... "
echo ""

# Check what's already installed
chrome_present=false
libreoffice_present=false
vscode_present=false
vlc_present=false
remmina_present=false
spotify_present=false

if command_exists google-chrome || command_exists google-chrome-stable; then
    chrome_present=true
fi
if command_exists libreoffice; then
    libreoffice_present=true
fi
if command_exists code || snap_installed code; then
    vscode_present=true
fi
if command_exists vlc; then
    vlc_present=true
fi
if command_exists remmina; then
    remmina_present=true
fi
if snap_installed spotify; then
    spotify_present=true
fi

# Show what will be installed
to_install=""
already_present=""

if [ "$chrome_present" = false ]; then
    to_install+="  • Google Chrome      (web browser, optional - requires third-party repo)\n"
else
    already_present+="  • Google Chrome\n"
fi
if [ "$libreoffice_present" = false ]; then
    to_install+="  • LibreOffice        (office suite, from apt)\n"
else
    already_present+="  • LibreOffice\n"
fi
if [ "$vscode_present" = false ]; then
    to_install+="  • Visual Studio Code (code editor, from snap)\n"
else
    already_present+="  • Visual Studio Code\n"
fi
if [ "$vlc_present" = false ]; then
    to_install+="  • VLC Media Player   (video player, from apt)\n"
else
    already_present+="  • VLC Media Player\n"
fi
if [ "$remmina_present" = false ]; then
    to_install+="  • Remmina            (remote desktop client, from apt)\n"
else
    already_present+="  • Remmina\n"
fi
if [ "$spotify_present" = false ]; then
    to_install+="  • Spotify            (music streaming, from snap)\n"
else
    already_present+="  • Spotify\n"
fi

if [ -n "$to_install" ]; then
    print_header "Will be installed:"
    echo -e "$to_install"
fi

if [ -n "$already_present" ]; then
    print_header "Already installed (will be skipped):"
    echo -e "$already_present"
fi

# Check if everything is already installed
if [ -z "$to_install" ]; then
    print_status "All applications are already installed. Nothing to do."
    exit 0
fi

print_info "Note: VS Code and Spotify use snap with 'classic' confinement,"
echo "    which gives them broader system access than regular snaps."
echo ""

read -p "Do you want to continue? (y/n): " continue_install
if [[ ! "$continue_install" =~ ^[Yy]$ ]]; then
    print_info "Installation cancelled."
    exit 0
fi

# Ask user about Chrome installation only if not already installed
install_chrome="n"
if [ "$chrome_present" = false ]; then
    echo ""
    print_info "Google Chrome installation requires adding third-party repositories (extrepo)."
    read -p "Do you want to install Google Chrome? (y/n): " install_chrome
fi
echo ""

# Update package lists
print_info "Updating package lists..."
print_dry_run "Would run: sudo apt-get update -qq"
sleep 1
print_status "Package lists updated"

# Check if snapd is available (needed for VS Code and Spotify)
snapd_available=false
if [ "$SIM_SNAPD_AVAILABLE" = true ] && [ "$SIM_SNAPD_NEEDS_INSTALL" = false ]; then
    snapd_available=true
elif [ "$SIM_SNAPD_NEEDS_INSTALL" = true ]; then
    print_info "Snapd not found. Installing snapd..."
    print_dry_run "Would run: sudo apt-get install -y -qq snapd"
    sleep 1
    print_status "Snapd installed successfully"
    
    print_info "Enabling snapd service..."
    print_dry_run "Would run: sudo systemctl enable --now snapd.socket"
    sleep 0.5
    
    print_dry_run "Would create symlink: /snap -> /var/lib/snapd/snap"
    
    print_info "Waiting for snapd to initialize..."
    print_dry_run "Would run: snap wait system seed.loaded"
    sleep 2
    
    if [ "$SIM_SNAPD_AVAILABLE" = true ]; then
        snapd_available=true
        print_status "Snapd is ready"
    else
        print_error "Snapd initialization failed. VS Code and Spotify will be skipped."
    fi
else
    print_error "Failed to install snapd. VS Code and Spotify will be skipped."
fi

echo ""
print_header "Installing applications..."
echo ""

# Install Google Chrome if user wants it
if [[ "$install_chrome" =~ ^[Yy]$ ]]; then
    if [ "$chrome_present" = true ]; then
        print_info "Google Chrome is already installed, skipping"
        chrome_skipped=true
        chrome_installed=true
    else
        print_info "Installing prerequisites for Chrome..."
        print_dry_run "Would run: sudo apt-get install -y -qq ca-certificates curl extrepo"
        sleep 0.5
        print_status "Prerequisites installed"

        print_info "Installing Google Chrome..."
        print_dry_run "Would run: sudo extrepo enable google_chrome"
        sleep 0.5
        print_status "Chrome repository enabled"
        
        print_dry_run "Would run: sudo apt-get update -qq"
        sleep 0.5
        
        print_dry_run "Would run: sudo apt-get install -y -qq google-chrome-stable"
        sleep 1
        
        if [ "$SIM_CHROME_FAIL" = true ]; then
            print_error "Failed to install Google Chrome"
        else
            print_status "Google Chrome installed successfully"
            chrome_installed=true
            print_dry_run "Would clean up duplicate repository files"
        fi
    fi
else
    print_info "Skipping Google Chrome installation"
fi

# Install LibreOffice
if [ "$libreoffice_present" = true ]; then
    print_info "LibreOffice is already installed, skipping"
    libreoffice_skipped=true
    libreoffice_installed=true
else
    print_info "Installing LibreOffice..."
    print_dry_run "Would run: sudo apt-get install -y -qq libreoffice"
    sleep 1
    if [ "$SIM_LIBREOFFICE_FAIL" = true ]; then
        print_error "Failed to install LibreOffice"
    else
        print_status "LibreOffice installed successfully"
        libreoffice_installed=true
    fi
fi

# Install Visual Studio Code (via Snap)
if [ "$vscode_present" = true ]; then
    print_info "Visual Studio Code is already installed, skipping"
    vscode_skipped=true
    vscode_installed=true
elif [ "$snapd_available" = true ]; then
    print_info "Installing Visual Studio Code..."
    print_dry_run "Would run: sudo snap install code --classic"
    sleep 1
    if [ "$SIM_VSCODE_FAIL" = true ]; then
        print_error "Failed to install VS Code"
    else
        print_status "VS Code installed successfully"
        vscode_installed=true
    fi
else
    print_error "Snapd not available, skipping VS Code installation"
fi

# Install VLC Media Player
if [ "$vlc_present" = true ]; then
    print_info "VLC is already installed, skipping"
    vlc_skipped=true
    vlc_installed=true
else
    print_info "Installing VLC Media Player..."
    print_dry_run "Would run: sudo apt-get install -y -qq vlc"
    sleep 1
    if [ "$SIM_VLC_FAIL" = true ]; then
        print_error "Failed to install VLC"
    else
        print_status "VLC installed successfully"
        vlc_installed=true
    fi
fi

# Install Remmina
if [ "$remmina_present" = true ]; then
    print_info "Remmina is already installed, skipping"
    remmina_skipped=true
    remmina_installed=true
else
    print_info "Installing Remmina..."
    print_dry_run "Would run: sudo apt-get install -y -qq remmina"
    sleep 1
    if [ "$SIM_REMMINA_FAIL" = true ]; then
        print_error "Failed to install Remmina"
    else
        print_status "Remmina installed successfully"
        remmina_installed=true
    fi
fi

# Install Spotify (via Snap)
if [ "$spotify_present" = true ]; then
    print_info "Spotify is already installed, skipping"
    spotify_skipped=true
    spotify_installed=true
elif [ "$snapd_available" = true ]; then
    print_info "Installing Spotify..."
    print_dry_run "Would run: sudo snap install spotify"
    sleep 1
    if [ "$SIM_SPOTIFY_FAIL" = true ]; then
        print_error "Failed to install Spotify"
    else
        print_status "Spotify installed successfully"
        spotify_installed=true
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
    print_dry_run "Would run: sudo apt-get autoremove -y -qq"
    print_dry_run "Would run: sudo apt-get autoclean -qq"
    sleep 0.5
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
echo ""
print_dry_run "Test complete. No actual changes were made to your system."
