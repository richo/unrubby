/**********************************************************************

  main.c -

  $Author$
  created at: Fri Aug 19 13:19:58 JST 1994

  Copyright (C) 1993-2007 Yukihiro Matsumoto

**********************************************************************/

#undef RUBY_EXPORT
#include "ruby.h"
#include "debug.h"
#ifdef HAVE_LOCALE_H
#include <locale.h>
#endif
#ifdef RUBY_DEBUG_ENV
#include <stdlib.h>
#endif

#define UNRUBBY "unrubby"

RUBY_GLOBAL_SETUP

int rubby = 0;

int
main(int argc, char **argv)
{
#ifdef RUBY_DEBUG_ENV
    ruby_set_debug_option(getenv("RUBY_DEBUG"));
#endif
#ifdef HAVE_LOCALE_H
    setlocale(LC_CTYPE, "");
#endif
    char* unrubby = strrchr(argv[0], '/');
    if (unrubby) {
      if (strcmp(++unrubby, UNRUBBY) == 0) {
        rubby = 1;
      }
    }

    ruby_sysinit(&argc, &argv);
    {
	RUBY_INIT_STACK;
	ruby_init();
	return ruby_run_node(ruby_options(argc, argv));
    }
}
