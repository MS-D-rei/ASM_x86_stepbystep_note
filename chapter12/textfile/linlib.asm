[SECTION .data]
	LineBase db "Number is: %d", 0xa, 0
	LineFeeds db 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, 0

[SECTION .bss]

[SECTION .text]
	extern printf
	extern rand
	extern srand
	extern time

	global seed
	global pull31
	global pull20
	global pull16
	global pull8
	global pull7
	global pull6
	global pull4
	global newline

pull31:
	mov rcx, 0
	jmp pull

pull20:
	mov rcx, 11
	jmp pull

pull16:
	mov rcx,15
	jmp pull

pull8:
	mov rcx, 23
	jmp pull

pull7:
	mov rcx, 24
	jmp pull

pull6:
	mov rcx, 25
	jmp pull

pull4:
	mov rcx, 27

pull:
	push rbp
	mov rbp, rsp


	push rcx
	call rand
	pop rcx
	shr rax, cl

	pop rbp
	ret

seed:
	push rbp
	mov rbp, rsp

	xor rdi, rdi
	call time
	mov rdi, rax
	call srand

	pop rbp
	ret

newline:
	push rbp
	mov rbp, rsp

	mov rcx, 10
	sub rcx, rax
	add rcx, LineFeeds
	mov rdi, rcx
	call printf
	
	pop rbp
	ret
