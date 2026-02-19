#!/usr/bin/env bash
# =============================================================================
#  Bug Bounty Lab Setup Script
#  Compatible with: Kali Linux / Parrot OS / Ubuntu 22.04+
#  Run as: sudo bash bugbounty_setup.sh
# =============================================================================

set -uo pipefail
# Note: NOT using 'set -e' so that individual tool failures don't abort the whole install

# ── Colours ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ── Helpers ───────────────────────────────────────────────────────────────────
info()    { echo -e "${CYAN}[*]${NC} $1"; }
success() { echo -e "${GREEN}[✔]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
error()   { echo -e "${RED}[✘]${NC} $1"; }
section() { echo -e "\n${BOLD}${CYAN}══════════════════════════════════════════${NC}"; \
            echo -e "${BOLD}${CYAN}  $1${NC}"; \
            echo -e "${BOLD}${CYAN}══════════════════════════════════════════${NC}"; }

# ── Root check ────────────────────────────────────────────────────────────────
if [[ $EUID -ne 0 ]]; then
  error "Please run this script as root: sudo bash $0"
  exit 1
fi

# ── Detect real user (for Go paths etc.) ─────────────────────────────────────
REAL_USER=${SUDO_USER:-$(whoami)}
REAL_HOME=$(eval echo "~$REAL_USER")
TOOLS_DIR="$REAL_HOME/tools"
WORDLIST_DIR="/opt/wordlists"
GO_VERSION="1.22.3"
GO_ARCH="amd64"

mkdir -p "$TOOLS_DIR" "$WORDLIST_DIR"

# ── Log file ──────────────────────────────────────────────────────────────────
LOG="/var/log/bugbounty_setup.log"
exec > >(tee -a "$LOG") 2>&1
info "Full log saved to $LOG"

# =============================================================================
# 0. SYSTEM UPDATE & BASE DEPS
# =============================================================================
section "0. System Update & Base Dependencies"

# Helper: install packages one-by-one so a missing package doesn't abort everything
safe_apt_install() {
  for pkg in "$@"; do
    if apt-get install -y "$pkg" &>/dev/null; then
      success "  $pkg"
    else
      warn "  $pkg not found in repos — skipping (non-critical)"
    fi
  done
}

apt-get update -y && apt-get upgrade -y

info "Installing core packages..."
safe_apt_install \
  curl wget git unzip tar build-essential \
  python3 python3-pip python3-venv pipx \
  ruby ruby-dev \
  libssl-dev libffi-dev libpcap-dev \
  nmap masscan nikto sqlmap \
  whois dnsutils net-tools \
  chromium chromium-driver \
  tmux zsh jq \
  libxml2-utils \
  apt-transport-https ca-certificates gnupg lsb-release

# ── Java: try multiple package names for Kali/Ubuntu/Parrot compatibility ──
info "Installing Java..."
if apt-get install -y default-jre &>/dev/null; then
  success "Java (default-jre) installed"
elif apt-get install -y openjdk-17-jre &>/dev/null; then
  success "Java (openjdk-17-jre) installed"
elif apt-get install -y openjdk-21-jre &>/dev/null; then
  success "Java (openjdk-21-jre) installed"
else
  warn "Java not installed — Burp Suite JAR will not work without it. Install manually."
fi

# ── System info tools: neofetch removed from Kali, use fastfetch ──
info "Installing system info tool..."
if apt-get install -y fastfetch &>/dev/null; then
  success "fastfetch installed"
elif apt-get install -y neofetch &>/dev/null; then
  success "neofetch installed"
else
  warn "No system info tool found (cosmetic only, not required)"
fi

success "Base dependencies installed"

# =============================================================================
# 1. GO LANGUAGE (required for most modern tools)
# =============================================================================
section "1. Go Language"

if ! command -v go &>/dev/null; then
  info "Installing Go $GO_VERSION..."
  GO_TAR="go${GO_VERSION}.linux-${GO_ARCH}.tar.gz"
  wget -q "https://go.dev/dl/${GO_TAR}" -O /tmp/${GO_TAR}
  tar -C /usr/local -xzf /tmp/${GO_TAR}
  rm /tmp/${GO_TAR}

  # Add to system-wide profile
  cat >> /etc/profile.d/go.sh <<'EOF'
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
EOF
  chmod +x /etc/profile.d/go.sh

  # Also add to real user's shell rc files
  for RC in "$REAL_HOME/.bashrc" "$REAL_HOME/.zshrc"; do
    if [[ -f "$RC" ]]; then
      grep -q "go/bin" "$RC" || cat >> "$RC" <<'EOF'

# Go
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin
EOF
    fi
  done

  export PATH=$PATH:/usr/local/go/bin
  export GOPATH=$REAL_HOME/go
  export PATH=$PATH:$GOPATH/bin
  success "Go $GO_VERSION installed"
else
  success "Go already installed: $(go version)"
fi

# Helper: install a Go-based tool
install_go_tool() {
  local name="$1"
  local pkg="$2"
  info "Installing $name..."
  GOPATH=$REAL_HOME/go go install "$pkg" 2>/dev/null && success "$name installed" || warn "$name failed — check log"
}

# =============================================================================
# 2. RECONNAISSANCE & OSINT
# =============================================================================
section "2. Reconnaissance & OSINT Tools"

# Amass
if ! command -v amass &>/dev/null; then
  install_go_tool "Amass" "github.com/owasp-amass/amass/v4/...@master"
fi

# Subfinder
install_go_tool "Subfinder"  "github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest"

# Assetfinder
install_go_tool "Assetfinder" "github.com/tomnomnom/assetfinder@latest"

# theHarvester
info "Installing theHarvester..."
pip3 install theHarvester --break-system-packages 2>/dev/null || \
  git -C "$TOOLS_DIR" clone --depth 1 https://github.com/laramies/theHarvester.git 2>/dev/null && \
  pip3 install -r "$TOOLS_DIR/theHarvester/requirements/base.txt" --break-system-packages
success "theHarvester done"

# dnsx
install_go_tool "dnsx" "github.com/projectdiscovery/dnsx/cmd/dnsx@latest"

# shuffledns
install_go_tool "shuffledns" "github.com/projectdiscovery/shuffledns/cmd/shuffledns@latest"

# =============================================================================
# 3. HTTP PROBING & CRAWLING
# =============================================================================
section "3. HTTP Probing & Web Crawling"

install_go_tool "httpx"       "github.com/projectdiscovery/httpx/cmd/httpx@latest"
install_go_tool "Katana"      "github.com/projectdiscovery/katana/cmd/katana@latest"
install_go_tool "GoSpider"    "github.com/jaeles-project/gospider@latest"
install_go_tool "Hakrawler"   "github.com/hakluke/hakrawler@latest"
install_go_tool "Waybackurls" "github.com/tomnomnom/waybackurls@latest"
install_go_tool "gau"         "github.com/lc/gau/v2/cmd/gau@latest"
install_go_tool "unfurl"      "github.com/tomnomnom/unfurl@latest"
install_go_tool "anew"        "github.com/tomnomnom/anew@latest"
install_go_tool "qsreplace"   "github.com/tomnomnom/qsreplace@latest"

# =============================================================================
# 4. VULNERABILITY SCANNING
# =============================================================================
section "4. Vulnerability Scanners"

# Nuclei
install_go_tool "Nuclei" "github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest"

# Pull Nuclei templates
info "Downloading Nuclei templates..."
NUCLEI_TMPL="$REAL_HOME/nuclei-templates"
if [[ ! -d "$NUCLEI_TMPL" ]]; then
  sudo -u "$REAL_USER" git clone --depth 1 https://github.com/projectdiscovery/nuclei-templates.git "$NUCLEI_TMPL"
  success "Nuclei templates cloned"
else
  sudo -u "$REAL_USER" git -C "$NUCLEI_TMPL" pull --quiet
  success "Nuclei templates updated"
fi

# Nmap already installed via apt above
# Masscan already installed via apt

# =============================================================================
# 5. WEB APPLICATION TESTING
# =============================================================================
section "5. Web Application Testing"

# ffuf
install_go_tool "ffuf"        "github.com/ffuf/ffuf/v2@latest"

# feroxbuster
info "Installing feroxbuster..."
if ! command -v feroxbuster &>/dev/null; then
  curl -sL https://raw.githubusercontent.com/epi052/feroxbuster/main/install-nix.sh | bash -s "$REAL_HOME/.local/bin" 2>/dev/null
  ln -sf "$REAL_HOME/.local/bin/feroxbuster" /usr/local/bin/feroxbuster 2>/dev/null || true
fi
success "feroxbuster done"

# dirsearch
info "Installing dirsearch..."
git -C "$TOOLS_DIR" clone --depth 1 https://github.com/maurosoria/dirsearch.git 2>/dev/null || \
  git -C "$TOOLS_DIR/dirsearch" pull --quiet
pip3 install -r "$TOOLS_DIR/dirsearch/requirements.txt" --break-system-packages
ln -sf "$TOOLS_DIR/dirsearch/dirsearch.py" /usr/local/bin/dirsearch 2>/dev/null || true
chmod +x /usr/local/bin/dirsearch
success "dirsearch done"

# SQLmap (apt already installed, also grab latest from git)
info "Updating SQLmap from git..."
git -C "$TOOLS_DIR" clone --depth 1 https://github.com/sqlmapproject/sqlmap.git 2>/dev/null || \
  git -C "$TOOLS_DIR/sqlmap" pull --quiet
success "SQLmap updated"

# =============================================================================
# 6. PARAMETER DISCOVERY
# =============================================================================
section "6. Parameter & Input Discovery"

# Arjun
info "Installing Arjun..."
pip3 install arjun --break-system-packages
success "Arjun done"

# ParamSpider
info "Installing ParamSpider..."
git -C "$TOOLS_DIR" clone --depth 1 https://github.com/devanshbatham/paramspider.git 2>/dev/null || \
  git -C "$TOOLS_DIR/paramspider" pull --quiet
pip3 install -e "$TOOLS_DIR/paramspider" --break-system-packages
success "ParamSpider done"

# x8
install_go_tool "x8" "github.com/Sh1Yo/x8@latest"

# =============================================================================
# 7. XSS TESTING
# =============================================================================
section "7. XSS Testing"

# dalfox
install_go_tool "dalfox" "github.com/hahwul/dalfox/v2@latest"

# XSStrike
info "Installing XSStrike..."
git -C "$TOOLS_DIR" clone --depth 1 https://github.com/s0md3v/XSStrike.git 2>/dev/null || \
  git -C "$TOOLS_DIR/XSStrike" pull --quiet
pip3 install -r "$TOOLS_DIR/XSStrike/requirements.txt" --break-system-packages
success "XSStrike done"

# kxss
install_go_tool "kxss" "github.com/Emoe/kxss@latest"

# =============================================================================
# 8. SSRF & OUT-OF-BAND TESTING
# =============================================================================
section "8. SSRF & OOB Testing"

# interactsh (open-source Burp Collaborator alternative)
install_go_tool "interactsh-client" "github.com/projectdiscovery/interactsh/cmd/interactsh-client@latest"
install_go_tool "interactsh-server" "github.com/projectdiscovery/interactsh/cmd/interactsh-server@latest"

# SSRFmap
info "Installing SSRFmap..."
git -C "$TOOLS_DIR" clone --depth 1 https://github.com/swisskyrepo/SSRFmap.git 2>/dev/null || \
  git -C "$TOOLS_DIR/SSRFmap" pull --quiet
pip3 install -r "$TOOLS_DIR/SSRFmap/requirements.txt" --break-system-packages
success "SSRFmap done"

# =============================================================================
# 9. SECRETS & SENSITIVE DATA DISCOVERY
# =============================================================================
section "9. Secrets & Sensitive Data Discovery"

# truffleHog
info "Installing truffleHog..."
pip3 install trufflehog --break-system-packages 2>/dev/null || \
  curl -sSfL https://raw.githubusercontent.com/trufflesecurity/trufflehog/main/scripts/install.sh | sh -s -- -b /usr/local/bin
success "truffleHog done"

# gitleaks
info "Installing gitleaks..."
GITLEAKS_VER=$(curl -s https://api.github.com/repos/gitleaks/gitleaks/releases/latest | jq -r '.tag_name')
wget -q "https://github.com/gitleaks/gitleaks/releases/download/${GITLEAKS_VER}/gitleaks_${GITLEAKS_VER#v}_linux_x64.tar.gz" \
     -O /tmp/gitleaks.tar.gz
tar -xzf /tmp/gitleaks.tar.gz -C /usr/local/bin gitleaks
rm /tmp/gitleaks.tar.gz
success "gitleaks $GITLEAKS_VER installed"

# SecretFinder
info "Installing SecretFinder..."
git -C "$TOOLS_DIR" clone --depth 1 https://github.com/m4ll0k/SecretFinder.git 2>/dev/null || \
  git -C "$TOOLS_DIR/SecretFinder" pull --quiet
pip3 install -r "$TOOLS_DIR/SecretFinder/requirements.txt" --break-system-packages
success "SecretFinder done"

# LinkFinder
info "Installing LinkFinder..."
git -C "$TOOLS_DIR" clone --depth 1 https://github.com/GerbenJavado/LinkFinder.git 2>/dev/null || \
  git -C "$TOOLS_DIR/LinkFinder" pull --quiet
pip3 install -r "$TOOLS_DIR/LinkFinder/requirements.txt" --break-system-packages
success "LinkFinder done"

# =============================================================================
# 10. CLOUD SECURITY
# =============================================================================
section "10. Cloud Security Tools"

# CloudEnum
info "Installing CloudEnum..."
git -C "$TOOLS_DIR" clone --depth 1 https://github.com/initstring/cloud_enum.git 2>/dev/null || \
  git -C "$TOOLS_DIR/cloud_enum" pull --quiet
pip3 install -r "$TOOLS_DIR/cloud_enum/requirements.txt" --break-system-packages
success "CloudEnum done"

# S3Scanner
info "Installing S3Scanner..."
pip3 install s3scanner --break-system-packages
success "S3Scanner done"

# ScoutSuite
info "Installing ScoutSuite..."
pip3 install scoutsuite --break-system-packages
success "ScoutSuite done"

# Pacu
info "Installing Pacu..."
git -C "$TOOLS_DIR" clone --depth 1 https://github.com/RhinoSecurityLabs/pacu.git 2>/dev/null || \
  git -C "$TOOLS_DIR/pacu" pull --quiet
pip3 install -r "$TOOLS_DIR/pacu/requirements.txt" --break-system-packages
success "Pacu done"

# =============================================================================
# 11. MOBILE SECURITY
# =============================================================================
section "11. Mobile Security Tools"

# MobSF (Docker-based — lightweight approach)
info "Installing MobSF dependencies..."
apt-get install -y python3-dev libxmlsec1-dev libxmlsec1-openssl
git -C "$TOOLS_DIR" clone --depth 1 https://github.com/MobSF/Mobile-Security-Framework-MobSF.git 2>/dev/null || \
  git -C "$TOOLS_DIR/Mobile-Security-Framework-MobSF" pull --quiet
pip3 install -r "$TOOLS_DIR/Mobile-Security-Framework-MobSF/requirements.txt" --break-system-packages
success "MobSF done (run: cd ~/tools/Mobile-Security-Framework-MobSF && ./setup.sh)"

# apktool
info "Installing apktool..."
wget -q https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool -O /usr/local/bin/apktool
APKTOOL_JAR_URL=$(curl -s https://api.github.com/repos/iBotPeaches/Apktool/releases/latest \
  | jq -r '.assets[] | select(.name | endswith(".jar")) | .browser_download_url')
wget -q "$APKTOOL_JAR_URL" -O /usr/local/bin/apktool.jar
chmod +x /usr/local/bin/apktool /usr/local/bin/apktool.jar
success "apktool installed"

# Frida & Objection
info "Installing Frida & Objection..."
pip3 install frida frida-tools objection --break-system-packages
success "Frida & Objection done"

# =============================================================================
# 12. ADDITIONAL UTILITY TOOLS (tomnomnom suite & others)
# =============================================================================
section "12. Utility & Tomnomnom Suite"

install_go_tool "httprobe"    "github.com/tomnomnom/httprobe@latest"
install_go_tool "meg"         "github.com/tomnomnom/meg@latest"
install_go_tool "gf"          "github.com/tomnomnom/gf@latest"
install_go_tool "hakcrawler"  "github.com/hakluke/hakrawler@latest"
install_go_tool "notify"      "github.com/projectdiscovery/notify/cmd/notify@latest"
install_go_tool "naabu"       "github.com/projectdiscovery/naabu/v2/cmd/naabu@latest"
install_go_tool "cdncheck"    "github.com/projectdiscovery/cdncheck/cmd/cdncheck@latest"

# gf patterns
info "Setting up gf patterns..."
GF_PATTERNS="$REAL_HOME/.gf"
mkdir -p "$GF_PATTERNS"
git -C "$TOOLS_DIR" clone --depth 1 https://github.com/1ndianl33t/Gf-Patterns.git 2>/dev/null || true
cp "$TOOLS_DIR/Gf-Patterns/"*.json "$GF_PATTERNS/" 2>/dev/null || true
success "gf patterns installed"

# Eyewitness (web screenshots)
info "Installing EyeWitness..."
git -C "$TOOLS_DIR" clone --depth 1 https://github.com/RedSiege/EyeWitness.git 2>/dev/null || \
  git -C "$TOOLS_DIR/EyeWitness" pull --quiet
python3 "$TOOLS_DIR/EyeWitness/Python/setup/setup.py" 2>/dev/null || true
success "EyeWitness done"

# =============================================================================
# 13. WORDLISTS
# =============================================================================
section "13. Wordlists"

# SecLists
info "Cloning SecLists (this may take a few minutes)..."
if [[ ! -d "$WORDLIST_DIR/SecLists" ]]; then
  git clone --depth 1 https://github.com/danielmiessler/SecLists.git "$WORDLIST_DIR/SecLists"
  success "SecLists cloned"
else
  git -C "$WORDLIST_DIR/SecLists" pull --quiet
  success "SecLists already present, updated"
fi

# Assetnote wordlists (key files only to save bandwidth)
info "Downloading Assetnote wordlists..."
mkdir -p "$WORDLIST_DIR/assetnote"
for WL in "httparchive_apiroutes_2024.txt" "httparchive_parameters_top_1m_2024.txt" "httparchive_subdomains_2024.txt"; do
  if [[ ! -f "$WORDLIST_DIR/assetnote/$WL" ]]; then
    wget -q "https://wordlists-cdn.assetnote.io/data/$WL" \
         -O "$WORDLIST_DIR/assetnote/$WL" 2>/dev/null || warn "Could not fetch $WL (may need manual download)"
  fi
done
success "Wordlists ready at $WORDLIST_DIR"

# =============================================================================
# 14. FIREFOX EXTENSIONS (reference only — install manually in browser)
# =============================================================================
section "14. Firefox & Browser Setup"

info "Installing Firefox (if not present)..."
apt-get install -y firefox-esr 2>/dev/null || apt-get install -y firefox 2>/dev/null || true

cat <<'EOF'

  ┌─────────────────────────────────────────────────────────┐
  │  Install these Firefox extensions MANUALLY in browser:  │
  │                                                         │
  │  • FoxyProxy Standard                                   │
  │  • Wappalyzer                                           │
  │  • DotGit                                               │
  │  • Retire.js                                            │
  │  • EditThisCookie                                       │
  │  • HackTools                                            │
  └─────────────────────────────────────────────────────────┘

EOF

# =============================================================================
# 15. ZSH & TMUX CONFIGURATION
# =============================================================================
section "15. Shell & Terminal Setup"

# Oh My Zsh (non-interactive)
if [[ ! -d "$REAL_HOME/.oh-my-zsh" ]]; then
  info "Installing Oh My Zsh..."
  sudo -u "$REAL_USER" sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    "" --unattended 2>/dev/null || warn "Oh My Zsh install skipped (already present or error)"
fi

# Tmux config
cat > "$REAL_HOME/.tmux.conf" <<'TMUX'
# Bug Bounty tmux config
set -g mouse on
set -g history-limit 50000
set -g default-terminal "screen-256color"
bind | split-window -h
bind - split-window -v
set -g status-bg black
set -g status-fg green
set -g status-right '#[fg=yellow]%H:%M %d-%b-%y'
TMUX
chown "$REAL_USER:$REAL_USER" "$REAL_HOME/.tmux.conf"
success "tmux configured"

# =============================================================================
# 16. ALIASES & SHORTCUTS
# =============================================================================
section "16. Bug Bounty Aliases"

ALIAS_FILE="$REAL_HOME/.bugbounty_aliases"
cat > "$ALIAS_FILE" <<'ALIASES'
# ── Bug Bounty Aliases ──────────────────────────────────────────

# Quick recon pipeline
recon() {
  local domain="$1"
  mkdir -p ~/recon/$domain
  echo "[*] Running subfinder..."
  subfinder -d $domain -silent -o ~/recon/$domain/subs_subfinder.txt
  echo "[*] Running amass passive..."
  amass enum -passive -d $domain -o ~/recon/$domain/subs_amass.txt
  echo "[*] Merging & probing live hosts..."
  cat ~/recon/$domain/subs_*.txt | sort -u | httpx -silent -o ~/recon/$domain/live_hosts.txt
  echo "[*] Running nuclei..."
  nuclei -l ~/recon/$domain/live_hosts.txt -o ~/recon/$domain/nuclei_results.txt
  echo "[✔] Done! Results in ~/recon/$domain/"
}

# Directory fuzzing shortcut
fuzz() { ffuf -u "$1/FUZZ" -w /opt/wordlists/SecLists/Discovery/Web-Content/raft-large-words.txt -mc 200,301,302,403; }

# Subdomain enumeration only
subenum() { subfinder -d $1 -silent | anew; }

# Pull all URLs from wayback
wayback() { echo $1 | waybackurls | anew; }

# Quick nmap
quickmap() { nmap -sV -sC -T4 --open $1; }

# Nuclei against a single host
nuclei-scan() { nuclei -u $1 -severity low,medium,high,critical; }

# Get all JS files
getjs() { echo $1 | waybackurls | grep "\.js$" | anew; }

# Param mine
parammine() { gau $1 | grep "?" | qsreplace FUZZ | sort -u; }

alias burp='java -jar ~/tools/burpsuite_community.jar &'
alias dirsearch='python3 ~/tools/dirsearch/dirsearch.py'
alias xsstrike='python3 ~/tools/XSStrike/xsstrike.py'
alias ssmrf='python3 ~/tools/SSRFmap/ssrfmap.py'
alias harvester='python3 ~/tools/theHarvester/theHarvester.py'
alias sqlmap='python3 ~/tools/sqlmap/sqlmap.py'
alias linkfinder='python3 ~/tools/LinkFinder/linkfinder.py'
alias secretfinder='python3 ~/tools/SecretFinder/SecretFinder.py'
alias mobsf='cd ~/tools/Mobile-Security-Framework-MobSF && python3 manage.py runserver 127.0.0.1:8000'
ALIASES

chown "$REAL_USER:$REAL_USER" "$ALIAS_FILE"

# Source aliases from shell rc files
for RC in "$REAL_HOME/.bashrc" "$REAL_HOME/.zshrc"; do
  if [[ -f "$RC" ]]; then
    grep -q "bugbounty_aliases" "$RC" || echo "source ~/.bugbounty_aliases" >> "$RC"
  fi
done
success "Aliases written to $ALIAS_FILE"

# =============================================================================
# 17. BURP SUITE COMMUNITY (optional download)
# =============================================================================
section "17. Burp Suite Community"

info "Downloading Burp Suite Community installer..."
BURP_URL="https://portswigger.net/burp/releases/download?product=community&type=jar"
wget -q "$BURP_URL" -O "$TOOLS_DIR/burpsuite_community.jar" 2>/dev/null && \
  success "Burp Suite JAR downloaded to $TOOLS_DIR/burpsuite_community.jar" || \
  warn "Burp download failed — grab manually from https://portswigger.net/burp/communitydownload"

# =============================================================================
# 18. FIX PERMISSIONS
# =============================================================================
section "18. Fixing Permissions"

chown -R "$REAL_USER:$REAL_USER" "$TOOLS_DIR" "$REAL_HOME/go" 2>/dev/null || true
chown -R "$REAL_USER:$REAL_USER" "$REAL_HOME/recon" 2>/dev/null || true
cp -r "$REAL_HOME/go/bin/"* /usr/local/bin/ 2>/dev/null || true
success "Permissions fixed"

# =============================================================================
# DONE — SUMMARY
# =============================================================================
echo ""
echo -e "${GREEN}${BOLD}"
cat <<'BANNER'
  ██████╗ ██╗   ██╗ ██████╗     ██████╗  ██████╗ ██╗   ██╗███╗   ██╗████████╗██╗   ██╗
  ██╔══██╗██║   ██║██╔════╝     ██╔══██╗██╔═══██╗██║   ██║████╗  ██║╚══██╔══╝╚██╗ ██╔╝
  ██████╔╝██║   ██║██║  ███╗    ██████╔╝██║   ██║██║   ██║██╔██╗ ██║   ██║    ╚████╔╝
  ██╔══██╗██║   ██║██║   ██║    ██╔══██╗██║   ██║██║   ██║██║╚██╗██║   ██║     ╚██╔╝
  ██████╔╝╚██████╔╝╚██████╔╝    ██████╔╝╚██████╔╝╚██████╔╝██║ ╚████║   ██║      ██║
  ╚═════╝  ╚═════╝  ╚═════╝     ╚═════╝  ╚═════╝  ╚═════╝ ╚═╝  ╚═══╝   ╚═╝      ╚═╝
                         LAB SETUP COMPLETE
BANNER
echo -e "${NC}"

echo -e "${CYAN}${BOLD}  NEXT STEPS:${NC}"
echo -e "  1. Restart your terminal or run: ${YELLOW}source ~/.bashrc${NC}"
echo -e "  2. Update Nuclei templates:      ${YELLOW}nuclei -update-templates${NC}"
echo -e "  3. Launch Burp Suite:            ${YELLOW}java -jar ~/tools/burpsuite_community.jar${NC}"
echo -e "  4. Start a new tmux session:     ${YELLOW}tmux new -s bugbounty${NC}"
echo -e "  5. Try your first recon:         ${YELLOW}recon example.com${NC}"
echo ""
echo -e "  ${GREEN}Wordlists location:${NC}  $WORDLIST_DIR"
echo -e "  ${GREEN}Tools location:${NC}      $TOOLS_DIR"
echo -e "  ${GREEN}Full install log:${NC}    $LOG"
echo ""
echo -e "  ${YELLOW}Remember: Only test on systems you have written permission for.${NC}"
echo -e "  ${YELLOW}Happy hunting. Stay legal. Stay sharp.${NC}"
echo ""
