section .data

	EOL		equ 0x0A         ; "\n", Line feed.
	SpaceChar	equ 0x20         ; " "
	ChartStartRow	equ 2
	ChartLength	equ 32           ; Each chart line width.

	ClearHome	db 27, "[2J", 27, "[01;01H"
	ClearHomeLength	equ $-ClearHome

	RulerString		db "12345678901234567890123456789012345678901234567890123456789012345678901234567890"
	RulerStringLength	equ $-RulerString

section .bss
	
	ColsWidth	equ 81                    ; Line length + EOL.
	RowsHeight	equ 25                    ; Number of lines in display.
	VideoBuffer	resb ColsWidth*RowsHeight

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

ShowBuffer:

	push r11
	push rax
	push rcx
	push rdx
	push rsi
	push rdi

	mov rax, 1
	mov rdi, 1
	mov rsi, VideoBuffer
	mov rdx, ColsWidth*RowsHeight
	syscall

	pop rdi
	pop rsi
	pop rdx
	pop rcx
	pop rax
	pop r11

	ret

ClearVideoBuffer:

	push rax
	push rcx
	push rdi
	cld

	; Fill VideoBuffer with space char.
	mov al, SpaceChar
	mov rdi, VideoBuffer
	mov rcx, ColsWidth*RowsHeight
	rep stosb

	mov rdi, VideoBuffer                 ; Set target in RDI.
	dec rdi                              ; To put EOL at RDI[80].
	mov rcx, RowsHeight                  ; Count for how many EOL we put.

	; Put EOL at each end of line.
	.PutEOL:

	add rdi, ColsWidth                   ; RDI[80], RDI[161]...
	mov byte [rdi], EOL
	loop .PutEOL                         ; Loop while RCX >= 0

	pop rdi
	pop rcx
	pop rax

	ret

;-------------------------------------------------------------------------
; Ruler                   : Generate "1234567890"-style ruler at X, Y
; In
	; 1-based X position in RBX
	; 1-based Y position in RAX
	; Counts for loop in RCX
; Returns                 : Nothing
; Modifies		  : VideoBuffer

Ruler:
	push rax
	push rbx
	push rcx
	push rdx
	push rdi

	mov rdi, VideoBuffer
	dec rax
	dec rbx
	mov ah, ColsWidth
	mul ah
	add rdi, rax
	add rdi, rbx

	mov rdx, RulerString

DoRule:
	mov byte al, [rdx]
	stosb
	inc rdx
	loop DoRule

	pop rdi
	pop rdx
	pop rcx
	pop rbx
	pop rax

	ret

;-------------------------------------------------------------------------
; MAIN PROGRAM:
;-------------------------------------------------------------------------	

_start:

	mov rbx, rsp

	call ClearTerminal
	call ClearVideoBuffer

	mov rax, 1
	mov rbx, 1
	mov rcx, 32
	call Ruler

	mov rdi, VideoBuffer
	add rdi, ColsWidth*ChartStartRow     ; Add Y position offset for where to begin.
	mov rcx, 224			     ; Counts for loop.
	mov al, 32                           ; Start from ASCII space char(32)

	.DoLn:
	mov bl, ChartLength
	.DoChar:
	stosb
	jrcxz AllDone
	inc al
	dec bl
	loopnz .DoChar
	add rdi, ColsWidth-ChartLength
	jmp .DoLn

AllDone:

	call ShowBuffer

Exit:
	mov rax, 60
	mov rdi, 0
	syscall
