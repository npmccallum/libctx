/*
 * libctx - A cooperative multitasking library for C/C++
 *
 * Copyright 2013 Nathaniel McCallum <nathaniel@themccallums.org>
 *
 * Distributed under the Boost Software License, Version 1.0.
 */

#include "ctx.h"

#include <assert.h>
#include <stdio.h>

struct bundle {
  ctx_state state;
  ctx_extra extra;
};

static int i;

static int
addfunc(struct bundle *param)
{
  struct bundle bundle;

  if (ctx_mark(&bundle.state, &bundle.extra, &param) == 0)
    ctx_jump(&param->state, &param->extra, &bundle);

  while (1) {
	i++;
    if (ctx_mark(&bundle.state, &bundle.extra, &param) == 0)
      ctx_jump(&param->state, &param->extra, &bundle);
  }

  return 0;
}

static int
subfunc(struct bundle *param)
{
  struct bundle bundle;

  if (ctx_mark(&bundle.state, &bundle.extra, &param) == 0)
    ctx_jump(&param->state, &param->extra, &bundle);

  while (1) {
	i--;
    if (ctx_mark(&bundle.state, &bundle.extra, &param) == 0)
      ctx_jump(&param->state, &param->extra, &bundle);
  }

  return 0;
}

int
main(int argc, const char **argv)
{
  ctx_stack addstk = { NULL, 1 }, substk = { NULL, 1 };
  struct bundle bundle, *addbndl, *subbndl;

  assert(ctx_new(&addstk) == 0);
  assert(ctx_new(&substk) == 0);

  if (ctx_mark(&bundle.state, &bundle.extra, &addbndl) == 0)
    ctx_call(&bundle, addstk, addfunc);
  if (ctx_mark(&bundle.state, &bundle.extra, &subbndl) == 0)
    ctx_call(&bundle, substk, subfunc);

  if (ctx_mark(&bundle.state, &bundle.extra, &addbndl) == 0)
    ctx_jump(&addbndl->state, &addbndl->extra, &bundle);
  assert(i == 1);

  if (ctx_mark(&bundle.state, &bundle.extra, &addbndl) == 0)
    ctx_jump(&addbndl->state, &addbndl->extra, &bundle);
  assert(i == 2);

  if (ctx_mark(&bundle.state, &bundle.extra, &subbndl) == 0)
    ctx_jump(&subbndl->state, &subbndl->extra, &bundle);
  assert(i == 1);

  if (ctx_mark(&bundle.state, &bundle.extra, &addbndl) == 0)
    ctx_jump(&addbndl->state, &addbndl->extra, &bundle);
  assert(i == 2);

  if (ctx_mark(&bundle.state, &bundle.extra, &subbndl) == 0)
    ctx_jump(&subbndl->state, &subbndl->extra, &bundle);
  assert(i == 1);

  if (ctx_mark(&bundle.state, &bundle.extra, &subbndl) == 0)
    ctx_jump(&subbndl->state, &subbndl->extra, &bundle);
  assert(i == 0);

  /* Ensure:
   *   1. that multiple jumps can occur on a single save.
   *   2. proper behavior when the ctx_mark() param pointer is NULL. */
  while (ctx_mark(&bundle.state, &bundle.extra, NULL) < 3) {
    i++;
	ctx_jump(&bundle.state, &bundle.extra, &bundle);
  }
  assert(i == 3);

  ctx_free(addstk);
  ctx_free(substk);
  return 0;
}
