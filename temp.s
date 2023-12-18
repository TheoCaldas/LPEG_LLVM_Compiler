	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 13, 0
	.globl	_main                           ; -- Begin function main
	.p2align	2
_main:                                  ; @main
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #48
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	.cfi_def_cfa_offset 48
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	mov	x8, #18350                      ; =0x47ae
	mov	x9, #20972                      ; =0x51ec
	movk	x8, #31457, lsl #16
	movk	x9, #7864, lsl #16
	movk	x8, #44564, lsl #32
	movk	x9, #60293, lsl #32
	movk	x8, #16371, lsl #48
	movk	x9, #16385, lsl #48
	mov	w10, #9                         ; =0x9
Lloh0:
	adrp	x0, l_.strD@PAGE
Lloh1:
	add	x0, x0, l_.strD@PAGEOFF
	stp	x9, x8, [sp, #16]
	mov	x8, #50099                      ; =0xc3b3
	movk	x8, #58836, lsl #16
	str	w10, [sp, #12]
	movk	x8, #2038, lsl #32
	movk	x8, #16401, lsl #48
	str	x8, [sp]
	bl	_printf
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	mov	w0, wzr
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
