#!/usr/bin/env bash

# shell_formatter_extract_document_line_action — Evaluate the structural characteristics
# of a single text stream to determine state transition requirements and block layout
# rules.
# 
# Arguments:
# - trim_line: The pre-processed continuous string representation of the current
#   text line, stripped of its global leading and trailing whitespace padding artifacts.
# - file_shebang: A temporary tracking string storage capturing the presence of execution
#   binary path references on initial read cycles.
# - mantain_comments: Boolean-like flag (1 or 0) stating if specific text comment
#   components should undergo capture sequences.
# - mantain_empty_lines: Boolean-like flag (1 or 0) evaluating whether horizontal
#   visual gaps need layout replication.
# - protected_area_open: Context state bit indicator representing if active line
#   streams are inside encapsulated markdown code fenced segments.
# - comment_block_open: Layout tracking flag mapping if a multi-line cluster of text
#   sentences is currently capturing content data.
# 
# Returns:
# - Updates the global configuration flags SHELL_FORMATTER_LINE_TYPE, SHELL_FORMATTER_REGISTER_RAW_LINE,
#   and SHELL_FORMATTER_REGISTER_COMMENT_BLOCK to dictate orchestrator line behavior.
shell_formatter_extract_document_line_action() {
  SHELL_FORMATTER_LINE_TYPE="none"
  SHELL_FORMATTER_REGISTER_RAW_LINE="0"
  SHELL_FORMATTER_REGISTER_COMMENT_BLOCK="0"


  local trim_line="${1}"
  local file_shebang="${2}"
  local mantain_comments="${3}"
  local mantain_empty_lines="${4}"
  local protected_area_open="${5}"
  local comment_block_open="${6}"


  # 
  # Tratando-se da declaração da shebang
  if [[ "${trim_line}" == "#!"* ]] && [ "${file_shebang}" = "" ]; then
    SHELL_FORMATTER_LINE_TYPE="shebang"
    return 0
  fi


  if [ "${trim_line}" = "" ]; then
    if [ "${mantain_empty_lines}" = "1" ]; then
      SHELL_FORMATTER_LINE_TYPE="empty_line"
    fi

    if [ "${mantain_comments}" = "1" ] && [ "${comment_block_open}" = "1" ]; then
      SHELL_FORMATTER_REGISTER_COMMENT_BLOCK="1"
    fi
    return 0
  fi

  if [[ "${mantain_comments}" = "1" && "${trim_line}" == "# \`\`\`"*  && "${protected_area_open}" -eq "0" ]]; then
    SHELL_FORMATTER_LINE_TYPE="protected_area_open"
    SHELL_FORMATTER_REGISTER_RAW_LINE="1"

    if [ "${comment_block_open}" = "1" ]; then
      SHELL_FORMATTER_REGISTER_COMMENT_BLOCK="1"
    fi
    return 0
  fi

  if [[ "${mantain_comments}" = "1" && "${trim_line}" == "# \`\`\`"* && "${protected_area_open}" -eq "1" ]]; then
    SHELL_FORMATTER_LINE_TYPE="protected_area_close"
    SHELL_FORMATTER_REGISTER_RAW_LINE="1"
    return 0
  fi

  if [[ "${trim_line}" == "#"* && "${protected_area_open}" -eq "0" ]]; then
    if [ "${mantain_comments}" = "1" ]; then
      SHELL_FORMATTER_LINE_TYPE="comment_line"
    fi
    return 0
  fi

  if [[ "${mantain_comments}" = "1" && "${comment_block_open}" = "1" && "${protected_area_open}" -eq "0" ]]; then
    SHELL_FORMATTER_LINE_TYPE="comment_end"
    SHELL_FORMATTER_REGISTER_RAW_LINE="1"
    SHELL_FORMATTER_REGISTER_COMMENT_BLOCK="1"
    return 0
  fi


  SHELL_FORMATTER_LINE_TYPE="code"
  SHELL_FORMATTER_REGISTER_RAW_LINE="1"
}
