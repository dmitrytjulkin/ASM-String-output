.model tiny
.code
org 100h

VIDEOSEG 				equ 0b800h
ADDRESS_OF_FRAME		equ 007D0h
NEIGHBOR_BY_VERTICAL	equ 000A0h

;ADDRESS_OF_FIRST_CMD	equ 00082h
;ADDRESS_OF_SECOND_CMD	equ 00085h
ADDRESS_OF_INPUT		equ 00082h
ADDRESS_OF_INP_CNT		equ 00080h

COUNT_TO_SKIP			equ 001h

TEXT_COLOR				equ 070h

HOR_BRDR 	equ 0CDh
VER_BRDR	equ 0BAh
TL_BRDR		equ 0C9h
TR_BRDR		equ 0BBh
BL_BRDR		equ 0C8h
BR_BRDR		equ 0BCh
SPACE		equ 020h

start:
.data
	str_len db 0h
	frame_symb db 	TL_BRDR, HOR_BRDR, TR_BRDR, \
					VER_BRDR, SPACE, VER_BRDR,  \
					BL_BRDR, HOR_BRDR, BR_BRDR

.code
	mov ax, VIDEOSEG
	mov es, ax

	mov al, ds:[ADDRESS_OF_INP_CNT]
	dec al
	mov str_len, al

	mov ah, TEXT_COLOR

	call PrintFrame

	call PrintSentence

	mov ax, 4c00h
	int 21h
;___________________________________________________________________________;


;__PRINTFRAME__
;Printing frame with special color and with given size relative to sentence
;Entry: AH - color of symbols
;Destr: AL, BX, CX, DX, DI
;___________________________________________________________________________;
PrintFrame		proc
	xor dx, dx
	mov dl, str_len
	shr dl, 1
	shl dl, 1				;turn dx to closest and smaller even number

	mov bx, ADDRESS_OF_FRAME
	sub bx, NEIGHBOR_BY_VERTICAL
	sub bx, dx
	mov di, bx				;di = address to print (for stosw)

	mov cx, 3

build_frame:
	mov bx, 3
	sub bx, cx				;bx is using for addressing to frame_symb

	call MultiplyBxBy3
	mov al, frame_symb[bx]
	mov es:[di-2], ax		;printing the edge of string

	mov al, frame_symb[bx + 1]
	push cx					;save cx value for double cycle
	mov cl, str_len
	REP STOSW				;printing the center of string
	pop cx

	mov al, frame_symb[bx + 2]
	mov es:[di], ax			;printing the edge of string

	add di, NEIGHBOR_BY_VERTICAL
	mov dl, str_len
	sub di, dx
	sub di, dx				;addressing to the start of next string

	loop build_frame

	ret
	endp
;___________________________________________________________________________;


;__PRINTSENTENCE__
;Printing the input string
;Entry: AH = color of sentence
;Destr: AX, BX, CX, DI
;___________________________________________________________________________;
PrintSentence 		proc
	mov cl, str_len

	mov bx, cx
	shr bx, 1
	shl bx, 1
	neg bx
	add bx, ADDRESS_OF_FRAME
	mov di, bx

	mov al, ds:[ADDRESS_OF_INPUT]	;al = the 1st symbol of input
	xor bx, bx

building_sentence:
	shl bx, 1
	mov es:[di+bx], ax
	shr bx, 1

	inc bx
	mov al, ds:[bx+ADDRESS_OF_INPUT]

	loop building_sentence

	ret
	endp
;___________________________________________________________________________;


;___________________________________________________________________________;
MultiplyBxBy3	proc
	push ax dx
	mov ax, bx
	mov dx, 3
	mul dx					;multiplying bx by 3
	mov bx, ax
	pop dx ax

	ret
	endp

end		Start
