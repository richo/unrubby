/**********************************************************************

  main.c -

  $Author$
  created at: Fri Aug 19 13:19:58 JST 1994

  Copyright (C) 1993-2007 Yukihiro Matsumoto

**********************************************************************/
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <errno.h>

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

static int require_reversal(const char* exe) {
  char path[1048];
  memset(path, 1048, 0);
  if (strlen(exe) > 1000) {
    return 1;
  }
  char* tmp = strdup(exe);
  strcpy(path, dirname(tmp));
  strcat(path, "/../reversal/lib/reversal.rb");

  struct stat sb;

  if (stat(path, &sb) == -1) {
    if (errno == ENOENT) {
      fprintf(stderr, "[!] Couldn't find reversal at %s, continuing\n");
      return 1;
    } else {
      perror("[!] stat");
      exit(1);
    }
  }


  rb_require(path);
  free(tmp);
  return 0;
}

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
    if (rubby) {
      require_reversal(argv[0]);
    }
	return ruby_run_node(ruby_options(argc, argv));
    }
}
