// This file exists to break the dependency loop
// between Foundation and CoreFoundation.
#include <stdint.h>
#define GS_GC_STRONG
#define GSNativeChar char

#ifdef __i386__
typedef unsigned long UTF32Char;
#else
typedef unsigned int UTF32Char;
#endif

