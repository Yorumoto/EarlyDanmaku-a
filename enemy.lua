local module = {}
module.__index = module
module.__type = "Enemy"

local ENEMY_COLOR = {0.9, 0, 0, 1.0}

-- at this point, i've should've made myself a rect library :pensive:
function module:GetCenter()
	return self.X + self.Width * 0.5, self.Y + self.Height * 0.5
end

function module:UpdateHitbox()
	self.Hitbox:Update(self.X + self.Width * 0.5, self.Y + self.Height * 0.5)
end

function module:Draw()
	graphics.setColor(ENEMY_COLOR)
	graphics.rectangle("fill", self.X, self.Y, self.Width, self.Height)
end

local function default_depleted()
	return true
end

function module:Update(dt)
	if self.Behavior then
		self.Behavior(self, dt)
	end
	
	self:UpdateHitbox()
	-- game.every_entity(check_player_collision)

	if collides(game.Player.Hitbox, self.Hitbox) then
		game.Player:Death()
	end

	if self.Health <= 0 then
		local remove_flag = (self.HealthDepleted or default_depleted)(self)
		-- print(self.MaxHealth)
		
		local cx, cy = self:GetCenter()
		
		if self.MaxHealth <= 1000 then
			game:AddScore((self.MaxHealth * 25) ^ 2, cx, cy)

			for i = 1, 20 do	
				game.Spawn(Particle.new, {
					X = cx;
					Y = cy;
				})
			end

		-- math.floor(self.MaxHealth / 4)
			for _ = 1, math.floor(self.MaxHealth / 4) do
				game.Spawn(Item.new, cx + math.random(-80, 80), cy + math.random(-80, 80))
			-- game.Spawn(Item.new, cx + math.random(-600, 600), math.random(-600, 600))
			end
		end

		game.Spawn(CircleParticle.new, cx, cy, 0.5, 40, 200)
		playsound("pop")
		playsound("enemyhit")
		self.RemoveFlag = remove_flag
	end
end

function module.new(x, y, width, height, health, setup)
	local self = setmetatable({
		X = x or 0;
		Y = y or 0;
		HitTagNumber = 2;
		Width = width or 75;
		Height = height or 75;
		MaxHealth = health or 50;
		RenderPriority = 2;
	}, module)
	
	self.Health = self.MaxHealth
	self.X = self.X - self.Width * 0.5
	self.Y = self.Y - self.Height * 0.5
	self.Hitbox = Hitbox.new(nil, nil, self.Width * 0.65, self.Height * 0.65)
	self:UpdateHitbox()

	if setup then
		setup(self)
	end

	return self
end

return module
