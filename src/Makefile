CC = 		gcc

VPATH =		.:prolog:KBS:frames:ML:ILP:Probot:image:GUI

CFLAGS = 	-std=c99 -g -I. -Iprolog -IKBS -IML -IILP -IProbot -IGUI -Iimage

LIBS =		prolog kbs frames ml ilp probot image gui 

LDFLAGS =	-L/usr/X11R6/lib -L/opt/local/lib -lm -lX11 -lforms -lnetpbm

all:
		(cd prolog;make)
		(cd KBS;make)
		(cd frames;make)
		(cd ML;make)
		(cd ILP;make)
		(cd Probot;make)
		(cd image;make)
		(cd GUI;make)

install:
		(cd prolog;make install)
		(cd KBS;make install)
		(cd frames;make install)
		(cd ML;make install)
		(cd ILP;make install)
		(cd Probot;make install)
		(cd image;make install)
		(cd GUI;make install)

clean:
		(cd prolog;make clean)
		(cd KBS;make clean)
		(cd frames;make clean)
		(cd ML;make clean)
		(cd ILP;make clean)
		(cd Probot;make clean)
		(cd GUI;make clean)
		(cd image;make clean)

