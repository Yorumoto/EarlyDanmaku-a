local module = {}
module.__index = module
module.__type = "FloatingNumber"

local THIS_FONT = assets.FloatingNumberFont
-- print(THIS_FONT)
-- assert(THIS_FONT, "This font doesn't exist lol")

local RISING_SPEED = 100

function module:Draw()
	graphics.setColor(1.0, 1.0, 1.0, 1 - self.Transparency)
	graphics.setFont(THIS_FONT)
	graphics.print(self.Text, self.X, self.Y)
end

function module:Update(dt)
	self.Y = self.Y - (RISING_SPEED * dt)

	if self.Lifetime > 0 then
		self.Lifetime = self.Lifetime - dt
	else
		self.Transparency = self.Transparency + dt * 2

		if self.Transparency > 1 then
			self.RemoveFlag = true
			return
		end
	end
end

function module.new(x, y, text)
	local self = setmetatable({
		X = x or 0;
		Y = y or 0;
		Text = tostring(text);
		Lifetime = 1;
		Transparency = 0;
		RenderPriority = 11;
	}, module)

	return self
end

return module
