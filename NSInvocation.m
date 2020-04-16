//
//  NSInvocation.m
//  CoreFoundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSArray.h>
#import <Foundation/NSData.h>
#import <Foundation/NSException.h>
#import <Foundation/NSInvocation.h>
#import <Foundation/NSMethodSignature.h>

#import "Block_private.h"
#import "NSInvocationInternal.h"
#import "NSObjCRuntimeInternal.h"

#import <objc/message.h>
#import <objc/runtime.h>
#import <dispatch/dispatch.h>


@implementation NSInvocation

+ (void)load
{
#if LEGACY_METHOD
    // signature should be @encode(long long) @encode(id) @encode(SEL) @encode(SEL) @encode(marg_list)
    class_addMethod([NSObject class], @selector(forward::), (IMP)&_CF_forwarding_prep_0, "q@::^v");
#else
    objc_setForwardHandler(&_CF_forwarding_prep_0, &_CF_forwarding_prep_1);
#endif
}

- (void **)_idxToArg:(NSUInteger)idx
{
    if (idx == 0)
    {
        return _retdata;
    }

    NSMethodType *argType = [_signature _argInfo:idx];
    return _frame + argType->offset;
}

// NSInvocation can retain its arguments, including copies of C
// strings which it places in an NSData. For such strings, this method
// therefore modifies the frame to use an internal pointer to the
// NSData rather than to the original string.
- (void)_retainArgument:(NSUInteger)idx
{
    NSMethodType *argInfo= [_signature _argInfo:idx];
    const char *type = stripQualifiersAndComments(argInfo->type);
    void **arg = [self _idxToArg:idx];

    id object = nil;

    switch (*type)
    {
        case _C_ID:
            object = *arg;
            break;
        case _C_CHARPTR:
        {
            NSUInteger length = strlen(*arg) + 1;
            char *copy = malloc(length);
            strlcpy(copy, *arg, length);
            *arg = copy;

            object = [NSData dataWithBytesNoCopy:copy length:length freeWhenDone:YES];

            break;
        }
        // In all other cases, store nothing.
        default:
            break;
    }

    if (object != _container[idx])
    {
        [_container[idx] release];
        _container[idx] = [object retain];
    }
}

- (instancetype)initWithMethodSignature:(NSMethodSignature *)sig
{
    if (sig == nil)
    {
        [self release];
        [NSException raise:NSInvalidArgumentException format:@"signature cannot be nil"];
        return nil;
    }

    self = [super init];

    if (self)
    {
        _signature = [sig retain];

        NSUInteger retSize = 0;
        NSGetSizeAndAlignment([_signature methodReturnType], &retSize, NULL);
        retSize = MAX(retSize, RET_SIZE_ARGS);
        _retdata = calloc(retSize + [_signature frameLength], 1);
        _frame = _retdata + retSize;

        if ([sig _stret])
        {
            // Set up the return value pointer for the objc_msgSend_stret call.
            void **ret = _frame;
            *ret = _retdata;
        }

        _container = NULL;
        _retainedArgs = NO;
    }

    return self;
}

- (instancetype)init
{
    [self release]; // init should not work on NSInvocation
    return nil;
}

- (void)dealloc
{
    if (_container)
    {
        int len = [_signature numberOfArguments] + 1;

        for (int i = 0; i < len; i++)
        {
            if (_container[i])
            {
                [_container[i] release];
                _container[i] = nil;
            }
        }

        free(_container);
        _container = NULL;
    }

    [_signature release];
    free(_retdata);
    [super dealloc];
}

+ (instancetype)invocationWithMethodSignature:(NSMethodSignature *)sig
{
    return [[[self alloc] initWithMethodSignature:sig] autorelease];
}

- (NSMethodSignature *)methodSignature
{
    return _signature;
}

- (void)retainArguments
{
    if (_retainedArgs)
    {
        return;
    }

    NSUInteger capacity = [_signature numberOfArguments] + 1; // Add one for return value.
    _container = (id *)calloc(sizeof(id), capacity);
    _retainedArgs = YES;

    for (NSUInteger idx = 0; idx < capacity; idx++)
    {
        [self _retainArgument:idx];
    }
}

- (BOOL)argumentsRetained
{
    return _retainedArgs;
}

- (id)target
{
    id t = nil;
    [self getArgument:&t atIndex:0];
    return t;
}

- (void)setTarget:(id)target
{
    [self setArgument:&target atIndex:0];
}

- (SEL)selector
{
    SEL sel;
    [self getArgument:&sel atIndex:1];
    return sel;
}

- (void)setSelector:(SEL)selector
{
    [self setArgument:&selector atIndex:1];
}

- (void)getReturnValue:(void *)retLoc
{
    [self getArgument:retLoc atIndex:-1];
}

- (void)setReturnValue:(void *)retLoc
{
    [self setArgument:retLoc atIndex:-1];
}

- (void)getArgument:(void *)argumentLocation atIndex:(NSInteger)idx
{
    // idx initially goes like this:
    // -1: return value
    // 0: self
    // 1: _cmd
    // 2+: arguments
    // Thus we add 1 to get an index into _frame.
    idx++;

    if (idx > [_signature numberOfArguments] || idx < 0)
    {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:nil userInfo:nil];
    }

    NSMethodType *argInfo = [_signature _argInfo:idx];
    void **arg = [self _idxToArg:idx];

    memcpy(argumentLocation, arg, argInfo->size);
}

- (void)setArgument:(void *)argumentLocation atIndex:(NSInteger)idx
{
    // idx initially goes like this:
    // -1: return value
    // 0: self
    // 1: _cmd
    // 2+: arguments
    // Thus we add 1 to get an index into _frame.
    idx++;

    if (idx > [_signature numberOfArguments] || idx < 0)
    {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:nil userInfo:nil];
    }

    NSMethodType *argInfo = [_signature _argInfo:idx];
    void **arg = [self _idxToArg:idx];

    memcpy(arg, argumentLocation, argInfo->size);

    if (_retainedArgs)
    {
        [self _retainArgument:idx];
    }
}

- (void)invoke
{
    id target = nil;
    [self getArgument:&target atIndex:0];

    if (target == nil)
    {
        return;
    }

    static Class NSBlockClass = Nil;
    static dispatch_once_t once = 0L;
    dispatch_once(&once, ^{
        // __NSGlobalBlock -> NSBlock
        NSBlockClass = class_getSuperclass(class_getSuperclass(object_getClass(^{})));
    });

    BOOL blockClass = NO;
    Class cls = object_getClass(target);

    while (cls != Nil)
    {
        if (cls == NSBlockClass)
        {
            blockClass = YES;
        }
        cls = class_getSuperclass(cls);
    }

    char rettype = [_signature methodReturnType][0];

    if (blockClass)
    {
        struct Block_layout *block_layout = (struct Block_layout *)target;
        __invoke__(block_layout->invoke, _retdata, _frame, [_signature frameLength], rettype);
    }
    else if ([_signature _stret])
    {
        char dummy[RET_SIZE_ARGS];
        __invoke__(&objc_msgSend_stret, &dummy, _frame, [_signature frameLength], rettype);
    }
    else
    {
        __invoke__(&objc_msgSend, _retdata, _frame, [_signature frameLength], rettype);
    }

    if (_retainedArgs)
    {
        [self _retainArgument:0];
    }
}

- (void)invokeWithTarget:(id)target
{
    [self setTarget:target];
    [self invoke];
}

@end
