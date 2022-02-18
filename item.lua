local module = {}
module.__index = module
module.__type = "Item"

local COLLECTION_POINT = 150
local DEFAULT_WIDTH = 40
local DEFAULT_HEIGHT = 40

local RATIO_X = DEFAULT_WIDTH / assets.star:getWidth()
local RATIO_Y = DEFAULT_HEIGHT / assets.star:getHeight()

local MAX_COLLECT_SCORE = 15000

function module:CheckPlayer()
	if not self.Autocollect and game.Player:IsAlive() then
		local _, pcy = game.Player:GetCenter()

		if pcy <= COLLECTION_POINT then
			self.AutoCollect = true
		end
	end

	if game.Player:IsAlive() and game.Player.X + game.Player.Width >= self.X and game.Player.X <= self.X + DEFAULT_WIDTH and game.Player.Y + game.Player.Height >= self.Y and game.Player.Y <= self.Y + DEFAULT_HEIGHT then
		local add_score = self.AutoCollect and MAX_COLLECT_SCORE or math.max(MAX_COLLECT_SCORE * (1 - (self.Y / boundaries.h)), 0)

		game:AddScore(add_score * self.Value, self.X, self.Y)

		self.X, self.Y = game.Player:GetCenter()
		self.X = self.X - DEFAULT_WIDTH * 0.5
		self.Y = self.Y - DEFAULT_HEIGHT * 0.5

		self.Collected = true
		self.FadeDirection = math.rad(math.random(-180, 180))
		self.RotationRate = math.random(-3.0, 3.0)
		playsound("collect")
	end
end

function module:Draw()
	local cx, cy = self:GetCenter()

	graphics.setColor(1.0, 1.0, 1.0, 1.0 - self.Transparency)
	-- graphics.rectangle("fill", self.X, self.Y, DEFAULT_WIDTH, DEFAULT_HEIGHT)
	graphics.draw(assets.star, cx, cy, self.Rotation, RATIO_X * self.Scale, RATIO_Y * self.Scale, (DEFAULT_WIDTH * self.Scale) * 0.5, (DEFAULT_HEIGHT * self.Scale) * 0.5)
	graphics.setColor(1.0, 1.0, 1.0, 1.0)
end

function module:GetCenter()
	return self.X + DEFAULT_WIDTH * 0.5, self.Y + DEFAULT_HEIGHT * 0.5
end

local AUTOCOLLECT_SPEED = 900

function module:Update(dt)
	if self.Collected then
		local smo = 1 - self.Transparency
		self.X = self.X + ((math.cos(self.FadeDirection) * 400) * smo) * (dt)
		self.Y = self.Y + ((math.sin(self.FadeDirection) * 400) * smo) * (dt)
		
		self.Transparency = self.Transparency + dt * 1.5
		self.Scale = self.Scale + (dt * 3) * (3 - self.Scale)
		self.Rotation = self.Rotation + math.rad((65 * dt) * self.RotationRate)

		if self.Transparency > 1 then
			self.RemoveFlag = true
		end
		
		return
	end

	if not self.AutoCollect then
		self.YVel = self.YVel + (200 * dt)
		self.Y = self.Y + (self.YVel * (dt * 1))
	else
		if not game.Player:IsAlive() then
			self.AutoCollect = false
			self.YVel = 0
			return
		end

		local cx, cy = self:GetCenter()
		local pcx, pcy = game.Player:GetCenter()


		local dir = math.towards(cx, cy, pcx, pcy)

		self.X = self.X + (math.cos(dir) * AUTOCOLLECT_SPEED) * dt
		self.Y = self.Y + (math.sin(dir) * AUTOCOLLECT_SPEED) * dt
	end

	if self.Y + DEFAULT_HEIGHT >= boundaries.h then
		self.RemoveFlag = true
	end

	self:CheckPlayer()
end

function module.new(x, y, value)
	local self = setmetatable({
		X = x or 0;
		Y = y or 0;
		YVel = -300;
		RenderPriority = 30;
		Transparency = 0;
		Collected = false;
		Scale = 1;
		FadeDirection = 0;
		Rotation = 0;
		RotationRate = 0;
		Value = value or 1;
	}, module)

	self.X = self.X - DEFAULT_WIDTH * 0.5
	self.Y = self.Y - DEFAULT_HEIGHT * 0.5

	return self
end

return module
