#!/usr/bin/env bash

# shell_formatter_normalize_blocks — Unify raw string segments into cohesive, standardized
# paragraph text units.
# 
# Arguments:
# - raw_blocks: Name reference (nameref) to the indexed array containing extracted
#   unstructured text chunks.
# - raw_blocks_indent: Name reference (nameref) to the indexed array mapping original
#   whitespace layouts for each block.
# 
# Returns:
# - Populates the global array SHELL_FORMATTER_NORMALIZATED_BLOCKS with atomized
#   text sentences and list-item blocks.
# - Compiles corresponding indentation tracking structures into the global array
#   SHELL_FORMATTER_NORMALIZATED_BLOCKS_INDENT.
shell_formatter_normalize_blocks() {
  SHELL_FORMATTER_NORMALIZATED_BLOCKS=()
  SHELL_FORMATTER_NORMALIZATED_BLOCKS_INDENT=()

  local -a block_paragraphs=()
  local -a block_paragraphs_indent=()

  local -n raw_blocks="${1}"
  local -n raw_blocks_indent="${2}"

  local i=0
  local raw_block=""
  local raw_block_indent=""

  for i in "${!raw_blocks[@]}"; do
    raw_block="${raw_blocks["${i}"]}"
    raw_block_indent="${raw_blocks_indent["${i}"]}"

    local current_block=""
    local raw_line=""
    local trim_line=""
    local is_list_item="0"


    # Read lines of the current single block
    while IFS= read -r raw_line || [ -n "${raw_line}" ]; do
      _shell_formatter_tools_trim_line "${raw_line}"
      trim_line="${SHELL_FORMATTER_FUNCTION_RETURN}"


      # 1. Handles blank lines inside the block
      if [ "${trim_line}" = "" ]; then
        if [ "${current_block}" != "" ]; then
          # At the end of a paragraph, it always removes any trailing spaces or line
          # breaks.
          _shell_formatter_tools_trimR_line "${current_block}"
          block_paragraphs+=("${SHELL_FORMATTER_FUNCTION_RETURN}")
          block_paragraphs_indent+=("${raw_block_indent}")
        fi

        block_paragraphs+=("")
        block_paragraphs_indent+=("${raw_block_indent}")

        current_block=""
        is_list_item="0"
        continue
      fi


      # 2. Checks if the line is a horizontal content separator.
      if _shell_formatter_tools_is_separator "${trim_line}"; then
        if [ "${current_block}" != "" ]; then
          current_block+="${codeNL}"
        fi
        current_block+="${trim_line}${codeNL}"
        is_list_item="0"
        continue
      fi


      # 3. Checks for list item initialization every line from this point on is considered
      #    part of a list until a blank line is encountered.
      if _shell_formatter_tools_is_list_item "${raw_line}"; then
        is_list_item="1"

        # 2.2 Breaks paragraph block if a new list item starts
        if [ "${current_block}" != "" ]; then
          # At the end of a paragraph, it always removes any trailing spaces or line
          # breaks.
          _shell_formatter_tools_trimR_line "${current_block}"
          block_paragraphs+=("${SHELL_FORMATTER_FUNCTION_RETURN}")
          block_paragraphs_indent+=("${raw_block_indent}")

          current_block=""
        fi
      fi

      # 4. The first line retains its normal spacing on the left but has it removed
      #    on the right. The remaining lines lose all spacing at the beginning and
      #    end.
      if [ "${current_block}" = "" ]; then
        _shell_formatter_tools_trimR_line "${raw_line}"
        current_block+="${SHELL_FORMATTER_FUNCTION_RETURN}"
      else
        _shell_formatter_tools_trim_line "${raw_line}"
        current_block+=" ${SHELL_FORMATTER_FUNCTION_RETURN}"
      fi

      # 4.1 Re-adds the two spaces indicating a line break.
      if [[ "${raw_line}" == *"  " ]]; then
        current_block+="  ${codeNL}"
      fi
    done <<< "${raw_block}"


    # Push the remaining block content
    if [ "${current_block}" != "" ]; then
      # At the end of a paragraph, it always removes any trailing spaces or line
      # breaks.
      _shell_formatter_tools_trimR_line "${current_block}"
      block_paragraphs+=("${SHELL_FORMATTER_FUNCTION_RETURN}")
      block_paragraphs_indent+=("${raw_block_indent}")
    fi


    # Technical Anchor: Add a special block separator so the renderer knows  that
    # this specific block cluster ended
    block_paragraphs+=("__${SHELL_FORMATTER_BLOCK_MARKUP}_END_${i}__")
    block_paragraphs_indent+=("")
  done


  SHELL_FORMATTER_NORMALIZATED_BLOCKS=("${block_paragraphs[@]}")
  SHELL_FORMATTER_NORMALIZATED_BLOCKS_INDENT=("${block_paragraphs_indent[@]}")
}
