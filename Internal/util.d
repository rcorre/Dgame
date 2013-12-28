/*
 *******************************************************************************************
 * Dgame (a D game framework) - Copyright (c) Randy Schütt
 * 
 * This software is provided 'as-is', without any express or implied warranty.
 * In no event will the authors be held liable for any damages arising from
 * the use of this software.
 * 
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 * 
 * 1. The origin of this software must not be misrepresented; you must not claim
 *    that you wrote the original software. If you use this software in a product,
 *    an acknowledgment in the product documentation would be appreciated but is
 *    not required.
 * 
 * 2. Altered source versions must be plainly marked as such, and must not be
 *    misrepresented as being the original software.
 * 
 * 3. This notice may not be removed or altered from any source distribution.
 *******************************************************************************************
 */
module Dgame.Internal.util;

private {
	import std.math : fabs;
	import std.traits : isNumeric;
}

struct CircularBuffer(T, const size_t Limit = 16) {
	private T[Limit] _store = void;
	private uint _length;
	
	T* get() pure nothrow {
		T* ptr = &this._store[this._length];
		this._length = (this._length + 1) % Limit;
		
		//writeln("CB length = ", this._length);
		
		return ptr;
	}
}

struct List(T...) {
	alias Type = T[0];
	
	Type*[12] ptrs = void;
	
	void opAssign(Type[] values) pure nothrow {
		foreach (index, ptr; ptrs) {
			//writeln(" -> ", index, "::", values);
			if (index >= values.length)
				break;
			
			*ptr = values[index];
		}
	}
}

List!U list(U = T[0], T...)(auto ref T vars) pure nothrow {
	List!U tmpList;
	
	foreach (i, ref U var; vars) {
		tmpList.ptrs[i] = &var;
	}
	
	return tmpList;
} unittest {
	int a, b, c;
	
	list(a, b, c) = [1, 2, 3];
	
	assert(a == 1);
	assert(b == 2);
	assert(c == 3);
}

@safe
bool fpEqual(T : float)(const T a, const T b) pure nothrow {
	return .fabs(a - b) < T.epsilon;
} unittest {
	float f = 5f;
	
	assert(f == 5f);
	assert(fpEqual(f, 5f));
	
	float fValue1 = 1.345f;
	float fValue2 = 1.123f;
	float fTotal = fValue1 + fValue2; // should be 2.468f
	
	//assert(fTotal == 2.468f, to!string(fTotal));
	assert(fpEqual(fTotal, 2.468f));
}

@safe
bool fpEqual(T : float, size_t n)(const T[n] values, const T b) pure nothrow {
	foreach (ref const T val; values) {
		if (!fpEqual(val, b))
			return false;
	}
	
	return true;
}

@safe
bool equals(T, U)(const T a, const U b) pure nothrow 
	if (isNumeric!T && isNumeric!U)
{
	static if (is(T == float) || is(T == double) || is(T == real))
		return fpEqual(a, cast(T) b);
	else
		return a == b;
}