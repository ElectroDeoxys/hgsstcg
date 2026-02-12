; shuffles an a-sized list in hl
ShuffleList::
	push hl
	push bc
	push de
	ld b, a
	ld c, a
	ld e, l
	ld d, h

.loop
	ld a, b
	call Random
	; swap [hl] with a-th index
	push de
	push bc
	add e
	ld e, a
	ld a, 0
	adc d
	ld d, a
	ld a, [de]
	ld b, a
	ld a, [hl]
	ld [de], a
	ld a, b
	ld [hli], a
	pop bc
	pop de
	dec c
	jr nz, .loop

	pop de
	pop bc
	pop hl
	ret

; creates list of turn-duelist hand cards in wList
; returns number of cards in a, and cerry set if empty
CreateHandCardList::
	push hl
	push de
	ld a, DUELVARS_CARD_LOCATIONS
	get_turn_duelist_var
	ld de, wList
.loop_cards
	ld a, [hli]
	dec a ; cp CARD_LOCATION_HAND
	jr nz, .next_card
	ld a, l
	dec a
	ld [de], a
	inc de
.next_card
	ld a, l
	cp DUELVARS_CARD_LOCATIONS + DECK_SIZE
	jr nz, .loop_cards
	ld a, -1
	ld [de], a ; terminating byte
	ld a, e
	pop de
	pop hl
	or a
	ret nz ; has cards
	scf ; no cards
	ret
