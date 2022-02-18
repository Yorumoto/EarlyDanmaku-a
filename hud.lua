local module = {}
local FONT = assets.HUDFont
-- print(FONT)

local score_interpolate, last_score, score_interpolate_inc

local BOMB_ICON = assets.power_star
local HEART_ICON = assets.heart
local DSP_SIZE = 45

local SETUP_SIZE_SCALE = {{BOMB_ICON, "Bomb"}, {HEART_ICON, "Heart"}}
local scales = {}

for _, data in ipairs(SETUP_SIZE_SCALE) do
	local image, name = unpack(data)
	scales[name] = {
		w = DSP_SIZE / image:getWidth();
		h = DSP_SIZE / image:getHeight()
	}
end

function module:Reset()
	score_interpolate = 0
	last_score = 0
	score_interpolate_inc = 0
end

function module:Update(dt)
	if game.Score ~= last_score then
		local dif = game.Score - last_score
		local new_inc = dif / 48

		if new_inc > score_interpolate_inc then
			score_interpolate_inc = new_inc
		end
	end

	score_interpolate = score_interpolate + score_interpolate_inc

	if score_interpolate > game.Score then
		score_interpolate = game.Score
		score_interpolate_inc = 0
	end

	last_score = game.Score
end

function module:Draw()
	graphics.setColor(1.0, 1.0, 1.0, 1.0)
	graphics.setFont(FONT)
	graphics.print(string.format("%.11i", score_interpolate), 10, 10)
	graphics.draw(HEART_ICON, 300, 10, 0, scales.Heart.w, scales.Heart.h)
	graphics.print(math.max(game.Lives, 0), 400, 10)
	graphics.draw(BOMB_ICON, 450, 10, 0, scales.Bomb.w, scales.Bomb.h)
	graphics.print(game.Bombs, 600, 10)
	graphics.print("Graze", 650, 10)
	graphics.print(string.format("%.3i", game.Graze), 800, 10)
end

return module
