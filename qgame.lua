local thud = require 'thud-win32'
if not thud then
	print "We plea thy forgiveness, only Windows OS currently supported..."
	print ""
	print "But have a look at 'thud-win32.lua'. It's really dumb, you totally"
	print "should be able to hack something similarly primitive for this"
	print "Ohsogreat Platform of yours."
	return
end

local function NewGrid(w, h, default)
	return {
		w = w,
		h = h,
		default = default,
		set = function(self, x, y, value)
			self.rows = self.rows or {}
			self.rows[y] = self.rows[y] or {}
			self.rows[y][x] = value
		end,
		get = function(self, x, y)
			return self.rows and self.rows[y] and self.rows[y][x] or self.default
		end,
	}
end

local screen = {
	w = 80,
	h = 25,
}
function screen:set(x, y, char)
	if x==self.w and y==self.h then
		return -- error('setting bottom-right corner not allowed because of overflow')
	end
	self.dirty:set(x, y, char:sub(1, 1))
end
function screen:get(x, y)
	return self.dirty:get(x, y) or self.bg:get(x, y) or ' '
end
function screen:flush()
	for y=1,self.h do
		for x=1,self.w do
			local c = self.dirty:get(x, y)
			if c~=nil and (x~=self.w or y~=self.h) then
				thud.gotoxy(x, y)
				io.write(c)
				self.bg:set(x, y, c)
			end
			self.dirty:set(x, y, nil)
		end
	end
end
function screen:clear()
	self.bg = NewGrid(self.w, self.h)
	self.dirty = NewGrid(self.w, self.h)
	for y=1,self.h-1 do
		thud.gotoxy(1, y)
		io.write((' '):rep(self.w))
	end
	thud.gotoxy(1, self.h)
	io.write((' '):rep(self.w-1))
end

function main()
	local player = {x=10, y=10}
	screen:clear()
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
				screen:clear()
				thud.gotoxy(1, 1)
				print('Bye.')
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
