# Ubuntu Must-Haves

Quick setup scripts and reference guide for Ubuntu systems.

## Quick Start

### Generate your own script

Download and open ```install-script-generator.html``` to pick which applications should be installed. You can then download the script and run it:
```bash '~/YOUR DOWNLOADS FOLDER/ubuntu-install.sh'
``## Install Must-Have Applications

Install essential applications with one command. The script checks what's already installed, then asks about optional components before proceeding:

```bash
bash <(wget -qO- https://raw.githubusercontent.com/mattencode/ubuntu-must-haves/main/ubuntu-must-haves.sh)
```

Or download and run:
```bash
wget https://raw.githubusercontent.com/mattencode/ubuntu-must-haves/main/ubuntu-must-haves.sh
bash ubuntu-must-haves.sh
```

**What it installs:**
- **Google Chrome** - Web browser (optional - requires third-party repo)
  - *Note:* Installing Chrome requires adding Google's repository via **extrepo**, Ubuntu's external repository management tool. Extrepo safely manages third-party software sources by handling GPG keys and repository configurations automatically. The script will prompt you before making any changes.
- **LibreOffice** - Full office suite (Writer, Calc, Impress, etc.)
- **Visual Studio Code** - Modern code editor (optional - installed via snap)
- **VLC Media Player** - Versatile media player
- **Remmina** - Remote desktop client (RDP, VNC, SSH)
- **Spotify** - Music streaming client (optional - installed via snap)

**Optional prompts:**
1. **Google Chrome** - Requires adding third-party repositories (extrepo)
2. **Snap-based apps** (VS Code & Spotify) - Use 'classic' confinement which gives broader system access

## Files in This Repository

- **ubuntu-reference-guide.md** - Complete reference guide with all commands
- **ubuntu-must-haves.sh** - Automated installer for must-have applications
- **ubuntu-must-haves-TEST.sh** - Test/dry-run version to preview script behavior
- **README.md** - This file

## Requirements

- Ubuntu 22.04 LTS or newer
- Internet connection
- Sudo privileges

## Installation Methods

The script uses Snap for VS Code and Spotify for easier updates and sandboxing. If you prefer APT packages or want to skip snap entirely, you can decline when prompted. See the reference guide for alternative installation methods.

### About Third-Party Repositories

**Google Chrome** installation uses **extrepo** (External Repository Tool), which is Ubuntu's recommended way to manage third-party software sources. Extrepo:
- Automatically handles GPG key imports for package verification
- Creates properly configured repository files
- Maintains security by ensuring packages are cryptographically signed
- Is maintained by the Debian/Ubuntu community

When you choose to install Chrome, the script will:
1. Enable extrepo's non-free policy (required for proprietary software)
2. Add Google's official Chrome repository
3. Install Chrome from this verified source
4. Clean up any duplicate repository files

You'll be prompted before any of these changes are made.

## Contributing

Feel free to suggest additional must-have applications or improvements!

## License

Free to use and modify.
