OBJECTS =	aq.o atms.o attr_info.o bp.o duce.o hash.o \
		heap.o id.o induct.o rt.o scw.o set.o \
		array.o discrim.o line.o mreg.o ml.o

CC =		gcc
CFLAGS = 	-std=c99 -fPIC -w -g -I. -I../prolog
LDFLAGS =	-lm

UNAME := $(shell uname -s)

ifeq ($(UNAME), Linux)
LDDYNAMICFLAGS = -shared
TARGET = libml.so
else ifeq ($(UNAME), Darwin)
LDDYNAMICFLAGS = -dynamiclib -flat_namespace -undefined dynamic_lookup
TARGET = libml.dylib
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

