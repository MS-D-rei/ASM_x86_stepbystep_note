; Executable name         ; hello-world-glibc
; Version
; Created date
; Last update
; Author
; Description

; How to build
; 	nasm -f elf64 -g -F dwarf hello-world-glibc.asm
;	gcc -o hello-world-glibc -no-pie hello-world-glibc.o
;	`-no-pie` option is required to use `puts`
;	`pie` stands for Position-Independent Executable

section .data
	Message db "Hello world!", 0x0a

section .bss

section .text
	extern puts

	global main

main:
	push rbp
	mov rbp, rsp

	mov rdi, Message
	call puts
	xor rax, rax

Exit:
	pop rbp

	ret
