section .bss
    GLOBAL BuffLen, Buff

    BuffLen EQU 10h
    Buff: resb BuffLen

section .data
    GLOBAL DumpLine, AscLine, HexDigits, BinDigits

    DumpLine: db " 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 "
    DumpLineLen EQU $-DumpLine
    AscLine: db "|................|", 0x0A
    AscLineLen EQU $-AscLine
    FullLen EQU $-DumpLine

    ; Equates can be exported, though this is an good way of NASM, and
    ; not for all assemblers, so here, if we want to export Lengths,
    ; export these below.
    DumpLength: dq DumpLineLen
    AscLength: dq AscLineLen
    FullLength: dq FullLen
    BuffLength: dq BuffLen

    HexDigits: db "0123456789ABCDEF"

    BinDigits: db "0000", "0001", "0010", "0011"
               db "0100", "0101", "0110", "0111"
	       db "1000", "1001", "1010", "1011"
	       db "1100", "1101", "1110", "1111"
    
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
    GLOBAL ClearLine, DumpChar, NewLines, PrintLine, LoadBuff

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

NewLines:
    push rax
    push rsi
    push rdi
    push rcx                             ; Used by syscall
    push rdx
    push r11                             ; Used by syscall

    cmp rdx, 15                          ; Make sure caller does not ask for more than 15.
    ja .exit

    mov rcx, EOLs
    mov rax, 1
    mov rdi, 1
    syscall

.exit:
    pop r11
    pop rdx
    pop rcx
    pop rdi
    pop rsi
    pop rax

    ret

EOLs db 10,10,10,10,10,10,10,10,10,10,10,10,10,10,10

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
