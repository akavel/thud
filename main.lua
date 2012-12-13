local ffi = require 'ffi'
local C = ffi.C

local crt = require 'crt-win32'

if not crt then
	print "We plea thy forgiveness, only Windows OS currently supported..."
	print ""
	print "But have a look at 'crt-win32.lua'. It's really dumb, you totally"
	print "should be able to hack something similarly primitive for this"
	print "Ohsogreat Platform of yours."
	return
end

crt.gotoxy(5, 3)
print('hello')
for i=1,5 do
	print(i, crt.readkey())
end
