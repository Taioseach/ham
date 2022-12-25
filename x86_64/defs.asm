; Syscalls
%define sys_read        0
%define sys_write       1
%define sys_open        2
%define sys_close       3
%define sys_stat        4
%define sys_mmap        9
%define sys_munmap      11
%define sys_exit        60

; IO: std
%define STDOUT          1
%define STDERR          2

; IO: access modes
%define O_RDONLY        0
%define O_WRONLY        1

; IO: flags
%define O_CREAT         64
%define O_TRUNC         512

; IO: error codes
;%define 

; mmap: flags
%define PROT_READ       1
%define MAP_PRIVATE     2
%define MAP_ANONYMOUS   32

; struct stat: consts
%define STAT_SIZE       114
%define ST_MODE_OFFSET  24
%define ST_SIZE_OFFSET  48

; Linux memory page size
%define PAGE_SIZE       4096

; Heap buffer size for write (32kb)
%define BUF_SIZE        (PAGE_SIZE * 8)
