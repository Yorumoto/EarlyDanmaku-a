local module = {}
module.__index = module
module.__type = "Player"

--[[
  PLAYER STATES:
  1: Alive
  2: Dead
]]--

local PLAYER_COLOR = {1.0, 1.0, 1.0, 1.0}
local PLAYER_SPEED = 600
local SLOWDOWN_KEY = "lshift"
local SHOOT_KEY = "z"
local BOMB_KEY = "x"
local BULLET_COLOR = {0.1, 0.3, 0.85, 1.0}
local SHOOT_DELAY = 0.025

local vectors = {
	left = {-1, 0};
	right = {1, 0};
	up = {0, -1};
	down = {0, 1};
}

local states = {}

local function hit_tag(hitted)
	hitted.Health = hitted.Health - 1
	playsound(hitted.Health / hitted.MaxHealth >= 0.25 and 'hit' or 'hit2')
	game.Score = game.Score + 9
	return hitted.Health > 0
end

local function get_enemies()
	local t = {}

	for _, v in ipairs(game.Entities) do
		if typeof(v) == "Enemy" then
			table.insert(t, v)	
		end
	end

	return t
end

states[1] = function(self, dt)
	if self.ForcefieldTimer > 0 then
		self.ForcefieldTimer = self.ForcefieldTimer - dt
	
		-- print("visisble timer", self.VisibleTimer)
		if self.VisibleTimer <= 0 then
			self.VisibleByForcefield = not self.VisibleByForcefield
			-- print(self.VisibleByForcefield)
			self.VisibleTimer = self.Starting.VisibleTimer
		else self.VisibleTimer = self.VisibleTimer - dt	
		end
	end

	local frame_speed  = keyboard.isDown(SLOWDOWN_KEY) and 0.35 or 1

	for key_name, vector in pairs(vectors) do
		if keyboard.isDown(key_name) then
			self.X = self.X + ((vector[1] * PLAYER_SPEED) * dt) * frame_speed
			self.Y = self.Y + ((vector[2] * PLAYER_SPEED) * dt) * frame_speed
			
			-- print(self.X, boundaries.w)
			self.X = math.clamp(self.X, 0, boundaries.w - self.Width)
			self.Y = math.clamp(self.Y, 0, boundaries.h - self.Height)
		end
	end

	if keyboard.isDown(SHOOT_KEY) then
		if self.ShootTimer <= 0 then
			-- shoot bullets bitch

			local sx, sy = self.X + self.Width * 0.5, self.Y + self.Height * 0.5
			
			local player_bullet = game.Spawn(Bullet.new, sx, sy, 15, 1250, nil, -1, BULLET_COLOR, {{get_enemies, hit_tag}})
			player_bullet.RenderPriority = 1
			player_bullet.DrawType = 2
			player_bullet.HitTagNumber = 2

			self.ShootTimer = SHOOT_DELAY
		else
			self.ShootTimer = self.ShootTimer - dt
		end
	end
end

states[2] = function(self, dt)
	if self.DeathbombTimer > 0 then
		self.DeathbombTimer = self.DeathbombTimer - dt
		return	
	end

	self.RespawnTimer = self.RespawnTimer - dt
	
	if self.RespawnTimer <= 0 then
		game.Lives = game.Lives - 1
		
		if game.Lives < 0 then
			game:GameOver()
			return
		end

		if game.Bombs < 5 then
			game.Bombs = 5
		end

		self.State = 1
		-- self.X = self.Starting.X
		-- self.Y = self.Starting.Y
		
		game:Nerf()

		for key, value in pairs(self.Starting) do
			self[key] = value
		end

		-- clear bullets
	end
end

states.global = function(self, dt)
	if keyboard.isDown(BOMB_KEY) and (self:IsAlive() or self.DeathbombTimer > 0) and game.Bombs > 0 and self.BombDelay <= 0 then
		local cx, cy = self:GetCenter()

		game.Bombs = game.Bombs - 1
		self.State = 1
		
		game:Nerf()
		game.Spawn(CircleParticle.new, cx, cy, 0.8, 30, 1000)

		local div = math.rad(360 / 70)
		local this_color = {math.random(), math.random(), math.random()}

		for i = 1, 70 do
			game.Spawn(Particle.new, {
				X = cx;
				Y = cy;
				Size = 20;
				Radius = 400;
				Speed = 2;
				Rotation = div * (i - 1);
				Color = this_color;
			}, {
				Size = 100;
			})
		end
		
		self.BombDelay = 1
		self.ForcefieldTimer = 2
		playsound("bomb")
	elseif self.BombDelay > 0 then
		self.BombDelay = self.BombDelay - dt
	end
end

function module:GetCenter()
	return self.X + self.Width * 0.5, self.Y + self.Height * 0.5
end

function module:UpdateHitbox()
	self.Hitbox:Update(self:GetCenter())
end

local DEATHBOMB_INDICATOR_COLOR = {1.0, 0, 0, 1.0}

function module:Draw()
	if not self:IsAlive() and self.DeathbombTimer <= 0 then
		return
	end

	if not self:IsAlive() and self.DeathbombTimer > 0 then
		local cx, cy = self:GetCenter()
		graphics.setColor(DEATHBOMB_INDICATOR_COLOR)
		graphics.circle("line", cx, cy, self.DeathbombTimer * 700)
	end

	-- print(self.ForcefieldTimer > 0, not self.VisibleByForcefield)
	if self.ForcefieldTimer > 0 and not self.VisibleByForcefield then
		return
	end
	graphics.setColor(PLAYER_COLOR)
	graphics.rectangle("fill", self.X, self.Y, self.Width, self.Height)
	
	-- self.Hitbox:Draw()
end

function module:IsAlive()
	return self.State == 1
end

function module:Death()
	if self.ForcefieldTimer > 0 or self.State == 2 then
		return
	end

	local cx, cy = self:GetCenter()
	game.Spawn(CircleParticle.new, cx, cy, 0.8, 20, 300)
	playsound("dead")
	playsound("dead2")
	
	local div = math.rad(360 / 30)
	
	for i = 1, 30 do
		game.Spawn(Particle.new, {
			X = cx;
			Y = cy;
			Size = 90;
			Radius = 400;
			Speed = 2;
			Rotation = div * (i - 1);
			Color = {1.0, 0, 0, 1};
		})
	end

	self.DeathbombTimer = 0.3
	self.State = 2
end

function module:Update(dt)
	-- print(dt)
	self:UpdateHitbox()
	states.global(self, dt)
	states[self.State](self, dt)		
end

local STARTING_GET_PROPERTIES = {"X", "Y", "RespawnTimer", "VisibleByForcefield", "VisibleTimer", "ForcefieldTimer"}

function module.new(x, y, width, height)
	local self = setmetatable({
		X = x or 0;
		Y = y or 0;
		Width = width or 55;
		Height = height or 55;
		State = 1;
		RenderPriority = 900;
		HitTagNumber = 1;
		ShootTimer = 0;
		Power = 0;
		RespawnTimer = 1;
		ForcefieldTimer = 2;
		BombDelay = 0;
		DeathbombTimer = 0;
		VisibleTimer = 0.0125;
		VisibleByForcefield = true;
		Starting = {};
	}, module)

	self.Hitbox = Hitbox.new(nil, nil, self.Width * 0.15, self.Height * 0.15)
	self.X = self.X - self.Width * 0.5
	self.Y = self.Y - self.Height * 0.5
	self:UpdateHitbox()
	
	for _, key in ipairs(STARTING_GET_PROPERTIES) do
		self.Starting[key] = self[key]
	end

	return self
end

return module
