# WinKit — Task & Roadmap Tracker

## 📌 Status: Completed

### 🔍 Analysis & Audit Findings
- [x] Analyze codebase architecture and module separation (`src/ui`, `src/core`, `src/config`)
- [x] Run PSScriptAnalyzer linting (`PSUseApprovedVerbs` in `winkit.ps1`, `PSUseBOMForUnicodeEncodedFile` in `Installer.ps1`)
- [x] Identify documentation desync in `README.md` and `README.ru.md` (app count, config file paths, preset mechanics)
- [x] Streamline `.gitignore` for Windows, PowerShell, VS Code, and local presets

---

### 🛠 Implemented Improvements & Fixes
- [x] **Install Script Fix**:
  - [x] Removed UTF-8 BOM and non-ASCII dashes in [install.ps1](file:///D:/Projects/WinKit/install.ps1) to prevent PowerShell `irm | iex` command parsing error.
- [x] **Unified Top Search & WinGet Lookup**:
  - [x] Removed duplicate search box from inside categories tab per user request.
  - [x] Fixed variable scoping in [Controller.ps1](file:///D:/Projects/WinKit/src/ui/Controller.ps1) (`$script:lblOnlineStatus`, `$script:onlineResultsWrap`).
  - [x] Top search bar `TxtSearch` now performs both local category filtering and instant WinGet online querying on `[Enter]`.
  - [x] Expanded top search bar width to 250px in [Layout.xaml](file:///D:/Projects/WinKit/src/ui/Layout.xaml).
- [x] **PSScriptAnalyzer Cleanliness**:
  - [x] 0 errors, 0 warnings across all scripts.
- [x] **Catalog & Docs**:
  - [x] Updated `Python 3` package ID to `Python.Python.3` in [Apps.ps1](file:///D:/Projects/WinKit/src/config/Apps.ps1).
  - [x] Synchronized [README.md](file:///D:/Projects/WinKit/README.md) and [README.ru.md](file:///D:/Projects/WinKit/README.ru.md).
