; cp de, bc
CompareDEtoBC::
	ld a, d
	cp b
	ret nz
	ld a, e
	cp c
	ret
