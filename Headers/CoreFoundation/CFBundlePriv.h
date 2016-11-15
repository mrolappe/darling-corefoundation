#ifndef _CFBUNDLEPRIV_H_
#define _CFBUNDLEPRIV_H_
#include <CoreFoundation/CFBundle.h>

CF_EXTERN_C_BEGIN

CF_EXPORT
CFURLRef _CFBundleCopyInfoPlistURL(CFBundleRef bundle);

CF_EXTERN_C_END

#endif
