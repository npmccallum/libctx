/*
 * libctx - A cooperative multitasking library for C/C++
 *
 * Copyright 2013 Nathaniel McCallum <nathaniel@themccallums.org>
 * Portions Copyright 2009 Oliver Kowalke
 *
 * Distributed under the Boost Software License, Version 1.0.
 */

#include "ctx.h"

#include <assert.h>
#include <errno.h>
#include <signal.h>

#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>
#include <sys/resource.h>

#define PROT_RW (PROT_READ | PROT_WRITE)
#if defined(MAP_ANON)
# define FLAGS (MAP_PRIVATE | MAP_ANON)
#elif defined (MAP_ANONYMOUS)
# define FLAGS (MAP_PRIVATE | MAP_ANONYMOUS)
#else
# define FLAGS (MAP_PRIVATE)
#endif

#if !defined(MINSIGSTKSZ)
# define MINSIGSTKSZ (8 * 1024)
#endif

#if !defined(SIGSTKSZ)
# define SIGSTKSZ (32 * 1024)
#endif

static inline long
pagesize(void)
{
  static long ps = 0;

  if (ps == 0)
    assert((ps = sysconf(_SC_PAGESIZE)) > 0);

  return ps;
}

static inline struct rlimit
limit(void)
{
  static struct rlimit limit = { 0, 0 };

  if (limit.rlim_cur == 0 && limit.rlim_max == 0)
    assert(getrlimit(RLIMIT_STACK, &limit) == 0);

  return limit;
}

int
ctx_new(ctx_stack *stack)
{
  int err, fd = -1;
  unsigned char *tmp;

  if (stack == NULL)
    return EINVAL;

  if (stack->size == 0)
    stack->size = SIGSTKSZ;

  if (stack->size < MINSIGSTKSZ)
    stack->size = MINSIGSTKSZ;

  stack->size += pagesize() * 2 - 1; /* Add a guard page. */
  stack->size = stack->size / pagesize() * pagesize(); /* Round off. */

  if (limit().rlim_max != RLIM_INFINITY && limit().rlim_max < stack->size)
    return E2BIG;

#if !defined(MAP_ANON) && !defined(MAP_ANONYMOUS)
  fd = open("/dev/zero", O_RDONLY);
  if (fd < 0)
    return errno;
#endif

  tmp = mmap(NULL, stack->size, PROT_RW, FLAGS, fd, 0);
  err = errno;
  if (fd >= 0)
    close(fd);
  if (tmp == NULL)
    return err;

  if (mprotect(tmp, pagesize(), PROT_NONE) != 0) {
    munmap(tmp, stack->size);
    return errno;
  }

  stack->stack = tmp + stack->size;
  stack->size -= pagesize();
  return 0;
}

void
ctx_free(ctx_stack stack)
{
  if (stack.stack == NULL || stack.size == 0)
	return;

  stack.size += pagesize();
  munmap(((unsigned char*) stack.stack) - stack.size, stack.size);
}
