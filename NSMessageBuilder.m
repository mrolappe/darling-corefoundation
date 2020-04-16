//
//  NSMessageBuilder.m
//  CoreFoundation
//
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "NSMessageBuilder.h"
#import <Foundation/NSInvocation.h>
#import <Foundation/NSMethodSignature.h>
#import <objc/runtime.h>

@implementation __NSMessageBuilder

id _NSMessageBuilder(id proxy, NSInvocation **inv) {
    __NSMessageBuilder *builder = class_createInstance(objc_getClass("__NSMessageBuilder"), 0);
    builder->_target = proxy;
    builder->_addr = inv;
    return builder;
}

+ (void) initialize {

}

- (NSMethodSignature *) methodSignatureForSelector: (SEL) sel {
    return [_target methodSignatureForSelector: sel];
}

- (void) forwardInvocation: (NSInvocation *) inv {
    [inv setTarget: _target];
    if (_addr != NULL) {
        *_addr = [[inv retain] autorelease];
    }
}

@end
