; How to build
; nasm -f elf64 -g -F dwarf hexdump3.asm
; ld -o hexdump3 hexdump3.o <path>/textlib.o

section .bss
section .data
section .text

EXTERN ClearLine, DumpChar, LoadBuff, PrintLine
EXTERN Buff, BuffLen

global _start

_start:
    push rbp
    mov rbp, rsp

    xor r15, r15
    xor rsi, rsi
    xor rcx, rcx
    call LoadBuff
    cmp r15, 0                           ; If stdin read 0 chars.
    jbe Exit

Scan:
    xor rax, rax
    mov al, [Buff+rcx]
    mov rdx, rsi                         ; As first attempt, rsi == 0
    and rdx, 000000000000000Fh           ; Mask out to get only least significant 4 bit. rdx could be 0 to 15.
    call DumpChar                        ; Dump the content of al to DumpLine.

    inc rsi                              ; As first attempt rsi == 0 and now 1. 
    inc rcx                              ; As first attempt rcx == 0 and now 1. 
    cmp rcx, r15                         ; r15 has the number of chars stdin read.
    jb .modTest                          ; Jump if rcx(counter) < r15. Loop while process all of buffer content.
    call LoadBuff                        ; After finished processing all the current buffer content, read next.
    cmp r15, 0                           ; If stdin read 0 chars
    jbe Done

.modTest:
    test rsi, 000000000000000Fh          ; and rsi, 0x0Fh, if rsi = 16, Zero Flag is set to 1.
    jnz Scan                             ; If ZF is not set 1, jump to Scan.
    call PrintLine                       ; Print DumpLine and AscLine.
    call ClearLine                       ; Clear DumpLine and AscLine to initial state.
    jmp Scan                             ; Go to next line of DumpLine and AscLine.

Done:
    call PrintLine

Exit:
    mov rsp, rbp
    pop rbp
    
    mov rax, 60
    mov rdi, 0
    syscall
