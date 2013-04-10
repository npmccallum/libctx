@
@ libctx - A cooperative multitasking library for C/C++
@
@ Copyright 2013 Nathaniel McCallum <nathaniel@themccallums.org>
@ Portions Copyright 2009 Oliver Kowalke
@
@ Distributed under the Boost Software License, Version 1.0.
@

@ ---------------------------------------------------------
@ |                       ctx_state                       |
@ ---------------------------------------------------------
@ | 0x00 | 0x04 | 0x08 | 0x0c | 0x10 | 0x14 | 0x18 | 0x1c |
@ ---------------------------------------------------------
@ |  cnt |  prm |  v1  |  v2  |  v3  |  v4  |  v5  |  v6  |
@ ---------------------------------------------------------
@ | 0x20 | 0x24 | 0x28 | 0x2c |                           |
@ ---------------------------------------------------------
@ |  v7  |  v8  |  sp  |  lr  |      |      |      |      |
@ ---------------------------------------------------------
@
@ ---------------------------------------------------------
@ |                       ctx_extra                       |
@ ---------------------------------------------------------
@ | 0x00 | 0x04 | 0x08 | 0x0c | 0x10 | 0x14 | 0x18 | 0x1c |
@ ---------------------------------------------------------
@ |  s16 |  s17 |  s18 |  s19 |  s20 |  s21 |  s22 |  s23 |
@ ---------------------------------------------------------
@ ---------------------------------------------------------
@ | 0x20 | 0x24 | 0x28 | 0x2c | 0x30 | 0x34 | 0x38 | 0x3c |
@ ---------------------------------------------------------
@ |  s24 |  s25 |  s26 |  s27 |  s28 |  s29 |  s30 |  s31 |
@ ---------------------------------------------------------

#if defined(__APPLE__)
# define NAME(name) _ ## name
# define TYPE(name)
# define SIZE(name)
# define EXIT EXIT
#else
# define NAME(name) name
# define TYPE(name) .type name, %function
# define SIZE(name) .size NAME(name), .-NAME(name)
# define EXIT _exit@PLT
#endif

@ void __CTX_NORETURN
@ ctx_call(void *param, ctx_stack stack, int (*func)(void *param));
.text
.globl NAME(ctx_call)
TYPE(ctx_call)
.align 2
NAME(ctx_call):
    bic        sp,     a2,     #15           @ Set the new, aligned stack.
#if defined(__ARM_ARCH_4__) || defined(__ARM_ARCH_4T__)
    mov        lr,     pc                    @ Link for the return jump.
    bx         a4                            @ Call the function.
#else
    blx        a4                            @ Call the function.
#endif
    b          EXIT                          @ Exit (argument implicit)
SIZE(ctx_call)

@ size_t
@ ctx_mark(ctx_state *state, ctx_extra *extra, void **param);
.text
.globl NAME(ctx_mark)
TYPE(ctx_mark)
.align 2
NAME(ctx_mark):
#if (defined(__VFP_FP__) && !defined(__SOFTFP__))
    cmp        a2,     #0                    @ Is extra NULL?
    vstmiane   a2,    {d8-d15}               @ Save FP registers.
#endif

    mov        a2,     a1                    @ Move state to a free register.
    mov        a1,     #0                    @ Set the return value and cnt.
    stmia      a2,    {a1, a3, v1-v8, sp-lr} @ Save cnt, param and GP regs.

    bx         lr                            @ Return 0.
SIZE(ctx_mark)

@ void __CTX_NORETURN
@ ctx_jump(ctx_state *state, ctx_extra *extra, void *param);
.text
.globl NAME(ctx_jump)
TYPE(ctx_jump)
.align 2
NAME(ctx_jump):
#if (defined(__VFP_FP__) && !defined(__SOFTFP__))
    cmp        a2,     #0                    @ Is extra NULL?
    vldmiane   a2,    {d8-d15}               @ Load FP registers.
#endif

    mov        a4,     a1                    @ Move state to a free register.
    ldmia      a4,    {a1, a2, v1-v8, sp-lr} @ Load cnt, param and GP regs.
    add        a1,     a1,     #1            @ Increment cnt.
    str        a1,    [a4]                   @ Store cnt.

    cmp        a2,     #0                    @ Is param NULL?
    strne      a3,    [a2]                   @ Conditionally save the param.

    bx         lr                            @ Return cnt (implicit).
SIZE(ctx_jump)
