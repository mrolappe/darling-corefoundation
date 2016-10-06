/* CFNotificationCenter.c
   
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
#include <CoreFoundation/CFNotificationCenter.h>
#include <CoreFoundation/CFString.h>
#include <CoreFoundation/CFDictionary.h>
#include "GSPrivate.h"

static CFTypeID _kCFNotificationCenterTypeID = 0;

static void
CFNotificationCenterFinalize (CFTypeRef cf)
{
}

static Boolean
CFNotificationCenterEqual (CFTypeRef cf1, CFTypeRef cf2)
{
  return cf1 == cf2;
}

static CFHashCode
CFNotificationCenterHash (CFTypeRef cf)
{
  return 0;
}

static CFStringRef
CFNotificationCenterCopyFormattingDesc (CFTypeRef cf, CFDictionaryRef formatOptions)
{
  return CFSTR("NotificationCenter");
}

static CFNotificationCenterRef
CFNotificationCenterCreateCopy (CFAllocatorRef allocator, CFNotificationCenterRef dict)
{
	return (CFNotificationCenterRef) CFRetain(dict);
}

static CFRuntimeClass CFNotificationCenterClass =
{
  0,
  "CFNotificationCenter",
  NULL,
  (CFTypeRef(*)(CFAllocatorRef, CFTypeRef))CFNotificationCenterCreateCopy,
  CFNotificationCenterFinalize,
  CFNotificationCenterEqual,
  CFNotificationCenterHash,
  CFNotificationCenterCopyFormattingDesc,
  NULL
};

struct __CFNotificationCenter
{
	CFRuntimeBase _parent;
	void (*addObserver)(const void* /*observer*/, CFNotificationCallback /*callBack*/, CFStringRef /*name*/, const void* /*object*/, CFNotificationSuspensionBehavior /*suspensionBehavior*/);
	void (*removeObserver)(const void* /*observer*/, CFStringRef /*name*/, const void* /*object*/);
	void (*removeEveryObserver)(const void* /*observer*/);
	void (*postNotification)(CFStringRef /*name*/, const void* /*object*/, CFDictionaryRef /*userInfo*/, CFOptionFlags /*options*/);
};
struct LocalCenter
{
	struct __CFNotificationCenter _parent;
	GSMutex mutex;
	CFMutableDictionaryRef observers;
};
static struct LocalCenter* g_localCenter;
static void LocalCenterAddObserver(const void* observer, CFNotificationCallback callBack, CFStringRef name, const void* object, CFNotificationSuspensionBehavior suspensionBehavior);
static void LocalCenterRemoveObserver(const void* observer, CFStringRef name, const void* object);
static void LocalCenterRemoveEveryObserver(const void* observer);
static void LocalCenterPostNotification(CFStringRef name, const void* object, CFDictionaryRef userInfo, CFOptionFlags options);

void CFNotificationCenterInitialize (void)
{
  _kCFNotificationCenterTypeID = _CFRuntimeRegisterClass (&CFNotificationCenterClass);
  
  // Initialize local center
  g_localCenter = (struct LocalCenter*) _CFRuntimeCreateInstance (NULL, _kCFNotificationCenterTypeID,
												sizeof(struct LocalCenter) - sizeof(CFRuntimeBase), NULL);
  
  GSMutexInitialize(&g_localCenter->mutex);
  g_localCenter->observers = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, NULL);
  g_localCenter->_parent.addObserver = LocalCenterAddObserver;
  g_localCenter->_parent.removeObserver = LocalCenterRemoveObserver;
  g_localCenter->_parent.removeEveryObserver = LocalCenterRemoveEveryObserver;
  g_localCenter->_parent.postNotification = LocalCenterPostNotification;
}

CFTypeID CFNotificationCenterGetTypeID(void)
{
	return _kCFNotificationCenterTypeID;
}

CFNotificationCenterRef CFNotificationCenterGetLocalCenter(void)
{
	return (CFNotificationCenterRef) g_localCenter;
}

CFNotificationCenterRef CFNotificationCenterGetDistributedCenter(void)
{
	// TODO
	return NULL;
}
CFNotificationCenterRef CFNotificationCenterGetDarwinNotifyCenter(void)
{
	// TODO
	return NULL;
}

void CFNotificationCenterAddObserver(CFNotificationCenterRef center, const void* observer, CFNotificationCallback callBack, CFStringRef name, const void* object, CFNotificationSuspensionBehavior suspensionBehavior)
{
	center->addObserver(observer, callBack, name, object, suspensionBehavior);
}

void CFNotificationCenterRemoveObserver(CFNotificationCenterRef center, const void* observer, CFStringRef name, const void* object)
{
	center->removeObserver(observer, name, object);
}

void CFNotificationCenterRemoveEveryObserver(CFNotificationCenterRef center, const void* observer)
{
	center->removeEveryObserver(observer);
}

void CFNotificationCenterPostNotification(CFNotificationCenterRef center, CFStringRef name, const void* object, CFDictionaryRef userInfo, Boolean deliverImmediately)
{
	CFNotificationCenterPostNotificationWithOptions(center, name, object, userInfo, deliverImmediately ? kCFNotificationDeliverImmediately : 0);
}

void CFNotificationCenterPostNotificationWithOptions(CFNotificationCenterRef center, CFStringRef name, const void* object, CFDictionaryRef userInfo, CFOptionFlags options)
{
	center->postNotification(name, object, userInfo, options);
}

static void LocalCenterAddObserver(const void* observer, CFNotificationCallback callBack, CFStringRef name, const void* object, CFNotificationSuspensionBehavior suspensionBehavior)
{
	GSMutexLock(&g_localCenter->mutex);
	
	GSMutexUnlock(&g_localCenter->mutex);
}

static void LocalCenterRemoveObserver(const void* observer, CFStringRef name, const void* object)
{
	GSMutexLock(&g_localCenter->mutex);
	
	GSMutexUnlock(&g_localCenter->mutex);
}

static void LocalCenterRemoveEveryObserver(const void* observer)
{
	GSMutexLock(&g_localCenter->mutex);
	
	GSMutexUnlock(&g_localCenter->mutex);
}

static void LocalCenterPostNotification(CFStringRef name, const void* object, CFDictionaryRef userInfo, CFOptionFlags options)
{
	GSMutexLock(&g_localCenter->mutex);
	
	GSMutexUnlock(&g_localCenter->mutex);
}
