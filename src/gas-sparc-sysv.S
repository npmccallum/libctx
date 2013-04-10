!
! libctx - A cooperative multitasking library for C/C++
!
! Copyright 2013 Nathaniel McCallum <nathaniel@themccallums.org>
! Portions Copyright 2013 Martin Husemann
!
! Distributed under the Boost Software License, Version 1.0.
!

! ---------------------------------------------------------
! |                       ctx_state                       |
! ---------------------------------------------------------
! |   0  |   1  |   2  |   3  |   4  |   5  |   6  |   7  |
! ---------------------------------------------------------
! |  l0  |  l1  |  l2  |  l3  |  l4  |  l5  |  l6  |  l7  |
! ---------------------------------------------------------
! |   8  |   9  |  10  |  11  |  12  |  13  |  14  |  15  |
! ---------------------------------------------------------
! |  i0  |  i1  |  i2  |  i3  |  i4  |  i5  |  i6  |  i7  |
! ---------------------------------------------------------
! |  16  |  17  |  18  |  19  |  20  |  21  |  22  |  23  |
! ---------------------------------------------------------
! |  sp  |  o7  |  g1  |  g2  |  g3  |  g6  |  g7  |  prm |
! ---------------------------------------------------------
! |  24  |                                                |
! ---------------------------------------------------------
! |  cnt |                                                |
! ---------------------------------------------------------
!
! -----------------------------------------------------------------
! |                       ctx_extra (32bit)                       |
! -----------------------------------------------------------------
! | 0x000 | 0x004 | 0x008 | 0x00c | 0x010 | 0x014 | 0x018 | 0x01c |
! -----------------------------------------------------------------
! |     f0-f1     |     f2-f3     |     f4-f5     |     f6-f7     |
! -----------------------------------------------------------------
! -----------------------------------------------------------------
! | 0x020 | 0x024 | 0x028 | 0x02c | 0x030 | 0x034 | 0x038 | 0x03c |
! -----------------------------------------------------------------
! |     f8-f9     |    f10-f11    |    f12-f13    |    f14-15     |
! -----------------------------------------------------------------
! -----------------------------------------------------------------
! | 0x040 |                                                       |
! -----------------------------------------------------------------
! |  fsr  |                                                       |
! -----------------------------------------------------------------
!
! -----------------------------------------------------------------
! |                       ctx_extra (64bit)                       |
! -----------------------------------------------------------------
! | 0x000 | 0x008 | 0x010 | 0x018 | 0x020 | 0x028 | 0x030 | 0x038 |
! -----------------------------------------------------------------
! |                             f0-f15                            |
! -----------------------------------------------------------------
! -----------------------------------------------------------------
! | 0x040 | 0x048 | 0x050 | 0x058 | 0x060 | 0x068 | 0x070 | 0x078 |
! -----------------------------------------------------------------
! |                            f16-f31                            |
! -----------------------------------------------------------------
! -----------------------------------------------------------------
! | 0x080 | 0x088 | 0x090 | 0x098 | 0x0a0 | 0x0a8 | 0x0b0 | 0x0b8 |
! -----------------------------------------------------------------
! |                            f32-f47                            |
! -----------------------------------------------------------------
! -----------------------------------------------------------------
! | 0x0c0 | 0x0c8 | 0x0d0 | 0x0d8 | 0x0e0 | 0x0e8 | 0x0f0 | 0x0f8 |
! -----------------------------------------------------------------
! |                            f48-f63                            |
! -----------------------------------------------------------------
! -----------------------------------------------------------------
! | 0x100 | 0x108 |                                               |
! -----------------------------------------------------------------
! |  fprs |  fsr  |                                               |
! -----------------------------------------------------------------

#ifdef CTX_64BIT
# define ALIGN 64
# define WINSZ 176+2048-1
# define OFFSET(r, i) [r + (8 * i)]
# define func %o3
# define st stx
# define ld ldx
#else
# define ALIGN 8
# define WINSZ 96
# define OFFSET(r, i) [r + (4 * i)]
# define func %o2
#endif

.register %g2, #ignore
.register %g3, #ignore
.register %g6, #ignore

! void __CTX_NORETURN
! ctx_call(void *param, ctx_stack stack, int (*func)(void *param));
.text
.globl ctx_call
.align 4
.type ctx_call, @function
ctx_call:
#ifndef CTX_64BIT
    ld        [%o1],           %o1   ! Get stack.stack.
#endif
    andn       %o1, ALIGN-1,   %o1   ! Align the stack.

    call      func                   ! Call the function.
      sub      %o1,   WINSZ,   %sp   ! Allocate register window.
    call     _exit
      nop
.size ctx_call, .-ctx_call

! size_t
! ctx_mark(ctx_state *state, ctx_extra *extra, void **param);
.text
.globl ctx_mark
.align 4
.type ctx_mark, @function
ctx_mark:
    st         %l0,    OFFSET(%o0, 0)  ! Save l0.
    st         %l1,    OFFSET(%o0, 1)  ! Save l1.
    st         %l2,    OFFSET(%o0, 2)  ! Save l2.
    st         %l3,    OFFSET(%o0, 3)  ! Save l3.
    st         %l4,    OFFSET(%o0, 4)  ! Save l4.
    st         %l5,    OFFSET(%o0, 5)  ! Save l5.
    st         %l6,    OFFSET(%o0, 6)  ! Save l6.
    st         %l7,    OFFSET(%o0, 7)  ! Save l7.
    st         %i0,    OFFSET(%o0, 8)  ! Save i0.
    st         %i1,    OFFSET(%o0, 9)  ! Save i1.
    st         %i2,    OFFSET(%o0, 10) ! Save i2.
    st         %i3,    OFFSET(%o0, 11) ! Save i3.
    st         %i4,    OFFSET(%o0, 12) ! Save i4.
    st         %i5,    OFFSET(%o0, 13) ! Save i5.
    st         %i6,    OFFSET(%o0, 14) ! Save i6.
    st         %i7,    OFFSET(%o0, 15) ! Save i7.
    st         %sp,    OFFSET(%o0, 16) ! Save sp.
    st         %o7,    OFFSET(%o0, 17) ! Save o7.
    st         %g1,    OFFSET(%o0, 18) ! Save g1.
    st         %g2,    OFFSET(%o0, 19) ! Save g2.
    st         %g3,    OFFSET(%o0, 20) ! Save g3.
    st         %g6,    OFFSET(%o0, 21) ! Save g6.
    st         %g7,    OFFSET(%o0, 22) ! Save g7.
    st         %o2,    OFFSET(%o0, 23) ! Save prm.
    st         %g0,    OFFSET(%o0, 24) ! Save cnt.

    cmp        %o1,    0               ! Is extra NULL?
    bz         noext0
    nop
#ifdef CTX_64BIT
    rd         %fprs,  %o4             ! Get fprs.
    stda       %f0,    [%o1]   0xf0    ! Save f00-f15.
    add        %o1,    64,     %o1     ! Move to next block.
    stda       %f16,   [%o1]   0xf0    ! Save f16-f31.
    add        %o1,    64,     %o1     ! Move to next block.
    stda       %f32,   [%o1]   0xf0    ! Save f32-f47.
    add        %o1,    64,     %o1     ! Move to next block.
    stda       %f48,   [%o1]   0xf0    ! Save f48-f64.
    add        %o1,    64,     %o1     ! Move to next block.
    stx        %o4,    [%o1 + 0x00]    ! Save fprs.
    stx        %fsr,   [%o1 + 0x08]    ! Save fsr.
#else
    std        %f0,    [%o1 + 0x00]    ! Save f0.
    std        %f2,    [%o1 + 0x08]    ! Save f2.
    std        %f4,    [%o1 + 0x10]    ! Save f4.
    std        %f6,    [%o1 + 0x18]    ! Save f6.
    std        %f8,    [%o1 + 0x20]    ! Save f8.
    std        %f10,   [%o1 + 0x28]    ! Save f10.
    std        %f12,   [%o1 + 0x30]    ! Save f12.
    std        %f14,   [%o1 + 0x38]    ! Save f14.
    st         %fsr,   [%o1 + 0x40]    ! Save fsr.
#endif
noext0:

    jmp        %o7 + 8
      mov      %g0,    %o0             ! Return 0.
.size ctx_mark, .-ctx_mark

! void __CTX_NORETURN
! ctx_jump(ctx_state *state, ctx_extra *extra, void *param);
.text
.globl ctx_jump
.align 4
.type ctx_jump, @function
ctx_jump:
    ld     OFFSET(%o0, 0),     %l0   ! Load l0.
    ld     OFFSET(%o0, 1),     %l1   ! Load l1.
    ld     OFFSET(%o0, 2),     %l2   ! Load l2.
    ld     OFFSET(%o0, 3),     %l3   ! Load l3.
    ld     OFFSET(%o0, 4),     %l4   ! Load l4.
    ld     OFFSET(%o0, 5),     %l5   ! Load l5.
    ld     OFFSET(%o0, 6),     %l6   ! Load l6.
    ld     OFFSET(%o0, 7),     %l7   ! Load l7.
    ld     OFFSET(%o0, 8),     %i0   ! Load i0.
    ld     OFFSET(%o0, 9),     %i1   ! Load i1.
    ld     OFFSET(%o0, 10),    %i2   ! Load i2.
    ld     OFFSET(%o0, 11),    %i3   ! Load i3.
    ld     OFFSET(%o0, 12),    %i4   ! Load i4.
    ld     OFFSET(%o0, 13),    %i5   ! Load i5.
    ld     OFFSET(%o0, 14),    %i6   ! Load i6.
    ld     OFFSET(%o0, 15),    %i7   ! Load i7.
    ld     OFFSET(%o0, 16),    %sp   ! Load sp.
    ld     OFFSET(%o0, 17),    %o7   ! Load o7.
    ld     OFFSET(%o0, 18),    %g1   ! Load g1.
    ld     OFFSET(%o0, 19),    %g2   ! Load g2.
    ld     OFFSET(%o0, 20),    %g3   ! Load g3.
    ld     OFFSET(%o0, 21),    %g6   ! Load g6.
    ld     OFFSET(%o0, 22),    %g7   ! Load g7.

    cmp    %o1,                0     ! Is extra NULL?
    bz     noext1
    nop
#ifdef CTX_64BIT
    ldda   [%o1]     0xf0,     %f0   ! Load f00-f15.
    add    %o1,      64,       %o1   ! Move to next block.
    ldda   [%o1]     0xf0,     %f16  ! Load f16-f31.
    add    %o1,      64,       %o1   ! Move to next block.
    ldda   [%o1]     0xf0,     %f32  ! Load f32-f47.
    add    %o1,      64,       %o1   ! Move to next block.
    ldda   [%o1]     0xf0,     %f48  ! Load f48-f63.
    add    %o1,      64,       %o1   ! Move to next block.
    ldx    [%o1 + 0x00],       %o3   ! Load fprs.
    ldx    [%o1 + 0x08],       %fsr  ! Load fsr.
    wr     %o3,          0,    %fprs ! Set fprs.
#else
    ldd    [%o1 + 0x00],       %f0   ! Load f0.
    ldd    [%o1 + 0x08],       %f2   ! Load f2.
    ldd    [%o1 + 0x10],       %f4   ! Load f4.
    ldd    [%o1 + 0x18],       %f6   ! Load f6.
    ldd    [%o1 + 0x20],       %f8   ! Load f8.
    ldd    [%o1 + 0x28],       %f10  ! Load f10.
    ldd    [%o1 + 0x30],       %f12  ! Load f12.
    ldd    [%o1 + 0x38],       %f14  ! Load f14.
    ld     [%o1 + 0x40],       %fsr  ! Load fsr.
#endif
noext1:

    ld     OFFSET(%o0, 23),    %o3   ! Load prm.
    cmp    %o3,                0     ! Is prm NULL?
    bz     noparam
    nop
    st     %o2,               [%o3]  ! Set the param.
noparam:

    ld     OFFSET(%o0, 24),    %o3   ! Load cnt.
    inc    %o3                       ! Increment cnt.
    st     %o3,    OFFSET(%o0, 24)   ! Save cnt.
    jmp    %o7 + 8                   ! Return.
      mov  %o3,                %o0   ! Return cnt.
.size ctx_jump, .-ctx_jump
