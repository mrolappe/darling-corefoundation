/* CFPreferences.h
   
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

#ifndef CFPREFERENCES_H
#define CFPREFERENCES_H
#include <CoreFoundation/CFBase.h>
#include <CoreFoundation/CFPropertyList.h>
#include <CoreFoundation/CFString.h>
#include <CoreFoundation/CFDictionary.h>
#include <CoreFoundation/CFArray.h>

CF_EXTERN_C_BEGIN

CF_EXPORT const CFStringRef kCFPreferencesAnyApplication;
CF_EXPORT const CFStringRef kCFPreferencesCurrentApplication;
CF_EXPORT const CFStringRef kCFPreferencesAnyHost;
CF_EXPORT const CFStringRef kCFPreferencesCurrentHost;
CF_EXPORT const CFStringRef kCFPreferencesAnyUser;
CF_EXPORT const CFStringRef kCFPreferencesCurrentUser;

CF_EXPORT
CFPropertyListRef CFPreferencesCopyAppValue(CFStringRef key, CFStringRef applicationID);

CF_EXPORT
Boolean CFPreferencesGetAppBooleanValue(CFStringRef key, CFStringRef applicationID,  Boolean* keyExistsAndHasValidFormat);

CF_EXPORT
CFIndex CFPreferencesGetAppIntegerValue(CFStringRef key, CFStringRef applicationID, Boolean* keyExistsAndHasValidFormat);

CF_EXPORT
void CFPreferencesSetAppValue(CFStringRef key, CFPropertyListRef value, CFStringRef applicationID);

CF_EXPORT
void CFPreferencesAddSuitePreferencesToApp(CFStringRef applicationID, CFStringRef suiteID);

CF_EXPORT
void CFPreferencesRemoveSuitePreferencesFromApp(CFStringRef applicationID, CFStringRef suiteID);

CF_EXPORT
Boolean CFPreferencesAppSynchronize(CFStringRef applicationID);

CF_EXPORT
CFPropertyListRef CFPreferencesCopyValue(CFStringRef key, CFStringRef applicationID, CFStringRef userName, CFStringRef hostName);

CF_EXPORT
CFDictionaryRef CFPreferencesCopyMultiple(CFArrayRef keysToFetch, CFStringRef applicationID, CFStringRef userName, CFStringRef hostName);

CF_EXPORT
void CFPreferencesSetValue(CFStringRef key, CFPropertyListRef value, CFStringRef applicationID, CFStringRef userName, CFStringRef hostName);

CF_EXPORT
void CFPreferencesSetMultiple(CFDictionaryRef keysToSet, CFArrayRef keysToRemove, CFStringRef applicationID, CFStringRef userName, CFStringRef hostName);

CF_EXPORT
Boolean CFPreferencesSynchronize(CFStringRef applicationID, CFStringRef userName, CFStringRef hostName);

CF_EXPORT
CFArrayRef CFPreferencesCopyApplicationList(CFStringRef userName, CFStringRef hostName);

CF_EXPORT
CFArrayRef CFPreferencesCopyKeyList(CFStringRef applicationID, CFStringRef userName, CFStringRef hostName);

CF_EXPORT
Boolean CFPreferencesAppValueIsForced(CFStringRef key, CFStringRef applicationID);

CF_EXTERN_C_END

#endif /* CFPREFERENCES_H */

