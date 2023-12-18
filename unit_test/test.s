	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 13, 0
	.globl	_main                           ; -- Begin function main
	.p2align	2
_main:                                  ; @main
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #48
	stp	x20, x19, [sp, #16]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	.cfi_def_cfa_offset 48
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	mov	w0, #16                         ; =0x10
	bl	_malloc
	mov	x8, #3                          ; =0x3
	mov	w9, #1                          ; =0x1
	movk	x8, #2, lsl #32
Lloh0:
	adrp	x19, l_.strI@PAGE
Lloh1:
	add	x19, x19, l_.strI@PAGEOFF
	str	x0, [sp, #8]
	str	w9, [x0, #8]
	str	x8, [x0]
	mov	w8, #3                          ; =0x3
	mov	x0, x19
	str	x8, [sp]
	bl	_printf
	ldr	x8, [sp, #8]
	mov	x0, x19
	ldr	w8, [x8, #4]
	str	x8, [sp]
	bl	_printf
	ldr	x8, [sp, #8]
	mov	x0, x19
	ldr	w8, [x8, #8]
	str	x8, [sp]
	bl	_printf
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	mov	w0, wzr
	ldp	x20, x19, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #48
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
