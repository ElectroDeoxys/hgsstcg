; copy the name of the card at wLoadedCard1 to wDefaultText
; a = length in number of tiles (the resulting string will be padded with spaces to match it)
_CopyCardName::
	push bc
	push de
	ld [wCardNameLength], a
	ld hl, wLoadedCard1Name
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld de, wDefaultText
	push de
	call CopyText ; copy card name to wDefaultText
	pop hl
	ld a, [hli]
	cp TX_HALFWIDTH
	jp z, _CopyCardName_HalfwidthText

; the name doesn't start with TX_HALFWIDTH
; this doesn't appear to be ever the case (unless caller manipulates wLoadedCard1Name)
	ld a, [wCardNameLength]
	ld c, a
	ld hl, wLoadedCard1Name
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld de, wDefaultText
	push de
	call CopyText
	pop hl
	push de
	ld e, c
	call GetTextLengthInTiles
	add e
	ld c, a
	pop hl
	push hl
.fill_loop
	ldfw a, " "
	ld [hli], a
	dec c
	jr nz, .fill_loop
	ld [hl], TX_END
	pop hl
	pop de
	pop bc
	ret

; the name starts with TX_HALFWIDTH
_CopyCardName_HalfwidthText:
	ld a, [wCardNameLength]
	inc a
	add a
	ld b, a
	ld hl, wDefaultText
.find_end_text_loop
	dec b
	ld a, [hli]
	or a ; TX_END
	jr nz, .find_end_text_loop
	dec hl
	push hl
	ld a, ' '
.fill_spaces_loop
	ld [hli], a
	dec b
	jr nz, .fill_spaces_loop
	ld [hl], TX_END
	pop hl
	pop de
	pop bc
	ret
