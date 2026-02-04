section .data
nl DB 0x0A

section .bss
board resb 10000
width resb 1
height resb 1
cells resb 2

section .text
global _start

exit:
	ADD esp,2

	MOV eax,4
	MOV ebx,1
	MOV ecx,nl
	MOV edx,1
	INT 0x80

	MOV eax,1
	INT 0x80

new_line:
	MOV eax,4
	MOV ebx,1
	MOV ecx,nl
	MOV edx,1
	INT 0x80

	JMP print

print:
	MOV eax,4
	MOV ebx,1
	MOV ecx,edi
	MOV edx,1
	INT 0x80

	ADD edi,1

	ADD word [esp],1
	MOV ax,[esp]
	CMP ax,[cells]
	JE exit

	MOV cl,[width]
	XOR ch,ch
	XOR dx,dx
	DIV cx
	CMP dx,0
	JE new_line

	JMP print

free:
	LEA edi,[board]

	JMP print

save_loop:
	SUB word [esp],1

	MOV byte [edi],'.'

	CMP word [esp],0
	JE free

	ADD edi,1
	JMP save_loop

save:
	MOV al,[width]
	MOV bl,[height]
	MUL bl
	MOV [cells],ax

	SUB esp,2
	MOV [esp],ax

	LEA edi,[board]
	JMP save_loop

_start:
	MOV byte [width],20
	MOV byte [height],20

	JMP save
