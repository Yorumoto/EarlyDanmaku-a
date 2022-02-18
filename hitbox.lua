-- unnecessary class, should've done this earlier
-- but whatever lol

local module = {}
module.__index = module

function module:Draw()
	graphics.rectangle("line", self.X, self.Y, self.Width, self.Height)
end

function module.new(x, y, width, height)
	local self = setmetatable({
		X = x or 0;
		Y = y or 0;
		Width = width or 20;
		Height = height or 20;
	}, module)

	return self
end

function module:Update(x, y)
	self.X = x - self.Width * 0.5
	self.Y = y - self.Height * 0.5
end

return module
