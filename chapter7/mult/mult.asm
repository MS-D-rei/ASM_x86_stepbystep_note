section .data
section .bss
section .text
    global _start
_start:
    mov rbp, rsp 
    nop

    mov rax, 447
    mov rbx, 1739
    mul rbx

    mov rax, 1
    mov rdi, 1
    mov rsi, rbx
    mov rdx, 20
    syscall
    
    mov rax, 60
    mov rdi, 0
    syscall
