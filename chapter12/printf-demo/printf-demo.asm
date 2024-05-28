section .data
	Message    db "The number is %d, %d, %x.", 0x0a, 0
	MsgNumber  dd 42

section .bss

section .text
	extern printf
	global main

main:
	push rbp                 ; Prolog
	mov rbp, rsp

	xor rax, rax

	; Parameter order
	; rdi, rsi, rdx, rcx, r8, r9
	; printf("The number is %d, %d, %x.", *MsgNumber, 43, 44)
	mov rdi, Message         ; 1st arg.
	mov rsi, [MsgNumber]     ; 2nd arg. [MsgNumber] is like de-referencing pointer.
	mov rdx, 43              ; 3rd arg. Can use literal value.
	mov rcx, 44              ; 4th arg. 
	mov rax, 0               ; This tells printf that no vector params are comimg.
	call printf

	pop rbp                  ; Epilog

	ret                      ; Return from main().
