section .data

	ErrorMessage		db "Terminated with error.", 0x0a
	ErrorMessageLength	equ $-ErrorMessage
	MaxArgs			equ 5

section .bss

section .text

	global _start

_start:
	mov rbp, rsp
	nop

	mov r14, rsi                ; RSI contains the address of the first item in the list of cli args.
	mov r15, rdi                ; RDI contains the number of cli args.

	cmp qword r15, MaxArgs      ; If the number of cli args > MaxArgs
	ja Error

	xor rbx, rbx

Scan1:
	xor rax, rax
	mov rcx, 0x0ffff
	mov rdi, qword [r14+rbx*8]
	mov rdx, rdi

	cld
	repne scasb
	jnz Error

	mov byte [rdi-1], 10
	sub rdi, rdx
	mov r13, rdi

	mov rax, 1
	mov rdi, 1
	mov rsi, rdx
	mov rdx, r13
	syscall

	inc rbx
	cmp rbx, r15
	jb Scan1
	jmp Exit

Error:
	mov rax, 1
	mov rdi, 1
	mov rsi, ErrorMessage
	mov rdx, ErrorMessageLength
	syscall

Exit:
	mov rax, 60
	mov rdi, 0
	syscall
