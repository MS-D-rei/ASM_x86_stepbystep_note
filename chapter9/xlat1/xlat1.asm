; How to run
; ./xlat1 < <input-file> > <output-file>

section .bss
    ReadBufferLen equ 1024
    ReadBuffer resb ReadBufferLen

section .data
    StatMsg db "Processing...", 0x0A
    StatMsgLen equ $-StatMsg
    DoneMsg db "...done!", 0x0A
    DoneMsgLen equ $-DoneMsg

    UpCase:
    ;                 |               |               |
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,09h,0Ah,20h,20h,20h,20h,20h
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
    db 20h,21h,22h,23h,24h,25h,26h,27h,28h,29h,2Ah,2Bh,2Ch,2Dh,2Eh,2Fh
    db 30h,31h,32h,33h,34h,35h,36h,37h,38h,39h,3Ah,3Bh,3Ch,3Dh,3Eh,3Fh; ___ 0,1,2,3,4,...?
    db 40h,41h,42h,43h,44h,45h,46h,47h,48h,49h,4Ah,4Bh,4Ch,4Dh,4Eh,4Fh;     @,A,B,C,D,...O 
    db 50h,51h,52h,53h,54h,55h,56h,57h,58h,59h,5Ah,5Bh,5Ch,5Dh,5Eh,5Fh;     P,Q,R,S,T,..._
    db 60h,41h,42h,43h,44h,45h,46h,47h,48h,49h,4Ah,4Bh,4Ch,4Dh,4Eh,4Fh;     `,A,B,C,D,...O // This line and next one converts to uppercase
    db 50h,51h,52h,53h,54h,55h,56h,57h,58h,59h,5Ah,7Bh,7Ch,7Dh,7Eh,20h; ___ P,Q,R,...Z,{,|,},~
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h; _
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h
    db 20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h,20h

section .text
    global _start

_start:
    mov rbp, rsp

    ; Display start message
    mov rax, 1                       ; sys_write
    mov rdi, 2                       ; File descriptor 2, standard error
    mov rsi, StatMsg
    mov rdx, StatMsgLen
    syscall

; Read the content of input file
read:
    mov rax, 0                       ; sys_read
    mov rdi, 0                       ; File descriptor 0, standard input
    mov rsi, ReadBuffer
    mov rdx, ReadBufferLen
    syscall
    
    mov rbp, rax                     ; Preserve the number of chars stdin read
    cmp rax, 0                       ; if sys_read returns 0
    je done

    ; Set up the registers for the translate step
    mov rbx, UpCase                  ; For xlat, put the address of the table into rbx 
    mov rdx, ReadBuffer
    mov rcx, rbp                     ; Copy the return of sys_read

; Translate all chars in the buffer with the table and xlat
translate:
    xor rax, rax                     ; rax = 0
    mov al, byte [rdx-1+rcx]         ; Load char into AL for translation
    xlat                             ; Translate the char, mov al, byte [rbx(UpCase)+al]
    mov byte [rdx-1+rcx], al         ; Replace with the translated char
    dec rcx                          ; Decrement rcx as the index
    jnz translate                    ; Loop until the index is 0

; After translation, write the buffer
write:
    mov rax, 1
    mov rdi, 1                       ; File descriptor 1, standard output
    mov rsi, ReadBuffer
    mov rdx, rbp                     ; rbp has the number of chars stdin read
    syscall
    jmp read

done:
    mov rax, 1
    mov rdi, 2
    mov rsi, DoneMsg
    mov rdx, DoneMsgLen
    syscall

    mov rax, 60
    mov rdi, 0
    syscall
