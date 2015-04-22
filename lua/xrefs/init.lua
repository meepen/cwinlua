function win.XRef(dll, name, args, type)
	if(type == TYPE_STDCALL) then
		return win.NewStdcall(win.GetProcAddress(win.GetModuleHandle(dll), name), args or {});
	end
	return win.NewCdecl(win.GetProcAddress(win.GetModuleHandle(dll), name), args or {});
end