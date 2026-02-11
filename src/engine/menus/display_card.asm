; display the card details of the card in wLoadedCard1
; print the text at hl
DisplayLoadedCard1DetailScreen::
	push hl
	call DrawLargePictureOfCard
	ld a, 18
	call CopyCardNameAndLevel
	ld [hl], TX_END
	ld hl, 0
	call LoadTxRam2
	pop hl
	jp DrawWideTextBox_WaitForInput

; draw a large picture of the card loaded in wLoadedCard1, including its image
; and a header indicating the type of card (TRAINER, ENERGY, PoKéMoN)
DrawLargePictureOfCard:
	call ZeroObjectPositionsAndToggleOAMCopy
	call EmptyScreen
	call LoadSymbolsFont
	call SetDefaultConsolePalettes
	ld a, LARGE_CARD_PICTURE
	ld [wDuelDisplayedScreen], a
	call LoadCardOrDuelMenuBorderTiles
	ld e, HEADER_TRAINER
	ld a, [wLoadedCard1Type]
	cp TYPE_TRAINER
	jr z, .draw
	ld e, HEADER_ENERGY
	and TYPE_ENERGY
	jr nz, .draw
	ld e, HEADER_POKEMON
.draw
	ld a, e
	call LoadCardTypeHeaderTiles
	ld de, v0Tiles1 + $20 tiles
	call LoadLoaded1CardGfx
	call SetBGP5ToCardPalette
	call FlushAllPalettes
	ld hl, LargeCardTileData
	call WriteDataBlocksToBGMap0
	lb de, 6, 3
;	fallthrough

; given the 8x6 card image with coordinates at de
; using the rectangle card attributes in wCardAttrMap
ApplyCardCGBAttributes:
	call BankswitchVRAM1
	call DECoordToBGMap0Address
	ld d, h
	ld e, l
	ld hl, wCardAttrMap
	ld c, 6
.loop_copy_rows
	ld b, 8
	call SafeCopyDataHLtoDE
	ld a, e
	add TILEMAP_WIDTH - 8
	ld e, a
	ld a, d
	adc 0
	ld d, a
	dec c
	jr nz, .loop_copy_rows
	jp BankswitchVRAM0

LargeCardTileData:
	db  5,  0, $d0, $d4, $d4, $d4, $d4, $d4, $d4, $d4, $d4, $d1, 0 ; top border
	db  5,  1, $d6, $e0, $e1, $e2, $e3, $e4, $e5, $e6, $e7, $d7, 0 ; header top
	db  5,  2, $d6, $e8, $e9, $ea, $eb, $ec, $ed, $ee, $ef, $d7, 0 ; header bottom
	db  5,  3, $d6, $a0, $a6, $ac, $b2, $b8, $be, $c4, $ca, $d7, 0 ; image
	db  5,  4, $d6, $a1, $a7, $ad, $b3, $b9, $bf, $c5, $cb, $d7, 0 ; image
	db  5,  5, $d6, $a2, $a8, $ae, $b4, $ba, $c0, $c6, $cc, $d7, 0 ; image
	db  5,  6, $d6, $a3, $a9, $af, $b5, $bb, $c1, $c7, $cd, $d7, 0 ; image
	db  5,  7, $d6, $a4, $aa, $b0, $b6, $bc, $c2, $c8, $ce, $d7, 0 ; image
	db  5,  8, $d6, $a5, $ab, $b1, $b7, $bd, $c3, $c9, $cf, $d7, 0 ; image
	db  5,  9, $d6, 0                                              ; empty line 1 (left)
	db 14,  9, $d7, 0                                              ; empty line 1 (right)
	db  5, 10, $d6, 0                                              ; empty line 2 (left)
	db 14, 10, $d7, 0                                              ; empty line 2 (right)
	db  5, 11, $d2, $d5, $d5, $d5, $d5, $d5, $d5, $d5, $d5, $d3, 0 ; bottom border
	db $ff

SetBGP5ToCardPalette:
	ld a, $05 ; CGB BG Palette 5
	jp SetCardPalette

SetBGP2ToCardPalette:
	ld a, $02 ; CGB BG Palette 2
;	fallthrough

; a = pal index
SetCardPalette:
	ld c, a
	add a
	add a
	add a ; a *= PAL_SIZE
	ld e, a
	ld d, $00
	ld hl, wBackgroundPalettesCGB
	add hl, de
	ld de, wCardPalette
	ld b, 3 palettes
.copy_pal_loop
	ld a, [de]
	inc de
	ld [hli], a
	dec b
	jr nz, .copy_pal_loop

	; de = wCardAttrMap
	ld b, $30
.loop_set_attr_pal
	ld a, [de]
	add c
	ld [de], a
	inc de
	dec b
	jr nz, .loop_set_attr_pal
	ret

; draw the card page of the card at wLoadedCard1 and listen for input
; in order to switch the page or to exit.
; PAD_UP and PAD_DOWN exit the card page allowing the caller to load the card page
; of the card above or below in the list.
OpenCardPage_FromCardList::
	ld a, PAD_B | PAD_UP | PAD_DOWN
	ld [wCardPageExitKeys], a
	xor a ; CARDPAGETYPE_NOT_PLAY_AREA
	jr OpenCardPage

; draw the card page of the card at wLoadedCard1 and listen for input
; in order to switch the page or to exit.
; triggered by checking a card in the Hand menu.
OpenCardPage_NotCardList::
	ld a, PAD_B
	ld [wCardPageExitKeys], a
	xor a ; CARDPAGETYPE_NOT_PLAY_AREA
;	fallthrough

; draw the card page of the card at wLoadedCard1 and listen for input
; in order to switch the page or to exit.
OpenCardPage:
	ld [wCardPageType], a
	call ZeroObjectPositionsAndToggleOAMCopy
	call EmptyScreen
	; load the graphics and display the card image of wLoadedCard1
	call LoadDuelCardSymbolTiles
	call SetDefaultConsolePalettes
	ld de, v0Tiles1 + $20 tiles
	call LoadLoaded1CardGfx
	call SetBGP5ToCardPalette
	call FlushAllPalettes

	; display the initial card page for the card at wLoadedCard1
	xor a
	ld [wCardPageNumber], a
.load_next
	call DisplayFirstOrNextCardPage
	ret c ; done if trying to advance past the last page with PAD_START or PAD_A
	call EnableLCD
ShowCardPage::
.input_loop
	call DoFrame
	ldh a, [hDPadHeld]
	ld b, a
	ld a, [wCardPageExitKeys]
	and b
	jr nz, .done
	; PAD_START and PAD_A advance to the next valid card page, but close it
	; after trying to advance from the last page
	ldh a, [hKeysPressed]
	and PAD_START | PAD_A
	jr nz, OpenCardPage.load_next
	; PAD_RIGHT and PAD_LEFT advance to the next and previous valid card page respectively.
	; however, unlike PAD_START and PAD_A, PAD_RIGHT past the last page goes back to the start.
	ldh a, [hKeysPressed]
	and PAD_RIGHT | PAD_LEFT
	jr z, .input_loop
	call DisplayCardPageOnLeftOrRightPressed
	jr .input_loop
.done
	ret

; display the previous valid card page of the card at wLoadedCard1 if bit B_PAD_LEFT
; of a is set, and the first or next valid card page otherwise.
; DisplayFirstOrNextCardPage and DisplayPreviousCardPage only call DisplayCardPage
; when GoToFirstOrNextCardPage and GoToPreviousCardPage respectively return nc
; so the "call c, DisplayCardPage" instructions makes sure the card page switched
; to is always displayed.
DisplayCardPageOnLeftOrRightPressed:
	bit B_PAD_LEFT, a
	jr nz, .left
;.right
	call DisplayFirstOrNextCardPage
	call c, DisplayCardPage
	ret
.left
	call DisplayPreviousCardPage
	call c, DisplayCardPage
	ret

; display the previous valid card page
DisplayPreviousCardPage:
	call GoToPreviousCardPage
	jr nc, DisplayCardPage
	ret

; display the next valid card page or load the first valid card page if [wCardPageNumber] == 0
DisplayFirstOrNextCardPage:
	call GoToFirstOrNextCardPage
	ret c
;	fallthrough

; display the card page with id at wCardPageNumber of wLoadedCard1
DisplayCardPage:
	ld a, [wCardPageNumber]
	ld hl, .CardPageDisplayPointerTable
	call JumpToFunctionInTable
	call EnableLCD
	or a
	ret

.CardPageDisplayPointerTable:
	dw NULL
	dw DisplayCardPage_PokemonOverview    ; CARDPAGE_POKEMON_OVERVIEW
	dw DisplayCardPage_PokemonAttack1Page1  ; CARDPAGE_POKEMON_ATTACK1_1
	dw DisplayCardPage_PokemonAttack1Page2  ; CARDPAGE_POKEMON_ATTACK1_2
	dw DisplayCardPage_PokemonAttack2Page1  ; CARDPAGE_POKEMON_ATTACK2_1
	dw DisplayCardPage_PokemonAttack2Page2  ; CARDPAGE_POKEMON_ATTACK2_2
	dw DisplayCardPage_PokemonDescription ; CARDPAGE_POKEMON_DESCRIPTION
	dw NULL
	dw NULL
	dw DisplayCardPage_Energy ; CARDPAGE_ENERGY
	dw DisplayCardPage_Energy ; CARDPAGE_ENERGY + 1
	dw NULL
	dw NULL
	dw DisplayCardPage_TrainerPage1 ; CARDPAGE_TRAINER_1
	dw DisplayCardPage_TrainerPage2 ; CARDPAGE_TRAINER_2
	dw NULL

DisplayCardPage_PokemonOverview:
	ld a, [wCardPageType]
	or a ; CARDPAGETYPE_NOT_PLAY_AREA
	jr nz, .play_area_card_page

; CARDPAGETYPE_NOT_PLAY_AREA
	; print surrounding box, card name at 5,1, type, set 2, and rarity
	call PrintPokemonCardPageGenericInformation
	; print fixed text and draw the card symbol associated to its TYPE_*
	ld hl, CardPageRetreatWRTextData
	call PlaceTextItems
	ld hl, CardPageLvHPNoTextTileData
	call WriteDataBlocksToBGMap0
	lb de, 3, 2
	call DrawCardSymbol
	; print pre-evolution's name (if any)
	ld a, [wLoadedCard1Stage]
	or a
	jr z, .basic
	ld hl, wLoadedCard1PreEvoName
	lb de, 1, 3
	call InitTextPrinting_ProcessTextFromPointerToID
.basic
	; print card level and maximum HP
	lb bc, 12, 2
	ld a, [wLoadedCard1Level]
	call WriteTwoDigitNumberInTxSymbolFormat
	lb bc, 16, 2
	ld a, [wLoadedCard1HP]
	call WriteTwoByteNumberInTxSymbolFormat
	jr .print_numbers_and_energies

; CARDPAGETYPE_PLAY_AREA
.play_area_card_page
	; draw the surrounding box, and print fixed text
	call DrawCardPageSurroundingBox
	call LoadDuelCheckPokemonScreenTiles
	ld hl, CardPageRetreatWRTextData
	call PlaceTextItems
	ld hl, CardPageNoTextTileData
	call WriteDataBlocksToBGMap0
	; print set 2 icon and rarity symbol at fixed positions
	call DrawCardPageSet2AndRarityIcons
	; print (Y coord at [wCurPlayAreaY]) card name, level, type, energies, HP, location...
	; TODO
	; call PrintPlayAreaCardInformationAndLocation

; common for both card page types
.print_numbers_and_energies
	; print Pokedex number in the bottom right corner (16,16)
	lb bc, 16, 16
	ld a, [wLoadedCard1PokedexNumber]
	call WriteTwoByteNumberInTxSymbolFormat
	; print the name, damage, and energy cost of each attack and/or Pokemon power that exists
	; first attack at 5,10 and second at 5,12
	lb bc, 5, 10

.attacks
	ld e, c
	ld hl, wLoadedCard1Atk1Name
	call PrintAttackOrPkmnPowerInformation
	inc c
	inc c ; 12
	ld e, c
	ld hl, wLoadedCard1Atk2Name
	call PrintAttackOrPkmnPowerInformation
	; print the retreat cost (some amount of colorless energies) at 8,14
	inc c
	inc c ; 14
	ld b, 8
	ld a, [wLoadedCard1RetreatCost]
	ld e, a
	inc e
.retreat_cost_loop
	dec e
	jr z, .retreat_cost_done
	ld a, SYM_COLORLESS
	call WriteByteToBGMap0
	inc b
	jr .retreat_cost_loop
.retreat_cost_done
	; print the colors (energies) of the weakness(es) and resistance(s)
	inc c ; 15
	ld a, [wCardPageType]
	or a
	jr z, .wr_from_loaded_card
	ld a, [wCurPlayAreaSlot]
	or a
	jr nz, .wr_from_loaded_card
	call GetArenaCardWeakness
	ld d, a
	call GetArenaCardResistance
	ld e, a
	jr .got_wr
.wr_from_loaded_card
	ld a, [wLoadedCard1Weakness]
	ld d, a
	ld a, [wLoadedCard1Resistance]
	ld e, a
.got_wr
	ld a, d
	ld b, 8
	call PrintCardPageWeaknessesOrResistances
	inc c ; 16
	ld a, e
	jp PrintCardPageWeaknessesOrResistances

; displays the name, damage, and energy cost of an attack or Pokemon power.
; used in the Attack menu and in the card page of a Pokemon.
; input:
   ; hl: pointer to attack 1 name in a atk_data_struct (which can be inside at card_data_struct)
   ; e: Y coordinate to start printing the data at
PrintAttackOrPkmnPowerInformation:
	ld a, [hli]
	or [hl]
	ret z
	push bc
	push hl
	dec hl
	; print text ID pointed to by hl at 7,e
	ld d, 7
	call InitTextPrinting_ProcessTextFromPointerToID
	pop hl
	inc hl
	inc hl
	ld a, [wCardPageNumber]
	or a
	jr nz, .print_damage
	dec hl
	ld a, [hli]
	or [hl]
	jr z, .print_damage
	; if in Attack menu and attack 1 description exists, print at 18,e:
	ld b, 18
	ld c, e
	ld a, SYM_ATK_DESCR
	call WriteByteToBGMap0
.print_damage
	inc hl
	inc hl
	inc hl
	push hl
	ld a, [hl]
	or a
	jr z, .print_category
	; print attack damage at 15,(e+1) if non-0
	ld b, 15 ; unless damage has three digits, this is effectively 16
	ld c, e
	inc c
	call WriteTwoByteNumberInTxSymbolFormat
.print_category
	pop hl
	inc hl
	ld a, [hl]
	and $ff ^ RESIDUAL
	jr z, .print_energy_cost
	cp POKEMON_POWER
	jr z, .print_pokemon_power
	; register a is DAMAGE_PLUS, DAMAGE_MINUS, or DAMAGE_X
	; print the damage modifier (+, -, x) at 18,(e+1) (after the damage value)
	add SYM_PLUS - DAMAGE_PLUS
	ld b, 18
	ld c, e
	inc c
	call WriteByteToBGMap0
.print_energy_cost
	ld bc, CARD_DATA_ATTACK1_ENERGY_COST - CARD_DATA_ATTACK1_CATEGORY
	add hl, bc
	ld c, e
	ld b, 2 ; bc = 2, e
	lb de, NUM_TYPES / 2, 0
.energy_loop
	ld a, [hl]
	swap a
	call PrintEnergiesOfColor
	ld a, [hli]
	call PrintEnergiesOfColor
	dec d
	jr nz, .energy_loop
	pop bc
	ret
.print_pokemon_power
	; print "PKMN PWR" at 2,e
	ld d, 2
	ldtx hl, PKMNPWRText
	call InitTextPrinting_ProcessTextFromID
	pop bc
	ret

; print the number of energies required of color (type) e, and return e ++ (next color).
; the requirement of the current color is provided as input in the lower nybble of a.
PrintEnergiesOfColor:
	inc e
	and $0f
	ret z
	push de
	ld d, a
.print_energies_loop
	ld a, e
	call WriteByteToBGMap0
	inc b
	dec d
	jr nz, .print_energies_loop
	pop de
	ret

; print the weaknesses or resistances of a Pokemon card, given in a, at b,c
PrintCardPageWeaknessesOrResistances:
	push bc
	push de
	ld d, a
	xor a ; FIRE
.loop
	; each WR_* constant is a different bit. rotate the value to find out
	; which bits are set and therefore which WR_* values are active.
	; a is kept updated with the equivalent TYPE_* constant.
	inc a
	cp 8
	jr nc, .done
	rl d
	jr nc, .loop
	push af
	call WriteByteToBGMap0
	inc b
	pop af
	jr .loop
.done
	pop de
	pop bc
	ret

; prints surrounding box, card name at 5,1, type, set 2, and rarity.
; used in all CARDPAGE_POKEMON_* and ATTACKPAGE_*, except in
; CARDPAGE_POKEMON_OVERVIEW when wCardPageType is CARDPAGETYPE_PLAY_AREA.
PrintPokemonCardPageGenericInformation:
	call DrawCardPageSurroundingBox
	lb de, 5, 1
	ld hl, wLoadedCard1Name
	call InitTextPrinting_ProcessTextFromPointerToID
	ld a, [wCardPageType]
	or a
	jr z, .from_loaded_card
	ld a, [wCurPlayAreaSlot]
	call GetPlayAreaCardColor
	jr .got_color
.from_loaded_card
	ld a, [wLoadedCard1Type]
.got_color
	lb bc, 18, 1
	inc a
	call WriteByteToBGMap0
	jp DrawCardPageSet2AndRarityIcons

; draws the 20x18 surrounding box and also colorizes the card image
DrawCardPageSurroundingBox:
	lb de, 0, 0
	lb bc, 20, 18
	call DrawRegularTextBox
	lb de, 6, 4
	ld a, $a0
	lb hl, 6, 1
	lb bc, 8, 6
	call FillRectangle
	jp ApplyCardCGBAttributes

CardPageRetreatWRTextData:
	textitem 1, 14, RetreatCostText
	textitem 1, 15, WeaknessText
	textitem 1, 16, ResistanceText
	db $ff

CardPageLvHPNoTextTileData:
	db 11,  2, SYM_Lv, 0
	db 15,  2, SYM_HP, 0
;	continues to CardPageNoTextTileData

CardPageNoTextTileData:
	db 15, 16, SYM_No, 0
	db $ff

DisplayCardPage_PokemonAttack1Page1:
	ld hl, wLoadedCard1Atk1Name
	ld de, wLoadedCard1Atk1Description
	jr DisplayPokemonAttackCardPage

DisplayCardPage_PokemonAttack1Page2:
	ld hl, wLoadedCard1Atk1Name
	ld de, wLoadedCard1Atk1Description + 2
	jr DisplayPokemonAttackCardPage

DisplayCardPage_PokemonAttack2Page1:
	ld hl, wLoadedCard1Atk2Name
	ld de, wLoadedCard1Atk2Description
	jr DisplayPokemonAttackCardPage

DisplayCardPage_PokemonAttack2Page2:
	ld hl, wLoadedCard1Atk2Name
	ld de, wLoadedCard1Atk2Description + 2
;	fallthrough

; input:
   ; hl = address of the attack's name (text id)
   ; de = address of the attack's description (either first or second text id)
DisplayPokemonAttackCardPage:
	push de
	push hl
	; print surrounding box, card name at 5,1, type, set 2, and rarity
	call PrintPokemonCardPageGenericInformation
	; print name, damage, and energy cost of attack or Pokemon power starting at line 2
	ld e, 2
	pop hl
	call PrintAttackOrPkmnPowerInformation
	pop hl
;	fallthrough

; print, if non-null, the description of the trainer card, energy card, attack,
; or Pokemon power, given as a pointer to text id in hl, starting from 1,11
PrintAttackOrNonPokemonCardDescription:
	ld a, [hli]
	or [hl]
	ret z
	dec hl
	lb de, 1, 11
	call SetNoLineSeparation
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call CountLinesOfTextFromID
	cp 7
	jr c, .print
	dec e ; move one line up to fit (assumes it will be enough)
.print
	ld a, 19
	call InitTextPrintingInTextbox
	call ProcessTextFromID
	jp SetOneLineSeparation

DisplayCardPage_PokemonDescription:
	; print surrounding box, card name at 5,1, type, set 2, and rarity
	call PrintPokemonCardPageGenericInformation
	call LoadDuelCardSymbolTiles2
	; print "LENGTH", "WEIGHT", "Lv", and "HP" where it corresponds in the page
	ld hl, CardPageLengthWeightTextData
	call PlaceTextItems
	ld hl, CardPageLvHPTextTileData
	call WriteDataBlocksToBGMap0
	; draw the card symbol associated to its TYPE_* at 3,2
	lb de, 3, 2
	call DrawCardSymbol
	; print the Level and HP numbers at 12,2 and 16,2 respectively
	lb bc, 12, 2
	ld a, [wLoadedCard1Level]
	call WriteTwoDigitNumberInTxSymbolFormat
	lb bc, 16, 2
	ld a, [wLoadedCard1HP]
	call WriteTwoByteNumberInTxSymbolFormat
	; print the Pokemon's category at 1,10 (just above the length and weight texts)
	lb de, 1, 10
	ld hl, wLoadedCard1Category
	call InitTextPrinting_ProcessTextFromPointerToID
	ld a, TX_KATAKANA
	call ProcessSpecialTextCharacter
	ldtx hl, PokemonText
	call ProcessTextFromID
	; print the length and weight values at 5,11 and 5,12 respectively
	lb bc, 5, 11
	ld hl, wLoadedCard1Length
	ld a, [hli]
	ld l, [hl]
	ld h, a
	call PrintPokemonCardLength
	lb bc, 5, 12
	ld hl, wLoadedCard1Weight
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call PrintPokemonCardWeight
	ldtx hl, LbsText
	call InitTextPrinting_ProcessTextFromID
	; print the card's description without line separation
	call SetNoLineSeparation
	ld hl, wLoadedCard1Description
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call CountLinesOfTextFromID
	lb de, 1, 13
	cp 4
	jr nc, .print_description
	inc e ; move a line down, as the description is short enough to fit in three lines
.print_description
	ld a, 19 ; line length
	call InitTextPrintingInTextbox
	ld hl, wLoadedCard1Description
	call ProcessTextFromPointerToID
	jp SetOneLineSeparation

; given a card rarity constant in a, and CardRarityTextIDs in hl,
; print the text character associated to it at d,e
PrintCardPageRarityIcon:
	inc a
	add a
	ld c, a
	ld b, $00
	add hl, bc
	jp InitTextPrinting_ProcessTextFromPointerToID

; prints the card's set 2 icon and the full width text character of the card's rarity
DrawCardPageSet2AndRarityIcons:
	ld a, [wLoadedCard1Set]
	call LoadCardSet2Tiles
	jr c, .icon_done
	; draw the 2x2 set 2 icon of this card
	ld a, $fc
	lb hl, 1, 2
	lb bc, 2, 2
	lb de, 15, 8
	call FillRectangle
.icon_done
	lb de, 18, 9
	ld hl, CardRarityTextIDs
	ld a, [wLoadedCard1Rarity]
	cp PROMOSTAR
	call nz, PrintCardPageRarityIcon
	ret

CardPageLengthWeightTextData:
	textitem 1, 11, LengthText
	textitem 1, 12, WeightText
	db $ff

CardPageLvHPTextTileData:
	db 11, 2, SYM_Lv, 0
	db 15, 2, SYM_HP, 0
	db $ff

CardRarityTextIDs:
	tx PromostarRarityText ; PROMOSTAR (unused)
	tx CircleRarityText    ; CIRCLE
	tx DiamondRarityText   ; DIAMOND
	tx StarRarityText      ; STAR

DisplayCardPage_TrainerPage1:
	xor a ; HEADER_TRAINER
	ld hl, wLoadedCard1NonPokemonDescription
	jr DisplayEnergyOrTrainerCardPage

DisplayCardPage_TrainerPage2:
	xor a ; HEADER_TRAINER
	ld hl, wLoadedCard1NonPokemonDescription + 2
	jr DisplayEnergyOrTrainerCardPage

DisplayCardPage_Energy:
	ld a, HEADER_ENERGY
	ld hl, wLoadedCard1NonPokemonDescription
;	fallthrough

; input:
   ; a = HEADER_ENERGY or HEADER_TRAINER
   ; hl = address of the card's description (text id)
DisplayEnergyOrTrainerCardPage:
	push hl
	call LoadCardTypeHeaderTiles
	; draw surrounding box
	lb de, 0, 0
	lb bc, 20, 18
	call DrawRegularTextBox
	; print the card's name at 4,3
	lb de, 4, 3
	ld hl, wLoadedCard1Name
	call InitTextPrinting_ProcessTextFromPointerToID
	; colorize the card image
	lb de, 6, 4
	ld a, $a0
	lb hl, 6, 1
	lb bc, 8, 6
	call FillRectangle
	call ApplyCardCGBAttributes
	; display the card type header
	ld a, $e0
	lb hl, 1, 8
	lb de, 6, 1
	lb bc, 8, 2
	call FillRectangle
	; print the set 2 icon and rarity symbol of the card
	call DrawCardPageSet2AndRarityIcons
	pop hl
	jp PrintAttackOrNonPokemonCardDescription

; given the current card page at [wCardPageNumber], go to the next valid card page or load
; the first valid card page of the current card at wLoadedCard1 if [wCardPageNumber] == 0
GoToFirstOrNextCardPage:
	ld a, [wCardPageNumber]
	or a
	jr nz, .advance_page
	; load the first page for this type of card
	ld a, [wLoadedCard1Type]
	ld b, a
	ld a, CARDPAGE_ENERGY
	bit TYPE_ENERGY_F, b
	jr nz, .set_initial_page
	ld a, CARDPAGE_TRAINER_1
	bit TYPE_TRAINER_F, b
	jr nz, .set_initial_page
	ld a, CARDPAGE_POKEMON_OVERVIEW
.set_initial_page
	ld [wCardPageNumber], a
	or a
	ret
.advance_page
	ld hl, wCardPageNumber
	inc [hl]
	ld a, [hl]
	call SwitchCardPage
	jr c, .set_card_page
	; stay in this page if it exists, or skip to previous page if it doesn't
	or a
	ret nz
	; non-existent page: skip to next
	jr .advance_page
.set_card_page
	ld [wCardPageNumber], a
	ret

; given the current card page at [wCardPageNumber], go to the previous
; valid card page for the current card at wLoadedCard1
GoToPreviousCardPage:
	ld hl, wCardPageNumber
	dec [hl]
	ld a, [hl]
	call SwitchCardPage
	jr c, .set_card_page
	; stay in this page if it exists, or skip to previous page if it doesn't
	or a
	ret nz
	; non-existent page: skip to previous
	jr GoToPreviousCardPage
.set_card_page
	ld [wCardPageNumber], a
.previous_page_loop
	call SwitchCardPage
	or a
	jr nz, .stay
	ld hl, wCardPageNumber
	dec [hl]
	jr .previous_page_loop
.stay
	scf
	ret

; check if the card page trying to switch to is valid for the card at wLoadedCard1
; return with the equivalent to one of these three actions:
   ; stay in card page trying to switch to (nc, nz)
   ; change to card page returned in a if PAD_LEFT/PAD_RIGHT pressed, or exit if PAD_A/PAD_START pressed (c)
   ; non-existent page, so skip to next/previous (nc, z)
SwitchCardPage:
	ld hl, CardPageSwitchPointerTable
	jp JumpToFunctionInTable

CardPageSwitchPointerTable:
	dw CardPageSwitch_00
	dw CardPageSwitch_PokemonOverviewOrDescription ; CARDPAGE_POKEMON_OVERVIEW
	dw CardPageSwitch_PokemonAttack1Page1 ; CARDPAGE_POKEMON_ATTACK1_1
	dw CardPageSwitch_PokemonAttack1Page2 ; CARDPAGE_POKEMON_ATTACK1_2
	dw CardPageSwitch_PokemonAttack2Page1 ; CARDPAGE_POKEMON_ATTACK2_1
	dw CardPageSwitch_PokemonAttack2Page2 ; CARDPAGE_POKEMON_ATTACK2_2
	dw CardPageSwitch_PokemonOverviewOrDescription ; CARDPAGE_POKEMON_DESCRIPTION
	dw CardPageSwitch_PokemonEnd
	dw CardPageSwitch_08
	dw CardPageSwitch_EnergyOrTrainerPage1 ; CARDPAGE_ENERGY
	dw CardPageSwitch_TrainerPage2 ; CARDPAGE_ENERGY + 1
	dw CardPageSwitch_EnergyEnd
	dw CardPageSwitch_0c
	dw CardPageSwitch_EnergyOrTrainerPage1 ; CARDPAGE_TRAINER_1
	dw CardPageSwitch_TrainerPage2 ; CARDPAGE_TRAINER_2
	dw CardPageSwitch_TrainerEnd

; return with CARDPAGE_POKEMON_DESCRIPTION
CardPageSwitch_00:
	ld a, CARDPAGE_POKEMON_DESCRIPTION
	scf
	ret

; return with current page
CardPageSwitch_PokemonOverviewOrDescription:
	ld a, $1
	or a
	ret ; nz

; return with current page if [wLoadedCard1Atk1Name] non-0
; (if card has at least one attack)
CardPageSwitch_PokemonAttack1Page1:
	ld hl, wLoadedCard1Atk1Name
	jr CheckCardPageExists

; return with current page if [wLoadedCard1Atk1Description + 2] non-0
; (if card's first attack has a two-page description)
CardPageSwitch_PokemonAttack1Page2:
	ld hl, wLoadedCard1Atk1Description + 2
	jr CheckCardPageExists

; return with current page if [wLoadedCard1Atk2Name] non-0
; (if card has two attacks)
CardPageSwitch_PokemonAttack2Page1:
	ld hl, wLoadedCard1Atk2Name
	jr CheckCardPageExists

; return with current page if [wLoadedCard1Atk1Description + 2] non-0
; (if card's second attack has a two-page description)
CardPageSwitch_PokemonAttack2Page2:
	ld hl, wLoadedCard1Atk2Description + 2
;	fallthrough

CheckCardPageExists:
	ld a, [hli]
	or [hl]
	ret

; return with CARDPAGE_POKEMON_OVERVIEW
CardPageSwitch_PokemonEnd:
	ld a, CARDPAGE_POKEMON_OVERVIEW
	scf
	ret

; return with CARDPAGE_ENERGY + 1
CardPageSwitch_08:
	ld a, CARDPAGE_ENERGY + 1
	scf
	ret

; return with current page
CardPageSwitch_EnergyOrTrainerPage1:
	ld a, $1
	or a
	ret ; nz

; return with current page if [wLoadedCard1NonPokemonDescription + 2] non-0
; (if this trainer card has a two-page description)
CardPageSwitch_TrainerPage2:
	ld hl, wLoadedCard1NonPokemonDescription + 2
	jr CheckCardPageExists

; return with CARDPAGE_ENERGY
CardPageSwitch_EnergyEnd:
	ld a, CARDPAGE_ENERGY
	scf
	ret

; return with CARDPAGE_TRAINER_2
CardPageSwitch_0c:
	ld a, CARDPAGE_TRAINER_2
	scf
	ret

; return with CARDPAGE_TRAINER_1
CardPageSwitch_TrainerEnd:
	ld a, CARDPAGE_TRAINER_1
	scf
	ret

; given a number in hl, print it divided by 10 at b,c, with decimal part
; separated by a dot (unless it's 0). used to print a Pokemon card's weight.
PrintPokemonCardWeight:
	push bc
	ld de, -1
	ld bc, -10
.divide_by_10_loop
	inc de
	add hl, bc
	jr c, .divide_by_10_loop
	ld bc, 10
	add hl, bc
	pop bc
	push hl
	push bc
	ld l, e
	ld h, d
	call TwoByteNumberToTxSymbol_TrimLeadingZeros
	pop bc
	pop hl
	ld a, l
	ld hl, wStringBuffer + 5
	or a
	jr z, .decimal_done
	ld [hl], SYM_DOT
	inc hl
	add SYM_0
	ld [hli], a
.decimal_done
	ld [hl], 0
	push bc
	call BCCoordToBGMap0Address
	ld hl, wStringBuffer
.find_first_digit_loop
	ld a, [hli]
	or a
	jr z, .find_first_digit_loop
	dec hl
	push hl
	ld b, -1
.get_number_length_loop
	inc b
	ld a, [hli]
	or a
	jr nz, .get_number_length_loop
	pop hl
	push bc
	call SafeCopyDataHLtoDE
	pop bc
	pop de
	ld a, b
	add d
	ld d, a
	ret

; given a number in h and another in l, print them formatted as <l>'<h>" at b,c.
; used to print the length (feet and inches) of a Pokemon card.
PrintPokemonCardLength:
	push hl
	ld l, h
	ld h, $00
	ldtx de, FeetText ; '
	call .print_feet_or_inches
	pop hl
	ld h, $00
	ldtx de, InchesText ; "
	call .print_feet_or_inches
	ret

.print_feet_or_inches
; keep track how many digits each number consists of in wPokemonLengthPrintOffset,
; in order to align the rest of the string. the text with id at de
; is printed after the number.
	push de
	push bc
	call TwoByteNumberToTxSymbol_TrimLeadingZeros
	ld a, b
	inc a
	ld [wPokemonLengthPrintOffset], a
	pop bc
	push bc
	push hl
	call BCCoordToBGMap0Address
	ld a, [wPokemonLengthPrintOffset]
	ld b, a
	pop hl
	call SafeCopyDataHLtoDE
	pop bc
	ld a, [wPokemonLengthPrintOffset]
	add b
	ld b, a
	pop hl
	push bc
	ld e, c
	ld d, b
	call InitTextPrinting
	call ProcessTextFromID
	pop bc
	inc b
	ret

; print lines of text with no separation between them
SetNoLineSeparation:
	ld a, SINGLE_SPACED
;	fallthrough

SetLineSeparation:
	ld [wLineSeparation], a
	ret

; separate lines of text by an empty line
SetOneLineSeparation:
	xor a ; DOUBLE_SPACED
	jr SetLineSeparation

; given a number between 0-255 in a, converts it to TX_SYMBOL format,
; and writes it to wStringBuffer + 2 and to the BGMap0 address at bc.
; leading zeros replaced with SYM_SPACE.
WriteTwoByteNumberInTxSymbolFormat:
	push de
	push bc
	ld l, a
	ld h, $00
	call TwoByteNumberToTxSymbol_TrimLeadingZeros
	pop bc
	push bc
	call BCCoordToBGMap0Address
	ld hl, wStringBuffer + 2
	ld b, 3
	call SafeCopyDataHLtoDE
	pop bc
	pop de
	ret

; given a number between 0-99 in a, converts it to TX_SYMBOL format,
; and writes it to wStringBuffer + 3 and to the BGMap0 address at bc.
; if the number is between 0-9, the first digit is replaced with SYM_SPACE.
WriteTwoDigitNumberInTxSymbolFormat:
	push hl
	push de
	push bc
	ld l, a
	ld h, $00
	call TwoByteNumberToTxSymbol_TrimLeadingZeros
	pop bc
	push bc
	call BCCoordToBGMap0Address
	ld hl, wStringBuffer + 3
	ld b, 2
	call SafeCopyDataHLtoDE
	pop bc
	pop de
	pop hl
	ret
