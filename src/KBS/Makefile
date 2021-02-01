OBJECTS =	frame.o print_rule.o rdr.o rdr_fn.o rdr_plist.o kbs.o

CC =		gcc
CFLAGS = 	-std=c99 -fPIC -w -g -I. -I../prolog
LDFLAGS =	-lm

UNAME := $(shell uname -s)

ifeq ($(UNAME), Linux)
LDDYNAMICFLAGS = -shared
TARGET = libkbs.so
else ifeq ($(UNAME), Darwin)
LDDYNAMICFLAGS = -dynamiclib -flat_namespace -undefined dynamic_lookup
TARGET = libkbs.dylib
endif


$(TARGET):	$(OBJECTS)
		$(CC) ${LDDYNAMICFLAGS} -o $(TARGET) $(OBJECTS) $(LDFLAGS)
		mkdir -p ../../lib
		cp $(TARGET) ../../lib

install:	$(TARGET)
		mkdir -p /usr/local/lib/iProlog
		cp $(TARGET) /usr/local/lib/iProlog

clean:
		rm -f *.o *.dylib *.so *~ core

# DEPENDENCIES

$(OBJECTS):	../prolog/prolog.h

