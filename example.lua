local ffi = require 'ffi'
local C = ffi.C

local thud = require 'thud-win32'

if not thud then
	print "We plea thy forgiveness, only Windows OS currently supported..."
	print ""
	print "But have a look at 'thud-win32.lua'. It's really dumb, you totally"
	print "should be able to hack something similarly primitive for this"
	print "Ohsogreat Platform of yours."
	return
end

thud.gotoxy(1, 1)
io.write(('....\n'):rep(4))
thud.gotoxy(3, 3)
io.write('@')

thud.gotoxy(1, 5)
for i=1,5 do
	io.write(i..'\t')
	for k,v in pairs(thud.waitforkey()) do
		io.write(tostring(k)..'='..tostring(v)..' ')
	end
	print()
end
