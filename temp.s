	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 13, 0
	.globl	_main                           ; -- Begin function main
	.p2align	2
_main:                                  ; @main
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #64
	stp	x20, x19, [sp, #32]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #48]             ; 16-byte Folded Spill
	.cfi_def_cfa_offset 64
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	mov	w0, #16                         ; =0x10
	bl	_malloc
	str	x0, [sp, #24]
	mov	w0, #8                          ; =0x8
	bl	_malloc
	ldr	x8, [sp, #24]
	str	x0, [x8]
	mov	w0, #8                          ; =0x8
	bl	_malloc
	ldr	x8, [sp, #24]
	mov	w10, #1                         ; =0x1
Lloh0:
	adrp	x19, l_.strI@PAGE
Lloh1:
	add	x19, x19, l_.strI@PAGEOFF
	ldr	x9, [x8]
	str	x0, [x8, #8]
	mov	x0, x19
	str	w10, [x9]
	mov	w10, #2                         ; =0x2
	ldr	x9, [x8]
	str	w10, [x9, #4]
	mov	w10, #3                         ; =0x3
	ldr	x9, [x8, #8]
	str	w10, [x9]
	mov	w10, #4                         ; =0x4
	ldr	x9, [x8, #8]
	str	w10, [x9, #4]
	ldr	x8, [x8]
	ldr	w8, [x8, #4]
	str	x8, [sp]
	bl	_printf
	mov	w0, #8                          ; =0x8
	bl	_malloc
	ldr	x8, [sp, #24]
	mov	x0, x19
	ldr	x8, [x8]
	ldr	w9, [x8]
	str	x8, [sp, #16]
	str	x9, [sp]
	bl	_printf
	ldr	x8, [sp, #16]
	mov	w9, #20                         ; =0x14
	mov	x0, x19
	str	w9, [x8]
	str	x9, [sp]
	bl	_printf
	ldr	x8, [sp, #24]
	mov	x0, x19
	ldr	x8, [x8]
	ldr	w8, [x8]
	str	x8, [sp]
	bl	_printf
	ldp	x10, x8, [sp, #16]
	mov	w9, #23                         ; =0x17
	mov	x0, x19
	ldr	x8, [x8]
	str	w9, [x8]
	ldr	w8, [x10]
	str	x8, [sp]
	bl	_printf
	ldr	x8, [sp, #24]
	mov	x0, x19
	ldr	x8, [x8]
	ldr	w8, [x8]
	str	x8, [sp]
	bl	_printf
	ldp	x29, x30, [sp, #48]             ; 16-byte Folded Reload
	mov	w0, wzr
	ldp	x20, x19, [sp, #32]             ; 16-byte Folded Reload
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
