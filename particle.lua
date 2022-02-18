local module = {}
module.__index = module
module.__type = "Particle"

local image = assets.power_star

function module:Draw()
	graphics.setColor(self.Color[1], self.Color[2], self.Color[3], 1-self.Transparency)
	local scx, scy = self.Size / image:getWidth(), self.Size / image:getHeight() 
	graphics.draw(image, self.X, self.Y, self.Rotation, scx, scy, scx * 0.5, scy * 0.5)
end

local update_properties = {"X", "Y", "Size", "Rotation"}

function module:Update(dt)
	for _, name in ipairs(update_properties) do
		if self[name] and self.Finish[name] then
			self[name] = self[name] + (self.Finish[name] - self[name]) * (dt * self.Speed)
		end
	end

	if self.FadeTimer <= 0 then
		self._fv = self._fv + (0.0125 * dt)
		
		if not self.Finish.Size then
			self.Size = self.Size - ((self._fv * dt) * 20)
		end

		self.Transparency = self.Transparency + (self._fv * dt)
		
	else self.FadeTimer = self.FadeTimer - dt
	end

	if self.Transparency > 1 then
		self.RemoveFlag = true
	end
end

local default_properties = {
	X = 0;
	Y = 0;
	Size = function()
		return math.random(30, 65)
	end;
	Rotation = function()
		return math.rad(math.random(-180, 180))
	end;
	FadeTimer = 0.8;
	Color = {1.0, 1.0, 1.0};
	Speed = function()
		return math.random(0.5, 2)
	end;
}

function module.new(start, finish)
	start = start or {}
	finish = finish or {}

	local self = setmetatable({
		Finish = finish;
		Transparency = 0;
		_fv = 4;
		RenderProperties = 10;
	}, module)

	for name, value in pairs(start) do
		self[name] = value
	end

	for name, value in pairs(default_properties) do
		if not self[name] then
			self[name] = type(value) == "function" and value() or value
		end
	end

	if not self.Finish.X or not self.Finish.Y then
		local radius = self.Radius or math.random(300, 1000)
		self.Finish.X = self.X + (math.cos(self.Rotation) * radius)
		self.Finish.Y = self.Y + (math.sin(self.Rotation) * radius)
	end
	
	if not self.Finish.Rotation then
		self.Finish.Rotation = self.Rotation + math.rad(math.random(-180, 180))
	end

	return self
end

return module
