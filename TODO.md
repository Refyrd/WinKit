# WinKit — Task & Roadmap Tracker

## 📌 Status: Completed

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
