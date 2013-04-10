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
# | 0x00 | 0x04 | 0x08 | 0x0c | 0x10 | 0x14 | 0x18 | 0x1c |
# ---------------------------------------------------------
# |  s0  |  s1  |  s2  |  s3  |  s4  |  s5  |  s6  |  s7  |
# ---------------------------------------------------------
# ---------------------------------------------------------
# | 0x20 | 0x24 | 0x28 | 0x2c | 0x30 | 0x34 | 0x38 | 0x3c |
# ---------------------------------------------------------
# |  fp  |  sp  |  ra  |  prm |  cnt |                    |
# ---------------------------------------------------------

# ---------------------------------------------------------
# |                       ctx_extra                       |
# ---------------------------------------------------------
# | 0x00 | 0x04 | 0x08 | 0x0c | 0x10 | 0x14 | 0x18 | 0x1c |
# ---------------------------------------------------------
# |   f20-f21   |   f22-f23   |   f24-f25   |   f26-f27   |
# ---------------------------------------------------------
# ---------------------------------------------------------
# | 0x20 | 0x24 | 0x28 | 0x2c |                           |
# ---------------------------------------------------------
# |   f28-f29   |   f30-f31   |                           |
# ---------------------------------------------------------

# void __CTX_NORETURN
# ctx_call(void *param, ctx_stack stack, int (*func)(void *param));
.text
.globl ctx_call
.type ctx_call, @function
.align 2
.ent ctx_call
ctx_call:
    li         $t0,    -16
    and        $t0,    $a1,    $t0         # Align stack.

    addiu      $sp,    $t0,    -32         # Push stack (incl. shadow space).
    sw         $gp,    28($sp)             # Save $gp for later recall.

    move       $t9,    $a3                 # Move func into $t9.
    jalr       $t9                         # Call func.

    lw         $gp,    28($sp)             # Get $gp.
    lw         $t9,    %call16(_exit)($gp) # Get function address.
    move       $a0,    $v0                 # Return value => argument.
    jalr       $t9                         # Call _exit().
.end ctx_call
.size ctx_call, .-ctx_call

# size_t
# ctx_mark(ctx_state *state, ctx_extra *extra, void **param);
.text
.globl ctx_mark
.type ctx_mark, @function
.align 2
.ent ctx_mark
ctx_mark:
    sw         $s0,    0x00($a0)    # Save s0.
    sw         $s1,    0x04($a0)    # Save s1.
    sw         $s2,    0x08($a0)    # Save s2.
    sw         $s3,    0x0c($a0)    # Save s3.
    sw         $s4,    0x10($a0)    # Save s4.
    sw         $s5,    0x14($a0)    # Save s5.
    sw         $s6,    0x18($a0)    # Save s6.
    sw         $s7,    0x1c($a0)    # Save s7.
    sw         $fp,    0x20($a0)    # Save fp.
    sw         $sp,    0x24($a0)    # Save sp.
    sw         $ra,    0x28($a0)    # Save ra.
    sw         $a2,    0x2c($a0)    # Save prm.
    sw         $zero,  0x30($a0)    # Save cnt.

#if defined(__mips_hard_float)
    beqz       $a1,    noext0       # Is extra NULL?
    s.d        $f20,   0x00($a1)    # Save f20-f21.
    s.d        $f22,   0x08($a1)    # Save f22-f23.
    s.d        $f24,   0x10($a1)    # Save f24-f25.
    s.d        $f26,   0x18($a1)    # Save f26-f27.
    s.d        $f28,   0x20($a1)    # Save f28-f29.
    s.d        $f30,   0x28($a1)    # Save f30-f31.
noext0:
#endif

    move       $v0,    $zero        # Return 0.
    jr         $ra
.end ctx_mark
.size ctx_mark, .-ctx_mark

# void __CTX_NORETURN
# ctx_jump(ctx_state *state, ctx_extra *extra, void *param);
.text
.globl ctx_jump
.type ctx_jump, @function
.align 2
.ent ctx_jump
ctx_jump:
    lw         $s0,    0x00($a0)    # Load s0.
    lw         $s1,    0x04($a0)    # Load s1.
    lw         $s2,    0x08($a0)    # Load s2.
    lw         $s3,    0x0c($a0)    # Load s3.
    lw         $s4,    0x10($a0)    # Load s4.
    lw         $s5,    0x14($a0)    # Load s5.
    lw         $s6,    0x18($a0)    # Load s6.
    lw         $s7,    0x1c($a0)    # Load s7.
    lw         $fp,    0x20($a0)    # Load fp.
    lw         $sp,    0x24($a0)    # Load sp.
    lw         $ra,    0x28($a0)    # Load ra.

#if defined(__mips_hard_float)
    beqz       $a1,    noext1       # Is extra NULL?
    l.d        $f20,   0x00($a1)    # Load f20-f21.
    l.d        $f22,   0x08($a1)    # Load f22-f23.
    l.d        $f24,   0x10($a1)    # Load f24-f25.
    l.d        $f26,   0x18($a1)    # Load f26-f27.
    l.d        $f28,   0x20($a1)    # Load f28-f29.
    l.d        $f30,   0x28($a1)    # Load f30-f31.
noext1:
#endif

    lw         $t0,    0x2c($a0)    # Load param.
    beqz       $t0,    noparam      # Skip param on NULL.
    sw         $a2,    ($t0)        # Set param.
noparam:

    lw         $v0,    0x30($a0)    # Load cnt.
    addiu      $v0,    $v0,    1    # Increment cnt.
    sw         $v0,    0x30($a0)    # Save cnt.
    jr         $ra                  # Return cnt.
.end ctx_jump
.size ctx_jump, .-ctx_jump
