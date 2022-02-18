-- :>

local assets = {}

local parse = {}

local function _image(filename)
	return graphics.newImage(filename)
end

local function _audio(filename)
	return audio.newSource(filename, "static")
end

--[[local function _shader(filename)
	local _, ret = pcall(function()
		return graphics.newShader(filename)
	end)

	if type(ret) == "string" then
		print("Shader failed to compile:\n" .. tostring(ret))
	end

	return ret
end]]--

-- might use this for later

local function _loader(_, script_name)
	for key, v in pairs(require("assets." .. script_name)) do
		if not assets[key] then
			assets[key] = v
		end
	end
end

parse.png = _image
parse.mp3 = _audio
parse.wav = _audio
parse.lua = _loader

for _, file in ipairs(fs.getDirectoryItems("assets")) do
	local name, ext = unpack(string.split(file, "."))	
	assets[name] = parse[ext]("assets/" .. file, name)
end

return assets
