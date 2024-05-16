section .data
    Snippet db "KANGAROO", 0x0A
    SnippetLen equ $-Snippet
section .bss
section .text
    global _start
_start:
    mov rbp, rsp
    nop

    mov rbx, Snippet                  ; char* rbx = &Snippet
    mov rax, 8
DoMore: add byte [rbx], 32            ; rbx[0] = rbx[0] + 32 // convert Upper to Lower
    inc rbx                           ; move to rbx[1]
    dec rax
    jnz DoMore

    mov rax, 1
    mov rdi, 1
    mov rsi, Snippet
    mov rdx, SnippetLen
    syscall

    mov rax, 60
    mov rdi, 0
    syscall
