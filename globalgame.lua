local this = {
	Score = 0;
	Graze = 0;
	Entities = {};
	Events = {};
	EventIndex = 1;
}

function this:ParseLevel(level_data)
	if not level_data then return end

	table.clear(this.Events)
	
	local total_time = 0

	for _, event_data in ipairs(level_data) do
		if #event_data > 0 then
			local compiled_data = {Args={}}

			for i, item in ipairs(event_data) do
				if i == 1 then
					total_time = total_time + (tonumber(item) or 0)
				elseif i == 2 then
					compiled_data.Function = item	
				else
					table.insert(compiled_data.Args, item)
				end
			end
			
			compiled_data.Time = total_time
			table.insert(self.Events, compiled_data)
		end
	end

	this.LastLevel = level_data
	this.EventIndex = 1
end

function this:AttachHealth(entity)
	-- print(entity, entity.Health, entity.MaxHealth)

	if not entity or not entity.Health or not entity.MaxHealth or entity.Health <= 0 then
		return
	end

	this.AttachedHealth = entity
end

function this:Pause(new)
	-- print("paused", new)
	if not this.Paused and new then
		if this.PauseTimer > 0 then
			return
		end

		this.Paused = true
		current_selection = this.PauseSelection
		current_selection.Index = 1
		current_selection.Selectable = true
		current_selection.Locked = false
	elseif this.Paused and not new then
		this.Paused = false
		this.PauseTimer = 0.75
		current_selection.Selectable = false
		current_selection.Locked = true
	end
end

function this:Reset()
	hud:Reset()
	table.clear(self.Entities)
	this.Score = 0
	this.Graze = 0
	this.Bombs = 3
	this.Lives = 3
	this.Paused = false
	this.PauseTimer = 0
	this.EventTimer = 0
	this.PauseTransparency = 0
	this.BossTime = false
	this.AttachedHealth = nil
	this.GameSpeed = 1
	this.ShakeIntensity = 0
	this.TranslateX = 0
	this.TranslateY = 0
	this.GameFinished = false
end

local function nerf_f(_, entity, type, any)
	if entity.BombUnaffected and not any then
		return
	end

	if type == "Enemy" then
		entity.Health = entity.Health * 0.1
	elseif type == "Bullet" then
		local cx, cy = entity:GetCenter()
		entity.RemoveFlag = true
		local item = game.Spawn(Item.new, cx, cy, 0.05)
		item.AutoCollect = true
	end
end

function this:Nerf(no_matter_what)
	-- print(no_matter_what)
	-- print(...)
	game.every_entity(nerf_f, no_matter_what)
end

function this:AddScore(amount, x, y)
	amount = tonumber(amount) or 0
	amount = amount * ((this.Graze + 1) * 0.25)
	
	amount = math.floor(amount)
	this.Score = this.Score + amount
	-- print(this.Score)

	if not x or not y then
		return
	end

	this.Spawn(FloatingNumbers.new, x, y, tostring(amount))
end

local PAUSE_FONT = assets.HUDFont
local PAUSE_FONT_HEIGHT = assets.HUDFont:getHeight()

local function pause_start_draw(self)
	graphics.setColor(0, 0, 0, this.PauseTransparency)
	graphics.rectangle("fill", 0, 0, boundaries.w, boundaries.h)
	graphics.push()
	graphics.translate(boundaries.w * 0.5, boundaries.h * 0.5)
	graphics.scale(unpack(self.Scale))
	graphics.setFont(PAUSE_FONT)
	graphics.setColor(1, 1, 1, 1)
	
	local text = this.GameFinished and "all clear" or (this.Lives < 0 and "game over" or "paused")
	graphics.print(text, 0, boundaries.h * -0.15, 0, 1, 1, PAUSE_FONT:getWidth(text) * 0.5, PAUSE_FONT_HEIGHT * 0.5)
end

local function pause_finish_draw(self)
	graphics.pop()
	graphics.scale(1, 1)
end

local function pause_draw_iterate(self, index, value, selected)
	local starting_point = boundaries.h * 0.05
	-- print(index, value)
	graphics.setColor(1, 1, 1, selected and 1 or 0.5)
	graphics.print(value[1], 0, starting_point + ((PAUSE_FONT_HEIGHT + 5) * (index - 1)), 0, 1, 1, PAUSE_FONT:getWidth(value[1]) * 0.5, PAUSE_FONT_HEIGHT * 0.5)
end

local function pause_selection_update(self, dt)
	self.Scale[2] = self.Scale[2] + ((this.Paused and 1 or 0) - self.Scale[2]) * (15 * dt)

	if this.Paused then
		this.PauseTransparency = math.min(this.PauseTransparency + dt, 0.7)
	else
		this.PauseTransparency = math.max(this.PauseTransparency - dt, 0)
	end
end

function this:GameOver()
	local current_items = this.PauseSelection.Items

	this:Pause(true)
	table.remove(this.PauseSelection.Items, 1)
end

function this:Setup()
	this:Reset()
	this.Player = this.Spawn(Player.new, boundaries.w * 0.5, boundaries.h * 0.85)
	
	this.PauseSelection = Selection.new({
		Items = {
			{"resume", function() this:Pause(false) end};
			{"restart", function()
				current_selection = nil
				new_scene(scenes.game, this.LastLevel)
			end};
			{"return", function()
				new_scene(scenes.menu)
			end}
		};	
	})

	this.PauseSelection.Scale = {1, 0}
	this.PauseSelection.SelfUpdate = pause_selection_update
	this.PauseSelection.SelfDraw = pause_start_draw
	this.PauseSelection.SelfFinishDraw = pause_finish_draw
	this.PauseSelection.DrawIterate = pause_draw_iterate
end

function this.every_entity(loop_callback, ...)
	if not loop_callback then
		return
	end
	
	for i, v in ipairs(this.Entities) do
		loop_callback(i, v, typeof(v), ...)
	end
end

function this.Spawn(constructor, ...)
	local new_entity = constructor(...)
	new_entity.RemoveFlag = false
	table.insert(this.Entities, new_entity)
	return new_entity
end

return this
