#!/usr/bin/env bash

# shell_formatter — The main orchestrator of the shell documentation and formatting
# pipeline.
# 
# Arguments:
# - target_file_path: The file system pathway pointing to the source script code
#   to be analyzed.
# - target_file_save: Optional. The target path where the formatted output will be
#   written. If omitted or empty, it defaults to rewriting the source file itself.
# - mantain_comments: Optional. Boolean-like flag (1 or 0) indicating whether text
#   comments should be normalized and preserved. Defaults to 1.
# - mantain_empty_lines: Optional. Boolean-like flag (1 or 0) indicating whether
#   empty lines should be maintained in the final layout. Defaults to 1.
# - soft_line_limit: Optional. The preferred maximum line length column width constraint
#   for comment wrapping. Defaults to 80.
# - hard_line_limit: Optional. The absolute maximum hard limit character column boundary
#   allowed for unbreakable tokens. Defaults to 120.
# 
# Returns:
# - Returns exit status 0 upon successful validation, paragraph wrapping, and document
#   compilation save operations.
# - Returns exit status 1 if input file validation checks fail or target files do
#   not match the expected criteria.
shell_formatter() {
  local target_file_path="${1}"
  local target_file_save="${2}"
  local mantain_comments="${3:-1}"
  local mantain_empty_lines="${4:-1}"
  local soft_line_limit="${5:-80}"
  local hard_line_limit="${4:-120}"


  _shell_formatter_tools_trim_line "${target_file_path}"
  target_file_path="${SHELL_FORMATTER_FUNCTION_RETURN}"

  _shell_formatter_tools_trim_line "${target_file_save}"
  target_file_save="${SHELL_FORMATTER_FUNCTION_RETURN}"

  if [ "${target_file_save}" = "" ]; then
    target_file_save="${target_file_path}"
  fi

  # Input parameters and file validation
  if [ ! -f "${target_file_path}" ]; then
    echo "[ x ] :: File does not exist: '${target_file_path}'"
    return 1
  fi
  if [[ "${target_file_path}" != *.sh ]]; then
    echo "[ x ] :: Not a *.sh file: '${target_file_path}'"
    return 1
  fi
  if [[ "${target_file_save}" != *.sh ]]; then
    target_file_save+=".sh"
  fi

  local file_content=$(< "${target_file_path}")

  # Evokes the data preparation parser function (Stage 1)
  shell_formatter_extract_document_data "${file_content}" "${mantain_comments}" "${mantain_empty_lines}"

  # STAGE_2: Parse comment blocks into atomic markdown-styled paragraphs
  if [ "${mantain_comments}" = "1" ] && [ "${#SHELL_FORMATTER_RAW_COMMENT_BLOCKS[@]}" -gt 0 ]; then
    shell_formatter_normalize_blocks \
      "SHELL_FORMATTER_RAW_COMMENT_BLOCKS" \
      "SHELL_FORMATTER_RAW_COMMENT_BLOCKS_INDENT"


    # STAGE_3: Formats the paragraph blocks so they are ready to be reinserted into
    #          the document. and restores the original indentation and comment markup
    shell_formatter_format_blocks \
      "SHELL_FORMATTER_NORMALIZATED_BLOCKS" \
      "SHELL_FORMATTER_NORMALIZATED_BLOCKS_INDENT" \
      "${soft_line_limit}" \
      "${hard_line_limit}" \
      "# "


    # STAGE_4:
    shell_formatter_apply_formatted_blocks \
      "${SHELL_FORMATTER_RAW_DOCUMENT}" \
      "SHELL_FORMATTER_FORMATTED_BLOCKS" \
      "__${SHELL_FORMATTER_BLOCK_MARKUP}_[idx]__" \
      "__${SHELL_FORMATTER_BLOCK_MARKUP}_END_[idx]__" \
      "${#SHELL_FORMATTER_RAW_COMMENT_BLOCKS[@]}"
  fi

  # _FINAL_ASSEMBLY_: Write the beautifully formatted stream to the target location.
  echo -n "${SHELL_FORMATTER_FINISHED_NEW_DOCUMENT}" > "${target_file_save}"
  return 0
}
