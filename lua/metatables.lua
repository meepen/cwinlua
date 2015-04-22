require"cwinlua";
require"xrefs";

local reading = reading;
local writing = writing;
_ENV.reading = nil;
_ENV.writing = nil;

getmetatable"".__index = function(self, k)
	if(type(k) == "number") then
		return self:sub(k,k);
	end
	return string[k];
end

local function num(x)
	if(type(x) == "number") then return x; end
	return x[1]:byte();
end

getmetatable"".__bor = function(self, o)
	return num(self) | num(o);
end

getmetatable"".__bxor = function(self, o)
	return num(self) ~ num(o);
end

getmetatable"".__bnot = function(self, o)
	return ~num(self);
end

getmetatable"".__shl = function(self, o)
	print(num(self));
	return num(self) << num(o);
end

getmetatable"".__shr = function(self, o)
	return num(self) >> num(o);
end

getmetatable""._lt = function(self, o)
	return num(self) < num(o);
end

getmetatable"".__le = function(self, o)
	return num(self) <= num(o);
end

getmetatable"".__unm = function(self, o)
	return -num(self);
end

getmetatable"".__idiv = function(self, o)
	return num(self) // num(o);
end

getmetatable"".__div = function(self, o)
	return num(self) / num(o);
end

getmetatable"".__mul = function(self, o)
	return num(self) * num(o);
end

getmetatable"".__add = function(self, o)
	return num(self) + num(o);
end

getmetatable"".__sub = function(self, o)
	return num(self) - num(o);
end

getmetatable"".__len = function(self)
	return self:len();
end

local NUM_MT = {};
debug.setmetatable(2, NUM_MT);
local IDX = {};
function NUM_MT:__index(k)
	if(IDX[k]) then return IDX[k]; end
end

local WriteProcessMemory = win.XRef("kernel32.dll", "WriteProcessMemory", {TYPE_PTR, TYPE_PTR, TYPE_PTR, TYPE_INT32, TYPE_PTR}, TYPE_STDCALL);
local ReadProcessMemory  = win.XRef("kernel32.dll", "ReadProcessMemory", {TYPE_PTR, TYPE_PTR, TYPE_PTR, TYPE_INT32, TYPE_PTR}, TYPE_STDCALL);


function IDX:Deref(handle)
	local ret;
	if(handle) then
		local memory = win.Alloc(4);
		if(ReadProcessMemory(handle, self, memory, 4, 0) == 0) then
			goto _end;
		end
		ret = reading.int32(memory);
		win.Free(memory);
	else -- assume it's in our process
		
		ret = reading.int32(self);
		
	end
	
	::_end::
	return ret;
end


function IDX:SetInt32(value, handle)
	local ret = true;
	if(handle) then
		
		local temp = win.Alloc(4);
		writing.int32(temp, value);
		ret = WriteProcessMemory(handle, self, temp, 4, 0) ~= 0; 
		win.Free(temp);
		
	else
		
		writing.int32(self, value);
		ret = true;
		
	end
	
	::_end::
	return ret;
end

function IDX:SetInt64(value, handle)
	local ret = true;
	if(handle) then
		
		local temp = win.Alloc(8);
		writing.int64(temp, value);
		ret = WriteProcessMemory(handle, self, temp, 8, 0) ~= 0; 
		win.Free(temp);
		
	else
		
		writing.int64(self, value);
		ret = true;
		
	end
	
	::_end::
	return ret;
end

function IDX:SetInt16(value, handle)
	local ret = true;
	if(handle) then
		
		local temp = win.Alloc(2);
		writing.int16(temp, value);
		ret = WriteProcessMemory(handle, self, temp, 2, 0) ~= 0; 
		win.Free(temp);
	else
		
		writing.int16(self, value);
		ret = true;
		
	end
	
	::_end::
	return ret;
end

function IDX:SetInt8(value, handle)
	local ret;
	if(handle) then
		local temp = win.Alloc(1);
		writing.int8(temp, value);
		ret = WriteProcessMemory(handle, self, temp, 1, 0) ~= 0; 
		win.Free(temp);
	else
		
		writing.int8(self, value);
		ret = true;
		
	end
	
	::_end::
	return ret;
end

function IDX:SetString(value, handle)
	local ret = true;
	
	if(handle) then
	
		local temp = win.Alloc(value:len());
		win.Write(temp, value);
	
		ret = WriteProcessMemory(handle, self, temp, value:len(), 0) ~= 0;
		
		win.Free(temp);
	else
		
		writing.char(self, value);
		
	end
	
	return ret;
	
end

function IDX:SetCString(value, handle)
	local ret = true;
	
	if(handle) then
	
		local temp = win.Alloc(value:len() + 1);
		win.Write(temp, value.."\x00");
	
		ret = WriteProcessMemory(handle, self, temp, value:len() + 1, 0) ~= 0;
		
		win.Free(temp);
	else
		
		writing.char(self, value);
		
	end
	
	return ret;
	
end

function IDX:ReadString(len, handle)
	local ret;
	
	if(handle) then 
		
		local temp = win.Alloc(len);
		ReadProcessMemory(handle, self, temp, len, 0);
		
		ret = win.Read(temp, len);
		win.Free(temp);
		
	else
		
		ret = win.Read(self, len);
		
	end
	
	return ret;
end

function IDX:ReadCString(handle)

	local ret;
	if(handle) then
		
		local temp = win.Alloc(1);
		ret = "";
		local addr = self;
		while true do
			ReadProcessMemory(handle, addr, temp, 1, 0);
			
			local chr = reading.char(temp, 1);
			if(chr == "\x00") then break; end
			ret = ret..chr;
			addr = addr + 1;
		end
		win.Free(temp);
		
	else
		
		ret = "";
		local addr = self;
		while true do
			local chr = reading.char(addr, 1);
			if(chr == "\x00") then break; end
			ret = ret..chr;
			addr = addr + 1;
		end
		
	end

	return ret;
end

function IDX:ReadInt32(handle)
	local ret;
	
	if(handle) then
		
		local temp = win.Alloc(4);
		ReadProcessMemory(handle, self, temp, 4, 0);
		
		ret = reading.int32(temp);
		win.Free(temp);
		
	else
		
		ret = reading.int32(self);
		
	end
	
	return ret;
	
end

function IDX:ReadInt16(handle)
	local ret;
	
	if(handle) then
		
		local temp = win.Alloc(2);
		ReadProcessMemory(handle, self, temp, 2, 0);
		
		ret = reading.int16(temp);
		win.Free(temp);
		
	else
		
		ret = reading.int16(self);
		
	end
	
	return ret;
	
end

function IDX:ReadInt8(handle)
	local ret;
	
	if(handle) then
		
		local temp = win.Alloc(1);
		ReadProcessMemory(handle, self, temp, 1, 0);
		
		ret = reading.int8(temp);
		win.Free(temp);
		
	else
		
		ret = reading.int8(self);
		
	end
	
	return ret;
	
end

function IDX:ReadInt64(handle)
	local ret;
	
	if(handle) then
		
		local temp = win.Alloc(8);
		ReadProcessMemory(handle, self, temp, 8, 0);
		
		ret = reading.int64(temp);
		win.Free(temp);
		
	else
		
		ret = reading.int64(self);
		
	end
	
	return ret;
	
end

function IDX:ReadFloat32(handle)
	return win.IntToFloat32(self:ReadInt32(handle));
end

function IDX:ReadFloat64(handle)
	return win.IntToFloat64(self:ReadInt64(handle));
end

function IDX:SetFloat32(value, handle)
	return self:SetInt32(win.Float32ToInt(value), handle);
end

function IDX:SetFloat64(value, handle)
	return self:SetInt64(win.Float64ToInt(value), handle);
end