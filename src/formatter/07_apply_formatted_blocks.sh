#!/usr/bin/env bash

# shell_formatter_apply_formatted_blocks — Compile the final document by injecting
# processed block content back into structural layout placeholders.
# 
# Arguments:
# - new_document: The original skeleton stream content containing temporary tracking
#   marker tags.
# - formated_blocks: Name reference (nameref) to the indexed array holding completely
#   restructured text segments.
# - placeholder_block: The string token pattern identifying the start position of
#   an injection boundary.
# - placeholder_block_end: The string token pattern identifying the termination sequence
#   of a processed text block.
# - total_blocks: Total integer count of segmented blocks tracking iterations across
#   data replacement loops.
# 
# Returns:
# - Populates the global variable SHELL_FORMATTER_FINISHED_NEW_DOCUMENT with the
#   compiled, formatted, and fully assembled target file stream.
shell_formatter_apply_formatted_blocks() {
  SHELL_FORMATTER_FINISHED_NEW_DOCUMENT=""

  local new_document="${1}"
  local -n formated_blocks="${2}"
  local placeholder_block="${3}"
  local placeholder_block_end="${4}"
  local total_blocks="${5}"

  local i="0"
  local target_block=""
  local target_end_block=""
  local stridx='\[idx\]'

  local str_block=""
  local str_paragraph=""
  for ((i=0; i<total_blocks; i++)); do
    str_block=""
    target_block="${placeholder_block/${stridx}/${i}}"
    target_end_block="${placeholder_block_end/${stridx}/${i}}"

    while [ "${#formated_blocks[@]}" -gt "0" ]; do
      str_paragraph="${formated_blocks[0]}"
      formated_blocks=("${formated_blocks[@]:1}")


      if [ "${str_paragraph}" = "${target_end_block}" ]; then
        break
      fi

      str_block+="${str_paragraph}"
    done

    str_block="${str_block:0: -1}"
    str_block="${str_block//&/\\&}"

    new_document="${new_document/${target_block}/${str_block}}"
  done


  SHELL_FORMATTER_FINISHED_NEW_DOCUMENT="${new_document}"
}
