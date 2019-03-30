                section         .text
                global          _start

_start:
; [rsp]      = 2
; [rsp + 8]  = ссылка на строку "./linesCntFile"
; [rsp + 16] = ссылка на строку "/home/solomax/lec02.txt"
; Первый аргумент всегда имя запускаемого файла
; Это как с argc, argv (qty, arr)
                pop             rax
                cmp             rax, 2
                jl              args_error

; rax = 2 -> syscall = sys_open
; sys_open(fileName (rdi), 0 (rsi), 0 (rdx))
; after syscall rax = file descriptor ID
                pop             rax
                mov             rax, 2
                pop             rdi
                xor             rsi, rsi
                xor             rdx, rdx
                syscall

                cmp             rax, 0
                jl              open_error

; r10 = file descriptor ID
                mov             r10, rax
; rax = 0 -> sys_read
; rdi = should be file descriptor ID, doesn't change while reading
read_char:
; prevChar (chars) = currChar (chars + 1)
                mov             rax, [chars + 1]
                mov             [chars], rax
                xor             rax, rax
                mov             rdi, r10
                mov             rsi, buf
                mov             rdx, 1
                syscall

; res in rax: if rax > 0 -- quantity of read bytes
; rax = 0 -> EOF
; rax < 0 -> error
                cmp             rax, 0
                jl              read_error
                je              write_result

; rax should be = 1
                cmp             rax, 1
                jg              read_error

; if (arr.find(currChar) && prevCharIsNotWhiteSpace)
;     ++count;
; currChar                   ->    al
; prevCharIsWhiteSpace       ->    [chars] = 1
; prevCharIsNotWhiteSpace    ->    [chars] = 0
; currCharIsWhiteSpace       ->    [chars + 1] = 1
; currCharIsNotWhiteSpace    ->    [chars + 1] = 0
; count                      ->    rbx
                mov             al, byte [buf]
                xor             rcx, rcx
.loop:
                cmp             rcx, arr_size
                jge             .afterLoop_notWhiteSpace
                mov             bl, [arr + rcx]
                cmp             al, bl
                je              .afterLoop_whiteSpace
                inc             rcx
                jmp             .loop

.afterLoop_whiteSpace:
                mov             byte [chars + 1], 0x01
                cmp             byte [chars], 0x00
                je              inc_result
                jmp             read_char

.afterLoop_notWhiteSpace:
                mov             byte [chars + 1], 0x00
                jmp             read_char

inc_result:
                inc             r12
                jmp             read_char

write_result:
                mov             rax, r12

; #######################################################################
; ####################### START OF NUMBER_PRINTER #######################
; #######################################################################

                call            print_number
                call            print_line_separator

                jmp             exit

; rax - number
print_number:
                cmp             rax, 0
                jg              positive
                call            print_digit
                ret

positive:
; rbx = 1
; while (rbx <= rax)
;     rbx *= 10
                mov             rbx, 1
.loop1:
                cmp             rbx, rax
                jg              .afterLoop1
                call            mulrbx10
                jmp             .loop1

.afterLoop1:
                call            divrbx10

; div x -> rax = rdx:rax / x, rdx = rdx:rax % x
;
; while (rbx > 0) {
;     printf("%d", rax / rbx)
;     rax %= rbx
;     rbx /= 10
; }
.loop2:
                cmp             rbx, 0
                jle             .afterLoop2
                xor             rdx, rdx
                div             rbx
                call            print_digit
                mov             rax, rdx
                call            divrbx10
                jmp             .loop2

.afterLoop2:
                ret

; rbx *= 10
mulrbx10:
                push            rdx
                push            rax
                xor             rdx, rdx
                mov             rax, rbx
                mov             rbx, 10
                mul             rbx
                mov             rbx, rax
                pop             rax
                pop             rdx
                ret

; rbx /= 10
divrbx10:
                push            rdx
                push            rax
                xor             rdx, rdx
                mov             rax, rbx
                mov             rbx, 10
                div             rbx
                mov             rbx, rax
                pop             rax
                pop             rdx
                ret
; rax - digit
print_digit:
; rax = 1 -> syscall = sys_write
; sys_write(rdi(fd), rsi(char buf), rdx(count))
                push            rdx
                lea             rsi, [digits + rax]
                mov             rax, 1
                mov             rdi, 1
                mov             rdx, 1
                syscall
                pop             rdx
                ret

print_line_separator:
; rax = 1 -> syscall = sys_write
; sys_write(rdi(fd), rsi(char buf), rdx(count))
                push            rax
                push            rdx
                mov             rax, 1
                mov             rdi, 1
                mov             rsi, line_separator
                mov             rdx, 1
                syscall
                pop             rdx
                pop             rax
                ret

; #######################################################################
; ######################## END OF NUMBER_PRINTER ########################
; #######################################################################

; close + exit
exit:
                mov             rax, 3
                mov             rdi, r10
                syscall

                mov             rax, 60
                xor             rdi, rdi
                syscall

args_error:
                mov             rsi, error_args
                mov             rdx, error_args_size
                jmp             write_and_exit

open_error:
                mov             rsi, error_args
                mov             rdx, error_args_size
                jmp             write_and_exit

read_error:
                mov             rsi, error_read
                mov             rdx, error_read_size
                jmp             write_and_exit

write_and_exit:
                mov             rax, 1
                mov             rdi, 1
                syscall
                jmp             exit
                
                section         .rodata
digits:         db              "0123456789"
line_separator: db              0x0a

error_read:     db              "Error occured at reading :(", 0x0a
error_read_size:equ             $ - error_read

error_args:     db              "Expected 2 or more arguments", 0x0a
error_args_size:equ             $ - error_args

error_open:     db              "Error at opening file :(", 0x0a
error_open_size:equ             $ - error_open

arr:            db              0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x20
arr_size:       equ             $ - arr

                section         .data
chars:          db              0x01, 0x01

                section         .bss
buf:            resb            1
