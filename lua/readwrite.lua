require"cwinlua";

reading = {
	int64 = function(addr)
		local data = win.Read(addr, 8);
		return data[1]:byte() | (data[2]:byte() << 8)
			| (data[3]:byte() << 16) | (data[4]:byte() << 24)
				| (data[5]:byte() << 32) | (data[6]:byte() << 40)
					| (data[7]:byte() << 48) | (data[8]:byte() << 56);
	end,
	int32 = function(addr)
		local data = win.Read(addr, 4);
		return data[1]:byte() | (data[2]:byte() << 8) | (data[3]:byte() << 16) | (data[4]:byte() << 24);
	end,
	int16 = function(addr)
		local data = win.Read(addr, 2);
		return data[1]:byte() | (data[2]:byte() << 8);
	end,
	int8 = function(addr)
		return win.Read(addr,1):byte();
	end,
	char = function(addr, len)
		return win.Read(addr,1);
	end,
};
reading.float32 = function(addr)
	return win.IntToFloat32(reading.int32(addr));
end
reading.float64 = function(addr)
	return win.IntToFloat64(reading.int64(addr));
end
reading.float = reading.float32;
reading.double = reading.float64;
reading.int = reading.int32;
reading.ptr = reading.int32;

writing = {};

function writing.int64(addr, n)
	win.Write(addr, win.DecimalToString(n):sub(1,8));
end

function writing.int32(addr, n)
	win.Write(addr, win.DecimalToString(n):sub(1,4));
end

function writing.int16(addr, n)
	win.Write(addr, win.DecimalToString(n):sub(1,2));
end

function writing.int8(addr, n)
	win.Write(addr, win.DecimalToString(n):sub(1,1));
end

function writing.float32(addr, n)
	win.Write(addr, win.DecimalToString(win.Float32ToInt(n)):sub(1,4));
end

function writing.float64(addr, n)
	win.Write(addr, win.DecimalToString(win.Float64ToInt(n)):sub(1,8));
end

writing.char = function(addr, c)
	win.Write(addr, c);
end

writing.double = writing.float64;
writing.float = writing.float32;
writing.ptr = writing.int32;
writing.int = writing.int32;