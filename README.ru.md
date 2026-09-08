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

## 🚀 Быстрый старт

### Одна команда (PowerShell)

```powershell
irm https://raw.githubusercontent.com/Refyrd/WinKit/main/install.ps1 | iex
```

### Или клонируй репозиторий

```bash
git clone https://github.com/Refyrd/WinKit.git
cd WinKit
setup.bat
```

## 🎯 Возможности

| Функция | Описание |
|---------|----------|
| 🖥 **Единый экран** | Все 20 приложений на одном экране |
| ✅ **Мульти-выбор** | Введите `1 3 5 7` чтобы выбрать несколько сразу |
| 📦 **Выбрать все** | Нажмите `A` — и всё выбрано |
| 🔄 **Переключение** | Повторный ввод номера снимает выбор |
| 📊 **Прогресс** | Счётчик `[2/5]` во время установки |
| 📋 **Отчёт** | Итоговая таблица: ✓ успех / ✗ ошибка |
| 🎨 **Категории** | 5 категорий для удобной навигации |
| 🛡 **Авто-права** | Автоматический запрос прав администратора |
| ⚡ **Одна команда** | Установка через `irm ... \| iex` — без git |

## 📦 Доступные приложения (20)

| Категория | Приложения |
|-----------|-----------|
| 🌐 **Браузеры** | Google Chrome, Mozilla Firefox, Brave |
| 💻 **Разработка** | VS Code, Git, Python 3, Node.js LTS, Notepad++ |
| 🎮 **Игры и общение** | Steam, Discord, Telegram |
| 🎬 **Медиа** | VLC, Spotify, OBS Studio |
| 🛠 **Утилиты** | 7-Zip, WinRAR, qBittorrent, MSI Afterburner, PowerToys, Everything Search |

> 💡 **Хотите добавить свои приложения?** Отредактируйте `setup.bat` — добавьте `NAME_`, `ID_`, `CAT_` и увеличьте `TOTAL`.

## ⌨️ Управление

| Клавиша | Действие |
|---------|----------|
| `1`-`20` | Выбрать/снять приложение |
| `1 3 5` | Выбрать несколько сразу |
| `A` | Выбрать все |
| `C` | Сбросить выбор |
| `D` | Начать установку |
| `0` | Выход |

## 📋 Требования

- **Windows 10** (версия 1709+) или **Windows 11**
- **WinGet** — предустановлен в Windows 11; для Windows 10 скачайте из [Microsoft Store](https://aka.ms/getwinget)

## 🤝 Вклад в проект

1. Сделайте форк репозитория
2. Добавьте новые приложения в `setup.bat`
3. Отправьте pull request

## 📄 Лицензия

[MIT](LICENSE) — делайте что хотите.

---

<div align="center">

**Сделано с ❤️ автором [Refyrd](https://github.com/Refyrd)**

</div>
