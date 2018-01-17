/* CFXPCBridge.h

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

#ifndef __CFCOREFOUNDATION_CFXPC_H__
#define __CFCOREFOUNDATION_CFXPC_H__
#include <CoreFoundation/CFBase.h>
#include <xpc/xpc.h>
#include <CoreFoundation/CFDictionary.h>

CF_EXTERN_C_BEGIN

extern CFTypeRef _CFXPCCreateCFObjectFromXPCObject(xpc_object_t xpcattrs);

extern xpc_object_t _CFXPCCreateXPCObjectFromCFObject(CFTypeRef attrs);

extern xpc_object_t _CFXPCCreateXPCMessageWithCFObject(CFTypeRef obj);

extern CFTypeRef _CFXPCCreateCFObjectFromXPCMessage(xpc_object_t obj);

CF_EXTERN_C_END

#endif
