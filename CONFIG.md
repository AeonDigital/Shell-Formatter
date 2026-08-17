VSCode Integration Guide
================================

> [Aeon Digital](http://www.aeondigital.com.br)  
> rianna@aeondigital.com.br

&nbsp;

This guide provides architectural instructions to integrate the **Shell-Formatter**
engine directly into your Visual Studio Code workspace. Since VSCode does not ship
with a native formatting provider for shell scripts (`.sh`), you can bridge this
gap easily using native engine features or lightweight official plugins.




&nbsp;
________________________________________________________________________________

## OPTION 1: NATIVE EXECUTION SHORTCUT (RECOMMENDED / ZERO PLUGINS)

This approach uses VSCode's native **Tasks** subsystem combined with custom keybindings.
It requires absolutely no third-party extensions.



### Step 1: Create the Project Task

Inside your project root directory, create a hidden folder named `.vscode/` (if it
does not exist yet) and add a file named `tasks.json`. Paste the following configuration:

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Run Shell-Formatter",
      "type": "shell",
      "command": "\${env:HOME}/.local/bin/shell_formatter/package.sh",
      "args": ["\${file}"],
      "group": "none",
      "presentation": {
        "reveal": "silent",
        "panel": "shared",
        "showReuseMessage": false,
        "clear": true
      },
      "runOptions": {
        "reevaluateOnRerun": true
      }
    }
  ]
}
```




### Step 2: Bind the Keyboard Shortcut (`Ctrl + Alt + F`)

To map the task to a key binding, open your global VSCode shortcuts configuration:

1. Press `Ctrl + Shift + P` (or `Cmd + Shift + P` on macOS).
2. Type and select `Preferences: Open Keyboard Shortcuts (JSON)`.
3. Add the following rule inside the configuration array:


```json
[
  {
    "key": "ctrl+alt+f",
    "command": "workbench.action.tasks.runTask",
    "args": "Run Shell-Formatter",
    "when": "editorLangId == shellscript && editorTextFocus"
  }
]
```


*(Note: If you are on macOS, you may use `ctrl+option+f` or `cmd+option+f` instead).*



### Why `Ctrl + Alt + F`?

The global default formatting key in VSCode is `Shift + Alt + F`. We deliberately
map our engine to **`Ctrl + Alt + F`** to avoid breaking default formatters for languages
that already have native formatters in the same workspace (such as JSON, Markdown,
or Python). The restriction `"when": "editorLangId == shellscript"` guarantees this
shortcut only triggers when a shell script file is actively focused.




&nbsp;
________________________________________________________________________________

## OPTION 2: RUN AUTOMATICALLY ON SAVE (EXTENSION-DRIVEN)

If you prefer the environment to automatically beautify and wrap your comments every
single time you hit save, VSCode limits native task injections inside the core save
pipeline for security reasons. The cleanest and industry-standard way to achieve
this is via a lightweight automation bridge.



### Step 1: Install the Extension

Install the official, lightweight, open-source extension **[Run on Save (by emeraldwalk)](https://visualstudio.com)**
from the VSCode Marketplace.



### Step 2: Configure Workspace Settings

Create or open the `.vscode/settings.json` file inside your project and add the following
lifecycle hook configuration:

```json
{
  "emeraldwalk.runonsave": {
    "commands": [
      {
        "match": "\\.sh\$",
        "cmd": "\({env:HOME}/.local/bin/shell_formatter/package.sh \"\){file}\""
      }
    ]
  }
}
```


Every time a `.sh` file is saved through the editor window, the plugin intercepts
the event and safely routes the current file path (`${file}`) directly into your
sandboxed local formatting bin.




&nbsp;
________________________________________________________________________________

## THE ULTIMATE COMBO: IDE INTEGRATION + GIT HOOK

By choosing either option above, you gain the best workflow efficiency available:

1. **In the IDE:** Code comment syntax wraps and drops into perfect margins instantly
   while you work.


2. **In the Git Hook (`pre-commit`):** Acts as a bulletproof gatekeeper. If someone
   changes a script outside VSCode (e.g., via `nano`, `vim`, or a separate terminal
   stream) and forgets to format, the pre-commit script catches it, isolates the
   files, and blocks the staging flow until reviewed.