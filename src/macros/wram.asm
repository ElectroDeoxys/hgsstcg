MACRO card_data_struct
\1Type::          ds 1
\1Gfx::           ds 2
\1Name::          ds 2
\1Rarity::        ds 1
\1Set::           ds 1
\1ID::            ds 2
\1EffectCommands:: ; ds 2
\1HP::            ds 1
\1Stage::         ds 1
\1NonPokemonDescription:: ; ds 2
\1PreEvoName::    ds 2
\1Atk1::         atk_data_struct \1Atk1
\1Atk2::         atk_data_struct \1Atk2
\1RetreatCost::   ds 1
\1Weakness::      ds 1
\1Resistance::    ds 1
\1Category::      ds 2
\1PokedexNumber:: ds 1
\1Length::        ds 2
\1Weight::        ds 2
\1Description::   ds 2
\1AIInfo::        ds 1
ENDM

MACRO atk_data_struct
\1EnergyCost::     ds NUM_TYPES / 2
\1Name::           ds 2
\1Description::    ds 4
\1Damage::         ds 1
\1Category::       ds 1
\1EffectCommands:: ds 2
\1Flag1::          ds 1
\1Flag2::          ds 1
\1Flag3::          ds 1
\1EffectParam::    ds 1
\1Animation::      ds 1
ENDM

MACRO text_header
\1DefaultFont:: ds 1
\1FontWidth::   ds 1
\1Address::     ds 2
\1RomBank::     ds 1
ENDM

MACRO sprite_anim_struct
\1Enabled::             ds 1
\1Attributes::          ds 1
\1CoordX::              ds 1
\1CoordY::              ds 1
\1TileID::              ds 1
\1ID::                  ds 1
\1Bank::                ds 1
\1Pointer::             ds 2
\1FrameOffsetPointer::  ds 2
\1FrameBank::           ds 1
\1FrameDataPointer::    ds 2
\1Counter::             ds 1
\1Flags::               ds 1
ENDM

MACRO loaded_npc_struct
\1ID::         ds 1
\1Sprite::     ds 1
\1CoordX::     ds 1
\1CoordY::     ds 1
\1Direction::  ds 1
\1Field0x05::  ds 1
\1Field0x06::  ds 1
\1Field0x07::  ds 1
\1Field0x08::  ds 1
\1Field0x09::  ds 1
\1Field0x0a::  ds 1
\1Field0x0b::  ds 1
ENDM

MACRO sprite_vram_struct
\1Valid::      ds 1
\1ID::         ds 1
\1TileOffset:: ds 1
\1TileSize::   ds 1
ENDM

MACRO deck_struct
\1Name::  ds DECK_NAME_SIZE
\1Cards:: ds DECK_COMPRESSED_SIZE
ENDM

MACRO duel_vars
	ASSERT (LOW(@) == 0), "must be aligned to $100"

; 60-byte array that indicates where each of the 60 cards is.
;	$00 - deck
;	$01 - hand
;	$02 - discard pile
;	$08 - prize
;	$10 - active (active pokemon or a card attached to it)
;	$1X - bench (where X is bench position from 1 to 5)
\1CardLocations::                ds DECK_SIZE

; 60-byte array that maps each card to its position in the deck or anywhere else
; This array is initialized to 00, 01, 02, ..., 59, until deck is shuffled.
; Cards in the discard pile go first, cards still in the deck go last, and others go in-between.
\1DeckCards::                    ds DECK_SIZE

; deck indexes of the up to 6 cards placed as prizes
\1PrizeCards::                   ds $6

; Stores x = deck remaining cards.
; The first x cards in the \1DeckCards array are the drawable deck this duel.
; The top card of the duelist's deck is at \1DeckCards + x - 1.
\1NumberOfCardsInDeck::        ds $1
\1NumberOfCardsInHand::        ds $1
\1NumberOfCardsInDiscardPile:: ds $1
; Pokemon cards in active + bench
\1NumberOfPokemonInPlayArea::  ds $1

; Deck index of the card that is in duelist's side of the field
; -1 indicates no pokemon

; Deck indexes of the cards that are in duelist's bench, plus an $ff (-1) terminator
; -1 indicates no pokemon
\1PlayArea::                     ds MAX_PLAY_AREA_POKEMON + 1
\1PlayAreaHP::                   ds MAX_PLAY_AREA_POKEMON
\1PlayAreaStage::                ds MAX_PLAY_AREA_POKEMON
; if bit 7 == 1, then bits 0-3 override the Pokemon's actual color
\1PlayAreaAttachedDefender::     ds MAX_PLAY_AREA_POKEMON
\1PlayAreaAttachedPlusPower::    ds MAX_PLAY_AREA_POKEMON
\1PlayAreaChangedType::          ds MAX_PLAY_AREA_POKEMON

\1ActiveCardStatus::              ds $1
\1ActiveCardFlags::               ds $1
\1ActiveCardSubstatus1::          ds $1
\1ActiveCardSubstatus2::          ds $1

; each bit represents a prize that this duelist can draw (1 = not drawn ; 0 = drawn)
\1Prizes::                       ds $1

	ds $54

ENDM
