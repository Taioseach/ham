bits 64

%include "common.asm"

section .text
global _start
_start:
    ; Move stack pointer to argv
    add rsp, 8

    ; Open file to overwrite
    mov rax, sys_open
    mov rdi, [rsp+8]              ; argv[1]
    mov rsi, O_WRONLY
    mov rdx, 0o600
    syscall

    ; Check if fd < 0
    test rax, rax
    jl err_exit

    ; Backup fd
    push rax

    ; Allocate null bytes buffer
    mov rax, sys_mmap
    xor rdi, rdi                  ; NULL
    mov rsi, BUFSIZE
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
    mov rdx, BUFSIZE
    pop rdi                       ; fd to write
    write:
        mov rax, sys_write
        syscall

        ; Check if no error code
        test rax, rax
        js err_exit

        dec dword [block_counter]
        cmp dword [block_counter], 0
        jne write

    ; Deallocate buffer
    mov rdx, rdi                  ; backup fd
    mov rdi, rsi
    mov rsi, BUFSIZE
    mov rax, sys_munmap
    syscall

    ; Close and exit
    mov rax, sys_close
    mov rdi, rdx
    syscall
    mov rax, sys_exit
    mov rdi, 0
    syscall


err_exit:
    mov rax, sys_write
    mov rdi, STDERR
    mov rsi, err_msg
    mov rdx, err_msg_len
    syscall

    mov rax, sys_write
    mov rsi, [rsp+8]
    mov r8, [rsp+8]
    arg_len:
        ; Calc filename len
        inc r8
        cmp byte [r8], 0
        jnz arg_len
    mov rdx, r8
    sub rdx, [rsp+8]
    syscall

    mov rax, sys_write
    mov rsi, newline
    mov rdx, 1
    syscall

    mov rax, sys_exit
    mov rdi, 1
    syscall


section .data
    block_counter: dd 131072


section .rodata
    ; Error messages
    err_msg:       db "Unable to write to file"
    err_msg_len:   equ $-err_msg

    newline:       db `\n`

