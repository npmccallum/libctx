//
// libctx - A cooperative multitasking library for C/C++
//
// Copyright 2013 Nathaniel McCallum <nathaniel@themccallums.org>
// Portions Copyright 2009 Oliver Kowalke
//
// Distributed under the Boost Software License, Version 1.0.
//

// ---------------------------------------------------------
// |                       ctx_state                       |
// ---------------------------------------------------------
// | 0x00 | 0x08 | 0x10 | 0x18 | 0x20 | 0x28 | 0x30 | 0x38 |
// ---------------------------------------------------------
// |  x18 |  x19 |  x20 |  x21 |  x22 |  x23 |  x24 |  x25 |
// ---------------------------------------------------------
// | 0x40 | 0x48 | 0x50 | 0x58 | 0x60 | 0x68 | 0x70 | 0x78 |
// ---------------------------------------------------------
// |  x26 |  x27 |  x28 |  x29 |  x30 |  sp  |  cnt |  prm |
// ---------------------------------------------------------
//
// ---------------------------------------------------------
// |                       ctx_extra                       |
// ---------------------------------------------------------
// | 0x00 | 0x04 | 0x08 | 0x0c | 0x10 | 0x14 | 0x18 | 0x1c |
// ---------------------------------------------------------
// |  d8  |  d9  |  d10 |  d11 |  d12 |  d13 |  d14 |  d15 |
// ---------------------------------------------------------

#if defined(__APPLE__)
# define NAME(name) _ ## name
# define TYPE(name)
# define SIZE(name)
# define EXIT EXIT
#else
# define NAME(name) name
# define TYPE(name) .type name, %function
# define SIZE(name) .size NAME(name), .-NAME(name)
# define EXIT exit
#endif

// void __CTX_NORETURN
// ctx_call(void *param, ctx_stack stack, int (*func)(void *param));
.text
.globl NAME(ctx_call)
TYPE(ctx_call)
.align 2
NAME(ctx_call):
    bic        sp,     x1,     #15           // Set the new, aligned stack.
    blr        x3                            // Call the function.
    b          EXIT                          // Exit (argument implicit)
SIZE(ctx_call)

// size_t
// ctx_mark(ctx_state *state, ctx_extra *extra, void **param);
.text
.globl NAME(ctx_mark)
TYPE(ctx_mark)
.align 2
NAME(ctx_mark):
    cbz        x1,     noextra0              // Is extra NULL?
    stp        d8,     d9,     [x1, 0x00]    // Save FP registers.
    stp        d10,    d11,    [x1, 0x10]    // Save FP registers.
    stp        d12,    d13,    [x1, 0x20]    // Save FP registers.
    stp        d14,    d15,    [x1, 0x30]    // Save FP registers.

noextra0:
    mov        x4,     sp                    // Get SP for later storage.
    mov        x1,     x0                    // Move state to a free register.
    mov        x0,     #0                    // Set cnt (x1) = 0 / return value.
    stp        x18,    x19,    [x1, 0x00]    // Save registers.
    stp        x20,    x21,    [x1, 0x10]    // Save registers.
    stp        x22,    x23,    [x1, 0x20]    // Save registers.
    stp        x24,    x25,    [x1, 0x30]    // Save registers.
    stp        x26,    x27,    [x1, 0x40]    // Save registers.
    stp        x28,    x29,    [x1, 0x50]    // Save registers.
    stp        x30,    x4,     [x1, 0x60]    // Save registers.
    stp        x0,     x2,     [x1, 0x70]    // Save cnt and param.

    ret                                      // Return 0.
SIZE(ctx_mark)

// void __CTX_NORETURN
// ctx_jump(ctx_state *state, ctx_extra *extra, void *param);
.text
.globl NAME(ctx_jump)
TYPE(ctx_jump)
.align 2
NAME(ctx_jump):
    cbz        x1,     noextra1              // Is extra NULL?
    ldp        d8,     d9,     [x1, 0x00]    // Load FP registers.
    ldp        d10,    d11,    [x1, 0x10]    // Load FP registers.
    ldp        d12,    d13,    [x1, 0x20]    // Load FP registers.
    ldp        d14,    d15,    [x1, 0x30]    // Load FP registers.

noextra1:
    mov        x1,     x0                    // Move state to a free register.
    ldp        x18,    x19,    [x1, 0x00]    // Load registers.
    ldp        x20,    x21,    [x1, 0x10]    // Load registers.
    ldp        x22,    x23,    [x1, 0x20]    // Load registers.
    ldp        x24,    x25,    [x1, 0x30]    // Load registers.
    ldp        x26,    x27,    [x1, 0x40]    // Load registers.
    ldp        x28,    x29,    [x1, 0x50]    // Load registers.
    ldp        x30,    x4,     [x1, 0x60]    // Load registers.
    ldp        x0,     x3,     [x1, 0x70]    // Load cnt and param (cnt is returned).
    add        x0,     x0,     #1            // Increment cnt.
    str        x0,     [x1, 0x70]            // Store cnt.
    mov        sp,     x4                    // Set the stack pointer.

    cbz        x3,     noparam               // Is param NULL?
    str        x2,     [x3]                  // Save the param.

noparam:
    ret                                      // Return cnt (implicit).
SIZE(ctx_jump)
