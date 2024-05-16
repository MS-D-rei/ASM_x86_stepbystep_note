; Version                   :
; Created date              : 2024-05-16
; Last update               : 2024-05-16
; Author                    : MS-D-rei
; Description
; How to build
; nasm -f elf64 -g -F dwarf eattermlib.asm

section .data
    GLOBAL PosTerm, ClearTerm, AdMessage, PromptMessage
    GLOBAL g_ScreenWidth, g_PosTermLength, g_ClearTermLength, g_AdMessageLength
    GLOBAL g_PromptMessageLength

    ScreenWidth          equ 80                ; Default is 80 chars wide
    PosTerm:             db 27, "[01;01H"      ; <ESC>[<Y>;<X>H
    PosTermLength        equ $-PosTerm
    ClearTerm:           db 27, "[2J"          ; <ESC>[2J
    ClearTermLength      equ $-ClearTerm
    AdMessage:           db "Eat, At Joe's!"   ; Ad message
    AdMessageLength      equ $-AdMessage
    PromptMessage:       db "Preass Enter: "
    PromptMessageLength  equ $-PromptMessage

    Digits: db "0001020304050607080910111213141516171819"
            db "2021222324252627282930313233343536373839"
	    db "4041424344454647484950515253545556575859"
	    db "6061626364656667686970717273747576777879"
	    db "80"
    
    ; For export
    g_ScreenWidth:         dq ScreenWidth
    g_PosTermLength:       dq PosTermLength
    g_ClearTermLength:     dq ClearTermLength
    g_AdMessageLength:     dq AdMessageLength
    g_PromptMessageLength: dq PromptMessageLength

section .bss

section .text

    GLOBAL ClearScreen, GotoXY, WriteString, WriteStringCentered

;--------------------------------------------------------------------------------
; ClearScreen           : Clear the linux console
; Update                : 2024-05-16
; In                    : nothing
; Returns               : nothing
; Modifies              : nothing
; Calls                 : SYSCALL sys_write
; Description           :

ClearScreen:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi

    mov rsi, ClearTerm             ; Pass offset of terminal control string
    mov rdx, ClearTermLength       ; Pass the length of terminal control string
    call WriteString

    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax

    ret

;--------------------------------------------------------------------------------
; GotoXY                : Position the Linux Console cursor to X, Y coordinates
; Updated               : 2024-05-16
; In                    : X in AH, Y in AL
; Returns               : Nothing
; Modifies              : PosTerm terminal control sequence string
; Calls                 : Kernel sys_write
; Description           :

GotoXY:
    push rax
    push rbx
    push rcx
    push rdx
    push rsi

    xor rbx, rbx
    xor rcx, rcx

    mov bl, al
    mov cx, [Digits+rbx*2]         ; 
    mov [PosTerm+2], cx

    mov bl, ah
    mov cx, [Digits+rbx*2]
    mov [PosTerm+5], cx

    mov rsi, PosTerm
    mov rdx, PosTermLength
    call WriteString

    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax

    ret

;--------------------------------------------------------------------------------
; WriteStringCentered   : Send a string centered to an 80 chars wide Linux console
; Updated               : 2024-05-16
; In                    : Y value in AL, String address in RSI, string length in RDX
; Returns               : Nothing
; Modifies              : PosTerm terminal control sequence string
; Calls                 : GotoXY, WriteString
; Description           :

WriteStringCentered:
    push rbx                      ; Preserve caller's RBX
    xor rbx, rbx
    mov bl, ScreenWidth
    sub bl, dl                    ; Get difference between screen width and string width
    shr bl, 1                     ; Divided by 2 for X value
    mov ah, bl                    ; GotoXY requires X in AH
    call GotoXY                   ; Go to X, Y position in screen
    call WriteString              ; Print the string

    pop rbx

    ret

;--------------------------------------------------------------------------------
; WriteString          : Send a string to the Linux console
; Updated              : 2024-05-16
; In                   : String address in RSI, string length in RDX
; Returns              : Nothing
; Modifies             : Nothing
; Calls                : Kernel sys_write
; Description          :

WriteString:
    push rax
    push rdi

    mov rax, 1
    mov rdi, 1
    syscall

    pop rdi
    pop rax

    ret
