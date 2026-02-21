.model tiny
.code
org 100h

VIDEOSEG 		equ 0b800h 
ADRESS_OF_FRAME		equ 007D0h
NEIGHBOR_BY_VERTICAL	equ 000A0h

;ADRESS_OF_FIRST_CMD	equ 00082h
;ADRESS_OF_SECOND_CMD	equ 00085h
ADRESS_OF_INPUT		equ 00082h

COUNT_TO_SKIP		equ 00001h	;have to skeep one space

TEXT_COLOR		equ 070h

HORIZONTAL_BORDER 	equ 0CDh
VERTICAL_BORDER		equ 0BAh
TOP_LEFT_CORNER		equ 0C9h
TOP_RIGHT_CORNER	equ 0BBh
BOTTOM_LEFT_CORNER	equ 0C8h
BOTTOM_RIGHT_CORNER	equ 0BCh

start:
	mov ax, VIDEOSEG
	mov es, ax

	mov ah, TEXT_COLOR

	call PrintFrame

	call PrintSentence

	mov ax, 4c00h
	int 21h
;___________________________________________________________________________;


;__PRINTFRAME__
;Printing frame with special color and with given size relative to sentence
;Entry: AH - color of symbols
;Exit: -
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
	call FindInputStrlen

	mov bx, cx
	call RoundBxToEvenNum
	add bx, NEIGHBOR_BY_VERTICAL
	sub bx, ADRESS_OF_FRAME
	neg bx
	mov di, bx			;di = adress to print

	mov al, TOP_LEFT_CORNER
	mov es:[di-2], ax		;printing top left corner
	
	mov al, HORIZONTAL_BORDER
	xor bx, bx

building_upper_border:
	shl bx, 1
	mov es:[di+bx], ax
	shr bx, 1

	inc bx

	loop building_upper_border

	mov al, TOP_RIGHT_CORNER
	shl bx, 1
	mov es:[di+bx], ax		;printing top right corner

	ret
	endp
;___________________________________________________________________________;


;__PRINTLOWERBORDER__
;Printing lower border (include lower corners) in special color
;Entry: AH - color of border
;Exit: -
;Destr: AL, BX, CX, DI
;___________________________________________________________________________;
PrintLowerBorder 	proc
	call FindInputStrlen

	mov bx, cx
	call RoundBxToEvenNum
	neg bx
	add bx, ADRESS_OF_FRAME
	add bx, NEIGHBOR_BY_VERTICAL 
	mov di, bx			;di = adress to print

	mov al, BOTTOM_LEFT_CORNER
	mov es:[di-2], ax		;printing bottom left corner

	mov al, HORIZONTAL_BORDER
	xor bx, bx

building_lower_border:
	shl bx, 1
	mov es:[di+bx], ax
	shr bx, 1

	inc bx

	loop building_lower_border

	mov al, BOTTOM_RIGHT_CORNER
	shl bx, 1
	mov es:[di+bx], ax		;printing bottom right corner

	ret
	endp
;___________________________________________________________________________;

;___________________________________________________________________________;
PrintVerticalBorderAndBackground	proc
	call FindInputStrlen

	mov bx, cx
	call RoundBxToEvenNum
	neg bx
	add bx, ADRESS_OF_FRAME
	mov di, bx 

	mov al, VERTICAL_BORDER
	mov es:[di-2], ax

	xor al, al
	xor bx, bx

building_background:
	shl bx, 1
	mov es:[di+bx], ax
	shr bx, 1
	
	inc bx
	loop building_background

	mov al, VERTICAL_BORDER
	shl bx, 1
	mov es:[di+bx], ax

	ret
	endp
;___________________________________________________________________________;

;__PRINTSENTENCE__
;Printing the input string
;Entry: AH = color of sentence
;Exit: -
;Destr: AL, BX, CX, DI
;___________________________________________________________________________;
PrintSentence 		proc
	call FindInputStrlen

	mov bx, cx
	call RoundBxToEvenNum
	neg bx
	add bx, ADRESS_OF_FRAME
	mov di, bx

	mov al, ds:[ADRESS_OF_INPUT]	;al = the 1st symbol of input
	xor bx, bx
	
building_sentence:
	shl bx, 1
	mov es:[di+bx], ax
	shr bx, 1

	inc bx
	mov al, ds:[bx+ADRESS_OF_INPUT]

	loop building_sentence

	ret
	endp
;___________________________________________________________________________;


;__FINDINPUTSTRLEN__
;Setting cx as counter of input symbols (the max value is 0EEh)
;Entry: -
;Exit: cx = count of input symbols
;Destr: -
;___________________________________________________________________________;
FindInputStrlen	proc
	mov cl, ds:[80h]
	mov ch, 00
	
	sub cx, COUNT_TO_SKIP

	ret
	endp
;__________________________________________________________________________;


;__ROUNDBXTOEVENNUM__
;Rounding value in bx to the nearest and the lowest even number
;Entry: BX = value
;Exit: BX = even value
;Destr: -
;__________________________________________________________________________;
RoundBxToEvenNum		proc
	shr bx, 1
	shl bx, 1

	ret
	endp
;__________________________________________________________________________;

end		Start