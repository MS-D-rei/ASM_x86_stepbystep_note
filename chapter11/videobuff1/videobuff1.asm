; Executable name                     : videobuff1
; Version
; Created date                        : 2024-05-21
; Last update                         : 2024-05-21
; Author
; Description
; How to build
; videobuff1: videobuff1.o
;     ld -o videobuff1 videobuff1.o
; videobuff1.o: videobuff1.asm
;     nasm -f elf64 -g -F dwarf videobuff1.asm

section .data

    EOL                    equ 10
    ASCIISpaceChar         equ 32
    HBarCharLength         equ 196
    StartRowLength         equ 2

; To display a ruler across the screen.
    TenDigits    db 31,32,33,34,35,36,37,38,39,30
    DigitCount   db 10
    RulerString  db "12345678901234567890123456789012345678901234567890123456789012345678901234567890"
    RulerLength  equ $-RulerString

; Table of byte-length numbers 
    Dataset    db 9,17,71,52,55,18,29,36,18,68,77,63,58,44,0
    Message    db "Data current as of 2024/05/21"
    MessageLength   equ $-Message

; Escape sequence will clear the console terminal and place
; the text cursor to the origin(1,1) on virtually all Linux.
    ClearHome    db 27,"[2J",27,"[01;01H"
    ClearHomeLength  equ $-ClearHome

section .bss

    Cols        equ 81               ; Line Length + 1 char for EOL
    Rows        equ 25               ; Number of lines in display
    VideoBuff   resb Cols*Rows

section .text

    global _start

ClearTerminal:
	
    push r11
    push rax
    push rcx
    push rdx
    push rsi
    push rdi

    mov rax, 1
    mov rdi, 1
    mov rsi, ClearHome
    mov rdx, ClearHomeLength
    syscall

    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rax
    pop r11

    ret

;--------------------------------------------------------------------------------
; ShowBuffer                   : Display text buffer
; Updated                      : 2024-5-21
; In                           : Nothing
; Returns                      : Nothing
; Modifies                     : Nothing
; Calls                        : Linux sys_write
; Description

ShowBuffer:

    push r11
    push rax
    push rcx
    push rdx
    push rsi
    push rdi

    mov rax, 1
    mov rdi, 1
    mov rsi, VideoBuff
    mov rdx, Cols*Rows

    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rax
    pop r11

    ret

;--------------------------------------------------------------------------------
; ClearVideoBuffer                  : Clears buffer
; Updated
; In
; Returns
; Modifies
; Calls
; Description

ClearVideoBuffer:

    push rax
    push rcx
    push rdi
    cld                              ; Clear Direction Flag.

    mov al, ASCIISpaceChar           ; The content to fill RDI(VideoBuff).
    mov rdi, VideoBuff               ; Target.
    mov rcx, Cols*Rows               ; Loop count.
    rep stosb                        ; Loop to fill VideoBuff with ASCII space char.
    ; rep stosb is equivalent to
    ; Clear:
    ;     mov [rdi], al              ; rdi[0] = al.
    ;     inc rdi                    ; point to rdi[1].
    ;     dec rcx                    ; --rcx.
    ;     jnz Clear                  ; if not rcx == 0, back to Clear.

    mov rdi, VideoBuff
    dec rdi                          ; VideoBuff[-1]
    mov rcx, Rows                    ; Loop count

.PutEOL:
    add rdi, Cols                    ; VideoBuff[80], Videobuff[161]...
    mov byte [rdi], EOL              ; Put EOL at the end of line
    loop .PutEOL                      ; Loop. decrement RCX and check Zero Flag.
    
    pop rdi
    pop rcx
    pop rax

    ret

;--------------------------------------------------------------------------------
; WriteLn                     : Writes a string to text buffer at a 1-based X,Y
; Updated
; In
; Address of the string in RSI
    ; X position (row #) in RBX
    ; Y position (col #) in RAX
    ; The length of the string in chars in RCX
; Returns                     : Nothing
; Modifies                    : VideoBuff, RDI, DF
; Calls                       : Nothing
; Description

WriteLn:
    push rax
    push rbx
    push rcx
    push rdi
    cld

    mov rdi, VideoBuff
    dec rax
    dec rbx
    mov ah, Cols
    mul ah                    ; AX = AL * AH
    add rdi, rax              ; Add X offset to VideoBuff
    add rdi, rbx              ; Add Y offset to VideoBuff
    rep movsb                 ; Blast the string into the buffer

    pop rdi
    pop rcx
    pop rbx
    pop rax

    ret

;--------------------------------------------------------------------------------
; WriteHB                     : Generate a horizontal line bar at X,Y
; Updated                     : 2024-05-21
; In
    ; X position (row #) in RBX
    ; Y position (col #) in RAX
    ; The length of the bar in chars in RCX
; Returns                     : Nothing
; Modifies                    : VideoBuff, DF
; Calls                       : Nothing
; Description

WriteHB:
    push rax
    push rbx
    push rcx
    push rdi
    cld

    mov rdi, VideoBuff
    dec rax                   ; Adjust Y down by 1 for address calculation
    dec rbx                   ; Adjust X down by 1 for address calculation
    mov ah, Cols              ; Screen width
    mul ah                    ; AX = AL * AH
    add rdi, rax              ; Add Y offset
    add rdi, rbx              ; Add X offset
    mov al, HBarCharLength
    rep stosb                 ; Blast the bar char into the buffer

    pop rdi
    pop rcx
    pop rbx
    pop rax

    ret

;--------------------------------------------------------------------------------
; Ruler                       : Generates "1234567890" style ruler at X, Y
; Updated                     : 2024-05-21
; In
    ; X position (row #) in RBX
    ; Y position (col #) in RAX
    ; The length of the ruler in chars in RCX
; Returns                     : Nothing
; Modifies                    : VideoBuff
; Calls                       : Nothing
; Description

Ruler:
    push rax
    push rbx
    push rcx
    push rdx
    push rdi

    mov rdi, VideoBuff
    dec rax
    dec rbx
    mov ah, Cols
    mul ah
    add rdi, rax
    add rdi, rbx

; RDI now contains the memory address in the buffer where the ruler
; is to begin. Now we display the ruler, starting at the position

    mov rdx, RulerString

DoRule:
    mov al, [rdx]
    stosb                    ; Store 1 char. Note that there is no `rep`.
    inc rdx                  ; Increment RDX to point to next char in RulerString.
    loop DoRule

    pop rdi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    
    ret

;--------------------------------------------------------------------------------
; Main program

_start:
    push rbp
    mov rbp, rsp
    and rsp, -16

    call ClearTerminal
    call ClearVideoBuffer

    mov rax, 1               ; Load Y position to AL.
    mov rbx, 1               ; Load X position to BL.
    mov rcx, Cols-1          ; Load ruler length to RCX.
    call Ruler               ; Write the ruler to the buffer.

    mov rsi, Message
    mov rcx, MessageLength
    mov rbx, Cols
    sub rbx, rcx             ; Calculate the diff of MessageLength and screen width.
    shr rbx, 1               ; the diff / 2 for X value
    mov rax, 20              ; Set message row to Line 24
    call WriteLn             ; Display the centered message

    mov rsi, Dataset
    mov rbx, 1
    mov r15, 0               ; Dataset element index starts at 0

.blast:
    mov rax, r15
    add rax, StartRowLength
    mov cl, byte [rsi+r15]   ; Put Dataset value to cl
    cmp rcx, 0
    je .rule2
    call WriteHB
    inc r15
    jmp .blast

; Display the bottom ruler
.rule2:
    mov rax, r15
    add rax, StartRowLength
    mov rbx, 1
    mov rcx, Cols-1
    call Ruler

    call ShowBuffer

Exit:
    mov rsp, rbp
    pop rbp

    mov rax, 60
    mov rdi, 0
    syscall
