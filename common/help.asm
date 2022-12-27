%ifndef COMMON_HELP
%define COMMON_HELP

; Help message
help_msg:     db `Usage: ham FILE\n`
help_msg_len: equ $-help_msg

%endif ; COMMON_HELP