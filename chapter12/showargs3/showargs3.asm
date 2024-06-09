; 64-bit calling convention parameter order
; RDI, RSI, RDX, RCX, R8, R9
; volatile registers
; RAX, RCX, RDX, RDI, RSI, R8, R9, R10
; nonvolatile registers
; RBP, RSP, RBX, R12, R13, R14, R15

section .data
	ArgMessage db "Argument %d: %s", 0xa, 0

section .bss

section .text
	global main
	extern printf

main:
	push rbp
	mov rbp, rsp

	mov r14, rdi                   ; RDI has argc (count).
	mov r13, rsi                   ; RSI has the pointer to argv (arg table).
	xor r12, r12                   ; r12 = 0. Will be used as the index in ArgMessage.

.showit:
	mov rdi, ArgMessage
	mov rsi, r12                   ; %d.
	mov rdx, qword [r13+r12*8]     ; %s.
	mov rax, 0                     ; Tells printf() no vector arguments are coming.
	call printf

	inc r12                        ; Increment index in ArgMessage
	dec r14                        ; Decrement argc
	jnz .showit                    ; Loop while (argc > 0)

	mov rsp, rbp
	pop rbp

	ret
