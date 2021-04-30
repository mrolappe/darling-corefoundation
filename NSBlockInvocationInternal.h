#import <Foundation/NSBlockInvocation.h>
#import <Block_private.h>

extern void _CF_forwarding_prep_b();

struct NSProxyBlock {
	struct Block_layout blockInternal;
	void (^proxy)(NSBlockInvocation*);
};
