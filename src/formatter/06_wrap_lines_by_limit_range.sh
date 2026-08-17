#!/usr/bin/env bash

# shell_formatter_wrap_lines_by_limit_range — Execute string segmentation algorithms
# based on word boundary and width limits.
# 
# Arguments:
# - raw_line: The single continuous text line context data to undergo character scanning
#   and fragmentation.
# - soft_line_limit: The integer target column count defining preferred line wrap
#   locations.
# - hard_line_limit: The absolute structural boundary ceiling allowed for single
#   text segments.
# - indent_line_one_length: Calculated width of the initial line indentation layout
#   metrics.
# - indent_line_other_length: Calculated width offset value used to balance secondary
#   lines within block segments.
# 
# Returns:
# - Populates the global indexed array SHELL_FORMATTER_WRAPPED_PARAGRAPH_LINES with
#   individual text line fragments.
shell_formatter_wrap_lines_by_limit_range() {
  SHELL_FORMATTER_WRAPPED_PARAGRAPH_LINES=()
  local -a wrapped_paragraph_lines=()

  local raw_line="${1}"
  local soft_line_limit="${2}"
  local hard_line_limit="${3}"
  local indent_line_one_length="${4}"
  local indent_line_other_length="${5}"


  # calculates the exact position where the line should break, taking into account
  # the internal and external indentation
  local min_break_point="0"
  (( min_break_point = soft_line_limit - indent_line_one_length ))

  local max_break_point="0"
  (( max_break_point = hard_line_limit - indent_line_one_length ))


  local scan_line="${raw_line}"
  local tmp_line=""
  local cut_pos=""
  local pos="0"
  local char=""
  while [ "${scan_line}" != "" ]; do
    # applies limit corrections to the lines following the first one
    if [ "${#wrapped_paragraph_lines[@]}" -gt "0" ] && [ "${indent_line_other_length}" -gt "0" ]; then
      (( min_break_point -= indent_line_other_length ))
      (( max_break_point -= indent_line_other_length ))
      indent_line_other_length="0"
    fi

    # If the remaining text is shorter than the search starting point, there is nothing
    # left to search.
    if [ "${#scan_line}" -le "${min_break_point}" ]; then
      wrapped_paragraph_lines+=("${scan_line}")
      break
    fi

    pos="${min_break_point}"
    tmp_line="${scan_line:0:${pos}}"

    # advances character by character until an empty space is found
    char="${scan_line:${pos}:1}"
    while [ "${char}" != " " ] && [ "${char}" != "" ]; do
      tmp_line+="${char}"

      ((pos++))
      char="${scan_line:${pos}:1}"
    done

    # checks if the final line exceeds the maximum limit try to isolate a potentially
    # very large token
    if [ "${#tmp_line}" -gt "${max_break_point}" ]; then
      local tmp_line_start="${tmp_line% *}"
      local tmp_line_big_token="${tmp_line##* }"

      if [ "${tmp_line_start}" = "${tmp_line_big_token}" ]; then
        wrapped_paragraph_lines+=("${tmp_line}")
      else
        wrapped_paragraph_lines+=("${tmp_line_start}")
        wrapped_paragraph_lines+=("${tmp_line_big_token}")
      fi
    else
      wrapped_paragraph_lines+=("${tmp_line}")
    fi

    # Advance past the space character to prevent leading space artifacts
    ((cut_pos = pos + 1))
    scan_line="${scan_line:${cut_pos}}"
  done


  # stores the result in the global variable
  SHELL_FORMATTER_WRAPPED_PARAGRAPH_LINES=("${wrapped_paragraph_lines[@]}")
}
