#include "ruby.h"

VALUE dbg;

void Init_dbg();

VALUE breakpoint(VALUE self);

void Init_dbg() {
	dbg = rb_define_module("DBG");
	rb_define_singleton_method(dbg, "breakpoint", breakpoint, 0);
}

VALUE breakpoint(VALUE klass) {
	__asm__("int3");
    return Qnil;
}
