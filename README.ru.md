<div align="center">

# ⚡ WinKit

### Быстрая установка приложений на Windows через WinGet

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Windows](https://img.shields.io/badge/Platform-Windows%2010%2F11-0078D6?logo=windows)](https://www.microsoft.com/windows)
[![WinGet](https://img.shields.io/badge/Powered%20by-WinGet-4B0082)](https://github.com/microsoft/winget-cli)

**[🇺🇸 English](README.md)** | **🇷🇺 Русский**

<br>

**Забудьте про рутину.** WinKit показывает все приложения на одном экране — выберите нужные и установите за один клик. Никаких мастеров установки, никаких поисков по сайтам.

<br>

```
 ╔════════════════════════════════════════════════════════╗
 ║             WinKit — App Installer                    ║
 ╚════════════════════════════════════════════════════════╝

   [Browsers]
   > 1. [■] Google Chrome
     2. [ ] Mozilla Firefox
     3. [ ] Brave Browser
     4. [ ] Vivaldi

   Selected: 4 of 25
   > _
```

</div>

---

## 🚀 Быстрый старт

### Одна команда (PowerShell)

```powershell
irm https://raw.githubusercontent.com/Refyrd/WinKit/main/install.ps1 | iex
```

### Или клонируй репозиторий

```bash
git clone https://github.com/Refyrd/WinKit.git
cd WinKit
winkit.bat
```

## 🎯 Возможности

| Функция | Описание |
|---------|----------|
| 🖥 **Интерактивный интерфейс** | Навигация стрелочками, выбор пробелом |
| 📦 **Выбрать все** | Нажмите `A` — и всё выбрано |
| 🔄 **Переключение** | Выбирайте разные приложения по разным категориям |
| 📊 **Прогресс** | Счётчик `[2/5]` во время установки |
| 📋 **Отчёт** | Итоговая таблица: ✓ успех / ✗ ошибка |
| 🎨 **Категории** | 7 категорий для удобной навигации |
| 🛡 **Авто-права** | Автоматический запрос прав администратора |
| ⚡ **Одна команда** | Установка через `irm ... \| iex` — без git |

## 📦 Доступные приложения (37)

| Категория | Приложения |
|-----------|-----------|
| 🌐 **Браузеры** | Google Chrome, Mozilla Firefox, Brave, Vivaldi |
| 💻 **Разработка** | VS Code, Git, Python 3, Node.js LTS, Notepad++, Docker Desktop |
| 🎮 **Игры и общение** | Steam, Discord, Telegram |
| 🎬 **Медиа** | VLC, Spotify, OBS Studio, K-Lite Codec Pack, Audacity, GIMP |
| 🛠 **Утилиты** | 7-Zip, WinRAR, qBittorrent, MSI Afterburner, PowerToys, Everything Search, Rufus, ShareX, Revo Uninstaller, WizTree |
| ⚙️ **Система** | DirectX Web Setup, Visual C++ Redist, CPU-Z, GPU-Z, HWMonitor, CrystalDiskInfo |
| 📝 **Продуктивность**| Obsidian, Notion |

> 💡 **Хотите добавить свои приложения?** Отредактируйте `winkit.bat` — добавьте `Name`, `Id`, `Cat` в массив `$apps`.

## ⌨️ Управление

| Клавиша | Действие |
|---------|----------|
| `↑` / `↓` | Перемещение по списку |
| `←` / `→` | Переключение между категориями |
| `1`-`9` | Выбор конкретного приложения на странице |
| `Пробел` | Выбрать / Отменить выбор |
| `A` / `C` | Выбрать всё (на текущей странице) / Очистить весь выбор |
| `Enter` | Начать установку |
| `Esc` | Выход |

## 📋 Требования

- **Windows 10** (версия 1709+) или **Windows 11**
- **WinGet** — предустановлен в Windows 11; для Windows 10 скачайте из [Microsoft Store](https://aka.ms/getwinget)

## 🤝 Вклад в проект

1. Сделайте форк репозитория
2. Добавьте новые приложения в `winkit.bat`
3. Отправьте pull request

## 📄 Лицензия

[MIT](LICENSE) — делайте что хотите.

---

<div align="center">

**Сделано с ❤️ автором [Refyrd](https://github.com/Refyrd)**

</div>
