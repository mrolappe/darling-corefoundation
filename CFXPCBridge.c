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
#include <CoreFoundation/CFString.h>
#include <CoreFoundation/CFDictionary.h>
#include <CoreFoundation/CFNumber.h>
#include <CoreFoundation/CFArray.h>
#include <CoreFoundation/CFData.h>
#include <CoreFoundation/CFNumber.h>

CFTypeRef _CFXPCCreateCFObjectFromXPCObject(xpc_object_t xpcattrs)
{
	// TODO
	// This function converts XPC null, bool, string, data, int64,
	// double, date, uuid, array and dictionary types to their
	// CF counterparts.
	return NULL;
}

static void CFXPCDictionaryApplier(const void* raw_key, const void* raw_value, void* context) {
	struct {
		char** keys;
		xpc_object_t* objs;
		size_t i;
	}* ctx = context;

	// NOTE(@facekapow):
	// we're assuming that the dictionary passed in contains only CFStrings as keys.
	// is this a bad assumption? probably maybe kinda sorta possibly definitely.
	// however, xpc dictionaries can only contain strings as keys so...
	//
	// here's to hoping that whoever uses `_CFXPCCreateXPCObjectFromCFObject` knows this
	// and only uses CFString keys for their dictionaries :/

	CFStringRef key = raw_key;

	CFIndex length = CFStringGetLength(key);
	CFIndex maxSize = CFStringGetMaximumSizeForEncoding(length, kCFStringEncodingUTF8) + 1;
	ctx->keys[ctx->i] = malloc(maxSize);
	CFStringGetCString(key, ctx->keys[ctx->i], maxSize, kCFStringEncodingUTF8);

	// we're also assuming that the values in the dictionary are all CF objects

	ctx->objs[ctx->i] = _CFXPCCreateXPCObjectFromCFObject(raw_value);

	++ctx->i;
};

xpc_object_t _CFXPCCreateXPCObjectFromCFObject(CFTypeRef attrs) {
	CFTypeID id = CFGetTypeID(attrs);

	if (id == CFStringGetTypeID()) {
		CFStringRef str = attrs;
		CFIndex length = CFStringGetLength(str);
		CFIndex maxSize = CFStringGetMaximumSizeForEncoding(length, kCFStringEncodingUTF8) + 1;
		char* tmp = malloc(maxSize);
		if (!CFStringGetCString(str, tmp, maxSize, kCFStringEncodingUTF8)) {
			free(tmp);
			return NULL;
		}
		xpc_object_t xo = xpc_string_create(tmp);
		free(tmp);
		return xo;
	}

	if (id == CFDictionaryGetTypeID()) {
		CFDictionaryRef dict = attrs;
		CFIndex length = CFDictionaryGetCount(dict);
		char** keys = malloc(sizeof(char*) * length);
		xpc_object_t* objs = malloc(sizeof(xpc_object_t) * length);
		struct {
			char** keys;
			xpc_object_t* objs;
			size_t i;
		} ctx = {
			.keys = keys,
			.objs = objs,
			.i = 0,
		};
		CFDictionaryApplyFunction(dict, CFXPCDictionaryApplier, &ctx);

		xpc_object_t xdict = xpc_dictionary_create(keys, objs, length);

		for (CFIndex i = 0; i < length; ++i) {
			free(keys[i]);
			xpc_release(objs[i]);
		}
		free(keys);
		free(objs);

		return xdict;
	}

	if (id == CFBooleanGetTypeID()) {
		CFBooleanRef boolean = attrs;
		return xpc_bool_create(CFBooleanGetValue(boolean));
	}

	if (id == CFArrayGetTypeID()) {
		CFArrayRef array = attrs;
		CFIndex length = CFArrayGetCount(array);
		xpc_object_t* objs = malloc(sizeof(xpc_object_t) * length);

		for (CFIndex i = 0; i < length; ++i)
			objs[i] = _CFXPCCreateXPCObjectFromCFObject(CFArrayGetValueAtIndex(array, i));

		xpc_object_t xarray = xpc_array_create(objs, length);

		for (CFIndex i = 0; i < length; ++i)
			xpc_release(objs[i]);
		free(objs);

		return xarray;
	}

	if (id == CFDataGetTypeID()) {
		CFDataRef data = attrs;
		return xpc_data_create(CFDataGetBytePtr(data), CFDataGetLength(data));
	}

	if (id == CFNumberGetTypeID()) {
		CFNumberRef num = attrs;
		int64_t tmp = 0;
		CFNumberGetValue(num, kCFNumberSInt64Type, &tmp);
		return xpc_int64_create(tmp);
	}

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
