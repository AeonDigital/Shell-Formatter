#!/usr/bin/env bash

# ==============================================================================
# SINGLE-FILE DISTRIBUTION SHELL PACKAGE 
# 
# PROJECT     : Shell-Formatter  
# ORIGIN URL  : https://github.com/AeonDigital/Shell-Formatter  
# EXPORTED AT : 2026-08-20 23:34:21  
# LICENSE     : MIT [ https://github.com/AeonDigital/Shell-Formatter/LICENSE ]  
# ==============================================================================



if [ -z "${codeNL+x}" ]; then
declare -gr codeNL=$'\n'
fi
if [ -z "${SHELL_FORMATTER_BLOCK_MARKUP+x}" ]; then
declare -gr SHELL_FORMATTER_BLOCK_MARKUP="SHELL_FORMATTER_PLACEHOLDER_BLOCK"
fi
declare -g SHELL_FORMATTER_FUNCTION_RETURN=""
declare -g SHELL_FORMATTER_RAW_DOCUMENT=""
declare -ga SHELL_FORMATTER_RAW_COMMENT_BLOCKS=()
declare -ga SHELL_FORMATTER_RAW_COMMENT_BLOCKS_INDENT=()
declare -ga SHELL_FORMATTER_NORMALIZATED_BLOCKS=()
declare -ga SHELL_FORMATTER_NORMALIZATED_BLOCKS_INDENT=()
declare -ga SHELL_FORMATTER_FORMATTED_BLOCKS=()
declare -ga SHELL_FORMATTER_FORMATED_PARAGRAPH_LINES=()
declare -ga SHELL_FORMATTER_WRAPPED_PARAGRAPH_LINES=()
declare -g SHELL_FORMATTER_FINISHED_NEW_DOCUMENT=""
declare -g SHELL_FORMATTER_LINE_TYPE=""
declare -g SHELL_FORMATTER_REGISTER_RAW_LINE="0"
declare -g SHELL_FORMATTER_REGISTER_COMMENT_BLOCK="0"


_shell_formatter_tools_trim_line() {
local str="${1}"
str="${str#"${str%%[![:space:]]*}"}" # trim L
SHELL_FORMATTER_FUNCTION_RETURN="${str%"${str##*[![:space:]]}"}" # trim R
}
_shell_formatter_tools_trimL_line() {
local str="${1}"
SHELL_FORMATTER_FUNCTION_RETURN="${str#"${str%%[![:space:]]*}"}" # trim L
}
_shell_formatter_tools_trimR_line() {
local str="${1}"
SHELL_FORMATTER_FUNCTION_RETURN="${str%"${str##*[![:space:]]}"}" # trim R
}
_shell_formatter_tools_is_list_item() {
local str="${1}"
local rx_markdown="^([[:space:]]*)([-*+]|([0-9]+\.)+|[a-zA-Z][\.\)])[[:space:]]+"
local rx_custom_stage="^([[:space:]]*)[A-Z]+_[0-9.]+:([[:space:]]+|$)"
local rx_custom_tags="^([[:space:]]*)_[A-Z_]+_:[[:space:]]+"
if [[ "${str}" =~ ${rx_markdown} || "${str}" =~ ${rx_custom_stage} || "${str}" =~ ${rx_custom_tags} ]]; then
return 0
fi
return 1
}
_shell_formatter_tools_is_separator() {
local str="${1}"
if [ "${#str}" -lt "3" ]; then
return 1
fi
if [ "${str:0:1}" = " " ] || [ "${str:1:1}" = " " ]; then
return 1
fi
local separator_regex='^[-=*][-=*[:space:]]*$'
if [[ "${str}" =~ ${separator_regex} ]]; then
return 0
else
return 1
fi
}


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
comment_line_content="${trim_line:2}"
if [[ "${raw_line}" == *"  " ]]; then
comment_line_content+="  "
fi
comment_block_content+="${comment_line_content}"
;;
esac
done <<< "${file_content}"
if [ "${comment_block_open}" = "1" ]; then
comment_blocks["${block_idx}"]="${comment_block_content}"
comment_blocks_indents["${block_idx}"]="${comment_block_indent}"
file_new_content+="__${SHELL_FORMATTER_BLOCK_MARKUP}_${block_idx}__${codeNL}"
((block_idx++))
comment_block_open="0"
comment_block_indent=""
comment_block_content=""
fi
file_new_content="${file_shebang}${file_new_content}"
SHELL_FORMATTER_RAW_DOCUMENT="${file_new_content}"
SHELL_FORMATTER_RAW_COMMENT_BLOCKS=("${comment_blocks[@]}")
SHELL_FORMATTER_RAW_COMMENT_BLOCKS_INDENT=("${comment_blocks_indents[@]}")
}


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
while IFS= read -r raw_line || [ -n "${raw_line}" ]; do
_shell_formatter_tools_trim_line "${raw_line}"
trim_line="${SHELL_FORMATTER_FUNCTION_RETURN}"
if [ "${trim_line}" = "" ]; then
if [ "${current_block}" != "" ]; then
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
if _shell_formatter_tools_is_separator "${trim_line}"; then
if [ "${current_block}" != "" ]; then
current_block+="${codeNL}"
fi
current_block+="${trim_line}${codeNL}"
is_list_item="0"
continue
fi
if _shell_formatter_tools_is_list_item "${raw_line}"; then
is_list_item="1"
if [ "${current_block}" != "" ]; then
_shell_formatter_tools_trimR_line "${current_block}"
block_paragraphs+=("${SHELL_FORMATTER_FUNCTION_RETURN}")
block_paragraphs_indent+=("${raw_block_indent}")
current_block=""
fi
fi
if [ "${current_block}" = "" ]; then
_shell_formatter_tools_trimR_line "${raw_line}"
current_block+="${SHELL_FORMATTER_FUNCTION_RETURN}"
else
_shell_formatter_tools_trim_line "${raw_line}"
current_block+=" ${SHELL_FORMATTER_FUNCTION_RETURN}"
fi
if [[ "${raw_line}" == *"  " ]]; then
current_block+="  ${codeNL}"
fi
done <<< "${raw_block}"
if [ "${current_block}" != "" ]; then
_shell_formatter_tools_trimR_line "${current_block}"
block_paragraphs+=("${SHELL_FORMATTER_FUNCTION_RETURN}")
block_paragraphs_indent+=("${raw_block_indent}")
fi
block_paragraphs+=("__${SHELL_FORMATTER_BLOCK_MARKUP}_END_${i}__")
block_paragraphs_indent+=("")
done
SHELL_FORMATTER_NORMALIZATED_BLOCKS=("${block_paragraphs[@]}")
SHELL_FORMATTER_NORMALIZATED_BLOCKS_INDENT=("${block_paragraphs_indent[@]}")
}


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
block_indent="${blocks_indent["${i}"]}"
block_indent_length="${#block_indent}"
(( external_indent_length = block_indent_length + 2 ))
if [[ "${raw_paragraph}" = "" || "${raw_paragraph}" = "${codeNL}" ]]; then
formated_blocks+=("${block_indent}${use_prefix}${codeNL}")
continue
fi
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
SHELL_FORMATTER_FORMATTED_BLOCKS=("${formated_blocks[@]}")
}


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
if [ "${indent_line_other_length}" -gt "0" ]; then
indent_line_one+="${indent_line_other}"
indent_line_one_length="${#indent_line_one}"
(( indent_line_one_length += external_indent_length ))
indent_line_other=""
indent_line_other_length="0"
fi
fi
raw_paragraph_line_ends_with_2_spaces="0"
if [[ "${raw_paragraph_line}" == *"  " ]]; then
raw_paragraph_line_ends_with_2_spaces="1"
fi
_shell_formatter_tools_trim_line "${raw_paragraph_line}"
raw_paragraph_line="${SHELL_FORMATTER_FUNCTION_RETURN}"
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
if [ "${i}" -gt "0" ] && [ "${indent_line_other}" != "" ]; then
use_line_indent+="${indent_line_other}"
indent_line_other=""
fi
if [ "${i}" = "${last_line_idx}" ] && [ "${raw_paragraph_line_ends_with_2_spaces}" = "1" ]; then
line+="  "
fi
formatted_paragraph_lines+=("${use_line_indent}${line}")
done
done <<< "${raw_paragraph}"
SHELL_FORMATTER_FORMATED_PARAGRAPH_LINES=("${formatted_paragraph_lines[@]}")
}


shell_formatter_wrap_lines_by_limit_range() {
SHELL_FORMATTER_WRAPPED_PARAGRAPH_LINES=()
local -a wrapped_paragraph_lines=()
local raw_line="${1}"
local soft_line_limit="${2}"
local hard_line_limit="${3}"
local indent_line_one_length="${4}"
local indent_line_other_length="${5}"
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
if [ "${#wrapped_paragraph_lines[@]}" -gt "0" ] && [ "${indent_line_other_length}" -gt "0" ]; then
(( min_break_point -= indent_line_other_length ))
(( max_break_point -= indent_line_other_length ))
indent_line_other_length="0"
fi
if [ "${#scan_line}" -le "${min_break_point}" ]; then
wrapped_paragraph_lines+=("${scan_line}")
break
fi
pos="${min_break_point}"
tmp_line="${scan_line:0:${pos}}"
char="${scan_line:${pos}:1}"
while [ "${char}" != " " ] && [ "${char}" != "" ]; do
tmp_line+="${char}"
((pos++))
char="${scan_line:${pos}:1}"
done
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
((cut_pos = pos + 1))
scan_line="${scan_line:${cut_pos}}"
done
SHELL_FORMATTER_WRAPPED_PARAGRAPH_LINES=("${wrapped_paragraph_lines[@]}")
}


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
shell_formatter_extract_document_data "${file_content}" "${mantain_comments}" "${mantain_empty_lines}"
if [ "${mantain_comments}" = "1" ] && [ "${#SHELL_FORMATTER_RAW_COMMENT_BLOCKS[@]}" -gt 0 ]; then
shell_formatter_normalize_blocks \
"SHELL_FORMATTER_RAW_COMMENT_BLOCKS" \
"SHELL_FORMATTER_RAW_COMMENT_BLOCKS_INDENT"
shell_formatter_format_blocks \
"SHELL_FORMATTER_NORMALIZATED_BLOCKS" \
"SHELL_FORMATTER_NORMALIZATED_BLOCKS_INDENT" \
"${soft_line_limit}" \
"${hard_line_limit}" \
"# "
shell_formatter_apply_formatted_blocks \
"${SHELL_FORMATTER_RAW_DOCUMENT}" \
"SHELL_FORMATTER_FORMATTED_BLOCKS" \
"__${SHELL_FORMATTER_BLOCK_MARKUP}_[idx]__" \
"__${SHELL_FORMATTER_BLOCK_MARKUP}_END_[idx]__" \
"${#SHELL_FORMATTER_RAW_COMMENT_BLOCKS[@]}"
fi
echo -n "${SHELL_FORMATTER_FINISHED_NEW_DOCUMENT}" > "${target_file_save}"
return 0
}


if [ "${BASH_SOURCE}" = "${0}" ]; then
for arg in "$@"; do
if [[ "${arg}" == -* ]]; then
case ${arg} in
-h|--help)
shell_formatter_help
exit $?
;;
esac
fi
done
shell_formatter "$@"
fi
