; 64-bit calling convention parameter order
; RDI, RSI, RDX, RCX, R8, R9
; volatile registers
; RAX, RCX, RDX, RDI, RSI, R8, R9, R10
; nonvolatile registers
; RBP, RSP, RBX, R12, R13, R14, R15

; How to use.
; ./textfile 50 time for dinner!
; First arg is supposed to be int.
; Output `new-textfile.txt` contains "Line # X: arg2 arg3 arg4 ..."

section .data
	IntFormat db "%d", 0
	WriteBase db "Line # %d: %s", 0x0a, 0
	NewFileName db "new-textfile.txt", 0
	DiskHelpName db "help-textfile.txt", 0
	WriteMode db "w", 0
	ReadMode db "r", 0
	CharTable db "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-@" ; total 64 chars.
	Error01 db "ERROR: The first command line argument must be an integer!", 0x0a, 0
	HelpMessage db "TEXTTEST: Generates a test file. Arg(1) should be the # of ", 0x0a, 0
	HelpSize EQU-$HelpMessage
	db "lines to write to the file. All other args are concatenated", 0x0a, 0
	db "into a single line and written to the file. If no text args", 0x0a, 0
	db "are entered, random text is written to the file. This message", 0x0a, 0
	db "appears only if thefile `help-textfile.txt` cannot be opened.", 0x0a, 0
	HelpEnd dq 0

section .bss
	LineCount resq 1
	IntBuffer resq 1
	HelpLength EQU 72
	HelpLine resb HelpLength
	BufferSize EQU 64
	Buffer resb BufferSize+16

section .text
	extern fopen
	extern fclose
	extern fgets
	extern fprintf
	extern printf
	extern sscanf
	extern time

	extern seed
	extern pull6

	global main

main:
	push rbp
	mov rbp, rsp

	mov r12, rdi                    ; Preserve argc.
	mov r13, rsi                    ; Preserve argv.

	call seed

	cmp r12, 1
	ja checkarg2

	mov rbx, DiskHelpName
	call diskhelp
	jmp gohome

; Convert first arg string to number in IntBuffer.
; If successfully do it, go to checkdata.
; If not, show Error01 and go to gohome.
checkarg2:
	mov rdi, qword [r13+8]          ; RDI = address of first arg (supposed to be int).
	mov rsi, IntFormat              ; RSI = address of format.
	mov rdx, IntBuffer              ; RDX = address of buffer for sscanf output.
	xor rax, rax                    ; Tells there will be no vector parameters.
	call sscanf                     ; Convert string to number.

	cmp rax, 1                      ; Return 1 in RAX says we successfully got a number.
	je checkdata

	mov rdi, Error01
	xor rax, rax
	call printf
	jmp gohome

; r12 = argc.
checkdata:
	mov r15, [IntBuffer]            ; r15 = output of sscanf
	cmp r12, 3
	jae getline
	call randline
	jmp generatefile

getline:
	mov r14, 2                      ; r14 = offset to get 2nd and subsequent value in argv table.
	mov rdi, Buffer                 ; movsb destination.
	xor rax, rax
	cld                             ; Clear direction flag for movsb

; r13 = argv.
grab:
	mov rsi, qword [r13+r14*8]      ; RSI = value of argv table from 2nd and subsequent one.
.copy:
	cmp byte [rsi], 0               ; if no other value from argv table.
	je .next
	movsb                           ; RDI[rdiIndex] = RSI[rsiIndex].
	inc rax                         ; Use RAX as index for RDI.
	cmp rax, BufferSize             ; if reaches BufferSize.
	je addnull                      ; Add null at the end of Buffer.
	jmp .copy                       ; Repeat.

.next:
	mov byte [rdi], ' '             ; Fill Buffer with white space.
	inc rdi                         ; Point to the next address.
	inc rax                         ; Increment index for RDI.
	cmp rax, BufferSize             ; If index reaches BufferSize.
	je addnull                      ; Add null at the end of data in Buffer.
	inc r14                         ; Point to next offset to get argv value.
	cmp r14, r12                    ; If the offset reaches argc.
	jae addnull                     ; Add null at the end of data in Buffer.
	jmp grab                        ; Back to grab.

addnull:
	mov byte [rdi], 0               ; Add null at the end of data in Buffer.
	mov rsi, Buffer

generatefile:
	mov rdi, NewFileName            ; Addres of file name for fopen
	mov rsi, WriteMode              ; Address of mode setting. 'r', 'w', 'a' or '[r|w|a]+'.
	call fopen                      ; Create/open file.
	mov rbx, rax                    ; fopen returns a file handle in RAX.

	mov r14, 1                      ; R14 = line number in the text file.

; Loop writeline while (r15 >= 0)
writeline:
	cmp qword r15, 0                ; If first arg(supposed to be number) is 0.
	je closeit

	mov rdi, rbx                    ; RDI = fopen file handle 64-bit number.
	mov rsi, WriteBase
	mov rdx, r14                    ; RDX = line number of the text file.
	mov rcx, Buffer                 ; RCX = address of Buffer filled with argv values.
	xor rax, rax                    ; Tells there will be no vector parameters.
	call fprintf
	dec r15                         ; Decrement count.
	inc r14                         ; Go to next line.
	jmp writeline

closeit:
	mov rdi, rbx                    ; RDI = fopen file handle 64-bit number.
	call fclose                     ; Closes the file.

gohome:
	pop rbp
	ret

; Sub routines -----------------------------------------------------------------

diskhelp:
	push rbp
	mov rbp, rsp

	mov rdi, DiskHelpName
	mov rsi, ReadMode
	call fopen
	cmp rax, 0
	jne .disk
	call memhelp

	pop rbp
	ret

.disk:
	mov rbx, rax                    ; RBX = fopen file handle 64-bit number.

.readline:
	mov rdi, HelpLine               ; RDI = address of buffer.
	mov rsi, HelpLength             ; RSI = buffer size.
	mov rdx, rbx                    ; RDX = fopen file handle.
	call fgets
	cmp rax, 0                      ; if fgets return 0 in RAX, it indicates error or EOF.
	jle .done

	mov rdi, HelpLine               ; RDI = content fgets returns.
	mov rax, rax                    ; Tells there will be no fp parameter.
	call printf
	jmp .readline

.done:
	mov rdi, rbx                    ; RDI = fopen file handle.
	call fclose
	jmp gohome

memhelp:
	push rbp
	mov rbp, rsp

	mov rax, 5
	mov rbx, HelpMessage

.checkline:
	cmp qword [rbx], 0
	jne .show

	pop rbp
	ret

.show:
	mov rdi, rbx
	xor rax, rax
	call printf
	add rbx, HelpSize
	jmp .checkline

showerror:
	push rbp
	mov rsp, rbp

	mov rdi, rax
	xor rax, rax
	call printf

	pop rbp
	ret

randline:
	push rbp
	mov rbp, rsp

	mov rbx, BufferSize
	mov byte [Buffer+BufferSize+1], 0

.loopback:
	dec rbx
	call pull6
	mov cl, [CharTable+rax]
	mov [Buffer+rbx], cl
	cmp rbx, 0
	jne .loopback
	mov rsi, Buffer

	pop rbp
	ret
