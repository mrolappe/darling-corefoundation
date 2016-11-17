/* CFBundle.m
   
   Copyright (C) 2011 Free Software Foundation, Inc.
   
   Written by: David Chisnall
   Date: April, 2011
   
   This file is part of the GNUstep CoreBase Library.
   
   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; see the file COPYING.LIB.
   If not, see <http://www.gnu.org/licenses/> or write to the 
   Free Software Foundation, 51 Franklin Street, Fifth Floor, 
   Boston, MA 02110-1301, USA.
*/

#include "CoreFoundation/CFRuntime.h"
#include "CoreFoundation/CFBundle.h"
#include "CoreFoundation/CFBundlePriv.h"
#include <Foundation/NSBundle.h>
#include <Foundation/NSURL.h>

#include "GSPrivate.h"

#if !defined(_WIN32)
#include <dlfcn.h>
#ifndef RTLD_DEFAULT
# define RTLD_DEFAULT   ((void *) 0)
#endif
#endif

static CFTypeID _kCFBundleTypeID = 0;

CONST_STRING_DECL(kCFBundleInfoDictionaryVersionKey, "CFBundleInfoDictionaryVersion");
CONST_STRING_DECL(kCFBundleExecutableKey, "CFBundleExecutable");
CONST_STRING_DECL(kCFBundleIdentifierKey, "CFBundleIdentifier");
CONST_STRING_DECL(kCFBundleVersionKey, "CFBundleVersion");
CONST_STRING_DECL(kCFBundleNameKey, "CFBundleName");
CONST_STRING_DECL(kCFBundleLocalizationsKey, "CFBundleLocalizations");

CONST_STRING_DECL(_kCFBundlePackageTypeKey, "CFBundlePackageType")
CONST_STRING_DECL(_kCFBundleSignatureKey, "CFBundleSignature")
CONST_STRING_DECL(_kCFBundleIconFileKey, "CFBundleIconFile")
CONST_STRING_DECL(_kCFBundleDocumentTypesKey, "CFBundleDocumentTypes")
CONST_STRING_DECL(_kCFBundleURLTypesKey, "CFBundleURLTypes")

CONST_STRING_DECL(_kCFBundleDisplayNameKey, "CFBundleDisplayName")
CONST_STRING_DECL(_kCFBundleShortVersionStringKey, "CFBundleShortVersionString")
CONST_STRING_DECL(_kCFBundleGetInfoStringKey, "CFBundleGetInfoString")
CONST_STRING_DECL(_kCFBundleGetInfoHTMLKey, "CFBundleGetInfoHTML")

CONST_STRING_DECL(_kCFBundleTypeNameKey, "CFBundleTypeName")
CONST_STRING_DECL(_kCFBundleTypeRoleKey, "CFBundleTypeRole")
CONST_STRING_DECL(_kCFBundleTypeIconFileKey, "CFBundleTypeIconFile")
CONST_STRING_DECL(_kCFBundleTypeOSTypesKey, "CFBundleTypeOSTypes")
CONST_STRING_DECL(_kCFBundleTypeExtensionsKey, "CFBundleTypeExtensions")
CONST_STRING_DECL(_kCFBundleTypeMIMETypesKey, "CFBundleTypeMIMETypes")

CONST_STRING_DECL(_kCFBundleURLNameKey, "CFBundleURLName")
CONST_STRING_DECL(_kCFBundleURLIconFileKey, "CFBundleURLIconFile")
CONST_STRING_DECL(_kCFBundleURLSchemesKey, "CFBundleURLSchemes")

CONST_STRING_DECL(_kCFBundleOldExecutableKey, "NSExecutable")
CONST_STRING_DECL(_kCFBundleOldInfoDictionaryVersionKey, "NSInfoPlistVersion")
CONST_STRING_DECL(_kCFBundleOldNameKey, "NSHumanReadableName")
CONST_STRING_DECL(_kCFBundleOldIconFileKey, "NSIcon")
CONST_STRING_DECL(_kCFBundleOldDocumentTypesKey, "NSTypes")
CONST_STRING_DECL(_kCFBundleOldShortVersionStringKey, "NSAppVersion")

CONST_STRING_DECL(_kCFBundleOldTypeNameKey, "NSName")
CONST_STRING_DECL(_kCFBundleOldTypeRoleKey, "NSRole")
CONST_STRING_DECL(_kCFBundleOldTypeIconFileKey, "NSIcon")
CONST_STRING_DECL(_kCFBundleOldTypeExtensions1Key, "NSUnixExtensions")
CONST_STRING_DECL(_kCFBundleOldTypeExtensions2Key, "NSDOSExtensions")
CONST_STRING_DECL(_kCFBundleOldTypeOSTypesKey, "NSMacOSType")

CONST_STRING_DECL(_kCFBundleInfoPlistURLKey, "CFBundleInfoPlistURL")
CONST_STRING_DECL(_kCFBundleRawInfoPlistURLKey, "CFBundleRawInfoPlistURL")
CONST_STRING_DECL(_kCFBundleNumericVersionKey, "CFBundleNumericVersion")
CONST_STRING_DECL(_kCFBundleExecutablePathKey, "CFBundleExecutablePath")
CONST_STRING_DECL(_kCFBundleResourcesFileMappedKey, "CSResourcesFileMapped")
CONST_STRING_DECL(_kCFBundleCFMLoadAsBundleKey, "CFBundleCFMLoadAsBundle")
CONST_STRING_DECL(_kCFBundleAllowMixedLocalizationsKey, "CFBundleAllowMixedLocalizations")

CONST_STRING_DECL(_kCFBundleInitialPathKey, "NSBundleInitialPath")
CONST_STRING_DECL(_kCFBundleResolvedPathKey, "NSBundleResolvedPath")
CONST_STRING_DECL(_kCFBundlePrincipalClassKey, "NSPrincipalClass")


@implementation NSBundle (CoreBaseAdditions)
- (CFTypeID) _cfTypeID
{
  return CFBundleGetTypeID();
}
@end

static const CFRuntimeClass CFBundleClass =
{
  0,
  "CFBundle",
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL,
  NULL
};

void CFBundleInitialize (void)
{
  _kCFBundleTypeID = _CFRuntimeRegisterClass(&CFBundleClass);
}

CFTypeID
CFBundleGetTypeID (void)
{
  return _kCFBundleTypeID;
}

CFBundleRef CFBundleCreate(CFAllocatorRef allocator, CFURLRef bundleURL)
{
  NSString *path = [(NSURL*)bundleURL path];

  if (nil == path) { return 0; }

  return (CFBundleRef)[[NSBundle alloc] initWithPath: path];
}

void* CFBundleGetFunctionPointerForName(CFBundleRef bundle,
                                        CFStringRef functionName)
{
#if !defined(_WIN32)
  [(NSBundle*)bundle load];
  return dlsym(RTLD_DEFAULT, [(NSString *) functionName UTF8String]);
#else
  return NULL;
#endif
}

void* CFBundleGetDataPointerForName(CFBundleRef bundle,
                                    CFStringRef functionName)
{
#if !defined(_WIN32)
  [(NSBundle*)bundle load];
  return dlsym(RTLD_DEFAULT, [(NSString *) functionName UTF8String]);
#else
  return NULL;
#endif
}

Boolean CFBundlePreflightExecutable(CFBundleRef bundle, CFErrorRef *error)
{
  NSBundle *ns = (NSBundle *) bundle;
  return [ns preflightAndReturnError: (NSError **)error];
}

Boolean CFBundleLoadExecutable(CFBundleRef bundle)
{
  NSBundle *ns = (NSBundle *) bundle;
  return [ns load];
}

Boolean CFBundleLoadExecutableAndReturnError(CFBundleRef bundle, CFErrorRef *error)
{
  NSBundle *ns = (NSBundle *) bundle;
  return [ns loadAndReturnError: (NSError**) error];
}

void CFBundleUnloadExecutable(CFBundleRef bundle)
{
  NSBundle *ns = (NSBundle *) bundle;
  [ns unload];
}

CFBundleRef CFBundleGetMainBundle(void)
{
  return (CFBundleRef) [NSBundle mainBundle];
}

CFBundleRef CFBundleGetBundleWithIdentifier(CFStringRef bundleID)
{
  return (CFBundleRef) [NSBundle bundleWithIdentifier: (NSString*)bundleID];
}

CFStringRef CFBundleGetIdentifier(CFBundleRef bundle)
{
  NSBundle *ns = (NSBundle *) bundle;
  return (CFStringRef) [ns bundleIdentifier];
}

CFURLRef CFBundleCopyBundleURL(CFBundleRef bundle)
{
  NSBundle *ns = (NSBundle *) bundle;
  NSURL *url = [ns bundleURL];
  [url retain];
  
  return (CFURLRef) url;
}

CFURLRef CFBundleCopyExecutableURL(CFBundleRef bundle)
{
  NSBundle *ns = (NSBundle *) bundle;
  NSURL* url;
  
  url = [ns executableURL];
  [url retain];
  
  return (CFURLRef) url;
}

CFURLRef CFBundleCopyBuiltInPlugInsURL(CFBundleRef bundle)
{
  NSBundle *ns = (NSBundle *) bundle;
  NSURL* url;
  
  url = [ns builtInPlugInsURL];
  [url retain];
  
  return (CFURLRef) url;
}

CFURLRef CFBundleCopyResourcesDirectoryURL(CFBundleRef bundle)
{
	NSBundle *ns = (NSBundle *) bundle;
	NSURL* url;

	url = [ns resourceURL];
	[url retain];

	return (CFURLRef) url;
}

CFURLRef CFBundleCopyResourceURL(CFBundleRef bundle, CFStringRef resourceName,
                                 CFStringRef resourceType,
                                 CFStringRef subDirName)
{
  NSBundle *ns = (NSBundle *) bundle;
  NSURL *url;
  
  url = [ns URLForResource: (NSString *) resourceName
             withExtension: (NSString *) resourceType
              subdirectory: (NSString *) subDirName];

  [url retain];
  return (CFURLRef) url;
}

CFURLRef CFBundleCopyResourceURLForLocalization(CFBundleRef bundle,
   CFStringRef resourceName, CFStringRef resourceType,
   CFStringRef subDirName, CFStringRef localizationName)
{
  NSBundle *ns = (NSBundle *) bundle;
  NSURL *url;
  
  url = [ns URLForResource: (NSString *) resourceName
             withExtension: (NSString *) resourceType
              subdirectory: (NSString *) subDirName
              localization: (NSString *) localizationName];

  [url retain];
  return (CFURLRef) url;
}


CFURLRef CFBundleCopyPrivateFrameworksURL(CFBundleRef bundle)
{
  NSBundle *ns = (NSBundle *) bundle;
  NSURL *url;
  
  url = [ns privateFrameworksURL];
  [url retain];
  
  return (CFURLRef) url;
}

CFURLRef CFBundleCopyAuxiliaryExecutableURL(CFBundleRef bundle,
                                            CFStringRef executableName)
{
  NSBundle *ns = (NSBundle *) bundle;
  NSURL *url;
  
  url = [ns URLForAuxiliaryExecutable: (NSString *) executableName];
  [url retain];
  
  return (CFURLRef) url;
}


CFDictionaryRef CFBundleGetInfoDictionary(CFBundleRef bundle)
{
  NSBundle *ns = (NSBundle *) bundle;
  return (CFDictionaryRef) [ns infoDictionary];
}

CFDictionaryRef CFBundleGetLocalInfoDictionary(CFBundleRef bundle)
{
  NSBundle *ns = (NSBundle *) bundle;
  return (CFDictionaryRef) [ns localizedInfoDictionary];
}

CFTypeRef CFBundleGetValueForInfoDictionaryKey(CFBundleRef bundle,
                                               CFStringRef key)
{
  NSBundle *ns = (NSBundle *) bundle;
  return [ns objectForInfoDictionaryKey: (NSString *)key];
}

CFStringRef CFBundleCopyLocalizedString(CFBundleRef bundle, CFStringRef key,
		CFStringRef value, CFStringRef tableName)
{
  NSBundle *ns = (NSBundle *) bundle;
  return (CFStringRef) [ns localizedStringForKey: (NSString*) key
                                           value: (NSString*) value
                                           table: (NSString*) tableName];
}

CFURLRef CFBundleCopySupportFilesDirectoryURL(CFBundleRef bundle)
{
  NSBundle *ns = (NSBundle *) bundle;
  NSString* rootPath = [ns _bundleRootPath];
  NSURL* url = [NSURL fileURLWithPath: rootPath isDirectory: YES];
  return (CFURLRef) [url retain];
}

CFURLRef _CFBundleCopyInfoPlistURL(CFBundleRef bundle)
{
  NSBundle *ns = (NSBundle *) bundle;
  NSURL* url = [ns pathForResource: @"Info" ofType: @"plist"];
  return (CFURLRef) [url retain];
}

CFBundleRef _CFBundleCreateWithExecutableURLIfMightBeBundle(CFAllocatorRef allocator, CFURLRef _url)
{
	NSURL* url = (NSURL*) _url;
	NSString* lastComponent;

	url = [url URLByDeletingLastPathComponent]; // remove the executable path
	lastComponent = [url lastPathComponent];

	if ([lastComponent isEqualToString: @"MacOS"])
	{
		url = [url URLByDeletingLastPathComponent];
		lastComponent = [url lastPathComponent];

		if ([lastComponent isEqualToString: @"Contents"])
			url = [url URLByDeletingLastPathComponent];
	}

	return (CFBundleRef) [[NSBundle alloc] initWithURL: url];
}
