; How to run
; hexdump1 < <input file>

section .bss
    BuffLen equ 16
    Buff resb BuffLen

section .data
    HexStr db " 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00", 0x0A
    HexLen equ $-HexStr
    Digits db "0123456789ABCDEF"

section .text
    global _start

_start:
    mov rbp, rsp

; Read a buffer full of text from stdin.
Read:
    mov rax, 0                      ; 0 = sys_read.
    mov rdi, 0                      ; File descriptor.
    mov rsi, Buff                   ; Address of buf.
    mov rdx, Buff                   ; Length of buf.
    syscall
    mov r15, rax                    ; preserve the length of the content stdin read.
    cmp rax, 0                      ; if rax = 0
    je Done

    ; 
    mov rsi, Buff
    mov rdi, HexStr
    xor rcx, rcx

Scan:
    xor rax, rax                    ; clear rax to 0

    mov rdx, rcx 
;    shl rdx, 1
;    add rdx, rcx
    lea rdx, [rdx*2+rdx]

    mov al, byte [rsi+rcx]
    mov rbx, rax

    and al, 0Fh
    mov al, byte [Digits+rax]
    mov byte [HexStr+rdx+2], al

    shr bl, 4
    mov bl, byte [Digits+rbx]
    mov byte [HexStr+rdx+1], bl

    inc rcx
    cmp rcx, r15
    jna Scan                         ; Jump if not above (rcx <= r15)

    mov rax, 1
    mov rdi, 1
    mov rsi, HexStr
    mov rdx, HexLen
    syscall
    jmp Read

Done:
    mov rax, 60
    mov rdi, 0
    syscall
