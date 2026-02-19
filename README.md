<div align="center">

<img src="https://readme-typing-svg.demolab.com?font=Fira+Code&size=28&duration=3000&pause=1000&color=00FF41&center=true&vCenter=true&width=600&lines=Bug+Bounty+Lab+Setup;Automated+Tool+Installer;Professional+Pentesting+Environment" alt="Typing SVG" />

<br/>

![Shell Script](https://img.shields.io/badge/Shell_Script-121011?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Kali Linux](https://img.shields.io/badge/Kali_Linux-557C94?style=for-the-badge&logo=kali-linux&logoColor=white)
![Python](https://img.shields.io/badge/Python-FFD43B?style=for-the-badge&logo=python&logoColor=blue)
![Go](https://img.shields.io/badge/Go-00ADD8?style=for-the-badge&logo=go&logoColor=white)

![License](https://img.shields.io/badge/License-MIT-green?style=flat-square)
![Tools](https://img.shields.io/badge/Tools-60%2B-red?style=flat-square)
![Platform](https://img.shields.io/badge/Platform-Kali%20%7C%20Parrot%20%7C%20Ubuntu-blue?style=flat-square)
![Maintained](https://img.shields.io/badge/Maintained-Yes-brightgreen?style=flat-square)

<br/>

> **One script to rule them all.** A fully automated bug bounty lab installer that sets up 60+ professional pentesting tools, wordlists, shell aliases, and a complete recon pipeline — in a single command.

<br/>

```bash
sudo bash bugbounty_setup.sh
```

</div>

---

## 📖 Table of Contents

- [Overview](#-overview)
- [Compatibility](#-compatibility)
- [Prerequisites](#-prerequisites)
- [Quick Start](#-quick-start)
- [What Gets Installed](#-what-gets-installed)
  - [Reconnaissance & OSINT](#1-reconnaissance--osint)
  - [HTTP Probing & Crawling](#2-http-probing--crawling)
  - [Vulnerability Scanning](#3-vulnerability-scanning)
  - [Web Application Testing](#4-web-application-testing)
  - [Parameter Discovery](#5-parameter-discovery)
  - [XSS Testing](#6-xss-testing)
  - [SSRF & OOB Testing](#7-ssrf--out-of-band-testing)
  - [Secrets Discovery](#8-secrets--sensitive-data-discovery)
  - [Cloud Security](#9-cloud-security)
  - [Mobile Security](#10-mobile-security)
  - [Utility & Shell Tools](#11-utility--shell-tools)
  - [Wordlists](#12-wordlists)
- [Built-in Recon Pipelines](#-built-in-recon-pipelines)
- [Directory Structure](#-directory-structure)
- [Post-Installation](#-post-installation)
- [Legal Disclaimer](#-legal-disclaimer)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🔍 Overview

This project automates the complete setup of a professional bug bounty hunting environment. Whether you're a beginner setting up your first lab or an experienced researcher spinning up a fresh machine, this script handles everything — language runtimes, tools, wordlists, shell configuration, and workflow aliases.

Built from real-world experience working with government and private sector engagements. Every tool included earns its place.

```
Recon → Probe → Fuzz → Exploit → Document → Report
  ↑         ↑        ↑       ↑           ↑          ↑
 Amass    httpx    ffuf   SQLmap    Obsidian    Nuclei
Subfinder Katana  ffuf  dalfox    Flameshot   truffleHog
```

---

## 💻 Compatibility

| OS | Status |
|---|---|
| **Kali Linux** (2023.x+) | ✅ Fully Supported |
| **Parrot OS Security** (5.x+) | ✅ Fully Supported |
| **Ubuntu** (22.04 / 24.04 LTS) | ✅ Supported |
| **Debian** (12+) | ⚠️ Mostly Supported |
| **WSL2** (Kali / Ubuntu) | ⚠️ Partial (GUI tools limited) |
| **macOS** | ❌ Not Supported |
| **Windows Native** | ❌ Not Supported |

> **Recommended:** Run on a dedicated Kali Linux VM with at least 8GB RAM and 60GB disk space.

---

## ✅ Prerequisites

Before running the script, ensure the following:

```bash
# Minimum requirements
RAM:     8GB  (16GB recommended)
Disk:    60GB free space (wordlists are large)
Network: Stable internet connection
User:    sudo / root access
```

No other pre-installation is required. The script installs everything including Go, Python dependencies, and all language runtimes.

---

## 🚀 Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/yourusername/bugbounty-setup.git
cd bugbounty-setup

# 2. Make executable
chmod +x bugbounty_setup.sh

# 3. Run as root
sudo bash bugbounty_setup.sh

# 4. After install — reload your shell
source ~/.bashrc   # or source ~/.zshrc
```

> ⏱️ **Estimated time:** 20–45 minutes depending on internet speed and hardware. SecLists alone is ~1.7GB.

---

## 📦 What Gets Installed

### 1. Reconnaissance & OSINT

| Tool | Purpose |
|------|---------|
| [Amass](https://github.com/owasp-amass/amass) | Deep subdomain enumeration, ASN & DNS mapping |
| [Subfinder](https://github.com/projectdiscovery/subfinder) | Passive subdomain discovery using 40+ sources |
| [Assetfinder](https://github.com/tomnomnom/assetfinder) | Fast lightweight subdomain finder |
| [dnsx](https://github.com/projectdiscovery/dnsx) | DNS toolkit for bulk resolution and probing |
| [shuffledns](https://github.com/projectdiscovery/shuffledns) | DNS brute-force with wildcard filtering |
| [theHarvester](https://github.com/laramies/theHarvester) | OSINT: emails, names, subdomains from public sources |

---

### 2. HTTP Probing & Crawling

| Tool | Purpose |
|------|---------|
| [httpx](https://github.com/projectdiscovery/httpx) | Fast multi-purpose HTTP probing toolkit |
| [Katana](https://github.com/projectdiscovery/katana) | Next-gen web crawler — handles JS SPAs |
| [GoSpider](https://github.com/jaeles-project/gospider) | Fast web spider with link extraction |
| [Hakrawler](https://github.com/hakluke/hakrawler) | Simple, fast web crawler for endpoints |
| [Waybackurls](https://github.com/tomnomnom/waybackurls) | Pull historical URLs from Wayback Machine |
| [gau](https://github.com/lc/gau) | Fetch URLs from Wayback, OTX, and Common Crawl |
| [unfurl](https://github.com/tomnomnom/unfurl) | Extract components from URLs at scale |
| [anew](https://github.com/tomnomnom/anew) | Append lines to file if not already present |

---

### 3. Vulnerability Scanning

| Tool | Purpose |
|------|---------|
| [Nuclei](https://github.com/projectdiscovery/nuclei) | Template-based vulnerability scanner (community + custom templates) |
| [Nuclei Templates](https://github.com/projectdiscovery/nuclei-templates) | 8,000+ community-maintained detection templates |
| [Nmap](https://nmap.org/) | Port scanning, service fingerprinting, NSE scripts |
| [Masscan](https://github.com/robertdavidgraham/masscan) | Internet-scale port scanner |
| [Nikto](https://github.com/sullo/nikto) | Web server misconfiguration scanner |
| [naabu](https://github.com/projectdiscovery/naabu) | Fast port scanner with host discovery |

---

### 4. Web Application Testing

| Tool | Purpose |
|------|---------|
| [Burp Suite Community](https://portswigger.net/burp/communitydownload) | Intercept proxy — the core of web app testing |
| [ffuf](https://github.com/ffuf/ffuf) | Fast web fuzzer for dirs, params, vhosts, headers |
| [feroxbuster](https://github.com/epi052/feroxbuster) | Recursive content discovery written in Rust |
| [dirsearch](https://github.com/maurosoria/dirsearch) | Web path scanning with rich output options |
| [SQLmap](https://github.com/sqlmapproject/sqlmap) | Automated SQL injection detection and exploitation |

---

### 5. Parameter Discovery

| Tool | Purpose |
|------|---------|
| [Arjun](https://github.com/s0md3v/Arjun) | HTTP parameter discovery — GET, POST, JSON, XML |
| [ParamSpider](https://github.com/devanshbatham/paramspider) | Mine parameters from web archives |
| [x8](https://github.com/Sh1Yo/x8) | Hidden parameter discovery with change detection |
| [qsreplace](https://github.com/tomnomnom/qsreplace) | Replace query string values in URLs |

---

### 6. XSS Testing

| Tool | Purpose |
|------|---------|
| [dalfox](https://github.com/hahwul/dalfox) | Parameter analysis-based XSS scanner |
| [XSStrike](https://github.com/s0md3v/XSStrike) | Context-aware XSS fuzzer |
| [kxss](https://github.com/Emoe/kxss) | Passive XSS parameter filter from URL streams |

---

### 7. SSRF & Out-of-Band Testing

| Tool | Purpose |
|------|---------|
| [interactsh](https://github.com/projectdiscovery/interactsh) | OOB interaction server (open-source Burp Collaborator) |
| [SSRFmap](https://github.com/swisskyrepo/SSRFmap) | SSRF detection and exploitation framework |

---

### 8. Secrets & Sensitive Data Discovery

| Tool | Purpose |
|------|---------|
| [truffleHog](https://github.com/trufflesecurity/trufflehog) | Scans git history for secrets, tokens, credentials |
| [gitleaks](https://github.com/gitleaks/gitleaks) | Fast secrets scanner with CI/CD integration |
| [SecretFinder](https://github.com/m4ll0k/SecretFinder) | Extracts API keys from JavaScript files |
| [LinkFinder](https://github.com/GerbenJavado/LinkFinder) | Discovers hidden endpoints in JS files |

---

### 9. Cloud Security

| Tool | Purpose |
|------|---------|
| [CloudEnum](https://github.com/initstring/cloud_enum) | Multi-cloud resource enumeration (AWS, Azure, GCP) |
| [S3Scanner](https://github.com/sa7mon/S3Scanner) | Finds and audits exposed S3 buckets |
| [ScoutSuite](https://github.com/nccgroup/ScoutSuite) | Multi-cloud security auditing framework |
| [Pacu](https://github.com/RhinoSecurityLabs/pacu) | AWS exploitation framework |

---

### 10. Mobile Security

| Tool | Purpose |
|------|---------|
| [MobSF](https://github.com/MobSF/Mobile-Security-Framework-MobSF) | Automated mobile app security analysis (Android/iOS) |
| [apktool](https://github.com/iBotPeaches/Apktool) | APK decompilation for static analysis |
| [Frida](https://frida.re/) | Dynamic instrumentation for runtime analysis |
| [Objection](https://github.com/sensepost/objection) | Frida-based mobile exploration without jailbreak |

---

### 11. Utility & Shell Tools

| Tool | Purpose |
|------|---------|
| [gf](https://github.com/tomnomnom/gf) | grep wrapper with pre-built patterns for bug bounty |
| [gf-patterns](https://github.com/1ndianl33t/Gf-Patterns) | Community patterns: XSS, SQLi, SSRF, RCE, LFI, IDOR |
| [httprobe](https://github.com/tomnomnom/httprobe) | Probe list of hosts for working HTTP/HTTPS |
| [meg](https://github.com/tomnomnom/meg) | Fetch many paths for many hosts efficiently |
| [notify](https://github.com/projectdiscovery/notify) | Send tool output to Slack/Discord/Telegram |
| [cdncheck](https://github.com/projectdiscovery/cdncheck) | Identify CDN-hosted IPs to avoid wasted testing |
| [EyeWitness](https://github.com/RedSiege/EyeWitness) | Screenshot websites, RDP, VNC services at scale |
| tmux | Terminal multiplexer for persistent sessions |
| Oh My Zsh | Enhanced shell with plugins and themes |

---

### 12. Wordlists

| Wordlist | Location | Size |
|----------|----------|------|
| [SecLists](https://github.com/danielmiessler/SecLists) | `/opt/wordlists/SecLists/` | ~1.7GB |
| [Assetnote](https://wordlists.assetnote.io/) | `/opt/wordlists/assetnote/` | ~500MB |

**Key files you'll use constantly:**

```
/opt/wordlists/SecLists/Discovery/Web-Content/raft-large-words.txt
/opt/wordlists/SecLists/Discovery/DNS/subdomains-top1million-5000.txt
/opt/wordlists/SecLists/Fuzzing/LFI/LFI-Jhaddix.txt
/opt/wordlists/assetnote/httparchive_apiroutes_2024.txt
/opt/wordlists/assetnote/httparchive_parameters_top_1m_2024.txt
```

---

## ⚡ Built-in Recon Pipelines

The script installs ready-to-use shell functions for common workflows:

### Full Automated Recon
```bash
recon target.com
```
Runs: `subfinder → amass → httpx → nuclei` and saves all output to `~/recon/target.com/`

### Directory Fuzzing
```bash
fuzz https://target.com
```
Runs ffuf with the raft-large wordlist automatically.

### Parameter Mining
```bash
parammine target.com
```
Pulls all URLs with parameters from web archives, ready to pipe into fuzzing tools.

### Subdomain Enumeration Only
```bash
subenum target.com
```

### Wayback URL Pulling
```bash
wayback target.com
```

### Quick Nmap Scan
```bash
quickmap 10.0.0.1
```

### XSS Parameter Finding
```bash
echo "https://target.com" | waybackurls | kxss
```

### Nuclei Targeted Scan
```bash
nuclei-scan https://target.com
```

### JavaScript Secret Mining
```bash
getjs target.com | xargs -I{} python3 ~/tools/SecretFinder/SecretFinder.py -i {} -o cli
```

---

## 📁 Directory Structure

After installation, your environment will look like this:

```
$HOME/
├── tools/                          # All cloned/installed tools
│   ├── dirsearch/
│   ├── XSStrike/
│   ├── SSRFmap/
│   ├── theHarvester/
│   ├── sqlmap/
│   ├── SecretFinder/
│   ├── LinkFinder/
│   ├── cloud_enum/
│   ├── pacu/
│   ├── Mobile-Security-Framework-MobSF/
│   ├── EyeWitness/
│   └── burpsuite_community.jar
├── go/
│   └── bin/                        # All Go-compiled tools
│       ├── subfinder
│       ├── httpx
│       ├── nuclei
│       ├── ffuf
│       ├── dalfox
│       └── ... (30+ binaries)
├── nuclei-templates/               # Nuclei community templates
├── recon/                          # Your target recon output
│   └── target.com/
│       ├── subs_subfinder.txt
│       ├── subs_amass.txt
│       ├── live_hosts.txt
│       └── nuclei_results.txt
└── .gf/                            # gf patterns (XSS, SQLi, SSRF...)

/opt/wordlists/
├── SecLists/
└── assetnote/

/usr/local/bin/                     # Symlinked tools (system-wide access)
```

---

## 🔧 Post-Installation

### 1. Reload Shell
```bash
source ~/.bashrc    # bash users
source ~/.zshrc     # zsh users
```

### 2. Update Nuclei Templates
```bash
nuclei -update-templates
```

### 3. Configure Burp Suite Proxy
- Launch: `java -jar ~/tools/burpsuite_community.jar`
- Set proxy: `127.0.0.1:8080`
- Install FoxyProxy in Firefox and point to same address

### 4. Set Up tmux Session
```bash
tmux new -s bugbounty
# Split panes: Ctrl+b then |
# Switch panes: Ctrl+b then arrow keys
```

### 5. Verify Key Tools
```bash
subfinder -version
nuclei -version
httpx -version
ffuf -V
dalfox version
```

### 6. Firefox Extensions to Install Manually
- [FoxyProxy Standard](https://addons.mozilla.org/en-US/firefox/addon/foxyproxy-standard/)
- [Wappalyzer](https://addons.mozilla.org/en-US/firefox/addon/wappalyzer/)
- [DotGit](https://addons.mozilla.org/en-US/firefox/addon/dotgit/)
- [Retire.js](https://addons.mozilla.org/en-US/firefox/addon/retire-js/)
- [EditThisCookie](https://addons.mozilla.org/en-US/firefox/addon/edit-this-cookie2/)
- [HackTools](https://addons.mozilla.org/en-US/firefox/addon/hacktools/)

---

## 📚 Learning Resources

| Platform | Link | Best For |
|----------|------|---------|
| PortSwigger Web Academy | [academy.portswigger.net](https://portswigger.net/web-security) | Web vulns — start here |
| HackTheBox | [hackthebox.com](https://www.hackthebox.com) | Realistic machines |
| TryHackMe | [tryhackme.com](https://tryhackme.com) | Guided learning paths |
| PentesterLab | [pentesterlab.com](https://pentesterlab.com) | Web-focused exercises |
| OWASP Testing Guide | [owasp.org](https://owasp.org/www-project-web-security-testing-guide/) | Methodology reference |

---

## 🐛 Troubleshooting

**Go tools not found after install:**
```bash
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
source ~/.bashrc
```

**Permission denied errors:**
```bash
sudo chown -R $USER:$USER ~/tools ~/go
```

**Nuclei templates not found:**
```bash
nuclei -update-templates
```

**pip install fails:**
```bash
pip3 install <tool> --break-system-packages
```

**Amass takes too long:**
Amass passive mode is fast; active/brute modes are slow by design. Use `-passive` flag for quick recon.

---

## ⚠️ Legal Disclaimer

> **This tool is provided for educational and authorized security testing purposes only.**

Using these tools against systems you do not own or have **explicit written permission** to test is illegal and unethical. The author assumes no liability for misuse.

Always:
- Read and follow the bug bounty program's scope and rules
- Never test out-of-scope targets
- Avoid destructive testing (no DoS, no data deletion)
- Responsibly disclose all findings
- Keep your VPN active while hunting

**The best hunters operate with integrity. Your reputation is your career.**

---

## 🤝 Contributing

Contributions are welcome! If you know a tool that belongs here, or find a bug in the installer:

1. Fork the repository
2. Create a feature branch: `git checkout -b add-new-tool`
3. Make your changes and test on a clean VM
4. Submit a pull request with a clear description

Please ensure any added tools are:
- Open source or freely available
- Actively maintained
- Genuinely useful for bug bounty hunting

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

**Built with ❤️ for the bug bounty community**

*Stay legal. Stay ethical. Happy hunting.*

[![GitHub stars](https://img.shields.io/github/stars/yourusername/bugbounty-setup?style=social)](https://github.com/yourusername/bugbounty-setup)
[![GitHub forks](https://img.shields.io/github/forks/yourusername/bugbounty-setup?style=social)](https://github.com/yourusername/bugbounty-setup)

</div>
