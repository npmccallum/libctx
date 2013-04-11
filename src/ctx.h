/*
 * libctx - A cooperative multitasking library for C/C++
 *
 * Copyright 2013 Nathaniel McCallum <nathaniel@themccallums.org>
 * Portions Copyright 2009 Oliver Kowalke
 *
 * Distributed under the Boost Software License, Version 1.0.
 */

#pragma once

#include <errno.h>
#include <stdint.h>
#include <stddef.h>

#ifdef _MSC_VER
#define __CTX_ALIGN(x) __declspec(align(x))
#define __CTX_NORETURN __declspec(noreturn)
#else
#define __CTX_ALIGN(x) __attribute__((aligned(x)))
#define __CTX_NORETURN __attribute__((noreturn))
#endif

typedef struct ctx_stack ctx_stack;
typedef struct ctx_state ctx_state;
typedef struct ctx_extra ctx_extra;

#pragma pack(0)
#if defined(__amd64__) || defined(__amd64) || \
    defined(__x86_64__) || defined(__x86_64) || \
    defined(_M_X64) || defined(_M_AMD64)
struct ctx_state {
  uintptr_t __opaque[10];
};

struct ctx_extra {
  uint8_t __opaque[512];
} __CTX_ALIGN(16);

#elif defined(i386) || defined(__i386) || defined(__i386__) || \
      defined(__i486__) || defined(__i586__) || defined(__i686__) || \
      defined(__IA32__) || defined(_M_IX86) || defined(__X86__) || \
      defined(_X86_) || defined(__THW_INTEL__) || defined(__I86__)  || \
      defined(__INTEL__)
struct ctx_state {
  uintptr_t __opaque[8];
};

struct ctx_extra {
  uint8_t __opaque[512];
} __CTX_ALIGN(16);

#elif defined(__arm__) || defined(__thumb__) || defined(__TARGET_ARCH_ARM) || \
      defined(__TARGET_ARCH_THUMB) || defined(_ARM) || defined(_M_ARM) || \
      defined(_M_ARMT)
struct ctx_state {
  uintptr_t __opaque[12];
};

struct ctx_extra {
  uintptr_t __opaque[16];
};

#elif defined(__mips__) || defined(mips) || defined(__mips) || defined(__MIPS__)
struct ctx_state {
  uintptr_t __opaque[13];
};

struct ctx_extra {
  uintptr_t __opaque[12];
};

#elif defined(__powerpc) || defined(__powerpc__) || defined(__POWERPC__) || \
      defined(__ppc__) || defined(_M_PPC) || defined(_ARCH_PPC)
struct ctx_state {
  uintptr_t __opaque[24];
};

struct ctx_extra {
  uint64_t __opaque[19];
};

#elif defined(__sparc__) || defined(__sparc) || defined(sparc)
struct ctx_state {
  uintptr_t __opaque[25];
};

# if defined(__sparc64__) || defined(_LP64) || defined(__LP64__)
  struct ctx_extra {
    uintptr_t __opaque[34];
  } __CTX_ALIGN(64);
# else
  struct ctx_extra {
    uintptr_t __opaque[17];
  } __CTX_ALIGN(8);
# endif

#else
#error Architecture not supported!
#endif
#pragma pack()
#undef __CTX_ALIGN

struct ctx_stack {
  void *stack;
  size_t size;
};

/* Allocate a new stack with guard page.
 *
 * The desired size is specified in the ctx_stack.size field. If
 * ctx_stack.size == 0, a default stack size is used. This stack size should
 * be estimated to be sufficient for "small" functions. If ctx_stack.size is
 * less than an internal minimum stack size, it will be silently upgraded. This
 * minimum stack size should be understood to be sufficient for "extra small"
 * functions.
 *
 * Returns 0 on success and errno on error.
 *
 * NOTE: You do not have to use this function. If you'd prefer to write your
 * own stack allocator, you are welcome to.
 */
int
ctx_new(ctx_stack *stack);

/* Free a stack allocated by ctx_new(). */
void
ctx_free(ctx_stack stack);

/* Call a function on a new stack.
 *
 * The function specified will be called with the given parameter and will
 * execute on the given stack. Once a set of functions are executing in
 * independent stacks, you can safely jump between them via ctx_mark() and
 * ctx_jump().
 *
 * If the executed function returns, the return value will be passed to _exit()
 * and the process will terminate.
 *
 * This function does not return.
 */
void __CTX_NORETURN
ctx_call(void *param, ctx_stack stack, int (*func)(void *param));
#define ctx_call(p, s, f) ctx_call(p, s, (int (*)(void *)) f)

/* Mark a point for a later jump via ctx_jump().
 *
 * Calling this function stores the current processor state in state. If extra
 * is not NULL, extended processor state (including floating point) will be
 * stored. Once this state is obtained, it may be jumped to via ctx_jump().
 * This state is reentrant (if your code is!), so you may call ctx_jump()
 * multiple times on a single saved state.
 *
 * If param is not NULL, it will contain the param argument from a ctx_jump()
 * invocation. On the first return (i.e. before any calls to ctx_jump()), param
 * will be unmodified.
 *
 * This function returns the number of times ctx_jump() has been called on the
 * processor state.
 */
size_t
ctx_mark(ctx_state *state, ctx_extra *extra, void **param);
#define ctx_mark(s, f, p) ctx_mark(s, f, (void **) p)

/* Jump to a previously saved state.
 *
 * If extra is not NULL, extended processor state (including floating point)
 * will be restored as well. If the param argument of ctx_mark() is not NULL,
 * the param argument to ctx_jump() will be stored in the aforementioned
 * pointer. Execution will resume as if ctx_mark() returned normally except the
 * return value will be incremented.
 *
 * This function does not return.
 */
void __CTX_NORETURN
ctx_jump(ctx_state *state, ctx_extra *extra, void *param);
