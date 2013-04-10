#
# libctx - A cooperative multitasking library for C/C++
#
# Copyright 2013 Nathaniel McCallum <nathaniel@themccallums.org>
# Portions Copyright 2009 Oliver Kowalke
#
# Distributed under the Boost Software License, Version 1.0.
#

# ---------------------------------------------------------
# | 0x00 | 0x04 | 0x08 | 0x0c | 0x10 | 0x14 | 0x18 | 0x1c |
# ---------------------------------------------------------
# |  edi |  esi |  ebx |  ebp |  esp |  eip |  prm |  cnt |
# ---------------------------------------------------------
# Extended cpu state is stored via fxsave.

#if defined(_WIN32)
# define NAME(name) _ ## name
# define TYPE(name) .def _ ## name; .scl 2; .type 32; .endef
# define ALIGN 16
# define SIZE(name) .size NAME(name), .-NAME(name)
# define EXIT _exit
#elif defined(__APPLE__)
# define NAME(name) _ ## name
# define TYPE(name)
# define ALIGN 8
# define SIZE(name)
# define EXIT EXIT
#else
# define NAME(name) name
# define TYPE(name) .type name, @function
# define ALIGN 16
# define SIZE(name) .size NAME(name), .-NAME(name)
# define EXIT _exit@PLT
#endif

# void __CTX_NORETURN
# ctx_call(void *param, ctx_stack stack, int (*func)(void *param));
.text
.globl NAME(ctx_call)
TYPE(ctx_call)
.align ALIGN
NAME(ctx_call):
    mov   0x04(%esp),        %eax  # Get param.
    mov   0x10(%esp),        %ecx  # Get func.

    mov   0x08(%esp),        %esp  # Get stack.
    and        $-16,         %esp  # Align the new stack.

    add        $-16,         %esp  # Push stack with alignment for argument.
    mov        %eax,        (%esp) # Set the argument
    call      *%ecx                # Call the function.

    mov        %eax,        (%esp) # Set the argument
    call       EXIT                # Exit
SIZE(ctx_call)

# size_t
# ctx_mark(ctx_state *state, ctx_extra *extra, void **param);
.text
.globl NAME(ctx_mark)
TYPE(ctx_mark)
.align ALIGN
NAME(ctx_mark):
    pop        %edx                # Pop the return pointer.

    mov   0x00(%esp),        %eax  # Get state.
    mov   0x08(%esp),        %ecx  # Get param.
    mov        %edi,    0x00(%eax) # Save edi.
    mov        %esi,    0x04(%eax) # Save esi.
    mov        %ebx,    0x08(%eax) # Save ebx.
    mov        %ebp,    0x0c(%eax) # Save ebp.
    mov        %esp,    0x10(%eax) # Save esp.
    mov        %edx,    0x14(%eax) # Save eip.
    mov        %ecx,    0x18(%eax) # Save prm.
    movl         $0,    0x1c(%eax) # Save cnt.

    cmp          $0,    0x04(%esp) # Is extra NULL?
    je       noext0
    mov   0x04(%esp),        %eax  # Get extra.
    fxsave                  (%eax) # Do fxsave.
noext0:

    mov          $0,         %eax  # Return 0
    jmp       *%edx
SIZE(ctx_mark)

# void __CTX_NORETURN
# ctx_jump(ctx_state *state, ctx_extra *extra, void *param);
.text
.globl NAME(ctx_jump)
TYPE(ctx_jump)
.align ALIGN
NAME(ctx_jump):
    mov   0x04(%esp),        %ecx  # Get state.

    cmp           $0,   0x08(%esp) # Is extra NULL?
    je        noext1
    mov   0x08(%esp),        %eax  # Get extra.
    fxrstor                 (%eax) # Do fxrstor.
noext1:

    cmp        $0,      0x18(%ecx) # Is param pointer NULL?
    je         noparam
    mov   0x18(%ecx),        %eax  # Get param pointer.
    mov   0x0c(%esp),        %edx  # Get param.
    mov        %edx,        (%eax) # Set param.
    mov        $0,           %eax  # Return false (if skipped, implicit).
noparam:

    mov   0x00(%ecx),        %edi  # Load edi.
    mov   0x04(%ecx),        %esi  # Load esi.
    mov   0x08(%ecx),        %ebx  # Load ebx.
    mov   0x0c(%ecx),        %ebp  # Load ebp.
    mov   0x10(%ecx),        %esp  # Load esp.
    mov   0x14(%ecx),        %edx  # Load eip.
    mov   0x1c(%ecx),        %eax  # Load cnt.

    inc        %eax                # Increment cnt.
    mov        %eax,    0x1c(%ecx) # Save cnt.
    jmp       *%edx                # Return cnt.
SIZE(ctx_jump)
