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

When invoked as `unrubby`, unrubby will attempt to automatically load its
paired copy of reversal, but if you have moved things around, simply passing

    unrubby -r path/to/bundled/reversal/lib/reversal.rb

Should give you the disasembler you need.

If you want to suppress the automatic load (Because, eg, you want to require
dependencies for the application without dissembling them and making your dump
horrendously huge):

    export UNRUBBY_DEFER_REVERSAL=1

Sockets
=======

If you really don't want whatever it is you're poking to talk to the network;

    export UNRUBBY_SOCKET_HACK=1

This won't protect you from shared objects knowing how to `socket(3)`, raw
syscalls, etc. It's also a pretty blunt hammer, but defining a `Socket` with
some method_missing glue won't be too hard.

Stubs
=====

There's a stub that will bring up most of a rails app in `etc`. Additionally, if you

    export UNRUBBY_STUBS=1

It will duck punch `Object` right in the face and make most any attempts to
poke at other classes succeed. Note that this will break attempts to include or
extend modules, you will need to define them yourself.

Reporting Bugs
==============

unrubby isn't perfect, and probably has a lot of lowhanging fruit right now. If you run into crashes (`InternalDecompilerError`s), there's a reporting mode that'll cough up enough information for me to probably fix it. It's documented in more detail in [reporting bugs][REPORTING_BUGS]

[REPORTING_BUGS]: REPORTING_BUGS.md
