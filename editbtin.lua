function collides(s1, s2)
	return s1.X + s1.Width > s2.X and s1.X < s2.X + s2.Width and s1.Y + s1.Height > s2.Y and s1.Y < s2.Y + s2.Height
end

function cleanuptable(tbl)
	local index = 1

	while index <= #tbl do
		local item = tbl[index]

		if item and item.RemoveFlag then
			table.remove(tbl, index)
		else
			index = index + 1
		end
	end
end

function playsound(sound_name)
	assets[sound_name]:clone():play()
end

function string.split(full, sep)
	local t = {}
	
	for otpt in string.gmatch(full,"([^"..sep.."]+)") do
		table.insert(t, otpt)
	end

	return t
end

function math.towards(x, y, x2, y2)
	return math.atan2((y2 - y), (x2 - x))
end

function math.clamp(x, min, max)
	return math.max(min, math.min(max, x))
end

function table.clear(t)
	for _ = 1, #t do
		table.remove(t, 1)
	end
end

-- maybe do table.cleardict(t)

function table.cleardict(t)
	for k, v in pairs(t) do
		t[k] = nil
	end
end

function typeof(value)
	return value.__type or type(value)
end

return function()
	print("Testing new user math functions in Lua")

	print("math.clamp(0, 5, 100), math.clamp(-100, 50, 100):", 
		math.clamp(0, 5, 100), math.clamp(-100, 50, 100)
	)

	print("Direction towards from 0, 0 to 45, 0", math.towards(0, 0, 45, 0))
end
