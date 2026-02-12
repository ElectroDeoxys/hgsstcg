; *_DECK constants are to be used with LoadDeck and related routines.
	const_def
	const CHARMANDER_AND_FRIENDS_DECK ; $00
	const CHARMANDER_EXTRA_DECK       ; $01
	const SQUIRTLE_AND_FRIENDS_DECK   ; $02
	const SQUIRTLE_EXTRA_DECK         ; $03
	const BULBASAUR_AND_FRIENDS_DECK  ; $04
	const BULBASAUR_EXTRA_DECK        ; $05
DEF NUM_STARTER_DECK_IDS EQU const_value
	const TEST_DECK                   ; $06
DEF NUM_DECKS EQU const_value

DEF NUM_AI_DECK_IDS EQU NUM_DECKS - NUM_STARTER_DECK_IDS
