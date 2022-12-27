bits 64

%include "common/defs.asm"
%include "x86_64/defs.asm"

section .bss
    ; Resuable memblock to hold multiple values
    ; struct stat size chosen as min required
    internal_mem:        resb INT_MEM_SIZE
    %define blocks_count internal_mem + B_COUNT_OFF
    %define rem_size     internal_mem + REM_SIZE_OFF
    %define st_mode      internal_mem + ST_MODE_OFF
    %define st_size      internal_mem + ST_SIZE_OFF
    %define timespec     internal_mem + TIMESPEC_OFF
    %define tv_nsec      internal_mem + TV_NSEC_OFF


section .text
    global _start

; Filling buffer with Lehmer RNG
; assert rsi holds buffer ptr
; assert r8 holds LEHMER_MUL
%macro lehmer_fill 1
    ; Setup Lehmer RNG
    mov r9, rsi               ; buffer[i]
    mov r10, rsi              ; Lehmer loop terminator
    add r10, %1
    ; Load last value from buffer[BUF_SIZE - 1]
    mov rax, qword [rsi + BUF_SIZE - 8]
    xor rdx, rdx
    ; Fill buffer with Lehmer RNG
    %%lehmer:
        mov rbx, rdx
        mul r8
        imul rbx, r8
        add rbx, rdx
        mov qword [r9], rdx
        mov rdx, rbx
        add r9, 8
        cmp r9, r10
        jl %%lehmer
%endmacro

_start:
    ; Check if argc < 2 (if so, exit)
    mov rdi, [rsp]
    cmp rdi, 2
    jl help

    ; Get file stat
    mov rax, sys_stat
    mov rdi, [rsp+16]             ; argv[1] - filename
    mov rsi, internal_mem
    syscall

    ; Check if no error
    test rax, rax
    jl err_exit
    ; Check if size not empty (if so, exit)
    cmp qword [st_size], 0
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
    mov rax, [st_size]
    xor rdx, rdx
    mov rbx, BUF_SIZE
    div rbx
    mov [blocks_count], rax
    mov [rem_size], rdx

    ; Allocate buffer
    mov rax, sys_mmap
    xor rdi, rdi                  ; NULL
    mov rsi, BUF_SIZE
    mov rdx, PROT_READ | PROT_WRITE
    mov r10, MAP_PRIVATE | MAP_ANONYMOUS
    mov r8, -1,                   ; no fd (required)
    xor r9, r9
    syscall

    ; Check if memory allocated
    test rax, rax
    jl err_exit

    ; Backup buffer ptr
    push rax

    ; Setup Lehmer RNG init state
    ; Init 64 bytes == nanoseconds from current time
    mov rax, sys_clock_gettime
    mov rdi, CLOCK_REALTIME
    mov rsi, timespec
    syscall
    mov rax, [tv_nsec]
    or rax, 1                     ; ensure seed is odd
    pop rsi                       ; buffer ptr
    mov [rsi + BUF_SIZE - 8], rax ; save in end of buffer (reinitialized later)

    ; Write
    pop rdi                       ; fd to write
    ; rsi with buffer ptr set above
    mov r8, LEHMER_MUL            ; Lehmer multiplier
    ; check if invoke block write
    cmp qword [blocks_count], 0
    je rem_write
    write:
        ; Fill buffer for block write
        lehmer_fill BUF_SIZE

        mov rax, sys_write
        mov rdx, BUF_SIZE
        syscall
        ; Check if no error code
        test rax, rax
        js err_exit

        dec qword [blocks_count]
        cmp qword [blocks_count], 0
        jne write

        ; Write remainder (if non-zero)
        rem_write:
        mov rcx, [rem_size]
        test rcx, rcx
        jz end_write
        ; Fill buffer for remainder write
        lehmer_fill [rem_size]
        mov rax, sys_write
        mov rdx, rcx
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

help:
    mov rax, sys_write
    mov rdi, STDOUT
    mov rsi, help_msg
    mov rdx, help_msg_len
    syscall

    mov rax, sys_exit
    mov rdi, 0
    syscall


section .rodata
    %include "common/err_table.asm"

    ; Other const strings/chars
    help_msg:     db `Usage: ham FILE\n`
    help_msg_len: equ $-help_msg
    newline:      db `\n`
