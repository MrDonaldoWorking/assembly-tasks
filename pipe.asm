				section         .text
				global          _start

_start:

again:
				; rax = 0 -> sys_read
				; fd(rdi) = 0 -> stdin
				xor             rax, rax
				mov             rdi, 0
				mov 			rsi, buf
				mov				rdx, 1024
				syscall

				; res in rax: if rax > 0 -- quantity of read bytes
				; rax = 0 -> EOF
				; rax < 0 -> ошибка
				cmp 			rax, 0
				jl 				read_fail
				je 				exit

				; rax = 1 -> sys_write
				; fd(rdi) = 1 -> stdout
				mov 			rdx, rax
				mov             rax, 1
				mov             rdi, 1
				mov             rsi, buf
				syscall

				cmp 			rax, rdx
				jne				write_fail
				jmp				again

				; ud2 - "невалидная команда" (illegal insutction)
				read_fail: 		ud2
				write_fail: 	ud2
				exit:			mov rax, 60
								xor rdi, rdi
								syscall

				; resb in .data for initialized datas
				section .bss
				; resb - зарезервировать сколько-то байт
buf:			resb			1024
