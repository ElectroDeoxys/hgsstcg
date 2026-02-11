SetupSound::
	push_wram BANK("WRAM Audio")
	farcall _SetupSound
	pop_wram
	ret

PlaySong::
	push bc
	ld b, a
	push_wram BANK("WRAM Audio")
	farcall _PlaySong
	pop_wram
	pop bc
	ret

; return a = 0: song finished, a = 1: song not finished
AssertSongFinished::
	push bc
	push_wram BANK("WRAM Audio")
	farcall _AssertSongFinished
	ld b, a
	pop_wram
	ld a, b
	pop bc
	ret

; return a = 0: SFX finished, a = 1: SFX not finished
AssertSFXFinished::
	push bc
	push_wram BANK("WRAM Audio")
	farcall _AssertSFXFinished
	ld b, a
	pop_wram
	ld a, b
	pop bc
	ret

PlaySFX_InvalidChoice::
	ld a, SFX_DENIED
PlaySFX::
	push bc
	ld b, a
	push_wram BANK("WRAM Audio")
	farcall _PlaySFX
	pop_wram
	pop bc
	ret

PauseSong::
	push_wram BANK("WRAM Audio")
	farcall _PauseSong
	pop_wram
	ret

ResumeSong::
	push_wram BANK("WRAM Audio")
	farcall _ResumeSong
	pop_wram
	ret
