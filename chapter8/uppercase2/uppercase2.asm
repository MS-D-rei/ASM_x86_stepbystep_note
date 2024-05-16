; Executable name : uppercase2
; How to run:
; ./uppercase2 < (input-file) > (output-file)

section .bss
    BuffLen equ 128
    Buff resb BuffLen

section .data

section .text
    global _start

_start:
    mov rbp, rsp

Read:
    mov rax, 0
    mov rdi, 0
    mov rsi, Buff
    mov rdx, BuffLen
    syscall                        ; Return the number read to buffer to rax
    mov r12, rax                   ; Preserve the number of chars to write later
    cmp rax, 0
    je Done

    mov rbx, rax                   ; Copy the number of chars to rbx
    mov r13, Buff                  ; Copy the first address of Buff to r13
    dec rbx                        ; rbx -1 to use rbx as address offset

Scan:
    cmp byte [r13+rbx], 61h
    jb Next
    cmp byte [r13+rbx], 7Ah
    ja Next

    sub byte [r13+rbx], 20h

Next:
    dec rbx
    cmp rbx, -1                    ; This needs to be -1 because [r13 + 0] contains the first char needed to be converted
    jnz Scan                       ; Jump not zero (when the Zero flag is not set)

Write:
    mov rax, 1
    mov rdi, 1
    mov rsi, Buff
    mov rdx, r12
    syscall
    jmp Read

Done:
    mov rax, 60
    mov rdi, 0
    syscall
