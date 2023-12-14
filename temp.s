	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 13, 0
	.globl	_main                           ; -- Begin function main
	.p2align	2
_main:                                  ; @main
	.cfi_startproc
; %bb.0:
	mov	w0, wzr
	ret
	.cfi_endproc
                                        ; -- End function
	.section	__TEXT,__cstring,cstring_literals
l_.strI:                                ; @.strI
	.asciz	"%d\n"

l_.strD:                                ; @.strD
	.asciz	"%g\n"

.subsections_via_symbols
