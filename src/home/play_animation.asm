; writes from hl the pointer to the function to be called by DoFrame
SetDoFrameFunction::
	ld a, l
	ld [wDoFrameFunction], a
	ld a, h
	ld [wDoFrameFunction + 1], a
	ret

ResetDoFrameFunction::
	push hl
	ld hl, NULL
	call SetDoFrameFunction
	pop hl
	ret
