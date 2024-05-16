;  Executable name        :  EATSYSCALL
;  Version                :  1.0
;  Created date           :  21/04/2024
;  Last update            :  21/04/2024
;  Author                 :  MS-D-rei
;  Architecture           :  x64
;  From                   :  Assembly Lang Step By Step, 4th
;  Description            :  A simple program in assembly for x64 linux
;  to display text, using NASM
;
;  Build using these commands:
;  nasm -f elf64 -g -F dwarf eatsyscall.asm
;  ld -o eatsyscall eatsyscall.o
;
SECTION .data             ;  Section containing initialized data
    Msg db "Hello world!", 0x0A
    MsgLen equ $-Msg
SECTION .bss
SECTION .text
    global _start
_start:
    mov rbp, rsp          ;  Save stack pointer register RSP to RBP for debugging
    nop                   ;  This no-op keeps gdb happy
    mov rax, 1            ;  1 = sys_write for syscall
    mov rdi, 1            ;  1 = fd for stdout
    mov rsi, Msg          ;  Put address of the message string in rsi
    mov rdx, MsgLen       ;  Length of the string to be written in rdx
    syscall               ;  Make thhe system call
    mov rax, 60           ;  60 = exit the program
    mov rdi, 0            ;  Return value in rdi 0 = nothing to return
    syscall               ;  Call syscall to exit
