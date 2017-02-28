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

#ifndef _FOUNDATION_EXCEPTIONS_H
#define _FOUNDATION_EXCEPTIONS_H

#if !__OBJC2__

enum {
	kCFDoExceptionOperationGetUncaughtHandler = 0,
	kCFDoExceptionOperationSetUncaughtHandler,
	kCFDoExceptionOperationRaiseError = 40,
	kCFDoExceptionOperationAddHandler = 50,
	kCFDoExceptionOperationRemoveHandler,
	kCFDoExceptionOperationExtractException
};

void* _CFDoExceptionOperation(int op, void* arg);

__attribute__((visibility("hidden")))
void __exceptionInit(void);

#endif

#endif
