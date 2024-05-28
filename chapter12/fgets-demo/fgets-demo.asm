section .data
	Message db "You entered: %s.", 0x0a

section .bss
	TestBuffer resb 20
	TestBufferLength equ $-TestBuffer

section .text
	extern stdin
	extern printf
	extern fgets

	global main

main:
	push rbp
	mov rbp, rsp

	; Get a number of characters from the user
	mov rdi, TestBuffer          ; RDI = the address of buffer.
	mov rsi, TestBufferLength    ; RSI = max number of chars.
	mov rdx, [stdin]             ; RDX = value of stdin.
	call fgets

	mov rdi, Message
	mov rsi, TestBuffer
	mov rax, 0
	call printf

	pop rbp

	ret
