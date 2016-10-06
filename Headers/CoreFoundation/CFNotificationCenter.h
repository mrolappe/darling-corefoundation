/* CFNotificationCenter.h
   
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

#ifndef CFNOTIFICATIONCENTER_H
#define CFNOTIFICATIONCENTER_H
#include <CoreFoundation/CFBase.h>
#include <CoreFoundation/CFDictionary.h>
#include <CoreFoundation/CFString.h>

CF_EXTERN_C_BEGIN
	
typedef const struct __CFNotificationCenter *CFNotificationCenterRef;

typedef void (*CFNotificationCallback)(CFNotificationCenterRef center, void* observer, CFStringRef name, const void* object, CFDictionaryRef userInfo);

enum {
	CFNotificationSuspensionBehaviorDrop = 1,
	CFNotificationSuspensionBehaviorCoalesce,
	CFNotificationSuspensionBehaviorHold,
	CFNotificationSuspensionBehaviorDeliverImmediately,
};

enum {
	kCFNotificationDeliverImmediately = 1,
	kCFNotificationPostToAllSessions = 2,
};
typedef CFIndex CFNotificationSuspensionBehavior;

CFTypeID CFNotificationCenterGetTypeID(void);
CFNotificationCenterRef CFNotificationCenterGetLocalCenter(void);
CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void);
CFNotificationCenterRef CFNotificationCenterGetDarwinNotifyCenter(void);

void CFNotificationCenterAddObserver(CFNotificationCenterRef center, const void* observer, CFNotificationCallback callBack, CFStringRef name, const void* object, CFNotificationSuspensionBehavior suspensionBehavior);
void CFNotificationCenterRemoveObserver(CFNotificationCenterRef center, const void* observer, CFStringRef name, const void* object);
void CFNotificationCenterRemoveEveryObserver(CFNotificationCenterRef center, const void* observer);
void CFNotificationCenterPostNotification(CFNotificationCenterRef center, CFStringRef name, const void* object, CFDictionaryRef userInfo, Boolean deliverImmediately);
void CFNotificationCenterPostNotificationWithOptions(CFNotificationCenterRef center, CFStringRef name, const void* object, CFDictionaryRef userInfo, CFOptionFlags options);

CF_EXTERN_C_END

#endif /* CFNOTIFICATIONCENTER_H */

