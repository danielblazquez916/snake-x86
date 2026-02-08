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
direction resd 1 ;4 bytes


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

set_on_board:
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

left:
	SUB byte [snake],1
	MOV dword [direction],left
	JMP set_on_board

up:
	SUB byte [snake+1],1
	MOV dword [direction],up
	JMP set_on_board

right:
	ADD byte [snake],1
	MOV dword [direction],right
	JMP set_on_board

down:
	ADD byte [snake+1],1
	MOV dword [direction],down
	JMP set_on_board

JMP_dir:
	JMP [direction]

get_key:
	MOV eax,3
	MOV ebx,0
	MOV ecx,buffer
	MOV edx,1
	INT 0x80

	CMP eax,0
	JL JMP_dir

	CMP byte [buffer],'w'
	JE up

	CMP byte [buffer],'a'
	JE left

	CMP byte [buffer],'s'
	JE down

	CMP byte [buffer],'d'
	JE right

	JMP get_key

update:
	CMP byte [snake+1],0
	JBE exit

	MOV al,[height]
	SUB al,1
	CMP [snake+1],al
	JAE exit

	CMP byte [snake],0
	JBE exit

	MOV al,[width]
	SUB al,1
	CMP [snake],al
	JAE exit

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

	JMP get_key


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

	MOV eax,55
	MOV ebx,0
	MOV ecx,3
	MOV edx,0
	INT 0x80

	OR eax,0x800

	MOV ebx,0
	MOV ecx,4
	MOV edx,eax
	MOV eax,55
	INT 0x80

	MOV dword [direction],up

	MOV byte [width],20
	MOV byte [height],20

	JMP get_cells
