OBJECTS =	atom.o chartype.o dcg.o eval.o evloop.o files.o \
		lex.o main.o make.o mem.o out.o p_compare.o p_db.o plist.o \
		p_lists.o p_math.o p_meta.o pred.o prove.o p_sockets.o \
		p_system.o p_unix.o read.o string_io.o unify.o

INCLUDES =	atom.h files.h out.h p_math.h p_system.h\
		dcg.h IPinterface.h p_compare.h pred.h p_unix.h\
		dump.h lex.h p_db.h prolog.h read.h\
		eval.h make.h plist.h prove.h string_io.h\
		evloop.h mem.h p_lists.h p_sockets.h unify.h

CC = 		gcc

UNAME := $(shell uname -s)

ifeq ($(UNAME), Linux)
CFLAGS		= -std=c99 -g -I. -fPIC -D _GNU_SOURCE
LDFLAGS		= -lm -ldl -Wl,--export-dynamic
LDDYNAMICFLAGS	= -shared
TARGET		= libprolog.so
else ifeq ($(UNAME), Darwin)
CFLAGS		= -std=c99 -g -I. -fPIC
LDFLAGS		= -lm -ldl -force_flat_namespace -exported_symbols_list exported_symbols
LDDYNAMICFLAGS	= -dynamiclib -flat_namespace -undefined dynamic_lookup
TARGET		= libprolog.dylib
endif


all:		prolog
#		-@make $(UNAME)

prolog:		$(OBJECTS)
		$(CC) -o prolog $(OBJECTS) $(LDFLAGS)
		mkdir -p $(HOME)/bin
		cp prolog $(HOME)/bin


$(TARGET):	$(OBJECTS)
		$(CC) ${LDDYNAMICFLAGS} -o $(TARGET) $(OBJECTS) $(LDFLAGS)
		mkdir -p ../../lib
		cp $(TARGET) ../../lib

install:	prolog
		cp prolog /usr/local/bin

install_lib:	prolog
		mkdir -p /usr/local/lib/iProlog
		cp $(TARGET) /usr/local/lib/iProlog
		mkdir -p /usr/local/include/iProlog
		cp $(INCLUDES) /usr/local/include/iProlog

clean:
		rm -f prolog *.o *.so *.dylib *~ core

# DEPENDENCIES

$(OBJECTS):	prolog.h
