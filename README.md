unrubby
=======

Unrubby is a hacked up rubby interpreter. In addition to parsing and evaluating
rubby code, it will dump a decompiled copy of any bytecode evaluated to stdout
upon exiting.

Building
========

You'll want to configure with something akin to:

    ./configure --prefix=$(pwd) --disable-install-doc

There's a Makefile in the toplevel of unrubby that will likely do something
plausible looking for you, if you prefer.
