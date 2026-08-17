#!/usr/bin/env bash

# shell_formatter_format_blocks — Orchestrate text layout restructuring and line
# reconstruction across block clusters.
# 
# Arguments:
# - normalizated_blocks: Name reference (nameref) to an indexed array containing
#   raw or intermediate metadata block paragraphs.
# - blocks_indent: Name reference (nameref) to an indexed array storing the captured
#   visual margin indentation structures.
# - soft_line_limit: Numeric constraint defining the targeted ideal horizontal width
#   margin before wrapping words.
# - hard_line_limit: Numeric constraint establishing the strict absolute maximum
#   character column boundary limit.
# - use_prefix: String literal injected at the beginning of reconstructed elements
#   to serve as a custom line decorator token.
# 
# Returns:
# - Populates the global indexed array SHELL_FORMATTER_FORMATTED_BLOCKS with structured,
#   wrapped, and prefix-decorated string streams.
shell_formatter_format_blocks() {
  SHELL_FORMATTER_FORMATTED_BLOCKS=()

  local -n normalizated_blocks="${1}"
  local -n blocks_indent="${2}"
  local soft_line_limit="${3}"
  local hard_line_limit="${4}"
  local use_prefix="${5}"

  local -a formated_blocks=()

  local block_indent=""
  local block_indent_length=""
  local external_indent_length=""


  # Fetch the indentation layout for the very first comment block cluster
  local i="0"
  local line=""
  local raw_paragraph=""
  local formated_paragraph=""
  for i in "${!normalizated_blocks[@]}"; do
    raw_paragraph="${normalizated_blocks["${i}"]}"
    if [[ "${raw_paragraph}" == "__${SHELL_FORMATTER_BLOCK_MARKUP}_"* ]]; then
      formated_blocks+=("${raw_paragraph}")
      continue
    fi

    # Calculates the block indentation plus the space reserved for the hash and the
    # corresponding spacing.
    block_indent="${blocks_indent["${i}"]}"
    block_indent_length="${#block_indent}"
    (( external_indent_length = block_indent_length + 2 ))

    # Handle intentional empty lines
    if [[ "${raw_paragraph}" = "" || "${raw_paragraph}" = "${codeNL}" ]]; then
      formated_blocks+=("${block_indent}${use_prefix}${codeNL}")
      continue
    fi

    # Process and wrap regular/list paragraphs to matching soft and hard limits
    shell_formatter_format_paragraph_lines \
      "${raw_paragraph}" \
      "${soft_line_limit}" \
      "${hard_line_limit}" \
      "${external_indent_length}"

    formated_paragraph=""
    for line in "${SHELL_FORMATTER_FORMATED_PARAGRAPH_LINES[@]}"; do
      formated_paragraph+="${block_indent}${use_prefix}${line}${codeNL}"
    done
    formated_blocks+=("${formated_paragraph}")
  done

  # stores the result in the global variable
  SHELL_FORMATTER_FORMATTED_BLOCKS=("${formated_blocks[@]}")
}
