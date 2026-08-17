#!/usr/bin/env bash


# _shell_formatter_tools_trim_line — Strip leading and trailing whitespace characters
# from a string.
# 
# Arguments:
# - str: The raw input string containing potential leading or trailing whitespace.
# 
# Returns:
# - Assigns the fully cleaned and trimmed string to the global variable SHELL_FORMATTER_FUNCTION_RETURN.
_shell_formatter_tools_trim_line() {
  local str="${1}"
  str="${str#"${str%%[![:space:]]*}"}" # trim L
  SHELL_FORMATTER_FUNCTION_RETURN="${str%"${str##*[![:space:]]}"}" # trim R
}



# _shell_formatter_tools_trimL_line — Strip leading whitespace characters from the
# left side of a string.
# 
# Arguments:
# - str: The raw input string containing potential leading spaces or tabs.
# 
# Returns:
# - Assigns the left-trimmed string to the global variable SHELL_FORMATTER_FUNCTION_RETURN.
_shell_formatter_tools_trimL_line() {
  local str="${1}"
  SHELL_FORMATTER_FUNCTION_RETURN="${str#"${str%%[![:space:]]*}"}" # trim L
}



# _shell_formatter_tools_trimR_line — Strip trailing whitespace characters from the
# right side of a string.
# 
# Arguments:
# - str: The raw input string containing potential trailing spaces or tabs.
# 
# Returns:
# - Assigns the right-trimmed string to the global variable SHELL_FORMATTER_FUNCTION_RETURN.
_shell_formatter_tools_trimR_line() {
  local str="${1}"
  SHELL_FORMATTER_FUNCTION_RETURN="${str%"${str##*[![:space:]]}"}" # trim R
}



# _shell_formatter_tools_is_list_item — Validate if a string starts with a recognized
# Markdown or custom list bullet pattern.
# 
# Arguments:
# - str: The text line content evaluated for list markers, stages, or custom documentation
#   tags.
# 
# Returns:
# - Returns exit status 0 if the string matches standard Markdown bullets, custom
#   stage tokens, or uppercase tag tokens.
# - Returns exit status 1 if no matching block initialization prefix pattern is detected.
_shell_formatter_tools_is_list_item() {
  local str="${1}"

  # 1.  Standard Markdown list items (e.g., "- ", "1. ", "2.1. ", "A)")
  local rx_markdown="^([[:space:]]*)([-*+]|([0-9]+\.)+|[a-zA-Z][\.\)])[[:space:]]+"

  # 2.  Custom stage tokens (e.g., "STAGE_3:", "STEP_4.5:", "PHASE_1:")
  # 2.1. [A-Z]+   -> One or more uppercase letters
  # 2.2. _        -> One literal underscore
  # 2.3. [0-9.]+ -> One or more digits, allowing decimal points
  # 2.4. :        -> A literal colon followed by space or end of string
  local rx_custom_stage="^([[:space:]]*)[A-Z]+_[0-9.]+:([[:space:]]+|$)"

  # 3.  Custom tag tokens (e.g., "_START_:", "_END_:", "_FINAL_ASSEMBLY_:")
  # 3.1. _        -> Leading underscore
  # 3.2. [A-Z_]+  -> One or more uppercase letters or internal underscores
  # 3.3. _        -> Trailing underscore
  # 3.4. :        -> A literal colon followed by space
  local rx_custom_tags="^([[:space:]]*)_[A-Z_]+_:[[:space:]]+"

  # Evaluates if the target line matches any of the bullet patterns
  if [[ "${str}" =~ ${rx_markdown} || "${str}" =~ ${rx_custom_stage} || "${str}" =~ ${rx_custom_tags} ]]; then
    return 0
  fi
  return 1
}



# _shell_formatter_tools_is_separator — Validate if a string qualifies as a Markdown
# or structural horizontal rule line separator.
# 
# Arguments:
# - str: The clean text line content evaluated for continuous markdown layout break
#   lines.
# 
# Returns:
# - Returns exit status 0 if the string forms a valid horizontal break layout sequence.
# - Returns exit status 1 if length is insufficient, leading spaces mimic lists,
#   or invalid tokens exist.
_shell_formatter_tools_is_separator() {
  local str="${1}"

  # 1. Length Criterion: Must have 3 or more than characters (minimum 3)
  if [ "${#str}" -lt "3" ]; then
    return 1
  fi

  # 2. First 2 Characters Criterion: Must not contain operational formatting whitespace
  #    gaps.
  if [ "${str:0:1}" = " " ] || [ "${str:1:1}" = " " ]; then
    return 1
  fi

  # 3. Entire Line Composition Criterion (Regex):
  #    - Must start with: -, =, or *
  #    - The rest of the line may only contain: -, =, *, or standard text spaces
  local separator_regex='^[-=*][-=*[:space:]]*$'

  if [[ "${str}" =~ ${separator_regex} ]]; then
    return 0
  else
    return 1
  fi
}
