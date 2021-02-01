#OBJECTS =	tc.o control.o
OBJECTS =	pq_frame.o control.o

CC =		gcc
#LDFLAGS =	-lm -lsqlite3 -ltokyocabinet
LDFLAGS =	-lm -lpq

UNAME := $(shell uname -s)

ifeq ($(UNAME), Linux)
CFLAGS = -std=c99 -fPIC -w -g -I. -I../prolog -I/usr/include/postgresql
LDDYNAMICFLAGS = -shared
TARGET = libdb.so
else ifeq ($(UNAME), Darwin)
CFLAGS = -std=c99 -w -g -I. -I../prolog -I/opt/local/include -I/usr/include/postgresql
LDDYNAMICFLAGS = -dynamiclib -flat_namespace -undefined dynamic_lookup -L/opt/local/lib
TARGET = libdb.dylib
endif


$(TARGET):	$(OBJECTS)
		$(CC) $(CFLAGS) ${LDDYNAMICFLAGS} -o $(TARGET) $(OBJECTS) $(LDFLAGS)
		mkdir -p ../../lib
		cp $(TARGET) ../../lib

install:	$(TARGET)
		mkdir -p /usr/local/lib/iProlog
		cp $(TARGET) /usr/local/lib/iProlog

clean:
		rm -f *.o *.dylib *.so *~ core

# DEPENDENCIES

$(OBJECTS):	../prolog/prolog.h

