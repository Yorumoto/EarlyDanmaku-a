local scene = {}
-- local demo_shoot_timer = 0
local render_priorities = {}

local every_entity = game.every_entity

local function fill_render_priority(entity, group_number)
	if not render_priorities[group_number] then
		render_priorities[group_number] = {}
	end

	table.insert(render_priorities[group_number], entity)
end

local function get_render_priority(_, entity, type)
	if not entity.Draw then
		return
	end
		
	fill_render_priority(entity, entity.RenderPriority and entity.RenderPriority or 0)
end

local function enemy_health()	
	if not game.AttachedHealth then
		return
	end

	local ref = game.AttachedHealth
	local div = (ref.Health or 0) / (ref.MaxHealth or 1)
	
	graphics.setColor(1, 1, 1, 1)
	graphics.rectangle("fill", boundaries.w * 0.05, 70, (boundaries.w * 0.9) * div, 15)
	graphics.setFont(assets.HUDFont)

	if ref.AttackTimer then
		graphics.setColor(ref.AttackTimer <= 10 and {0.7, 0, 0, 1} or {1, 1, 1, 1})
		local attack_timer_text = string.format("%.2f", ref.AttackTimer)
		graphics.print(attack_timer_text, boundaries.w * 0.5, 95, 0, 1, 1, assets.HUDFont:getWidth(attack_timer_text) * 0.5)
	end
end

local function draw_objects()
	graphics.push()
	graphics.translate(game.TranslateX, game.TranslateY)
	table.cleardict(render_priorities)	
	every_entity(get_render_priority)


	for _, group in pairs(render_priorities) do
		for _, item in ipairs(group) do
			if item then
				item:Draw()
			end
		end
	end

	-- hud shit
	
	enemy_health()
	graphics.pop()
	hud:Draw()
	-- graphics.print(tostring(game.BossTime), 10, 400)
	
end

local function draw()
	draw_objects()    
    -- draw_text()    
end

local function update_entity(_, entity, type, dt)
	if entity.Update then
		entity:Update(dt)
	end
end

local function handle_level(dt)
	-- print(game.EventIndex, game.Events)
	if not game.BossTime then
		game.EventTimer = game.EventTimer + dt
	end

	if game.EventIndex > #game.Events then
		return
	end

	local next_event = game.Events[game.EventIndex]
	
	if next_event.Time >= game.EventTimer then
		return
	end

	if next_event.Function then
		next_event.Function(unpack(next_event.Args))	
	end

	game.EventIndex = game.EventIndex + 1
end

function scene.update(dt)
	hud:Update(dt)
	
	if game.Paused or game.PauseTimer > 0 then
		if not game.Paused and game.PauseTimer > 0 then
			game.PauseTimer = game.PauseTimer - dt
			
			if game.PauseTimer <= 0 then
				current_selection = nil
			end
		end

		return
	end

	dt = dt * game.GameSpeed
	handle_level(dt)
	every_entity(update_entity, dt)
	cleanuptable(game.Entities)

	game.ShakeIntensity = game.ShakeIntensity + (-game.ShakeIntensity) * (dt * 3)
	game.TranslateX = math.random(-5, 5) * game.ShakeIntensity
	game.TranslateY = math.random(-5, 5) * game.ShakeIntensity
end

function scene.setup(level)
	
    game:Setup()
	game:ParseLevel(level)

	connections.keypressed = {
		escape = function()
			game:Pause(not game.Paused)
		end;
	}
end

scene.draw = draw

return scene
