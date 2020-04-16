#import <Foundation/NSInvocation.h>
#import <Foundation/NSMethodSignature.h>

extern id _NSMessageBuilder(id proxy, NSInvocation **inv);

NS_ROOT_CLASS
@interface __NSMessageBuilder
{
@public
    Class isa;
    id _target;
    NSInvocation **_addr;
}

+ (void)initialize;
- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel;
- (void)forwardInvocation:(NSInvocation *)inv;

@end
