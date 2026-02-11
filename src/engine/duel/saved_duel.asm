; try to resume a saved duel from the main menu
TryContinueDuel::
    ; TODO
	ldtx hl, BackUpIsBrokenText
	call DrawWideTextBox_WaitForInput
	scf
	ret

; return carry if there is no data saved at sCurrentDuel or if the checksum isn't correct
; input: hl = sCurrentDuel
ValidateSavedDuelData:
	call EnableSRAM
	push de
	ld a, [hli]
	or a
	jr z, .no_saved_data
	lb de, $23, $45
	ld bc, $334
	ld a, [hl]
	sub e
	ld e, a
	inc hl
	ld a, [hl]
	xor d
	ld d, a
	inc hl
	inc hl
.loop
	ld a, [hl]
	add e
	ld e, a
	ld a, [hli]
	xor d
	ld d, a
	dec bc
	ld a, c
	or b
	jr nz, .loop
	ld a, e
	or d
	jr z, .ok
.no_saved_data
	scf
.ok
	call DisableSRAM
	pop de
	ret

; discard data of a duel that was saved by SaveDuelData, by setting the first byte
; of sCurrentDuel to $00, and zeroing the checksum (next two bytes)
DiscardSavedDuelData:
	call EnableSRAM
	ld hl, sCurrentDuel
	xor a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	jp DisableSRAM
