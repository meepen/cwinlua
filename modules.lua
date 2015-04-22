require"cwinlua"
require"xrefs"
require"structs"

CreateToolhelp32Snapshot = win.XRef("kernel32.dll", "CreateToolhelp32Snapshot", {TYPE_INT32, TYPE_INT32}, TYPE_STDCALL);
Process32First           = win.XRef("kernel32.dll", "Process32First", {TYPE_PTR, TYPE_PTR}, TYPE_STDCALL);
Process32Next            = win.XRef("kernel32.dll", "Process32Next", {TYPE_PTR, TYPE_PTR}, TYPE_STDCALL);
CloseHandle              = win.XRef("kernel32.dll", "CloseHandle", {TYPE_PTR}, TYPE_STDCALL);

win.Parse("structs/win.luap", _ENV);

local snap = CreateToolhelp32Snapshot(0x2, 0);

local processentry = PROCESSENTRY32(win.Alloc(sizes.PROCESSENTRY32));
processentry.structsize = sizes.PROCESSENTRY32;


if(Process32First(snap, processentry[1]) ~= 0) then
	repeat
		print(processentry.exe);
	until(Process32Next(snap, processentry[1]) == 0)
end

win.Free(processentry[1]);
CloseHandle(snap);

