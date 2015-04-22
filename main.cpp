extern "C" { 
	#include "lauxlib.h" 
}
#define WIN32_LEAN_AND_MEAN
#include <Windows.h>
#include <cstdlib>

#pragma comment(lib, "lua_5_3.lib")

#define TYPE_FLOAT32 (1)
#define TYPE_INT32 (2)
#define TYPE_INT64 (3)
#define TYPE_INT16 (4)
#define TYPE_INT8 (5)
#define TYPE_FLOAT64 (6)
#define TYPE_PTR (7)
#define TYPE_STRING (8)

#define CONV_CDECL (1)
#define CONV_STDCALL (2)
#define CONV_THISCALL (3)

#define lua_setlfunc(L, n) \
	lua_pushstring(L, #n); \
	lua_pushcfunction(L, &L##n); \
	lua_settable(L, -3)

#define lua_setwintype(L, n) \
	lua_pushstring(L, "TYPE_" #n);\
	lua_pushinteger(L, TYPE_##n);\
	lua_settable(L, -3)

#define lua_setwinconv(L, n) \
	lua_pushstring(L, "TYPE_" #n);\
	lua_pushinteger(L, CONV_##n);\
	lua_settable(L, -3)

#define lua_pushglobal(L) lua_rawgeti(L, LUA_REGISTRYINDEX, LUA_RIDX_GLOBALS)


// func(TYPE_FLOAT32, 2.0, TYPE_INT32, 1, RETURNAMOUNT)
int __cdecl cdecl_proxy(lua_State *L)
{
	lua_pushvalue(L, lua_upvalueindex(1));
	int func_addr = (int)lua_tointeger(L, -1);
	lua_pop(L, 1);
	// table

	int table = lua_upvalueindex(2);


	for (int i = lua_gettop(L); i >= 1; i--)
	{
		lua_rawgeti(L, table, i);
		switch (lua_tointeger(L, -1))
		{
		default:
		case TYPE_INT32:
		case TYPE_INT16:
		case TYPE_INT8:
		case TYPE_PTR:
		{
			lua_Integer val_ = lua_tointeger(L, i);
			int val = (int)val_;
			__asm push val;
		}
		break;

		case TYPE_FLOAT32:
		{
			lua_Number val_ = lua_tonumber(L, i);
			float val = (float)val_;
			__asm push val;
		}
		break;

		case TYPE_FLOAT64:
		{
			union {
				lua_Number n;
				unsigned long parts[2];
			} val;
			val.n = lua_tonumber(L, i);
			unsigned long lo, hi;
			lo = val.parts[1];
			hi = val.parts[0];
			__asm
			{
				push hi
					push lo
			}
		}
		break;

		case TYPE_INT64:
		{
			union {
				lua_Integer n;
				unsigned long parts[2];
			} val;
			val.n = lua_tointeger(L, i);
			auto lo = val.parts[1];
			auto hi = val.parts[0];
			__asm
			{
				push hi
					push lo
			}
		}
		break;
		case TYPE_STRING:
		{
			auto val = lua_tostring(L, i);
			__asm push val;
		}
		break;
		}
		lua_pop(L, 1);
	}
	int retn_amt = (int)lua_tointeger(L, lua_gettop(L));
	int return_;
	__asm call func_addr
	__asm {
		push eax
		mov eax, retn_amt
		add esp, eax
		pop eax
	}
	__asm mov return_, eax

	lua_pushinteger(L, return_);

	return 1;

}
int __cdecl stdcall_proxy(lua_State *L)
{
	lua_pushvalue(L, lua_upvalueindex(1));
	int func_addr = (int)lua_tointeger(L, -1);
	lua_pop(L, 1);

	// table

	int table = lua_upvalueindex(2);

	for (int i = lua_gettop(L); i >= 1; i--)
	{
		lua_rawgeti(L, table, i);
		switch (lua_tointeger(L, -1))
		{
		default:
		case TYPE_INT32:
		case TYPE_INT16:
		case TYPE_INT8:
		case TYPE_PTR:
		{
			lua_Integer val_ = lua_tointeger(L, i);
			int val = (int)val_;
			__asm push val;
		}
		break;

		case TYPE_FLOAT32:
		{
			lua_Number val_ = lua_tonumber(L, i);
			float val = (float)val_;
			__asm push val;
		}
		break;

		case TYPE_FLOAT64:
		{
			union {
				lua_Number n;
				unsigned long parts[2];
			} val;
			val.n = lua_tonumber(L, i);
			unsigned long lo, hi;
			lo = val.parts[1];
			hi = val.parts[0];
			__asm
			{
				push hi
					push lo
			}
		}
		break;

		case TYPE_INT64:
		{
			union {
				lua_Integer n;
				unsigned long parts[2];
			} val;
			val.n = lua_tointeger(L, i);
			auto lo = val.parts[1];
			auto hi = val.parts[0];
			__asm
			{
				push hi
					push lo
			}
		}
		break;
		case TYPE_STRING:
		{
			auto val = lua_tostring(L, i);
			__asm push val;
		}
		break;
		}
		lua_pop(L, 1);
	}

	int return_;
	__asm call func_addr
	__asm mov return_, eax

	lua_pushinteger(L, return_);

	return 1;

}

int LGetModuleHandle(lua_State *L)
{
	HMODULE ret = GetModuleHandleA(lua_tostring(L, 1));
	lua_pushinteger(L, (lua_Integer)ret);
	return 1;
}

int LGetProcAddress(lua_State *L)
{
	HMODULE module = (HMODULE)lua_tointeger(L, 1);
	FARPROC ret = GetProcAddress(module, lua_tostring(L, 2));
	lua_pushinteger(L, (lua_Integer)ret);
	return 1;
}

int LGetLastError(lua_State *L)
{
	lua_pushinteger(L, GetLastError());
	return 1;
}

int LNewCdecl(lua_State *L)
{
	lua_pushvalue(L, 1);
	lua_pushvalue(L, 2);
	lua_pushcclosure(L, &cdecl_proxy, 2);
	return 1;
}

int LNewStdcall(lua_State *L)
{
	lua_pushvalue(L, 1);
	lua_pushvalue(L, 2);
	lua_pushcclosure(L, &stdcall_proxy, 2);
	return 1;
}

int LAlloc(lua_State *L)
{
	lua_pushinteger(L, (lua_Integer)malloc((size_t)lua_tointeger(L, 1)));
	return 1;
}

int LFree(lua_State *L)
{
	free((void *)lua_tointeger(L, 1));

	return 0;
}

int LWrite(lua_State *L)
{
	char *data = (char *)lua_tointeger(L, 1);

	size_t len;
	const char *written = lua_tolstring(L, 2, &len);

	while (len--)
		*data++ = *written++;

	return 0;
}

int LRead(lua_State *L)
{
	lua_pushlstring(L, (char *)lua_tointeger(L, 1), (size_t)lua_tointeger(L, 2));
	return 1;
}

int LIntToFloat32(lua_State *L)
{
	int num = (int)lua_tointeger(L, 1);
	lua_pushnumber(L, (lua_Number)*reinterpret_cast<float *>(&num));
	return 1;
}

int LIntToFloat64(lua_State *L)
{
	long long num = lua_tointeger(L, 1);
	lua_pushnumber(L, *reinterpret_cast<lua_Number *>(&num));
	return 1;
}

int LFloat32ToInt(lua_State *L)
{
	float num = (float)lua_tonumber(L, 1);
	lua_pushinteger(L, (lua_Integer)*reinterpret_cast<int *>(&num));
	return 1;
}

int LFloat64ToInt(lua_State *L)
{
	lua_Number num = lua_tonumber(L, 1);
	lua_pushinteger(L, (lua_Integer)*reinterpret_cast<long long *>(&num));
	return 1;
}

int LDecimalToString(lua_State *L)
{
	lua_Integer num = lua_tointeger(L, 1);
	lua_pushlstring(L, reinterpret_cast<char *>(&num), sizeof(num));
	return 1;
}

extern "C" int __declspec(dllexport) __cdecl luaopen_lua_5_3_winapi(lua_State *L)
{
	lua_pushglobal(L);

	// types
	lua_setwintype(L, FLOAT32);
	lua_setwintype(L, FLOAT64);

	lua_setwintype(L, INT8);
	lua_setwintype(L, INT16);
	lua_setwintype(L, INT32);
	lua_setwintype(L, INT64);

	lua_setwintype(L, PTR);

	lua_setwintype(L, STRING);

	lua_pushstring(L, "win");
	lua_newtable(L);
	// win table
	{

		// conventions

		lua_setwinconv(L, CDECL);
		lua_setwinconv(L, STDCALL);
		lua_setwinconv(L, THISCALL);

		lua_setlfunc(L, NewCdecl);
		lua_setlfunc(L, NewStdcall);
		lua_setlfunc(L, GetProcAddress);
		lua_setlfunc(L, GetModuleHandle);
		lua_setlfunc(L, Alloc);
		lua_setlfunc(L, Free);
		lua_setlfunc(L, Read);
		lua_setlfunc(L, Write);
		lua_setlfunc(L, IntToFloat32);
		lua_setlfunc(L, IntToFloat64);
		lua_setlfunc(L, Float32ToInt);
		lua_setlfunc(L, Float64ToInt);
		lua_setlfunc(L, DecimalToString);
		lua_setlfunc(L, GetLastError);
	}

	lua_settable(L, -3);

	return 0;
}