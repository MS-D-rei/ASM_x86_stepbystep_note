;   Usage: ./uppercase1 < <input-file> > <output-file>

section .bss
    Buff resb 1
section .data
section .text
    global _start

_start:
    mov rbp, rsp

Read:
    mov rax, 0                    ; 0 = sys_read call
    mov rdi, 0                    ; File descriptor 0 = stdin
    mov rsi, Buff                 ; Address of te buffer to read
    mov rdx, 1                    ; Length of the buffer to read
    syscall                       ; Return how many char program read. If return 0, it means to reach EOF.
                                  ; (syscall return rax = 1 or rax = 0)

    cmp rax, 0                    ; Compare operands and sets the flags.
    je Exit                       ; Jump if equal based on preceding CMP. (if rax == 0)

    ; Write the char without converting if it is not in the range of lowercase (from 61h'a' to 7Ah'z')
    cmp byte [Buff], 61h          ; if (char < 'a')
    jb Write                      ; Jump if below
    cmp byte [Buff], 7Ah          ; if (char > 'z')
    ja Write                      ; Jump if above

    sub byte [Buff], 20h          ; Convert lowercase to uppercase (ex. 68h'h' to 48'H')

Write:
    mov rax, 1
    mov rdi, 1
    mov rsi, Buff
    mov rdx, 1
    syscall
    jmp Read

Exit:
    mov rax, 60
    mov rdi, 0
    syscall
