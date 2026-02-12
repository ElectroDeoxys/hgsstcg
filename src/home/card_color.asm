; input: a = play area location offset (PLAY_AREA_*) of the desired card
; return the turn holder's card's color in a, accounting for Venomoth's Shift Pokemon Power if active
GetPlayAreaCardColor::
	push hl
	push de
	ld e, a
	add DUELVARS_ACTIVE_CARD_CHANGED_TYPE
	get_turn_duelist_var
	bit HAS_CHANGED_COLOR_F, a
	jr nz, .has_changed_color
	ld a, e
	add DUELVARS_ACTIVE
	get_turn_duelist_var
	call GetCardIDFromDeckIndex
	call GetCardType
	pop de
	pop hl
	ret
.has_changed_color
	ld a, e
	add DUELVARS_ACTIVE_CARD_CHANGED_TYPE
	get_turn_duelist_var
	pop de
	pop hl
	and $f
	ret

; return in a the weakness of the turn holder's active or benchx Pokemon given the PLAY_AREA_* value in a
; if a == 0 and [DUELVARS_ACTIVE_CARD_CHANGED_WEAKNESS] != 0,
; return [DUELVARS_ACTIVE_CARD_CHANGED_WEAKNESS] instead
GetPlayAreaCardWeakness::
	or a
	jr z, GetActiveCardWeakness
	add DUELVARS_ACTIVE
	jr GetCardWeakness

; return in a the weakness of the turn holder's active Pokemon
; if [DUELVARS_ACTIVE_CARD_CHANGED_WEAKNESS] != 0, return it instead
GetActiveCardWeakness::
	ld a, DUELVARS_ACTIVE
GetCardWeakness::
	get_turn_duelist_var
	; TODO
	;call LoadCardDataToBuffer2_FromDeckIndex
	ld a, [wLoadedCard2Weakness]
	ret

; return in a the resistance of the turn holder's active or benchx Pokemon given the PLAY_AREA_* value in a
; if a == 0 and [DUELVARS_ACTIVE_CARD_CHANGED_RESISTANCE] != 0,
; return [DUELVARS_ACTIVE_CARD_CHANGED_RESISTANCE] instead
GetPlayAreaCardResistance::
	or a
	jr z, GetActiveCardResistance
	add DUELVARS_ACTIVE
	jr GetCardResistance

; return in a the resistance of the active Pokemon
; if [DUELVARS_ACTIVE_CARD_CHANGED_RESISTANCE] != 0, return it instead
GetActiveCardResistance::
	ld a, DUELVARS_ACTIVE
GetCardResistance::
	get_turn_duelist_var
	; TODO
	;call LoadCardDataToBuffer2_FromDeckIndex
	ld a, [wLoadedCard2Resistance]
	ret
