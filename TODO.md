# WinKit — Task & Roadmap Tracker

## 📌 Status: Completed

### 🔍 Analysis & Audit Findings
- [x] Analyze codebase architecture and module separation (`src/ui`, `src/core`, `src/config`)
- [x] Run PSScriptAnalyzer linting (`PSUseApprovedVerbs` in `winkit.ps1`, `PSUseBOMForUnicodeEncodedFile` in `Installer.ps1`)
- [x] Identify documentation desync in `README.md` and `README.ru.md` (app count, config file paths, preset mechanics)
- [x] User instruction: Keep `.gitignore` untouched

---

### 🛠 Implemented Improvements & Features
- [x] **PSScriptAnalyzer Fixes**:
  - [x] Renamed `Ensure-WinGet` to approved verb `Assert-WinGet` in [winkit.ps1](file:///D:/Projects/WinKit/winkit.ps1).
  - [x] Re-encoded [Installer.ps1](file:///D:/Projects/WinKit/src/core/Installer.ps1) and [Controller.ps1](file:///D:/Projects/WinKit/src/ui/Controller.ps1) with UTF-8 BOM.
  - [x] Re-tested: 0 warnings, 0 errors in PSScriptAnalyzer.
- [x] **Catalog Update**:
  - [x] Updated `Python 3` package ID to `Python.Python.3` in [Apps.ps1](file:///D:/Projects/WinKit/src/config/Apps.ps1).
- [x] **Feature: WinGet Online Search & Store**:
  - [x] Added `🌐 WinGet Search` tab with query input, instant search button, and live status feedback.
  - [x] Added `[Enter]` shortcut in both main search box and online search tab to query WinGet online.
  - [x] Seamlessly integrated online package selections into the unified install pipeline.
- [x] **Dynamic Selection Counter**:
  - [x] Added live count indicator on the Install button (`Install (N)`).
- [x] **Documentation Sync**:
  - [x] Updated [README.md](file:///D:/Projects/WinKit/README.md) (42+ apps, WinGet online search feature, preset dialogs, modular structure).
  - [x] Updated [README.ru.md](file:///D:/Projects/WinKit/README.ru.md) with complete Russian translation.
