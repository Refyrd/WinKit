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
   > 1. [■] Google Chrome
     2. [ ] Mozilla Firefox
     3. [ ] Brave Browser
     4. [ ] Opera GX
     5. [ ] Vivaldi

   Selected: 4 of 30
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
| 🖥 **Interactive UI** | Navigate with arrow keys, select with spacebar |
| 📦 **Select all** | Press `A` to grab everything |
| 🔄 **Toggle** | Select multiple apps across different categories |
| 📊 **Progress** | Live counter `[2/5]` during installation |
| 📋 **Report** | Summary with ✓ success / ✗ failure for each app |
| 🎨 **Categories** | Apps organized into 5 categories |
| 🛡 **Auto-elevate** | Requests admin rights automatically |
| ⚡ **One-liner** | Install via `irm ... \| iex` — no git needed |

## 📦 Available Apps (30)

| Category | Apps |
|----------|------|
| 🌐 **Browsers** | Google Chrome, Mozilla Firefox, Brave, Opera GX, Vivaldi |
| 💻 **Development** | VS Code, Git, Python 3, Node.js LTS, Notepad++, Windows Terminal, Docker Desktop |
| 🎮 **Gaming / Social** | Steam, Discord, Telegram, Epic Games, GOG Galaxy |
| 🎬 **Media** | VLC, Spotify, OBS Studio, iTunes, K-Lite Codec Pack |
| 🛠 **Utilities** | 7-Zip, WinRAR, qBittorrent, MSI Afterburner, PowerToys, Everything, Rufus, ShareX |

> 💡 **Want to add your own apps?** Edit `setup.bat` — add `Name`, `Id`, and `Cat` into the `$apps` array.

## ⌨️ Controls

| Key | Action |
|-----|--------|
| `↑` / `↓` | Navigate apps |
| `←` / `→` | Switch categories |
| `Space` | Select / Deselect app |
| `A` / `C` | Select all / Clear selection |
| `Enter` | Start installation |
| `Esc` | Exit |

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
