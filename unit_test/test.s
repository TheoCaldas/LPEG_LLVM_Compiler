	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 13, 0
	.globl	_fabs                           ; -- Begin function fabs
	.p2align	2
_fabs:                                  ; @fabs
	.cfi_startproc
; %bb.0:                                ; %common.ret
	sub	sp, sp, #16
	.cfi_def_cfa_offset 16
	fmov	d1, d0
	fneg	d0, d0
	fcmp	d1, #0.0
	str	d1, [sp, #8]
	fcsel	d0, d0, d1, mi
	add	sp, sp, #16
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_fsqrt                          ; -- Begin function fsqrt
	.p2align	2
_fsqrt:                                 ; @fsqrt
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #64
	.cfi_def_cfa_offset 64
	stp	d9, d8, [sp, #32]               ; 16-byte Folded Spill
	stp	x29, x30, [sp, #48]             ; 16-byte Folded Spill
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset b8, -24
	.cfi_offset b9, -32
	mov	x8, #25749
	fmov	d8, #2.00000000
	movk	x8, #57721, lsl #16
	stp	d0, d0, [sp, #16]
	movk	x8, #64895, lsl #32
	movk	x8, #15781, lsl #48
	str	x8, [sp, #8]
LBB1_1:                                 ; %L17
                                        ; =>This Inner Loop Header: Depth=1
	ldp	d0, d1, [sp, #16]
	fmul	d0, d0, d0
	fsub	d0, d1, d0
	bl	_fabs
	ldr	d1, [sp, #8]
	fcmp	d0, d1
	ldr	d0, [sp, #16]
	b.le	LBB1_3
; %bb.2:                                ; %L18
                                        ;   in Loop: Header=BB1_1 Depth=1
	ldp	d2, d1, [sp, #16]
	fdiv	d1, d1, d2
	fadd	d0, d0, d1
	fdiv	d0, d0, d8
	str	d0, [sp, #16]
	b	LBB1_1
LBB1_3:                                 ; %L19
	ldp	x29, x30, [sp, #48]             ; 16-byte Folded Reload
	ldp	d9, d8, [sp, #32]               ; 16-byte Folded Reload
	add	sp, sp, #64
	ret
	.cfi_endproc
                                        ; -- End function
	.section	__TEXT,__literal8,8byte_literals
	.p2align	3, 0x0                          ; -- Begin function main
lCPI2_0:
	.quad	0x409370db43526528              ; double 1244.2141240000001
	.section	__TEXT,__text,regular,pure_instructions
	.globl	_main
	.p2align	2
_main:                                  ; @main
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #48
	.cfi_def_cfa_offset 48
	stp	x20, x19, [sp, #16]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	fmov	d0, #4.00000000
	bl	_fsqrt
Lloh0:
	adrp	x19, l_.strD@PAGE
Lloh1:
	add	x19, x19, l_.strD@PAGEOFF
	mov	x0, x19
	str	d0, [sp]
	bl	_printf
	fmov	d0, #9.00000000
	bl	_fsqrt
	mov	x0, x19
	str	d0, [sp]
	bl	_printf
	fmov	d0, #16.00000000
	bl	_fsqrt
	mov	x0, x19
	str	d0, [sp]
	bl	_printf
	fmov	d0, #25.00000000
	bl	_fsqrt
	mov	x0, x19
	str	d0, [sp]
	bl	_printf
Lloh2:
	adrp	x8, lCPI2_0@PAGE
Lloh3:
	ldr	d0, [x8, lCPI2_0@PAGEOFF]
	bl	_fsqrt
	mov	x0, x19
	str	d0, [sp]
	bl	_printf
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	mov	w0, wzr
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #48
	ret
	.loh AdrpLdr	Lloh2, Lloh3
	.loh AdrpAdd	Lloh0, Lloh1
	.cfi_endproc
                                        ; -- End function
	.section	__TEXT,__cstring,cstring_literals
l_.strI:                                ; @.strI
	.asciz	"%d\n"

l_.strD:                                ; @.strD
	.asciz	"%g\n"

.subsections_via_symbols
