local thud = require 'thud-win32'
if not thud then
	print "We plea thy forgiveness, only Windows OS currently supported..."
	print ""
	print "But have a look at 'thud-win32.lua'. It's really dumb, you totally"
	print "should be able to hack something similarly primitive for this"
	print "Ohsogreat Platform of yours."
	return
end

local screen = {w=80, h=25}
function screen:set(x, y, char)
	if x==self.w and y==self.h then
		return
		-- error('setting bottom-right corner not allowed because of overflow')
	end
	local rows = self.rows or {}
	self.rows = rows

	local row = rows[y] or {}
	rows[y] = row

	row[x] = char:sub(1, 1)
end
function screen:clear()
	self.rows = {}
end
function screen:get(x, y)
	if not self.rows then
		return ' '
	end
	local row = self.rows[y]
	if not row then
		return ' '
	end
	return row[x] or ' '
end
function screen:flush()
	for y=1,self.h-1 do
		thud.gotoxy(1, y)
		for x=1,self.w do
			io.write(self:get(x, y))
		end
	end
	thud.gotoxy(1, self.h)
	for x=1,self.w-1 do
		io.write(self:get(x, self.h))
	end
end

function main()
	local player = {x=10, y=10}
	for x=5,15 do
		for y=5,15 do
			screen:set(x, y, '.')
		end
	end

	while true do
		screen:set(player.x, player.y, '@')
		screen:flush()
		thud.gotoxy(player.x, player.y)

		local k = thud.waitforkey()

		if k.char=='q' then
			thud.gotoxy(1, 1)
			io.write('Quit without saving? [yN] ')
			if thud.waitforkey().char=='y' then
				thud.gotoxy(1, screen.h)
				print('\nBye.')
				return
			end
		end

		local lastpos = {x=player.x, y=player.y}
		screen:set(player.x, player.y, '.')
		if k.code=='right' or k.char=='6' or k.char=='l' then
			player.x = player.x + 1
		elseif k.code=='left' or k.char=='4' or k.char=='h' then
			player.x = player.x - 1
		elseif k.code=='up' or k.char=='8' or k.char=='k' then
			player.y = player.y - 1
		elseif k.code=='down' or k.char=='2' or k.char=='j' then
			player.y = player.y + 1
		end
		if screen:get(player.x, player.y) ~= '.' then
			screen:set(player.x, player.y, '#')
			player.x, player.y = lastpos.x, lastpos.y
		end
	end
end

main()
