section .data
nl DB 0x0A,0x0A
term_raw: times 36 DB 0
term_orig: times 36 DB 0
ts:
	DD 1
	DD 0
apple: times 2 DB 0

section .bss
board resb 10000
snake resb 40000
turn_points resb 3000
turn_count resb 2
snake_count resb 2
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

set_on_board:
	MOV al,[snake+ecx+1]
	MOV bl,[width]
	MUL bl
	MOV bl,[snake+ecx]
	XOR bh,bh
	ADD ax,bx

	LEA edi,[board]
	MOVZX eax,ax
	ADD edi,eax

	MOV byte [edi],'#'
	LEA edi,[board]

	MOV ax,cx
	MOV bx,3
	XOR dx,dx
	DIV bx

	CMP ax,[snake_count]
	JE render

	ADD cx,3
	JMP set_on_board

move_to_up:
	SUB byte [snake+ecx+1],1
	JMP snake_loop

move_to_left:
	SUB byte [snake+ecx],1
	JMP snake_loop

move_to_right:
	ADD byte [snake+ecx],1
	JMP snake_loop

move_to_down:
	ADD byte [snake+ecx+1],1
	JMP snake_loop

move_to:
	CMP [snake+ecx+2],'u'
	JE move_to_up

	CMP [snake+ecx+2],'l'
	JE move_to_left

	CMP [snake+ecx+2],'d'
	JE move_to_down

	CMP [snake+ecx+2],'r'
	JE move_to_right

before_set_on_board:
	XOR ecx,ecx
	MOV word [esp],0

	JMP set_on_board

snake_loop:
	MOV ax,cx
	XOR dx,dx
	MOV bx,4
	DIV bx

	CMP ax,[snake_count]
	JE before_set_on_board

	ADD cx,4
	JMP set_turn

set_dir:
	MOV al,[edi+2]
	MOV [snake+ecx+2],al

	ADD byte [snake+ecx+3],1

	JMP move_to

y_equal:
	MOV al,[edi+1]

	CMP [snake+ecx+1],al
	JE set_dir

set_turn:
	MOV al,[snake+ecx+3]
	CMP word [turn_count],al
	JBE move_to

	LEA edi,[turn_points]

	MOV al,[snake+ecx+3]
	MOV bl,3
	MUL bl
	MOVZX eax,ax

	ADD edi,eax
	MOV al,[edi]

	CMP [snake+ecx],al
	JE y_equal

	JMP move_to

down:
	LEA edi,[turn_points]

	MOV ax,[turn_count]
	MOV bx,3
	MUL bx
	MOVZX eax,ax
	ADD edi,eax

	MOV al,[snake]
	MOV [edi],al

	MOV al,[snake+1]
	MOV [edi+1],al

	MOV byte [edi+2],'d'

	ADD byte [snake+1],1

	ADD word [turn_count],1

	JMP get_apple


; recolocar de forma randomizada la manzana
; colocar la manzana en el tablero

random_pos_apple:
	JMP set_turn

left_dir_seg_realloc:
	ADD byte [edi+4],1
	JMP random_pos_apple

down_dir_seg_realloc:
	SUB byte [edi+5],1
	JMP random_pos_apple

up_dir_seg_realloc:
	ADD byte [edi+5],1
	JMP random_pos_apple

right_dir_seg_realloc:
	ADD byte [edi+4],1
	JMP random_pos_apple

add_segment:
	LEA edi,[snake]
	MOV ax,[snake_count]
	MOV bx,4
	MUL bx
	MOVZX eax,ax
	ADD edi,eax

	MOV al,[edi+3]
	MOV [edi+7],al

	MOV al,[edi+2]
	MOV [edi+6],al

	MOV al,[edi+1]
	MOV [edi+5],al

	MOV al,[edi]
	MOV [edi+4],al

	CMP [edi+6],'u'
	JE up_dir_seg_realloc

	CMP [edi+6],'l'
	JE left_dir_seg_realloc

	CMP [edi+6],'d'
	JE down_dir_seg_realloc

	CMP [edi+6],'r'
	JE right_dir_seg_realloc

get_apple:
	MOV al,[apple]
	XOR al,[snake]

	MOV cl,[apple+1]
	XOR cl,[snake+1]

	OR al,cl
	CMP al,0
	JE add_segment

	XOR ecx,ecx
	JMP set_turn

get_key:
	MOV eax,3
	MOV ebx,0
	MOV ecx,buffer
	MOV edx,1
	INT 0x80

	CMP eax,0
	JL move_snake

	CMP byte [buffer],'w'
	JE up

	CMP byte [buffer],'a'
	JE left

	CMP byte [buffer],'s'
	JE down

	CMP byte [buffer],'d'
	JE right

	JMP get_key

clear_snake:
	MOV al,[snake+ecx+1]
	MOV bl,[width]
	MUL bl
	MOV bl,[snake+ecx]
	XOR bh,bh
	ADD ax,bx

	LEA edi,[board]
	MOVZX eax,ax
	ADD edi,eax

	MOV byte [edi],'.'

	MOV ax,cx
	MOV bx,4
	XOR dx,dx
	DIV bx

	CMP ax,[snake_count]
	JE get_key

	ADD cx,4
	JMP clear_snake


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

	XOR ecx,ecx
	JMP clear_snake

snake_save:
	MOV al,[snake+ecx+1]
	MOV bl,[width]
	MUL bl
	MOV bl,[snake+ecx]
	XOR bh,bh
	ADD ax,bx

	LEA edi,[board]
	MOVZX eax,ax
	ADD edi,eax
	MOV byte [edi],'#'

	MOV ax,cx
	MOV bx,4
	XOR dx,dx
	DIV bx

	CMP ax,[snake_count]
	JE render

	ADD cx,4
	JMP snake_save

start_GameLoop:
	MOV byte [snake],10
	MOV byte [snake+1],10
	MOV byte [snake+2],'u'
	MOV byte [snake+3],0

	MOV word [snake_count],0

	MOV byte [snake+4],10
	MOV byte [snake+5],11
	MOV byte [snake+6],'u'
	MOV byte [snake+7],0

	ADD word [snake_count],1

	MOV word [turn_count],0

	LEA edi,[board]
	XOR ecx,ecx

	JMP snake_save

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
