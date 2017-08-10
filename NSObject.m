//
//  NSObject.m
//  CoreFoundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>
#import <Foundation/NSMethodSignature.h>
#import <Foundation/NSInvocation.h>
#import <Foundation/NSException.h>
#import "CFString.h"
#import "NSZombie.h"
#import <objc/runtime.h>
#import <objc/message.h>
#include <stdio.h>
#include <malloc/malloc.h>

//#import <libv/libv.h>
#define _GETENV(a,b) 0

#define SYMBOL_HERE_IN_3(sym, vers, n)                             \
	OBJC_EXPORT const char here_ ##n __asm__("$ld$add$os" #vers "$" #sym); const char here_ ##n = 0
#define SYMBOL_HERE_IN_2(sym, vers, n)     \
	SYMBOL_HERE_IN_3(sym, vers, n)
#define SYMBOL_HERE_IN(sym, vers)                  \
	SYMBOL_HERE_IN_2(sym, vers, __COUNTER__)

#if __OBJC2__
# define NSOBJECT_HERE_IN(vers)                       \
	SYMBOL_HERE_IN(_OBJC_CLASS_$_NSObject, vers);     \
	SYMBOL_HERE_IN(_OBJC_METACLASS_$_NSObject, vers); \
	SYMBOL_HERE_IN(_OBJC_IVAR_$_NSObject.isa, vers)
#else
# define NSOBJECT_HERE_IN(vers)                       \
	    SYMBOL_HERE_IN(.objc_class_name_NSObject, vers)
#endif

#if TARGET_OS_IOS

NSOBJECT_HERE_IN(2.0);
NSOBJECT_HERE_IN(2.1);
NSOBJECT_HERE_IN(2.2);
NSOBJECT_HERE_IN(3.0);
NSOBJECT_HERE_IN(3.1);
NSOBJECT_HERE_IN(3.2);
NSOBJECT_HERE_IN(4.0);
NSOBJECT_HERE_IN(4.1);
NSOBJECT_HERE_IN(4.2);
NSOBJECT_HERE_IN(4.3);
NSOBJECT_HERE_IN(5.0);
NSOBJECT_HERE_IN(5.1);

#elif TARGET_OS_MAC

NSOBJECT_HERE_IN(10.0);
NSOBJECT_HERE_IN(10.1);
NSOBJECT_HERE_IN(10.2);
NSOBJECT_HERE_IN(10.3);
NSOBJECT_HERE_IN(10.4);
NSOBJECT_HERE_IN(10.5);
NSOBJECT_HERE_IN(10.6);
NSOBJECT_HERE_IN(10.7);

#endif

void __CFZombifyNSObject(void) {
    Class cls = objc_lookUpClass("NSObject");
    Method dealloc_zombie = class_getInstanceMethod(cls, @selector(__dealloc_zombie));
    Method dealloc = class_getInstanceMethod(cls, @selector(dealloc));
    method_exchangeImplementations(dealloc_zombie, dealloc);
}

static void NSUnrecognizedForwarding() { __asm__("int3"); }

@implementation NSObject

// BELOW CODE IS FROM NSObject.mm IN objc4

+ (void)load {
}

+ (void)initialize {
}

+ (id)self {
    return (id)self;
}

- (id)self {
    return self;
}

+ (Class)class {
    return self;
}

- (Class)class {
    return object_getClass(self);
}

+ (Class)superclass {
    return class_getSuperclass(self);
}

- (Class)superclass {
    return class_getSuperclass([self class]);
}

+ (BOOL)isMemberOfClass:(Class)cls {
    return object_getClass((id)self) == cls;
}

- (BOOL)isMemberOfClass:(Class)cls {
    return [self class] == cls;
}

+ (BOOL)isKindOfClass:(Class)cls {
    for (Class tcls = object_getClass((id)self); tcls; tcls = class_getSuperclass(tcls)) {
        if (tcls == cls) return YES;
    }
    return NO;
}

- (BOOL)isKindOfClass:(Class)cls {
    for (Class tcls = [self class]; tcls; tcls = class_getSuperclass(tcls)) {
        if (tcls == cls) return YES;
    }
    return NO;
}

+ (BOOL)isSubclassOfClass:(Class)cls {
    for (Class tcls = self; tcls; tcls = class_getSuperclass(tcls)) {
        if (tcls == cls) return YES;
    }
    return NO;
}

+ (BOOL)isAncestorOfObject:(NSObject *)obj {
    for (Class tcls = [obj class]; tcls; tcls = class_getSuperclass(tcls)) {
        if (tcls == self) return YES;
    }
    return NO;
}

+ (BOOL)instancesRespondToSelector:(SEL)sel {
    if (!sel) return NO;
    return class_respondsToSelector(self, sel);
}

+ (BOOL)respondsToSelector:(SEL)sel {
    if (!sel) return NO;
    printf("TODO: +[NSObject respondsToSelector]\n");
    return YES;
    //return class_respondsToSelector_inst(object_getClass(self), sel, self);
}

- (BOOL)respondsToSelector:(SEL)sel {
    if (!sel) return NO;
    printf("TODO: -[NSObject respondsToSelector]\n");
    return YES;
    //return class_respondsToSelector_inst([self class], sel, self);
}

+ (BOOL)conformsToProtocol:(Protocol *)protocol {
    if (!protocol) return NO;
    for (Class tcls = self; tcls; tcls = class_getSuperclass(tcls)) {
        if (class_conformsToProtocol(tcls, protocol)) return YES;
    }
    return NO;
}

- (BOOL)conformsToProtocol:(Protocol *)protocol {
    if (!protocol) return NO;
    for (Class tcls = [self class]; tcls; tcls = class_getSuperclass(tcls)) {
        if (class_conformsToProtocol(tcls, protocol)) return YES;
    }
    return NO;
}

+ (NSUInteger)hash {
}

- (NSUInteger)hash {
}

+ (BOOL)isEqual:(id)obj {
    return obj == (id)self;
}

- (BOOL)isEqual:(id)obj {
    return obj == self;
}


+ (BOOL)isFault {
    return NO;
}

- (BOOL)isFault {
    return NO;
}

+ (BOOL)isProxy {
    return NO;
}

- (BOOL)isProxy {
    return NO;
}


+ (IMP)instanceMethodForSelector:(SEL)sel {
    if (!sel) [self doesNotRecognizeSelector:sel];
    return class_getMethodImplementation(self, sel);
}

+ (IMP)methodForSelector:(SEL)sel {
    if (!sel) [self doesNotRecognizeSelector:sel];
    return class_getMethodImplementation(self, sel);
}

- (IMP)methodForSelector:(SEL)sel {
    if (!sel) [self doesNotRecognizeSelector:sel];
    return class_getMethodImplementation([self class], sel);
}

+ (BOOL)resolveClassMethod:(SEL)sel {
    return NO;
}

+ (BOOL)resolveInstanceMethod:(SEL)sel {
    return NO;
}

// Replaced by CF (throws an NSException)
+ (void)doesNotRecognizeSelector:(SEL)sel {
    printf("unrecognized selector sent to instance\n");
    //_objc_fatal("+[%s %s]: unrecognized selector sent to instance %p", 
                //class_getName(self), sel_getName(sel), self);
}

// Replaced by CF (throws an NSException)
- (void)doesNotRecognizeSelector:(SEL)sel {
    printf("unrecognized selector sent to instance\n");
    //_objc_fatal("-[%s %s]: unrecognized selector sent to instance %p", 
               // object_getClassName(self), sel_getName(sel), self);
}


+ (id)performSelector:(SEL)sel {
    if (!sel) [self doesNotRecognizeSelector:sel];
    return ((id(*)(id, SEL))objc_msgSend)((id)self, sel);
}

+ (id)performSelector:(SEL)sel withObject:(id)obj {
    if (!sel) [self doesNotRecognizeSelector:sel];
    return ((id(*)(id, SEL, id))objc_msgSend)((id)self, sel, obj);
}

+ (id)performSelector:(SEL)sel withObject:(id)obj1 withObject:(id)obj2 {
    if (!sel) [self doesNotRecognizeSelector:sel];
    return ((id(*)(id, SEL, id, id))objc_msgSend)((id)self, sel, obj1, obj2);
}

- (id)performSelector:(SEL)sel {
    if (!sel) [self doesNotRecognizeSelector:sel];
    return ((id(*)(id, SEL))objc_msgSend)(self, sel);
}

- (id)performSelector:(SEL)sel withObject:(id)obj {
    if (!sel) [self doesNotRecognizeSelector:sel];
    return ((id(*)(id, SEL, id))objc_msgSend)(self, sel, obj);
}

- (id)performSelector:(SEL)sel withObject:(id)obj1 withObject:(id)obj2 {
    if (!sel) [self doesNotRecognizeSelector:sel];
    return ((id(*)(id, SEL, id, id))objc_msgSend)(self, sel, obj1, obj2);
}


// Replaced by CF (returns an NSMethodSignature)
+ (NSMethodSignature *)instanceMethodSignatureForSelector:(SEL)sel {
    //_objc_fatal("+[NSObject instanceMethodSignatureForSelector:] "
             //   "not available without CoreFoundation");
}

// Replaced by CF (returns an NSMethodSignature)
+ (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
  //  _objc_fatal("+[NSObject methodSignatureForSelector:] "
              //  "not available without CoreFoundation");
}

// Replaced by CF (returns an NSMethodSignature)
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
   // _objc_fatal("-[NSObject methodSignatureForSelector:] "
          //      "not available without CoreFoundation");
}

+ (void)forwardInvocation:(NSInvocation *)invocation {
    [self doesNotRecognizeSelector:(invocation ? [invocation selector] : 0)];
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    [self doesNotRecognizeSelector:(invocation ? [invocation selector] : 0)];
}

+ (id)forwardingTargetForSelector:(SEL)sel {
    return nil;
}

- (id)forwardingTargetForSelector:(SEL)sel {
    return nil;
}


// Replaced by CF (returns an NSString)
+ (NSString *)description {
    return nil;
}

// Replaced by CF (returns an NSString)
- (NSString *)description {
    return nil;
}

+ (NSString *)debugDescription {
    return [self description];
}

- (NSString *)debugDescription {
    return [self description];
}


+ (id)new {
    return [[self alloc] init];
}

+ (id)retain {
    return (id)self;
}

// Replaced by ObjectAlloc
- (id)retain {
    return (id)self;
}


+ (BOOL)_tryRetain {
    return YES;
}

// Replaced by ObjectAlloc
- (BOOL)_tryRetain {
    return (id)self;
}

+ (BOOL)_isDeallocating {
    return NO;
}

- (BOOL)_isDeallocating {
    return (id)self;
}

+ (BOOL)allowsWeakReference { 
    return YES; 
}

+ (BOOL)retainWeakReference { 
    return YES; 
}

- (BOOL)allowsWeakReference { 
    return ! [self _isDeallocating]; 
}

- (BOOL)retainWeakReference { 
    return [self _tryRetain]; 
}

+ (oneway void)release {
}

// Replaced by ObjectAlloc
- (oneway void)release {
    (id)self;
}

+ (id)autorelease {
    return (id)self;
}

// Replaced by ObjectAlloc
- (id)autorelease {
    return (id)self;
}

+ (NSUInteger)retainCount {
    return ULONG_MAX;
}

// Should not be used, we can fake it
- (NSUInteger)retainCount {
    printf("-[NSObject retainCount]: should not be used\n");
    return ULONG_MAX;
}

+ (id)alloc {
    return self;
}

// Replaced by ObjectAlloc
+ (id)allocWithZone:(struct _NSZone *)zone {
    id obj;

#if __OBJC2__
    // allocWithZone under __OBJC2__ ignores the zone parameter
    (void)zone;
    obj = class_createInstance(self, 0);
#else
    if (!zone) {
        obj = class_createInstance(self, 0);
    }
    else {
        obj = class_createInstanceFromZone(self, 0, (malloc_zone_t *)zone);
    }
#endif

    return obj;
}

// Replaced by CF (throws an NSException)
+ (id)init {
    return (id)self;
}

- (id)init {
    return self;
}

// Replaced by CF (throws an NSException)
+ (void)dealloc {
}


// Replaced by NSZombies
- (void)dealloc {
}

// Previously used by GC. Now a placeholder for binary compatibility.
- (void) finalize {
}

+ (struct _NSZone *)zone {
}

- (struct _NSZone *)zone {
}

+ (id)copy {
    return (id)self;
}

+ (id)copyWithZone:(struct _NSZone *)zone {
    return (id)self;
}

- (id)copy {
    return [(id)self copyWithZone:nil];
}

+ (id)mutableCopy {
    return (id)self;
}

+ (id)mutableCopyWithZone:(struct _NSZone *)zone {
    return (id)self;
}

- (id)mutableCopy {
    return [(id)self mutableCopyWithZone:nil];
}

@end

@implementation NSObject (NSObject)

+ (void)doesNotRecognizeSelector:(SEL)sel
{
    if (_GETENV(BOOL, "NSUnrecognizedForwardingDisabled"))
    {
        RELEASE_LOG("+[%s %s]: unrecognized selector sent to instance %p; set a breakpoint on NSUnrecognizedForwarding to debug", class_getName(self), sel_getName(sel), self);
        NSUnrecognizedForwarding();
    }
    else
    {
        // DONT EVEN THINK ABOUT REMOVING/HACKING AROUND THIS!
        // EVER!
        // ...
        // yes, I mean YOU!
        [NSException raise:NSInvalidArgumentException format:@"+[%s %s]: unrecognized selector sent to instance %p", class_getName(self), sel_getName(sel), self];
    }
}

- (void)doesNotRecognizeSelector:(SEL)sel
{
    if (_GETENV(BOOL, "NSUnrecognizedForwardingDisabled"))
    {
        RELEASE_LOG("+[%s %s]: unrecognized selector sent to instance %p; set a breakpoint on NSUnrecognizedForwarding to debug", object_getClassName(self), sel_getName(sel), self);
        NSUnrecognizedForwarding();
    }
    else
    {
        // DONT EVEN THINK ABOUT REMOVING/HACKING AROUND THIS!
        // EVER!
        // ...
        // yes, I mean YOU!
        [NSException raise:NSInvalidArgumentException format:@"-[%s %s]: unrecognized selector sent to instance %p", object_getClassName(self), sel_getName(sel), self];
    }
}

+ (NSMethodSignature *)instanceMethodSignatureForSelector:(SEL)sel
{
    if (sel == NULL)
    {
        return nil;
    }

    Method m = class_getInstanceMethod(self, sel);

    if (m == NULL)
    {
        return nil;
    }

    return [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(m)];
}

+ (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    if (sel == NULL)
    {
        return nil;
    }

    Method m = class_getClassMethod(self, sel);

    if (m == NULL)
    {
        return nil;
    }

    return [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(m)];
}


- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
    if (sel == NULL)
    {
        return nil;
    }

    Method m = class_getInstanceMethod(object_getClass(self), sel);

    if (m == NULL)
    {
        return nil;
    }

    return [NSMethodSignature signatureWithObjCTypes:method_getTypeEncoding(m)];
}

+ (NSString *)description
{
    CFStringRef description = CFStringCreateWithCString(kCFAllocatorDefault, class_getName(self), kCFStringEncodingUTF8);
    return [(NSString *)description autorelease];
}

- (NSString *)description
{
    CFStringRef description = CFStringCreateWithFormat(kCFAllocatorDefault, NULL, CFSTR("<%s: %p>"), object_getClassName(self), self);
    return [(NSString *)description autorelease];
}

+ (BOOL)implementsSelector:(SEL)selector
{
    if (selector == NULL)
    {
        [NSException raise:NSInvalidArgumentException format:@"selector cannot be NULL"];
        return NO;
    }

    return class_getMethodImplementation(object_getClass(self), selector) != (IMP)&_objc_msgForward;
}

- (BOOL)implementsSelector:(SEL)selector
{
    if (selector == NULL)
    {
        [NSException raise:NSInvalidArgumentException format:@"selector cannot be NULL"];
        return NO;
    }

    // sneaky! this calls [self class]!!
    return class_getMethodImplementation([self class], selector) != (IMP)&_objc_msgForward;
}

+ (BOOL)instancesImplementSelector:(SEL)selector
{
    if (selector == NULL)
    {
        [NSException raise:NSInvalidArgumentException format:@"selector cannot be NULL"];
        return NO;
    }

    return class_getMethodImplementation(self, selector) != (IMP)&_objc_msgForward;
}

+ (void)forwardInvocation:(NSInvocation *)inv
{
    [inv setTarget:self];
    [inv invoke];
}

- (void)forwardInvocation:(NSInvocation *)inv
{
    [inv setTarget:self];
    [inv invoke];
}

- (void)__dealloc_zombie
{
    const char *className = object_getClassName(self);
    char *zombieClassName = NULL;
    do {
        if (asprintf(&zombieClassName, "%s%s", ZOMBIE_PREFIX, className) == -1)
        {
            break;
        }

        Class zombieClass = objc_getClass(zombieClassName);
        
        if (zombieClass == Nil) 
        {
            zombieClass = objc_duplicateClass(objc_getClass(ZOMBIE_PREFIX), zombieClassName, 0);
        }

        if (zombieClass == Nil)
        {
            break;
        }

        objc_destructInstance(self);

        object_setClass(self, zombieClass);

    } while (0);
    
    if (zombieClassName != NULL)
    {
        free(zombieClassName);
    }
}

@end

@implementation NSObject (NSCoderMethods)

- (BOOL)_allowsDirectEncoding
{
    return NO;
}

+ (NSInteger)version
{
    return class_getVersion(self);
}

+ (void)setVersion:(NSInteger)aVersion
{
    class_setVersion(self, aVersion);
}

- (Class)classForCoder
{
    return [self class];
}

- (id)replacementObjectForCoder:(NSCoder *)aCoder
{
    return self;
}

- (id)awakeAfterUsingCoder:(NSCoder *)aDecoder
{
    return self;
}

@end

@implementation NSObject (__NSIsKinds)

- (BOOL)isNSValue__
{
    return NO;
}

- (BOOL)isNSTimeZone__
{
    return NO;
}

- (BOOL)isNSString__
{
    return NO;
}

- (BOOL)isNSSet__
{
    return NO;
}

- (BOOL)isNSOrderedSet__
{
    return NO;
}

- (BOOL)isNSNumber__
{
    return NO;
}

- (BOOL)isNSDictionary__
{
    return NO;
}

- (BOOL)isNSDate__
{
    return NO;
}

- (BOOL)isNSData__
{
    return NO;
}

- (BOOL)isNSArray__
{
    return NO;
}

@end

