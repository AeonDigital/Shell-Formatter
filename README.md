Shell-Formatter
================================

> [Aeon Digital](http://www.aeondigital.com.br)  
> rianna@aeondigital.com.br

&nbsp;

> An elegant formatting mechanism to normalize, automatically wrap, and beautify
> code comments using Markdown-style syntax.

&nbsp;

Writing clean code is only half the battle - keeping your documentation readable
is just as important. Shell-Formatter is a production-ready utility designed to automatically
format, clean, and standardize code comments. Instead of manually wrapping long paragraphs
or adjusting broken lines, this engine reads your script, interprets your comments
using natural Markdown rules, and realigns the text to stay within your preferred
column limits.




&nbsp;
________________________________________________________________________________

## ADVANCED BULLETS & FORMATTING FEATURES

Beyond standard paragraph formatting, the engine features an intelligent parser that
recognizes and preserves advanced list item structures. This gives you complete freedom
to organize technical blocks without losing manual indents or breaking lines accidentally:

- **Standard Markdown:** Full support for classic bullets (`-`, `*`, `+`) and sub-lists.
- **Multi-Level Numbering:** Automatically scales with technical index nesting (e.g.,
  `1.`, `2.1.`, `3.1.2.`).
- **Custom Project Stages:** Supports clear uppercase structural anchors (e.g., `STAGE_3:`,
  `STEP_4.5:`, `PHASE_1:`).
- **System Tag Overrides:** Clean syntax tags for environment boundaries (e.g., `_START_:`,
  `_FINAL_ASSEMBLY_:`).



### Defensive Unicode Type Conversions

To ensure absolute paragraph stability during aggressive word wrapping, the engine
implements a defensive normalization layer.

If standard Markdown list characters (`+`, `*`) are discovered as isolated text elements
(surrounded by spaces) near your column limits, forcing them to the start of a new
wrapped line would cause standard Markdown parsers to incorrectly interpret them
as new bullet points. To prevent this formatting corruption, the engine intelligently
converts them into safe, visually equivalent Unicode mathematical operators:

- **Isolated " - " => " — "** (Converts to an Em Dash; `U+2014`)
- **Isolated " + " => " ＋ "** (Converts to a Fullwidth Plus Sign; `U+FF0B`)
- **Isolated " * " => " ∗ "** (Converts to an Asterisk Operator; `U+2217`)

These operators are treated as pure text string literals by Markdown, maintaining
perfect visual styling while completely disabling accidental list item triggers.



### The Magic in Action: Before & After

**Before Formatting (Messy, manual breaks, and trailing alignment gaps):**

```bash
  # STAGE_3: Formats the paragraph blocks so they are ready to be reinserted into the document. And restores the original indentation and comment markup
  #          
  shell_formatter_format_blocks \
    "SHELL_FORMATTER_NORMALIZATED_BLOCKS"
```

**After Formatting (Perfect word wrapping, aligned custom margins, and professional
layout):**

```bash
  # STAGE_3: Formats the paragraph blocks so they are ready to be reinserted into
  #          the document. And restores the original indentation and comment markup
  shell_formatter_format_blocks \
    "SHELL_FORMATTER_NORMALIZATED_BLOCKS"
```




&nbsp;
________________________________________________________________________________

## DOWNLOAD AND USE

To install or update the formatting engine instantly without manually handling parameters,
copy and execute the command below in your terminal. This one-liner pulls the automated
installer, provisions your native local user binary directory (`$XDG_BIN_HOME` or
`~/.local/bin`), deploys the tool into a dedicated sandboxed directory, and sets
up executable states automatically:

```bash
# Download and install the shell formatter engine tool
curl -sSL "https://githubusercontent.com/AeonDigital/Shell-Formatter/refs/heads/main/package.sh" | \
  bash -s -- \
  "https://githubusercontent.com" \
  "shell_formatter_engine" \
  "shell_formatter"
```



### Manual Execution Examples

Once deployed, you can access the embedded manual guidelines directly from your local
path or invoke the script context using its configuration flags:

```bash
# Display the Formatting Engine CLI Manual
~/.local/bin/shell_formatter_engine/shell_formatter.sh --help

# Process a script and overwrite its original content paths
shell_formatter "target_script.sh"

# Format a script with custom limits (e.g., Soft: 90 characters, Hard: 130 characters)
shell_formatter "target_script.sh" "output_fixed.sh" 1 1 90 130
```




&nbsp;
________________________________________________________________________________

## IMPORTANT CAUTION: CLEANING & HEREDOC BEHAVIOR

The formatting engine is highly optimized to maximize source code hygiene. During
its execution pipeline, it will automatically perform the following operations:

- **Right Whitespace Stripping:** All trailing spaces or tabs at the end of code
  lines are immediately removed.
- **Empty Line Purging:** Any existing whitespace characters sitting inside intentional
  blank lines are completely cleaned.



### Handling Pre-formatted Blocks & Heredocs

Because the engine cleans line structures globally, you must exercise caution when
your scripts rely on code blocks where trailing spaces or specific formatting must
remain untouched. This includes:

1. **Heredocs (`<<EOF ... EOF`):** Internal layout padding or trailing whitespaces
   inside the text string will be stripped.
2. **Herestrings (`<<< "$variable"`):** Surrounding formatting padding will be evaluated
   and cleaned.
3. **Embedded Multiline Strings:** Literal raw multiline text definitions block definitions.

**Best Practice Solution:** If your shell tool requires loading sensitive pre-formatted
text structures, multi-line templates, or exact whitespace matrices, we strongly
recommend moving that specific layout block **into an external template file** and
loading it dynamically at runtime (e.g., via `cat`, `source`, or native template
streams). This keeps your main script entirely clean and safe to be optimized by
the formatting engine.




&nbsp;
________________________________________________________________________________

## DEVELOPMENT SETUP

This project uses custom Git hooks to automate tasks (such as code formatting) before
commits. Since the `.git` folder is not shared in the repository, you need to enable
the hook locally the first time you clone the project.



### Enabling Git Hooks

Open your terminal at the project root and run the command below to point the Git
hooks to our dedicated folder:

```bash
git config core.hooksPath .dev/hooks/git
```

Ensure the script has execution permissions:

```bash
chmod +x .dev/hooks/git/pre-commit
```

You're all set! The comment formatter will trigger automatically whenever you attempt
to run `git commit` on `.sh` files.




&nbsp;
________________________________________________________________________________

## VSCODE INTEGRATION

To boost your productivity, you can configure Visual Studio Code to execute the formatting
engine directly on demand using a native keyboard shortcut or automate it on every
file save.

For a complete step-by-step guide on how to configure native project tasks, custom
keybindings, or lightweight automation extensions, please refer to our dedicated
guide:

**[VSCode Integration Guide (CONFIG.md)](CONFIG.md)**




&nbsp;
________________________________________________________________________________

## LICENSE

This project is offered under the [MIT license](LICENSE.md).