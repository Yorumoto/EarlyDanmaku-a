local boss_f = require("boss")

local function _tupcom(...)
	local com = {}

	for _, v in ipairs(...) do
		table.insert(com, v)
	end

	return unpack(com)
end

local _1colors = {
	{0.5, 0.5, 0.75, 1.0};
	{0, 0, 1.0, 1};
}

local function _1bev(enemy, dt)
	if enemy.LeaveTimer > 0 then
		enemy.Y = enemy.Y + (190 - enemy.Y) * (dt * 5)		
		enemy.LeaveTimer = enemy.LeaveTimer - dt
	else
		enemy.Y = enemy.Y - (60 * dt)

		if enemy.Y <= -enemy.Height then
			enemy.RemoveFlag = true
		end
	end

	if enemy.ShootTimer <= 0 then
		local cx, cy = enemy:GetCenter()
		local direction = math.towards(cx, cy, game.Player:GetCenter())
		
		local div = 360 / 15

		for i = 1, 7 do
			game.Spawn(Bullet.new, cx, cy, 12, 250 + ((i - 1) * 30), nil, nil, _1colors[1]):SetDirection(direction)
		end

		for i = 1, 15 do
			game.Spawn(Bullet.new, cx, cy, 20, 300, nil, nil, _1colors[2]):SetDirection(
				direction + math.rad((i - 1) * div)
			)
		end

		enemy.ShootTimer = 0.65
	else enemy.ShootTimer = enemy.ShootTimer - dt
		
	end
end

local function _1(x)
	local enemy = game.Spawn(Enemy.new, boundaries.w * x, -50, nil, nil, 15)
	enemy.LeaveTimer = 5
	enemy.ShootTimer = 1
	enemy.Behavior = _1bev
end

local function _rndcolor()
	return {math.random(), math.random(), math.random(), 1}
end

local _2states = {}

_2states[1] = function(enemy, dt)
	if not enemy.SetupState then
		enemy.NextStateTimer = 1
		enemy.SetupState = true
	end

	enemy.X = enemy.X + (enemy.EndPosition - enemy.X) * (dt * 7)
end

local _2_ANGLE_INC = math.rad(5)

_2states[2] = function(enemy, dt)
	if not enemy.SetupState then
		enemy.FireTimer = 0
		enemy.NextStateTimer = 4
		enemy.SetupState = true
	end

	if enemy.FireTimer <= 0 then
		-- yandev moment
		local cx, cy = enemy:GetCenter()

		if enemy.ShootType == 1 then
			game.Spawn(Bullet.new, cx, cy, math.random(10, 25), math.random(300, 600), nil, nil, _rndcolor()):SetDirection(math.rad(math.random(-180, 180)))	
			enemy.FireTimer = 0.0125
		elseif enemy.ShootType == 2 then
			for i = 1, 45 do
				game.Spawn(Bullet.new, cx, cy, math.random(10, 25), math.random(300, 600), nil, nil, _rndcolor()):SetDirection(math.rad(math.random(-180, 180)))	
			end

			enemy.FireTimer = 0.65
		elseif enemy.ShootType >= 3 then
			if not enemy.CurrentAngle then
				enemy.CurrentAngle = 0	
			end

			enemy.CurrentAngle = enemy.CurrentAngle + math.rad(enemy.ShootType == 3 and 15 or -15)
			
			for i = 1, 5 do
				game.Spawn(Bullet.new, cx, cy, 12, 400, nil, nil, {0.3, 0.5, 0.7, 1}):SetDirection(enemy.CurrentAngle + ((i - 1) * _2_ANGLE_INC))
			end

			enemy.FireTimer = 0.07
		end
	else enemy.FireTimer = enemy.FireTimer - dt
	end
end

_2states[3] = function(enemy, dt)
	if not enemy.SetupState then
		enemy.Increment = enemy.StartPosition - enemy.EndPosition
		enemy.NextStateTimer = 3
		enemy.SetupState = true
	end
	
	enemy.X = enemy.X + enemy.Increment * (dt * 0.25)
end

_2states[4] = function(enemy)
	enemy.RemoveFlag = true
	enemy.NextStateTimer = 9999
end

local function _2bev(enemy, dt)
	_2states[enemy.State](enemy, dt)

	-- print(enemy.NextStateTimer)
	if enemy.NextStateTimer <= 0 then
		if _2states[enemy.State + 1] ~= nil then
			enemy.SetupState = false
			enemy.State = enemy.State + 1
		end
	else
		enemy.NextStateTimer = enemy.NextStateTimer - dt
	end
end

local function _2(instance, startpos, endpos)
	local enemy = game.Spawn(Enemy.new, startpos, 200, nil, nil, 65)
	enemy.State = 1
	enemy.NextStateTimer = 0
	enemy.EndPosition = endpos
	enemy.ShootType = instance
	enemy.SetupState = false
	enemy.StartPosition = startpos
	enemy.Behavior = _2bev
end

local _3_AMOUNT_OF_SQUARES = 8
local _3_BULLET_COLOR = {0.9, 0.2, 0, 1.0}

local function _3sonbev(enemy, dt)
	if not enemy.Setup then
		enemy.EndX = enemy.EndX - enemy.Width * 0.5
		enemy.EndY = enemy.EndY - enemy.Height * 0.5
		enemy.Setup = true
	end

	enemy.X = enemy.X + (enemy.EndX - enemy.X) * (dt * 2)
	enemy.Y = enemy.Y + (enemy.EndY - enemy.Y) * (dt * 2)

	if enemy.FireTimer <= 0 then
		local cx, cy = enemy:GetCenter()
		local dir = math.towards(cx, cy, game.Player:GetCenter())

		for i = 0, 6 do
			game.Spawn(Bullet.new, cx, cy, 10, 90 + (i * 70), nil, nil, _3_BULLET_COLOR):SetDirection(dir)
		end

		enemy.FireTimer = math.random(0.7, 2)
	else enemy.FireTimer = enemy.FireTimer - dt
	end

	if enemy.DestroyTimer <= 0 then
		enemy.Health = 0
	else enemy.DestroyTimer = enemy.DestroyTimer - dt
	end
end

local function _3bev(enemy, dt)
	enemy.Y = enemy.Y + (250 - enemy.Y) * (dt * 5)

	if not enemy.GaveBirth then
		if enemy.BirthTime <= 0 then
			local cx, cy = enemy:GetCenter()
			game.Spawn(CircleParticle.new, cx, cy, 1, 30, 200)
			
			local div = math.rad(360 / _3_AMOUNT_OF_SQUARES)

			for i = 0, _3_AMOUNT_OF_SQUARES - 1 do
				local a = div * i
				local n = game.Spawn(Enemy.new, cx, cy, 40, 40, 45)
				n.EndX = cx + (math.cos(a) * 200)
				n.EndY = cy + (math.sin(a) * 200)
				n.FireTimer = 1 + ((i + 1) * 0.125)
				n.DestroyTimer = 7 + i * 0.25
				n.Behavior = _3sonbev
			end

			enemy.GaveBirth = true
		else enemy.BirthTime = enemy.BirthTime - dt
		end
	end

	if enemy.DestroyTime <= 0 then
		enemy.Health = 0
	else enemy.DestroyTime = enemy.DestroyTime - dt
	end
end

local function _3(x)
	local enemy = game.Spawn(Enemy.new, boundaries.w * x, -300, 130, 130, 125)
	enemy.GaveBirth = false
	enemy.BirthTime = 2
	enemy.DestroyTime = 4
	enemy.Behavior = _3bev
end

local _4_ENEMY_RATE = 1 / 13
local _4_INC_S = math.rad(13.5)
local _4_BULLET_COLOR = {0, 0, 1, 1}

local function _4bulbev(self, dt)
	if not self.StartSpeed then
		self.StartSpeed = self.Speed
		-- self._d = 
	end

	self.Speed = self.Speed + (0 - self.Speed) * (dt * 2)

	if self.GoSpeedTimer <= 0 then
		if math.abs(self.Speed) <= 0.0025 then
			self.Speed = 10
			self.StartSpeed = self.Speed
		end

		if math.abs(self.StartSpeed) * 6 >= math.abs(self.Speed) then
			self.Speed = self.Speed + ((self.StartSpeed * 1.5) * dt)
		end
	else self.GoSpeedTimer = self.GoSpeedTimer - dt
	end
end

local function _4bev(self, dt)
	self._p = self._p + _4_ENEMY_RATE * dt
	self.X = self.Start + (self._d * self._p)

	if self._p > 1 then
		self.RemoveFlag = true
	end

	if not self.StartFireTimer then
		self.StartFireTimer = self.FireTimer
	end

	if self.FireTimer <= 0 then
		local cx, cy = self:GetCenter()
		local speed = math.sin(self._s) * 300

		local bullet = game.Spawn(Bullet.new, cx, cy, 15, speed, nil, -1, _4_BULLET_COLOR)
		bullet.GoSpeedTimer = 4
		bullet.Behavior = _4bulbev

		self.FireTimer = self.StartFireTimer
		self._s = self._s + _4_INC_S
	else self.FireTimer = self.FireTimer - dt
	end
end

local function _4(s, e, y)
	local enemy = game.Spawn(Enemy.new, s, y, 50, 50, 50)
	enemy.Start = s
	enemy._p = 0
	enemy._d = e - s
	enemy.FireTimer = 0.1
	enemy._s = 0
	enemy.Behavior = _4bev

end

local function _4_5bev(entity, dt)
	if entity.Timer <= 0 then
		entity.Speed = entity.Speed + (200 * dt)
	else entity.Timer = entity.Timer - dt
	end
end

local function _4_5_boom()
	game.Spawn(CircleParticle.new, boundaries.w*0.5, boundaries.h*0.5, 2, 30, 600)

	game.every_entity(function(_, entity, type)
		if type ~= "Bullet" or not entity then
			return
		end

		entity.Speed = 0
		entity.Color = {0, 1.0, 0, 1.0}
		entity:SetDirection(math.rad(math.random(-180, 180)))
		entity.Behavior = _4_5bev
		entity.Timer = 2
	end)
end

local function _5bulbev(self, dt)
	if self.AngleTurn > 0.0125 then
		self.AngleTurn = self.AngleTurn - (1 * dt)
	end
	
	self:SetDirection(self:GetDirection() + (self.AngleTurn * dt))
end

local _5_BULLET_COLORS = {
	[-1] = {0.9, 0.2, 0.3, 1};
	[1] = {0.2, 0.3, 0.5, 1};
}

local _5_START_ANGLE = math.rad(-45)
local _5_MOD_EACH = math.rad(90)

local function _5bev(self, dt)
	if self.LeaveTimer <= 0 then
		self.Y = self.Y + (100 * dt)
	else
		self.Y = self.Y + (150 - self.Y) * (dt * 5)
		self.LeaveTimer = self.LeaveTimer - dt
	end

	if self.FireTimer <= 0 then
		local mod = self._mod % 1
		local cx, cy = self:GetCenter()
		local sine_speed = math.max(20 + math.sin(0.5 + self._mod) * 600, 100)

		for i = 1, 2 do
			local bullet = game.Spawn(Bullet.new, cx, cy, 20, sine_speed, nil, nil, _5_BULLET_COLORS[self.AngleWhere])
			bullet:SetDirection(_5_START_ANGLE + (_5_MOD_EACH * mod) + math.rad(((i - 1) * 105)))
			bullet.AngleTurn = math.rad(sine_speed / 20) + math.rad(i * 65)
			bullet.Behavior = _5bulbev
		end

		self._mod = self._mod + 0.15
		self.AngleWhere = -self.AngleWhere
		self.FireTimer = 0.025
	else self.FireTimer = self.FireTimer - dt
	end
end

local function _5(x)
	local enemy = game.Spawn(Enemy.new, boundaries.w * x, -100, 100, 100, 110)
	enemy.LeaveTimer = 6
	enemy.AngleWhere = 1
	enemy.FireTimer = 2
	enemy._mod = 0
	enemy.Behavior = _5bev
end

local function _nerf()
	game:Nerf()

	-- local boss = game.Spawn(Enemy.new, boundaries.w * 0.5, -100)	
end

--[[
local level = {}
local picked = {_1, _2, _3, _4, _5, _4_5_boom,  _nerf, _final, boss_f}

local arg_required = {
	aelse = function()
		return {}
	end;

	[_1] = function()
		return {math.random()}
	end;

	[_2] = function()
		return {math.random(1, 3), math.random(-0.5, boundaries.w * 1.5), math.random(-0.5, boundaries.w * 1.5)}
	end;

	[_4] = function()
		return {math.random(-0.5, boundaries.w * 1.5), math.random(-0.5, boundaries.w * 1.5),  math.random(0, boundaries.h)}
	end;
}

arg_required[_3] = arg_required[_1]
arg_required[_5] = arg_required[_1]

-- math.randomseed(2931)
for i = 1, 400 do
	local picked = picked[math.random(1, #picked)]
	table.insert(level, {math.random(0.4, 3), picked, unpack((arg_required[picked] or arg_required.aelse)())})
end

return level
]]--

local function _final()
	game.GameFinished = true	
	game:GameOver()

	-- print("game done")
end

return {
	{1, _1, 0.25};
	{0.5, _1, 0.5};
	{0.4, _1, 0.75};
	{4, _1, 0.6};
	{0.5, _1, 0.3};
	{5, _2, 1, boundaries.w * -0.2, boundaries.w * 0.1};
	{3, _2, 2, boundaries.w * 1.3, boundaries.w * 0.8};
	{8, _3, 0.25};
	{4, _3, 0.75};
	{7, _4, boundaries.w * -0.3, boundaries.w * 1.3, 200};
	{4, _4, boundaries.w * 1.3, boundaries.w * -0.3, 350};
	{4, _4, boundaries.w * -0.3, boundaries.w * 1.3, 500};
	{3, _4, boundaries.w * 1.6, boundaries.w * -0.6, 400};
	{15, _4_5_boom};
	{6, _1, 0.1};
	{0.5, _1, 0.25};
	{0.5, _1, 0.4};
	{0.5, _1, 0.55};
	{0.5, _1, 0.7};
	{0.5, _1, 0.95};
	{10, _5, 0.5};
	{3, _5, 0.25};
	{3, _5, 0.75};
	{6, _2, 3, boundaries.w * -0.2, boundaries.w * 0.1};
	{0, _2, 4, boundaries.w * 1.3, boundaries.w * 0.8};
	{4, _2, 3, boundaries.w * -0.3, boundaries.w * 0.5};
	{5, _1, 0.5};
	{0, _4, boundaries.w * -0.3, boundaries.w * 1.3, 200};
	{0, _4, boundaries.w * 1.6, boundaries.w * -0.6, 400};
	{14, _nerf};
	{1, boss_f};
	{8, _final};
}
