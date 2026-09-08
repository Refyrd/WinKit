<div align="center">

# ⚡ WinKit

### Быстрая установка приложений на Windows через WinGet

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Windows](https://img.shields.io/badge/Platform-Windows%2010%2F11-0078D6?logo=windows)](https://www.microsoft.com/windows)
[![WinGet](https://img.shields.io/badge/Powered%20by-WinGet-4B0082)](https://github.com/microsoft/winget-cli)

**🇬🇧 [Read in English](README.md)**

<br>

**Забудьте про рутину.** WinKit показывает все приложения на одном экране — выберите нужные и установите за один клик. Никаких мастеров установки, никаких поисков по сайтам.

<br>

```
 ╔════════════════════════════════════════════════════════╗
 ║             WinKit — App Installer                    ║
 ╚════════════════════════════════════════════════════════╝

   [Browsers]
     1. [■] Google Chrome
     2. [ ] Mozilla Firefox

   [Development]
     3. [■] Visual Studio Code

   [Gaming & Social]
     4. [■] Steam
     5. [ ] Discord

   [Media & Utilities]
     6. [ ] VLC Media Player
     7. [■] 7-Zip
     8. [ ] Happ
     9. [ ] MSI Afterburner

   Selected: 4 of 9
   > _
```

</div>

---

## 🚀 Быстрый старт

```bash
git clone https://github.com/Refyrd/WinKit.git
cd WinKit
setup.bat
```

Скрипт автоматически запросит права администратора, покажет список приложений и установит всё, что вы выберете.

## 🎯 Возможности

| Функция | Описание |
|---------|----------|
| 🖥 **Единый экран** | Все приложения на одном экране — без пошаговых вопросов |
| ✅ **Мульти-выбор** | Введите `1 3 5 7` чтобы выбрать несколько приложений сразу |
| 📦 **Выбрать все** | Нажмите `A` — и все приложения выбраны |
| 🔄 **Переключение** | Повторный ввод номера снимает выбор |
| 📊 **Прогресс** | Счётчик `[2/5]` во время установки |
| 📋 **Отчёт** | Итоговая таблица: ✓ успех / ✗ ошибка |
| 🎨 **Категории** | Приложения сгруппированы по типу |
| 🛡 **Авто-права** | Автоматический запрос прав администратора |

## 📦 Доступные приложения

| Категория | Приложение | WinGet ID |
|-----------|-----------|-----------|
| 🌐 Браузеры | Google Chrome | `Google.Chrome` |
| 🌐 Браузеры | Mozilla Firefox | `Mozilla.Firefox` |
| 💻 Разработка | Visual Studio Code | `Microsoft.VisualStudioCode` |
| 🎮 Игры и общение | Steam | `Valve.Steam` |
| 🎮 Игры и общение | Discord | `Discord.Discord` |
| 🛠 Медиа и утилиты | VLC Media Player | `VideoLAN.VLC` |
| 🛠 Медиа и утилиты | 7-Zip | `7zip.7zip` |
| 🛠 Медиа и утилиты | Happ | `Happ.Happ` |
| 🛠 Медиа и утилиты | MSI Afterburner | `Guru3D.Afterburner` |

> 💡 **Хотите добавить свои приложения?** Просто отредактируйте список в `setup.bat` — добавьте строки `NAME_`, `ID_`, `CAT_` и увеличьте счётчик `TOTAL`.

## ⌨️ Управление

| Клавиша | Действие |
|---------|----------|
| `1`-`9` | Выбрать/снять приложение |
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
