# Ubuntu Reference Guide

## System Update Command

### Full System Update Command
```bash
sudo apt update && sudo apt full-upgrade -y && sudo snap refresh && sudo apt autoremove -y && sudo apt autoclean
```

**What this does:**
- `apt update` - Refreshes package lists
- `apt full-upgrade` - Upgrades all packages (handles dependency changes better than `upgrade`)
- `snap refresh` - Updates Snap packages
- `apt autoremove` - Removes unused dependencies
- `apt autoclean` - Cleans up old package files to free disk space

---

## Creating a Bash Alias for System Updates

### Setup Instructions

1. **Open your `.bashrc` file:**
   ```bash
   nano ~/.bashrc
   ```

2. **Add these lines at the bottom:**
   ```bash
   # Custom alias to update all packages, snaps, and clean up the system
   # Usage: just type 'update-all' and press Enter
   alias update-all='sudo apt update && sudo apt full-upgrade -y && sudo snap refresh && sudo apt autoremove -y && sudo apt autoclean'
   ```

3. **Save and exit:**
   - Press `Ctrl+X`
   - Press `Y`
   - Press `Enter`

4. **Reload your `.bashrc`:**
   ```bash
   source ~/.bashrc
   ```

### Using the Alias

Simply type:
```bash
update-all
```

The command will prompt you for your password when needed (because of the `sudo` commands inside the alias).

**Note:** You cannot run `sudo update-all` because aliases don't work with sudo. Just use `update-all` as-is.

---

## Installing Google Chrome with Extrepo

### Prerequisites: Install Required Packages

Before installing Chrome, refresh your system's package index:

```bash
sudo apt update
```

Next, install the prerequisite packages. The following command installs everything needed:

```bash
sudo apt install ca-certificates curl extrepo -y
```

**What this installs:**
- `ca-certificates` - Certificate handling for HTTPS connections
- `curl` - Utility for downloading files
- `extrepo` - Automatic repository management tool

Ubuntu includes the `gpg` command by default for GPG key operations.

### Step 1: Enable Non-Free Policy

**Quick method (recommended):**
```bash
sudo sed -i 's/^# - non-free$/- non-free/' /etc/extrepo/config.yaml
```

**Manual method:**
1. Open the config file:
   ```bash
   sudo nano /etc/extrepo/config.yaml
   ```

2. Find the `enabled_policies:` section and uncomment `- non-free`:
   ```yaml
   enabled_policies:
   - main
   # - contrib
   - non-free
   ```

3. Save and exit (`Ctrl+X`, `Y`, `Enter`)

### Step 2: Enable the Google Chrome Repository

```bash
sudo extrepo enable google_chrome
```

### Step 3: Update Package Lists

```bash
sudo apt update
```

### Step 4: Install Google Chrome

**For stable version (recommended):**
```bash
sudo apt install google-chrome-stable
```

**For beta version:**
```bash
sudo apt install google-chrome-beta
```

**For unstable/dev version:**
```bash
sudo apt install google-chrome-unstable
```

**For canary version:**
```bash
sudo apt install google-chrome-canary
```

### Step 5: Remove Duplicate Repository Files (Important!)

Google's installer creates duplicate `.list` files that cause errors. Remove them:

```bash
sudo rm -f /etc/apt/sources.list.d/google-chrome*.list
sudo apt update
```

This cleanup is required only once after installation.

### Step 6: Verify Installation

```bash
google-chrome --version
```

---

## Troubleshooting: Duplicate Repository Warnings

If you see warnings like:
```
Warning: Target Packages (main/binary-amd64/Packages) is configured multiple times...
```

**Solution:**
Remove duplicate `.list` files:
```bash
sudo rm -f /etc/apt/sources.list.d/google-chrome*.list
sudo apt update
```

Keep only the extrepo-managed `.sources` file.

---

## Additional Notes

- Chrome updates automatically through your system updates (`update-all` alias)
- The stable version is most reliable for daily use
- Beta/unstable/canary versions are for testing new features
- All versions can be installed simultaneously

---

## Installing Must-Have Applications

### Quick Install (Recommended)

Install essential applications all at once with a single script from GitHub. The script checks what's already installed, then prompts you for optional components:
- **Google Chrome** - requires third-party repository
- **Snap-based apps** (VS Code & Spotify) - use 'classic' confinement

LibreOffice, VLC, and Remmina are installed automatically via apt.

> **⚠️ Security Warning:** Always review scripts before running them! You can view the script contents at:  
> https://github.com/mattencode/ubuntu-must-haves/blob/main/ubuntu-must-haves.sh  
> Never blindly execute scripts from the internet without checking what they do first.

```bash
# Download and run in one command
bash <(wget -qO- https://raw.githubusercontent.com/mattencode/ubuntu-must-haves/main/ubuntu-must-haves.sh)
```

Or download first, review it, then run:
```bash
wget https://raw.githubusercontent.com/mattencode/ubuntu-must-haves/main/ubuntu-must-haves.sh
cat ubuntu-must-haves.sh  # Review the script first!
bash ubuntu-must-haves.sh
```

For more details, visit the repository: https://github.com/mattencode/ubuntu-must-haves

---

### Individual Installation Instructions

If you prefer to install applications individually or use different methods, here are the manual installation instructions:

#### LibreOffice
LibreOffice usually comes pre-installed on Ubuntu. To install or update it:

```bash
sudo apt install libreoffice -y
```

#### Visual Studio Code
**Method 1: Via Snap (easiest):**
```bash
sudo snap install code --classic
```

**Method 2: Via Microsoft's Repository:**
```bash
# Import Microsoft GPG key
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
sudo install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg

# Add VS Code repository
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list

# Install VS Code
sudo apt update
sudo apt install code -y

# Clean up
rm -f packages.microsoft.gpg
```

#### VLC Media Player
```bash
sudo apt install vlc -y
```

#### Remmina (Remote Desktop Client)
Remmina usually comes pre-installed on Ubuntu. To install or update it:

```bash
sudo apt install remmina -y
```

#### Spotify
**Method 1: Via Snap (easiest):**
```bash
sudo snap install spotify
```

**Method 2: Via Spotify's Repository:**
```bash
# Import Spotify GPG key
curl -sS https://download.spotify.com/debian/pubkey_6224F9941A8AA6D1.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg

# Add Spotify repository
echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list

# Install Spotify
sudo apt update
sudo apt install spotify-client -y
```

---

**Last Updated:** December 30, 2025
