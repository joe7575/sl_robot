--[[

	sl_robot
	========

	Copyright (C) 2018 Joachim Stolberg

	LGPLv2.1+
	See LICENSE.txt for more information

	commands.lua:
	
	Register all robot commands

]]--

-- constrict value to the given range
local function range(val, min, max)
	val = tonumber(val)
	if val < min then return min end
	if val > max then return max end
	return val
end

local function one_of(val, selection)
	for _,v in ipairs(selection) do
		if val == v then return val end
	end
	return selection[1]
end

function sl_robot.move(pos, dir, steps)
	steps = range(steps, 1, 100)
	local idx = 1
	while idx <= steps do
		local meta = minetest.get_meta(pos)
		local robot_pos = minetest.string_to_pos(meta:get_string("robot_pos"))
		local robot_param2 = meta:get_int("robot_param2")
		local new_pos = sl_robot.move_robot(robot_pos, robot_param2, 1)
		if new_pos then  -- not blocked?
			if new_pos.y == robot_pos.y then  -- forward move?
				idx = idx + 1
			end
			meta:set_string("robot_pos", minetest.pos_to_string(new_pos))
			--minetest.log("action", "[robby] forward "..meta:get_string("robot_pos"))
		end
		coroutine.yield()
	end
end

function sl_robot.turn(pos, dir)
	local meta = minetest.get_meta(pos)
	local robot_pos = minetest.string_to_pos(meta:get_string("robot_pos"))
	local robot_param2 = meta:get_int("robot_param2")
	robot_param2 = sl_robot.turn_robot(robot_pos, robot_param2, dir)
	meta:set_int("robot_param2", robot_param2)
	--minetest.log("action", "[robby] left "..meta:get_string("robot_pos"))
	coroutine.yield()
end

function sl_robot.lift(pos, dir)
	local meta = minetest.get_meta(pos)
	local robot_pos = minetest.string_to_pos(meta:get_string("robot_pos"))
	local robot_param2 = meta:get_int("robot_param2")
	local new_pos
	while true do
		if dir == "up" then
			new_pos = sl_robot.robot_up(robot_pos, robot_param2)
		else
			new_pos = sl_robot.robot_down(robot_pos, robot_param2)
		end
		if new_pos then break end
		coroutine.yield()
	end
	meta:set_string("robot_pos", minetest.pos_to_string(new_pos))
	--minetest.log("action", "[robby] up "..meta:get_string("robot_pos"))
	coroutine.yield()
end

function sl_robot.take(pos, owner, slot, num)
	num = range(num, 1, 99)
	slot = range(slot, 1, 8)
	local meta = minetest.get_meta(pos)
	local robot_pos = minetest.string_to_pos(meta:get_string("robot_pos"))
	local robot_param2 = meta:get_int("robot_param2")
	sl_robot.robot_take(pos, robot_pos, robot_param2, owner, num, slot)
	minetest.log("action", "[robby] take "..meta:get_string("robot_pos"))
	coroutine.yield()
end

function sl_robot.add(pos, owner, slot, num)
	num = range(num, 1, 99)
	slot = range(slot, 1, 8)
	local meta = minetest.get_meta(pos)
	local robot_pos = minetest.string_to_pos(meta:get_string("robot_pos"))
	local robot_param2 = meta:get_int("robot_param2")
	sl_robot.robot_add(pos, robot_pos, robot_param2, owner, num, slot)
	minetest.log("action", "[robby] add "..meta:get_string("robot_pos"))
	coroutine.yield()
end

function sl_robot.place(pos, owner, slot, dir)
	slot = range(slot, 1, 8)
	dir = one_of(dir, {"-", "U", "D"})
	local meta = minetest.get_meta(pos)
	local robot_pos = minetest.string_to_pos(meta:get_string("robot_pos"))
	local robot_param2 = meta:get_int("robot_param2")
	sl_robot.robot_place(pos, robot_pos, robot_param2, owner, dir, slot)
	minetest.log("action", "[robby] place "..meta:get_string("robot_pos"))
	coroutine.yield()
end

function sl_robot.dig(pos, owner, slot, dir)
	slot = range(slot, 1, 8)
	print("sl_robot.dig", dir)
	dir = one_of(dir, {"-", "U", "D"})
	print("sl_robot.dig", dir)
	local meta = minetest.get_meta(pos)
	local robot_pos = minetest.string_to_pos(meta:get_string("robot_pos"))
	local robot_param2 = meta:get_int("robot_param2")
	sl_robot.robot_dig(pos, robot_pos, robot_param2, owner, dir, slot)
	minetest.log("action", "[robby] dig "..meta:get_string("robot_pos"))
	coroutine.yield()
end

sl_robot.register_action("get_ms_time", {
	cmnd = function(self)
		return math.floor(minetest.get_us_time() / 1000)
	end,
	help = "$get_ms_time()\n"..
		" returns time with millisecond precision."
})

sl_robot.register_action("forward", {
	cmnd = function(self, steps)
		sl_robot.move(self.meta.pos, 1, steps)
	end,
	help = " go one (or more) steps forward\n"..
		" Syntax: $forward(<steps>)\n"..
		" Example: $forward(4)"
})

sl_robot.register_action("backward", {
	cmnd = function(self, steps)
		sl_robot.move(self.meta.pos, -1, steps)
	end,
	help = " go one (or more) steps backward\n"..
		" Syntax: $backward(<steps>)\n"..
		" Example: $backward(4)"
})

sl_robot.register_action("left", {
	cmnd = function(self)
		sl_robot.turn(self.meta.pos, "L")
	end,
	help = " turn left\n"..
		" Example: $left()"
})

sl_robot.register_action("right", {
	cmnd = function(self)
		sl_robot.turn(self.meta.pos, "R")
	end,
	help = " turn right\n"..
		" Example: $right()"
})

sl_robot.register_action("up", {
	cmnd = function(self)
		sl_robot.lift(self.meta.pos, "up")
	end,
	help = " go one step up (2 steps max.)\n"..
		" Example: $up()"
})

sl_robot.register_action("down", {
	cmnd = function(self)
		sl_robot.lift(self.meta.pos, "dn")
	end,
	help = " go down again (2 steps max.)\n"..
		" you have to go up before\n"..
		" Example: $down()"
})

sl_robot.register_action("take", {
	cmnd = function(self, num, slot)
		sl_robot.take(self.meta.pos, self.meta.owner, slot, num)
	end,
	help = " take 'num' items from a chest or a node\n"..
		" with an inventory in front of the robot\n"..
		" and put the item into the own inventory,\n"..
		" specified by 'slot'.\n"..
		" Syntax: $take(num, slot)\n"..
		" Example: $take(99, 1)"
})

sl_robot.register_action("add", {
	cmnd = function(self, num, slot)
		sl_robot.add(self.meta.pos, self.meta.owner, slot, num)
	end,
	help = " take 'num' items from the own inventory\n"..
		" specified by 'slot' and add it to the nodes\n"..
		" inventory in front of the robot.\n"..
		" Syntax: $add(num, slot)\n"..
		" Example: $add(99, 1)"
})

sl_robot.register_action("place", {
	cmnd = function(self, slot, dir)
		if dir == nil then dir = "-" end
		sl_robot.place(self.meta.pos, self.meta.owner, slot, dir)
	end,
	help = " places an node in front of, above (up),\n"..
		"  or below (down) the robot. The node is taken\n"..
		" from the own inventory, specified by 'slot'.\n"..
		' Examples: $place(1) $place(1, "U"), $place(1, "D")'
})

sl_robot.register_action("dig", {
	cmnd = function(self, slot, dir)
		if dir == nil then dir = "-" end
		sl_robot.dig(self.meta.pos, self.meta.owner, slot, dir)
	end,
	help = " dig an node in front of, above (up),\n"..
		"  or below (down) the robot. The node is placed\n"..
		" into the own inventory, specified by 'slot'.\n"..
		' Examples: $dig(1) $dig(1, "U"), $dig(1, "D")'
})

sl_robot.register_action("stop", {
	cmnd = function(self)
		while true do
			coroutine.yield()
		end
	end,
	help = "tbd"
})
