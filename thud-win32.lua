--[[
thud - extremely primitive console library for roguelike games.

## MIT License
Copyright (c) 2012  Mateusz Czapliński <czapkofan@gmail.com>
Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]

local ffi = require 'ffi'
local C = ffi.C
local bit = require 'bit'

if ffi.os ~= 'Windows' then
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
typedef DWORD *LPDWORD;
typedef uint32_t UINT; // FIXME ok?
typedef wchar_t WCHAR; // uint16_t?
typedef uint16_t WORD;
typedef char CHAR; // uint8_t?
]]

ffi.cdef [[
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

DWORD GetLastError(void);
]]

local STD_INPUT_HANDLE = ffi.new('DWORD', -10)
local STD_OUTPUT_HANDLE = ffi.new('DWORD', -11)
local cout = C.GetStdHandle(STD_OUTPUT_HANDLE)
local cin = C.GetStdHandle(STD_INPUT_HANDLE)

local function gotoxy(x, y)
	x = x>0 and x-1 or x
	y = y>0 and y-1 or y
	C.SetConsoleCursorPosition(cout, ffi.new('COORD', x, y))
end


ffi.cdef [[
typedef struct _FOCUS_EVENT_RECORD {
  BOOL bSetFocus;
} FOCUS_EVENT_RECORD;

typedef struct _KEY_EVENT_RECORD {
  BOOL  bKeyDown;
  WORD  wRepeatCount;
  WORD  wVirtualKeyCode;
  WORD  wVirtualScanCode;
  union {
    WCHAR UnicodeChar;
    CHAR  AsciiChar;
  } uChar;
  DWORD dwControlKeyState;
} KEY_EVENT_RECORD;

typedef struct _MENU_EVENT_RECORD {
  UINT dwCommandId;
} MENU_EVENT_RECORD, *PMENU_EVENT_RECORD;

typedef struct _MOUSE_EVENT_RECORD {
  COORD dwMousePosition;
  DWORD dwButtonState;
  DWORD dwControlKeyState;
  DWORD dwEventFlags;
} MOUSE_EVENT_RECORD;

typedef struct _WINDOW_BUFFER_SIZE_RECORD {
  COORD dwSize;
} WINDOW_BUFFER_SIZE_RECORD;
typedef struct _INPUT_RECORD {
  WORD  EventType;
  union {
    KEY_EVENT_RECORD          KeyEvent;
    MOUSE_EVENT_RECORD        MouseEvent;
    WINDOW_BUFFER_SIZE_RECORD WindowBufferSizeEvent;
    MENU_EVENT_RECORD         MenuEvent;
    FOCUS_EVENT_RECORD        FocusEvent;
  } Event;
} INPUT_RECORD, *PINPUT_RECORD;

BOOL ReadConsoleInputA(
  HANDLE hConsoleInput,
  PINPUT_RECORD lpBuffer,
  DWORD nLength,
  LPDWORD lpNumberOfEventsRead
);
]]

local vk = {
--lbutton=0x01,	--Left mouse button
--rbutton=0x02,	--Right mouse button
--cancel=0x03,	--Control-break processing
--mbutton=0x04,	--Middle mouse button (three-button mouse)
back=0x08,	--BACKSPACE key
tab=0x09,	--TAB key
--clear=0x0c,	--CLEAR key
['return']=0x0d,	--ENTER key
shift=0x10,	--SHIFT key
control=0x11,	--CTRL key
menu=0x12,	--ALT key
pause=0x13,	--PAUSE key
capital=0x14,	--CAPS LOCK key
escape=0x1b,	--ESC key
space=0x20,	--SPACEBAR
prior=0x21,	--PAGE UP key
next=0x22,	--PAGE DOWN key
['end']=0x23,	--END key
home=0x24,	--HOME key
left=0x25,	--LEFT ARROW key
up=0x26,	--UP ARROW key
right=0x27,	--RIGHT ARROW key
down=0x28,	--DOWN ARROW key
select=0x29,	--SELECT key
print=0x2a,	--PRINT key
execute=0x2b,	--EXECUTE key
snapshot=0x2c,	--PRINT SCREEN key
insert=0x2d,	--INS key
delete=0x2e,	--DEL key
help=0x2f,	--HELP key
['0']=0x30,	--0 key
['1']=0x31,	--1 key
['2']=0x32,	--2 key
['3']=0x33,	--3 key
['4']=0x34,	--4 key
['5']=0x35,	--5 key
['6']=0x36,	--6 key
['7']=0x37,	--7 key
['8']=0x38,	--8 key
['9']=0x39,	--9 key
a=0x41,	--A key
b=0x42,	--B key
c=0x43,	--C key
d=0x44,	--D key
e=0x45,	--E key
f=0x46,	--F key
g=0x47,	--G key
h=0x48,	--H key
i=0x49,	--I key
j=0x4a,	--J key
k=0x4b,	--K key
l=0x4c,	--L key
m=0x4d,	--M key
n=0x4e,	--N key
o=0x4f,	--O key
p=0x50,	--P key
q=0x51,	--Q key
r=0x52,	--R key
s=0x53,	--S key
t=0x54,	--T key
u=0x55,	--U key
v=0x56,	--V key
w=0x57,	--W key
x=0x58,	--X key
y=0x59,	--Y key
z=0x5a,	--Z key
numpad0=0x60,	--Numeric keypad 0 key
numpad1=0x61,	--Numeric keypad 1 key
numpad2=0x62,	--Numeric keypad 2 key
numpad3=0x63,	--Numeric keypad 3 key
numpad4=0x64,	--Numeric keypad 4 key
numpad5=0x65,	--Numeric keypad 5 key
numpad6=0x66,	--Numeric keypad 6 key
numpad7=0x67,	--Numeric keypad 7 key
numpad8=0x68,	--Numeric keypad 8 key
numpad9=0x69,	--Numeric keypad 9 key
separator=0x6c,	--Separator key
subtract=0x6d,	--Subtract key
decimal=0x6e,	--Decimal key
divide=0x6f,	--Divide key
f1=0x70,	--F1 key
f2=0x71,	--F2 key
f3=0x72,	--F3 key
f4=0x73,	--F4 key
f5=0x74,	--F5 key
f6=0x75,	--F6 key
f7=0x76,	--F7 key
f8=0x77,	--F8 key
f9=0x78,	--F9 key
f10=0x79,	--F10 key
f11=0x7a,	--F11 key
f12=0x7b,	--F12 key
f13=0x7c,	--F13 key
f14=0x7d,	--F14 key
f15=0x7e,	--F15 key
f16=0x7f,	--F16 key
f17=0x80, --F17 key
f18=0x81, --F18 key
f19=0x82, --F19 key
f20=0x83, --F20 key
f21=0x84, --F21 key
f22=0x85, --F22 key
f23=0x86, --F23 key
f24=0x87, --F24 key
numlock=0x90,	--NUM LOCK key
scroll=0x91,	--SCROLL LOCK key
lshift=0xa0,	--Left SHIFT key
rshift=0xa1,	--Right SHIFT key
lcontrol=0xa2,	--Left CONTROL key
rcontrol=0xa3,	--Right CONTROL key
lmenu=0xa4,	--Left MENU key
rmenu=0xa5,	--Right MENU key
play=0xfa,	--Play key
zoom=0xfb,	--Zoom key
}

local vk_reverse = {}
for name, val in pairs(vk) do
	vk_reverse[val] = name
end

local vk_special = {
	[vk.shift] = true,
	[vk.menu] = true,
	[vk.control] = true,
	[vk.capital] = true,
	[vk.numlock] = true,
	[vk.scroll] = true,
}

local RIGHT_ALT_PRESSED = 0x01
local LEFT_ALT_PRESSED = 0x02
local RIGHT_CTRL_PRESSED = 0x04
local LEFT_CTRL_PRESSED = 0x08
local SHIFT_PRESSED = 0x10

local function waitforkey()
	local inputrec = ffi.new 'INPUT_RECORD'
	local ret = C.ReadConsoleInputA(cin, inputrec, 1, ffi.new('DWORD[1]'))
	if ret == 0 then
		error('Windows Error #'..C.GetLastError())
	end
	if inputrec.EventType ~= 1 then
		return waitforkey()
	end

	local evt = inputrec.Event.KeyEvent
	if evt.bKeyDown==0 or vk_special[evt.wVirtualKeyCode] then
		return waitforkey()
	end

	local char = evt.uChar.AsciiChar
	local controls = evt.dwControlKeyState
	return {
		code = vk_reverse[evt.wVirtualKeyCode] or evt.wVirtualKeyCode,
		char = char~=0 and string.char(char) or nil,
		alt = bit.band(controls, RIGHT_ALT_PRESSED+LEFT_ALT_PRESSED)>0,
		ctrl = bit.band(controls, RIGHT_CTRL_PRESSED+LEFT_CTRL_PRESSED)>0,
		shift = bit.band(controls, SHIFT_PRESSED)>0,
	}
end

return {
	waitforkey = waitforkey,
	gotoxy = gotoxy,
}
