// This file exists to break the dependency loop
// between Foundation and CoreFoundation.
#include <stdint.h>
#define GS_GC_STRONG
#define GSNativeChar char
#define UTF32Char uint32_t
