/**
 * Copyright (C) 2017 Lubos Dolezel
 * 
 * Darling is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * Foobar is distributed in the hope that it will be useful,
 * Darling WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
 */

#if !__OBJC2__

#include <objc/runtime.h>
#include <objc/objc-exception.h>
#include "CFLogUtilities.h"
#include "CFInternal.h"
#include "ForFoundationOnly.h"
#include "FoundationExceptions.h"
#include <stdlib.h>
#include <dlfcn.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSException.h>

static void (*__uncaughtExceptionHandler)(id exc) = NULL;

typedef struct {
	jmp_buf buf;
	void* pointers[4];
} LocalData_t;

typedef struct ThreadChainLink
{
	void** localExceptionData;
	size_t localExceptionDataCount, localExceptionDataSize;
} ThreadChainLink_t;

static int objectIsKindOfNSException(id exc);

// Throw handler with Foundation support
static void __raiseError(id exc)
{
	ThreadChainLink_t* chainLink = (ThreadChainLink_t*) _CFGetTSD(__CFTSDKeyExceptionData);
	if (chainLink != NULL)
	{
		LocalData_t* led = (LocalData_t*) chainLink->localExceptionData[chainLink->localExceptionDataCount - 1];
		
		if (led != NULL)
		{
			chainLink->localExceptionDataCount--;
			led->pointers[0] = exc;
			_longjmp(led->buf, 1);
		}
	}
	
	if (__uncaughtExceptionHandler != NULL && objectIsKindOfNSException(exc))
	{
		__uncaughtExceptionHandler(exc);
	}
	else
	{
		if (!objectIsKindOfNSException(exc))
		{
			CFLog(kCFLogLevelError, CFSTR("*** Terminating app due to uncaught exception of class %s"), object_getClassName(exc));
		}
		else
		{
			CFLog(kCFLogLevelError, CFSTR("*** Terminating app due to uncaught exception of class %@, reason: \"%@\",\n"
				"*** Call stack:\n%@\n"),
				[exc name], [exc reason], [exc description]);
		}
	}
	abort();
}

static id __exceptionExtract(void* localExceptionData)
{
	LocalData_t* led = (LocalData_t*)localExceptionData;
	return (id) led->pointers[0];
}

static int objectIsKindOfNSException(id exc)
{
	Class c = [NSException class];
	if (class_respondsToSelector(object_getClass(exc), @selector(isKindOfClass:)))
	{
		return [exc isKindOfClass: c];
	}
	else
	{
		// NSException implements isKindOfClass:, so this means it's not an NSException
		return 0;
	}
}

static void __exceptionFinalize(void* ptr)
{
	ThreadChainLink_t* tsd = (ThreadChainLink_t*) ptr;
	free(tsd->localExceptionData);
	free(tsd);
}

static int __exceptionMatch(Class matchClass, id exc)
{
	Class excClass = object_getClass(exc);
	
	if (class_respondsToSelector(excClass, @selector(isKindOfClass:)))
	{
		return [exc isKindOfClass: matchClass];
	}
	else
	{
		while (excClass != NULL)
		{
			if (excClass == matchClass)
				return 1;
			excClass = class_getSuperclass(excClass);
		}
		return 0;
	}
}

static void __addHandler2(void* localExceptionData)
{
	ThreadChainLink_t* tsd = (ThreadChainLink_t*) _CFGetTSD(__CFTSDKeyExceptionData);
	
	if (!tsd)
	{
		tsd = (ThreadChainLink_t*) malloc(sizeof(ThreadChainLink_t));
		memset(tsd, 0, sizeof(*tsd));
		_CFSetTSD(__CFTSDKeyExceptionData, tsd, __exceptionFinalize);
	}
	
	if (tsd->localExceptionDataCount+1 > tsd->localExceptionDataSize)
	{
		tsd->localExceptionDataSize += 16;
		tsd->localExceptionData = (void**) realloc(tsd->localExceptionData, sizeof(void*) * tsd->localExceptionDataSize);
	}
	
	// store pointer to localExceptionData in tsd
	tsd->localExceptionData[tsd->localExceptionDataCount] = localExceptionData;
	tsd->localExceptionDataCount++;
}

static void __removeHandler2(void* localExceptionData)
{
	ThreadChainLink_t* tsd = (ThreadChainLink_t*) _CFGetTSD(__CFTSDKeyExceptionData);
	tsd->localExceptionDataCount--;
}

void* _CFDoExceptionOperation(int op, void* arg)
{
	switch (op)
	{
		case kCFDoExceptionOperationGetUncaughtHandler:
			return __uncaughtExceptionHandler;
		case kCFDoExceptionOperationSetUncaughtHandler:
			__uncaughtExceptionHandler = arg;
			break;
		case kCFDoExceptionOperationRaiseError:
			__raiseError((id) arg);
			break;
		case kCFDoExceptionOperationAddHandler:
			__addHandler2(arg);
			break;
		case kCFDoExceptionOperationRemoveHandler:
			__removeHandler2(arg);
			break;
		case kCFDoExceptionOperationExtractException:
			return __exceptionExtract(arg);
	}
	return NULL;
}

static objc_exception_functions_t old_exc_funcs;

// Called from __CFInitialize
void __exceptionInit(void)
{
	objc_exception_functions_t funcs = { 0, __raiseError, __addHandler2, __removeHandler2, __exceptionExtract, __exceptionMatch };
	objc_exception_get_functions(&old_exc_funcs);
	objc_exception_set_functions(&funcs);
}

#endif // !__OBJC2__

