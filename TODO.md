# WinKit — Task & Roadmap Tracker

## 📌 Status: Active Development

### 🔍 Analysis & Audit Findings
- [x] Analyze codebase architecture and module separation (`src/ui`, `src/core`, `src/config`)
- [x] Run PSScriptAnalyzer linting (`PSUseApprovedVerbs` in `winkit.ps1`, `PSUseBOMForUnicodeEncodedFile` in `Installer.ps1`, `PSUseSingularNouns` in `Controller.ps1`)
- [x] Streamline `.gitignore` for Windows, PowerShell, VS Code, and local presets

---

### 🛠 Implemented Improvements & Fixes
- [x] **Background / Category Reactivation On Click**:
  - [x] Added `Window.PreviewMouseDown` global hit-testing: clicking anywhere outside the search box (on background, categories, or apps) clears search focus and restores categories to active state (`Opacity = 1.0`, `IsEnabled = $true`).
  - [x] While search is focused, categories are non-intrusively dimmed (`Opacity = 0.5`) without hard-disabling clicks, so clicking a tab or checkbox activates it immediately.
- [x] **Search Box Activation & Caret**:
  - [x] Caret ("палочка") styled with `CaretBrush="{DynamicResource AppText}"` for visibility in both dark and light modes.
  - [x] `PreviewKeyDown` with `$e.Handled = $true` guarantees Enter key triggers WinGet online search without missing events.
  - [x] Animated Fluent progress bar appears during WinGet online query.
- [x] **Install Script Fix**:
  - [x] Saved [install.ps1](file:///D:/Projects/WinKit/install.ps1) with UTF-8 without BOM and ASCII dashes to ensure clean `irm | iex` execution in Windows PowerShell 5.1.
- [x] **Catalog & Docs**:
  - [x] Updated `Python 3` package ID in [Apps.ps1](file:///D:/Projects/WinKit/src/config/Apps.ps1).
  - [x] Synchronized [README.md](file:///D:/Projects/WinKit/README.md) and [README.ru.md](file:///D:/Projects/WinKit/README.ru.md).

---

### 💡 Future Ideas & Enhancements (Backlog)
- [ ] **1. Детекция установленных программ (Installed Detection)**:
  - Фоновый вызов `winget list` при старте для определения установленных в системе приложений.
  - Отображение бейджа `Installed` или зеленого индикатора рядом с программами, которые уже есть на ПК, чтобы не ставить их повторно.
- [ ] **2. Быстрые готовые профили (Quick Preset Profiles)**:
  - Готовые кнопки/пресеты в один клик:
    - *Essentials*: Браузер, 7-Zip, VLC, Telegram, VC++ Redist.
    - *Developer*: VS Code, Git, Python 3, Node.js, Docker Desktop, Notepad++.
    - *Gamer*: Steam, Epic Games, Discord, MSI Afterburner, 7-Zip, DirectX, GPU-Z.
- [ ] **3. Пакетное обновление установленного ПО (WinGet Upgrade)**:
  - Кнопка "Check Updates" или вкладка "Updates", запускающая `winget upgrade` для обновления всех устаревших программ на ПК в один клик.
- [ ] **4. Поддержка нативного экспорта/импорта WinGet (winget export/import)**:
  - Сохранение и загрузка конфигурации в официальном JSON-формате `winget export -o setup.json`.
  - Позволяет развернуть тот же софт на любой машине официальной командой `winget import`.
- [ ] **5. Интеграция базовых твиков Windows 11 (Post-Install Tweaks)**:
  - Опциональная вкладка или чеклист системных твиков после чистой установки:
    - Включение классического контекстного меню Windows 11.
    - Включение отображения расширений файлов и скрытых папок.
    - Отключение назойливых виджетов и телеметрии.
- [ ] **6. Отображение размера загрузки и версий в карточках**:
  - Отображение актуальной версии и ориентировочного размера дистрибутива прямо в списке.
