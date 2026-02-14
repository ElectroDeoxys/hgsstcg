; shows card list given in wList
; with list parameters given in hl
DisplayCardList:
	xor a
	ld [wTileMapFill], a
	call EmptyScreen
	call ClearOAM
	ret

CardListParam_HandCards:

