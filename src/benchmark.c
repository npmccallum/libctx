/*
 * libctx - A cooperative multitasking library for C/C++
 *
 * Copyright 2013 Nathaniel McCallum <nathaniel@themccallums.org>
 *
 * Distributed under the Boost Software License, Version 1.0.
 */

#include <ctx.h>

#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <assert.h>
#include <string.h>

#define ITERATIONS 25000

#define RFMT "%8s: %d.%06u\n"
#define FMT "%s-" RFMT
#define DIFF(one, two) ((one > two) ? (one - two) : (two - one))
#define SECONDS(stv, etv) ((unsigned int) (etv.tv_sec - stv.tv_sec - \
	                   ((stv.tv_usec > etv.tv_usec) ? 1 : 0)))
#define USECONDS(stv, etv) ((unsigned int) DIFF(etv.tv_usec, stv.tv_usec))
#define TIME(stv, etv) SECONDS(stv, etv), USECONDS(stv, etv)

struct bundle {
  ctx_state state;
  ctx_extra extra;
};

static volatile uintptr_t j;

static int
test_return(void *param)
{
  ++j;
  return 0;
}

static int
test_noext(void *param)
{
  ctx_state state;

  while (1) {
    ++j;
    if (ctx_mark(&state, NULL, &param) == 0)
      ctx_jump(param, NULL, &state);
  }

  return 0;
}

static int
test_ext(void *param)
{
  struct bundle bundle;

  while (1) {
    ++j;
    if (ctx_mark(&bundle.state, &bundle.extra, &param) == 0)
      ctx_jump(&((struct bundle *) param)->state,
               &((struct bundle *) param)->extra, &bundle);
  }

  return 0;
}

int
main(int argc, char **argv)
{
  struct timeval stv, etv;
  struct bundle bundle, *rbundle;
  ctx_state *rstate;
  ctx_stack stk;

  stk.size = 1;
  assert(ctx_new(&stk) == 0);

  gettimeofday(&stv, NULL);
  for (j = 0; j < ITERATIONS; )
    test_return(NULL);
  gettimeofday(&etv, NULL);
  printf(RFMT, "return", TIME(stv, etv));

  gettimeofday(&stv, NULL);
  for (j = 0; ctx_mark(&bundle.state, NULL, &rstate) < ITERATIONS; ) {
    if (j == 0)
      ctx_call(&bundle.state, stk, test_noext);
    else
      ctx_jump(rstate, NULL, &bundle.state);
  }
  gettimeofday(&etv, NULL);
  printf(RFMT, "noexts", TIME(stv, etv));

  gettimeofday(&stv, NULL);
  for (j = 0; j < ITERATIONS; ) {
    if (ctx_mark(&bundle.state, NULL, &rstate) == 0) {
      if (j == 0)
        ctx_call(&bundle.state, stk, test_noext);
      else
        ctx_jump(rstate, NULL, &bundle.state);
    }
  }
  gettimeofday(&etv, NULL);
  printf(RFMT, "noextd", TIME(stv, etv));

  gettimeofday(&stv, NULL);
  for (j = 0; ctx_mark(&bundle.state, &bundle.extra, &rbundle) < ITERATIONS; ) {
    if (j == 0)
      ctx_call(&bundle, stk, test_ext);
    else
      ctx_jump(&rbundle->state, &rbundle->extra, &bundle);
  }
  gettimeofday(&etv, NULL);
  printf(RFMT, "exts", TIME(stv, etv));

  gettimeofday(&stv, NULL);
  for (j = 0; j < ITERATIONS; ) {
    if (ctx_mark(&bundle.state, &bundle.extra, &rbundle) == 0) {
      if (j == 0)
        ctx_call(&bundle, stk, test_ext);
      else
        ctx_jump(&rbundle->state, &rbundle->extra, &bundle);
    }
  }
  gettimeofday(&etv, NULL);
  printf(RFMT, "extd", TIME(stv, etv));

  ctx_free(stk);
  return 0;
}
