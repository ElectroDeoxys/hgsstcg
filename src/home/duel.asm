; returns [([hWhoseTurn] ^ $1) << 8 + a] in a and in [hl]
; i.e. duelvar a of the player whose turn it is not
GetNonTurnDuelistVariable::
	ld l, a
	ldh a, [hWhoseTurn]
	ld h, OPPONENT_TURN
	cp PLAYER_TURN
	jr z, .ok
	ld h, PLAYER_TURN
.ok
	ld a, [hl]
	ret

; sort a $ff-terminated list of deck index cards by ID (lowest to highest ID).
; the list is wList.
SortCardsInDuelTempListByID::
	ld hl, hTempListPtr_ff99
	ld [hl], LOW(wList)
	inc hl
	ld [hl], HIGH(wList)
	jr SortCardsInListByID_CheckForListTerminator

; sort a $ff-terminated list of deck index cards by ID (lowest to highest ID).
; the pointer to the list is given in hTempListPtr_ff99.
; sorting by ID rather than deck index means that the order of equal (same ID) cards does not matter,
; even if they have a different deck index.
SortCardsInListByID::
	; load [hTempListPtr_ff99] into hl and de
	ld hl, hTempListPtr_ff99
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld e, l
	ld d, h
	; get ID of card with deck index at [de]
	ld a, [de]
	call GetCardIDFromDeckIndex_bc
	ld a, c
	ldh [hTempCardID_ff9b], a
	ld a, b
	ldh [hTempCardID_ff9b + 1], a
	; hl = [hTempListPtr_ff99] + 1
	inc hl
	jr .check_list_end

.next_card_in_list
	ld a, [hl]
	call GetCardIDFromDeckIndex_bc
	ldh a, [hTempCardID_ff9b + 1]
	cp b
	jr nz, .go
	ldh a, [hTempCardID_ff9b]
	cp c
.go
	jr c, .not_lower_id
	; this card has the lowest ID of those checked so far
	ld e, l
	ld d, h
	ld a, c
	ldh [hTempCardID_ff9b], a
	ld a, b
	ldh [hTempCardID_ff9b + 1], a
.not_lower_id
	inc hl
.check_list_end
	bit 7, [hl] ; $ff is the list terminator
	jr z, .next_card_in_list
	; reached list terminator
	ld hl, hTempListPtr_ff99
	push hl
	ld a, [hli]
	ld h, [hl]
	ld l, a
	; swap the lowest ID card found with the card in the current list position
	ld c, [hl]
	ld a, [de]
	ld [hl], a
	ld a, c
	ld [de], a
	pop hl
	; [hTempListPtr_ff99] += 1 (point hl to next card in list)
	inc [hl]
	jr nz, SortCardsInListByID_CheckForListTerminator
	inc hl
	inc [hl]
;	fallthrough

SortCardsInListByID_CheckForListTerminator::
	ld hl, hTempListPtr_ff99
	ld a, [hli]
	ld h, [hl]
	ld l, a
	bit 7, [hl] ; $ff is the list terminator
	jr z, SortCardsInListByID
	ret

; returns, in register bc, the id of the card with the deck index specified in register a
; preserves hl
GetCardIDFromDeckIndex_bc::
	push hl
	push de
	call _GetCardIDFromDeckIndex
	ld c, e
	ld b, d
	pop de
	pop hl
	ret

; returns, in register de, the id of the card with the deck index (0-59) specified by register a
; preserves af and hl
GetCardIDFromDeckIndex::
	push af
	push hl
	call _GetCardIDFromDeckIndex
	pop hl
	pop af
	ret

; returns, in register de, the id of the card with the deck index (0-59) specified in register a
_GetCardIDFromDeckIndex::
	ld e, a
	ld d, $0
	ld hl, wPlayerDeck
	ldh a, [hWhoseTurn]
	cp PLAYER_TURN
	jr z, .load_card_from_deck
	ld hl, wOpponentDeck
.load_card_from_deck
	add hl, de
	add hl, de
	ld e, [hl]
	inc hl
	ld d, [hl]
	ret

; copies the deck pointed to by de to wPlayerDeck or wOpponentDeck (depending on whose turn it is)
CopyDeckData::
	ld hl, wPlayerDeck
	ldh a, [hWhoseTurn]
	cp PLAYER_TURN
	jr z, .copy_deck_data
	ld hl, wOpponentDeck
.copy_deck_data
	; start by putting a terminator at the end of the deck
	push hl
	ld bc, DECK_SIZE_BYTES - 2
	add hl, bc
	xor a
	ld [hli], a
	ld [hl], a
	pop hl
	push hl
.next_card
	ld a, [de]
	inc de
	ld b, a
	or a
	jr z, .done
.card_quantity_loop
	ld a, [de]
	inc de
	ld [hli], a
	ld a, [de]
	ld [hli], a
	dec de
	dec b
	jr nz, .card_quantity_loop
	inc de
	inc de
	jr .next_card
.done
	ld hl, wDeckName
	ld a, [de]
	inc de
	ld [hli], a
	ld a, [de]
	ld [hl], a
	pop hl

	ld bc, DECK_SIZE_BYTES - 2
	add hl, bc
	ld a, [hli]
	or [hl]
	jr z, .fail
	inc hl
	ld a, [hli]
	or [hl]
	jr nz, .fail
	ret
.fail
	debug_nop
	scf
	ret

; copy the TX_END-terminated player's name from sPlayerName to de
CopyPlayerName::
	call EnableSRAM
	ld hl, sPlayerName
.loop
	ld a, [hli]
	ld [de], a
	inc de
	or a ; TX_END
	jr nz, .loop
	dec de
	jp DisableSRAM

; copy the opponent's name to de
; if text ID at wOpponentName is non-0, copy it from there
; else, if text at wc500 is non-0, copy if from there
; else, copy Player2Text
CopyOpponentName::
	ld hl, wOpponentName
	ld a, [hli]
	or [hl]
	jr z, .special_name
	ld a, [hld]
	ld l, [hl]
	ld h, a
	jp CopyText
.special_name
	ld hl, wNameBuffer
	ld a, [hl]
	or a
	jr z, .print_player2
	jr CopyPlayerName.loop
.print_player2
	ldtx hl, Player2Text
	jp CopyText
