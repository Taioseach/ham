%ifndef COMMON_ERR_TABLE
%define COMMON_ERR_TABLE

%include "common/defs.asm"

; Error messages
err_pre_msg:        db EPRE_MSG
err_pre_msg_len:    equ $-err_pre_msg

; Error msg table
err_msgs_table:
    enoent_msg:           db ENOENT_MSG
    enoent_msg_len:       equ $-enoent_msg
    eacces_msg:           db EACCES_MSG
    eacces_msg_len:       equ $-eacces_msg
    ebusy_msg:            db EBUSY_MSG
    ebusy_msg_len:        equ $-ebusy_msg
    eisdir_msg:           db EISDIR_MSG
    eisdir_msg_len:       equ $-eisdir_msg
    enfile_msg:           db ENFILE_MSG
    enfile_msg_len:       equ $-enfile_msg
    enametoolong_msg:     db ENAMETOOLONG_MSG
    enametoolong_msg_len: equ $-enametoolong_msg
    eunexpect:            db EUNEXPECT_MSG
    eunexpect_len:        equ $-eunexpect

; Error lookup table
; fmt: <byte: err code>, <byte: err msg len>, <quad: err msg addr> = 10 bytes
err_lookup_row_len: equ 10
err_lookup_table:
    db ENOENT, enoent_msg_len
    dq enoent_msg
    db EACCES, eacces_msg_len
    dq eacces_msg
    db EBUSY, ebusy_msg_len
    dq ebusy_msg
    db EISDIR, eisdir_msg_len
    dq eisdir_msg
    db ENFILE, enfile_msg_len
    dq enfile_msg
    db ENAMETOOLONG, enametoolong_msg_len
    dq enametoolong_msg
err_lookup_table_end:
    db 0, eunexpect_len
    dq eunexpect

%endif ; COMMON_ERR_TABLE