DuelScene:
	xor a
	ld [wTileMapFill], a
	call EmptyScreen
	call ClearOAM

	call SetDuelSceneVBlank
	ld hl, DuelSceneDoFrame
	call SetDoFrameFunction
	call SetDuelStatFunction

	; load necessary graphics
	call SetDefaultConsolePalettes
	ld a, PALETTE_DUEL_CURSOR
	farcall LoadOBPalette

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

	; init cursor
	ld a, SCREEN_WIDTH_PX / 2
	ld [wDuelCursorX], a
	ld a, SCREEN_HEIGHT_PX / 2
	ld [wDuelCursorY], a
	ld a, -1
	ld [wDuelCursorAnimIdx], a
	ld a, CURSOR_IDLE | CURSOR_PENDING_UPDATE
	ld [wDuelCursorState], a

	call EnableLCD

	ld a, SPRITE_DUEL_CURSOR
	ld b, BANK("VRAM1")
	call LoadDuelSprite

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
	cp 8 + 1 ; over 8 px, do maximum speed
	jr c, .got_scy_speed_entry
	ld a, 8
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
	bit B_PAD_B, a
	jr z, .no_b_btn
	bit B_PAD_UP, a
	jr nz, .scroll_area_up
	bit B_PAD_DOWN, a
	jr z,.done_input

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

.no_b_btn
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
	; update cursor state
	ld hl, wDuelCursorX
	ld a, [hli]
	ld b, a ; x
	ld a, [wDuelSceneSCY + 1]
	add [hl]
	ld c, a ; y

.done_input
	jp .loop

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
	dw 0.75 ; 2
	dw 1.00 ; 3
	dw 1.50 ; 4
	dw 2.00 ; 5
	dw 2.50 ; 6
	dw 3.50 ; 7
	dw 4.00 ; 8

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

	; draw active card
	call LoadCardDataToBuffer1_FromDeckIndex
	ld de, v0Tiles1 + $50 tiles
	call LoadLoaded1CardGfx
	ld c, $5
	ld de, wCardAttrMap
	call SetCardGfxPaletteIndex
	ld a, $d0 ; v0Tiles1 + $50 tiles
	lb hl, 6, 1
	lb de, 6, 17
	lb bc, 8, 6
	call FillRectangle
	call ApplyCardCGBAttributes
	; copy over palettes
	ld hl, wCardPalette
	ld de, wPlayerCardPalette
	ld bc, 3 palettes
	call CopyDataHLtoDE

	; print name
	ld a, 13
	call CopyCardNameAndLevel
	lb de, 7, 23
	call InitTextPrinting
	ld hl, wDefaultText
	call ProcessText

	xor a ; PLAY_AREA_ARENA
	ld e, $80
	lb bc, 7, 24
	call DrawHPBar

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

	; draw active card
	call LoadCardDataToBuffer1_FromDeckIndex
	ld de, v0Tiles1 + $20 tiles
	call LoadLoaded1CardGfx
	ld c, $5
	ld de, wCardAttrMap
	call SetCardGfxPaletteIndex
	ld a, $a0 ; v0Tiles1 + $20 tiles
	lb hl, 6, 1
	lb de, 6, 9
	lb bc, 8, 6
	call FillRectangle
	call ApplyCardCGBAttributes
	; copy over palettes
	ld hl, wCardPalette
	ld de, wOppCardPalette
	ld bc, 3 palettes
	call CopyDataHLtoDE

	; print name
	ld a, 13
	call CopyCardNameAndLevel
	lb de, 7, 7
	call InitTextPrinting
	ld hl, wDefaultText
	call ProcessText

	xor a ; PLAY_AREA_ARENA
	ld e, $85
	lb bc, 7, 8
	call DrawHPBar

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
	cp -1 ; is empty?
	lb bc, $dc, $3
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

SetDuelStatFunction:
	di
	ld hl, wLCDCFunctionTrampoline + 1
	ld a, LOW(DuelSceneStat)
	ld [hli], a
	ld [hl], HIGH(DuelSceneStat)
	ei

	ld hl, rSTAT
	set B_STAT_LYC, [hl]
	xor a
	ldh [rLYC], a
	ld hl, rIE
	set B_IE_STAT, [hl]
	ret

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

; draw HP bar for turn-holder's Pokémon
; at play area location given in a
; to VRAM tile offset given in e
; to coordinates in bc
DrawHPBar::
	ld hl, wHPBarTileOffset
	ld [hl], e ; wHPBarTileOffset
	inc hl
	ld [hl], b  ; wHPBarX
	inc hl
	ld [hl], c  ; wHPBarY

	push af
	add DUELVARS_PLAY_AREA_HP
	get_turn_duelist_var
	ld b, a ; current hp
	pop af
	add DUELVARS_PLAY_AREA
	ld l, a
	ld a, [hl]
	call GetCardIDFromDeckIndex
	call GetCardMaxHP
	ld e, a ; max hp

	; get length
	dec a
	ld hl, HPBarLengths
.loop_find_length
	cp [hl]
	jr c, .got_length
	inc hl
	inc hl
	jr .loop_find_length
.got_length
	inc hl
	ld a, [hl]
	ld [wHPBarLength], a

	; calculate (cur hp / max hp) * $100
	xor a
	ld c, a ; 0
	ld d, a ; 0
	; bc = cur HP * $100
	; de = max HP
	call DivideBCbyDE
	; c = percentage of HP bar to fill
	; if zero then it's 100%

	; num of total pixels is [wHPBarLength] * 8 - 2 (border pixels)
	ld a, [wHPBarLength]
	add a
	add a
	add a ; *8
	sub 2
	ld h, a
	push af
	ld l, c
	ld a, c
	or a
	call nz, HtimesL
	; h = num of pixels
	ld a, h
	ld [wHPBarActivePx], a
	ld b, a
	pop af
	; a = max num of pixels
	sub b
	; a = num of "inactive" pixels
	cp 8
	ld b, a
	jr nc, .at_least_8_px_from_right

	; we only need to modify the right end of the bar
	ld a, 7
	sub b
	; a = num active pixels
	call .GetPixelMask_Reversed
	ld hl, HPBarEndGfx
	call .GenerateHPBarTile
	ld hl, wHPBarScratch
	ld a, [wHPBarTileOffset]
	inc a
	inc a
	call .PushHPBarTile

	ld hl, HPBarEndGfx
	ld a, [wHPBarTileOffset]
	call .PushHPBarTile

	ld hl, HPBarMidGfx
	ld a, [wHPBarTileOffset]
	inc a
	call .PushHPBarTile

	jr .draw_pattern_1

.at_least_8_px_from_right
	ld a, [wHPBarActivePx]
	cp 8
	jr nc, .at_least_8_px_from_left

	; we only need to modify the left end of the bar
	call .GetPixelMask
	srl b ; extra shift due to left border
	ld hl, HPBarEndGfx
	call .GenerateHPBarTile
	ld hl, wHPBarScratch
	ld a, [wHPBarTileOffset]
	call .PushHPBarTile

	ld hl, HPBarMidGfx
	ld b, %11111111
	call .GenerateHPBarTile
	ld hl, wHPBarScratch
	ld a, [wHPBarTileOffset]
	inc a
	call .PushHPBarTile

	ld hl, HPBarEndGfx
	ld b, %11111111
	call .GenerateHPBarTile
	ld hl, wHPBarScratch
	ld a, [wHPBarTileOffset]
	inc a
	inc a
	call .PushHPBarTile

.draw_pattern_1
	; draw in pattern 1222..3
	ld hl, wHPBarX
	ld b, [hl] ; x
	inc hl
	ld c, [hl] ; y
	call BCCoordToBGMap0Address
	ld l, e
	ld h, d
	ld a, [wHPBarTileOffset]
	ld b, a
	ld [hli], a
	ld a, [wHPBarLength]
	dec a
	dec a
	ld c, a
	inc b
	ld a, b
.loop_fill_bg_1
	ld [hli], a
	dec c
	jr nz, .loop_fill_bg_1
	inc a
	ld [hl], a
	jp .apply_attributes

.at_least_8_px_from_left
	; one of the middle tiles needs to be modified
	push bc

	; push full left end tile
	ld hl, HPBarEndGfx
	ld a, [wHPBarTileOffset]
	call .PushHPBarTile

	; if at least 7 + 8 pixels, then we need a full middle tile
	ld a, [wHPBarActivePx]
	cp 7 + 8
	jr c, .not_enough_for_filled_middle_tile
	ld hl, HPBarMidGfx
	ld a, [wHPBarTileOffset]
	inc a
	call .PushHPBarTile

.not_enough_for_filled_middle_tile
	pop bc
	; b = num of "inactive" pixels
	ld a, b
	; if at least 7 + 8 pixels, then we need an empty middle tile
	cp 7 + 8
	jr c, .not_enough_for_empty_middle_tile
	ld hl, HPBarMidGfx
	ld b, %11111111
	call .GenerateHPBarTile
	ld hl, wHPBarScratch
	ld a, [wHPBarTileOffset]
	add 3
	call .PushHPBarTile

.not_enough_for_empty_middle_tile
	; push empty right end tile
	ld hl, HPBarEndGfx
	ld b, %11111111
	call .GenerateHPBarTile
	ld hl, wHPBarScratch
	ld a, [wHPBarTileOffset]
	add 4
	call .PushHPBarTile

	; now generate half-empty middle tile
	ld a, [wHPBarActivePx]
	sub 7 ; first border tile
	and $7
	; a = pixels % TILE_SIZE = num of pixels in the middle tile
	jr z, .multiple_of_8
	call .GetPixelMask
	ld hl, HPBarMidGfx
	call .GenerateHPBarTile
	ld hl, wHPBarScratch
	ld a, [wHPBarTileOffset]
	inc a
	inc a
	call .PushHPBarTile

.multiple_of_8
	; draw in pattern 122...344...5
	ld hl, wHPBarX
	ld b, [hl] ; x
	inc hl
	ld c, [hl] ; y
	call BCCoordToBGMap0Address
	ld l, e
	ld h, d
	ld a, [wHPBarTileOffset]
	ld b, a
	ld c, 0

	; place left end tile
	ld [hli], a
	inc c

	; place filled middle tiles
	ld a, [wHPBarActivePx]
	sub 7
	inc b
.loop_fill_bg_2
	sub 8
	jr c, .done_middle_filled_tiles
	ld [hl], b
	inc hl
	inc c
	jr .loop_fill_bg_2

.done_middle_filled_tiles
	; place half-empty middle tile
	inc b
	ld a, [wHPBarActivePx]
	sub 7 ; first border tile
	and $7
	jr z, .skip_mid_tile
	ld [hl], b
	inc hl
	inc c
.skip_mid_tile
	; c = num of placed tiles
	; num of empty middle tiles = wHPBarLength - c - 1
	ld a, [wHPBarLength]
	sub c
	inc b
.loop_fill_bg_3
	dec a
	jr z, .done_middle_empty_tiles
	ld [hl], b
	inc hl
	jr .loop_fill_bg_3

.done_middle_empty_tiles
	; finally place empty right tile
	inc b
	ld [hl], b

.apply_attributes
	ld hl, wHPBarX
	ld b, [hl] ; x
	inc hl
	ld c, [hl] ; y
	call BCCoordToBGMap0Address
	ld l, e
	ld h, d
	call BankswitchVRAM1
	ld a, [wHPBarLength]
	sub 2
	ld c, a
	ld a, 1
	ld [hli], a
.loop_attrs
	ld [hli], a
	dec c
	jr nz, .loop_attrs
	or BG_XFLIP
	ld [hli], a
	call BankswitchVRAM0
	ret

; returns b = %000...111
; where number of 0s is equal to a
.GetPixelMask:
	ld b, %11111111
	inc a
.loop_bitmask
	dec a
	ret z
	srl b
	jr .loop_bitmask

; returns b = %111...000
; where number of 0s is equal to a
.GetPixelMask_Reversed:
	ld b, %11111111
	inc a
.loop_bitmask_rev
	dec a
	ret z
	sla b
	jr .loop_bitmask_rev

; input:
; - hl = base tile to copy
; - b  = pixel bitmask
.GenerateHPBarTile:
	ld de, wHPBarScratch

	; first 2 rows are unaffected
	REPT 2 * 2 ; 2 bytes per row
		ld a, [hli]
		ld [de], a
		inc de
	ENDR

	ld c, 8 - 2 - 1
.loop_generate
	ld a, [hli]
	or b
	ld [de], a
	inc de
	ld a, [hli]
	or b
	ld [de], a
	inc de
	dec c
	jr nz, .loop_generate

	; bottom border
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hli]
	ld [de], a
	ret

; pushes tile in hl to tile given in a
.PushHPBarTile:
	swap a
	ld b, a
	and $0f
	or HIGH(v1Tiles1)
	ld d, a
	ld a, b
	and $f0
	ld e, a
	ld bc, TILE_SIZE
	jp CopyDataHLtoDE

HPBarEndGfx:
	dw `00000000
	dw `03333333
	dw `31111111
	dw `31000000
	dw `31111111
	dw `31111111
	dw `31111111
	dw `03333333

	dw `00000000
	dw `03333333
	dw `32222222
	dw `32000000
	dw `32222222
	dw `32222222
	dw `32222222
	dw `03333333

HPBarMidGfx:
	dw `00000000
	dw `33333333
	dw `11111111
	dw `00000000
	dw `11111111
	dw `11111111
	dw `11111111
	dw `33333333

	dw `00000000
	dw `33333333
	dw `22222222
	dw `00000000
	dw `22222222
	dw `22222222
	dw `22222222
	dw `33333333

HPBarLengths:
	db  30,  3
	db  50,  4
	db  70,  5
	db  90,  6
	db 110,  7
	db 130,  8
	db 150,  9
	db  -1, 10
