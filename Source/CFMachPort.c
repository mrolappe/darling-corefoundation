/* CFMachPort.c
   
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
#include <CoreFoundation/CFMachPort.h>
#include "GSPrivate.h"

static CFTypeID _kCFMachPortTypeID = 0;

struct __CFMachPort
{
	CFRuntimeBase _parent;
	mach_port_t port;
	CFMachPortContext context;
	CFMachPortInvalidationCallBack invalidationCb;
	CFMachPortCallBack eventCb;
};

static void
CFMachPortFinalize (CFTypeRef cf)
{
	// TODO: deallocate port?
}

static Boolean
CFMachPortEqual (CFTypeRef cf1, CFTypeRef cf2)
{
	return cf1 == cf2 || ((CFMachPortRef)cf1)->port == ((CFMachPortRef)cf2)->port;
}

static CFHashCode
CFMachPortHash (CFTypeRef cf)
{
	return ((CFMachPortRef)cf)->port;
}

static CFStringRef
CFMachPortCopyFormattingDesc (CFTypeRef cf, CFDictionaryRef formatOptions)
{
	return CFSTR("MachPort");
}

static CFMachPortRef
CFMachPortCreateCopy (CFAllocatorRef allocator, CFMachPortRef tocopy)
{
	struct __CFMachPort* port;
	port = (struct __CFMachPort*)_CFRuntimeCreateInstance (allocator,
	  _kCFMachPortTypeID, sizeof(struct __CFMachPort) - sizeof(CFRuntimeBase), NULL);

	port->port = tocopy->port;
	memcpy(&port->context, &tocopy->context, sizeof(tocopy->context));
	port->invalidationCb = tocopy->invalidationCb;
	port->eventCb = tocopy->eventCb;

	return port;
}

static CFRuntimeClass CFMachPortClass =
{
	0,
	"CFMachPort",
	NULL,
	(CFTypeRef(*)(CFAllocatorRef, CFTypeRef))CFMachPortCreateCopy,
	CFMachPortFinalize,
	CFMachPortEqual,
	CFMachPortHash,
	CFMachPortCopyFormattingDesc,
	NULL
};

void CFMachPortInitialize (void)
{
	_kCFMachPortTypeID = _CFRuntimeRegisterClass (&CFMachPortClass);
}

CFTypeID CFMachPortGetTypeID(void)
{
	return _kCFMachPortTypeID;
}

CFMachPortRef CFMachPortCreate(CFAllocatorRef allocator, CFMachPortCallBack callout, CFMachPortContext *context, Boolean *shouldFreeInfo)
{
	// TODO
	if (shouldFreeInfo)
		*shouldFreeInfo = true;
	return NULL;
}

CFMachPortRef CFMachPortCreateWithPort(CFAllocatorRef allocator, mach_port_t portNum, CFMachPortCallBack callout, CFMachPortContext *context, Boolean *shouldFreeInfo)
{
	struct __CFMachPort* port;

	if (shouldFreeInfo)
		*shouldFreeInfo = true;

	port = (struct __CFMachPort*)_CFRuntimeCreateInstance (allocator,
	  _kCFMachPortTypeID, sizeof(struct __CFMachPort) - sizeof(CFRuntimeBase), NULL);

	port->port = portNum;
	port->eventCb = callout;

	memcpy(&port->context, context, sizeof(*context));

	if (shouldFreeInfo)
		*shouldFreeInfo = false;

	return port;
}

void CFMachPortInvalidate(CFMachPortRef port)
{
	// TODO
}

CFRunLoopSourceRef CFMachPortCreateRunLoopSource(CFAllocatorRef allocator, CFMachPortRef port, CFIndex order)
{
	// TODO
	return NULL;
}

void CFMachPortSetInvalidationCallBack(CFMachPortRef port, CFMachPortInvalidationCallBack callout)
{
	((struct __CFMachPort*) port)->invalidationCb = callout;
}

void CFMachPortGetContext(CFMachPortRef port, CFMachPortContext *context)
{
	memcpy(context, &port->context, sizeof(*context));
}

CFMachPortInvalidationCallBack CFMachPortGetInvalidationCallBack(CFMachPortRef port)
{
	return port->invalidationCb;
}

mach_port_t CFMachPortGetPort(CFMachPortRef port)
{
	return port->port;
}
