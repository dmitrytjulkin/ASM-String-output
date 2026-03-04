.model tiny
.code
org 100h

VIDEOSEG 				equ 0b800h
ADDRESS_OF_FRAME		equ 007D0h
NEIGHBOR_BY_VERTICAL	equ 000A0h

;ADDRESS_OF_FIRST_CMD	equ 00082h
;ADDRESS_OF_SECOND_CMD	equ 00085h
ADDRESS_OF_INPUT		equ 00082h

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
					VER_BRDR, SPACE, VER_BRDR, BL_BRDR, \
					BL_BRDR, HOR_BRDR, BR_BRDR

.code
	mov ax, VIDEOSEG
	mov es, ax

	mov al, ds:[80h]
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
;Destr: AL, BX, CX, DI
;___________________________________________________________________________;
PrintFrame		proc
	call PrintUpperBorder

	call PrintVerticalBorderAndBackground

	call PrintLowerBorder

	ret
	endp
;___________________________________________________________________________;


;__PRINTUPPERBORDER__
;Printing the top and bottom horizontal borders
;Entry: AH = color of the text
;Exit: -
;Destr: AL, BX, CX, DI
;___________________________________________________________________________;
PrintUpperBorder	proc
	mov cl, str_len

	mov bx, cx
	shr bx, 1
	shl bx, 1
	add bx, NEIGHBOR_BY_VERTICAL
	sub bx, ADDRESS_OF_FRAME
	neg bx
	mov di, bx			;di = address to print

	mov al, TL_BRDR
	mov es:[di-2], ax		;printing top left corner

	mov al, HOR_BRDR
	xor bx, bx

build_string:
	shl bx, 1
	mov es:[di+bx], ax
	shr bx, 1

	inc bx

	loop build_string

	mov al, TR_BRDR
	shl bx, 1
	mov es:[di+bx], ax		;printing top right corner

	ret
	endp
;___________________________________________________________________________;


;__PRINTLOWERBORDER__
;Printing lower border (include lower corners) in special color
;Entry: AH - color of border
;Destr: AX, BX, CX, DI
;___________________________________________________________________________;
PrintLowerBorder 	proc
	mov cl, str_len

	mov bx, cx
	shr bx, 1
	shl bx, 1
	neg bx
	add bx, ADDRESS_OF_FRAME
	add bx, NEIGHBOR_BY_VERTICAL
	mov di, bx			;di = address to print

	mov al, BL_BRDR
	mov es:[di-2], ax		;printing bottom left corner

	mov al, HOR_BRDR
	xor bx, bx

building_lower_border:
	shl bx, 1
	mov es:[di+bx], ax
	shr bx, 1

	inc bx

	loop building_lower_border

	mov al, BR_BRDR
	shl bx, 1
	mov es:[di+bx], ax		;printing bottom right corner

	ret
	endp
;___________________________________________________________________________;


;__PRINTVERTICALBORDERANDBACKGROUND__
;prints colored background and vertical borders (without corners)
;Entry: -
;Destr: AX, BX, CX, DI
;___________________________________________________________________________;
PrintVerticalBorderAndBackground	proc
	mov cl, str_len

	mov bx, cx
	shr bx, 1
	shl bx, 1
	neg bx
	add bx, ADDRESS_OF_FRAME
	mov di, bx

	mov al, VER_BRDR
	mov es:[di-2], ax

	xor al, al
	xor bx, bx

building_background:
	shl bx, 1
	mov es:[di+bx], ax
	shr bx, 1

	inc bx
	loop building_background

	mov al, VER_BRDR
	shl bx, 1
	mov es:[di+bx], ax

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

end		Start
