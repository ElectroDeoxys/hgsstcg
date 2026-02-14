DuelScene:
	xor a
	ld [wTileMapFill], a
	call EmptyScreen
	call ClearOAM

	call SetDuelSceneVBlank
	ld hl, DuelSceneDoFrame
	call SetDoFrameFunction

	ld de, v1Tiles0
	ld hl, .CursorTile
	ld bc, 1 tiles
	call CopyDataHLtoDE

	; load necessary graphics
	call SetDefaultConsolePalettes

	call DrawPlayerDuelScene
	call DrawOpponentDuelScene

	; init scroll to center
	ld hl, wDuelSceneSCY
	xor a ; LOW(0.0)
	ld [hli], a
	ld a, DUELSCY_CENTER
	ld [hli], a
	ld a, -1
	ld [hli], a ; wTargetDuelSceneSCY

	; center cursor
	ld a, SCREEN_WIDTH_PX / 2
	ld [wDuelCursorX], a
	ld a, SCREEN_HEIGHT_PX / 2
	ld [wDuelCursorY], a

	farcall FadeScreenFromWhite

.loop
	call ZeroObjectPositions
	call DoFrame

	; do we have a target scroll?
	ld a, [wTargetDuelSceneSCY]
	cp -1
	jr z, .free_movement
	; are we already at target scroll?
	ld hl, wDuelSceneSCY + 1
	sub [hl]
	jr nz, .do_target_scroll
	; yes, snap scroll y
	xor a
	ld [wDuelSceneSCY + 0], a
	; then clear target scroll
	dec a ; -1
	ld [wTargetDuelSceneSCY], a
	jr .free_movement

.do_target_scroll
	; how far is target?
	ld d, FALSE
	jr nc, .got_target_distance
	inc d ; TRUE
	cpl
	inc a
.got_target_distance
	cp 6 + 1 ; over 6 px, do maximum speed
	jr c, .got_scy_speed_entry
	ld a, 6
.got_scy_speed_entry
	ld hl, ScrollSpeeds
	add a
	ld c, a
	ld b, 0
	add hl, bc
	ld c, [hl]
	inc hl
	ld b, [hl]
	; bc = absolute offset to apply
	; if d == FALSE, then should be negative
	ld a, d
	or a
	jr nz, .negative_offset
	call ScrollDuelScene
	jr .done_input

.negative_offset
	ld a, c
	cpl
	add 1
	ld c, a
	ld a, b
	cpl
	adc 0
	ld b, a
	call ScrollDuelScene
	jr .done_input

.free_movement
	ldh a, [hKeysHeld]
	ld b, a
	cp PAD_B | PAD_UP
	jr z, .scroll_area_up
	ld a, b
	cp PAD_B | PAD_DOWN
	jr nz,.no_scroll_area

; scroll area down
	ld a, [wDuelSceneSCY + 1]
	cp MAX_DUEL_SCENE_SCROLL
	jr z, .done_input
	cp DUELSCY_CENTER
	ld b, DUELSCY_CENTER
	jr c, .got_target_scroll
	ld b, DUELSCY_PLAYER_PLAY_AREA
	jr .got_target_scroll

.scroll_area_up
	ld a, [wDuelSceneSCY + 1]
	or a ; cp 0
	jr z, .done_input
	cp DUELSCY_CENTER + 1
	ld b, DUELSCY_OPPONENT_PLAY_AREA
	jr c, .got_target_scroll
	ld b, DUELSCY_CENTER
.got_target_scroll
	ld a, b
	ld [wTargetDuelSceneSCY], a
	jr .done_input

.no_scroll_area
	ld hl, wDuelCursorX
	ldh a, [hKeysHeld]
	bit B_PAD_LEFT, a
	jr nz, .move_cursor_left
	bit B_PAD_RIGHT, a
	jr z, .check_cursor_y

; move cursor right
	inc [hl]
	inc [hl]
	jr .check_cursor_y

.move_cursor_left
	dec [hl]
	dec [hl]

.check_cursor_y
	ld hl, wDuelCursorY
	ldh a, [hKeysHeld]
	bit B_PAD_UP, a
	jr nz, .move_cursor_up
	bit B_PAD_DOWN, a
	jr z, .no_move_cursor_y

; move cursor right
	inc [hl]
	inc [hl]
	jr .done_input

.move_cursor_up
	dec [hl]
	dec [hl]
	jr .done_input

.no_move_cursor_y

.done_input
	jp .loop

.CursorTile:
	db $e0, $c0, $98, $b0, $84, $8c, $83, $82
	db $86, $8f, $9d, $be, $f4, $f8, $50, $60

; input:
; - bc = 8-bit precision to offset
ScrollDuelScene:
	ld hl, wDuelSceneSCY
	ld a, c
	add [hl]
	ld [hli], a
	ld a, b
	adc [hl]
	ld [hl], a

	ld hl, wDuelSceneSCY + 1
	ld a, MAX_DUEL_SCENE_SCROLL
	cp [hl]
	ret nc ; within margins

	; moving up or down?
	ld a, MAX_DUEL_SCENE_SCROLL
	bit 7, b
	jr z, .moving_down
	xor a
.moving_down
	ld [hld], a
	ld [hl], LOW(0.0)
	ret

ScrollSpeeds:
	dw 0.00 ; 0
	dw 0.50 ; 1
	dw 1.50 ; 2
	dw 2.75 ; 3
	dw 3.50 ; 4
	dw 3.88 ; 5
	dw 4.25 ; 6

DrawPlayerDuelScene:
	; force PLAYER_TURN temporarily
	ldh a, [hWhoseTurn]
	push af
	ld a, PLAYER_TURN
	ldh [hWhoseTurn], a

	; draw active card
	ld a, DUELVARS_ACTIVE
	get_turn_duelist_var
	cp -1
	jr z, .no_active
	call LoadCardDataToBuffer1_FromDeckIndex
	ld de, v0Tiles1 + $50 tiles
	call LoadLoaded1CardGfx
	call SetBGP5ToCardPalette
	ld a, $d0 ; v0Tiles1 + $50 tiles
	lb hl, 6, 1
	lb de, 6, 17
	lb bc, 8, 6
	call FillRectangle
	call ApplyCardCGBAttributes

.no_active
	; draw bench
	ld hl, wPlayerPlayArea + PLAY_AREA_BENCH_1
	lb de, 3, 28 ; x, y

REPT MAX_BENCH_POKEMON
	call .DrawBenchSymbol
ENDR

	pop af
	ldh [hWhoseTurn], a
	ret

.DrawBenchSymbol:
	ld a, [hli]
	call GetBenchSymbolAndAttribute
	call DrawSquareSymbol
	inc d
	inc d
	inc d
	ret

DrawOpponentDuelScene:
	; force OPPONENT_TURN temporarily
	ldh a, [hWhoseTurn]
	push af
	ld a, OPPONENT_TURN
	ldh [hWhoseTurn], a

	; draw active card
	ld a, DUELVARS_ACTIVE
	get_turn_duelist_var
	cp -1
	jr z, .no_active
	call LoadCardDataToBuffer1_FromDeckIndex
	ld de, v0Tiles1 + $20 tiles
	call LoadLoaded1CardGfx
	call SetBGP2ToCardPalette
	ld a, $a0 ; v0Tiles1 + $20 tiles
	lb hl, 6, 1
	lb de, 6, 9
	lb bc, 8, 6
	call FillRectangle
	call ApplyCardCGBAttributes

.no_active
	; draw bench
	ld hl, wOpponentPlayArea + PLAY_AREA_BENCH_1
	lb de, 15, 2 ; x, y

REPT MAX_BENCH_POKEMON
	call .DrawBenchSymbol
ENDR

	pop af
	ldh [hWhoseTurn], a
	ret

.DrawBenchSymbol:
	ld a, [hli]
	call GetBenchSymbolAndAttribute
	call DrawSquareSymbol
	dec d
	dec d
	dec d
	ret

; gets correct bench symbol/attribute in bc
; from turn-duelist's bench pokemon with deck index a
GetBenchSymbolAndAttribute:
	lb bc, $dc, $3
	cp -1 ; is empty?
	ret z

	push de
	call GetCardIDFromDeckIndex
	call GetCardStage
	pop de

	push hl
	add a
	ld c, a
	ld b, 0
	ld hl, .StageSymbolsAndAttributes
	add hl, bc
	ld b, [hl] ; tile
	inc hl
	ld c, [hl] ; attribute
	pop hl
	ret

.StageSymbolsAndAttributes:
	db $d0, $3 ; BASIC
	db $d4, $3 ; STAGE1
	db $d8, $3 ; STAGE2

SetDuelSceneVBlank:
	ld hl, wVBlankFunctionTrampoline + 1
	di
	ld a, LOW(DuelSceneVBlank)
	ld [hli], a
	ld [hl], HIGH(DuelSceneVBlank)
	reti

DrawSquareSymbol:
	push hl
	push bc
	push de
	call DECoordToBGMap0Address
	ld a, b
	ld [hli], a
	inc a
	ld [hld], a
	inc a
	ld b, a
	call BankswitchVRAM1
	ld a, c
	ld [hli], a
	ld [hld], a
	call BankswitchVRAM0

	ld de, TILEMAP_WIDTH
	add hl, de
	ld a, b
	ld [hli], a
	inc a
	ld [hld], a
	call BankswitchVRAM1
	ld a, c
	ld [hli], a
	ld [hld], a
	call BankswitchVRAM0
	pop de
	pop bc
	pop hl
	ret
