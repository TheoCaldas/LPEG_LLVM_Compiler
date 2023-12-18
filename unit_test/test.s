	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 13, 0
	.globl	_step                           ; -- Begin function step
	.p2align	2
_step:                                  ; @step
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #16
	.cfi_def_cfa_offset 16
	mov	x8, #3689348814741910323        ; =0x3333333333333333
	scvtf	d0, w0
	movk	x8, #16387, lsl #48
	str	w0, [sp, #12]
	fmov	d1, x8
	fmul	d0, d0, d1
	add	sp, sp, #16
	ret
	.cfi_endproc
                                        ; -- End function
	.section	__TEXT,__literal8,8byte_literals
	.p2align	3, 0x0                          ; -- Begin function main
lCPI1_0:
	.quad	0x4010cccccccccccd              ; double 4.2000000000000002
lCPI1_1:
	.quad	0x4054066666666666              ; double 80.099999999999994
	.section	__TEXT,__text,regular,pure_instructions
	.globl	_main
	.p2align	2
_main:                                  ; @main
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #64
	stp	d9, d8, [sp, #16]               ; 16-byte Folded Spill
	stp	x20, x19, [sp, #32]             ; 16-byte Folded Spill
	stp	x29, x30, [sp, #48]             ; 16-byte Folded Spill
	.cfi_def_cfa_offset 64
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	.cfi_offset w19, -24
	.cfi_offset w20, -32
	.cfi_offset b8, -40
	.cfi_offset b9, -48
	mov	x8, #-3689348814741910324       ; =0xcccccccccccccccc
	mov	w0, #4                          ; =0x4
	movk	x8, #16425, lsl #48
	str	x8, [sp, #8]
	bl	_step
Lloh0:
	adrp	x8, lCPI1_0@PAGE
Lloh1:
	adrp	x19, l_.strD@PAGE
Lloh2:
	add	x19, x19, l_.strD@PAGEOFF
Lloh3:
	ldr	d1, [x8, lCPI1_0@PAGEOFF]
Lloh4:
	adrp	x8, lCPI1_1@PAGE
	fadd	d8, d0, d1
Lloh5:
	ldr	d9, [x8, lCPI1_1@PAGEOFF]
LBB1_1:                                 ; %L10
                                        ; =>This Inner Loop Header: Depth=1
	ldr	d0, [sp, #8]
	fcmp	d0, d9
	b.hi	LBB1_3
; %bb.2:                                ; %L11
                                        ;   in Loop: Header=BB1_1 Depth=1
	ldr	d0, [sp, #8]
	mov	x0, x19
	str	d0, [sp]
	bl	_printf
	ldr	d0, [sp, #8]
	fadd	d0, d0, d8
	str	d0, [sp, #8]
	b	LBB1_1
LBB1_3:                                 ; %L12
	ldp	x29, x30, [sp, #48]             ; 16-byte Folded Reload
	mov	w0, wzr
	ldp	x20, x19, [sp, #32]             ; 16-byte Folded Reload
	ldp	d9, d8, [sp, #16]               ; 16-byte Folded Reload
	add	sp, sp, #64
	ret
	.loh AdrpLdr	Lloh4, Lloh5
	.loh AdrpAdd	Lloh1, Lloh2
	.loh AdrpAdrp	Lloh0, Lloh4
	.loh AdrpLdr	Lloh0, Lloh3
	.cfi_endproc
                                        ; -- End function
	.section	__TEXT,__cstring,cstring_literals
l_.strI:                                ; @.strI
	.asciz	"%d\n"

l_.strD:                                ; @.strD
	.asciz	"%g\n"

.subsections_via_symbols
