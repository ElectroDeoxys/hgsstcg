SECTION "HRAM", HRAM

hBankROM::
	ds $1

hBankSRAM::
	ds $1

hBankVRAM::
	ds $1

hDMAFunction::
	ds $a

; D-pad repeat counter. see HandleDPadRepeat
hDPadRepeat::
	ds $1

; keys pressed in last frame but not in current frame
hKeysReleased::
	ds $1

; used to quickly scroll through menus when a relevant D-pad key is held
; see HandleDPadRepeat
hDPadHeld::
	ds $1

; keys pressed in last frame and in current frame
hKeysHeld::
	ds $1

; keys pressed in current frame but not in last frame
hKeysPressed::
	ds $1

hSCX::
	ds $1

hSCY::
	ds $1

hWX::
	ds $1

hWY::
	ds $1

hff96::
	ds $1

; $c2 = player ; $c3 = opponent
hWhoseTurn::
	ds $1

; used in SortCardsInListByID
hTempListPtr_ff99::
	ds $2

; used in SortCardsInListByID
; this function supports 16-bit card IDs
hTempCardID_ff9b::
	ds $2

; hffa8 through hffb0 belong to the text engine
hffa8::
	ds $1

hffa9::
	ds $1

; Address within v*BGMap0 where text is currently being written to
hTextBGMap0Address::
	ds $2

; position within a line of text where text is currently being placed at
; ranges between 0 and [hTextLineLength]
hTextLineCurPos::
	ds $1

; used as an x coordinate offset when printing text, in order to align
; the text's starting position and/or adjust for the BG scroll registers
hTextHorizontalAlign::
	ds $1

; how many tiles can be fit per line in the current text area
; for example, 11 for a narrow text box and 19 for a wide text box
hTextLineLength::
	ds $1

; when printing text and no leading control character is specified, whether characters
; $10 to $60 map to the katakana.1bpp font graphics as characters $0 to $50
; (TX_KATAKANA mode), or map to the hiragana.1bpp font graphics (TX_HIRAGANA mode).
; the TX_HIRAGANA and TX_KATAKANA control characters are used to set this address to said
; value. only these two values are admitted, as any other is interpreted as TX_HIRAGANA.
hJapaneseSyllabary::
	ds $1

hffb0::
	ds $1

; unlike wCurMenuItem, this accounts for the scroll offset (wListScrollOffset)
hCurMenuItem::
	ds $1

hffb3::
	ds $1

hffb4::
	ds $1

hffb5::
	ds $1

; used in DivideBCbyDE
hffb6::
	ds $1

hffb7::
	ds $1
