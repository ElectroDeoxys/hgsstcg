MACRO? lb ; r, hi, lo
	ld \1, (\2) << 8 + ((\3) & $ff)
ENDM

MACRO? ldtx
	IF _NARG == 2
		ld \1, \2_
	ELSE
		ld \1, \2_ \3
	ENDC
ENDM

MACRO? bank1call
	rst $18
	dw \1
ENDM

MACRO? farcall
	rst $28
	IF _NARG == 1
		db BANK(\1)
		dw \1
	ELSE
		db \1
		dw \2
	ENDC
ENDM

; runs SetEventValue with the next byte as the event, c as the new value
MACRO? set_event_value
	call SetStackEventValue
	db \1
ENDM

; runs ZeroOutEventValue with the next byte as the event
; functionally identical to set_event_zero but intended for single-bit events
MACRO? set_event_false
	call SetStackEventFalse
	db \1
ENDM

; runs ZeroOutEventValue with the next byte as the event
; functionally identical to set_event_false but intended for multi-bit events
MACRO? set_event_zero
	call SetStackEventZero
	db \1
ENDM

; runs MaxOutEventValue with the next byte as the event
MACRO? max_event_value
	call MaxStackEventValue
	db \1
ENDM

; runs GetEventValue with the next byte as the event. returns value in a
MACRO? get_event_value
	call GetStackEventValue
	db \1
ENDM

; the rst $38 handler is a single ret instruction
; probably used for testing purposes during development
MACRO? debug_nop
	rst $38
ENDM

; Returns to the pointer in bc instead of where the stack was.
MACRO? retbc
	push bc
	ret
ENDM

MACRO? cp16
	ld a, d
	cp HIGH(\1)
	jr nz, :+
	ld a, e
	cp LOW(\1)
:
ENDM

MACRO? cphl
	inc hl
	ld a, [hld]
	cp HIGH(\1)
	jr nz, :+
	ld a, [hl]
	cp LOW(\1)
:
ENDM

; loads into a register the GameBoy (DMG) palette given
; by the arguments as SHADE_* constants
MACRO? ldgbpal
	ld \1, (\2 << 0) | (\3 << 2) | (\4 << 4) | (\5 << 6)
ENDM

; used to temporarily switch
; to the given WRAM bank
MACRO? push_wram
	ldh a, [rWBK]
	push af
	ld a, \1 ; WRAM bank number
	ldh [rWBK], a
ENDM

MACRO? pop_wram
	pop af
	ldh [rWBK], a
ENDM

MACRO? get_turn_duelist_var
	rst GetTurnDuelistVariable
ENDM

MACRO? swap_turn
	rst SwapTurn
ENDM

; call this anytime in duel to load gfx during V-Blank
; through VDMA (maximum $80 tiles)
; \1 = gfx
; \2 = destination in VRAM
; \3 = number of tiles
MACRO? request_vdma
	ASSERT \3 >    0, "Has to be at least 1 tile to transfer"
	ASSERT \3 <= $80, "Only able to transfer max. $80 tiles"

	ld hl, wVDMASourceBank
	ld a, BANK(\1)
	ld [hli], a ; wVDMASourceBank
	ld a, HIGH(\1)
	ld [hli], a ; wVDMASource
	ld a, LOW(\1)
	ld [hli], a
	ld a, BANK(\2)
	ld [hli], a ; wVDMADestBank
	ld a, HIGH(\2)
	ld [hli], a ; wVDMADest
	ld a, LOW(\2)
	ld [hli], a
	ld a, \3 - 1
	ld [hli], a ; wVDMALen

	ld a, TRUE
	ld [wVDMAPending], a
ENDM
