/* CFPreferences.m
   
   Copyright (C) 2016 Lubos Dolezel
      
   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with this library; see the file COPYING.LIB.
   If not, see <http://www.gnu.org/licenses/> or write to the 
   Free Software Foundation, 51 Franklin Street, Fifth Floor, 
   Boston, MA 02110-1301, USA.
*/
#include <CoreFoundation/CFPreferences.h>
#include <Foundation/NSUserDefaults.h>
#include "GSPrivate.h"

// NOTE
// The following incomplete implementation wraps Foundation's NSUserDetails API.
// The problem is NSUserDetails only provides a subset of required functionality.
// TODO: NSUserDetails should wrap CFPreferences. (or at least check against kCFPreferencesCurrentApplication before that)

CF_EXTERN_C_BEGIN

CONST_STRING_DECL(kCFPreferencesAnyApplication,
  "kCFPreferencesAnyApplication");
CONST_STRING_DECL(kCFPreferencesCurrentApplication,
  "kCFPreferencesCurrentApplication");
CONST_STRING_DECL(kCFPreferencesAnyHost,
  "kCFPreferencesAnyHost");
CONST_STRING_DECL(kCFPreferencesCurrentHost,
  "kCFPreferencesCurrentHost");
CONST_STRING_DECL(kCFPreferencesAnyUser,
  "kCFPreferencesAnyUser");
CONST_STRING_DECL(kCFPreferencesCurrentUser,
  "kCFPreferencesCurrentUser");

CF_EXTERN_C_END

CFPropertyListRef CFPreferencesCopyAppValue(CFStringRef key, CFStringRef applicationID)
{
	NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
	return [[defs objectForKey: key] retain];
}

Boolean CFPreferencesGetAppBooleanValue(CFStringRef key, CFStringRef applicationID,  Boolean* keyExistsAndHasValidFormat)
{
	NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
	
	if (keyExistsAndHasValidFormat != NULL)
	{
		*keyExistsAndHasValidFormat = [defs objectForKey: key] != NULL;
	}
	
	return [defs boolForKey: key];
}

CFIndex CFPreferencesGetAppIntegerValue(CFStringRef key, CFStringRef applicationID, Boolean* keyExistsAndHasValidFormat)
{
	NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
	
	if (keyExistsAndHasValidFormat != NULL)
	{
		*keyExistsAndHasValidFormat = [defs objectForKey: key] != NULL;
	}
	
	return [defs integerForKey: key];
}

void CFPreferencesSetAppValue(CFStringRef key, CFPropertyListRef value, CFStringRef applicationID)
{
	NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
	[defs setObject: value forKey: key];
}

void CFPreferencesAddSuitePreferencesToApp(CFStringRef applicationID, CFStringRef suiteID)
{
	
}

void CFPreferencesRemoveSuitePreferencesFromApp(CFStringRef applicationID, CFStringRef suiteID)
{
	
}

Boolean CFPreferencesAppSynchronize(CFStringRef applicationID)
{
	NSUserDefaults* defs = [NSUserDefaults standardUserDefaults];
	return [defs synchronize];
}

CFPropertyListRef CFPreferencesCopyValue(CFStringRef key, CFStringRef applicationID, CFStringRef userName, CFStringRef hostName)
{
	return CFPreferencesCopyAppValue(key, applicationID);
}

CFDictionaryRef CFPreferencesCopyMultiple(CFArrayRef keysToFetch, CFStringRef applicationID, CFStringRef userName, CFStringRef hostName)
{
	// TODO
}

void CFPreferencesSetValue(CFStringRef key, CFPropertyListRef value, CFStringRef applicationID, CFStringRef userName, CFStringRef hostName)
{
	CFPreferencesSetAppValue(key, value, applicationID);
}

void CFPreferencesSetMultiple(CFDictionaryRef keysToSet, CFArrayRef keysToRemove, CFStringRef applicationID, CFStringRef userName, CFStringRef hostName)
{
	
}

Boolean CFPreferencesSynchronize(CFStringRef applicationID, CFStringRef userName, CFStringRef hostName)
{
	return CFPreferencesAppSynchronize(applicationID);
}

CFArrayRef CFPreferencesCopyApplicationList(CFStringRef userName, CFStringRef hostName)
{
	
}

CFArrayRef CFPreferencesCopyKeyList(CFStringRef applicationID, CFStringRef userName, CFStringRef hostName)
{
	
}

Boolean CFPreferencesAppValueIsForced(CFStringRef key, CFStringRef applicationID)
{
	return NO;
}
