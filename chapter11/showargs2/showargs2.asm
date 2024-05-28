; Executable                  : showargs2
; Version
; Created date
; Last update
; Author
; Description

section .data
	ErrorMessage		db "Terminated with error", 0x0a
	ErrorMessageLength	equ $-ErrorMessage
	MaxArgs			equ 10

section .bss
	ArgLength		resq MaxArgs

section .text
	global _start

_start:
	push rbp
	mov rbp, rsp                 ; RBP = the address of top of the stack.
	and rsp, -16                 ; -16 = ... 1111 | 1111 | 1111 | 0000.
	                             ; Get rid of the least 4 bits.
	
	mov r13, [rbp+8]             ; r13 = the args count from the stack.
	cmp qword r13, MaxArgs       ; If the args count.
	ja Error                     ; Above MaxArgs.

	mov rbx, 1                   ; Stack address offset.

Scan1:
	xor rax, rax                 ; RAX = 0 for repne scasb.
	mov rcx, 0x0ffff             ; Max repeat count.
	mov rdi, [rbp+8+rbx*8]       ; RDI = the address of the string to scan.
	mov rdx, rdi                 ; Copy to RDX.

	cld
	repne scasb                  ; After this line, RDI points to the next address of the found char position.
	; while (RCX >= 0)
	; {
	;    if [RDI] == AL
	;        return;
	;    if [RDI != AL]
	;        ++RDI;
	;        --RCX;
	; }
	jnz Error

	mov byte [rdi-1], 0x0a       ; Put EOL at the end of the string.
	sub rdi, rdx                 ; This is for calculating the length like equ rdi-rdx.
	mov [ArgLength+rbx*8], rdi   ; Copy the length to ArgLength.

	inc rbx
	cmp rbx, r13                 ; If the stack address offset reaches MaxArgs.
	jbe Scan1                    ; If not, loop Scan1.

	mov rbx, 1                   ; Reset RBX to 1.

ShowArgs:
	mov rax, 1                   ; sys_write
	mov rdi, 1                   ; File descriptor 1, stdout
	mov rsi, [rbp+8+rbx*8]
	mov rdx, [ArgLength+rbx*8]
	syscall

	inc rbx
	cmp rbx, r13
	jbe ShowArgs
	jmp Exit

Error:
	mov rax, 1
	mov rdi, 1
	mov rsi, ErrorMessage
	mov rdx, ErrorMessageLength
	syscall

Exit:
	mov rsp, rbp
	pop rbp

	mov rax, 60
	mov rdi, 0
	syscall
