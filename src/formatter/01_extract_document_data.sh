#!/usr/bin/env bash

# shell_formatter_extract_document_data — Parse raw document streams to isolate block
# metadata from primary code paths.
# 
# Arguments:
# - file_content: The entire continuous string representation of the multi-line input
#   data stream.
# - mantain_comments: Boolean-like flag (1 or 0) indicating whether specific extracted
#   metadata content blocks should be parsed and mapped.
# - mantain_empty_lines: Boolean-like flag (1 or 0) indicating whether formatting
#   whitespace gap patterns must remain in the skeleton output structure.
# 
# Returns:
# - Assigns the stripped document layout skeleton structure into the global variable
#   SHELL_FORMATTER_RAW_DOCUMENT.
# - Populates the SHELL_FORMATTER_RAW_COMMENT_BLOCKS indexed array with segregated
#   content chunks found between execution lines.
# - Compiles the visual alignment prefix spacing layout definitions into the global
#   SHELL_FORMATTER_RAW_COMMENT_BLOCKS_INDENT array mapping.
shell_formatter_extract_document_data() {
  SHELL_FORMATTER_RAW_DOCUMENT=""
  SHELL_FORMATTER_RAW_COMMENT_BLOCKS=()
  SHELL_FORMATTER_RAW_COMMENT_BLOCKS_INDENT=()

  local file_content="${1}"
  local mantain_comments="${2}"
  local mantain_empty_lines="${3}"

  local file_new_content=""
  local file_shebang=""
  local raw_line=""
  local trim_line=""
  local comment_block_open="0"
  local comment_block_indent=""
  local comment_block_content=""
  local comment_line_content=""
  local protected_area_open="0"

  # Local arrays initialized to structure comments during parsing
  local -a comment_blocks=()
  local -a comment_blocks_indents=()
  local block_idx=0


  while IFS= read -r raw_line || [ -n "${raw_line}" ]; do
    _shell_formatter_tools_trim_line "${raw_line}"
    trim_line="${SHELL_FORMATTER_FUNCTION_RETURN}"


    shell_formatter_extract_document_line_action \
      "${trim_line}" "${file_shebang}" \
      "${mantain_comments}" "${mantain_empty_lines}" \
      "${protected_area_open}" "${comment_block_open}"


    if [ "${SHELL_FORMATTER_REGISTER_COMMENT_BLOCK}" = "1" ]; then
      comment_blocks["${block_idx}"]="${comment_block_content}"
      comment_blocks_indents["${block_idx}"]="${comment_block_indent}"

      file_new_content+="__${SHELL_FORMATTER_BLOCK_MARKUP}_${block_idx}__${codeNL}"
      ((block_idx++))

      comment_block_open="0"
      comment_block_indent=""
      comment_block_content=""
    fi


    if [ "${SHELL_FORMATTER_REGISTER_RAW_LINE}" = "1" ]; then
      _shell_formatter_tools_trimR_line "${raw_line}"
      file_new_content+="${SHELL_FORMATTER_FUNCTION_RETURN}${codeNL}"
    fi


    case "${SHELL_FORMATTER_LINE_TYPE}" in
      code)
        protected_area_open="0"
        ;;
      shebang)
        file_shebang="${trim_line}${codeNL}"
        protected_area_open="0"
        ;;
      empty_line)
        file_new_content+="${codeNL}"
        protected_area_open="0"
        ;;
      protected_area_open)
        protected_area_open="1"
        ;;
      protected_area_close)
        protected_area_open="0"
        ;;

      comment_line)
        if [ "${comment_block_open}" = "1" ]; then
          comment_block_content+="${codeNL}"
        else
          comment_block_open="1"
          comment_block_indent="${raw_line%%#*}"
          comment_block_content=""
        fi

        # Extracts the raw text from the comment.  
        # Leading and trailing spaces are excluded..
        comment_line_content="${trim_line:2}"

        # maintains the line break marker.
        if [[ "${raw_line}" == *"  " ]]; then
          comment_line_content+="  "
        fi

        comment_block_content+="${comment_line_content}"
        ;;
    esac
  done <<< "${file_content}"



  # Flush any remaining comment block at the end of the file stream
  if [ "${comment_block_open}" = "1" ]; then
    comment_blocks["${block_idx}"]="${comment_block_content}"
    comment_blocks_indents["${block_idx}"]="${comment_block_indent}"
    file_new_content+="__${SHELL_FORMATTER_BLOCK_MARKUP}_${block_idx}__${codeNL}"
    ((block_idx++))

    comment_block_open="0"
    comment_block_indent=""
    comment_block_content=""
  fi



  # Prepends shebang back to structure if it was defined
  file_new_content="${file_shebang}${file_new_content}"


  # transfers the obtained information to globally accessible variables.
  SHELL_FORMATTER_RAW_DOCUMENT="${file_new_content}"
  SHELL_FORMATTER_RAW_COMMENT_BLOCKS=("${comment_blocks[@]}")
  SHELL_FORMATTER_RAW_COMMENT_BLOCKS_INDENT=("${comment_blocks_indents[@]}")
}
