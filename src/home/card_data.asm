; load data of card with id at de to wLoadedCard2
LoadCardDataToBuffer2_FromCardID::
	push hl
	ld hl, wLoadedCard2
	jr LoadCardDataToHL_FromCardID

; load data of card with id at de to wLoadedCard1
LoadCardDataToBuffer1_FromCardID::
	push hl
	ld hl, wLoadedCard1
;	fallthrough

LoadCardDataToHL_FromCardID::
	push de
	push bc
	push hl
	call GetCardPointer
	pop de
	jr c, .done
	call BankpushROM2
	ld b, PKMN_CARD_DATA_LENGTH
.copy_card_data_loop
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, .copy_card_data_loop
	call BankpopROM
	or a
.done
	pop bc
	pop de
	pop hl
	ret

; load data of card with deck index a (0-59) to wLoadedCard1
LoadCardDataToBuffer1_FromDeckIndex::
	push de
	call GetCardIDFromDeckIndex
	call LoadCardDataToBuffer1_FromCardID
	pop de
	ret

; return in a the max HP of the card with id at de
GetCardMaxHP::
	ld a, CARD_DATA_HP
	jr GetCardByte

; return in a the stage of the card with id at de
GetCardStage::
	ld a, CARD_DATA_STAGE
	jr GetCardByte

; return in a the type (TYPE_* constant) of the card with id at de
GetCardType::
	xor a ; ld a, CARD_DATA_TYPE
;	fallthrough

; get card byte data of card ID given by de
; input:
; - a  = CARD_DATA_* constant
; - de = card ID
; output:
; - a = card data
GetCardByte::
	push hl
	push bc
	ld c, a
	call GetCardPointer
	jr c, .done
	call BankpushROM2
	ld b, 0
	add hl, bc
	ld c, [hl]
	call BankpopROM
	ld a, c
	or a
.done
	pop bc
	pop hl
	ret

; return in de the 2-byte text id of the name of the card with id at de
GetCardName::
	ld a, CARD_DATA_NAME
;	fallthrough

; get card word data of card ID given by de
; input:
; - a  = CARD_DATA_* constant
; - de = card ID
; output:
; - de = card data
GetCardWord::
	push hl
	push bc
	ld c, a
	call GetCardPointer
	jr c, .done
	call BankpushROM2
	ld b, 0
	add hl, bc
	ld e, [hl]
	inc hl
	ld d, [hl]
	call BankpopROM
	or a
.done
	pop bc
	pop hl
	ret

; return at a:hl the pointer to the data of the card with id at de
; return carry if de was out of bounds, so no pointer was returned
GetCardPointer::
	push de
	push bc
	ldh a, [hBankROM]
	push af
	ld a, BANK(CardPointers)
	call BankswitchROM
	ld l, e
	ld h, d
	add hl, hl
	add hl, de
	ld bc, CardPointers
	add hl, bc
	ld a, h
	cp HIGH(CardPointers + 3 * (NUM_CARDS + 1))
	jr nz, .nz
	ld a, l
	cp LOW(CardPointers + 3 * (NUM_CARDS + 1))
.nz
	ccf
	jr c, .out_of_bounds
	ld a, [hli]
	ld c, [hl]
	inc hl
	ld b, [hl]
	ld l, a
	ld h, c
	pop af
	call BankswitchROM
	ld a, b
	pop bc
	pop de
	or a
	ret

.out_of_bounds
	pop af
	call BankswitchROM
	pop bc
	pop de
	scf
	ret

; input:
; wLoadedCard1 = card with gfx to load
; de = where to load the card gfx to
; bc are supposed to be $30 (number of tiles of a card gfx) and TILE_SIZE respectively
; card_gfx_index = (<Name>CardGfx - CardGraphics) / 8  (using absolute ROM addresses)
; also copies the card's palette to wCardPalette
LoadLoaded1CardGfx::
	ld hl, wLoadedCard1Gfx
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ldh a, [hBankROM]
	push af
	push hl
	; first, get the bank with the card gfx is at
	srl h
	srl h
	srl h
	ld a, BANK(CardGraphics)
	add h
	call BankswitchROM
	pop hl
	; once we have the bank, get the pointer: multiply by 8 and discard the bank offset
	add hl, hl
	add hl, hl
	add hl, hl
	res 7, h
	set 6, h ; $4000 ≤ hl ≤ $7fff

	push de
	ld de, wCardPalette
	ld b, 3 palettes
.copy_card_palette
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, .copy_card_palette

	; de = wCardAttrMap
	ld b, $30
.copy_card_attrmap
	ld a, [hli]
	ld [de], a
	inc de
	dec b
	jr nz, .copy_card_attrmap

	pop de
	lb bc, $30, TILE_SIZE
	call CopyGfxData
	pop af
	jp BankswitchROM
