# WinKit — Task & Roadmap Tracker

## 📌 Status: In Progress

### 🔍 Analysis & Audit Findings
- [x] Analyze codebase architecture and module separation (`src/ui`, `src/core`, `src/config`)
- [x] Run PSScriptAnalyzer linting (`PSUseApprovedVerbs` in `winkit.ps1`, `PSUseBOMForUnicodeEncodedFile` in `Installer.ps1`)
- [x] Identify documentation desync in `README.md` and `README.ru.md` (app count, config file paths, preset mechanics)
- [ ] Review bloated `.gitignore` (6700+ lines of foreign stack templates)

---

### 🛠 Planned Improvements & Bug Fixes
- [ ] **Docs sync**: Update [README.md](file:///D:/Projects/WinKit/README.md) & [README.ru.md](file:///D:/Projects/WinKit/README.ru.md) with current app catalog (42 apps), modular structure (`src/config/Apps.ps1`), and custom preset file picker dialogs.
- [ ] **ScriptAnalyzer Cleanliness**: Fix function naming verb in [winkit.ps1](file:///D:/Projects/WinKit/winkit.ps1) and file encoding BOM in [Installer.ps1](file:///D:/Projects/WinKit/src/core/Installer.ps1).
- [ ] **App Catalog Refinement**: Update `Python.Python.3.12` to `Python.Python.3` (or add latest versions) in [Apps.ps1](file:///D:/Projects/WinKit/src/config/Apps.ps1).
- [ ] **Clean .gitignore**: Remove unused foreign tech stack templates, keeping clean rules for Windows, PowerShell, VS Code, and local secrets.

---

### 💡 Feature Ideas for WinKit
1. **Selection Counter on Install Button**: Display exact count on button (e.g. `Install (4)`) so user immediately sees what is queued.
2. **"Installed" Pre-Detection**: Query `winget list` in background upon launch and mark already installed apps with a subtle badge or tooltip.
3. **Unified "All Apps" Search View**: Filter seamlessly across all categories or show matching count badges on tab headers.
4. **Export / Import Preset as JSON**: Offer portable JSON presets alongside plain text.
