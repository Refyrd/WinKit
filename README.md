<div align="center">

# ⚡ WinKit

### One-click Windows app installer powered by WinGet

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Windows](https://img.shields.io/badge/Platform-Windows%2010%2F11-0078D6?logo=windows)](https://www.microsoft.com/windows)
[![WinGet](https://img.shields.io/badge/Powered%20by-WinGet-4B0082)](https://github.com/microsoft/winget-cli)

<br>

**Skip the boring setup.** WinKit lets you pick all the apps you need from a single screen and installs them in one go — no clicking through wizards, no hunting for downloads.

<br>

```
 ╔════════════════════════════════════════════════════════╗
 ║          AutoInstall — Мастер установки ПО            ║
 ╚════════════════════════════════════════════════════════╝

   [Браузеры]
     1. [■] Google Chrome
     2. [ ] Mozilla Firefox

   [Разработка]
     3. [■] Visual Studio Code

   [Игры и общение]
     4. [■] Steam
     5. [ ] Discord

   [Медиа и утилиты]
     6. [ ] VLC Media Player
     7. [■] 7-Zip
     8. [ ] Happ
     9. [ ] MSI Afterburner

   Выбрано: 4 из 9
   > _
```

</div>

---

## 🚀 Quick Start

```bash
git clone https://github.com/Refyrd/WinKit.git
cd WinKit
setup.bat
```

That's it. The script auto-elevates to admin, shows you the app list, and installs everything you pick.

## 🎯 Features

| Feature | Description |
|---------|-------------|
| 🖥 **Single screen** | All apps displayed at once — no stepping through prompts |
| ✅ **Multi-select** | Type `1 3 5 7` to pick multiple apps in one line |
| 📦 **Select all** | Press `A` to grab everything |
| 🔄 **Toggle** | Enter a number again to deselect it |
| 📊 **Progress** | Live counter `[2/5]` during installation |
| 📋 **Report** | Summary with ✓ success / ✗ failure for each app |
| 🎨 **Categories** | Apps organized by type for easy navigation |
| 🛡 **Auto-elevate** | Requests admin rights automatically |

## 📦 Available Apps

| Category | App | WinGet ID |
|----------|-----|-----------|
| 🌐 Browsers | Google Chrome | `Google.Chrome` |
| 🌐 Browsers | Mozilla Firefox | `Mozilla.Firefox` |
| 💻 Development | Visual Studio Code | `Microsoft.VisualStudioCode` |
| 🎮 Gaming & Social | Steam | `Valve.Steam` |
| 🎮 Gaming & Social | Discord | `Discord.Discord` |
| 🛠 Media & Utilities | VLC Media Player | `VideoLAN.VLC` |
| 🛠 Media & Utilities | 7-Zip | `7zip.7zip` |
| 🛠 Media & Utilities | Happ | `Happ.Happ` |
| 🛠 Media & Utilities | MSI Afterburner | `Guru3D.Afterburner` |

> 💡 Want to add your own apps? Just edit the app list in `setup.bat` — it's dead simple. Add a `NAME_`, `ID_`, and `CAT_` line and bump the `TOTAL` counter.

## ⌨️ Controls

| Key | Action |
|-----|--------|
| `1`-`9` | Toggle an app on/off |
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
