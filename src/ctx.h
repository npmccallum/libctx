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
  unsigned char __opaque[512];
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
  unsigned char __opaque[512];
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

int
ctx_new(ctx_stack *stack);

void
ctx_free(ctx_stack stack);

void __CTX_NORETURN
ctx_call(void *param, ctx_stack stack, int (*func)(void *param));
#define ctx_call(p, s, f) ctx_call(p, s, (int (*)(void *)) f)

size_t
ctx_mark(ctx_state *state, ctx_extra *extra, void **param);
#define ctx_mark(s, f, p) ctx_mark(s, f, (void **) p)

void __CTX_NORETURN
ctx_jump(ctx_state *state, ctx_extra *extra, void *param);
