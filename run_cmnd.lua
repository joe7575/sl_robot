--[[

	sl_robot
	========

	Copyright (C) 2018 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information

	run_cmnd.lua:
	
	Register the run command

]]--

local function Reverse(arr)
	local i, j = 1, #arr

	while i < j do
		arr[i], arr[j] = arr[j], arr[i]

		i = i + 1
		j = j - 1
	end
end

local switch = {
	f = function(self, cmnd) 
		local num = (cmnd:byte(2) or  0x31) - 0x30
		sl_robot.move(self.meta.pos, 1, num)
	end,
	b = function(self, cmnd) 
		local num = (cmnd:byte(2) or 0x31) - 0x30
		sl_robot.move(self.meta.pos, -1, num)
	end,
	l = function(self, cmnd, reverse) 
		if reverse then
			sl_robot.turn(self.meta.pos, "R")
		else
			sl_robot.turn(self.meta.pos, "L")
		end
	end,
	r = function(self, cmnd, reverse) 
		if reverse then
			sl_robot.turn(self.meta.pos, "L")
		else
			sl_robot.turn(self.meta.pos, "R")
		end
	end,
	u = function(self, cmnd) 
		sl_robot.lift(self.meta.pos, "up")
	end,
	d = function(self, cmnd) 
		sl_robot.lift(self.meta.pos, "dn")
	end,
	t = function(self, cmnd) 
		local num, slot
		if cmnd:sub(2,2) == "s" then
			num = 99
			slot = (cmnd:byte(3) or 0x31) - 0x30
		else
			num = 1
			slot = (cmnd:byte(2) or 0x31) - 0x30
		end
		sl_robot.take(self.meta.pos, self.meta.owner, slot, num)
	end,
	a = function(self, cmnd) 
		local num, slot
		if cmnd:sub(2,2) == "s" then
			num = 99
			slot = (cmnd:byte(3) or 0x31) - 0x30
		else
			num = 1
			slot = (cmnd:byte(2) or 0x31) - 0x30
		end
		sl_robot.add(self.meta.pos, self.meta.owner, slot, num)
	end,
	p = function(self, cmnd) 
		local num, slot
		if cmnd:sub(2,2) == "u" then
			slot = (cmnd:byte(3) or 0x31) - 0x30
			sl_robot.place(self.meta.pos, self.meta.owner, slot, "U")
		elseif cmnd:sub(2,2) == "d" then
			slot = (cmnd:byte(3) or 0x31) - 0x30
			sl_robot.place(self.meta.pos, self.meta.owner, slot, "D")
		else
			slot = (cmnd:byte(2) or 0x31) - 0x30
			sl_robot.place(self.meta.pos, self.meta.owner, slot, "-")
		end
	end,
	x = function(self, cmnd) 
		local num, slot
		if cmnd:sub(2,2) == "u" then
			slot = (cmnd:byte(3) or 0x31) - 0x30
			sl_robot.dig(self.meta.pos, self.meta.owner, slot, "U")
		elseif cmnd:sub(2,2) == "d" then
			slot = (cmnd:byte(3) or 0x31) - 0x30
			sl_robot.dig(self.meta.pos, self.meta.owner, slot, "D")
		else
			slot = (cmnd:byte(2) or 0x31) - 0x30
			sl_robot.dig(self.meta.pos, self.meta.owner, slot, "-")
		end
	end,
	e = function(self, cmnd)
		print(cmnd.." is a invalid command")
	end,
}

sl_robot.register_action("run", {
	cmnd = function(self, sCmndList, reverse)
		sCmndList = sCmndList:gsub("\n", " ")
		sCmndList = sCmndList:gsub("\t", " ")
		local cmnds = sCmndList:split(" ")
		if reverse then
			Reverse(cmnds)
		end
		for i,cmnd in ipairs(cmnds) do
			(switch[cmnd:sub(1,1)] or switch["e"])(self, cmnd, reverse)
		end
	end,
	help = " "
})
