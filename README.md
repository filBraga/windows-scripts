# windows-scripts

Small Windows tweaks for the right-click (context) menu.

All scripts only change keys under `HKEY_CURRENT_USER`, so they don't need admin rights and don't affect other users on the computer. Each one has a matching undo.

## VS Code in the right-click menu

Folder: [`vscode-context-menu/`](vscode-context-menu/)

Adds these items to Windows Explorer, with the VS Code icon:

| You right-click on… | Menu item |
|---|---|
| A file | **Open this file in VS Code** |
| A folder | **Open folder in VS Code** |
| Empty space inside a folder | **Open folder in VS Code** |

**Install:** open PowerShell in the `vscode-context-menu` folder and run:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

The script finds `Code.exe` by itself. It checks the user install (`%LOCALAPPDATA%\Programs\Microsoft VS Code`), the system installs (`Program Files`), and finally the `code` command on your PATH. The items appear right away, with no restart needed.

**Uninstall:** double-click `uninstall.reg` and click **Yes**.

> On Windows 11, these items appear under **Show more options** (or **Shift + right-click**). To see them in the first menu, enable the classic menu below.

## Classic (old) right-click menu on Windows 11

Folder: [`classic-context-menu/`](classic-context-menu/)

Windows 11's compact menu only shows items from packaged apps. Items added through the registry (like the VS Code ones above) only appear in the classic menu. This tweak makes the classic, full menu the default again.

**Enable:** double-click `enable.reg` and click **Yes**.
**Disable (back to Windows 11 default):** double-click `disable.reg` and click **Yes**.

After either one, restart Windows Explorer: open Task Manager (**Ctrl + Shift + Esc**), right-click **Windows Explorer**, and choose **Restart**. Signing out and back in also works.

## Notes

- `.reg` and `.ps1` files are stored with Windows line endings (CRLF). `.gitattributes` keeps Git from changing them.
- Before changing the registry, you can export a backup in `regedit` (**File → Export**).
# windows-scripts
