#
# Makefile for Sparse Bundle Adjustment projections and Jacobians [libsbaprojs.so]
# modified from Lourakis' sba demo eucsbademo.c
#

# Determine the operating system, default to unix
OS = unix
ifneq ($(shell uname -a | grep -i Darwin),)
        OS = macOS
endif
ifneq ($(shell uname -a | grep -i Windows),)
        OS = windows
endif
ifneq ($(shell uname -a | grep -i Linux),)
        OS = linux
endif

CC=gcc
CFLAGS=-I.. -O3 -Wall #-g -pg
OBJS=sbaprojs.o imgproj.o 
SRCS=sbaprojs.c imgproj.c

ifeq ($(OS),macOS)
	LAPACKLIBS=-framework Accelerate
else
	LAPACKLIBS=-llapack -lblas -lf2c # On systems with a FORTRAN (not f2c'ed) version of LAPACK, -lf2c is
                                 # not necessary; on others -lf2c is equivalent to -lF77 -lI77

	#LAPACKLIBS=-L/usr/local/atlas/lib -llapack -lcblas -lf77blas -latlas -lf2c # This works with the ATLAS updated lapack and Linux_P4SSE2
                                                                            # from http://www.netlib.org/atlas/archives/linux/

	#LAPACKLIBS=-llapack -lgoto -lpthread -lf2c # This works with GotoBLAS
                                            # from http://www.tacc.utexas.edu/resources/software/

	#LAPACKLIBS=-L/opt/intel/mkl/8.0.1/lib/32/ -lmkl_lapack -lmkl_ia32 -lguide -lf2c # This works with MKL 8.0.1 from
                                            # http://www.intel.com/cd/software/products/asmo-na/eng/perflib/mkl/index.htm
endif

LIBS=-lsba $(LAPACKLIBS) -lm
LDFLAGS=-L.. # for 

libsbaprojs.so:
ifeq ($(OS),macOS)
	$(CC) $(CFLAGS) -fPIC -c sbaprojs.h sbaprojs.c imgproj.c -target arm64-apple-macos11
	$(CC) $(CFLAGS) $(OBJS) -o libsbaprojs_a64.dylib -shared $(LDFLAGS) $(LIBS) -target arm64-apple-macos11
	$(CC) $(CFLAGS) -fPIC -c sbaprojs.h sbaprojs.c imgproj.c -target x86_64-apple-macos10.6
	$(CC) $(CFLAGS) $(OBJS) -o libsbaprojs_x64.dylib -shared $(LDFLAGS) $(LIBS) -target x86_64-apple-macos10.6
	lipo -create -output libsbaprojs.dylib libsbaprojs_a64.dylib libsbaprojs_x64.dylib
else 
	$(CC) $(CFLAGS) -fPIC -c sbaprojs.h sbaprojs.c imgproj.c 
	$(CC) $(CFLAGS) $(OBJS) -o libsbaprojs.so -shared $(LDFLAGS) $(LIBS)
endif

install: # linux example
	@chmod a-x libsbaprojs.so
	@cp libsbaprojs.so /usr/local/lib/libsbaprojs.so.1.6.0
	@rm -f /usr/local/lib/libsbaprojs.so
	@ln -s /usr/local/lib/libsbaprojs.so.1.6.0 /usr/local/lib/libsbaprojs.so
	@cp sbaprojs.h /usr/local/include
	@ldconfig
# this must be done as root (sudo)

clean:
	@rm -f $(OBJS)
	@rm -f *_*dylib

realclean cleanall: clean
	@rm -f libsbaprojs.so
	@rm -f libsbaprojs.dylib

depend:
	makedepend -f Makefile $(SRCS)

# DO NOT DELETE THIS LINE -- make depend depends on it.
