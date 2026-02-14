StartDuel::
	push_wram BANK("WRAM Duel")

	; clear relevant WRAM
	call ClearDuelWRAM
	call ClearAIWRAM

	call SetupDuel
	call DuelLoop

	pop_wram
	ret

ClearDuelWRAM:
	xor a
	ld [wDuelResult], a

	ld hl, STARTOF("WRAM Duel")
	ld bc, SIZEOF("WRAM Duel")
.loop_1
	xor a
	ld [hli], a
	dec bc
	ld a, b
	or c
	jr nz, .loop_1

	; clear duel variables
	ld hl, wPlayerDuelVariables
.loop_2
	xor a
	ld [hli], a
	ld a, h
	cp HIGH(wOpponentDuelVariables) + 1
	jr nz, .loop_2
	ret

ClearAIWRAM:
	push_wram BANK("WRAM AI")

	ld hl, STARTOF("WRAM AI")
	ld bc, SIZEOF("WRAM AI")
.loop
	xor a
	ld [hli], a
	dec bc
	ld a, b
	or c
	jr nz, .loop

	pop_wram
	ret

SetupDuel:
	; start with player
	ld a, PLAYER_TURN
	ld [wWhoseTurn], a
	ldh [hWhoseTurn], a

	; load player's deck
	call EnableSRAM
	ld a, [sCurrentlySelectedDeck]
	ld l, a
	ld h, sDeck2Cards - sDeck1Cards
	call HtimesL
	ld de, sDeck1Cards
	add hl, de
	ld d, h
	ld e, l
	ld hl, wPlayerDeck
	call DecompressSRAMDeck
	call DisableSRAM

	; load opponent's deck
	swap_turn
	ld a, [wOpponentDeckID]
	call LoadDeck
	swap_turn

	ld a, [wNPCDuelPrizes]
	ld [wDuelInitialPrizes], a

	; init duelist variables
	call .InitDuelistVariables
	swap_turn
	call .InitDuelistVariables
	swap_turn

	; shuffle both duelist's decks
	ld a, DUELVARS_DECK_CARDS
	get_turn_duelist_var
	ld a, DECK_SIZE
	call ShuffleList

	ld a, DUELVARS_DECK_CARDS
	call GetNonTurnDuelistVariable
	ld a, DECK_SIZE
	call ShuffleList

.draw_initial
	xor a
	ld hl, wMulligans
	ld [hli], a ; wPlayerMulligans
	ld [hli], a ; wOpponentMulligans

	ld a, 7
	call DrawNCards
	swap_turn
	ld a, 7
	call DrawNCards
	swap_turn

	call .CheckDuelistStartingHand
	swap_turn
	call .CheckDuelistStartingHand
	swap_turn
	ld hl, wMulligans
	ld a, [hli] ; wPlayerMulligans
	cp [hl] ; wOpponentMulligans
	jr z, .same_mulligans

	; being here means only 1 duelist has no basic cards
	or a ; player mulligans != 0?
	jr nz, .opp_has_no_basics

; player has no basics
	call .DrawInitialUntilDuelistHasBasics
	jr .got_initial_draw

.opp_has_no_basics
	swap_turn
	call .DrawInitialUntilDuelistHasBasics
	swap_turn
	jr .got_initial_draw

.same_mulligans
	; did mulligans happen?
	or a
	jr z, .got_initial_draw ; no, we can continue as normal
	; shuffle hand cards back into deck
	call CreateHandCardList
	call ShuffleCardsIntoDeck

	swap_turn
	call CreateHandCardList
	call ShuffleCardsIntoDeck
	swap_turn
	jr .draw_initial

.got_initial_draw
	; at this point only one duelist can have mulligans
	; TODO make this drawing optional
	ld hl, wMulligans
	ld a, [hli]
	or a
	jr z, .check_opp_mulligans
; player has mulligans
	call DrawNCards
	jr .resolved_mulligans
.check_opp_mulligans
	ld a, [hli]
	or a
	jr z, .resolved_mulligans
; opp has mulligans
	swap_turn
	call DrawNCards
	swap_turn

.resolved_mulligans
	; TODO handle initial Play Area selection
	; for now it's done automatically
	call PlayAllBasics
	swap_turn
	call PlayAllBasics
	swap_turn
	ret

.InitDuelistVariables:
	; all cards are in deck
	xor a ; DUELVARS_CARD_LOCATIONS
	get_turn_duelist_var
	ld b, DECK_SIZE
.loop_locations
	ld [hli], a
	dec b
	jr nz, .loop_locations

	; a = 0
	; l = DUELVARS_DECK_CARDS
	ld b, DECK_SIZE
.loop_deck_cards
	ld [hli], a
	inc a
	dec b
	jr nz, .loop_deck_cards

	; a = DECK_SIZE
	ld l, DUELVARS_NUMBER_OF_CARDS_IN_DECK
	ld [hl], a

	ld l, DUELVARS_PLAY_AREA
	ld a, -1
	ld b, MAX_PLAY_AREA_POKEMON + 1
.loop_play_area
	ld [hli], a
	dec b
	jr nz, .loop_play_area

	; init prize bitmasks
	ld a, [wDuelInitialPrizes]
	ld b, 1
.loop_get_bitmask
	sla b
	dec a
	jr nz, .loop_get_bitmask
	dec b
	ld l, DUELVARS_PRIZES
	ld [hl], b
	ret

.DrawInitialUntilDuelistHasBasics:
	call CreateHandCardList
	call ShuffleCardsIntoDeck

	ld a, 7
	call DrawNCards
	call .CheckDuelistStartingHand
	jr c, .DrawInitialUntilDuelistHasBasics
	ret

; if turn-duelist has no basic cards in hand
; then increment non-turn duelist mulligan counter
; and return carry
.CheckDuelistStartingHand:
	call CreateHandCardList
	ld hl, wList
.loop_hand
	ld a, [hli]
	cp -1
	jr z, .no_basics
	call LoadCardDataToBuffer1_FromDeckIndex
	ld a, [wLoadedCard1Type]
	cp TYPE_ENERGY
	jr nc, .loop_hand ; not pkmn card
	ld a, [wLoadedCard1Stage]
	or a
	ret z ; found basic
	jr .loop_hand

.no_basics
	ld a, [hWhoseTurn]
	ld hl, wPlayerMulligans
	and %1
	jr nz, .got_mulligans
	inc hl ; wOpponentMulligans
.got_mulligans
	inc [hl]
	scf
	ret

PlayAllBasics:
	call CreateHandCardList
	ld hl, wList
.loop_hand
	ld a, [hli]
	ld b, a
	cp -1
	ret z
	call LoadCardDataToBuffer1_FromDeckIndex
	ld a, [wLoadedCard1Type]
	cp TYPE_ENERGY
	jr nc, .loop_hand ; not pkmn card
	ld a, [wLoadedCard1Stage]
	or a
	jr nz, .loop_hand ; not basic
	ld a, b
	push hl
	call PlayPkmnCardFromHand
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	get_turn_duelist_var
	pop hl
	cp MAX_PLAY_AREA_POKEMON
	ret z ; no more space
	jr .loop_hand

DuelLoop:
	ld [wDuelLoopSP], sp

.loop
	call DuelScene
	jp .loop

; draws a number of cards
; deck must not be empty!
; returns carry if deck got empty as a result
DrawNCards:
	ld c, a
.loop
	call .DrawCard
	ret c
	dec c
	jr nz, .loop
	or a
	ret

.DrawCard:
	ld a, DUELVARS_NUMBER_OF_CARDS_IN_DECK
	get_turn_duelist_var
	dec a
	ld [hl], a
	ld b, a
	add DUELVARS_DECK_CARDS
	ld l, a
	; hl = DeckCards + (num remaining cards) - 1

	ld l, [hl]
	; hl = card location of this card
	ld a, CARD_LOCATION_HAND
	ld [hl], a ; set it as being in hand

	; increase number of cards in hand
	ld l, DUELVARS_NUMBER_OF_CARDS_IN_HAND
	inc [hl]

	ld a, b
	cp 1
	ret ; carry set if 0 remaining deck cards

; shuffles all cards in wList into turn-player's deck
ShuffleCardsIntoDeck:
	ld hl, wList
.loop
	ld a, [hli]
	cp -1
	jr z, .shuffle
	push hl
	call PlaceCardOnTopOfDeck
	pop hl
	jr .loop

.shuffle
	ld a, DUELVARS_NUMBER_OF_CARDS_IN_DECK
	get_turn_duelist_var
	ld l, DUELVARS_DECK_CARDS
	jp ShuffleList

; places card index given in a on top of turn-duelist's deck
PlaceCardOnTopOfDeck:
	ld c, a
	ld a, DUELVARS_NUMBER_OF_CARDS_IN_DECK
	get_turn_duelist_var
	inc [hl]
	add DUELVARS_DECK_CARDS
	ld l, a
	push hl
	; hl = non-deck cards + 0
	ld a, [hli]
.loop_shift
	cp c ; is it input card?
	jr z, .done_shift
	ld b, [hl]
	ld [hli], a
	ld a, b
	jr .loop_shift

.done_shift
	pop hl
	ld [hl], a ; place on top of deck
	ld l, a
	ld a, [hl] ; card location
	ld [hl], CARD_LOCATION_DECK ; set it as deck location
	; decrement num cards of whichever location it was
	add DUELVARS_NUMBER_OF_CARDS_IN_DECK
	ld l, a
	dec [hl]
	ret

; plays Pkmn card with card index given in a
; to turn-duelist's Play Area
PlayPkmnCardFromHand:
	ld b, a
	ld a, DUELVARS_NUMBER_OF_POKEMON_IN_PLAY_AREA
	get_turn_duelist_var
	inc [hl] ; increment num of Pkmn in Play Area
	ld c, a ; play area location

	; set play area card
	inc a
	add l
	ld l, a
	ld [hl], b ; DUELVARS_PLAY_AREA + n

	; set its location
	ld a, c
	or CARD_LOCATION_PLAY_AREA
	ld l, b
	ld [hl], a

	ld l, DUELVARS_NUMBER_OF_CARDS_IN_HAND
	dec [hl] ; decrement num of cards in hand

	; initialise Play Area variables
	ld a, b
	call LoadCardDataToBuffer1_FromDeckIndex
	ld b, 0

	; hp
	ld l, DUELVARS_PLAY_AREA_HP
	add hl, bc
	ld a, [wLoadedCard1HP]
	ld [hl], a
	; stage
	ld l, DUELVARS_PLAY_AREA_STAGE
	add hl, bc
	ld a, [wLoadedCard1Stage]
	ld [hl], a
	; defenders
	ld l, DUELVARS_PLAY_AREA_ATTACHED_DEFENDER
	add hl, bc
	ld [hl], 0
	; pluspowers
	ld l, DUELVARS_PLAY_AREA_ATTACHED_PLUSPOWER
	add hl, bc
	ld [hl], 0
	; changed type
	ld l, DUELVARS_ACTIVE_CHANGED_TYPE
	add hl, bc
	ld [hl], NONE
	ret
