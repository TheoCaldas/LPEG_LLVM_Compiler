	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 13, 0
	.globl	_printArray                     ; -- Begin function printArray
	.p2align	2
_printArray:                            ; @printArray
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #80
	stp	d9, d8, [sp, #32]               ; 16-byte Folded Spill
	stp	x20, x19, [sp, #48]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #64]             ; 16-byte Folded Spill
	.cfi_def_cfa_offset 80
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset b8, -40
	.cfi_offset b9, -48
	sub	w8, w1, #1
	fmov	d9, #1.00000000
Lloh0:
	adrp	x19, l_.strI@PAGE
Lloh1:
	add	x19, x19, l_.strI@PAGEOFF
	str	x0, [sp, #24]
	scvtf	d8, w8
	str	w1, [sp, #20]
	str	xzr, [sp, #8]
LBB0_1:                                 ; %L9
                                        ; =>This Inner Loop Header: Depth=1
	ldr	d0, [sp, #8]
	fcmp	d0, d8
	b.hi	LBB0_3
; %bb.2:                                ; %L10
                                        ;   in Loop: Header=BB0_1 Depth=1
	ldr	d0, [sp, #8]
	mov	x0, x19
	ldr	x9, [sp, #24]
	fcvtzs	w8, d0
	ldr	w8, [x9, w8, sxtw #2]
	str	x8, [sp]
	bl	_printf
	ldr	d0, [sp, #8]
	fadd	d0, d0, d9
	str	d0, [sp, #8]
	b	LBB0_1
LBB0_3:                                 ; %L11
	ldp	x29, x30, [sp, #64]             ; 16-byte Folded Reload
	ldp	x20, x19, [sp, #48]             ; 16-byte Folded Reload
	ldp	d9, d8, [sp, #32]               ; 16-byte Folded Reload
	add	sp, sp, #80
	ret
	.loh AdrpAdd	Lloh0, Lloh1
	.cfi_endproc
                                        ; -- End function
	.globl	_fillWith                       ; -- Begin function fillWith
	.p2align	2
_fillWith:                              ; @fillWith
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #32
	.cfi_def_cfa_offset 32
	sub	w8, w1, #1
	fmov	d2, #1.00000000
	str	w1, [sp, #20]
	str	x0, [sp, #24]
	scvtf	d1, w8
	str	d0, [sp, #8]
	str	xzr, [sp]
LBB1_1:                                 ; %L35
                                        ; =>This Inner Loop Header: Depth=1
	ldr	d0, [sp]
	fcmp	d0, d1
	b.hi	LBB1_3
; %bb.2:                                ; %L36
                                        ;   in Loop: Header=BB1_1 Depth=1
	ldp	d0, d3, [sp]
	ldr	x9, [sp, #24]
	fcvtzs	w8, d0
	fadd	d0, d0, d2
	str	d3, [x9, w8, sxtw #3]
	str	d0, [sp]
	b	LBB1_1
LBB1_3:                                 ; %L37
	add	sp, sp, #32
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_zeroMatrix                     ; -- Begin function zeroMatrix
	.p2align	2
_zeroMatrix:                            ; @zeroMatrix
	.cfi_startproc
; %bb.0:
	stp	d9, d8, [sp, #-32]!             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	add	x29, sp, #16
	sub	sp, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset b8, -24
	.cfi_offset b9, -32
	lsl	w8, w0, #3
	stp	w1, w0, [x29, #-24]
	sxtw	x8, w8
	mov	x0, x8
	bl	_malloc
	ldur	w8, [x29, #-20]
	fmov	d9, #1.00000000
	stp	xzr, x0, [x29, #-40]
	sub	w8, w8, #1
	scvtf	d8, w8
	b	LBB2_2
LBB2_1:                                 ; %L87
                                        ;   in Loop: Header=BB2_2 Depth=1
	ldur	d0, [x29, #-40]
	fadd	d0, d0, d9
	stur	d0, [x29, #-40]
LBB2_2:                                 ; %L64
                                        ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB2_4 Depth 2
	ldur	d0, [x29, #-40]
	fcmp	d0, d8
	b.hi	LBB2_6
; %bb.3:                                ; %L65
                                        ;   in Loop: Header=BB2_2 Depth=1
	ldur	w8, [x29, #-24]
	lsl	w8, w8, #3
	sxtw	x0, w8
	bl	_malloc
	ldur	d0, [x29, #-40]
	ldur	x9, [x29, #-32]
	fcvtzs	w8, d0
	str	x0, [x9, w8, sxtw #3]
	mov	x9, sp
	sub	x8, x9, #16
	mov	sp, x8
	ldur	w10, [x29, #-24]
	stur	xzr, [x9, #-16]
	sub	w10, w10, #1
	scvtf	d0, w10
LBB2_4:                                 ; %L85
                                        ;   Parent Loop BB2_2 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ldr	d1, [x8]
	fcmp	d1, d0
	b.hi	LBB2_1
; %bb.5:                                ; %L86
                                        ;   in Loop: Header=BB2_4 Depth=2
	ldur	d1, [x29, #-40]
	ldr	d2, [x8]
	ldur	x10, [x29, #-32]
	fcvtzs	w9, d1
	fadd	d1, d2, d9
	fcvtzs	w11, d2
	ldr	x9, [x10, w9, sxtw #3]
	str	d1, [x8]
	str	xzr, [x9, w11, sxtw #3]
	b	LBB2_4
LBB2_6:                                 ; %L66
	ldur	x0, [x29, #-32]
	sub	sp, x29, #16
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	ldp	d9, d8, [sp], #32               ; 16-byte Folded Reload
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_main                           ; -- Begin function main
	.p2align	2
_main:                                  ; @main
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #80
	stp	x20, x19, [sp, #48]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #64]             ; 16-byte Folded Spill
	.cfi_def_cfa_offset 80
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	mov	w0, #40                         ; =0x28
	bl	_malloc
	mov	x8, #1                          ; =0x1
	mov	x9, #3                          ; =0x3
	movk	x8, #2, lsl #32
	movk	x9, #4, lsl #32
	mov	x10, #5                         ; =0x5
	str	x0, [sp, #40]
	mov	x11, #7                         ; =0x7
	movk	x10, #6, lsl #32
	stp	x8, x9, [x0]
	mov	x8, #9                          ; =0x9
	movk	x11, #8, lsl #32
	movk	x8, #10, lsl #32
	mov	w1, #10                         ; =0xa
	stp	x10, x11, [x0, #16]
	str	x8, [x0, #32]
	ldr	x0, [sp, #40]
	bl	_printArray
	mov	w8, #4                          ; =0x4
	mov	w0, #32                         ; =0x20
	str	w8, [sp, #28]
	bl	_malloc
	mov	x8, #7378697629483820646        ; =0x6666666666666666
	ldr	w1, [sp, #28]
	movk	x8, #16374, lsl #48
	str	x0, [sp, #32]
	fmov	d0, x8
	bl	_fillWith
	ldr	x8, [sp, #32]
Lloh2:
	adrp	x19, l_.strD@PAGE
Lloh3:
	add	x19, x19, l_.strD@PAGEOFF
	mov	x0, x19
	ldr	d0, [x8, #24]
	str	d0, [sp]
	bl	_printf
	mov	w0, #3                          ; =0x3
	mov	w1, #4                          ; =0x4
	bl	_zeroMatrix
	ldr	x8, [x0, #8]
	str	x0, [sp, #16]
	mov	x0, x19
	ldr	d0, [x8, #8]
	str	d0, [sp]
	bl	_printf
	ldp	x29, x30, [sp, #64]             ; 16-byte Folded Reload
	mov	w0, wzr
	ldp	x20, x19, [sp, #48]             ; 16-byte Folded Reload
	add	sp, sp, #80
	ret
	.loh AdrpAdd	Lloh2, Lloh3
	.cfi_endproc
                                        ; -- End function
	.section	__TEXT,__cstring,cstring_literals
l_.strI:                                ; @.strI
	.asciz	"%d\n"

l_.strD:                                ; @.strD
	.asciz	"%g\n"

.subsections_via_symbols
