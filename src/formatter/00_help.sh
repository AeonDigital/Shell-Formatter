#!/usr/bin/env bash

# shell_formatter_help — Display the CLI manual and usage guide for the shell_formatter
# function.
# 
# Returns:
# - Outputs the formatted manual text to stdout.
shell_formatter_help() {
  local msg=""

  msg+="NAME${codeNL}"
  msg+="  shell_formatter - Stream-based block parser and text layout restructuring engine${codeNL}${codeNL}"

  msg+="SUMMARY${codeNL}"
  msg+="  shell_formatter <target_file_path> [target_file_save] [mantain_comments] [mantain_empty_lines] [soft_line_limit] [hard_line_limit]${codeNL}${codeNL}"

  msg+="DESCRIPTION${codeNL}"
  msg+="  Parses an input shell document to segregate logic pathways from literal metadata chunks.${codeNL}"
  msg+="  It isolates continuous paragraphs, preserves custom block markers (such as specialized stages,${codeNL}"
  msg+="  tags, and sub-level numeric markdown items), and dynamically reorganizes sentences against${codeNL}"
  msg+="  configurable soft and hard line limits. Once formatted, it reconstructs the original visual${codeNL}"
  msg+="  indentation layout and flushes the compiled content to the target file pathway.${codeNL}${codeNL}"

  msg+="ARGUMENTS${codeNL}"
  msg+="  \$1  target_file_path     The file system pathway pointing to the source script context to${codeNL}"
  msg+="                            be processed. Must possess a valid '.sh' extension.${codeNL}"
  msg+="                            * Required.${codeNL}${codeNL}"
  msg+="  \$2  target_file_save     Optional. The file system destination path where the beautifully${codeNL}"
  msg+="                            formatted stream will be written. If omitted, empty, or missing${codeNL}"
  msg+="                            the extension, it defaults to overwriting the input file context.${codeNL}${codeNL}"
  msg+="  \$3  mantain_comments     Optional. Integer boolean flag (1 or 0) indicating whether specific${codeNL}"
  msg+="                            extracted block elements should be processed and preserved.${codeNL}"
  msg+="                            * Defaults to 1.${codeNL}${codeNL}"
  msg+="  \$4  mantain_empty_lines  Optional. Integer boolean flag (1 or 0) indicating whether structural${codeNL}"
  msg+="                            whitespace gap spacing should remain in the skeleton output stream.${codeNL}"
  msg+="                            * Defaults to 1.${codeNL}${codeNL}"
  msg+="  \$5  soft_line_limit      Optional. Integer value representing the ideal column line width${codeNL}"
  msg+="                            before forcing natural text word wrapping transitions.${codeNL}"
  msg+="                            * Defaults to 80.${codeNL}${codeNL}"
  msg+="  \$6  hard_line_limit      Optional. Integer ceiling constraint establishing the absolute maximum${codeNL}"
  msg+="                            horizontal width allowed for continuous or long tokens.${codeNL}"
  msg+="                            * Defaults to 120.${codeNL}${codeNL}"

  msg+="RETURN CODES${codeNL}"
  msg+="  0   Success               The document stream was successfully validated, wrapped, and compiled.${codeNL}"
  msg+="  1   Failure               Process aborted due to missing targets, invalid extensions, or runtime crashes.${codeNL}${codeNL}"

  msg+="EXAMPLES${codeNL}"
  msg+="  Standard document optimization overwriting the source script context file:${codeNL}"
  msg+="      shell_formatter \"myscript.sh\"${codeNL}${codeNL}"
  msg+="  Layout compilation directing the stream results into a separate output with custom limits:${codeNL}"
  msg+="      shell_formatter \"myscript.sh\" \"output.sh\" 1 1 90 140${codeNL}${codeNL}"
  msg+="  Aggressive code extraction stripping out all comment block entities from the final assembly:${codeNL}"
  msg+="      shell_formatter \"myscript.sh\" \"stripped_code.sh\" 0 1${codeNL}"

  echo -e "${msg}"
}
