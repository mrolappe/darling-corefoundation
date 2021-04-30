#import <Foundation/NSInvocation.h>

#import "NSBlockInvocationInternal.h"

@implementation NSBlockInvocation

- (SEL)selector
{
	[self doesNotRecognizeSelector: _cmd];
}

- (void)setSelector: (SEL)selector
{
	[self doesNotRecognizeSelector: _cmd];
}

- (void)invokeSuper
{
	[self doesNotRecognizeSelector: _cmd];
}

- (void)invokeUsingIMP: (IMP)implementation
{
	[self doesNotRecognizeSelector: _cmd];
}

@end

struct Block_descriptor_full {
	struct Block_descriptor_1 desc1;
	struct Block_descriptor_2 desc2;
	struct Block_descriptor_3 desc3;
};

struct NSProxyBlockFull {
	struct NSProxyBlock block;
	struct Block_descriptor_full descs;
	char signature[];
};

id __NSMakeSpecialForwardingCaptureBlock(const char* signature, void (^proxyBlock)(NSBlockInvocation*)) {
	// dummy block we can use to borrow certain details we need for our custom block
	void (^dummyBlock)(void) = ^{
		[proxyBlock self];
	};
	size_t signatureLength = strlen(signature);
	struct Block_layout* dummy = (void*)dummyBlock;
	struct Block_descriptor_full* dummyDescs = dummy->descriptor;
	struct NSProxyBlockFull* custom = calloc(sizeof(struct NSProxyBlockFull) + signatureLength + 1, 1);

	custom->block.blockInternal.isa = _NSConcreteMallocBlock;
	custom->block.blockInternal.flags = BLOCK_NEEDS_FREE | BLOCK_HAS_SIGNATURE | BLOCK_HAS_COPY_DISPOSE | (1 << 1);
	custom->block.blockInternal.invoke = _CF_forwarding_prep_b;
	custom->block.blockInternal.descriptor = &custom->descs.desc1;

	custom->block.proxy = proxyBlock;

	custom->descs.desc1.size = sizeof(struct NSProxyBlock);

	custom->descs.desc2.copy = dummyDescs->desc2.copy;
	custom->descs.desc2.dispose = dummyDescs->desc2.dispose;

	custom->descs.desc3.signature = custom->signature;
	custom->descs.desc3.layout = dummyDescs->desc3.layout;

	strlcpy(custom->signature, signature, signatureLength + 1);

	custom->descs.desc2.copy(custom, dummy);

	return custom;
};
