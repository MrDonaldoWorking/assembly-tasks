				section 		.text
				global 			_start

_start:
; rax = 0 -> sys_read
; fd(rdi) = 0 -> stdin
read_char:
				xor             rax, rax
				xor             rdi, rdi
				mov 			rsi, buf
				mov				rdx, 1
				syscall
				
; res in rax: if rax > 0 -- quantity of read bytes
; rax = 0 -> EOF
; rax < 0 -> error
				cmp 			rax, 0
				jl 				read_error
				je				write_result

; rax should be = 1
				cmp 			rax, 1
				jg 				read_error

				lea 			rax, [buf]
				mov				al, byte [rax]
; if this char = '\n'
; ++rbx;
				cmp 			al, 0x0a
				je				inc_result
				jmp 			read_char

inc_result:
				inc 			rbx
				jmp				read_char

read_error:
                mov             rsi, error_msg
                mov             rdx, error_msg_size
; rax = 1 -> sys_write
; rdi = 1 -> stdout
                mov             rax, 1
                mov             rdi, 1
                syscall
                jmp 			exit

write_result:
				mov 			rax, rbx

; #######################################################################
; ####################### START OF NUMBER_PRINTER #######################
; #######################################################################

				call 			print_number
				call			print_line_separator
				
				call 			exit

; rax - number
print_number:
				cmp	 			rax, 0
				jg 				positive
				call 			print_digit
				ret

positive:
; rbx = 1
; while (rbx <= rax)
;	 rbx *= 10
				mov 			rbx, 1
.loop1:
				cmp 			rbx, rax
				jg 				.afterLoop1
				call 			mulrbx10
				jmp 			.loop1

.afterLoop1:
				call 			divrbx10

; div x -> rax = rdx:rax / x, rdx = rdx:rax % x
;
; while (rbx > 0) {
;	 printf("%d", rax / rbx)
;	 rax %= rbx
;	 rbx /= 10
; }
.loop2:
				cmp 			rbx, 0
				jle	 			.afterLoop2
				xor 			rdx, rdx
				div 			rbx
				call 			print_digit
				mov 			rax, rdx
				call 			divrbx10
				jmp 			.loop2
				
.afterLoop2:
				ret

; rbx *= 10				
mulrbx10:
				push 			rdx
				push 			rax
				xor 			rdx, rdx
				mov 			rax, rbx
				mov 			rbx, 10
				mul 			rbx
				mov 			rbx, rax
				pop				rax
				pop 			rdx
				ret

; rbx /= 10
divrbx10:
				push 			rdx
				push 			rax
				xor 			rdx, rdx
				mov 			rax, rbx
				mov 			rbx, 10
				div 			rbx
				mov 			rbx, rax
				pop 			rax
				pop 			rdx
				ret
; rax - digit
print_digit:
; rax = 1 -> syscall = sys_write
; sys_write(rdi(fd), rsi(char buf), rdx(count))
				push 			rdx
				lea 			rsi, [digits + rax]
				mov 			rax, 1
				mov 			rdi, 1
				mov 			rdx, 1
				syscall
				pop 			rdx
				ret

print_line_separator:
; rax = 1 -> syscall = sys_write
; sys_write(rdi(fd), rsi(char buf), rdx(count))
				push			rax
				push 			rdx
				mov				rax, 1
				mov				rdi, 1
				mov				rsi, line_separator
				mov				rdx, 1
				syscall
				pop				rdx
				pop 			rax
				ret

exit:
				mov 			rax, 60
				xor				rdi, rdi
				syscall

; #######################################################################
; ######################## END OF NUMBER_PRINTER ########################
; #######################################################################

				section         .rodata
digits:			db				"0123456789"
line_separator	db				0x0a

error_msg:      db              "Error occured :(",0x0a
error_msg_size: equ				$ - error_msg

				section 		.bss
buf:			resb			1
