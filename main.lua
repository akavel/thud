local ffi = require 'ffi'
local C = ffi.C

if ffi.os ~= 'Windows' then
	print "Only Windows OS is currently supported..."
	return
end

-- http://svn.freepascal.org/cgi-bin/viewvc.cgi/trunk/rtl/win/crt.pp?revision=21738&view=markup

ffi.cdef [[
// http://msdn.microsoft.com/en-us/library/windows/desktop/aa383751%28v=vs.85%29.aspx
typedef void *PVOID;
typedef PVOID HANDLE;
typedef uint32_t DWORD;
typedef int BOOL;
typedef int16_t SHORT;

HANDLE GetStdHandle(
  DWORD nStdHandle
);

typedef struct _COORD {
  SHORT X;
  SHORT Y;
} COORD, *PCOORD;

BOOL SetConsoleCursorPosition(
  HANDLE hConsoleOutput,
  COORD dwCursorPosition
);
]]

local win32 = {
	STD_INPUT_HANDLE = ffi.new('DWORD', -10),
	STD_OUTPUT_HANDLE = ffi.new('DWORD', -11),
}

--print(tonumber(win32.STD_INPUT_HANDLE))
local out = C.GetStdHandle(win32.STD_OUTPUT_HANDLE)
ffi.C.SetConsoleCursorPosition(out, ffi.new('COORD', 3, 10))
print('hello')

