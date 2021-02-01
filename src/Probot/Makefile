OBJECTS =	probot.o read_script.o rdr_chat.o

CC =		gcc
CFLAGS = 	-std=c99 -fPIC -w -g -I. -I../prolog -I../KBS
LDFLAGS =	-L ../../lib -lm -lkbs

UNAME := $(shell uname -s)

ifeq ($(UNAME), Linux)
LDDYNAMICFLAGS = -shared
TARGET = libprobot.so
else ifeq ($(UNAME), Darwin)
LDDYNAMICFLAGS = -dynamiclib -flat_namespace -undefined dynamic_lookup
TARGET = libprobot.dylib
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

