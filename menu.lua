local module = {}
local selection

function module.update(dt)

end

local function draw_start()
	graphics.setFont(assets.HUDFont)
end

local function draw_iterate(self, index, value, selected)
	local y = 300 + ((index - 1) * (assets.HUDFont:getHeight() + 5))
	graphics.setColor(1, 1, 1, selected and 1 or 0.5)
	graphics.print(value[1], boundaries.w * 0.5, y, 0, 1, 1, assets.HUDFont:getWidth(value[1]) * 0.5, 0)
end

function module.draw()
	graphics.setColor(1, 1, 1, 1)
	graphics.setFont(assets.TitleFont)
	graphics.print("EarlyDanmaku", boundaries.w * 0.5, 100, 0, 1, 1, assets.TitleFont:getWidth("EarlyDanmaku") * 0.5, 0)
end

function module.setup()
	selection = Selection.new({
		Items = {
			{"play", function()
				current_selection = nil
				new_scene(scenes.game, LevelData)
			end};
			{"challenge play", function()
				current_selection = nil
				new_scene(scenes.game, ExtremeLevelData)
			end};
			{"quit", love.event.quit};
		}
	})

	selection.SelfDraw = draw_start
	selection.DrawIterate = draw_iterate
	current_selection = selection
end

return module
