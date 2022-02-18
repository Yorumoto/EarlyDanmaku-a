audio, graphics, window, keyboard, fs = love.audio, love.graphics, love.window, love.keyboard, love.filesystem

connections = {
	keypressed = {};
}

--[[game = {
	Score = 0;
	Entities = {};
}]]--

current_selection = nil
selections = {}

boundaries = {
	w = 900;--900;
	h = 950;
}

timer = 0
scene = nil
game_canvas = nil

function reset_timer()
	timer = 0
end

local INC_DT = 1 / 240
local next_time = 0

local function fps_cap(dt)
	local cur_time = love.timer.getTime()

	if next_time <= cur_time then
		next_time = cur_time
		return
	end

	love.timer.sleep(next_time - cur_time)
end

local function update(dt)
	next_time = next_time + INC_DT
	timer = timer + dt

	
	if scene.update then
		scene.update(dt)
	end

	if current_selection then
		current_selection:Update(dt)
	end

	fps_cap(dt)
end

local function draw()
	local ww, wh = window.getMode()
	graphics.scale(ww / boundaries.w, wh / boundaries.h)
	
	-- graphics.setCanvas(game_canvas)
	-- graphics.clear()

	if scene.draw then
		scene.draw()
	end

	if current_selection then
		current_selection:Draw()
	end

	graphics.setCanvas()

end

function new_scene(which_new_scene, ...)
	scene = which_new_scene

	if scene and scene.setup then
		scene.setup(...)
	end
end

function love.keypressed(key)
	if current_selection and current_selection.Keys then
		local func = current_selection.Keys[key]

		if func then
			func()
		end
	end

	for nkey, func in pairs(connections.keypressed) do
		if nkey == key then
			func()
		end
	end
end

function love.load()
	for i = 1, 20 do
		math.randomseed(love.timer.getTime())
		math.randomseed(math.random(-10000,10000))
	end

	require("editbtin")
	assets = require("assets")
	game = require("globalgame")
	hud = require("hud")
	Bullet = require("bullet")
	Enemy = require("enemy")
	LevelData = require("level")
	ExtremeLevelData = require("extremelevel")
	Player = require("player")
	Hitbox = require("hitbox")
	CircleParticle = require("circleparticle")
	Particle = require("particle")
	Item = require("item")
	FloatingNumbers = require("floatingnumbers")
	Selection = require("selection")

	scenes = {
		game = require("game");
		menu = require("menu")
	}

	-- game:Setup()
	-- game:ParseLevel(LevelData)
	-- game.Spawn(Item.new, boundaries.w * 0.5, boundaries.h * 0.5)

	new_scene(scenes.menu)
	
	window.setMode(boundaries.w, boundaries.h, {resizable=true})
	window.setVSync(false)
	window.setTitle("danmako")
	game_canvas = graphics.newCanvas()
	
	next_time = love.timer.getTime()
end

love.update = update
love.draw = draw
