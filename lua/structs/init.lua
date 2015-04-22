require"cwinlua";

require"readwrite";
require"metatables";

local sizes = {
	int64   = 8,
	int32   = 4,
	int16   = 2,
	int8    = 1,
	int     = 4,
	float32 = 4,
	float   = 4,
	float64 = 8,
	double  = 8,
	ptr     = 4,
	char    = 1,
};

local reading = {
	ptr = function(addr, size, handle)
		return addr:ReadInt32(handle);
	end,
	int32 = function(addr, size, handle)
		return addr:ReadInt32(handle);
	end,
	int = function(addr, size, handle)
		return addr:ReadInt32(handle);
	end,
	int16 = function(addr, size, handle)
		return addr:ReadInt16(handle);
	end,
	int8 = function(addr, size, handle)
		return addr:ReadInt8(handle);
	end,
	int64 = function(addr, size, handle)
		return addr:ReadInt64(handle);
	end,
	float32 = function(addr, size, handle)
		return addr:ReadFloat32(handle);
	end,
	float = function(addr, size, handle)
		return addr:ReadFloat32(handle);
	end,
	float64 = function(addr, size, handle)
		return addr:ReadFloat64(handle);
	end,
	double = function(addr, size, handle)
		return addr:ReadFloat64(handle);
	end,
	char = function(addr, size, handle)
		return addr:ReadCString(handle);
	end,
};

local writing = {
	ptr = function(addr, value, size, handle)
		return addr:SetInt32(value, handle);
	end,
	int32 = function(addr, value, size, handle)
		return addr:SetInt32(value, handle);
	end,
	int = function(addr, value, size, handle)
		return addr:SetInt32(value, handle);
	end,
	int16 = function(addr, value, size, handle)
		return addr:SetInt16(value, handle);
	end,
	int8 = function(addr, value, size, handle)
		return addr:SetInt8(value, handle);
	end,
	int64 = function(addr, value, size, handle)
		return addr:SetInt64(value, handle);
	end,
	float32 = function(addr, value, size, handle)
		return addr:SetFloat32(value, handle);
	end,
	float = function(addr, value, size, handle)
		return addr:SetFloat32(value, handle);
	end,
	float64 = function(addr, value, size, handle)
		return addr:SetFloat64(handle);
	end,
	double = function(addr, value, size, handle)
		return addr:SetFloat64(handle);
	end,
	char = function(addr, value, size, handle)
		return addr:SetCString(value, handle);
	end,
};


function win.Parse(fname, env)
	local f = io.open(fname);
	
	local data = f:read("*all");
	
	local name, offset, datatype;
	local instruct = false;
	local current = {};
	
	local structsizes = {};
	
	for text in data:gmatch("([^\r\n%s]+)") do
		
		if(not name) then
			name = text;
		elseif(not instruct) then
			assert(text == "{");
			instruct = true;
			offset = 0;
		else
			
			if(text == "}") then
				instruct = false;
				local struct = current;
				current = {};
				local offset = offset;
				local function f(addr, handle)
					
					return setmetatable({addr}, {
						__add = function(self, n)
							return f(self[1] + offset * n, handle);
						end,
						__index = function(self, k)
						
							assert(struct[k]);
							
							local member = struct[k];
							local read = reading[member[1]];
							
							return read(self[1] + member[2], member[3], handle);
							
						end,
						__newindex = function(self, k, v)
							assert(struct[k]);
							local member = struct[k];
							local write = writing[member[1]];
							
							assert(member[1] ~= "char" or v:len() <= member[3]);
							
							write(self[1] + member[2], v, member[3], handle);
						end
					});
					
				end
				env[name] = f;
				structsizes[name] = offset;
				
				name = nil;
			elseif(not datatype) then
				datatype = text;
			else
				local size = sizes[datatype];
				if(datatype:sub(1,4) == "char") then
					size = tonumber(datatype:sub(6, -2));
					datatype = "char";
				end
				current[text] = {datatype, offset, size};
				
				assert(sizes[datatype], datatype.." doesn't exist!");
				offset = offset + size;
				datatype = nil;
				
			end
			
		end
		
	end
	
	env.sizes = env.sizes or {};
	for k,v in pairs(structsizes) do
		env.sizes[k] = v;
	end
	
end