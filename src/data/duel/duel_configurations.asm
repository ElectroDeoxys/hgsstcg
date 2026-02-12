DeckDuelConfigurations:
	table_width 10

	db TEST_DECK ; deck ID
	db PORTRAIT_SAM ; NPC portrait
	tx SamNPCName ; name text ID
	db PRIZES_2 ; number of prize cards
	db MUSIC_STOP ; theme
	dw NULL ; rank
	dw NULL ; element

	assert_table_length NUM_AI_DECK_IDS
	db -1 ; end
