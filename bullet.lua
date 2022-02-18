local module = {}
module.__index = module
module.__type = "Bullet"

local hit_tag = {}
local graze_tag = {}

local function player_graze_tag(hitted)
	if not hitted:IsAlive() then
		return false
	end

	playsound("graze")
	game.Graze = game.Graze + 1
	game:AddScore(game.Graze ^ 1.25)
	return true
end

local function player_hit_tag(hitted, bullet)
	-- hitted.RemoveFlag = true
	hitted:Death()
	return hitted:IsAlive()
end

function module:CheckCollisions()
	local rect = {X=self.X, Y=self.Y, Width=self.Size, Height=self.Size}

	for _, item in ipairs(self.Collisions) do
		local t = item[1]
		local typ = type(t)

		if typ == "function" then
			t = t()
		elseif typ ~= "table" then
			t = {t}
		end

		-- if t then
			for _, entity in ipairs(t) do
				-- graze
			
				local entity_hitbox = entity.Hitbox

				if item[3] and entity_hitbox and not self.Grazed and collides(entity, rect) then
					self.Grazed = item[3](entity, self)
				end

				-- hit

				if collides((entity_hitbox or entity), self.Hitbox) then
					self.RemoveFlag = item[2](entity, self)
				end
			end
		-- end
	end
end

function module:GetCenter()
	return self.X + self.Size * 0.5, self.Y + self.Size * 0.5
end

function module:UpdateHitbox()
	self.Hitbox:Update(self:GetCenter())	
end

function module:Update(dt)
	if self.Behavior then
		self.Behavior(self, dt)
	end

	self.X = self.X + ((self.XVel * self.Speed) * dt)
	self.Y = self.Y + ((self.YVel * self.Speed) * dt)
	self:UpdateHitbox()

	if self.Fencing then
		if self.X + self.Size <= 0 or self.X >= boundaries.w or self.Y + self.Size <= 0 or self.Y >= boundaries.h then
			self.RemoveFlag = true
		end
	end

	if self.CanCollide then
		-- game.every_entity(bullet_collide, self)
		self:CheckCollisions()
	end
end

-- local WHITE = {1.0, 1.0, 1.0, 1.0}

local draw_types = {}

draw_types[1] = function(self, dx, dy)
	graphics.setColor(self.Color)
	graphics.circle("fill", dx, dy, self.Size)
	graphics.setColor(1, 1, 1, self.Color[4] or 1)
	graphics.circle("fill", dx, dy, self.Size * 0.85)
end

draw_types[2] = function(self, dx, dy)
	graphics.setColor(self.Color)
	graphics.circle("fill", dx, dy, self.Size)
end

function module:Draw()
	-- print(self.DrawType)
	draw_types[self.DrawType](self, self.X + self.Size * 0.5, self.Y + self.Size * 0.5) 
	-- self.Hitbox:Draw()
end

function module:SetDirection(ang)
	ang = ang or 0
	self.XVel = math.cos(ang)
	self.YVel = math.sin(ang)
end

function module:GetDirection()
	return math.atan2(self.YVel, self.XVel)
end

function module.new(x, y, size, speed, xvel, yvel, color, collisions)
	local self = setmetatable({
		X = x or 0;
		Y = y or 0;
		Size = size or 10;
		Speed = speed or 50;
		XVel = xvel or 0;
		YVel = yvel or 0;
		Color = color or {1, 0, 0, 1};
		Fencing = true;
		CanCollide = true;
		Collisions = collisions or {{{game.Player}, player_hit_tag, player_graze_tag}};
		DrawType = 1;
		-- RenderPriority = 0;
	}, module)

	self.Hitbox = Hitbox.new(nil, nil, self.Size * 0.4, self.Size * 0.4)
	self:UpdateHitbox()

	self.X = self.X - self.Size * 0.5
	self.Y = self.Y - self.Size * 0.5 

	return self
end

return module
