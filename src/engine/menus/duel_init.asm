Duel_Init:
	ld a, [wd291]
	push af
	call DisableLCD
	call InitMenuScreen
	ld a, $1
	ld [wTextBoxFrameType], a
	lb de,  0, 12
	lb bc, 20,  6
	call DrawRegularTextBox
	ld a, [wNPCDuelDeck]
	add a
	add a
	ld c, a
	ld b, $0
	ld hl, OpponentTitlesAndDeckNames
	add hl, bc
	ld a, [hli]
	ld [wTxRam2], a
	ld a, [hli]
	ld [wTxRam2 + 1], a
	push hl
	ld a, [wOpponentName]
	ld [wTxRam2_b], a
	ld a, [wOpponentName + 1]
	ld [wTxRam2_b + 1], a
	ld hl, OpponentTitleAndNameLabel
	call PrintLabels ; LoadDuelistName
	pop hl
	ld a, [hli]
	ld [wTxRam2], a
	ld c, a
	ld a, [hli]
	ld [wTxRam2 + 1], a
	or c
	jr z, .skip_deck_name
	ld hl, OpponentDeckNameLabel
	call PrintLabels ; LoadDeckName
.skip_deck_name
	lb bc, 7, 3
	ld a, [wOpponentPortrait]
	ld e, EMOTION_NEUTRAL
	call DrawOpponentPortrait
	ld a, [wMatchStartTheme]
	call PlaySong
	call FlashWhiteScreen
	call DoFrameIfLCDEnabled
	lb bc, $2f, $1d ; cursor tile, tile behind cursor
	lb de, 18, 17 ; x, y
	call SetCursorParametersForTextBox
	call WaitForButtonAorB
	call WaitForSongToFinish
	call FadeScreenToWhite ; fade out
	pop af
	ld [wd291], a
	ret

OpponentTitleAndNameLabel:
	db 1, 14
	tx OpponentTitleAndNameText
	db $ff

OpponentDeckNameLabel:
	db 1, 16
	tx OpponentDeckNameText
	db $ff

OpponentTitlesAndDeckNames:
	table_width 4

	tx EmptyText
	dw NULL

	tx EmptyText
	dw NULL

	tx EmptyText
	dw NULL

	tx EmptyText
	dw NULL

	tx EmptyText
	dw NULL

	tx EmptyText
	dw NULL

	tx EmptyText
	dw NULL

	assert_table_length NUM_DECKS
