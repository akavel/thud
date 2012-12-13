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
LBUTTON=0x01,	--Left mouse button
RBUTTON=0x02,	--Right mouse button
CANCEL=0x03,	--Control-break processing
MBUTTON=0x04,	--Middle mouse button (three-button mouse)
BACK=0x08,	--BACKSPACE key
TAB=0x09,	--TAB key
CLEAR=0x0C,	--CLEAR key
RETURN=0x0D,	--ENTER key
SHIFT=0x10,	--SHIFT key
CONTROL=0x11,	--CTRL key
MENU=0x12,	--ALT key
PAUSE=0x13,	--PAUSE key
CAPITAL=0x14,	--CAPS LOCK key
ESCAPE=0x1B,	--ESC key
SPACE=0x20,	--SPACEBAR
PRIOR=0x21,	--PAGE UP key
NEXT=0x22,	--PAGE DOWN key
END=0x23,	--END key
HOME=0x24,	--HOME key
LEFT=0x25,	--LEFT ARROW key
UP=0x26,	--UP ARROW key
RIGHT=0x27,	--RIGHT ARROW key
DOWN=0x28,	--DOWN ARROW key
SELECT=0x29,	--SELECT key
PRINT=0x2A,	--PRINT key
EXECUTE=0x2B,	--EXECUTE key
SNAPSHOT=0x2C,	--PRINT SCREEN key
INSERT=0x2D,	--INS key
DELETE=0x2E,	--DEL key
HELP=0x2F,	--HELP key
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
A=0x41,	--A key
B=0x42,	--B key
C=0x43,	--C key
D=0x44,	--D key
E=0x45,	--E key
F=0x46,	--F key
G=0x47,	--G key
H=0x48,	--H key
I=0x49,	--I key
J=0x4A,	--J key
K=0x4B,	--K key
L=0x4C,	--L key
M=0x4D,	--M key
N=0x4E,	--N key
O=0x4F,	--O key
P=0x50,	--P key
Q=0x51,	--Q key
R=0x52,	--R key
S=0x53,	--S key
T=0x54,	--T key
U=0x55,	--U key
V=0x56,	--V key
W=0x57,	--W key
X=0x58,	--X key
Y=0x59,	--Y key
Z=0x5A,	--Z key
NUMPAD0=0x60,	--Numeric keypad 0 key
NUMPAD1=0x61,	--Numeric keypad 1 key
NUMPAD2=0x62,	--Numeric keypad 2 key
NUMPAD3=0x63,	--Numeric keypad 3 key
NUMPAD4=0x64,	--Numeric keypad 4 key
NUMPAD5=0x65,	--Numeric keypad 5 key
NUMPAD6=0x66,	--Numeric keypad 6 key
NUMPAD7=0x67,	--Numeric keypad 7 key
NUMPAD8=0x68,	--Numeric keypad 8 key
NUMPAD9=0x69,	--Numeric keypad 9 key
SEPARATOR=0x6C,	--Separator key
SUBTRACT=0x6D,	--Subtract key
DECIMAL=0x6E,	--Decimal key
DIVIDE=0x6F,	--Divide key
F1=0x70,	--F1 key
F2=0x71,	--F2 key
F3=0x72,	--F3 key
F4=0x73,	--F4 key
F5=0x74,	--F5 key
F6=0x75,	--F6 key
F7=0x76,	--F7 key
F8=0x77,	--F8 key
F9=0x78,	--F9 key
F10=0x79,	--F10 key
F11=0x7A,	--F11 key
F12=0x7B,	--F12 key
F13=0x7C,	--F13 key
F14=0x7D,	--F14 key
F15=0x7E,	--F15 key
F16=0x7F,	--F16 key
F17=0x80, --F17 key
F18=0x81, --F18 key
F19=0x82, --F19 key
F20=0x83, --F20 key
F21=0x84, --F21 key
F22=0x85, --F22 key
F23=0x86, --F23 key
F24=0x87, --F24 key
NUMLOCK=0x90,	--NUM LOCK key
SCROLL=0x91,	--SCROLL LOCK key
LSHIFT=0xA0,	--Left SHIFT key
RSHIFT=0xA1,	--Right SHIFT key
LCONTROL=0xA2,	--Left CONTROL key
RCONTROL=0xA3,	--Right CONTROL key
LMENU=0xA4,	--Left MENU key
RMENU=0xA5,	--Right MENU key
PLAY=0xFA,	--Play key
ZOOM=0xFB,	--Zoom key
}

local vk_reverse = {}
for name, val in pairs(vk) do
	vk_reverse[val] = name:lower()
end

local vk_special = {
	[vk.SHIFT] = true,
	[vk.MENU] = true,
	[vk.CONTROL] = true,
	[vk.CAPITAL] = true,
	[vk.NUMLOCK] = true,
	[vk.SCROLL] = true,
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
		code = vk_reverse[evt.wVirtualKeyCode],
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
