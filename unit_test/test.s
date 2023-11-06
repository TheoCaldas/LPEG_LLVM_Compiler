	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 13, 0
	.globl	_main                           ; -- Begin function main
	.p2align	2
_main:                                  ; @main
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #64
	.cfi_def_cfa_offset 64
	stp	x20, x19, [sp, #32]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #48]             ; 16-byte Folded Spill
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	mov	x8, #-3689348814741910324
Lloh0:
	adrp	x19, l_.strD@PAGE
Lloh1:
	add	x19, x19, l_.strD@PAGEOFF
	movk	x8, #52429
	movk	x8, #16422, lsl #48
	mov	x0, x19
	str	x8, [sp]
	bl	_printf
	mov	x8, #4617878467915022336
	mov	w9, #1
	mov	x0, x19
	str	x8, [sp, #24]
	mov	x8, #4620974692658839552
	str	w9, [sp, #20]
	str	x8, [sp]
	bl	_printf
	ldr	d0, [sp, #24]
	mov	x0, x19
	ldr	w9, [sp, #20]
	fcvtzs	w8, d0
	scvtf	d0, w9
	scvtf	d1, w8
	fadd	d0, d1, d0
	str	d0, [sp]
	bl	_printf
	ldr	w8, [sp, #20]
	mov	w0, wzr
	ldp	x29, x30, [sp, #48]             ; 16-byte Folded Reload
	scvtf	d0, w8
	ldp	x20, x19, [sp, #32]             ; 16-byte Folded Reload
	str	d0, [sp, #8]
	add	sp, sp, #64
	ret
	.loh AdrpAdd	Lloh0, Lloh1
	.cfi_endproc
                                        ; -- End function
	.section	__TEXT,__cstring,cstring_literals
l_.strI:                                ; @.strI
	.asciz	"%d\n"

l_.strD:                                ; @.strD
	.asciz	"%g\n"

.subsections_via_symbols
