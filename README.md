thud - extremely primitive console library for roguelike games. [LuaJIT, Win32 only now]

## Usage

    local thud = require 'thud-win32'  -- loads the library [LuaJIT required for FFI and bit libraries]
    
    thud.gotoxy(1, 1)  -- moves cursor to top-left corner of console window
    
    local k = thud.waitforkey() -- returns a table with fields:
    print(k.code) -- long name of pressed key (consult `vk` in `thud-win32.lua`), or number code if unknown
    print(k.char) -- character typed on keyboard ('A' for [Shift]-[A]), or nil if special key like [F1]
    print(k.alt, k.ctrl, k.shift) -- true or false, describes modifier keys used

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
