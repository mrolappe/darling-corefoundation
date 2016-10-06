project(libcf)

cmake_minimum_required(VERSION 2.4.0)

if(COMMAND cmake_policy)
	cmake_policy(SET CMP0003 NEW)
endif(COMMAND cmake_policy)

add_definitions(-D__APPLE__ -D__MACH__)
add_definitions(-DTARGET_OS_MAC=1)
add_definitions(-DHAVE_STDINT_H=1)
add_definitions(-D__APPLE__ -D__DYNAMIC__)
add_definitions(-D__ENVIRONMENT_MAC_OS_X_VERSION_MIN_REQUIRED__=1080)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -nostdinc -D__DARWIN_UNIX03 -fPIC -w -fconstant-string-class=NSConstantString -ggdb -O0")

# Duplicated, because CMake treats .m files as .cpp files and disregards
# set_source_file_properties on OBJECT libraries
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -nostdinc -D__DARWIN_UNIX03 -fPIC -w -fconstant-string-class=NSConstantString -ggdb -O0")
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -nostdlib -Wl,--version-script=${DARLING_TOP_DIRECTORY}/darwin.map")

if(BITS EQUAL 64)
	set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fobjc-runtime=gnustep")
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fobjc-runtime=gnustep")
else(BITS EQUAL 64)
	set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fobjc-abi-version=1")
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fobjc-abi-version=1")
endif(BITS EQUAL 64)

SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/darling")
SET(CMAKE_BUILD_WITH_INSTALL_RPATH TRUE) 
SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

add_definitions(-DOBJC2RUNTIME=1)
add_definitions(-DHAVE_LIBXML2=1)

include_directories(${CMAKE_CURRENT_SOURCE_DIR})
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/Headers)
include_directories(${CMAKE_CURRENT_BINARY_DIR}/Headers)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../libobjc2)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../foundation/Headers)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../libdispatch)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../icu/icuSources/common)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../icu/icuSources/i18n)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../libxml2/include)
include_directories(${CMAKE_CURRENT_BINARY_DIR}/../libxml2/include)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../apr/apr-util/apr-util)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/../apr/apr/apr/include)

set(GS_SINT8_T "signed char")
set(GS_UINT8_T "unsigned char")
set(GS_SINT16_T "signed short")
set(GS_UINT16_T "unsigned short")
set(GS_SINT64_T "signed long long")
set(GS_UINT64_T "unsigned long long")
set(GS_SINTPTR_T "signed long")
set(GS_UINTPTR_T "unsigned long")

if (BITS EQUAL 64)
	set(GS_SINT32_T "signed int")
	set(GS_UINT32_T "unsigned int")
else (BITS EQUAL 64)
	set(GS_SINT32_T "signed long")
	set(GS_UINT32_T "unsigned long")
endif (BITS EQUAL 64)

configure_file(Headers/CoreFoundation/CFBase.h.in
	Headers/CoreFoundation/CFBase.h)

set(cf_SRCS
	Source/CFArray.c
	Source/CFAttributedString.c
	Source/CFBag.c
	Source/CFBase.c
	Source/CFBinaryHeap.c
	Source/CFBitVector.c
	Source/CFBundle.m
	Source/CFCalendar.c
	Source/CFCharacterSet.c
	Source/CFData.c
	Source/CFDate.c
	Source/CFDateFormatter.c
	Source/CFDictionary.c
	Source/CFError.c
	Source/CFLocale.c
	Source/CFNumber.c
	Source/CFNumberFormatter.c
	Source/CFPropertyList.c
	Source/CFRunLoop.c
	Source/CFRuntime.c
	Source/CFSet.c
	Source/CFSocket.c
	Source/CFStream.c
	Source/CFString.c
	Source/CFStringEncoding.c
	Source/CFStringUtilities.c
	Source/CFTimeZone.c
	Source/CFTree.c
	Source/CFURLAccess.c
	Source/CFURL.c
	Source/CFUUID.c
	Source/CFXMLNode.c
	Source/CFXMLParser.c
	Source/GSCArray.c
	Source/GSFunctions.c
	Source/GSHashTable.c
	Source/GSUnicode.c
	Source/NSCFArray.m
	Source/NSCFData.m
	Source/NSCFDate.m
	Source/NSCFDictionary.m
	Source/NSCFError.m
	Source/NSCFInputStream.m
	Source/NSCFLocale.m
	Source/NSCFOutputStream.m
	Source/NSCFSet.m
	Source/NSCFString.m
	Source/NSCFTimeZone.m
	Source/NSCFType.m
	
	Source/darling/AppleCFString.m
        Source/CFNotificationCenter.c
        Source/CFPreferences.m
)

add_library(CoreFoundation OBJECT ${cf_SRCS})
set_source_files_properties(${cf_SRCS} LANGUAGE C)
#target_link_libraries(CoreFoundation system icucore)

#install(TARGETS CoreFoundation DESTINATION ${CMAKE_INSTALL_LIBDIR}/darling)
