#
# libctx - A cooperative multitasking library for C/C++
#
# Copyright 2013 Nathaniel McCallum <nathaniel@themccallums.org>
# Portions Copyright 2009 Oliver Kowalke
#
# Distributed under the Boost Software License, Version 1.0.
#

# -----------------------------------------------------------------------
# | 0x00 | 0x08 | 0x10 | 0x18 | 0x20 | 0x28 | 0x30 | 0x38 | 0x40 | 0x48 |
# -----------------------------------------------------------------------
# |  r12 |  r13 |  r14 |  r15 |  rbx |  rbp |  rsp |  rip |  prm |  cnt |
# -----------------------------------------------------------------------
# Extended cpu state is stored via fxsave.

#if defined(_WIN32) || defined(_WIN64)
# define __NAME(name) _ ## name
# define __TYPE(name) .def _ ## name; .scl 2; .type 32; .endef
# define __ALIGN 16
# define __SIZE(name) .size __NAME(name),.-__NAME(name)
# define __EXIT _exit
#elif defined(__APPLE__)
# define __NAME(name) _ ## name
# define __TYPE(name)
# define __ALIGN 8
# define __SIZE(name)
# define __EXIT __exit
#else
# define __NAME(name) name
# define __TYPE(name) .type name, @function
# define __ALIGN 16
# define __SIZE(name) .size __NAME(name),.-__NAME(name)
# define __EXIT _exit@PLT
#endif

# void __CTX_NORETURN
# ctx_call(void *param, ctx_stack stack, int (*func)(void *param));
.text
.globl __NAME(ctx_call)
__TYPE(ctx_call)
.align __ALIGN
__NAME(ctx_call):
    mov    %rsi,   %rsp  # Set the new stack address.
    and    $-16,   %rsp  # Align the new stack.
    call  *%rcx          # Call the function.
    mov    %rax,   %rdi  # Set the argument
    call __EXIT
__SIZE(ctx_call)

# size_t
# ctx_mark(ctx_state *state, ctx_extra *extra, void **param);
.text
.globl __NAME(ctx_mark)
__TYPE(ctx_mark)
.align __ALIGN
__NAME(ctx_mark):
    pop    %rcx               # Pop the return pointer.

    mov    %r12,   0x00(%rdi) # Save r12.
    mov    %r13,   0x08(%rdi) # Save r13.
    mov    %r14,   0x10(%rdi) # Save r14.
    mov    %r15,   0x18(%rdi) # Save r15.
    mov    %rbx,   0x20(%rdi) # Save rbx.
    mov    %rbp,   0x28(%rdi) # Save rbp.
    mov    %rsp,   0x30(%rdi) # Save rsp.
    mov    %rcx,   0x38(%rdi) # Save rip.
    mov    %rdx,   0x40(%rdi) # Save prm.
    movq     $0,   0x48(%rdi) # Save cnt.

    cmp      $0,        %rsi  # Is extra NULL?
    je   noext0
    fxsave             (%rsi) # Do fxsave.
noext0:

    mov      $0,        %rax  # Return 0.
    jmp   *%rcx
__SIZE(ctx_mark)

# void __CTX_NORETURN
# ctx_jump(ctx_state *state, ctx_extra *extra, void *param);
.text
.globl __NAME(ctx_jump)
__TYPE(ctx_jump)
.align __ALIGN
__NAME(ctx_jump):
    cmp          $0,       %rsi  # Is extra NULL?
    je       noext1
    fxrstor               (%rsi) # Do fxrstor.
noext1:

    mov  0x00(%rdi),       %r12  # Load r12.
    mov  0x08(%rdi),       %r13  # Load r13.
    mov  0x10(%rdi),       %r14  # Load r14.
    mov  0x18(%rdi),       %r15  # Load r15.
    mov  0x20(%rdi),       %rbx  # Load rbx.
    mov  0x28(%rdi),       %rbp  # Load rbp.
    mov  0x30(%rdi),       %rsp  # Load rsp.
    mov  0x38(%rdi),       %rcx  # Load rip.
    mov  0x40(%rdi),       %rsi  # Load prm.
    mov  0x48(%rdi),       %rax  # Load cnt.

    cmp          $0,       %rsi  # Is prm NULL?
    je      noparam
    mov        %rdx,      (%rsi) # Set param.
noparam:

    inc        %rax              # Increment cnt.
    mov        %rax,  0x48(%rdi) # Save cnt.
    jmp       *%rcx              # Return cnt.
__SIZE(ctx_jump)
