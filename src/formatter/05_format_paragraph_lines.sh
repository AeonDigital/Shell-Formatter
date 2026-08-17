#!/usr/bin/env bash

# shell_formatter_format_paragraph_lines — Process atomic paragraph streams to handle
# structural margins and wrap boundaries.
# 
# Arguments:
# - raw_paragraph: The continuous text block data chunk extracted from a single paragraph
#   context.
# - soft_line_limit: The targeted horizontal column width value defining preferred
#   word wrapping margins.
# - hard_line_limit: The maximum structural horizontal column barrier allowed for
#   unbreakable or oversized tokens.
# - external_indent_length: The length of the external prefix and spacing required
#   to balance relative indentation metrics.
# 
# Returns:
# - Populates the global indexed array SHELL_FORMATTER_FORMATED_PARAGRAPH_LINES with
#   layout-aligned and structural-wrapped text strings.
shell_formatter_format_paragraph_lines() {
  SHELL_FORMATTER_FORMATED_PARAGRAPH_LINES=()
  local -a formatted_paragraph_lines=()

  local raw_paragraph="${1}"
  local soft_line_limit="${2}"
  local hard_line_limit="${3}"
  local external_indent_length="${4}"

  local raw_paragraph_line=""
  local raw_paragraph_line_ends_with_2_spaces="0"

  local indent_line_one=""
  local indent_line_one_length="-1"
  local indent_line_other=""
  local indent_line_other_length="0"

  local i="0"
  local line=""
  local last_line_idx="0"
  local use_line_indent=""


  while IFS= read -r raw_paragraph_line || [ -n "${raw_paragraph_line}" ]; do
    # 1. The first line of each paragraph determines whether or not it is a list
    #    item and also dictates the indentation level of the subsequent lines.  
    # Here, we obtain the information needed for the correct subsequent indentation.
    if [ "${indent_line_one_length}" -lt "0" ]; then
      indent_line_one="${raw_paragraph_line%%[^[:space:]]*}"
      indent_line_one_length="${#indent_line_one}"
      (( indent_line_one_length += external_indent_length ))

      indent_line_other=""
      indent_line_other_length="0"
      if _shell_formatter_tools_is_list_item "${raw_paragraph_line}"; then
        _shell_formatter_tools_trim_line "${raw_paragraph_line}"

        indent_line_other="${SHELL_FORMATTER_FUNCTION_RETURN%% *} "
        indent_line_other_length="${#indent_line_other}"
        indent_line_other=$(printf '%*s' "${indent_line_other_length}" "")
      fi
    else
      # adjustments for the correct indentation of the multiple lines of a list item
      if [ "${indent_line_other_length}" -gt "0" ]; then
        indent_line_one+="${indent_line_other}"
        indent_line_one_length="${#indent_line_one}"
        (( indent_line_one_length += external_indent_length ))

        indent_line_other=""
        indent_line_other_length="0"
      fi
    fi

    # 2. Checks if the raw paragraph line ends with 2 spaces.
    raw_paragraph_line_ends_with_2_spaces="0"
    if [[ "${raw_paragraph_line}" == *"  " ]]; then
      raw_paragraph_line_ends_with_2_spaces="1"
    fi


    # 3. Removes the spaces from the beginning and end of the line.  The indentation
    #    will be recalculated later.
    _shell_formatter_tools_trim_line "${raw_paragraph_line}"
    raw_paragraph_line="${SHELL_FORMATTER_FUNCTION_RETURN}"

    # 3.1 Replaces list item marker characters so that any paragraph line-break adjustments
    # do not generate lists not intended by the author.
    raw_paragraph_line="${raw_paragraph_line// - / — }"
    raw_paragraph_line="${raw_paragraph_line// '+' / ＋ }"
    raw_paragraph_line="${raw_paragraph_line// '*' / ∗ }"


    shell_formatter_wrap_lines_by_limit_range \
      "${raw_paragraph_line}" \
      "${soft_line_limit}" \
      "${hard_line_limit}" \
      "${indent_line_one_length}" \
      "${indent_line_other_length}"

    i="0"
    line=""
    last_line_idx="${#SHELL_FORMATTER_WRAPPED_PARAGRAPH_LINES[@]}"
    ((last_line_idx--))
    use_line_indent="${indent_line_one}"

    for i in "${!SHELL_FORMATTER_WRAPPED_PARAGRAPH_LINES[@]}"; do
      line="${SHELL_FORMATTER_WRAPPED_PARAGRAPH_LINES["${i}"]}"

      # starting from the second line, use a different indentation if necessary (list
      # item)
      if [ "${i}" -gt "0" ] && [ "${indent_line_other}" != "" ]; then
        use_line_indent+="${indent_line_other}"
        indent_line_other=""
      fi

      # adds back the 2 spaces at the end of the line indicating a line break
      if [ "${i}" = "${last_line_idx}" ] && [ "${raw_paragraph_line_ends_with_2_spaces}" = "1" ]; then
        line+="  "
      fi

      formatted_paragraph_lines+=("${use_line_indent}${line}")
    done

  done <<< "${raw_paragraph}"

  # stores the result in the global variable
  SHELL_FORMATTER_FORMATED_PARAGRAPH_LINES=("${formatted_paragraph_lines[@]}")
}
