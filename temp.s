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
	.globl	_main                           ; -- Begin function main
	.p2align	2
_main:                                  ; @main
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #32
	.cfi_def_cfa_offset 32
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	mov	x8, #3689348814741910323
	movk	x8, #49163, lsl #48
	fmov	d0, x8
	bl	_fabs
Lloh0:
	adrp	x0, l_.strD@PAGE
Lloh1:
	add	x0, x0, l_.strD@PAGEOFF
	str	d0, [sp]
	bl	_printf
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	mov	w0, wzr
	add	sp, sp, #32
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
