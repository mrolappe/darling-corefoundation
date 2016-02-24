#ifndef _CFAVAILABILITY_H_
#define _CFAVAILABILITY_H_

#if (__cplusplus && __cplusplus >= 201103L && (__has_extension(cxx_strong_enums) || __has_feature(objc_fixed_enum))) || (!__cplusplus && __has_feature(objc_fixed_enum))
  #define CF_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
  #if (__cplusplus)
    #define CF_OPTIONS(_type, _name) _type _name; enum : _type
  #else
    #define CF_OPTIONS(_type, _name) enum _name : _type _name; enum _name : _type
  #endif
#else
  #define CF_ENUM(_type, _name) _type _name; enum
  #define CF_OPTIONS(_type, _name) _type _name; enum
#endif

#endif


