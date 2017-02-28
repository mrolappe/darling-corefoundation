#define RELEASE_LOG(fmt, ...)
#define DEBUG_LOG(fmt, ...)
#define DEBUG_BREAK() __builtin_trap()
#define UNLIKELY(x) __builtin_expect((x),0)

