project(corefoundation)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -nostdinc -fblocks -fconstant-cfstrings -fexceptions \
	-Wno-bridge-cast \
	-include ${CMAKE_CURRENT_SOURCE_DIR}/CoreFoundation_Prefix.h \
	-mmacosx-version-min=10.10")

include(darling_framework)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}
	${CMAKE_SOURCE_DIR}/src/external/libclosure
	${CMAKE_SOURCE_DIR}/src/external/libpthread/private
	${CMAKE_SOURCE_DIR}/src/external/libdispatch/include
	${CMAKE_SOURCE_DIR}/src/external/libdispatch
	${CMAKE_SOURCE_DIR}/src/external/icu/icuSources/common
	${CMAKE_SOURCE_DIR}/src/external/icu/icuSources/i18n
	${CMAKE_SOURCE_DIR}/src/launchd/liblaunch
	${CMAKE_SOURCE_DIR}/src/kernel/libsyscall
	${CMAKE_SOURCE_DIR}/src/libremovefile
	${CMAKE_SOURCE_DIR}/src/libc/gen
	${CMAKE_SOURCE_DIR}/src/libmalloc/include/malloc
	${CMAKE_SOURCE_DIR}/src/libffi/include
	${CMAKE_SOURCE_DIR}/src/external/security/include
	${CMAKE_SOURCE_DIR}/src/libc/stdtime/FreeBSD
	${CMAKE_SOURCE_DIR}/src/external/syslog/libsystem_asl.tproj/include
	${CMAKE_SOURCE_DIR}/src/external/objc4/runtime
	${CMAKE_SOURCE_DIR}/src/external/cfnetwork/include
	${CMAKE_SOURCE_DIR}/src/external/foundation/include
	${CMAKE_SOURCE_DIR}/src/external/foundation/src
	${CMAKE_SOURCE_DIR}/src/libmalloc/include)

add_definitions(-DCF_BUILDING_CF
	-DDEPLOYMENT_TARGET_MACOSX=1
	-DU_SHOW_DRAFT_API=1
	-DU_SHOW_CPLUSPLUS_API=0
	-DINCLUDE_OBJC
	-DDISPATCH_SUPPORT=1
	-D__CONSTANT_CFSTRINGS__=1
	-D__CONSTANT_STRINGS__=1
)

set(cf_sources
	CFApplicationPreferences.c
	CFArray.c
	CFAttributedString.c
	CFBag.c
	CFBase.c
	CFBasicHash.c
	CFBigNumber.c
	CFBinaryHeap.c
	CFBinaryPList.c
	CFBitVector.c
	CFBuiltinConverters.c
	CFBundle_Binary.c
	CFBundle.c
	CFBundle_Grok.c
	CFBundle_InfoPlist.c
	CFBundle_Locale.c
	CFBundle_Resources.c
	CFBundle_Strings.c
	CFBurstTrie.c
	CFCalendar.c
	CFConcreteStreams.c
	CFData.c
	CFDate.c
	CFDateFormatter.c
	CFDictionary.c
	CFError.c
	CFFileUtilities.c
	CFCharacterSet.c
	CFICUConverters.c
	CFLocale.c
	CFLocaleIdentifier.c
	CFLocaleKeys.c
	CFMachPort.c
	CFMessagePort.c
	CFNotificationCenter.c
	CFNumber.c
	CFNumberFormatter.c
	CFOldStylePList.c
	CFPlatform.c
	CFPlatformConverters.c
	CFPlugIn.c
	CFPlugIn_Factory.c
	CFPlugIn_Instance.c
	CFPlugIn_PlugIn.c
	CFPreferences.c
	CFPropertyList.c
	CFRunLoop.c
	CFRuntime.c
	CFSet.c
	CFSocket.c
	CFSocketStream.c
	CFSortFunctions.c
	CFStorage.c
	CFStream.c
	CFString.c
	CFStringEncodingConverter.c
	CFStringEncodingDatabase.c
	CFStringEncodings.c
	CFStringScanner.c
	CFStringUtilities.c
	CFSystemDirectories.c
	CFTimeZone.c
	CFTree.c
	CFUnicodeDecomposition.c
	CFUnicodePrecomposition.c
	CFUniChar.c
	CFURLAccess.c
	CFURL.c
	CFURLConstants.c
	CFUserNotification.c
	CFUtilities.c
	CFUUID.c
	CFVersion.c
	CFXMLInputStream.c
	CFXMLNode.c
	CFXMLParser.c
	CFXMLPreferencesDomain.c
	CFXMLTree.c
	CFURLEnumerator.c
	# CFStubs.m
	NSArray.m
	NSAttributedString.m
	NSBlock.m
	NSCache.m
	NSCalendar.m
	NSCFType.m
	NSConstantString.m
	NSData.m
	NSDateComponents.m
	NSDate.m
	NSDictionary.m
	NSEnumerator.m
	NSError.m
	NSException.m
	NSFastEnumerationEnumerator.m
	NSGenericDeallocHandler.m
	NSCharacterSet.m
	NSInputStream.m
	NSInvocation.m
	NSLocale.m
	NSMessageBuilder.m
	NSMethodSignature.m
	NSNull.m
	NSNumber.m
	NSObjCRuntime.m
	NSObject.m
	NSOrderedSet.m
	NSOutputStream.m
	NSPropertyList.m
	NSSet.m
	NSSharedKeyDictionary.m
	NSSharedKeySet.m
	NSStream.m
	NSString.m
	NSTimer.m
	NSTimeZone.m
	NSURL.m
	NSZombie.m
	cifframe.m
	GSFFIInvocation.m
	GSObjCRuntime.m
)

add_framework(CoreFoundation
	FAT
	CURRENT_VERSION
	SOURCES
		${cf_sources}
	VERSION "A"
	DEPENDENCIES
		objc
		system
		icucore
		ffi
	LINK_FLAGS
		"-Wl,-init,___CFInitialize \
		-Wl,-compatibility_version,150 \
		-Wl,-current_version,1153.18 \
		-Wl,-alias_list,${CMAKE_CURRENT_SOURCE_DIR}/SymbolAliases \
		-Wl,-sectcreate,__UNICODE,__csbitmaps,${CMAKE_CURRENT_SOURCE_DIR}/CFCharacterSetBitmaps.bitmap \
		-Wl,-sectcreate,__UNICODE,__properties,${CMAKE_CURRENT_SOURCE_DIR}/CFUniCharPropertyDatabase.data \
		-Wl,-sectcreate,__UNICODE,__data,${CMAKE_CURRENT_SOURCE_DIR}/CFUnicodeData-L.mapping \
		-Wl,-segprot,__UNICODE,r,r"
)

