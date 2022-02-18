local module = {}
module.__index = module
module.__type = "CircleParticle"

local controltypes = {}

controltypes[1] = function(p)
	return 1 - p
end

controltypes[2] = function(p)
	return p
end

--[[controltypes[3] = function(p)
	if p > 0.5 then
		-- return 1 - ((p - 0.5) * 2)
		-- return 
	else
		-- return p * 2
	end
end]]--


function module:Draw()
	graphics.setColor(1, 1, 1, self.TransparencyEffect and controltypes[self.TransparencyControlType](self._p) or 1)
	graphics.circle(self.DrawMode, self.X, self.Y, self.Start + (self._d * self._p))
	graphics.setColor(1, 1, 1, 1)
end

function module:Update(dt)
	self._p = self._p + self.Rate * dt

	if self._p > 1 then
		self.RemoveFlag = true
	end
end

function module.new(x, y, duration, start_radius, end_radius)
	local self = setmetatable({
		X = x or 0;
		Y = y or 0;
		Rate = 1 / (duration or 1);
		RenderPriority = -1;
		Start = start_radius or 10;
		End = end_radius or 100;
		_p = 0;
		
		TransparencyControlType = 1;
		DrawMode = "fill";
		TransparencyEffect = true;
	}, module)

	self._d = self.End - self.Start

	return self
end

return module
