#
# libctx - A cooperative multitasking library for C/C++
#
# Copyright 2013 Nathaniel McCallum <nathaniel@themccallums.org>
# Portions Copyright 2009 Oliver Kowalke
#
# Distributed under the Boost Software License, Version 1.0.
#

# ---------------------------------------------------------
# |                       ctx_state                       |
# ---------------------------------------------------------
# |   0  |   1  |   2  |   3  |   4  |   5  |   6  |   7  |
# ---------------------------------------------------------
# |  r13 |  r14 |  r15 |  r16 |  r17 |  r18 |  r19 |  r20 |
# ---------------------------------------------------------
# ---------------------------------------------------------
# |   8  |   9  |  10  |  11  |  12  |  13  |  14  |  15  |
# ---------------------------------------------------------
# |  r21 |  r22 |  r23 |  r24 |  r25 |  r26 |  r27 |  r28 |
# ---------------------------------------------------------
# ---------------------------------------------------------
# |  16  |  17  |  18  |  19  |  20  |  21  |  22  |  23  |
# ---------------------------------------------------------
# |  r29 |  r30 |  r31 |  sp  |  cr  |  lr  |  prm |  cnt |
# ---------------------------------------------------------

# ---------------------------------------------------------
# |                       ctx_extra                       |
# ---------------------------------------------------------
# | 0x00 | 0x08 | 0x10 | 0x18 | 0x20 | 0x28 | 0x30 | 0x38 |
# ---------------------------------------------------------
# |  f14 |  f15 |  f16 |  f17 |  f18 |  f19 |  f20 |  f21 |
# ---------------------------------------------------------
# ---------------------------------------------------------
# | 0x40 | 0x48 | 0x50 | 0x58 | 0x60 | 0x68 | 0x70 | 0x78 |
# ---------------------------------------------------------
# |  f22 |  f23 |  f24 |  f25 |  f26 |  f27 |  f28 |  f29 |
# ---------------------------------------------------------
# ---------------------------------------------------------
# | 0x80 | 0x88 | 0x90 |                                  |
# ---------------------------------------------------------
# |  f30 |  f31 | fpscr|                                  |
# ---------------------------------------------------------

#ifdef CTX_64BIT
# define NAME(name) .name
# define OFFSET(r, o) (o * 8)(r)
# define lwz ld
# define stw std
# define clrrwi clrrdi
# define cmpwi cmpdi
#else
# define NAME(name) name
# define OFFSET(r, o) (o * 4)(r)
#endif

# void __CTX_NORETURN
# ctx_call(void *param, ctx_stack stack, int (*func)(void *param));
.text
.align 2
.globl ctx_call
.type ctx_call, @function
#ifdef CTX_64BIT
.section ".opd", "aw"
.align 3
ctx_call:
.quad .ctx_call, .TOC.@tocbase, 0
.size ctx_call, 24
.previous
.ctx_call:
    ld         %r5,    0(%r6)    # Get entry point.
    ld         %r2,    8(%r6)    # Get TOC base address.
    ld         %r11,  16(%r6)    # Get environment pointer.
#else
ctx_call:
    lwz        %r4,    0(%r4)    # Get the stack pointer from the struct.
#endif

    clrrwi     %r4,      %r4, 4  # Align the stack.
    subi       %r1,      %r4, 64 # Create parameter and linkage area.

    mtctr      %r5
    bctrl                        # Call func().
    bl         _exit             # Call _exit().
    nop
.size NAME(ctx_call), .-NAME(ctx_call)

# size_t
# ctx_mark(ctx_state *state, ctx_extra *extra, void **param);
.text
.align 2
.globl ctx_mark
.type ctx_mark, @function
#ifdef CTX_64BIT
.section ".opd", "aw"
.align 3
ctx_mark:
.quad .ctx_mark, .TOC.@tocbase, 0
.size ctx_mark, 24
.previous
.ctx_mark:
#else
ctx_mark:
#endif
    mfcr       %r6                     # Get cr.
    mflr       %r7                     # Get lr.
    li         %r8,    0               # Get cnt.
    stw        %r13,   OFFSET(%r3, 0)  # Save r13.
    stw        %r14,   OFFSET(%r3, 1)  # Save r14.
    stw        %r15,   OFFSET(%r3, 2)  # Save r15.
    stw        %r16,   OFFSET(%r3, 3)  # Save r16.
    stw        %r17,   OFFSET(%r3, 4)  # Save r17.
    stw        %r18,   OFFSET(%r3, 5)  # Save r18.
    stw        %r19,   OFFSET(%r3, 6)  # Save r19.
    stw        %r20,   OFFSET(%r3, 7)  # Save r20.
    stw        %r21,   OFFSET(%r3, 8)  # Save r21.
    stw        %r22,   OFFSET(%r3, 9)  # Save r22.
    stw        %r23,   OFFSET(%r3, 10) # Save r23.
    stw        %r24,   OFFSET(%r3, 11) # Save r24.
    stw        %r25,   OFFSET(%r3, 12) # Save r25.
    stw        %r26,   OFFSET(%r3, 13) # Save r26.
    stw        %r27,   OFFSET(%r3, 14) # Save r27.
    stw        %r28,   OFFSET(%r3, 15) # Save r28.
    stw        %r29,   OFFSET(%r3, 16) # Save r29.
    stw        %r30,   OFFSET(%r3, 17) # Save r30.
    stw        %r31,   OFFSET(%r3, 18) # Save r31.
    stw        %r1,    OFFSET(%r3, 19) # Save sp.
    stw        %r6,    OFFSET(%r3, 20) # Save cr.
    stw        %r7,    OFFSET(%r3, 21) # Save lr.
    stw        %r5,    OFFSET(%r3, 22) # Save prm.
    stw        %r8,    OFFSET(%r3, 23) # Save cnt.

    cmpwi      cr0,    %r4,    0       # Is extra NULL?
    beq        cr0,    noext0
    mffs       %f0                     # Get fpscr.
    stfd       %f14,   0x00(%r4)       # Save f14.
    stfd       %f15,   0x08(%r4)       # Save f15.
    stfd       %f16,   0x10(%r4)       # Save f16.
    stfd       %f17,   0x18(%r4)       # Save f17.
    stfd       %f18,   0x20(%r4)       # Save f18.
    stfd       %f19,   0x28(%r4)       # Save f19.
    stfd       %f20,   0x30(%r4)       # Save f20.
    stfd       %f21,   0x38(%r4)       # Save f21.
    stfd       %f22,   0x40(%r4)       # Save f22.
    stfd       %f23,   0x48(%r4)       # Save f23.
    stfd       %f24,   0x50(%r4)       # Save f24.
    stfd       %f25,   0x58(%r4)       # Save f25.
    stfd       %f26,   0x60(%r4)       # Save f26.
    stfd       %f27,   0x68(%r4)       # Save f27.
    stfd       %f28,   0x70(%r4)       # Save f28.
    stfd       %f29,   0x78(%r4)       # Save f29.
    stfd       %f30,   0x80(%r4)       # Save f30.
    stfd       %f31,   0x88(%r4)       # Save f31.
    stfd       %f0,    0x90(%r4)       # Save fpscr.
noext0:

    li         %r3,    0               # Return cnt.
    blr
.size NAME(ctx_mark), .-NAME(ctx_mark)

# void __CTX_NORETURN
# ctx_jump(ctx_state *state, ctx_extra *extra, void *param);
.text
.align 2
.globl ctx_jump
.type ctx_jump, @function
#ifdef CTX_64BIT
.section ".opd", "aw"
.align 3
ctx_jump:
.quad .ctx_jump, .TOC.@tocbase, 0
.size ctx_jump, 24
.previous
.ctx_jump:
#else
ctx_jump:
#endif
    lwz        %r13,   OFFSET(%r3, 0)  # Load r13.
    lwz        %r14,   OFFSET(%r3, 1)  # Load r14.
    lwz        %r15,   OFFSET(%r3, 2)  # Load r15.
    lwz        %r16,   OFFSET(%r3, 3)  # Load r16.
    lwz        %r17,   OFFSET(%r3, 4)  # Load r17.
    lwz        %r18,   OFFSET(%r3, 5)  # Load r18.
    lwz        %r19,   OFFSET(%r3, 6)  # Load r19.
    lwz        %r20,   OFFSET(%r3, 7)  # Load r20.
    lwz        %r21,   OFFSET(%r3, 8)  # Load r21.
    lwz        %r22,   OFFSET(%r3, 9)  # Load r22.
    lwz        %r23,   OFFSET(%r3, 10) # Load r23.
    lwz        %r24,   OFFSET(%r3, 11) # Load r24.
    lwz        %r25,   OFFSET(%r3, 12) # Load r25.
    lwz        %r26,   OFFSET(%r3, 13) # Load r26.
    lwz        %r27,   OFFSET(%r3, 14) # Load r27.
    lwz        %r28,   OFFSET(%r3, 15) # Load r28.
    lwz        %r29,   OFFSET(%r3, 16) # Load r29.
    lwz        %r30,   OFFSET(%r3, 17) # Load r30.
    lwz        %r31,   OFFSET(%r3, 18) # Load r31.
    lwz        %r1,    OFFSET(%r3, 19) # Load sp.
    lwz        %r6,    OFFSET(%r3, 20) # Load cr.
    lwz        %r7,    OFFSET(%r3, 21) # Load lr.
    mtcr       %r6                     # Set cr.
    mtlr       %r7                     # Set lr.

    cmpwi      cr0,    %r4,    0       # Is extra NULL?
    beq        cr0,    noext1
    lfd        %f14,   0x00(%r4)       # Load f14.
    lfd        %f15,   0x08(%r4)       # Load f15.
    lfd        %f16,   0x10(%r4)       # Load f16.
    lfd        %f17,   0x18(%r4)       # Load f17.
    lfd        %f18,   0x20(%r4)       # Load f18.
    lfd        %f19,   0x28(%r4)       # Load f19.
    lfd        %f20,   0x30(%r4)       # Load f20.
    lfd        %f21,   0x38(%r4)       # Load f21.
    lfd        %f22,   0x40(%r4)       # Load f22.
    lfd        %f23,   0x48(%r4)       # Load f23.
    lfd        %f24,   0x50(%r4)       # Load f24.
    lfd        %f25,   0x58(%r4)       # Load f25.
    lfd        %f26,   0x60(%r4)       # Load f26.
    lfd        %f27,   0x68(%r4)       # Load f27.
    lfd        %f28,   0x70(%r4)       # Load f28.
    lfd        %f29,   0x78(%r4)       # Load f29.
    lfd        %f30,   0x80(%r4)       # Load f30.
    lfd        %f31,   0x88(%r4)       # Load f31.
    lfd        %f0,    0x90(%r4)       # Load fpscr.
    mtfsf      0x9f,   %f0             # Set fpscr.
noext1:

    lwz        %r8,    OFFSET(%r3, 22) # Load prm.
    cmpwi      cr0,    %r8,    0       # Is param NULL?
    beq        cr0,    noparam
    stw        %r5,    0x00(%r8)       # Set param.
noparam:

    lwz        %r9,    OFFSET(%r3, 23) # Load cnt.
    addi       %r9,    %r9,    1       # Increment cnt.
    stw        %r9,    OFFSET(%r3, 23) # Save cnt.
    mr         %r3,    %r9             # Return cnt.
    mtctr      %r7
    bctr
.size NAME(ctx_jump), .-NAME(ctx_jump)
