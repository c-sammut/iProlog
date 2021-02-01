OBJECTS =	face.o fbrowser_cb.o generic.o instance_display.o \
		rdr_cb.o rdr_GUI.o xforms_io.o xmessage.o gui.o
 
CC = 		gcc

UNAME := $(shell uname -s)

ifeq ($(UNAME), Linux)
CFLAGS = 	-std=c99 -fPIC -g -I. -I../prolog -I../KBS -I../Probot \
		-D _GNU_SOURCE \
		-I/usr/X11R6/include/X11 -I/usr/include/X11
LDDYNAMICFLAGS = -shared
TARGET = libdb.so
else ifeq ($(UNAME), Darwin)
CFLAGS = 	-std=c99 -g -I. -I../prolog -I../KBS -I../Probot \
		-I/usr/X11R6/include/X11 -I/usr/include/X11 -I/opt/local/include
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

