bits 64

%include "x86_64/defs.asm"

section .bss
    ; Resuable memblock to hold multiple values
    ; struct stat size chosen as min required
    internal_mem:        resb STAT_SIZE
    %define blocks_count [internal_mem]
    %define rem_size     [internal_mem + 8]
    %define st_mode      [internal_mem + ST_MODE_OFFSET]
    %define st_size      [internal_mem + ST_SIZE_OFFSET]


section .text
    global _start

_start:
    ; Move stack pointer to argv
    add rsp, 8

    ; Get file stat
    mov rax, sys_stat
    mov rdi, [rsp+8]              ; argv[1] - filename
    mov rsi, internal_mem
    syscall

    ; Check if no error
    test rax, rax
    jl err_exit

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
    write:
        mov rax, sys_write
        syscall
        ; Check if no error code
        test rax, rax
        js err_exit

        dec dword blocks_count
        cmp dword blocks_count, 0
        jne write

        ; Write remainder (if non-zero)
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


section .rodata
    ; Error messages
    err_msg:       db "Unable to write to file "
    err_msg_len:   equ $-err_msg

    newline:       db `\n`
