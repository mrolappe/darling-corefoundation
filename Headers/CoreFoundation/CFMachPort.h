/* CFMachPort.h
   
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

#ifndef CFMACHPORT_H
#define CFMACHPORT_H
#include <CoreFoundation/CFBase.h>
#include <CoreFoundation/CFString.h>
#include <CoreFoundation/CFRunLoop.h>
#include <mach/port.h>

CF_EXTERN_C_BEGIN

typedef const struct __CFMachPort *CFMachPortRef;

typedef void (*CFMachPortCallBack)(CFMachPortRef port, void *msg, CFIndex size, void *info);
typedef void (*CFMachPortInvalidationCallBack)(CFMachPortRef port, void *info);

struct __CFMachPortContext
{
	CFIndex version;
	void* info;
	const void *(*retain)(const void *info);
	void (*release)(const void *info);
	CFStringRef (*copyDescription)(const void *info);
};
typedef struct __CFMachPortContext CFMachPortContext;

CFMachPortRef CFMachPortCreate(CFAllocatorRef allocator, CFMachPortCallBack callout, CFMachPortContext *context, Boolean *shouldFreeInfo);

CFMachPortRef CFMachPortCreateWithPort(CFAllocatorRef allocator, mach_port_t portNum, CFMachPortCallBack callout, CFMachPortContext *context, Boolean *shouldFreeInfo);

void CFMachPortInvalidate(CFMachPortRef port);

CFRunLoopSourceRef CFMachPortCreateRunLoopSource(CFAllocatorRef allocator, CFMachPortRef port, CFIndex order);

void CFMachPortSetInvalidationCallBack(CFMachPortRef port, CFMachPortInvalidationCallBack callout);

void CFMachPortGetContext(CFMachPortRef port, CFMachPortContext *context);

CFMachPortInvalidationCallBack CFMachPortGetInvalidationCallBack(CFMachPortRef port);

mach_port_t CFMachPortGetPort(CFMachPortRef port);

Boolean CFMachPortIsValid(CFMachPortRef port);

CFTypeID CFMachPortGetTypeID(void);

CF_EXTERN_C_END

#endif /* CFMACHPORT_H */

