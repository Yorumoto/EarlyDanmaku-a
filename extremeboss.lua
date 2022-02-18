local function power_charge(cx, cy)
	local cp = game.Spawn(CircleParticle.new, cx, cy, 1.5, 400, 0)
	cp.TransparencyControlType = 2

	for i = 1, math.random(20, 45) do
		local ang = math.rad(math.random(-180, 180))
		local radius = math.random(650, 675)

		game.Spawn(Particle.new, {
			X = cx + (math.cos(ang) * radius);
			Y = cy + (math.sin(ang) * radius);
			Size = 20;
			FadeTimer = 0.9;
			Speed = 3;
			Color = {math.random(), math.random(), math.random()}
		}, {
			X = cx;
			Y = cy;
			Size = math.random(60, 100);
		})	
	end
end

local function _1setup(variables)
	variables.FireTimer = 0.1
end

local function _1bulbev(self, dt)
	if self.TargetTimer <= 0 then
		self.Speed = self.Speed + (200 * dt)
	else
		self.TargetTimer = self.TargetTimer - dt
		self.Speed = self.Speed + (-self.Speed) * (2 * dt)
	
		if self.TargetTimer <= 0 then
			local cx, cy = self:GetCenter()
			self:SetDirection(math.towards(cx, cy, game.Player:GetCenter()))
		end
	end
end

-- Hoop Lead 
local function _1(self, variables, dt)
	if variables.FireTimer <= 0 then
		local cx, cy = self:GetCenter()
		local bullets = 15
		local radius = 25
		local speed = 200

		for _ = 1, 3 do
			local div = math.rad(360 / bullets)

			for i = 1, bullets do
				local bullet = game.Spawn(Bullet.new, cx, cy, radius, speed, nil, nil, {0.2, 0.8, 0.1})
				bullet.TargetTimer = 2
				bullet.Behavior = _1bulbev
				bullet:SetDirection(div * (i - 1))
			end

			bullets = math.floor(bullets * 1.25)
			radius = math.floor(bullets * 0.9)
			speed = speed * 2
		end

		self.MoveRandom()
		variables.FireTimer = 0.9
	else variables.FireTimer = variables.FireTimer - dt
	end
end

local function _2bulbev_3(self, dt)
	if self.State == 0 then
		self.YVel = self.YVel + (dt * 2)
		
		if self.Y > boundaries.h * 0.3 then
			self.State = 1
			self.Timer = 0.5
			self.Color = {0.3, 0.3, 0.8}	
		end
	elseif self.State  == 1 then
		self.Speed = self.Speed + (-self.Speed) * (dt * 4)
		self.Timer = self.Timer - dt

		if self.Timer < 0 then
			self.State = 2
			local cx, cy = self:GetCenter()
			self:SetDirection(math.towards(cx, cy, game.Player:GetCenter()) + math.rad(math.random(-4, 4)))
		end
	elseif self.State == 2 then
		self.Speed = self.Speed + (150 * dt)
	end
end

local function _2setup(variables, boss)
	variables.Angle = 0
	variables.Increment = math.rad(45)
	variables.Attack = 1
	variables.FireTimer = 0.5
	variables.NewAttackTimer = 5
	variables.NewAttackState = 1

	local hoop_count = 50
	local hoop_div = math.rad(360 / hoop_count)

	variables.Attacks = {
		function()
			local cx, cy = boss:GetCenter()
			local towards = math.towards(cx, cy, game.Player:GetCenter())
			
			for i = 1, 12 do
				game.Spawn(Bullet.new, cx, cy, 20, 110 + ((i - 1) * 120), nil, nil, {0.4, 0.2, 0.1}):SetDirection(towards)
			end

			variables.FireTimer = 0.05
		end;
		function()
			local cx, cy = boss:GetCenter()
			local angle = math.rad(math.random(-180, 180))
			
			for i = 1, hoop_count do
				game.Spawn(Bullet.new, cx, cy, 30, 800, nil, nil, {0.6, 0.4, 0.7}):SetDirection(angle + ((i - 1) * hoop_div))
			end

			variables.FireTimer = 0.35
		end;
		function()
			local cx, cy = boss:GetCenter()

			for i = 1, math.random(10, 25) do
				local ang = math.rad(math.random(-180 + 25, -25))
				local bullet = game.Spawn(Bullet.new, cx, cy, 15, math.random(600, 700))
				bullet.Color = {0.3, math.random(0.5, 1), 0.3}
				bullet.Behavior = _2bulbev_3
				bullet:SetDirection(ang)
				bullet.XVel = bullet.XVel * 0.8
				bullet.State = 0
				bullet.Timer = 0
			end

			variables.FireTimer = 0.05
		end;
	}

end

-- Circular Orbit of 3 Types of Endurance
local function _2(self, variables, dt)
	self.MoveTo((boundaries.w * 0.5) + (math.cos(variables.Angle) * 300), 200 + (math.sin(variables.Angle) * 120))
	
	if variables.NewAttackState == 1 then
		variables.Angle = variables.Angle + variables.Increment * dt

		if variables.FireTimer <= 0 then
			variables.Attacks[variables.Attack]()
		else variables.FireTimer = variables.FireTimer - dt
		end
	end

	-- if variables.NewAttackState >= 1 and variables.NewAttackState <= 2 then
		variables.NewAttackTimer = variables.NewAttackTimer - dt
		-- print(variables.NewAttackTimer)

		if variables.NewAttackTimer <= 0 then
			if variables.NewAttackState == 1 then
				variables.NewAttackState = 2
				variables.NewAttackTimer = 1
				power_charge(self:GetCenter())
			elseif variables.NewAttackState == 2 then
				variables.NewAttackState = 1
				variables.NewAttackTimer = 5
				variables.Attack = variables.Attack + 1

				if variables.Attack > #variables.Attacks then
					variables.Attack = 1
				end
			end
		end
	-- end
end

local function _3setup(variables, self)
	variables.BallTimer = 1
	variables.State = 1
	variables.BallCount = 0
	self.MoveTo(boundaries.w * 0.325, 150)
end


-- Four Balls of Death
local _3star_bounce = math.rad(360 / 5)

local function _3lifetimebypass(self, dt)
	if self.Lifetime <= 0 then
		self.Fencing = true
		self.Behavior = nil
	else self.Lifetime = self.Lifetime - dt
	end
end

local function _3bulbev(self, dt)
	self.YVel = self.YVel + (dt * 0.75)

	if self.X <= 0 or self.X >= boundaries.w - self.Size then
		if self.X <= 0 then
			self.X = 0
		else
			self.X = boundaries.w - self.Size
		end
		
		local cx, cy = self:GetCenter()

		for i = 1, 5 do
			game.Spawn(Particle.new, {
				X = cx;
				Y = cy;
			})
		end

		local circles = 9
		local div = math.rad(360 / circles)

		for i = 1, circles do
			local bullet = game.Spawn(Bullet.new, cx, cy, 20, 50, nil, nil, self.Color)
			bullet.Fencing = false
			bullet:SetDirection((i - 1) * div)
			bullet.Lifetime = 1
			bullet.Behavior = _3lifetimebypass
		end

		playsound("hit2")
		self.XVel = -self.XVel
	end

	if self.Y >= boundaries.h + (self.Size * 0.5) then
		local cx, cy = self:GetCenter()

		game.Spawn(CircleParticle.new, cx, cy, 1.2, 80, 700)

		for i = 1, 40 do
			game.Spawn(Particle.new, {
				X = cx;
				Y = cy;
				Size = math.random(20, 80);
				Speed = math.random(0.3, 2)
			})
		end

		local radius = 20
		local speed = 50
		local circles = 20

		for _ = 1, 2 do
			local div = math.rad(360 / circles)

			for i = 1, circles  do
				local bullet = game.Spawn(Bullet.new, cx, cy, radius, speed, nil, nil, self.Color)
				bullet.Fencing = false
				bullet:SetDirection((i - 1) * div)
				bullet.Lifetime = 1
				bullet.Behavior = _3lifetimebypass
			end

			radius = radius * 0.96
			speed = speed * 3
			circles = math.floor(circles * 2.5)
		end

		playsound("enemyhit")
		self.RemoveFlag = true
	end
end

local function _3(self, variables, dt)
	if variables.State == 1 then
		if variables.BallTimer <= 0 then
			if variables.BallCount >= 15 then
				variables.State = 2
				return
			end

			local cx, cy = self:GetCenter()
			
			local ball = game.Spawn(Bullet.new, cx, cy, 40, 500, nil, nil, {math.random(0.5, 1), math.random(0.5, 1), math.random(0.5, 1)})
			ball:SetDirection(math.rad(math.random(-180 + 45, -45)))
			ball.Behavior = _3bulbev
			ball.DrawType = 2
			ball.XVel = ball.XVel * 0.8
			ball.Fencing = false
			ball.BombUnaffected = true

			variables.BallCount = variables.BallCount + 1
			variables.BallTimer = 0.125
		else variables.BallTimer = variables.BallTimer - dt
		end
	elseif variables.State == 2 then
		self.MoveRandom()
		variables.BallTimer = 3
		variables.State = 3
		variables.BallCount = 0
	elseif variables.State == 3 then
		variables.BallTimer = variables.BallTimer - dt

		if variables.BallTimer <= 0 then
			variables.State = 1
		end
	end
end


local function _4setup(variables, self)
	variables.TargetX = 0
	variables.State = 2
	variables.Timer = 0
	variables.Y = -15
	variables.FireTimer = 0
	variables._f = false
	variables.LeaveTimerSet = 3
	variables.TimerSet = 1
	-- variables.RandOffset = math.random(-5, 5)
end

local function _4bulbev(self, dt)
	if self.LeaveTimer <= 0 then
		self.XVel = self.XVel + ((10 * self.Increase) * dt)
	else 
		self.LeaveTimer = self.LeaveTimer - dt
		self.XVel = self.XVel + (-self.XVel) * (2 * dt)
	end
end

local function _4(self, variables, dt)
	if variables.State == 0 then
		variables.Y = -90
		variables.State = 1
		variables.Timer = 0.05
		variables.FireTimer = 0.25
		variables.RandOffset = math.random(-10, 10)
	elseif variables.State == 1 then
		variables.Y = variables.Y + ((360 * 1.5) * dt)
		if variables.Y >= boundaries.h then
			variables.State = 2
			variables.LeaveTimerSet = variables.LeaveTimerSet * 0.95
			variables.Timer = variables.TimerSet
			variables.TimerSet = variables.TimerSet * 0.935
		end
	else
		if variables.Timer <= 0 then
			if variables.State == 2 then
				variables.State = 3
				variables.Timer = variables.TimerSet * 0.5
				variables.Y = -90
				variables.TargetX = game.Player:GetCenter()
			elseif variables.State == 3 then
				variables.State = 0
			end
		else variables.Timer = variables.Timer - dt
		end
	end


	if variables.RandOffset and variables.FireTimer <= 0 then
		local cx, cy = self:GetCenter()

		variables._f = false
			
		for i = 1, 2 do	
			local bullet = game.Spawn(Bullet.new, cx, cy + variables.RandOffset, 16, 300, nil, nil)
			bullet:SetDirection(variables._f and math.rad(-180) or 0)
			bullet.LeaveTimer = variables.LeaveTimerSet
			bullet.Increase = variables._f and -1 or 1
			bullet.Behavior = _4bulbev
			variables._f = not variables._f
		end

		variables.FireTimer = 0.075 * 0.25
	else variables.FireTimer = variables.FireTimer - dt
	end

	self.MoveTo(variables.TargetX, variables.Y)
end

local function _5setup(variables, self)
	variables.FireTimer = 0.5
	variables.AngleIncrementIncrement = math.rad(.05)
	variables.AngleIncrement = 0
	variables.Angle = 180
	variables.Sides = 5
	variables.FullCircleRad = math.rad(360)
	variables.BulletColor = {0.3, 0.1, 0.8}
	self.MoveTo(boundaries.w*0.5, 200)
	variables.SideTimer = 1
	variables.ShotsToTurn = 100
end

local function _5(self, variables, dt)
	if variables.FireTimer <= 0 then
		local cx, cy = self:GetCenter()
		local div = variables.FullCircleRad / variables.Sides
		
		-- print(variables.Sides)
		for i = 1, variables.Sides do
			game.Spawn(Bullet.new, cx, cy, 7, 600, nil, nil, variables.BulletColor):SetDirection(variables.Angle + ((i - 1) * div))
		end
	
		if variables.ShotsToTurn <= 0 then
			variables.FireTimer = 0.0125 * 0.5
			variables.Angle = variables.Angle + variables.AngleIncrement
			variables.AngleIncrement = variables.AngleIncrement + variables.AngleIncrementIncrement
		else variables.ShotsToTurn = variables.ShotsToTurn - 1
		end
	else variables.FireTimer = variables.FireTimer - dt
	end

	if variables.SideTimer <= 0 then
		variables.Sides = variables.Sides + 1

		if variables.Sides > 16 then
			variables.Sides = 6
		end

		variables.SideTimer = 1
	else variables.SideTimer = variables.SideTimer - dt
	end
end

local start_index = 1 -- if you are wondering why this exists, because scrolling in vim and memorizing line numbers is such a pain

local function _6setup(variables, self)
	-- variables.Angle = 0
	-- variables.IncAngle = math.rad(40)
	self.MoveTo(boundaries.w * 0.5, 250)
	variables.Groups = {}
	variables.AngleGroupInc = math.rad(25)
	variables.NewGroupTimer = 1
	variables.Set = 2.25
	variables.Half = false
end

local function _6(self, variables, dt)
	local pcx, pcy = game.Player:GetCenter()
	--self.MoveTo(pcx + math.cos(variables.Angle) * 200, pcy + math.sin(variables.Angle) * 200)
	--variables.Angle = variables.Angle + (variables.IncAngle * dt)

	if self.Health / self.MaxHealth <= 0.5 and not variables.Half then
		variables.Half = true
	end

	if variables.NewGroupTimer <= 0 then
		local bullet_amount = 13
		local rotation = -1
		local radius = 250
		local radius_velocity = 180
		local start_angle = 0

		for _ = 1, 4 + (variables.Half and 2 or 0) do
			local new_group = {
				Center = {
					X = pcx;
					Y = pcy;
				};

				Bullets = {};
				RemoveFlag = false;
				Angle = start_angle;
				RadiusVelocity = radius_velocity;
				Radius = radius;
				Rotation = rotation;
			}

			local div = math.rad(360 / bullet_amount)
			for i = 1, bullet_amount do
				local bulang = ((i - 1) * div)
				local bullet = game.Spawn(Bullet.new, -10, 10,
					20, nil, nil, nil, {0.63, 0.912, 0.35, 0}	
				)

				bullet.Fencing = false
				bullet.CanCollide = false

				-- print(math.deg(bulang))
				-- print(math.deg(bulang))
				
				table.insert(new_group.Bullets, {
					Bullet = bullet;
					Angle = bulang
				})
			end
			
			table.insert(variables.Groups, new_group)
			rotation = -rotation
			bullet_amount = math.floor(bullet_amount * 1.5)
			radius = radius * 1.2
			radius_velocity = radius_velocity * 2 
			start_angle = start_angle + math.rad(120)
		end

		variables.NewGroupTimer = variables.Set
		variables.Set = variables.Set * 0.9888
	else variables.NewGroupTimer = variables.NewGroupTimer - dt
	end

	for _, group in ipairs(variables.Groups) do
		for _, bullet in ipairs(group.Bullets) do
			local actual = bullet.Bullet

			actual.X = (group.Center.X + (math.cos(group.Angle + bullet.Angle) * group.Radius)) - (actual.Size * 0.5)
			actual.Y = (group.Center.Y + (math.sin(group.Angle + bullet.Angle) * group.Radius)) - (actual.Size * 0.5)
		
			if actual.Color[4] >= 1 and not actual.CanCollide then
				actual.CanCollide = true
			else
				actual.Color[4] = actual.Color[4] + (dt)
			end
		end

		group.Angle = group.Angle + ((variables.AngleGroupInc * group.Rotation) * dt)
	
		group.RadiusVelocity = group.RadiusVelocity - (100 * dt)
		group.Radius = group.Radius + ((group.RadiusVelocity * dt) * 0.25)

		if group.Radius <= 0 then
			-- print(#group.Bullets)
			-- print(unpack(group.Bullets))

			for _, bullet in ipairs(group.Bullets) do
				bullet.Bullet.RemoveFlag = true
			end

			game.Spawn(Item.new, group.Center.X, group.Center.Y, 5)
			group.RemoveFlag = true
		end
	end

	cleanuptable(variables.Groups)
end

-- not actually 7th state, but explosion
-- local _7, _7setup


local attacks = {
	{1, _1setup, _1};
	{2, _2setup, _2, 50};
	{2.5, _3setup, _3, 40};
	{2, _4setup, _4, 60};
	{1.5, _5setup, _5, 60};
	{4, _6setup, _6, 240};
	-- {999, _7setup, _7, 999};
}

local BOSS_CONSTANT_HEALTH = 200

local function _7setup(variables, self)
	game.GameSpeed = 0.15
	-- game.ShakeIntensity = 5
	playsound("bomb")

	variables.DeathTimer = 0.5
	variables.LoseStarTimer = 0.15

	local cx, cy = self:GetCenter()
	game.Spawn(CircleParticle.new, cx, cy, 1, 10, 1000)
end

local function _7(self, variables, dt)
	attacks[self.AttackIndex - 1][3](self, variables, dt)

	if variables.LoseStarTimer <= 0 then
		local cx, cy = self:GetCenter()

		game.Spawn(Particle.new, {
			X = cx;
			Y = cy;
			Size = math.random(60, 120);
		}, {
			Size = math.random(10, 40)
		})

		for i = 1, 2 do
			playsound("enemyhit")
		end
		
		variables.LoseStarTimer = 0.05
	else
		variables.LoseStarTimer = variables.LoseStarTimer * dt
	end

	-- print(variables.DeathTimer)

	if variables.DeathTimer <= 0 then
		game.ShakeIntensity = 20
		self.Health = 0
	else variables.DeathTimer = variables.DeathTimer - dt
	end
end

table.insert(attacks, {999, _7setup, _7, 999})

local function handle_moveto(self, dt)
	self.X = self.X + (self.CurrentMoveTo.X - self.X) * (dt * 6)
	self.Y = self.Y + (self.CurrentMoveTo.Y - self.Y) * (dt * 6)
end

local TIMEOUT = 30
local function boss_behavior(self, dt)
	handle_moveto(self, dt)
	
	if self.IntroduceTimer > 0 then
		self.IntroduceTimer = self.IntroduceTimer - dt
		return
	end

	if not self.AttackSetup then
		if not self.NoClearVariables then
			table.cleardict(self.Variables)
		end

		attacks[self.AttackIndex][2](self.Variables, self)
		self.AttackSetup = true
		self.AttackTimer = attacks[self.AttackIndex][4] or TIMEOUT
		self.Health = BOSS_CONSTANT_HEALTH * attacks[self.AttackIndex][1]
		self.MaxHealth = self.Health
	end

	
	attacks[self.AttackIndex][3](self, self.Variables, dt)

	if self.AttackTimer <= 0 then
		self.Health = 0
	else self.AttackTimer = self.AttackTimer - dt
	end
end

local function health_depleted(self)
	-- print("yes")
	self.AttackIndex = self.AttackIndex + 1
	
	if self.AttackIndex == #attacks then
		self.NoClearVariables = true
		game.AttachedHealth = nil
	else
		self.IntroduceTimer = 2
		game:Nerf(true)

		-- if self.AttackIndex <= #attacks then
			self.MaxHealth = 99999
		-- end
	end
	
	self.Health = 99999
	self.AttackSetup = false
	-- power_charge(self:GetCenter())

	local remove = self.AttackIndex > #attacks
	
	if remove then
		-- game.AttachedHealth = nil
		game.GameSpeed = 1
		game.BossTime = false
		playsound("bomb")
	end
	
	return remove
end

return function()
	-- print("called")
	game.BossTime = true

	local boss = game.Spawn(Enemy.new, boundaries.w * 0.5, -100, 150, 150, 99999)
	boss.CurrentMoveTo = {X=0;Y=0}
	boss.HealthDepleted = health_depleted
	boss.BombUnaffected = true

	function boss.MoveTo(x, y, center)
		center = center == nil
		boss.CurrentMoveTo.X = center and (x - boss.Width * 0.5) or x
		boss.CurrentMoveTo.Y = center and (y - boss.Height * 0.5) or y
	end

	function boss.MoveRandom()
		boss.MoveTo(math.clamp(boss.X + math.random(-100, 100), 0, boundaries.w - boss.Width), math.clamp(boss.Y + math.random(-100, 100), 0, 300), false)
	end

	-- boss.Boss = true
	
	boss.Variables = {}
	boss.AttackSetup = false
	boss.AttackIndex = start_index
	boss.IntroduceTimer = 1
	boss.Behavior = boss_behavior
	boss.AttackTimer = 0

	boss.MoveTo(boundaries.w*0.5, 300)
	game:AttachHealth(boss)
end
