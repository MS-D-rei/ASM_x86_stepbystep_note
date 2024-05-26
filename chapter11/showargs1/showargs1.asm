; This showargs1.asm is for SASM.

; Executable name		: showargs1
; Version
; Created date
; Last update
; Description

section .data

	ErrorMessage		db "Terminated with error.", 0x0a
	ErrorMessageLength	equ $-ErrorMessage
	MaxArgs			equ 5

section .bss

section .text

	global _start

_start:
	mov rbp, rsp

	mov r14, rsi                ; RSI contains the address of the first item in the list of CLI args.
	mov r15, rdi                ; RDI contains the number of CLI args.

	; cmp qword r15, MaxArgs      ; If the number of CLI args > MaxArgs
	; ja Error

	xor rbx, rbx                ; Set RBX 0 as a index for CLI args.

Scan1:
	xor rax, rax                ; AL = 0.
	mov rcx, 0x0ffff            ; Limit search count. 65,535.
	mov rdi, qword [r14+rbx*8]  ; RDI = the address of CLI args.
	mov rdx, rdi                ; RDX = the address of CLI args.

	cld
	repne scasb                 ; repne (Repeat while not equal) scasb (Scan String by Byte).
	; Search for 0(null) in string at RDI.
	; while (RCX >= 0)
	; {
	;    if [RDI] == AL return;
	;    if [RDI] != AL
	;        ++RDI;
	;        --RCX;
	; }
	; Now RDI point the byte AFTER the found character's position.
	jnz Error

	mov byte [rdi-1], 0x0a       ; Put EOL where the null is.
	; Calculate the length of the arg.
	sub rdi, rdx                 ; This is like equ rdi - rdx.
	mov r13, rdi                 ; Preserve the length of the arg.

	mov rax, 1
	mov rdi, 1
	mov rsi, rdx
	mov rdx, r13
	syscall

	inc rbx                      ; Increment index of CLI args.
	cmp rbx, r15                 ; Compare the index of CLI args, the number of CLI args.
	jb Scan1                     ; If not the index reaches the number.
	jmp Exit                     ;

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
