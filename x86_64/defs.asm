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

; mmap: flags
%define PROT_READ       1
%define MAP_PRIVATE     2
%define MAP_ANONYMOUS   32

; Errors
%define ENOENT          2
%define EACCES          13
%define EBUSY           16
%define EISDIR          21
%define ENFILE          23
%define ENAMETOOLONG    36

%define ENOENT_MSG       "No such file"
%define EACCES_MSG       "Permission denied"
%define EBUSY_MSG        "Is busy"
%define EISDIR_MSG       "Is a directory"
%define ENFILE_MSG       "System-wide open file limit reached"
%define ENAMETOOLONG_MSG "File name too long"

%define EUNEXPECT_MSG    "Unexpected error"

; internal mem: consts
%define INT_MEM_SIZE    114
%define B_COUNT_OFF     0
%define REM_SIZE_OFF    8
%define ST_MODE_OFF     24
%define ST_SIZE_OFF     48

; Linux memory page size
%define PAGE_SIZE       4096

; Heap buffer size for write (32kb)
%define BUF_SIZE        (PAGE_SIZE * 8)
