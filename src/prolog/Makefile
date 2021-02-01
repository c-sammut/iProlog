OBJECTS =	atom.o chartype.o dcg.o eval.o evloop.o files.o \
		lex.o main.o make.o mem.o out.o p_compare.o p_db.o plist.o \
		p_lists.o p_math.o p_meta.o pred.o prove.o p_sockets.o \
		p_system.o p_unix.o read.o string_io.o unify.o

CC = 		gcc

UNAME := $(shell uname -s)

ifeq ($(UNAME), Linux)
CFLAGS = 	-std=c99 -g -I. -fPIC -D _GNU_SOURCE
LDFLAGS =	-lm -ldl -Wl,--export-dynamic
else ifeq ($(UNAME), Darwin)
CFLAGS = 	-std=c99 -g -I. -fPIC
LDFLAGS =	-lm -ldl -force_flat_namespace -exported_symbols_list exported_symbols
endif


all:		prolog
#		-@make $(UNAME)

prolog:		$(OBJECTS)
		$(CC) -o prolog $(OBJECTS) $(LDFLAGS)
		mkdir -p $(HOME)/bin
		cp prolog $(HOME)/bin


install:	prolog
		cp prolog /usr/local/bin

clean:
		rm -f prolog *.o *.so *.dylib *~ core

# DEPENDENCIES

$(OBJECTS):	prolog.h

