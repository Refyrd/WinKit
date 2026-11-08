# WinKit — Task & Roadmap Tracker

## 📌 Status: Completed

### 🔍 Analysis & Audit Findings
- [x] Analyze codebase architecture and module separation (`src/ui`, `src/core`, `src/config`)
- [x] Run PSScriptAnalyzer linting (`PSUseApprovedVerbs` in `winkit.ps1`, `PSUseBOMForUnicodeEncodedFile` in `Installer.ps1`, `PSUseSingularNouns` in `Controller.ps1`)
- [x] Streamline `.gitignore` for Windows, PowerShell, VS Code, and local presets

---

### 🛠 Implemented Improvements & Fixes
- [x] **Search Box Activation & Category Inactivity**:
  - [x] Fixed function scope bug: declared `script:Show-CategoryView` and `script:Show-SearchResultView` in script scope so they are callable from any scriptblock.
  - [x] Used `PreviewKeyDown` for `[Enter]` with `$e.Handled = $true` so online search always triggers without being intercepted.
  - [x] When search is focused or active, category tabs automatically become inactive (`IsEnabled = $false`, `Opacity = 0.4`), clearly showing that search mode is active.
  - [x] Exiting search, clearing text, or clicking "Back to Categories" smoothly re-enables categories (`IsEnabled = $true`, `Opacity = 1.0`).
- [x] **Caret & Loading Bar**:
  - [x] Text caret ("палочка") styled with `CaretBrush="{DynamicResource AppText}"`.
  - [x] Animated Fluent progress bar appears during WinGet online query.
- [x] **Install Script Fix**:
  - [x] Saved [install.ps1](file:///D:/Projects/WinKit/install.ps1) with UTF-8 without BOM and ASCII dashes to ensure clean `irm | iex` execution in Windows PowerShell 5.1.
- [x] **Catalog & Docs**:
  - [x] Updated `Python 3` package ID in [Apps.ps1](file:///D:/Projects/WinKit/src/config/Apps.ps1).
  - [x] Synchronized [README.md](file:///D:/Projects/WinKit/README.md) and [README.ru.md](file:///D:/Projects/WinKit/README.ru.md).
