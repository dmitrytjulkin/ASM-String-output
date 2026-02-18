.model tiny
.code
org 100h

VIDEOSEG 		equ 0b800h 
CENTER_OF_FRAME		equ 007CAh
PLACE_OF_UPPER_BORDER	equ 000A0h
PLACE_OF_LOWER_BORDER	equ 0FF60h

PLACE_OF_FIRST_CMD	equ 00082h
PLACE_OF_SECOND_CMD	equ 00085h
PLACE_OF_INPUT		equ 00088h

COUNT_TO_SKIP		equ 7

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

	call BuildFrame

	mov ax, 4c00h
	int 21h
;___________________________________________________________________________;


;__BUILDFRAME__
;Printing framed input string with special color
;Entry: -
;Exit: -
;Destr: AX, BX, CX, DX, DI
;___________________________________________________________________________;
BuildFrame		proc
	mov ah, TEXT_COLOR			;init color of text

	call BuildTopCorners

	mov dx, PLACE_OF_UPPER_BORDER
	call BuildHorizontalBorder

	call PrintSentence

;	call BuildVerticalBorder

	mov dx, PLACE_OF_LOWER_BORDER
	call BuildHorizontalBorder

	call BuildBottomCorners

	ret
	endp
;___________________________________________________________________________;


;__BUILDHORIZONTALBORDER__
;Printing the top and bottom horizontal borders 
;Entry: al = color of the text
;Exit: -
;Destr: AH, BX, CX, DI
;___________________________________________________________________________;
BuildHorizontalBorder	proc
	call FindInputStrlen

	mov bx, cx
	call RoundBxToEvenNum
	sub dx, CENTER_OF_FRAME
	add bx, dx			;choose if it top border or bottom
	neg bx
	mov di, bx			;di = place to print

	mov al, HORIZONTAL_BORDER

	xor bx, bx

building_border:
	shl bx, 1
	mov es:[di+bx], ax
	shr bx, 1

	inc bx

	loop building_border

	ret
	endp
;___________________________________________________________________________;


;__PRINTSENTENCE__
;Printing the input string and vertical borders on each side.
;Entry: al = color of text
;Exit: -
;Destr: AH, BX, CX, DI
;___________________________________________________________________________;
PrintSentence 		proc
	call FindInputStrlen

	mov bx, cx
	call RoundBxToEvenNum
	sub bx, CENTER_OF_FRAME
	neg bx
	mov di, bx

	mov al, VERTICAL_BORDER 
	mov es:[di-2], ax		;printing left border

	mov al, ds:[PLACE_OF_INPUT]	;al = the 1st symbol of input

	xor bx, bx
	
building_sentence:
	shl bx, 1
	mov es:[di+bx], ax
	shr bx, 1

	inc bx
	mov al, ds:[PLACE_OF_INPUT+bx]

	loop building_sentence

	shl bx, 1
	mov al, VERTICAL_BORDER
	mov es:[di+bx], ax		;printing right border

	ret
	endp
;___________________________________________________________________________;


;__BUILDTOPCORNERS__
;Printing top right and left corners.
;Entry: al = color of text
;Exit: -
;Destr: AH, BX, CX, DI
;___________________________________________________________________________;
BuildTopCorners		proc
	call FindInputStrlen	
	
	mov bx, cx
	call RoundBxToEvenNum
	mov di, CENTER_OF_FRAME
	sub di, PLACE_OF_UPPER_BORDER	;di = same row as border, but in center
	sub di, bx

	mov al, TOP_LEFT_CORNER
	sub di, 2			;di = the start of top border
	mov es:[di], ax

	shl cx, 1

	mov al, TOP_RIGHT_CORNER
	add di, cx			;di = the end of top border
	mov es:[di+2], ax			

	ret
	endp
;___________________________________________________________________________;


;__BUILDBOTTOMCORNERS__
;Printing bottom left and right corners of frame.  
;Entry: AH = color of the text
;Exit: -
;Destr: AH, BX, CX, DI
;___________________________________________________________________________;
BuildBottomCorners	proc
	call FindInputStrlen

	mov bx, cx
	call RoundBxToEvenNum
	mov di, CENTER_OF_FRAME
	sub di, PLACE_OF_LOWER_BORDER	;di = same row as border, but in center
	sub di, bx

	mov al, BOTTOM_LEFT_CORNER
	sub di, 2
	mov es:[di], ax			;printing bottom left corner

	shl cx, 1
	
	mov al, BOTTOM_RIGHT_CORNER
	add di, cx
	mov es:[di+2], ax		;printing bottom right corner

	ret
	endp
;___________________________________________________________________________;


;__SETCYCLECOUNTER__
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