				global 			_start
				section 		.text

_start:

				pop             rax
				;cmp            rax, 2
				pop				rax
				mov				rax, 2
				pop             rdi
				xor             rsi, rsi
				xor             rdx, rdx
				syscall

				mov 			r10, rax

				xor 			rax, rax
				mov 			rdi, r10 
				mov 			rsi, symbol
				mov 			rdx, 1
				syscall

				mov 			rax, 1
				mov 			rdi, 1
				mov 			rsi, symbol
				mov 			rdx, 1
				syscall

				mov 			rax, 3
				mov 			rdi, r10
				syscall

				mov             rax, 60
				xor             rdi, rdi
				syscall

				section 		.bss
symbol: 		resb 			1
