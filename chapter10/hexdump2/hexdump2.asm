section .bss
    BuffLen equ 10h
    Buff: resb BuffLen

section .data
    DumpLine: db " 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
    DumpLineLen equ $-DumpLine
    AscLine: db "|................|", 0x0A
    AscLineLen equ $-AscLine
    FullLen equ $-DumpLine

    HexDigits: db "0123456789ABCDEF"

    DotXlat:
        ;                 |               |               |
        db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
	db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
	db 20h,21h,22h,23h,24h,25h,26h,27h,28h,29h,2Ah,2Bh,2Ch,2Dh,2Eh,2Fh
	db 30h,31h,32h,33h,34h,35h,36h,37h,38h,39h,3Ah,3Bh,3Ch,3Dh,3Eh,3Fh;___
	db 40h,41h,42h,43h,44h,45h,46h,47h,48h,49h,4Ah,4Bh,4Ch,4Dh,4Eh,4Fh
	db 50h,51h,52h,53h,54h,55h,56h,57h,58h,59h,5Ah,5Bh,5Ch,5Dh,5Eh,5Fh
	db 60h,61h,62h,63h,64h,65h,66h,67h,68h,69h,6Ah,6Bh,6Ch,6Dh,6Eh,6Fh
	db 70h,71h,72h,73h,74h,75h,76h,77h,78h,79h,7Ah,7Bh,7Ch,7Dh,7Eh,2Eh;___
	db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
	db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
	db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
	db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh;___
	db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
	db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
	db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh
	db 2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh,2Eh

section .text

; Clear DumpLine and AscLine to initial state.
ClearLine:
    push rax
    push rbx
    push rcx
    push rdx
    mov rdx, 15
.poke:
    mov rax, 0
    call DumpChar                        ; rax = 0, so put 00 into DumpLine and "." into AscLine
    sub rdx, 1
    jae .poke

    pop rdx
    pop rcx
    pop rbx
    pop rax

    ret

; Dump the content of al to AscLine (|...|)
; Dump the number of al to DumpLine ("00")
DumpChar:
    ; From Scan, al == [Buff+rcx(0,1,2,3,...)], rdx == 0,1,2,3,...15
    ; From ClearLine rax = 0, rdx = 15
    push rbx                             ; Preserve caller's RAX.
    push rdi

    mov bl, [DotXlat+rax]                ; Copy number of the char corresponding to DotXlat.
    mov [AscLine+rdx+1], bl              ; Replace one of |...| with the number of the char.

    mov rbx, rax                         ; bl = [Buff+rcx].
    lea rdi, [rdx+rdx*2]                 ; Calculate offset. Should not rdx*3 because have to follow memory formula. [base + (index * scale) + disp]

    and rax, 000000000000000Fh           ; Mask out the least 4bits of [Buff+rcx] for mov al instruction.
    mov al, [HexDigits+rax]              ; Pick a char from HexDigits with rax as index and copy to al.
    mov [DumpLine+rdi+2], al             ; Put the content to the right side of 00 in DumpLine.

    and rbx, 00000000000000F0h           ; Mask out as well to get the rest 4 bits of [Buff+rcx].
    shr rbx, 4                           ; Bit shift to right.
    mov bl, [HexDigits+rbx]              ; Pick a char from HexDigits.
    mov [DumpLine+rdi+1], bl             ; Put the content to the left side of 00 in DumpLine.

    pop rdi
    pop rbx

    ret

; Print DumpLine + AscLine
PrintLine:
    push rax                             ; Preserve caller's rax. 
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi

    mov rax, 1                           ; sys_call write
    mov rdi, 1
    mov rsi, DumpLine
    mov rdx, FullLen
    syscall

    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax

    ret

LoadBuff:
    push rax                             ; Preserve caller's RAX.
    push rdx
    push rsi
    push rdi

    mov rax, 0                           ; sys_read.
    mov rdi, 0                           ; File descriptor.
    mov rsi, Buff
    mov rdx, BuffLen
    syscall
    
    mov r15, rax                         ; Preserve the number of chars stdin read.
    xor rcx, rcx                         ; Clear RCX.

    pop rdi
    pop rsi
    pop rdx
    pop rax

    ret

global _start
_start:
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
