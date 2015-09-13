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

Usage
=====

In short, just invoke `bin/unrubby` instead of ruby. You almost certainly want to

    export UNRUBBY_METHODS=1

Which will invoke the method disasembler, which is definitely what you want
unless you just want a classmap.

Experimental support for disasembling entire ISeq's is hidden behind
`UNRUBBY_FULL_ISEQ`.

Sockets
=======

If you really don't want whatever it is you're poking to talk to the network;

    export UNRUBBY_SOCKET_HACK=1

This won't protect you from shared objects knowing how to `socket(3)`, raw
syscalls, etc. It's also a pretty blunt hammer, but defining a `Socket` with
some method_missing glue won't be too hard.
