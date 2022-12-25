bits 64

%include "x86_64/defs.asm"

section .bss
    ; Resuable memblock to hold multiple values
    ; struct stat size chosen as min required
    internal_mem:        resb INT_MEM_SIZE
    %define blocks_count [internal_mem + B_COUNT_OFF]
    %define rem_size     [internal_mem + REM_SIZE_OFF]
    %define st_mode      [internal_mem + ST_MODE_OFF]
    %define st_size      [internal_mem + ST_SIZE_OFF]


section .text
    global _start

_start:
    ; Check if argc < 2 (if so, exit)
    mov rdi, [rsp]
    cmp rdi, 2
    jl exit

    ; Get file stat
    mov rax, sys_stat
    mov rdi, [rsp+16]             ; argv[1] - filename
    mov rsi, internal_mem
    syscall

    ; Check if no error
    test rax, rax
    jl err_exit
    ; Check if size not empty (if so, exit)
    cmp qword st_size, 0
    jz exit

    ; Open file to overwrite
    mov rax, sys_open
    ; rdi skipped, setup in sys_stat
    mov rsi, O_WRONLY
    mov rdx, 0o600
    syscall

    ; Check if fd < 0
    test rax, rax
    jl err_exit

    ; Backup fd
    push rax

    ; Setup block counter
    mov rax, st_size
    xor rdx, rdx
    mov rbx, BUF_SIZE
    div rbx
    mov blocks_count, rax
    mov rem_size, rdx

    ; Allocate null bytes buffer
    mov rax, sys_mmap
    xor rdi, rdi                  ; NULL
    mov rsi, BUF_SIZE
    mov rdx, PROT_READ
    mov r10, MAP_PRIVATE | MAP_ANONYMOUS
    mov r8, -1,                   ; no fd (required)
    xor r9, r9
    syscall

    ; Check if memory allocated
    test rax, rax
    jl err_exit

    ; Write
    mov rsi, rax                  ; null buffer ptr
    mov rdx, BUF_SIZE
    pop rdi                       ; fd to write
    cmp qword blocks_count, 0     ; check if invoke block write
    je rem_write
    write:
        mov rax, sys_write
        syscall
        ; Check if no error code
        test rax, rax
        js err_exit

        dec qword blocks_count
        cmp qword blocks_count, 0
        jne write

        ; Write remainder (if non-zero)
        rem_write:
        mov rdx, rem_size
        test rdx, rdx
        jz end_write
        mov rax, sys_write
        syscall
        ; Check if no error code
        test rax, rax
        js err_exit
    end_write:

    ; Deallocate buffer
    mov rdx, rdi                  ; backup fd
    mov rdi, rsi
    mov rsi, BUF_SIZE
    mov rax, sys_munmap
    syscall

    ; Close file
    mov rax, sys_close
    mov rdi, rdx
    syscall
    ; Exit
exit:
    mov rax, sys_exit
    mov rdi, 0
    syscall


err_exit:
    ; Backup errno
    mov r10, rax
    neg r10

    ; Write filename
    mov rax, sys_write
    mov rdi, STDERR
    mov rsi, [rsp+16]
    mov rdx, rsi
    fname_len:
        inc rdx
        mov bl, byte[rdx]
        cmp bl, 0
        jne fname_len
    sub rdx, rsi
    syscall

    ; Write err message preamble
    mov rax, sys_write
    mov rsi, err_pre_msg
    mov rdx, err_pre_msg_len
    syscall

    ; Write specific error message
    mov rax, sys_write
    mov r9, err_lookup_table
    err_lookup:
        ; Linear search in error lookup table
        cmp byte[r9], r10b
        je end_err_lookup
        add r9, err_lookup_row_len
        cmp r9, err_lookup_table_end
        jne err_lookup
    end_err_lookup:
    mov rsi, [r9+2]
    mov dl, [r9+1]
    syscall

    ; Newline
    mov rax, sys_write
    mov rsi, newline
    mov rdx, 1
    syscall

    mov rax, sys_exit
    mov rdi, 1
    syscall


section .rodata
    ; Error messages
    err_pre_msg:        db ": Failed to overwrite file - "
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

    ; Other const strings/chars
    newline: db `\n`
