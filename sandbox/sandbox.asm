SECTION .data
    Msg db "Hello, world!", 0x0A      ; 0x0A = LineFeed
    MsgLen equ $-Msg
SECTION .bss
SECTION .text
    global _start
_start:
    mov rbp, rsp
    nop
    mov rax, 1
    mov rdi, 1
    ; size specifier tells NASM the size of source
    ; mov(copy) "A" to the content of the address of Msg
    ; (in this case, H)
    ; as a result, Msg content will be "Aello, world!"
    ; mov byte [Msg], "A"
    mov rsi, Msg
    mov rdx, MsgLen
    syscall

    xor rax, rax
    xor rcx, rcx
    inc rcx
    lea rcx, [rcx*2+rcx]
    mov al, byte [Msg+rcx]

Exit:
    mov rax, 60
    mov rdi, 0
    syscall
