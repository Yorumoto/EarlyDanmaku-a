local module = {}
module.__index = module

local function _u(self, by)
	if self.Locked then
		return
	end

	self.Index = self.Index + by
	
	if self.Index <= 0 then
		self.Index = #self.Items
	end

	if self.Index > #self.Items then
		self.Index = 1
	end

	playsound("collect")
end

function module:Draw()
	if self.SelfDraw then
		self.SelfDraw(self)
	end

	if self.DrawIterate then
		for index, value in ipairs(self.Items) do
			self:DrawIterate(index, value, index == self.Index)
		end
	end

	if self.SelfFinishDraw then
		self.SelfFinishDraw(self)
	end
end

function module:Update(dt)
	if self.SelfUpdate then
		self.SelfUpdate(self, dt)
	end
end

function module:Select()
	if self.Selectable and self.Items[self.Index] then
		self.Items[self.Index][2]()
	end
end

function module.new(setup)
	setup = setup or {}

	local self = setmetatable({}, module)
	self.Locked = false
	self.Index = 1
	self.Items = setup.Items or {}
	self.Selectable = true	
	
	local function selectself()
		self:Select()
	end
	
	self.Keys = setup.Keys or {
		up = function()
			_u(self, -1)
		end;

		down = function()
			_u(self, 1)
		end;

		z = selectself;
		["return"] = selectself;
	};

	return self
end

return module
