	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 13, 0
	.globl	_foo                            ; -- Begin function foo
	.p2align	2
_foo:                                   ; @foo
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
Lloh0:
	adrp	x19, l_.strI@PAGE
Lloh1:
	add	x19, x19, l_.strI@PAGEOFF
	mov	w8, w0
	stp	w1, w0, [sp, #8]
	mov	x0, x19
	str	x8, [sp]
	bl	_printf
	ldr	w8, [sp, #8]
	mov	x0, x19
	str	x8, [sp]
	bl	_printf
	mov	x8, #3689348814741910323
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	movk	x8, #16395, lsl #48
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	fmov	d0, x8
	add	sp, sp, #48
	ret
	.loh AdrpAdd	Lloh0, Lloh1
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
	mov	w8, #3
	mov	w9, #4
	mov	w0, #3
	mov	w1, #4
	stp	w9, w8, [sp, #8]
	bl	_foo
Lloh2:
	adrp	x0, l_.strD@PAGE
Lloh3:
	add	x0, x0, l_.strD@PAGEOFF
	str	d0, [sp]
	bl	_printf
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	mov	w0, wzr
	add	sp, sp, #32
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
