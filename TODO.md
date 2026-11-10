# WinKit — Task & Roadmap Tracker

## 📌 Status: Completed

### 🔍 Analysis & Audit Findings
- [x] Analyze codebase architecture and module separation (`src/ui`, `src/core`, `src/config`)
- [x] Run PSScriptAnalyzer linting (`PSUseApprovedVerbs` in `winkit.ps1`, `PSUseBOMForUnicodeEncodedFile` in `Installer.ps1`, `PSUseSingularNouns` in `Controller.ps1`)
- [x] Streamline `.gitignore` for Windows, PowerShell, VS Code, and local presets

---

### 🛠 Implemented Improvements & Features
- [x] **Feature 1 & 6: Installed Detection & Version Badges**:
  - [x] Implemented non-blocking background scanner using in-process PowerShell runspace querying `winget list`.
  - [x] Dynamic version badges under each app in categories (`Installed: vX.X` in green or `Installed • Update: vY.Y` in gold).
  - [x] Added installed status badges to online WinGet search result cards.
- [x] **Feature 3: One-Click WinGet Upgrade All**:
  - [x] Added `Upgrade All` button in bottom controls bar.
  - [x] Integrated `Start-SystemUpgrade` with real-time log streaming and progress overlay.
  - [x] Automatically refreshes installed badges once upgrade completes.
- [x] **Feature 4: Native WinGet JSON Preset Support**:
  - [x] Added support for official WinGet JSON schema (`.json`) in Save/Load preset dialogs.
  - [x] Preserved 100% backward compatibility with classic `.txt` presets.
- [x] **UI & Search UX Enhancements**:
  - [x] Caret ("палочка") styled with `CaretBrush="{DynamicResource AppText}"`.
  - [x] Top search bar with online WinGet querying on `[Enter]` and smooth loading progress bar.
  - [x] Global outside click handler: clicking background or categories reactivates categories and clears search focus.
- [x] **Install Script Fix**:
  - [x] Saved [install.ps1](file:///D:/Projects/WinKit/install.ps1) with UTF-8 without BOM and ASCII dashes for PowerShell 5.1 compatibility.
- [x] **Catalog & Docs**:
  - [x] Updated `Python 3` package ID in [Apps.ps1](file:///D:/Projects/WinKit/src/config/Apps.ps1).
  - [x] Synchronized [README.md](file:///D:/Projects/WinKit/README.md) and [README.ru.md](file:///D:/Projects/WinKit/README.ru.md).
