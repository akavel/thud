local ffi = require 'ffi'
local C = ffi.C

if ffi.os ~= 'Windows' then
	print "Only Windows OS is currently supported..."
	return
end
local crt = require 'crt-win32'

crt.gotoxy(5, 3)
print('hello')

