	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 13, 0
	.section	__TEXT,__literal8,8byte_literals
	.p2align	3, 0x0                          ; -- Begin function main
lCPI0_0:
	.quad	0x3ff4cccccccccccd              ; double 1.3
	.section	__TEXT,__text,regular,pure_instructions
	.globl	_main
	.p2align	2
_main:                                  ; @main
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #80
	.cfi_def_cfa_offset 80
	stp	d11, d10, [sp, #16]             ; 16-byte Folded Spill
	stp	d9, d8, [sp, #32]               ; 16-byte Folded Spill
	stp	x20, x19, [sp, #48]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #64]             ; 16-byte Folded Spill
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset b8, -40
	.cfi_offset b9, -48
	.cfi_offset b10, -56
	.cfi_offset b11, -64
Lloh0:
	adrp	x8, lCPI0_0@PAGE
	mov	x9, #-7378697629483820647
	movk	x9, #39322
	fmov	d8, #-1.00000000
	movk	x9, #16313, lsl #48
	fmov	d9, #20.00000000
Lloh1:
	ldr	d10, [x8, lCPI0_0@PAGEOFF]
Lloh2:
	adrp	x19, l_.strD@PAGE
Lloh3:
	add	x19, x19, l_.strD@PAGEOFF
	str	x9, [sp, #8]
LBB0_1:                                 ; %L1
                                        ; =>This Inner Loop Header: Depth=1
	ldr	d0, [sp, #8]
	fadd	d0, d0, d8
	fcmp	d0, d9
	b.pl	LBB0_3
; %bb.2:                                ; %L2
                                        ;   in Loop: Header=BB0_1 Depth=1
	ldr	d0, [sp, #8]
	mov	x0, x19
	str	d0, [sp]
	bl	_printf
	ldr	d0, [sp, #8]
	fadd	d0, d0, d10
	str	d0, [sp, #8]
	b	LBB0_1
LBB0_3:                                 ; %L3
	ldp	x29, x30, [sp, #64]             ; 16-byte Folded Reload
	mov	w0, wzr
	ldp	x20, x19, [sp, #48]             ; 16-byte Folded Reload
	ldp	d9, d8, [sp, #32]               ; 16-byte Folded Reload
	ldp	d11, d10, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #80
	ret
	.loh AdrpAdd	Lloh2, Lloh3
	.loh AdrpLdr	Lloh0, Lloh1
	.cfi_endproc
                                        ; -- End function
	.section	__TEXT,__cstring,cstring_literals
l_.strI:                                ; @.strI
	.asciz	"%d\n"

l_.strD:                                ; @.strD
	.asciz	"%g\n"

.subsections_via_symbols
