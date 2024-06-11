section .data
	EditBuffer db "abcdefghijklm ", 0x0A
	EditBufferLength    equ $-EditBuffer
	EndPosition         equ 12
	InsertPosition      equ 1

section .bss

section .text

	global _start

_start:

	mov rbp, rsp
	nop

	std                                      ; Set Direction Flag
	mov rbx, EditBuffer
	mov rdi, EditBuffer+EndPosition+1
	mov rsi, EditBuffer+EndPosition
	mov rcx, EndPosition-InsertPosition+2
	rep movsb
	; while (RCX >= 0)
	; {
	;    RDI[rdiIndex] = RSI[rsiIndex];
	;    --RCX;
	;    ; rdiIndex and rsiIndex will be decremented
	;    ; because `std` set direction flag.
	;    --rdiIndex;
	;    --rsiIndex;
	; }

	mov byte [rbx], 0x20

	mov rax, 1
	mov rdi, 1
	mov rsi, EditBuffer
	mov rdx, EditBufferLength
	syscall

	nop

Exit:
	mov rax, 60
	mov rdi, 0
	syscall
