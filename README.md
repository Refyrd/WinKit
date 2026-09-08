<div align="center">

# ⚡ WinKit

### One-click Windows app installer powered by WinGet

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Windows](https://img.shields.io/badge/Platform-Windows%2010%2F11-0078D6?logo=windows)](https://www.microsoft.com/windows)
[![WinGet](https://img.shields.io/badge/Powered%20by-WinGet-4B0082)](https://github.com/microsoft/winget-cli)

**🇺🇸 English** | **[🇷🇺 Русский](README.ru.md)**

<br>

**Skip the boring setup.** WinKit lets you pick all the apps you need from a single screen and installs them in one go — no clicking through wizards, no hunting for downloads.

<br>

```
 ╔════════════════════════════════════════════════════════╗
 ║             WinKit — App Installer                    ║
 ╚════════════════════════════════════════════════════════╝

   [Browsers]
     1. [■] Google Chrome        3. [ ] Brave Browser
     2. [ ] Mozilla Firefox

   [Development]
     4. [■] Visual Studio Code   7. [ ] Node.js LTS
     5. [ ] Git                  8. [ ] Notepad++
     6. [ ] Python 3

   [Gaming & Social]
     9. [■] Steam               11. [ ] Telegram
    10. [ ] Discord

   [Media]
    12. [ ] VLC Media Player    14. [ ] OBS Studio
    13. [ ] Spotify

   [Utilities]
    15. [■] 7-Zip               18. [ ] MSI Afterburner
    16. [ ] WinRAR              19. [ ] PowerToys
    17. [ ] qBittorrent         20. [ ] Everything Search

   Selected: 4 of 20
   > _
```

</div>

---

## 🚀 Quick Start

### One-liner (PowerShell)

```powershell
irm https://raw.githubusercontent.com/Refyrd/WinKit/main/install.ps1 | iex
```

### Or clone the repo

```bash
git clone https://github.com/Refyrd/WinKit.git
cd WinKit
setup.bat
```

## 🎯 Features

| Feature | Description |
|---------|-------------|
| 🖥 **Single screen** | All 20 apps displayed at once — no stepping through prompts |
| ✅ **Multi-select** | Type `1 3 5 7` to pick multiple apps in one line |
| 📦 **Select all** | Press `A` to grab everything |
| 🔄 **Toggle** | Enter a number again to deselect it |
| 📊 **Progress** | Live counter `[2/5]` during installation |
| 📋 **Report** | Summary with ✓ success / ✗ failure for each app |
| 🎨 **Categories** | Apps organized into 5 categories |
| 🛡 **Auto-elevate** | Requests admin rights automatically |
| ⚡ **One-liner** | Install via `irm ... \| iex` — no git needed |

## 📦 Available Apps (20)

| Category | Apps |
|----------|------|
| 🌐 **Browsers** | Google Chrome, Mozilla Firefox, Brave |
| 💻 **Development** | VS Code, Git, Python 3, Node.js LTS, Notepad++ |
| 🎮 **Gaming & Social** | Steam, Discord, Telegram |
| 🎬 **Media** | VLC, Spotify, OBS Studio |
| 🛠 **Utilities** | 7-Zip, WinRAR, qBittorrent, MSI Afterburner, PowerToys, Everything Search |

> 💡 **Want to add your own apps?** Edit `setup.bat` — add `NAME_`, `ID_`, `CAT_` lines and bump `TOTAL`.

## ⌨️ Controls

| Key | Action |
|-----|--------|
| `1`-`20` | Toggle an app on/off |
| `1 3 5` | Select multiple at once |
| `A` | Select all |
| `C` | Clear selection |
| `D` | Start installation |
| `0` | Exit |

## 📋 Requirements

- **Windows 10** (version 1709+) or **Windows 11**
- **WinGet** — pre-installed on Windows 11; for Windows 10, get it from the [Microsoft Store](https://aka.ms/getwinget)

## 🤝 Contributing

1. Fork this repo
2. Add new apps to `setup.bat`
3. Submit a pull request

## 📄 License

[MIT](LICENSE) — do whatever you want with it.

---

<div align="center">

**Made with ❤️ by [Refyrd](https://github.com/Refyrd)**

</div>
