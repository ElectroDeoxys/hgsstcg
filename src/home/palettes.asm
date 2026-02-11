; Flush all non-CGB and CGB palettes
FlushAllPalettes::
	ld a, FLUSH_ALL_PALS
	jr FlushPalettes

; Set wBGP to the specified value, flush non-CGB palettes, and the first CGB palette.
SetBGP::
	ld [wBGP], a
;	fallthrough

; Flush non-CGB palettes and the first CGB palette
FlushPalette0::
	ld a, FLUSH_ONE_PAL
;	fallthrough

FlushPalettes::
	ld [wFlushPaletteFlags], a
	ld a, [wLCDC]
	rla
	ret c
	push hl
	push de
	push bc
	call FlushPalettesIfRequested
	pop bc
	pop de
	pop hl
	ret

; Set wOBP0 to the specified value, flush non-CGB palettes, and the first CGB palette.
SetOBP0::
	ld [wOBP0], a
	jr FlushPalette0

; Set wOBP1 to the specified value, flush non-CGB palettes, and the first CGB palette.
SetOBP1::
	ld [wOBP1], a
	jr FlushPalette0

; Flushes non-CGB palettes from [wBGP], [wOBP0], [wOBP1] as well as CGB
; palettes from [wBackgroundPalettesCGB..wBackgroundPalettesCGB+$3f] (BG palette)
; and [wObjectPalettesCGB+$00..wObjectPalettesCGB+$3f] (sprite palette).
; Only flushes if [wFlushPaletteFlags] is nonzero, and only flushes
; a single CGB palette if bit6 of that location is reset.
FlushPalettesIfRequested::
	ld a, [wFlushPaletteFlags]
	or a
	ret z
	; flush grayscale (non-CGB) palettes
	ld hl, wBGP
	ld a, [hli]
	ldh [rBGP], a
	ld a, [hli]
	ldh [rOBP0], a
	ld a, [hl]
	ldh [rOBP1], a
	ld a, [wConsole]
	cp CONSOLE_CGB
	jr z, .CGB
.done
	xor a
	ld [wFlushPaletteFlags], a
	ret
.CGB
	; flush a single CGB BG or OB palette
	; if bit6 (FLUSH_ALL_PALS_F) of [wFlushPaletteFlags] is set, flush all 16 of them
	ld a, [wFlushPaletteFlags]
	bit FLUSH_ALL_PALS_F, a
	jr nz, FlushAllCGBPalettes
	ld b, PAL_SIZE
	call CopyCGBPalettes
	jr .done

FlushAllCGBPalettes::
	; flush 8 BGP palettes
	xor a ; start with BGP0 (wBackgroundPalettesCGB)
	ld b, 8 palettes
	call CopyCGBPalettes
	; flush 8 OBP palettes
	ld a, NUM_BACKGROUND_PALETTES ; skip all background palettes and start with OBP0 (wObjectPalettesCGB)
	ld b, 8 palettes
	call CopyCGBPalettes
	jr FlushPalettesIfRequested.done

; copy b bytes of CGB palette data starting at
; (wBackgroundPalettesCGB + a palettes) into rBGPD or rOBPD.
CopyCGBPalettes::
	add a ; *2
	add a ; *4
	add a ; *8 (PAL_SIZE)
	ld e, a
	ld d, $0
	ld hl, wBackgroundPalettesCGB
	add hl, de
	ld c, LOW(rBGPI)
	bit 6, a ; was a between 0-7 (BGP), or between 8-15 (OBP)?
	jr z, .copy
	ld c, LOW(rOBPI)
.copy
	and %10111111
	ld e, a
.next_byte
	ld a, e
	ld [$ff00+c], a
	inc c
.wait
	ldh a, [rSTAT]
	and STAT_BUSY ; wait until hblank or vblank
	jr nz, .wait
	ld a, [hl]
	ld [$ff00+c], a
	ld a, [$ff00+c]
	cp [hl]
	jr nz, .wait
	inc hl
	dec c
	inc e
	dec b
	jr nz, .next_byte
	ret

; set the default game palettes
; BGP0 to BGP5 and OBP1 on CGB
SetDefaultConsolePalettes::
	ld a, $1
	ld [wTextBoxFrameType], a
	ld de, CGBDefaultPalettes
	ld hl, wBackgroundPalettesCGB
	ld c, 5 palettes
	call .copy_de_to_hl
	ld de, CGBDefaultPalettes
	ld hl, wObjectPalettesCGB
	ld c, PAL_SIZE
	call .copy_de_to_hl
	jp FlushAllPalettes

.copy_de_to_hl
	ld a, [de]
	inc de
	ld [hli], a
	dec c
	jr nz, .copy_de_to_hl
	ret

CGBDefaultPalettes:
; BGP0 and OBP0
	rgb 28, 28, 24
	rgb 21, 21, 16
	rgb 10, 10, 8
	rgb 0, 0, 0
; BGP1
	rgb 28, 28, 24
	rgb 26, 10, 0
	rgb 28, 0, 0
	rgb 0, 0, 0
; BGP2
	rgb 28, 28, 24
	rgb 30, 29, 0
	rgb 30, 3, 0
	rgb 0, 0, 0
; BGP3
	rgb 28, 28, 24
	rgb 0, 18, 0
	rgb 12, 11, 20
	rgb 0, 0, 0
; BGP4
	rgb 28, 28, 24
	rgb 22, 0, 22
	rgb 27, 7, 3
	rgb 0, 0, 0
