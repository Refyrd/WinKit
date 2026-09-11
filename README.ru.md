<div align="center">

# ⚡ WinKit

### Современный инсталлятор приложений для Windows 11 на базе WinGet

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Windows](https://img.shields.io/badge/Platform-Windows%2010%2F11-0078D6?logo=windows)](https://www.microsoft.com/windows)
[![WinGet](https://img.shields.io/badge/Powered%20by-WinGet-4B0082)](https://github.com/microsoft/winget-cli)

**[🇺🇸 English](README.md)** | **🇷🇺 Русский**

<br>

![WinKit Demo](winkit-preview.gif)

<br>

**Забудьте про рутину.** WinKit 2.0 — это стильный GUI-инсталлятор приложений в дизайне Windows 11 Fluent UI. Выберите все необходимые программы по категориям и установите их в один клик — никаких мастеров установки и поисков по сайтам.

</div>

---

## 🚀 Быстрый старт

**Одна команда (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/Refyrd/WinKit/main/install.ps1 | iex
```

*Скрипт скачает и сразу откроет графическое окно WinKit.*

### Или клонируй репозиторий

```bash
git clone https://github.com/Refyrd/WinKit.git
cd WinKit
powershell -ExecutionPolicy Bypass -File winkit.ps1
```

---

## ✨ Что нового в WinKit 2.0+

- 🪟 **Нативный эффект Mica**: Полупрозрачный размытый фон в стиле Windows 11.
- 🌓 **Светлая и тёмная темы**: Автоматическое определение системной темы при старте и кнопка мгновенного переключения на лету.
- 🎨 **Современный WPF Fluent UI**: Скруглённые вкладки категорий, векторные галочки чекбоксов, стильные кнопки и плавные эффекты наведения.
- 💾 **Управление пресетами**: Сохранение и загрузка списка выбранных программ в один клик (`Документы\winkit-preset.txt`).
- ⚡ **Пакетная установка**: Выбирайте приложения из разных категорий и запускайте их установку через WinGet.

---

## 🎯 Возможности

| Функция | Описание |
|---------|----------|
| 🖥 **Современный WPF GUI** | Чистый интерфейс в стиле Fluent Design на WPF |
| 🪟 **Эффект Mica** | Нативный блюр-эффект Windows 11 через DWM API |
| 🌓 **Светлая / Тёмная тема** | Авто-определение темы OS + кнопка ручного переключения |
| 🗂 **Вкладки категорий** | Удобное разделение по вкладкам (Браузеры, Разработка, Медиа и т.д.) |
| 💾 **Поддержка пресетов** | Быстрое сохранение и загрузка вашего набора программ |
| 📦 **Пакетное управление** | Кнопки `Выбрать всё` и `Очистить всё` |
| 📊 **Отслеживание прогресса** | Отображение статуса установки каждого приложения в консоли |
| 🛡 **Авто-права** | Автоматический запрос прав администратора при запуске |

---

## 📦 Доступные приложения (20+)

| Категория | Приложения |
|-----------|-----------|
| 🌐 **Браузеры** | Google Chrome, Mozilla Firefox, Brave Browser, Vivaldi |
| 💻 **Разработка** | VS Code, Notepad++, Sublime Text, Git |
| 🎬 **Медиа** | VLC Media Player, OBS Studio, Spotify |
| 💬 **Общение** | Discord, Telegram, Skype |
| 🛠 **Утилиты** | 7-Zip, WinRAR, Everything, Rufus |
| 🎮 **Игры** | Steam, Epic Games |

> 💡 **Хотите добавить свои приложения?** Отредактируйте `winkit.ps1` — добавьте `Name`, `Id` и `Cat` в массив `$apps`.

---

## 📋 Требования

- **Windows 10** (версия 1709+) или **Windows 11**
- **WinGet** — предустановлен в Windows 11; для Windows 10 скачайте из [Microsoft Store](https://aka.ms/getwinget)

---

## 🤝 Вклад в проект

1. Сделайте форк репозитория
2. Добавьте новые приложения в `winkit.ps1`
3. Отправьте pull request

---

## 📄 Лицензия

[MIT](LICENSE) — делайте что хотите.

---

<div align="center">

**Сделано с ❤️ автором [Refyrd](https://github.com/Refyrd)**

</div>
