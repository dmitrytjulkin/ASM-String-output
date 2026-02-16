.model tiny
.code
org 100h

VIDEOSEG 		equ 0b800h
START_OF_SENTENCE 	equ 000A0h 

start:
	mov ax, VIDEOSEG
	mov es, ax

	call UpperBorder

	call Sentence

	call LowerBorder

	mov ax, 4c00h
	int 21h
;___________________________________________________________________________;

;__UPPERBORDER__

;___________________________________________________________________________;
UpperBorder proc
	call SetCycleCounter

	mov al, 205		;al = upper border
	mov ah, 70h		;ah = white colour on black

	xor bx, bx

building_upper_border:
	shl bx, 1
	mov es:[bx], ax
	shr bx, 1
	
	inc bx

	loop building_upper_border

	ret
	endp
;___________________________________________________________________________;

;__SENTENCE__

;___________________________________________________________________________;
Sentence 	proc
	call SetCycleCounter

	mov al, ds:[82h]
	mov ah, 70h

	xor bx, bx

building_sentence:
	shl bx, 1
	mov es:[START_OF_SENTENCE+bx], ax
	shr bx, 1

	inc bx
	mov al, ds:[82h+bx]

	loop building_sentence

	ret
	endp
;___________________________________________________________________________;

;__LOWERBORDER__

;___________________________________________________________________________;
LowerBorder	proc
	call SetCycleCounter

	mov al, 205
	mov ah, 70h

	xor bx, bx 

building_lower_border:
	shl bx, 1
	mov es:[320+bx], ax
	shr bx, 1

	inc bx

	loop building_lower_border

	ret
	endp
;___________________________________________________________________________;

;__SETCYCLECOUNTER__

;___________________________________________________________________________;
SetCycleCounter proc
	mov cl, ds:[80h]
	dec cl

	ret
	endp
;__________________________________________________________________________;

end		Start