; Executable name
; Version
; Create date
; Last update
; Author
; Description
; Build command
; 	time-test: time-test.o
;		gcc -o time-test -no-pie time-test.o
;	time-test.o: time-test.asm
; 		nasm -f elf64 -g -F dwarf time-test.asm

section .data
	TimeMessage db "It's %s now.", 0x0a, 0
	YearMessage db "The year is %d.", 0x0a, 0
	PressEnterMessage db "Press enter after a few seconds: ", 0
	ElapsedMessage db "A total of %d seconds has elapsed since program began running.", 0x0a, 0

section .bss
	OldTime		resq 1
	NewTime		resq 1
	TimeDiff	resq 1
	TimeString	resb 40
	TmCopy		resd 9

section .text
	extern ctime
	extern difftime
	extern getchar
	extern printf
	extern localtime
	extern strftime
	extern time

	global main

main:
	push rbp                     ; Prolog. Setup stack frame.
	mov rbp, rsp

	; Get current time.
	xor rdi, rdi
	call time                    ; If RDI == 0, return time_t value in RAX.
	mov [OldTime], rax           ; *OldTime = RAX(current time)

	; Get a pointer to current time formatted by ctime.
	mov rdi, OldTime             ; ctime needs the address of the time_t value.
	call ctime                   ; Return a pointer to the formatted string in RAX.

	; `ctime` seems to put EOL the end of the formatted string.

	; printf("It's %s now.", rsi).
	mov rdi, TimeMessage         ; RDI = printf sentense.
	mov rsi, rax                 ; RSI = Pointer to the formatted string by ctime.
	mov rax, 0                   ; This tells printf that no vector params are comimg.
	call printf

	; Get tm structure created with the time_t value.
	mov rdi, OldTime             ; RDI = the address of the time_t value.
	call localtime               ; Create tm structure with RDI and return the pointer to it in RAX.

	; Create a copyt of the tm structure.
	mov rsi, rax                 ; RSI = the pointer to the tm structure.
	mov rdi, TmCopy              ; RDI = the copy destination.
	mov rcx, 9                   ; RCX = counts for rep movsd.
	cld
	rep movsd                    ; Copy the tm structure to TmCopy.
	; (while rcx >= 0)
	; {
	;    RDI[rdiIndex] = RSI[rsiIndex];
	;    --RCX;
	;    ++rdiIndex;
	;    ++rsiIndex;
	; }

	; Print the year extracted from the tm structure.
	mov rdi, YearMessage         ; RDI = printf sentense.
	mov rsi, [TmCopy+20]         ; tm structure[20] = tm_year has the number of years since 1900.
	add rsi, 1900                ; Add 1900 to get the current year.
	mov rax, 0                   ; Tells printf that no vector params are coming.
	call printf

	mov rdi, PressEnterMessage
	mov rax, 0
	call printf

	; Wait for the user to press enter.
	call getchar

	; Get current time_t value.
	xor rdi, rdi
	call time                    ; If RDI == 0, return time_t value in RAX.
	mov [NewTime], rax           ; *NewTime = RAX(time_t value).

	; Get time diff between NewTime and OldTime.
	sub rax, [OldTime]           ; Calculate the difference between New and Old.
	mov [TimeDiff], rax

	; Print the time diff.
	mov rdi, ElapsedMessage
	mov rsi, [TimeDiff]          ; RSI = time diff value between New and Old.
	mov rax, 0
	call printf

Exit:
	pop rbp
	ret

