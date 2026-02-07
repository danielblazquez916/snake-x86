section .data
nl DB 0x0A,0x0A
term_raw: times 36 DB 0
term_orig: times 36 DB 0
ts:
	DD 1
	DD 0

section .bss
board resb 10000
snake resb 20000
width resb 1
height resb 1
cells resb 2
buffer resb 1


section .text
global _start

exit:
	ADD esp,2

	MOV eax,54
	MOV ebx,0
	MOV ecx,0x5402
	MOV edx,term_orig
	INT 0x80

	MOV eax,1
	INT 0x80

my_sleep:
	MOV eax,162
	LEA ebx,[ts]
	XOR ecx,ecx
	INT 0x80

	JMP update

separator:
	MOV word [esp],0
	LEA edi,[board]

	MOV eax,4
	MOV ebx,1
	MOV ecx,nl
	MOV edx,2
	INT 0x80

	JMP my_sleep

new_line:
	MOV eax,4
	MOV ebx,1
	MOV ecx,nl
	MOV edx,1
	INT 0x80

	JMP render


render:
	MOV eax,4
	MOV ebx,1
	MOV ecx,edi
	MOV edx,1
	INT 0x80

	ADD edi,1

	ADD word [esp],1
	MOV ax,[esp]
	CMP ax,[cells]
	JE separator

	MOV cl,[width]
	XOR ch,ch
	XOR dx,dx
	DIV cx
	CMP dx,0
	JE new_line

	JMP render

update:
	CMP byte [snake+1],0
	JBE exit

	MOV al,[snake+1]
	MOV bl,[width]
	MUL bl
	MOV bl,[snake]
	XOR bh,bh
	ADD ax,bx

	LEA edi,[board]
	MOVZX eax,ax
	ADD edi,eax

	MOV byte [edi],'.'

	SUB byte [snake+1],1 ; new position

	MOV al,[snake+1]
	MOV bl,[width]
	MUL bl
	MOV bl,[snake]
	XOR bh,bh
	ADD ax,bx

	LEA edi,[board]
	MOVZX eax,ax
	ADD edi,eax

	MOV byte [edi],'#'
	LEA edi,[board]

	JMP render


start_GameLoop:
	MOV byte [snake],10
	MOV byte [snake+1],10

	MOV al,[snake+1]
	MOV bl,[width]
	MUL bl
	MOV bl,[snake]
	XOR bh,bh
	ADD ax,bx

	LEA edi,[board]
	MOVZX eax,ax
	ADD edi,eax
	MOV byte [edi],'#'

	LEA edi,[board]

	JMP render

save:
	SUB word [esp],1

	MOV byte [edi],'.'

	CMP word [esp],0
	JE start_GameLoop

	ADD edi,1
	JMP save

get_cells:
	MOV al,[width]
	MOV bl,[height]
	MUL bl
	MOV [cells],ax

	SUB esp,2
	MOV [esp],ax

	LEA edi,[board]
	JMP save


_start:
	MOV eax,54
	MOV ebx,0
	MOV ecx,0x5401
	MOV edx,term_orig
	INT 0x80

	MOV esi,term_orig
	MOV edi,term_raw
	MOV ecx,36
	REP MOVSB

	MOV eax,[term_raw+12]
	AND eax,0xFFFFFFF5
	MOV [term_raw+12],eax

	MOV eax,54
	MOV ebx,0
	MOV ecx,0x5402
	MOV edx,term_raw
	INT 0x80

	MOV byte [width],20
	MOV byte [height],20

	JMP get_cells
