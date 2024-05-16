; Executable name           : eatterm
; Version                   :
; Created date              : 2024-05-16
; Last update               : 2024-05-16
; Author                    : MS-D-rei
; Description
; How to build
; nasm -f elf64 -g -F dwarf eatterm.asm
; ld -o eatterm eatterm.o eattermlib.o

section .data
section .bss
section .text

    EXTERN PosTerm, ClearTerm, AdMessage, PromptMessage
    EXTERN ClearScreen, GotoXY, WriteString, WriteStringCentered
    EXTERN g_AdMessageLength, g_PromptMessageLength

;--------------------------------------------------------------------------------

global _start

_start:
    push rbp                 ; Prolog
    mov rbp, rsp             ; For debugging

    call ClearScreen

    ; Post ad message on the 80 chars wide console
    xor rax, rax
    mov al, 12
    mov rsi, AdMessage
    mov rdx, g_AdMessageLength
    call WriteStringCentered

    ; Position the cursor for the "Press Enter" prompt
    mov rax, 0117h           ; X, Y = 1, 23 as a single hex value
    call GotoXY

    ; Display "Press Enter" prompt
    mov rsi, PromptMessage
    mov rdx, g_PromptMessageLength
    call WriteString

    ; Wait for the user to press Enter
    mov rax, 0               ; sys_read
    mov rdi, 0               ; File Descriptor 0 = stdin
    syscall

Exit:
    pop rbp
    mov rax, 60
    mov rdi, 0
    syscall
