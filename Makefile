CONFIGURE_ARGS ?= --prefix=$(PWD) --disable-install-doc --without-tk
all: bin/unrubby

ruby/configure:
	cd ruby && autoconf

ruby/ruby: ruby/config.status
	cd ruby && make

ruby/config.status: ruby/configure
	cd ruby && ./configure $(CONFIGURE_ARGS)

bin/ruby: ruby/ruby
	cd ruby && make install

bin/unrubby: bin/ruby
	cp $< $@
