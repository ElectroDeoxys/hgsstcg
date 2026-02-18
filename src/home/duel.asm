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

; called during V-Blank
; does any pending VDMA transfers
DuelSceneVBlank::
	push_wram BANK("WRAM Duel")
	ld hl, wVDMAPending
	ld a, [hl]
	or a
	jr z, .no_vdma
	xor a
	ld [hli], a
	ldh a, [hBankROM]
	push af
	ld a, [hli] ; wVDMASourceBank
	call BankswitchROM
	ld c, LOW(rVDMA_SRC_HIGH)
	ld a, [hli] ; wVDMASource
	ld [$ff00+c], a ; rVDMA_SRC_HIGH
	inc c
	ld a, [hli]
	ld [$ff00+c], a ; rVDMA_SRC_LOW
	inc c
	ld a, [hli] ; wVDMADestBank
	or a
	call nz, BankswitchVRAM1
	ld a, [hli] ; wVDMADest
	ld [$ff00+c], a ; rVDMA_DEST_HIGH
	inc c
	ld a, [hli]
	ld [$ff00+c], a ; rVDMA_DEST_LOW
	inc c
	ld a, [hli] ; wVDMALen
	ld [$ff00+c], a ; rVDMA_LEN
	pop af
	call BankswitchROM
	call BankswitchVRAM0

.no_vdma
	pop_wram
	ret

; applies duel scene scroll
; and cursor positioning
DuelSceneDoFrame::
	push_wram BANK("WRAM Duel")
	ld a, [wDuelSceneSCY + 1]
	ldh [hSCY], a

	call UpdateDuelCursorAnimation
	call ProcessDuelAnimationQueue
	call UpdateDuelAnimations

	ld a, $1
	ld [wVBlankOAMCopyToggle], a

	pop_wram
	ret

UpdateDuelCursorAnimation::
	ld a, [wDuelCursorAnimIdx]
	cp -1
	jr nz, .got_idx
	ld a, SPRITE_DUEL_CURSOR
	ld b, BANK("VRAM1")
	call LoadDuelSprite
	ld a, SPRITE_ANIM_DUEL_CURSOR_POINT
	call LoadDuelAnimation
	ld [wDuelCursorAnimIdx], a
.got_idx
	call GetLoadedDuelAnimation
	set DUELANIMF_LOOPING_F, [hl]
	ld bc, DUELANIM_YPOS
	add hl, bc
	ld a, [wDuelCursorY]
	ld [hli], a
	ld a, [wDuelCursorX]
	ld [hli], a
	ld a, 0 ; tile offset
	ld [hli], a
	ld a, 0 | OAM_BANK1
	ld [hli], a
	ret

; find first inactive duel animation
; outputs in a which duel animation index was found
FindInactiveDuelAnimation:
	push bc
	push de
	ld hl, wDuelAnimations
	ld bc, DUELANIM_STRUCT_SIZE
	ld a, NUM_DUEL_ANIMS
	ld d, 0
.loop_find_inactive
	bit DUELANIMF_ACTIVE_F, [hl]
	jr z, .found
	add hl, bc
	inc d
	dec a
	jr nz, .loop_find_inactive
	pop de
	pop bc
	scf ; this should not happen
	ret
.found
	ld a, d
	pop de
	pop bc
	or a
	ret

; loads duel animation given in a (SPRITE_ANIM_* constant)
; outputs in a which duel animation index was used
LoadDuelAnimation:
	push hl
	push bc
	ld l, GFXTABLE_SPRITE_ANIMATIONS
	farcall GetMapDataPointer
	farcall LoadGraphicsPointerFromHL

	call FindInactiveDuelAnimation
	set DUELANIMF_ACTIVE_F, [hl]
	push af

	ld a, [hBankROM]
	push af
	ld a, [wTempPointerBank]
	call BankswitchROM
	inc hl
	inc hl
	ld a, [wTempPointer + 0]
	ld c, a
	ld a, [wTempPointer + 1]
	ld b, a
	ld a, [bc]
	inc bc
	add BANK("Load Gfx")
	ld [hli], a ; OAM bank
	ld a, [bc]
	inc bc
	ld [hli], a ; OAM ptr
	ld a, [bc]
	inc bc
	ld [hli], a
	ld a, c
	ld [hli], a ; frameset ptr
	ld a, b
	ld [hli], a
	ld a, c
	ld [hli], a ; starting frameset ptr
	ld a, b
	ld [hli], a

	; set starting duration
	inc bc
	ld a, [bc]
	ld bc, DUELANIM_DURATION - (DUELANIM_START_FRAMESET_PTR + 2)
	add hl, bc
	ld [hl], a
	pop af
	call BankswitchROM

	pop af
	pop bc
	pop hl
	ret

; set VDMA to load sprite given in a (SPRITE_* constant)
; to VRAM bank given in b
LoadDuelSprite:
	push hl
	ld l, GFXTABLE_SPRITES
	farcall GetMapDataPointer
	farcall LoadSpriteGraphicsPointerFromHL
	dec a ; -1
	ld [wVDMALen], a
	ld hl, wVDMASourceBank
	ld a, [wTempPointerBank]
	ld [hli], a ; wVDMASourceBank
	ld a, [wTempPointer + 1]
	ld [hli], a ; wVDMASource
	ld a, [wTempPointer + 0]
	ld [hli], a
	ld a, b
	ld [hli], a ; wVDMADestBank
	ld a, TRUE
	ld [wVDMAPending], a ; trigger VDMA
	pop hl
	ret

; returns pointer to ath loaded duel animation in hl
GetLoadedDuelAnimation:
	push bc
	ld hl, wDuelAnimations
	ld bc, DUELANIM_STRUCT_SIZE
	or a
	jr .start_loop
.loop
	add hl, bc
	dec a
.start_loop
	jr nz, .loop
	pop bc
	ret

ProcessDuelAnimationQueue::
	call CheckIfDuelAnimationIsRunning
	ret c ; still running an animation

	ld a, [wTargetDuelSceneSCY]
	inc a
	ret nz ; still scrolling

	; no animations running, green light
	ld hl, wDuelAnimationQueue
	ld a, [wDuelAnimationQueueSize]
	ld c, a
	ld b, 0 ; num of anims processed
	or a
	jr .start_loop
.loop_queue
	inc hl
	ld a, [wDuelSceneSCY + 1]
	cp [hl]
	jr nz, .set_target_scy
	; is on target scroll, start animation
	dec hl
	call .AddAnimation
	inc b
.next_in_queue
	; we only process up to the first non-concurrent
	bit DUELANIMENTRYF_CONCURRENT_F, [hl]
	jr z, .done_queue
	dec c
.start_loop
	jr nz, .loop_queue
	
.done_queue
	; check if we need to reduce queue
	ld a, b
	or a
	ret z ; none processed
	ld a, [wDuelAnimationQueueSize]
	sub b
	ld [wDuelAnimationQueueSize], a
	ld a, DUEL_ANIMS_QUEUE_CAPACITY
	sub b
	ld c, a
	add a
	add a
	add c ; *5
	ld c, a
	ld b, 0
	ld hl, wDuelAnimationQueue
	add hl, bc
	ld de, wDuelAnimationQueue
	jp CopyDataHLtoDE

.set_target_scy
	ld [wTargetDuelSceneSCY], a
	dec hl
	jr .next_in_queue

.AddAnimation:
	push hl
	push bc
	inc hl
	inc hl
	ld e, l
	ld d, h

	ld a, [de] ; sprite id
	cp -1
	ld b, BANK("VRAM0")
	call nz, LoadDuelSprite

	inc de
	ld a, [de] ; anim id
	call LoadDuelAnimation
	pop bc
	pop hl
	ret

UpdateDuelAnimations::
	call ZeroObjectPositions

	ld hl, wDuelAnimations
	ld bc, DUELANIM_STRUCT_SIZE
	ld a, NUM_DUEL_ANIMS
.loop
	bit DUELANIMF_ACTIVE_F, [hl]
	call nz, .Update
	add hl, bc
	dec a
	jr nz, .loop
	ret

.Update:
	push af
	push hl
	push bc
	inc hl
	xor a ; FALSE
	ld [wChangeAnimFrame], a
	ld a, [hl]
	dec [hl]
	or a
	jr nz, .skip_decrement_duration
	; change to next frame
	ld a, TRUE
	ld [wChangeAnimFrame], a
.skip_decrement_duration
	ld a, [hBankROM]
	push af
	push hl
	inc hl
	ld a, [hli] ; OAM bank
	call BankswitchROM
	ld a, [hli] ; OAM ptr
	ld d, [hl]
	ld e, a
	inc hl

.get_frame_data
	; get frame data
	push hl
	ld a, [hli] ; frameset ptr
	ld h, [hl]
	ld l, a
	ld a, [wChangeAnimFrame]
	or a
	jr z, .got_frameset_ptr
	; next frame
	ld bc, SPRITE_FRAME_OFFSET_SIZE
	add hl, bc
	ld c, l
	ld b, h
.got_frameset_ptr
	ld a, [hli] ; frame
	ld [wCurAnimFrame], a
	ld a, [hli] ; duration
	ld [wCurAnimDuration], a
	ld a, [hli] ; x
	ld [wCurAnimFrameX], a
	ld a, [hli] ; y
	ld [wCurAnimFrameY], a
	pop hl

	ld a, [wChangeAnimFrame]
	or a
	jr z, .skip_frameset_ptr_update
	ld a, c
	ld [hli], a
	ld [hl], b
	dec hl

.skip_frameset_ptr_update
	ld bc, DUELANIM_YPOS - DUELANIM_FRAMESET_PTR
	add hl, bc
	ld a, [hli]
	ld [wCurAnimY], a
	ld a, [hli]
	ld [wCurAnimX], a
	ld a, [hli]
	ld [wCurAnimTileOffset], a
	ld a, [hl]
	ld [wCurAnimOBPal], a

	; if duration = -1 then it means it's end of frames
	ld a, [wCurAnimDuration]
	inc a ; cp -1
	jr nz, .valid_duration
	; is -1, if non-looping animation, end it here
	ld bc, DUELANIM_FLAGS - DUELANIM_OBPAL
	add hl, bc
	bit DUELANIMF_LOOPING_F, [hl]
	jr z, .end_animation
	; is looping, set oam ptr to start
	ld bc, DUELANIM_START_FRAMESET_PTR - DUELANIM_FLAGS
	add hl, bc
	ld a, [hli]
	ld c, a
	ld a, [hld]
	ld b, a
	dec hl
	ld [hld], a
	ld [hl], c
	inc bc ; duration
	ld a, [bc]
	push hl
	ld bc, DUELANIM_DURATION - DUELANIM_FRAMESET_PTR
	add hl, bc
	ld [hl], a
	pop hl
	xor a ; FALSE
	ld [wChangeAnimFrame], a
	jr .get_frame_data

.valid_duration
	; if frame == -1, then don't output OAM
	ld a, [wCurAnimFrame]
	cp -1
	ld hl, EmptyFrameData
	jr z, .got_frame_data_ptr
	add a ; *2
	add e
	ld e, a
	ld a, 0
	adc d
	ld d, a
	ld a, [de]
	inc de
	ld l, a
	ld a, [de]
	ld h, a
.got_frame_data_ptr
	ld a, [hli] ; size
	or a
	jr .start_loop_oam
.loop_oam
	ld a, [wCurAnimY]
	ld b, a
	ld a, [wCurAnimFrameY]
	add [hl]
	inc hl
	add b
	ld e, a ; y
	ld a, [wCurAnimX]
	ld b, a
	ld a, [wCurAnimFrameX]
	add [hl]
	inc hl
	add b
	ld d, a ; x
	ld a, [wCurAnimTileOffset]
	add [hl]
	inc hl
	ld c, a ; tile
	ld a, [wCurAnimOBPal]
	or [hl]
	inc hl
	ld b, a ; attributes
	call SetOneObjectAttributes
	ld a, [wCurOAMCount]
	dec a
.start_loop_oam
	ld [wCurOAMCount], a
	jr nz, .loop_oam

	pop hl
	ld a, [wChangeAnimFrame]
	or a
	jr z, .skip_duration_update
	ld a, [wCurAnimDuration]
	ld [hl], a
.skip_duration_update
	pop af
	call BankswitchROM
	pop bc
	pop hl
	pop af
	ret

.end_animation
	pop hl
	pop af
	call BankswitchROM
	pop bc
	pop hl
	pop af
	res DUELANIMF_ACTIVE_F, [hl]
	ret

EmptyFrameData:
	db 0 ; size

; returns carry set if animation is running
CheckIfDuelAnimationIsRunning:
	push hl
	push bc
	ld hl, wDuelAnimations
	ld bc, DUELANIM_STRUCT_SIZE
	ld a, NUM_DUEL_ANIMS
.loop
	bit DUELANIMF_ACTIVE_F, [hl]
	jr nz, .set_carry
	add hl, bc
	dec a
	jr nz, .loop
	or a
	jr .done
.set_carry
	scf
.done
	pop bc
	pop hl
	ret
