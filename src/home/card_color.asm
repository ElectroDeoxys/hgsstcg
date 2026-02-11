; input: a = play area location offset (PLAY_AREA_*) of the desired card
; return the turn holder's card's color in a, accounting for Venomoth's Shift Pokemon Power if active
GetPlayAreaCardColor::
	push hl
	push de
	ld e, a
	add DUELVARS_ARENA_CARD_CHANGED_TYPE
	call GetTurnDuelistVariable
	bit HAS_CHANGED_COLOR_F, a
	jr nz, .has_changed_color
	ld a, e
	add DUELVARS_ARENA_CARD
	call GetTurnDuelistVariable
	call GetCardIDFromDeckIndex
	call GetCardType
	pop de
	pop hl
	ret
.has_changed_color
	ld a, e
	add DUELVARS_ARENA_CARD_CHANGED_TYPE
	call GetTurnDuelistVariable
	pop de
	pop hl
	and $f
	ret

; return in a the weakness of the turn holder's arena or benchx Pokemon given the PLAY_AREA_* value in a
; if a == 0 and [DUELVARS_ARENA_CARD_CHANGED_WEAKNESS] != 0,
; return [DUELVARS_ARENA_CARD_CHANGED_WEAKNESS] instead
GetPlayAreaCardWeakness::
	or a
	jr z, GetArenaCardWeakness
	add DUELVARS_ARENA_CARD
	jr GetCardWeakness

; return in a the weakness of the turn holder's arena Pokemon
; if [DUELVARS_ARENA_CARD_CHANGED_WEAKNESS] != 0, return it instead
GetArenaCardWeakness::
	ld a, DUELVARS_ARENA_CARD_CHANGED_WEAKNESS
	call GetTurnDuelistVariable
	or a
	ret nz
	ld a, DUELVARS_ARENA_CARD
;	fallthrough

GetCardWeakness::
	call GetTurnDuelistVariable
	; TODO
	;call LoadCardDataToBuffer2_FromDeckIndex
	ld a, [wLoadedCard2Weakness]
	ret

; return in a the resistance of the turn holder's arena or benchx Pokemon given the PLAY_AREA_* value in a
; if a == 0 and [DUELVARS_ARENA_CARD_CHANGED_RESISTANCE] != 0,
; return [DUELVARS_ARENA_CARD_CHANGED_RESISTANCE] instead
GetPlayAreaCardResistance::
	or a
	jr z, GetArenaCardResistance
	add DUELVARS_ARENA_CARD
	jr GetCardResistance

; return in a the resistance of the arena Pokemon
; if [DUELVARS_ARENA_CARD_CHANGED_RESISTANCE] != 0, return it instead
GetArenaCardResistance::
	ld a, DUELVARS_ARENA_CARD_CHANGED_RESISTANCE
	call GetTurnDuelistVariable
	or a
	ret nz
	ld a, DUELVARS_ARENA_CARD
;	fallthrough

GetCardResistance::
	call GetTurnDuelistVariable
	; TODO
	;call LoadCardDataToBuffer2_FromDeckIndex
	ld a, [wLoadedCard2Resistance]
	ret
