require"cwinlua"
require"xrefs"

Beep = win.XRef("kernel32.dll", "Beep", {TYPE_INT32, TYPE_INT32}, TYPE_STDCALL);

Beep(1000,1000);