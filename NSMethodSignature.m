//
//  NSMethodSignature.m
//  CoreFoundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSMethodSignature.h>
#import "NSObjCRuntimeInternal.h"
#import "NSObjectInternal.h"

#define ALIGN_TO(value, alignment) \
(((value) % (alignment)) ? \
((value) + (alignment) - ((value) % (alignment))) : \
(value) \
)

@implementation NSMethodSignature

- (instancetype)initWithObjCTypes:(const char *)types
{
    self = [super init];

    if (self == nil)
    {
        return nil;
    }

    _count = 0;
    _frameLength = 0;
    _typeString = CFStringCreateMutable(NULL, strlen(types));
    // strlen(types) is a safe overapproximation to the actual number of types.
    _types = calloc(sizeof(NSMethodType), strlen(types));

    if (UNLIKELY(_types == NULL))
    {
        [self release];
        return nil;
    }

    const char *currentType = types;
    const char *nextType = types;

#ifdef __LP64__
    // On x86-64, the first few arguments are passed in registers as long as
    // they satisfy certain conditions. __CF_forwarding_prep and __invoke__
    // pack and unpack all register values into a 0xce-sized block preceeding
    // the actual stack frame contents. This means frameLength always starts
    // at 0xce and grows from there if there are any on-stack arguments.
    unsigned short usedGPRegisters = 0;
    unsigned short usedSSERegisters = 0;
    _frameLength = 0xe0;
#endif

    while (nextType[0])
    {
        NSMethodType *ms = &_types[_count];

        currentType = nextType;
        nextType = NSGetSizeAndAlignment(currentType, &ms->size, &ms->alignment);
        ms->type = calloc(nextType - currentType + 1, 1);
        if (UNLIKELY(ms->type == NULL))
        {
            [self release];
            return nil;
        }
        strncpy(ms->type, currentType, nextType - currentType);
        extern void __CFStringAppendBytes(CFMutableStringRef, const char *, CFIndex, CFStringEncoding);
        __CFStringAppendBytes(_typeString, currentType, nextType - currentType, kCFStringEncodingUTF8);

        // Skip advisory size
        strtol(nextType, (char **)&nextType, 10);

        NSUInteger frameAlignment = MAX(ms->alignment, sizeof(int));
        NSUInteger frameSize = ALIGN_TO(ms->size, frameAlignment);

        if (_count == 0)
        {
            // Determine whether the method is stret, based on the
            // type of the return value.
            switch (*stripQualifiersAndComments(_types[0].type))
            {
                case _C_STRUCT_B:
                {
                    if (frameSize > sizeof(int))
                    {
                        // Account for the stret return pointer.
                        _frameLength += sizeof(void *);
                        _stret = YES;
                    }
                    break;
                }

                default:
                    // All other cases are non-stret.
                    break;
            }
        }
        else
        {
#if __arm__
            _frameLength = ALIGN_TO(_frameLength, frameAlignment);
#elif __LP64__
            // FIXME: This is far from being a complete implementation of
            // the x86-64 calling convention.
            BOOL isFP = currentType[0] == _C_FLT || currentType[0] == _C_DBL;
            if (isFP) {
                unsigned short registersNeeded = ALIGN_TO(frameSize, 16) / 16;
                if (usedSSERegisters + registersNeeded > 8) {
                    _types[_count].offset = _frameLength;
                    _frameLength += frameSize;
                } else {
                    _types[_count].offset = 0x30 + usedSSERegisters * 16;
                    usedSSERegisters += registersNeeded;
                }
            } else {
                unsigned short registersNeeded = ALIGN_TO(frameSize, 8) / 8;
                if (usedGPRegisters + registersNeeded > 6 || frameSize > 16) {
                    _types[_count].offset = _frameLength;
                    _frameLength += frameSize;
                } else {
                    _types[_count].offset = usedGPRegisters * 8;
                    usedGPRegisters += registersNeeded;
                }
            }
#else
            _types[_count].offset = _frameLength;
            _frameLength += frameSize;
#endif
        }

        _count++;
    }

    // Check whether the method is oneway by reading all the
    // qualifiers of the return type.
    static const char *qualifiers = "nNoOrRV";
    char *cur = _types[0].type;
    while (strchr(qualifiers, *cur)) {
        if (*cur == 'V') {
            _isOneway = YES;
            break;
        }
        cur++;
    }

    return self;
}

+ (NSMethodSignature *)signatureWithObjCTypes:(const char *)types
{
    return [[[self alloc] initWithObjCTypes:types] autorelease];
}

- (void)dealloc
{
    for (NSUInteger idx = 0; idx < _count; idx++)
    {
        if (_types[idx].type != NULL)
        {
            free(_types[idx].type);
        }
    }

    if (_types != NULL)
    {
        free(_types);
    }

    CFRelease(_typeString);
    [super dealloc];
}

- (NSUInteger)numberOfArguments
{
    return _count - 1;
}

- (const char *)getArgumentTypeAtIndex:(NSUInteger)idx
{
    return _types[idx + 1].type;
}

- (NSUInteger)frameLength
{
    return _frameLength;
}

- (BOOL)isOneway
{
    return _isOneway;
}

- (const char *)methodReturnType
{
    return _types[0].type;
}

- (NSUInteger)methodReturnLength
{
    return _types[0].size;
}

- (NSMethodType *)_argInfo:(NSUInteger)index
{
    return &_types[index];
}

- (BOOL)_stret
{
    return _stret;
}

- (CFStringRef) _typeString
{
    return _typeString;
}

@end
