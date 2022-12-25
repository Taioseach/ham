; Syscalls
%define sys_read        0
%define sys_write       1
%define sys_open        2
%define sys_close       3
%define sys_mmap        9
%define sys_munmap      11
%define sys_exit        60

; IO
%define STDIN           0
%define STDOUT          1
%define STDERR          2

; Access modes
%define O_RDONLY        0
%define O_WRONLY        1

; Flags
%define O_CREAT         64
%define O_TRUNC         512

; mmap constants
%define PROT_READ       1
%define MAP_PRIVATE     2
%define MAP_ANONYMOUS   32

; Linux memory page size
%define PAGE_SIZE       4096
