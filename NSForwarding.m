/*
This file is part of Darling.

Copyright (C) 2017-2019 Lubos Dolezel

Darling is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Darling is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Darling.  If not, see <http://www.gnu.org/licenses/>.
*/

//
//  CoreFoundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import <Foundation/NSInvocation.h>
#import <Foundation/NSMethodSignature.h>

#import "NSObjCRuntimeInternal.h"
#import "NSZombie.h"

#import <objc/runtime.h>
#import <stdio.h>

#define ALIGN_TO(value, alignment) \
    (((value) % (alignment)) ? \
    ((value) + (alignment) - ((value) % (alignment))) : \
    (value) \
)

static void __NSForwardSignatureError() { __builtin_trap(); }

struct objc_sendv_margs {
    uintptr_t a[4];
    uintptr_t stackArgs[];
};

id __forwarding___(struct objc_sendv_margs *args, void *returnStorage)
{
    id self = (id)args->a[0];
    SEL _cmd = (SEL)args->a[1];

    const char *className = object_getClassName(self);

    if (strncmp(className, ZOMBIE_PREFIX, strlen(ZOMBIE_PREFIX)) == 0)
    {
        const char* origClassName = &className[strlen(ZOMBIE_PREFIX)];
        const char* selName = sel_getName(_cmd);
        printf("-[%s %s] message sent to deallocated instance %p.\n", origClassName, selName, self);
#if defined(__i386__) || defined(__x86_64__)
        __asm__ volatile("int $0x03");
#elif defined(__thumb__)
        __asm__ volatile(".inst 0xde01");
#elif defined(__arm__) && !defined(__thumb__)
        __asm__ volatile(".inst 0xe7f001f0");
#else
        __builtin_trap();
#endif

    }

    long long result = 0LL;
    id target = [self forwardingTargetForSelector:_cmd];

    if (target != nil && target != self)
    {
        // Short-circuit machinery was requested. Bail out and restart with the
        //  new target.
        return target;
    }
    else
    {
        target = self;
    }

    NSMethodSignature *signature = [target methodSignatureForSelector:_cmd];

    if (signature == nil)
    {
        // DONT EVEN THINK ABOUT REMOVING/HACKING AROUND THIS!
        // EVER!
        // ...
        // yes, I mean YOU!
        [target doesNotRecognizeSelector:_cmd];
        return target;
    }

    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:signature];
    const char *returnType = [signature methodReturnType];
    [inv setTarget:target];
    [inv setSelector:_cmd];
    void *arguments = &args->a[2];
    NSUInteger retSize = 0;
    NSUInteger retAlign = 0;
    NSGetSizeAndAlignment(returnType, &retSize, &retAlign);

    switch (*returnType)
    {
        case _C_ID:
        case _C_CLASS:
        case _C_SEL:
        case _C_BOOL:
        case _C_CHR:
        case _C_UCHR:
        case _C_SHT:
        case _C_USHT:
        case _C_INT:
        case _C_UINT:
        case _C_LNG:
        case _C_ULNG:
        case _C_LNG_LNG:
        case _C_ULNG_LNG:
        case _C_PTR:
        case _C_CHARPTR:
        case _C_VOID:
        case _C_FLT:
        case _C_DBL:
            break;
        default:
//            if (retSize > sizeof(void *))
//            {
//                arguments += sizeof(void *);     // account for stret
//            }
            break;
    }

    NSUInteger signatureVerification = 2;
    const char *selName = sel_getName(_cmd);
    for (int i = 0; i < strlen(selName); i++)
    {
        if (selName[i] == ':')
        {
            signatureVerification++;
        }
    }

    NSUInteger signatureArgumentCount = [signature numberOfArguments];
    if (signatureVerification != signatureArgumentCount)
    {
        printf("NSForwardSignatureError: invoked with %d args, but %d expected. Selector %s, class %s\n", signatureVerification, signatureArgumentCount, selName, className);
        RELEASE_LOG("Forward invocation was invoked with %d arguments but claims by signature to respond to %d arguments, break on __NSForwardSignatureError to debug", signatureVerification, signatureArgumentCount);
        // __NSForwardSignatureError();
    }

    for (NSUInteger i = 2; i < MIN(signatureVerification, signatureArgumentCount); i++)
    {
        const char *type = [signature getArgumentTypeAtIndex:i];
        NSUInteger size = 0;
        NSUInteger align = 0;
        NSGetSizeAndAlignment(type, &size, &align);

        // alignment doesn't happen on x86
#if __arm__
        if (align)
        {
            arguments = (void *)ALIGN_TO((uintptr_t)arguments, align);
        }
#endif

        [inv setArgument:arguments atIndex:i];
        arguments += ALIGN_TO(size, sizeof(void *));
    }

    [target forwardInvocation:inv];
    [inv getReturnValue:returnStorage];
    return nil;
}

