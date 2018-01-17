/* CFXPCBridge.c

   Copyright (C) 2016 Lubos Dolezel

   This file is part of the GNUstep CoreBase Library.

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

#include <CoreFoundation/CFXPCBridge.h>

CFTypeRef _CFXPCCreateCFObjectFromXPCObject(xpc_object_t xpcattrs)
{
	// TODO
	// This function converts XPC null, bool, string, data, int64,
	// double, date, uuid, array and dictionary types to their
	// CF counterparts.
	return NULL;
}

xpc_object_t _CFXPCCreateXPCObjectFromCFObject(CFTypeRef attrs)
{
	return NULL;
}

xpc_object_t _CFXPCCreateXPCMessageWithCFObject(CFTypeRef obj) {
	return NULL;
}

CFTypeRef _CFXPCCreateCFObjectFromXPCMessage(xpc_object_t obj) {
	return NULL;
}

// TODO: _CFXPCCreateCFObjectFromXPCMessage
// This function takes the "ECF19A18-7AA6-4141-B4DC-A2E5123B2B5C" data value
// from the dictionary and parses it as a binary plist.
