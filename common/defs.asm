%ifndef COMMON_DEFS
%define COMMON_DEFS

; IO: std
%define STDOUT            1
%define STDERR            2

; IO: access modes
%define O_RDONLY          0
%define O_WRONLY          1

; IO: flags
%define O_CREAT           64
%define O_TRUNC           512

; mmap: protection flags
%define PROT_READ         1
%define PROT_WRITE        2

; mmap: flags
%define MAP_PRIVATE       2
%define MAP_ANONYMOUS     32

; Errors
%define ENOENT            2
%define EACCES            13
%define EBUSY             16
%define EISDIR            21
%define ENFILE            23
%define ENAMETOOLONG      36

%define EPRE_MSG          ": Failed to overwrite file - "

%define ENOENT_MSG        "No such file"
%define EACCES_MSG        "Permission denied"
%define EBUSY_MSG         "Is busy"
%define EISDIR_MSG        "Is a directory"
%define ENFILE_MSG        "System-wide open file limit reached"
%define ENAMETOOLONG_MSG  "File name too long"

%define EUNEXPECT_MSG     "Unexpected error"

; Clock: constants
%define CLOCK_REALTIME    0

%endif ; COMMON_DEFS