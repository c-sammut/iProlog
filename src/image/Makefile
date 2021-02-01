OBJECTS =	bfl.o blob.o edge.o p_image.o p_pbm.o p_pgm.o p_ppm.o \
		skeleton.o trace.o
 
CC =		gcc
LDFLAGS =	-lm -lnetpbm

UNAME := $(shell uname -s)

ifeq ($(UNAME), Linux)
CFLAGS = -std=c99 -fPIC -w -g -I. -I../prolog -D _GNU_SOURCE
LDDYNAMICFLAGS = -shared
TARGET = libimage.so
else ifeq ($(UNAME), Darwin)
CFLAGS = -std=c99 -g -I. -I../prolog -I/opt/local/include
LDDYNAMICFLAGS = -dynamiclib -flat_namespace  -undefined dynamic_lookup -L/opt/local/lib
TARGET = libimage.dylib
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

