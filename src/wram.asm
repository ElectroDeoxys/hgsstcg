INCLUDE "macros.asm"
INCLUDE "constants.asm"

INCLUDE "vram.asm"

SECTION "WRAM", WRAM0

UNION

wTempCardCollection::
	ds CARD_COLLECTION_SIZE

NEXTU

; used in DrawLabeledTextBox to draw the top border
; of a label text box (with top border symbols and NPC name)
wLabeledTextBoxTopBorder::
	ds $100

NEXTU

; aside from wDecompressionBuffer, which stores the
; de facto final decompressed data after decompression,
; this buffer stores a secondary buffer that is used
; for "lookbacks" when repeating byte sequences.
; actually starts in the middle of the buffer,
; at wDecompressionSecondaryBufferStart, then wraps back up
; to wDecompressionSecondaryBuffer.
; this is used so that $00 can be "looked back", since anything
; before $ef is initialized to 0 when starting decompression.
wDecompressionSecondaryBuffer::
	ds $ef
wDecompressionSecondaryBufferStart::
	ds $11

NEXTU

; buffer used to store a deck that will be built
wDeckToBuild::
	ds DECK_STRUCT_SIZE

ENDU

; In order to be identified during a duel, the 60 cards of each duelist are given an index between 0 and 59.
; These indexes are assigned following the order of the card list in wPlayerDeck or wOpponentDeck,
; which, in turn, follows the internal order of the cards.
; This temporary index of a card identifies the card within the duelist's deck during an ongoing duel.

; Terminology used in labels and comments:
; - The deck index, or the index within the deck of a card refers to the identifier mentioned just above,
;   that is, its temporary position in the wPlayerDeck or wOpponentDeck card list during the current duel.
; - The card ID is its actual internal identifier, that is, its number from card_constants.asm.
; check macros/wram.asm for information on each variable
wPlayerDuelVariables::   duel_vars wPlayer
wOpponentDuelVariables:: duel_vars wOpponent

; this holds an $ff-terminated list of card deck indexes (e.g. cards in hand or in bench)
; or (less often) the attack list of a Pokemon card
wList::
	ds $80

UNION

; temporary list of the cards drawn from a booster pack
wBoosterCardsDrawn::
wBoosterTempNonEnergiesDrawn::
	ds 2 * 11
wBoosterTempEnergiesDrawn::
	ds 2 * 11
wBoosterCardsDrawnEnd::

NEXTU

wPlayerDeck::
	ds DECK_SIZE * 2

ENDU

wOpponentDeck::
	ds DECK_SIZE * 2

; this holds names like player's or opponent's.
wNameBuffer::
	ds NAME_BUFFER_LENGTH

UNION

; this is kept updated with some default text that is used
; when the text printing functions are called with text id $0000
wDefaultText::
	ds $3c

NEXTU

; used in CheckIfCurrentDeckWasChanged to determine whether
; wCurDeckCards was changed from the original
; deck it was based on
wCurDeckCardChanges::
	ds (DECK_SIZE + 1) * 2

ENDU

SECTION "WRAM Text Engine", WRAM0

wc600::
	ds $100

wc700::
	ds $100

wc800::
	ds $100

wc900::
	ds $100

SECTION "WRAM 1", WRAM0

wOAM::
	ds OAM_SIZE

; 16-byte buffer to store text, usually a name or a number
; used by TX_RAM1 but not exclusively
wStringBuffer::
	ds $10

wcab0::
	ds $1

wcab1::
	ds $1

wcab2::
	ds $1

; initial value of the A register. used to tell the console when reset
wInitialA::
	ds $1

; what console we are playing on, either 0 (DMG), 1 (SGB) or 2 (CGB)
; use constants CONSOLE_DMG, CONSOLE_SGB and CONSOLE_CGB for checks
wConsole::
	ds $1

; used to select a sprite or a starting sprite from wOAM
wOAMOffset::
	ds $1

; FillTileMap fills VRAM0 BG Maps with the tile stored here
wTileMapFill::
	ds $1

wIE::
	ds $1

; incremented whenever the vblank handler ends. used to wait for it to end,
; or to delay a specific amount of frames
wVBlankCounter::
	ds $1

	ds $1

; bit0: is in vblank interrupt?
; bit1: is in timer interrupt?
wReentrancyFlag::
	ds $1

wLCDC::
	ds $1

wBGP::
	ds $1

wOBP0::
	ds $1

wOBP1::
	ds $1

; used to request palette(s) to be flushed by FlushPalettes from wBGP, wOBP0, wOBP1,
; wBackgroundPalettesCGB, and/or wBackgroundPalettesCGB to the corresponding hw registers
wFlushPaletteFlags::
	ds $1

; set to non-0 to request OAM copy during vblank
wVBlankOAMCopyToggle::
	ds $1

; used by WriteByteToBGMap0
wTempByte::
	ds $1

; used to increase the play time counter every four timer interrupts (60.24 Hz)
wTimerCounter::
	ds $1

wPlayTimeCounterEnable::
	ds $1

; byte0: 1/60ths of a second
; byte1: seconds
; byte2: minutes
; byte3: hours (lower byte)
; byte4: hours (upper byte)
wPlayTimeCounter::
	ds $5

wRNG1::
	ds $1

wRNG2::
	ds $1

wRNGCounter::
	ds $1

; the LCDC status interrupt is always disabled and this always reads as jp $0000
wLCDCFunctionTrampoline::
	ds $3

; a jp $nnnn instruction called by the vblank handler. calls a single ret by default
wVBlankFunctionTrampoline::
	ds $3

; pointer to a function to be called by DoFrame
wDoFrameFunction::
	ds $2

; if non-zero, the game screen can be paused at any time with the select button
wDebugPauseAllowed::
	ds $1

; pointer to keep track of where
; in the source data we are while
; running the decompression algorithm
wDecompSourcePosPtr::
	ds $2

; number of bits that are still left
; to read from the current command byte
wDecompNumCommandBitsLeft::
	ds $1

; command byte from which to read the bits
; to decompress source data
wDecompCommandByte::
	ds $1

; if bit 7 is changed from off to on, then
; decompression routine will read next two bytes
; for repeating previous sequence (length, offset)
; if it changes from on to off, then the routine
; will only read one byte, and reuse previous length byte
wDecompRepeatModeToggle::
	ds $1

; stores in both nybbles the length of the
; sequences to copy in decompression
; the high nybble is used first, then the low nybble
; for a subsequent sequence repetition
wDecompRepeatLengths::
	ds $1

wDecompNumBytesToRepeat::
	ds $1

wDecompSecondaryBufferPtrHigh::
	ds $1

; offset to repeat byte from decompressed data
wDecompRepeatSeqOffset::
	ds $1

wDecompSecondaryBufferPtrLow::
	ds $1

	ds $f

wDecompSavedDeckCount::
	ds $1

; temporary CGB palette data buffer to eventually save into BGPD registers.
wBackgroundPalettesCGB::
	ds NUM_BACKGROUND_PALETTES palettes

; temporary CGB palette data buffer to eventually save into OBPD registers.
wObjectPalettesCGB::
	ds NUM_OBJECT_PALETTES palettes

; temporarily holds the palettes from
; wBackgroundPalettesCGB
wTempBackgroundPalettesCGB::
	ds NUM_BACKGROUND_PALETTES palettes

; temporarily holds the palettes from
; wObjectPalettesCGB
wTempObjectPalettesCGB::
	ds NUM_OBJECT_PALETTES palettes

; When we're viewing a card's information, the page we are currently at.
; For Pokemon cards, values from $1 to $6 (two pages for attack descriptions)
; For Energy cards, it's always $9
; For Trainer cards, $d or $e (two pages for trainer card descriptions)
; see CARDPAGE_* constants
wCardPageNumber::
	ds $1

; selects a PLAY_AREA_* slot in order to display information related to it. used by functions
; such as PrintPlayAreaCardLocation, PrintPlayAreaCardInformation and PrintPlayAreaCardHeader
wCurPlayAreaSlot::
	ds $1

; CARDPAGETYPE_PLAY_AREA or CARDPAGETYPE_NOT_PLAY_AREA
; some of the elements displayed in a card page change depending on which value
wCardPageType::
	ds $1

; when viewing a card page, which keys (among PAD_B, PAD_UP, and PAD_DOWN) will exit the page,
; either to go back to the previous menu or list, or to load the card page of the card above/below it
wCardPageExitKeys::
	ds $1

; used to print a Pokemon card's length in feet and inches
wPokemonLengthPrintOffset::
	ds $1

; used when opening the card page of an attack when attacking,
; serving as an index for AttackPageDisplayPointerTable.
; see ATTACKPAGE_* constants
wAttackPageNumber::
	ds $1

; stores the player's result in a duel (0: win, 1: loss)
; to be read by the overworld caller
wDuelResult::
	ds $1

; this holds the current opponent's deck ID
wOpponentDeckID::
	ds $1

wOpponentPortrait::
	ds $1

; text id of the opponent's name
wOpponentName::
	ds $2

; an overworld script starting a duel sets this address to the value to be written into wDuelInitialPrizes
wNPCDuelPrizes::
	ds $1

; an overworld script starting a duel sets this address to the value to be written into wOpponentDeckID
wNPCDuelDeck::
	ds $1

; song played during a duel
wDuelTheme::
	ds $1

; Used as temporary storage for a card's data
wLoadedCard1::
	card_data_struct wLoadedCard1
wLoadedCard2::
	card_data_struct wLoadedCard2

; text ID of the name of the deck loaded by CopyDeckData
wDeckName::
	ds $2

; when non-0, allows the player to skip some delays during a duel by pressing B.
; value read from sSkipDelayAllowed. probably only used for debugging.
wSkipDelayAllowed::
	ds $1

SECTION "WRAM 2", WRAM0

; on CGB, attributes of the text box borders. (values 0-7 seem to be used, which only affect palette)
wTextBoxFrameType::
	ds $1

; pixel data of a tile used for text
; either a combination of two half-width characters or a full-width character
wTextTileBuffer::
	ds TILE_SIZE

wcd04::
	ds $1

; used by PlaceNextTextTile
wCurTextTile::
	ds $1

; VRAM tile patterns selector for text tiles
; if wTilePatternSelector == $80 and wTilePatternSelectorCorrection == $00 -> select tiles at $8000-$8FFF
; if wTilePatternSelector == $88 and wTilePatternSelectorCorrection == $80 -> select tiles at $8800-$97FF
wTilePatternSelector::
	ds $1

; complements wTilePatternSelector by correcting the VRAM tile order when $8800-$97FF is selected
; a value of $80 in wTilePatternSelectorCorrection reflects tiles $00-$7f being located after tiles $80-$ff
wTilePatternSelectorCorrection::
	ds $1

; if 0 (DOUBLE_SPACED), text lines are separated by a blank line
; uses constants DOUBLE_SPACED and SINGLE_SPACED
wLineSeparation::
	ds $1

; line number in which text is being printed as an offset to
; the topmost line, including separator lines
wCurTextLine::
	ds $1

; how to process the current text tile
; 0: full-width font | non-0: half-width font
wFontWidth::
	ds $1

; when printing half-width text, this variable alternates between 0 and the value
; of the first character. 0 signals that no text should be printed in the current
; iteration of Func_235e, while non-0 means to print the character pair
; made of [wHalfWidthPrintState] (first char) and register e (second char).
wHalfWidthPrintState::
	ds $1

; used by CopyTextData
wTextMaxLength::
	ds $1

; half-width font letters become uppercase if non-0, lowercase if 0
wUppercaseHalfWidthLetters::
	ds $1

	ds $1

; handles timing of (horizontal or vertical) arrow blinking while waiting for user input.
wCursorBlinkCounter::
	ds $1

wCurMenuItem::
	ds $1

wMenuParams::

wMenuCursorXOffset::
	ds $1

wMenuCursorYOffset::
	ds $1

wMenuYSeparation::
	ds $1

wNumMenuItems::
	ds $1

wMenuVisibleCursorTile::
	ds $1

wMenuInvisibleCursorTile::
	ds $1

; if non-NULL, the function loaded here is called once per frame by HandleMenuInput
wMenuUpdateFunc::
	ds $2

wMenuParamsEnd::

wListScrollOffset::
	ds $1

wListItemXPosition::
	ds $1

wNumListItems::
	ds $1

wListItemNameMaxLength::
	ds $1

; if not NULL, the function loaded here is called once per frame by CardListMenuFunction,
; which is the function loaded to wMenuUpdateFunc for card lists
wListFunctionPointer::
	ds $2

	ds $50

; in a card list, the Y position where the <sel_item>/<num_items> indicator is placed
; if wListIndicatorYPosition == $ff, no indicator is displayed
wListIndicatorYPosition::
	ds $1

; x coord of the leftmost item in a horizontal menu
wLeftmostItemCursorX::
	ds $1

; used in RefreshMenuCursor_CheckPlaySFX to play a sound during any frame when this address is non-0
wRefreshMenuCursorSFX::
	ds $1

; when printing a YES/NO menu, whether the cursor is
; initialized to the YES ($01) or to the NO ($00) item
wDefaultYesOrNo::
	ds $1

; used in _CopyCardNameAndLevel to keep track of the remaining space to copy the text
wCardNameLength::
	ds $1

; stores the total number of coins to flip
wCoinTossTotalNum::
	ds $1

; this stores the result from a coin toss (number of heads)
wCoinTossNumHeads::
	ds $1

; stores type of the duelist that is tossing coins
wCoinTossDuelistType::
	ds $1

; holds the number of coins that have already been tossed
wCoinTossNumTossed::
	ds $1

; LoadLoaded1CardGfx loads the card's palette here
wCardPalette::
	ds 3 palettes
wCardAttrMap::
	ds $30

; information about the text being currently processed, including font width,
; the rom bank, and the memory address of the next character to be printed.
; supports up to four nested texts (used with TX_RAM).
wTextHeader1::
	text_header wTextHeader1
wTextHeader2::
	text_header wTextHeader2
wTextHeader3::
	text_header wTextHeader3
wTextHeader4::
	text_header wTextHeader4

; text id for the first TX_RAM2 of a text
; prints from wDefaultText if $0000
wTxRam2::
	ds $2

; text id for the second TX_RAM2 of a text
wTxRam2_b::
	ds $2

; text id for the first TX_RAM3 of a text
; a number between 0 and 65535
wTxRam3::
	ds $2

; text id for the second TX_RAM3 of a text
; a number between 0 and 65535
wTxRam3_b::
	ds $2

; when printing text, number of frames to wait between each text tile
wTextSpeed::
	ds $1

; a number between 0 and 3 to select a wTextHeader to use for the current text
wWhichTextHeader::
	ds $1

; selects wTxRam2 or wTxRam2_b
wWhichTxRam2::
	ds $1

; selects wTxRam3 or wTxRam3_b
wWhichTxRam3::
	ds $1

wIsTextBoxLabeled::
	ds $1

; text id of a text box's label
wTextBoxLabel::
	ds $2

wCoinTossScreenTextID::
	ds $2

; set to PLAYER_TURN in the "Your Play Area" screen
; set to OPPONENT_TURN in the "Opp Play Area" screen
; alternates when drawing the "In Play Area" screen
wCheckMenuPlayAreaWhichDuelist::
	ds $1

; apparently complements wCheckMenuPlayAreaWhichDuelist to be able to combine
; the usual player or opponent layout with the opposite duelist information
; appears not to be relevant in the "In Play Area" screen
wCheckMenuPlayAreaWhichLayout::
	ds $1

; holds the position of the cursor when selecting
; in the "Your Play Area" or "Opp Play Area" screens
wYourOrOppPlayAreaCurPosition::
	ds $1

; pointer to the table which contains information for each key-press.
wMenuInputTablePointer::

; pointer to transition table data
wTransitionTablePtr::
	ds $2

; same as wDuelInitialPrizes but with upper 2 bits set
wDuelInitialPrizesUpperBitsSet::
	ds $1

; it's used for restore the position of cursor
; when going into another view, and returning to
; the previous view.
wInPlayAreaPreservedPosition::
	ds $1

; it's used for checking if the player changed
; the cursor in the play area view.
wInPlayAreaTemporaryPosition::
	ds $1

; number of prize cards still to be
; picked by the player
wNumberOfPrizeCardsToSelect::
	ds $1

; pointer to a $ff-terminated list
; of the prize cards selected by the player
wSelectedPrizeCardListPtr::
	ds $2

wce5c::
	ds $1

; stores whether there are Pokemon in play area
; player active Pokemon sets bit 0
; opponent active Pokemon sets bit 1
wActiveCardsInPlayArea::
	ds $1

wce5e::
	ds $1

; this is used to store last cursor position
; in the "Your Play Area" and the "Opp. Play Area" screens
wYourOrOppPlayAreaLastCursorPosition::
	ds $1

; $00 when the "In Play Area" screen has been opened from the Check menu
; $01 when the "In Play Area" screen has been opened by pressing the select button
wInPlayAreaFromSelectButton::
	ds $1

; it's used only in one function,
; which means that it's a kind of local variable, but defined in wram.
wPrizeCardCursorTemporaryPosition::
	ds $1

wGlossaryPageNo::
	ds $1

; these next 3 seem to be an address (bank @ end) for copying bg data
wTempPointer::
	ds $2

wTempPointerBank::
	ds $1

wDamageAnimAmount::
	ds $2

wDamageAnimEffectiveness::
	ds $1

wDamageAnimPlayAreaLocation::
	ds $1

; this value is never read
wDamageAnimPlayAreaSide::
	ds $1

wDamageAnimCardID::
	ds $1

	ds $d

; first index in the current card list that is visible
; used to calculate which element to get based
; on the cursor position
wListVisibleOffset::
	ds $1

; it's used when the player enters check menu, and its sub-menus.
; increases from 0x00 to 0xff. the game makes its blinking cursor by this.
; note that the check menu also contains the pokemon glossary.
wCheckMenuCursorBlinkCounter::
	ds $1

; used to temporarily store wCurCardTypeFilter
; to check whether a new filter is to be applied
wTempCardTypeFilter::

wListCursorPos::

wNamingScreenCursorY::
	ds $1

wListCursorXPos::
	ds $1

wListCursorYPos::
	ds $1

wListYSpacing::
	ds $1

wListXSpacing::
	ds $1

wListNumCursorPositions::

wNamingScreenKeyboardHeight::
	ds $1

; tile to draw when cursor is blinking
wVisibleCursorTile::
	ds $1

; tile to draw when cursor is visible
wInvisibleCursorTile::
	ds $1

; unknown handler function run in HandleDeckCardSelectionList
; is always NULL
wListHandlerFunction::
	ds $2

; number of cards that are listed
; in the current filtered list
wNumEntriesInCurFilter::
	ds $1

wCheckMenuCursorXPosition::
	ds $1

wCheckMenuCursorYPosition::
	ds $1

; deck selected by the player in the Decks screen
wCurDeck::
	ds $1

; each of these are a boolean to
; represent whether a given deck
; that the player has is a valid deck
wDecksValid::
wDeck1Valid:: ds $1 ; ceb2
wDeck2Valid:: ds $1 ; ceb3
wDeck3Valid:: ds $1 ; ceb4
wDeck4Valid:: ds $1 ; ceb5

; holds symbols for representing a number in decimal
; goes up in magnitude (first byte is ones place,
; second byte is tens place, etc) up to 5 digits
wDecimalDigitsSymbols::
	ds $5

; each of these stores the card count
; of each filter in the deck building screen
; the order follows CardTypeFilters
wCardFilterCounts::
	ds NUM_FILTERS

UNION

; buffer used to show which card IDs
; are visible in a given list
wVisibleListCardIDs::
	ds NUM_DECK_CONFIRMATION_VISIBLE_CARDS * 2

NEXTU

; whether a given Card Set is unavailable in the Card Album screen
; used only for CARD_SET_PROMOTIONAL, in which case
; if it's unavailable, will print "----------" as the Card Set name
wUnavailableAlbumCardSets::
	ds NUM_CARD_SETS

ENDU

; number of visible entries
; when showing a list of cards
wNumVisibleCardListEntries::
	ds $1

wTotalCardCount::
	ds $1

; is TRUE if list cannot be scrolled down
; past the last visible entry
wUnableToScrollDown::
	ds $1

; pointer to a function that should be called
; to update the card list being shown
wListUpdateFunction::
	ds $2

; holds y and x coordinates (in that order)
; of start of card list (top-left corner)
wListCoords::
	ds $2

wced2::
	ds $1

; the current filter being used
; from the CardTypeFilters list
wCurCardTypeFilter::
	ds $1

; temporarily stores wListNumCursorPositions value
wTempCardListCursorPos::
	ds $1

wTempFilteredCardListNumCursorPositions::
	ds $1

wced6::
	ds $1

wListVisibleOffsetBackup::
	ds $1

; stores how many different cards there are in a deck
wNumUniqueCards::
	ds $1

; stores AI temporary hand card list
wHandTempList::
	ds DECK_SIZE + 1

; holds cards for the current deck
wCurDeckCards::
	ds (DECK_CONFIG_BUFFER_SIZE + 1) * 2

wCurDeckCardsEnd::

SECTION "Stack", WRAM0

	ds $100
wStack::

SECTION "WRAM1", WRAMX

; stores the count number of cards owned
; can be 0 in the case that a card is not available
; i.e. already inside a built deck
wOwnedCardsCountList::
	ds DECK_SIZE

	ds $15

; name of the selected deck
wCurDeckName::
	ds DECK_NAME_SIZE

; max number of cards that are allowed
; to include when building a deck configuration
wMaxNumCardsAllowed::
	ds $1

; max number of cards with same name that are allowed
; to be included when building a deck configuration
wSameNameCardsLimit::
	ds $1

; whether to include the cards in the selected deck
; to appear in the filtered lists
; is TRUE when building a deck (since the cards should be shown for removal)
; is FALSE when choosing a deck configuration to send through Gift Center
; (can't select cards that are included in already built decks)
wIncludeCardsInDeck::
	ds $1

; pointer to a function that handles the menu
; when building a deck configuration
wDeckConfigurationMenuHandlerFunction::
	ds $2

; pointer to a transition table for the
; function in wDeckConfigurationMenuHandlerFunction
wDeckConfigurationMenuTransitionTable::
	ds $2

; pointer to a list of cards that
; is currently being shown/manipulated
wCurCardListPtr::
	ds $2

; text ID to print in the card confirmation screen text box
wCardConfirmationText::
	ds $2

wDeckCompressionCmdByte::
	ds $1

; the tile to draw in place of the cursor, in case
; the cursor is not to be drawn
wCursorAlternateTile::
	ds $1

; temporarily stores value of wListNumCursorPositions
wTempCardListNumCursorPositions::
	ds $1

; which Card Set selected by the player to view
wSelectedCardSet::
	ds $1

; number of cards the player owns from the given Card Set
wNumOwnedCardsInSet::
	ds $1

; flags that corresponds to each Phantom Card owned by the player
; see src/constants/menu_constants.asm
wOwnedPhantomCardFlags::
	ds $1

; value containing a SFX to play
; due to a menu input
wMenuInputSFX::
	ds $1

; collection index of the first owned card
wFirstOwnedCardIndex::
	ds $1

wNumCardListEntries::
	ds $1

; a name buffer in the naming screen.
wNamingScreenBuffer::
	ds NAMING_SCREEN_BUFFER_LENGTH

; current name length in the naming screen.
wNamingScreenBufferLength::
	ds $1

wNamingScreenDestPointer::
	ds $2

wNamingScreenQuestionPointer::
	ds $2

; max length of name buffer.
; it's given for limiting the player's input.
wNamingScreenBufferMaxLength::
	ds $1

wNamingScreenNumColumns::
	ds $1

wNamingScreenCursorX::
	ds $1

; the position to display the input on.
wNamingScreenNamePosition::
	ds $2

wd009::
	ds $4

; pointers to all decks of current deck machine
wMachineDeckPtrs::
	ds 2 * NUM_DECK_SAVE_MACHINE_SLOTS

wNumSavedDecks::
	ds $1

; temporarily holds value of wListCursorPos
wTempDeckMachineCursorPos::
	ds $1

; temporarily holds value of wListVisibleOffset
wTempCardListVisibleOffset::
	ds $1

; which list entry was selected in the Deck Machine screen
wSelectedDeckMachineEntry::
	ds $1

wDismantledDeckName::
	ds DECK_NAME_SIZE

; which deck slot to be used to
; build a new deck
wDeckSlotForNewDeck::
	ds $1

wDeckMachineTitleText::
	ds $2

wTempBankSRAM::
	ds $1

wNumDeckMachineEntries::
	ds $1

; DECK_* flags to be dismantled to build a given deck
wDecksToBeDismantled::
	ds $1

; text ID to print in the text box when
; inside the Deck Machine menu
wDeckMachineText::
	ds $2

; which deck machine is being used
wCurAutoDeckMachine::
	ds $1

; text IDs for each deck descriptions of the
; Auto Deck Machine currently being shown
wAutoDeckMachineTextDescriptions::
	ds 2 * NUM_DECK_MACHINE_SLOTS

; if bit 4 is set, transition to another map via a warp
; if bit 6 is set, transition to a special screen
;   (duel, challenge machine, battle center, gift center, credits)
; bit 7 may also be used for some unknown purpose
wOverworldTransition::
	ds $1

; a GAME_EVENT_* constant corresponding to an entry in GameEventPointerTable
; overworld, duel, credits...
wGameEvent::
	ds $1

wSCX::
	ds $1

wSCY::
	ds $1

wSelectedPauseMenuItem::
	ds $1

wSelectedPCMenuItem::
	ds $1

	ds $1

wTempMap::
	ds $1

wTempPlayerXCoord::
	ds $1

wTempPlayerYCoord::
	ds $1

wTempPlayerDirection::
	ds $1

; See constants/misc_constants.asm for OWMODE's
wOverworldMode::
	ds $1

wOverworldModeBackup::
	ds $1

; overworld npc flag options
; bit 0; auto-close textbox when finished talking to npc
; bit 1; restore npc facing direction when finished talking to npc
; bit 7; hide all npc sprites (for screens like pause menu, opening boosters, entering deck machine, etc.)
wOverworldNPCFlags::
	ds $1

; only used with GAME_EVENT_DUEL
wActiveGameEvent::
	ds $1

wNPCDuelist::
	ds $1

wNPCDuelistDirection::
	ds $1

; used to store the location of an overworld script, which is jumped to later
wNextScript::
	ds $2

wCurrentNPCNameTx::
	ds $2

wDefaultObjectText::
	ds $2

wObjectPalettesCGBBackup::
	ds 8 palettes

wOBP0Backup::
	ds $1

wOBP1Backup::
	ds $1

	ds $1

wReloadOverworldCallbackPtr::
	ds $2

wDefaultSong::
	ds $1

wSongOverride::
	ds $1

wMatchStartTheme::
	ds $1

wMedalScreenYOffset::
	ds $1

wWhichMedal::
	ds $1

wMedalDisplayTimer::
	ds $1

; if FALSE, first booster being given
; if TRUE, additional booster being given
; used to control the text that is displayed when booster is opened
wAnotherBoosterPack::
	ds $1

wConfigMessageSpeedCursorPos::
	ds $1

wConfigDuelAnimationCursorPos::
	ds $1

wConfigExitSettingsCursorPos::
	ds $1

wConfigCursorYPos::
	ds $1

; cursor is invisible if bit 4 is set (every $10 ticks)
wCursorBlinkTimer::
	ds $1

wPCPackSelection::
	ds $1

; 7th bit of each pack corresponds to whether or not it's been read
wPCPacks::
	ds NUM_PC_PACKS

wPCLastDirectionPressed::
	ds $1

wSelectedPCPack::
	ds $1

wBGMapWidth::
	ds $1

wBGMapHeight::
	ds $1

; current tilemap to load
; TILEMAP_* constant
wCurTilemap::
	ds $1

UNION

; when opening a booster pack, list of cards available in the booster pack of a specific rarity
wBoosterViableCardList::
	ds $100

NEXTU

; permission map of the current room with impassable objects (walls, NPCs, etc).
; $00: passable (floor)
; $10: text/menu box tile
; $40: impassable and talkable (NPC or talkable wall)
; $80: impassable and untalkable (wall)
wPermissionMap::
	ds $100

ENDU

wd233::
	ds $1

wd234::
	ds $1

wSCXBuffer::
	ds $1

wSCYBuffer::
	ds $1

wd237::
	ds $1

wd238::
	ds $1

; current tileset to load to VRAM
; TILESET_* constant
wCurTileset::
	ds $1

; pointer to compressed data
; of the current map's permission map
wBGMapPermissionDataPtr::
	ds $2

; whether the  BG Map is in CGB mode
; this means half of the width is for
; VRAM0 and the other half is for VRAM1
wBGMapCGBMode::
	ds $1

wBGMapBank::
	ds $1

; palette loaded from Palette* data
wLoadedPalData::

; temporary frame data loaded in HandleAnimationFrame
wLoadedFrameData::

; where BG map data or other compressed data is decompressed
wDecompressionBuffer::
	ds $50

wDecompressionRowWidth::
	ds $1

wCurMapInitialPalette::
	ds $1

wCurMapPalette::
	ds $1

wd291::
	ds $1

; determines where to copy BG Map data
; $0 = copies to VRAM
; $1 = copies to SRAM
wWriteBGMapToSRAM::
	ds $1

	ds $1

wd317::
	ds $1

; pointer to the data of current map OW frameset
wCurMapOWFrameset::
	ds $2

; stored data for each OW frameset subgroup
; has frame data offset and duration
wOWFramesetSubgroups::
	ds NUM_OW_FRAMESET_SUBGROUPS * $2

; address offset of current OW frame
; relative to wCurMapOWFrameset
wCurOWFrameDataOffset::
	ds $1

; duration of the current map OW frame
wCurOWFrameDuration::
	ds $1

; number of valid subgroups
; that are currently loaded in wOWFramesetSubgroups
wNumLoadedFramesetSubgroups::
	ds $1

; holds the current state of each event
; each corresponding to a MAP_EVENT_* constant
; if FALSE, doors are closed / deck machines are deactivated
; if TRUE, doors are open / deck machines are activated
wOWMapEvents::
	ds NUM_MAP_EVENTS

; the OWMAP_* value for the current overworld map selection
wOverworldMapSelection::
	ds $1

wCurMap::
	ds $1

wPlayerXCoord::
	ds $1

wPlayerYCoord::
	ds $1

wPlayerXCoordPixels::
	ds $1

wPlayerYCoordPixels::
	ds $1

wPlayerDirection::
	ds $1

; seems to be 1 if moving 0 otherwise
wPlayerCurrentlyMoving::
	ds $1

wPlayerSpriteIndex::
	ds $1

wPlayerSpriteBaseAnimation::
	ds $1

wd338::
	ds $1

wd339::
	ds $1

wd33a::
	ds $1

wOverworldMapCursorSprite::
	ds $1

wOverworldMapCursorAnimation::
	ds $1

wOverworldMapStartingPosition::
	ds $1

; 0: selection not made, controlling cursor
; 1: selection made, animating player across map
; 2: player arrived at new map
wOverworldMapPlayerAnimationState::
	ds $1

wOverworldMapPlayerMovementPtr::
	ds $2

wOverworldMapPlayerMovementCounter::
	ds $1

	ds $1

; during setup, this holds a signed 16-bit integer
; representing the total horizontal distance between
; the current point and the next point
; afterward, this holds a signed fixed-point fractional number
; where the high byte represents the number of pixels
; to travel per frame and the low byte represents the
; fraction of a pixel to travel per frame
wOverworldMapPlayerPathHorizontalMovement::
	ds $2

; works the same as above, but for vertical distance
wOverworldMapPlayerPathVerticalMovement::
	ds $2

wOverworldMapPlayerHorizontalSubPixelPosition::
	ds $1

wOverworldMapPlayerVerticalSubPixelPosition::
	ds $1

; total number of NPCs that are currently loaded
wNumLoadedNPCs::
	ds $1

wLoadedNPCs::
	loaded_npc_struct wLoadedNPC1
	loaded_npc_struct wLoadedNPC2
	loaded_npc_struct wLoadedNPC3
	loaded_npc_struct wLoadedNPC4
	loaded_npc_struct wLoadedNPC5
	loaded_npc_struct wLoadedNPC6
	loaded_npc_struct wLoadedNPC7
	loaded_npc_struct wLoadedNPC8

wLoadedNPCTempIndex::
	ds $1

wTempNPC::
	ds $1

wLoadNPCXPos::
	ds $1

wLoadNPCYPos::
	ds $1

wLoadNPCDirection::
	ds $1

wLoadNPCFunction::
	ds $2

wNPCAnim::
	ds $1

wNPCAnimFlags::
	ds $1

; sprite ID of the NPC to load
wNPCSpriteID::
	ds $1

	ds $2

; ID of the NPC being interacted with in Script
wScriptNPC::
	ds $1

; bit 6 will be set if an NPC is currently moving
wIsAnNPCMoving::
	ds $1

; whether Ronald is in the current map
; is used to load his theme whenever he is present
wRonaldIsInMap::
	ds $1

wd3b9::
	ds $2

wMastersBeatenList::
	ds $a

wGeneralSaveDataCheckSum::
	ds $2

wNumSRAMValidationErrors::
	ds $1

; play time hours and minutes
; byte 0: minutes
; byte 1: hours (lower byte)
; byte 2: hours (higher byte)
wPlayTimeHourMinutes::
	ds $3

wCurOverworldMap::
	ds $1

wMedalCount::
	ds $1

; total number of cards the player has collected
wTotalNumCardsCollected::
	ds $2

; total number of cards to be collected
; doesn't count the Phantom cards (VenusaurLv64 and MewLv15)
; unless they have already been collected
wTotalNumCardsToCollect::
	ds $2

	ds $1

wd3d0::
	ds $1

; the bits relevant to the currently worked on event, obtained from EventVarMasks
wLoadedEventBits::
	ds $1

wEventVars::
	ds $40

; 0 keeps looping, other values break the loop in RST20
wBreakScriptLoop::
	ds $1

wScriptPointer::
	ds $2

; generally set to ff when an event check passes, 0 otherwise
wScriptControlByte::
	ds $1

wd416::
	ds $1

wd417::
	ds $1

	ds $7

; store settings for animation enabled/disabled
; FALSE means enabled, TRUE means disabled
wAnimationsDisabled::
	ds $1

; stores the character symbols of some
; value that was converted to decimal
; through ConvertWordToNumericalDigits
wDecimalChars::
	ds $3

	ds $1

; pointer to address in VRAM
wVRAMPointer::
	ds $2

; stores number of bytes per tile for current sprite
wCurSpriteTileSize::
	ds $1

; stores number of tiles that current sprite/tileset has
wTotalNumTiles::

; checksum?
wGeneralSaveDataByteCount::
	ds $2

; stores tile offset in VRAM
wVRAMTileOffset::

; for LoadOBPalette
; which object palette to load to (DMG)
wWhichOBP::

; temporary storage of variables when
; calculating booster chances of cards
wTempBoosterChances::

; current frame to load when processing an animation
wWhichAnimationFrame::
	ds $1

; for LoadOBPalette
; which object palette index to load to (CGB)
wWhichOBPalIndex::

; for LoadBGPalette
; which background palette index to load to (CGB)
wWhichBGPalIndex::

; stores which VRAM bank to draw certain gfx
; $0 = VRAM0, $1 = VRAM1
wWhichVRAMBank::
	ds $1

	ds $3

; used as an index to manipulate a sprite from wSpriteAnimBuffer
wWhichSprite::
	ds $1

; 16-byte data for up to 16 sprites
wSpriteAnimBuffer::
	sprite_anim_struct wSprite1
	sprite_anim_struct wSprite2
	sprite_anim_struct wSprite3
	sprite_anim_struct wSprite4
	sprite_anim_struct wSprite5
	sprite_anim_struct wSprite6
	sprite_anim_struct wSprite7
	sprite_anim_struct wSprite8
	sprite_anim_struct wSprite9
	sprite_anim_struct wSprite10
	sprite_anim_struct wSprite11
	sprite_anim_struct wSprite12
	sprite_anim_struct wSprite13
	sprite_anim_struct wSprite14
	sprite_anim_struct wSprite15
	sprite_anim_struct wSprite16

wCurrSpriteAttributes::
	ds $1

wCurrSpriteXPos::
	ds $1

wCurrSpriteYPos::
	ds $1

wCurrSpriteTileID::
	ds $1

wCurrSpriteRightEdgeCheck::
	ds $1

wCurrSpriteBottomEdgeCheck::
	ds $1

wCurrSpriteFrameBank::
	ds $1

; when non-0, skips all routines
; related to animating sprites
; (perhaps used during testing)
; it is always set to 0
wAllSpriteAnimationsDisabled::
	ds $1

wSpriteVRAMBuffer::
	sprite_vram_struct wSpriteVRAM1
	sprite_vram_struct wSpriteVRAM2
	sprite_vram_struct wSpriteVRAM3
	sprite_vram_struct wSpriteVRAM4
	sprite_vram_struct wSpriteVRAM5
	sprite_vram_struct wSpriteVRAM6
	sprite_vram_struct wSpriteVRAM7
	sprite_vram_struct wSpriteVRAM8
	sprite_vram_struct wSpriteVRAM9
	sprite_vram_struct wSpriteVRAM10
	sprite_vram_struct wSpriteVRAM11
	sprite_vram_struct wSpriteVRAM12
	sprite_vram_struct wSpriteVRAM13
	sprite_vram_struct wSpriteVRAM14
	sprite_vram_struct wSpriteVRAM15
	sprite_vram_struct wSpriteVRAM16

; seems to be the amount of entries in wSpriteVRAMBuffer
wSpriteVRAMBufferSize::
	ds $1

wSceneSprite::
	ds $1

wSceneSpriteAnimation::
	ds $1

wSceneSpriteIndex::
	ds $1

; base X position in pixels of loaded scene
wSceneBaseX::
	ds $1

; base Y position in pixels of loaded scene
wSceneBaseY::
	ds $1

wCurPortrait::
	ds $1
wPortraitSlot::
	ds $1
wPortraitEmotion::
	ds $1

wd61f::
	ds $1

	ds $2

; whether there exists valid save data
wHasSaveData::
	ds $1

; whether has valid duel save data
wHasDuelSaveData::
	ds $1

; keep track of which Start Menu item
; is currently highlighted
wCurHighlightedStartMenuItem::

; used to keep track of the time
; in which the Title Screen ignores
; the player's input
wTitleScreenIgnoreInputCounter::
	ds $1

wLastSelectedStartMenuItem::
	ds $1

; START_MENU_* constant chosen
; by the player in the Start Menu
wStartMenuChoice::
	ds $1

; list of sprites used in the Title Screen
wTitleScreenSprites::
	ds $7

	ds $1

; pointer to commands used by opening and credits sequence
; (see IntroSequence and CreditsSequence)
wSequenceCmdPtr::
	ds $2

; when non-zero, is decremented and only
; executes the next sequence command when it's 0
; when it's $ff, it is interpreted as end of sequence
wSequenceDelay::
	ds $1

wIntroSequencePalsNeedUpdate::
	ds $1

; counter that increments each frame in the Title screen
; if bottom 6 bits are 0, then spawn a new orb
wTitleScreenOrbCounter::
	ds $1

; has parameters used for the Start Menu
; check SetStartMenuParams for what parameters are set
wStartMenuParams::
	ds $11

wd647::
	ds $1

wd648::
	ds $1

wd649::
	ds $1

wd64a::
	ds $1

; wd64b to wd665 used by Func_3e44
wd64b::
	ds $6

wd651::
	ds $6

wd657::
	ds $1

wd658::
	ds $1

wd659::
	ds $6

wd65f::
	ds $6

wd665::
	ds $1

; used by GetNextBackgroundScroll
wBGScrollMod::
	ds $1

; used by ApplyBackgroundScroll
wApplyBGScroll::
	ds $1

; used by ApplyBackgroundScroll
wNextScrollLY::
	ds $1

; which BoosterPack_* corresponds to the booster pack that the player is opening
wBoosterPackID::
	ds $1

; card being currently processed by the booster pack engine functions
wBoosterCurrentCard::
	ds $2

; BOOSTER_CARD_TYPE_* of the card that has just been drawn from the pack
wBoosterJustDrawnCardType::
	ds $1

; rarity of the cards being currently generated (non-energy cards are generated ordered by rarity)
wBoosterCurrentRarity::
	ds $1

; the averaged value of all values in wBoosterData_TypeChances
; used to recalculate the chances of a booster card type when a card of said type is drawn from the pack
wBoosterAveragedTypeChances::
	ds $1

; data of the booster pack copied from the corresponding BoosterSetRarityAmountsTable entry
wBoosterData_CommonAmount::
	ds $1
wBoosterData_UncommonAmount::
	ds $1
wBoosterData_RareAmount::
	ds $1

; how many cards of each type are available of a certain rarity in the booster pack's set
wBoosterAmountOfCardTypeTable::
	ds NUM_BOOSTER_CARD_TYPES

; holds information similar to wBoosterData_TypeChances, except that it contains 00 on any type
; of which there are no cards remaining in the set for the current rarity
wBoosterTempTypeChancesTable::
	ds NUM_BOOSTER_CARD_TYPES

; properties of the card being currently processed by the booster pack engine functions
wBoosterCurrentCardType::
	ds $1
wBoosterCurrentCardRarity::
	ds $1
wBoosterCurrentCardSet::
	ds $1

; data of the booster pack copied from the corresponding BoosterPack_* structure.
; wBoosterData_TypeChances is updated after each card is drawn, to re-balance the type chances.
wBoosterData_Set::
	ds $1
wBoosterData_EnergyFunctionPointer::
	ds $2
wBoosterData_TypeChances::
	ds NUM_BOOSTER_CARD_TYPES

; index into ChallengeMachine_OpponentDecks
; not the typical NPC duelist ID
wChallengeMachineOpponent::
	ds $1

wStarterDeckChoice::
	ds $1

wMultichoiceTextboxResult_Sam::
	ds $1

wMultichoiceTextboxResult_ChooseDeckToDuelAgainst::
	ds $1

wChallengeHallNPC::
	ds $1

wCardReceived::
	ds $1

wd698::
	ds $4

; stores the list of all card IDs that filtered by its card type
; (Fire, Water, ..., Energy card, Trainer card)
wFilteredCardList::
	ds (MAX_NUM_CARDS_PER_TYPE + 1) * 2

; list of all the different cards in a deck configuration
wUniqueDeckCardList::
	ds DECK_SIZE * 2

SECTION "WRAM Duel", WRAMX

; saved at start of DuelLoop
; sp will return here once duel is over
wDuelLoopSP:: dw

; the value of hWhoseTurn gets loaded here at the beginning of each duelist's turn.
; more reliable than hWhoseTurn, as hWhoseTurn may change temporarily in order to handle status
; conditions or other events of the non-turn duelist. used mostly between turns (to check which
; duelist's turn just finished), or to restore the value of hWhoseTurn at some point.
wWhoseTurn:: db

; current duel is a [wDuelInitialPrizes]-prize match
wDuelInitialPrizes:: db

; number of mulligans each player takes at the beginning of the duel
wMulligans::
wPlayerMulligans::   db
wOpponentMulligans:: db

; y scroll, in q8 precision
wDuelSceneSCY:: dw
wTargetDuelSceneSCY:: db

wDuelCursorX:: db
wDuelCursorY:: db

; duel scene is 20x32 tiles in dimension
wDuelSceneTilemap::
	ds SCREEN_WIDTH * TILEMAP_HEIGHT

wVDMAPending::    db ; if true, trigger VDMA during V-Blank
wVDMASourceBank:: db
wVDMASource::     dw ; big endian
wVDMADestBank::   db ; VRAM bank
wVDMADest::       dw ; big endian
wVDMALen::        db

wDuelAnimationQueueSize:: db ; in num of entries
wDuelAnimationQueue::
	ds DUEL_ANIMS_QUEUE_CAPACITY * DUELANIMENTRY_STRUCT_SIZE
wDuelAnimations:: ; concurrent animations
	ds NUM_DUEL_ANIMS * DUELANIM_STRUCT_SIZE

wChangeAnimFrame:: db ; if TRUE, then move to next frame
wAnimFinished::    db ; if TRUE, animation reached ending frame
wCurAnimFrame::    db
wCurAnimDuration:: db
wCurAnimX::        db
wCurAnimY::        db
wCurOAMCount::     db

SECTION "WRAM AI", WRAMX

; just so ClearAIWRAM doesn't do an "infinite" loop
wDummy::
	ds $1


SECTION "WRAM Audio", WRAMX

; bit 7 is set once the song has been started
wCurSongID::
	ds $1

wCurSongBank::
	ds $1

; bit 7 is set once the sfx has been started
wCurSfxID::
	ds $1

; 8-bit output enable mask for left/right output for each channel
wMusicStereoPanning::
	ds $1

wdd85::
	ds $1

wMusicDuty1::
	ds $1

wMusicDuty2::
	ds $1

	ds $2

wMusicWave::
	ds $1

wMusicWaveChange::
	ds $1

wdd8c::
	ds $1

wMusicIsPlaying::
	ds $4

wMusicTie::
	ds $4

; 4 pointers to the current music commands being executed
wMusicChannelPointers::
	ds $8

; 4 pointers to the addresses of the beginning of the main loop for each channel
wMusicMainLoopStart::
	ds $8

wMusicCh1CurPitch::
	ds $1

wMusicCh1CurOctave::
	ds $1

wMusicCh2CurPitch::
	ds $1

wMusicCh2CurOctave::
	ds $1

wMusicCh3CurPitch::
	ds $1

wMusicCh3CurOctave::
	ds $1

wddab::
	ds $1

wddac::
	ds $1

	ds $2

wMusicOctave::
	ds $4

wddb3::
	ds $4

wddb7::
	ds $1

wddb8::
	ds $1

wddb9::
	ds $1

wddba::
	ds $1

wddbb::
	ds $4

; the delay (1-8) before a note is cut off early (0 is disabled)
wMusicCutoff::
	ds $4

wddc3::
	ds $4

; the volume to apply after a cutoff
wMusicEcho::
	ds $4

; the pitch offset to apply to each note (see Pitches)
wMusicPitchOffset::
	ds $4

wMusicSpeed::
	ds $4

wMusicVibratoType::
	ds $4

wMusicVibratoType2::
	ds $4

wdddb::
	ds $4

wMusicVibratoDelay::
	ds $4

wdde3::
	ds $4

wMusicVolume::
	ds $3

; the frequency offset to apply to each note
wMusicFrequencyOffset::
	ds $3

wdded::
	ds $2

wddef::
	ds $1

wddf0::
	ds $1

wMusicPanning::
	ds $1

wddf2::
	ds $1

; 4 pointers to the positions on the stack for each channel
wMusicChannelStackPointers::
	ds $8

; these stacks contain the address of the command to return to at the end of a sub branch (2 bytes)
; and also contain the address of the command to return to at the end of a loop (2 bytes for address and
; 1 byte for loop count)
wMusicCh1Stack::
	ds $c

wMusicCh2Stack::
	ds $c

wMusicCh3Stack::
	ds $c

wMusicCh4Stack::
	ds $c

wde2b::
	ds $3

wde2e::
	ds $1

wSFXPitchOffsets::
	ds $3

wde32::
	ds $1

wde33::
	ds $4

wde37::
	ds $6

wde3d::
	ds $2

wde3f::
	ds $4

wde43::
	ds $8

wSFXCommandPointers::
	ds $8

wSFXBank::
	ds $1

wSFXIsPlaying::
	ds $1

wde54::
	ds $1

wCurSongIDBackup::
	ds $1

wCurSongBankBackup::
	ds $1

wMusicStereoPanningBackup::
	ds $1

wMusicDuty1Backup::
	ds $4

wMusicWaveBackup::
	ds $1

wMusicWaveChangeBackup::
	ds $1

wMusicIsPlayingBackup::
	ds $4

wMusicTieBackup::
	ds $4

wMusicChannelPointersBackup::
	ds $8

wMusicMainLoopStartBackup::
	ds $8

wde76::
	ds $1

wde77::
	ds $1

wMusicOctaveBackup::
	ds $4

wde7c::
	ds $4

wde80::
	ds $4

wde84::
	ds $4

wMusicCutoffBackup::
	ds $4

wde8c::
	ds $4

wMusicEchoBackup::
	ds $4

wMusicPitchOffsetBackup::
	ds $4

wMusicSpeedBackup::
	ds $4

wMusicVibratoType2Backup::
	ds $4

wMusicVibratoDelayBackup::
	ds $4

wMusicVolumeBackup::
	ds $3

wMusicFrequencyOffsetBackup::
	ds $3

wdeaa::
	ds $2

wdeac::
	ds $1

wMusicChannelStackPointersBackup::
	ds $8

wMusicCh1StackBackup::
	ds $c * 4

wAudioCmd::
	ds $1

wAudioArg::
	ds $2

INCLUDE "sram.asm"
