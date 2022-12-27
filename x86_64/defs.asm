%ifndef X86_64_DEFS
%define X86_64_DEFS

; Syscalls
%define sys_read           0
%define sys_write          1
%define sys_open           2
%define sys_close          3
%define sys_stat           4
%define sys_mmap           9
%define sys_munmap         11
%define sys_exit           60
%define sys_clock_gettime  228

; internal mem: consts
%define INT_MEM_SIZE       114
%define B_COUNT_OFF        0
%define REM_SIZE_OFF       8
%define ST_MODE_OFF        24
%define ST_SIZE_OFF        48
%define TIMESPEC_OFF       56
%define TV_NSEC_OFF        64

; Linux memory page size
%define PAGE_SIZE          4096

; Heap buffer size for write (32kb)
%define BUF_SIZE           (PAGE_SIZE * 8)

; Lehmer RNG multiplier
%define LEHMER_MUL         -2696494805208442699

%endif ; X86_64_DEFS