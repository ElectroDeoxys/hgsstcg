DeckPointers::
	table_width 2
	dw CharmanderAndFriendsDeck
	dw CharmanderExtraDeck
	dw SquirtleAndFriendsDeck
	dw SquirtleExtraDeck
	dw BulbasaurAndFriendsDeck
	dw BulbasaurExtraDeck
	dw TestDeck
	assert_table_length NUM_DECKS

CharmanderAndFriendsDeck:
	deck_list_start
	card_item FIRE_ENERGY,      10
	card_item LIGHTNING_ENERGY,  8
	card_item FIGHTING_ENERGY,   6
	card_item CHARMANDER,        2
	card_item CHARMELEON,        1
	card_item CHARIZARD,         1
	card_item GROWLITHE,         2
	card_item ARCANINE_LV45,     1
	card_item PONYTA,            2
	card_item MAGMAR_LV24,       1
	card_item PIKACHU_LV12,      2
	card_item RAICHU_LV40,       1
	card_item MAGNEMITE_LV13,    2
	card_item MAGNETON_LV28,     1
	card_item ZAPDOS_LV64,       1
	card_item DIGLETT,           2
	card_item DUGTRIO,           1
	card_item MACHOP,            1
	card_item MACHOKE,           1
	card_item RATTATA,           2
	card_item RATICATE,          1
	card_item MEOWTH_LV14,       1
	card_item PROFESSOR_OAK,     1
	card_item BILL,              2
	card_item SWITCH,            1
	card_item COMPUTER_SEARCH,   1
	card_item PLUSPOWER,         1
	card_item POTION,            2
	card_item FULL_HEAL,         2
	deck_list_end
	tx CharmanderAndFriendsDeckName

CharmanderExtraDeck:
	deck_list_start
	card_item GRASS_ENERGY,    4
	card_item WATER_ENERGY,    4
	card_item PSYCHIC_ENERGY,  3
	card_item BULBASAUR,       1
	card_item IVYSAUR,         1
	card_item NIDORANF,        2
	card_item CATERPIE,        2
	card_item METAPOD,         1
	card_item NIDORANM,        1
	card_item PINSIR,          1
	card_item SEEL,            2
	card_item DEWGONG,         1
	card_item GOLDEEN,         2
	card_item SEAKING,         1
	card_item ABRA,            2
	card_item KADABRA,         1
	card_item GASTLY_LV8,      1
	card_item GRASS_ENERGY,   30 ; irrelevant
	deck_list_end
	tx CharmanderExtraDeckName

SquirtleAndFriendsDeck:
	deck_list_start
	card_item WATER_ENERGY,    11
	card_item FIGHTING_ENERGY,  6
	card_item PSYCHIC_ENERGY,   8
	card_item SQUIRTLE,         2
	card_item WARTORTLE,        1
	card_item BLASTOISE,        1
	card_item SEEL,             2
	card_item DEWGONG,          1
	card_item STARYU,           1
	card_item STARMIE,          1
	card_item GOLDEEN,          1
	card_item SEAKING,          1
	card_item LAPRAS,           1
	card_item ABRA,             2
	card_item KADABRA,          1
	card_item GASTLY_LV8,       2
	card_item HAUNTER_LV22,     1
	card_item MACHOP,           1
	card_item MACHOKE,          1
	card_item GEODUDE,          2
	card_item HITMONCHAN,       1
	card_item RATTATA,          2
	card_item RATICATE,         1
	card_item MEOWTH_LV14,      1
	card_item PROFESSOR_OAK,    1
	card_item BILL,             1
	card_item SWITCH,           1
	card_item POKE_BALL,        1
	card_item SCOOP_UP,         1
	card_item ITEM_FINDER,      1
	card_item POTION,           1
	card_item FULL_HEAL,        1
	deck_list_end
	tx SquirtleAndFriendsDeckName

SquirtleExtraDeck:
	deck_list_start
	card_item GRASS_ENERGY,      3
	card_item FIRE_ENERGY,       4
	card_item LIGHTNING_ENERGY,  4
	card_item NIDORANF,          2
	card_item NIDORANM,          1
	card_item CATERPIE,          1
	card_item METAPOD,           1
	card_item WEEDLE,            1
	card_item KAKUNA,            1
	card_item PINSIR,            1
	card_item CHARMANDER,        2
	card_item CHARMELEON,        1
	card_item MAGMAR_LV24,       1
	card_item GROWLITHE,         1
	card_item ARCANINE_LV45,     1
	card_item PIKACHU_LV12,      2
	card_item MAGNEMITE_LV13,    1
	card_item MAGNETON_LV28,     1
	card_item ELECTABUZZ_LV35,   1
	card_item GRASS_ENERGY,     30 ; irrelevant
	deck_list_end
	tx SquirtleExtraDeckName

BulbasaurAndFriendsDeck:
	deck_list_start
	card_item GRASS_ENERGY,    11
	card_item FIRE_ENERGY,      3
	card_item WATER_ENERGY,     9
	card_item BULBASAUR,        2
	card_item IVYSAUR,          1
	card_item VENUSAUR_LV67,    1
	card_item CATERPIE,         2
	card_item METAPOD,          1
	card_item NIDORANF,         2
	card_item NIDORANM,         2
	card_item NIDORINO,         1
	card_item TANGELA_LV12,     1
	card_item FLAREON_LV28,     1
	card_item SEEL,             1
	card_item DEWGONG,          1
	card_item KRABBY,           2
	card_item KINGLER,          1
	card_item GOLDEEN,          2
	card_item SEAKING,          1
	card_item VAPOREON_LV42,    1
	card_item JIGGLYPUFF_LV14,  1
	card_item MEOWTH_LV14,      1
	card_item EEVEE,            2
	card_item KANGASKHAN,       1
	card_item PROFESSOR_OAK,    1
	card_item SWITCH,           1
	card_item POKE_BALL,        1
	card_item PLUSPOWER,        2
	card_item DEFENDER,         1
	card_item FULL_HEAL,        2
	card_item REVIVE,           1
	deck_list_end
	tx BulbasaurAndFriendsDeckName

BulbasaurExtraDeck:
	deck_list_start
	card_item LIGHTNING_ENERGY,  4
	card_item PSYCHIC_ENERGY,    4
	card_item FIGHTING_ENERGY,   3
	card_item PIKACHU_LV12,      2
	card_item RAICHU_LV40,       1
	card_item MAGNEMITE_LV13,    1
	card_item ELECTABUZZ_LV35,   1
	card_item ABRA,              2
	card_item KADABRA,           1
	card_item JYNX,              1
	card_item GASTLY_LV8,        2
	card_item HAUNTER_LV22,      1
	card_item DIGLETT,           1
	card_item DUGTRIO,           1
	card_item HITMONCHAN,        1
	card_item BILL,              1
	card_item POTION,            2
	card_item GUST_OF_WIND,      1
	card_item GRASS_ENERGY,     30 ; irrelevant
	deck_list_end
	tx BulbasaurExtraDeckName

TestDeck:
	deck_list_start
	card_item BULBASAUR,     4
	card_item CHARMANDER,    4
	card_item SQUIRTLE,      4
	card_item GRASS_ENERGY, 16
	card_item FIRE_ENERGY,  16
	card_item WATER_ENERGY, 16
	deck_list_end
	tx BulbasaurExtraDeckName

