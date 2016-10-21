local learning = require "ml"

local player = {
	x = 0x0094,
	y = 0x0096,
	speed = 0x007b,
	animation_trigger = 0x0071,
	on_air = 0x0072,
	on_ground = 0x13ef,
	reaction = {
		x = 32,
		y = 15,
	},
	blocked_status = 0x0077,
}

function getPlayer()
	return {
		x = memory.readwordsigned(player.x)+8,
		y = memory.readwordsigned(player.y)+16
	}
end

local sprite = {
	number = 0x009e,
	status = 0x14c8,
	x_high = 0x14e0,
	x_low = 0x00e4,
	y_high = 0x14d4,
	y_low = 0x00d8,
	x_offscreen = 0x15a0,
	y_offscreen = 0x186c,
}

local extended_sprite = {
	number = 0x170b,
    x_high = 0x1733,
    x_low = 0x171f,
    y_high = 0x1729,
    y_low = 0x1715,
    x_speed = 0x1747,
    y_speed = 0x173d,
}

function Set (list)
	local set = {}
	for _, l in ipairs(list) do set[l] = true end
	return set
end

local camera = {
	x = 0x001a,
	y = 0x001c,
	screens_number = 0x005d,
	hscreen_number = 0x005e,
	vscreen_number = 0x005f,
	vertical_scroll = 0x1412,
	camera_scroll_timer = 0x1401,
}

local commands = {
	{button = "A", states = {false, true}},
	{button = "Y", states = {false, true}},
	{button = "B", states = {false, true}},
	{button = "right", states = {true, false}},
}

local variations = {}
local reactions = {}
local decision_tree = {}
local resets = 0

function new(var)
	local new_var = {}
	for k, v in pairs(var) do
		new_var[k] = v
	end

	return new_var
end

local variationIndex = 0;
function generateVariations(action, index)
	local command = commands[index]
	for i=1, #command.states, 1 do
		action[command.button] = command.states[i]
		if index < #commands then
			generateVariations(action, index+1)
		else
			variationIndex = variationIndex + 1
			local variation = {
				action = new(action),
				weight = 1000,
				index = variationIndex
			}
			table.insert(variations, variation)
		end
	end
end

function optimizeVariation(variationIndex)
	local i=1
	while i < #variations do
		if variations[i].index == variationIndex then
			variations[i].weight = variations[i].weight - 1
			break
		end
		i = i + 1
	end

	local aux
	if variations[i+1] ~= nil and variations[i+1].weight > variations[i].weight then
		aux = variations[i]
		variations[i] = variations[i+1]
		variations[i+1] = aux
	else if variations[i-1] ~= nil and variations[i-1].weight < variations[i].weight then
		aux = variations[i]
		variations[i] = variations[i-1]
		variations[i-1] = aux
	end
	end
end

function saveFile(filename, obj)
	local file = io.open(filename, "w")
	file:write(tostring(obj))
	file:flush()
	file:close()
end

function loadFile(filename)
	local file = io.open(filename, "r")
	if file == nil then
		saveFile(filename, {})
		file = io.open(filename, "r")
	end
	local response = file:read()
	file:close()
	return response
end

function cleanFile(filename)
	local file = io.open(filename, "w")
	file:write("")
	file:flush()
	file:close()
end

function removeFile(filename)
	os.remove(filename)
end

function getFilePath(filename)
	local info = debug.getinfo(1, "S")
	local path = info.source:sub(2)

	path = path:gsub("smw.lua", filename)

	return path
end

function reload(save_num)
	local save_state = savestate.create(save_num)
	resets = resets + 1
	savestate.load(save_state)
end

function signed(num, bits)
    local maxval = 2^(bits - 1)

    if num < maxval then
    	return num
    else
    	return num - 2*maxval
    end
end

function console()
	gui.text(10, 200, "X: " .. getPlayer().x)
	gui.text(10, 210, "Y: " .. getPlayer().y)
	gui.text(50, 210, "Speed: " .. memory.readbyte(player.speed))
	gui.text(100, 210, "Resets: " .. tostring(resets))
end

function screenCoordinates(x, y, camera_x, camera_y)
    local x_screen = (x - camera_x)
    local y_screen = (y - camera_y) - 1

    return x_screen, y_screen
end

function drawSprite(screen_x, screen_y, color, id, st)
	gui.line(screen_x-8, screen_y, screen_x+8, screen_y, color)
	gui.line(screen_x, screen_y-8, screen_x, screen_y+8, color)
	gui.text(screen_x-8, screen_y, id)
	gui.text(screen_x+8, screen_y, st)
end

function drawExtendedSprite(screen_x, screen_y, color, id, st)
	gui.line(screen_x-8, screen_y, screen_x+8, screen_y, color)
	gui.line(screen_x, screen_y-8, screen_x, screen_y+8, color)
	gui.text(screen_x-8, screen_y, id)
	gui.text(screen_x+8, screen_y, st)
end

function drawBlock(screen_x, screen_y, width, height, color)
	local x, y = screen_x-(width/2), screen_y-(width/2)

	gui.line(x, y, x+width, y, color)
	gui.line(x, y+height, x+width, y+height, color)

	gui.line(x, y, x, y+height, color)
	gui.line(x+width, y, x+width, y+height, color)
end

function drawFieldOfView()
	local x_screen, y_screen = screenCoordinates(getPlayer().x, getPlayer().y, memory.readwordsigned(camera.x), memory.readwordsigned(camera.y))

	gui.box(x_screen-player.reaction.x, y_screen+player.reaction.y, x_screen+player.reaction.x, y_screen-player.reaction.y, 0,"blue")
end

function debugger(game_x, game_y, text)
	local screen_x, screen_y = screenCoordinates(game_x, game_y, memory.readwordsigned(camera.x), memory.readwordsigned(camera.y))
	drawBlock(screen_x, screen_y, 16, 16, "purple")
	gui.text(screen_x, screen_y, text)
end

function toClassify(table)
	local features = {}
	local labels = {}
	for ki, vi in pairs(table) do
		for kj, vj in pairs(vi) do
			for kk, vk in pairs(vj) do
				features[#features+1] = {ki, kj, kk}
				labels[#labels+1] = vk
			end
		end
	end
	return features, labels
end

function updateTree(reactions)
	local features, labels = toClassify(reactions)

	decision_tree = learning.tree(features, labels)
end

function getSprites()
	local sprites = {}

	for i=0, 12, 1 do
		local s = {
			x = 256*memory.readbyte(sprite.x_high + i) + memory.readbyte(sprite.x_low + i),
			y = 256*memory.readbyte(sprite.y_high + i) + memory.readbyte(sprite.y_low + i),
			id = memory.readbyte(sprite.number + i),
			st = memory.readbyte(sprite.status + i)
		}

		s.x = signed(s.x, 16)+8
    	s.y = signed(s.y, 16)+8

    	local screen_x, screen_y = screenCoordinates(s.x, s.y, memory.readwordsigned(camera.x), memory.readwordsigned(camera.y))

		if s.st ~= 0 then
			table.insert(sprites, s)
			drawSprite(screen_x, screen_y, "red", s.id, s.st)
		end
	end

	return sprites
end

function getExtendedSprites()
	local extended = {}

	for i=0, 11, 1 do
		local e = {
			x = 256*memory.readbyte(extended_sprite.x_high + i) + memory.readbyte(extended_sprite.x_low + i),
			y = 256*memory.readbyte(extended_sprite.y_high + i) + memory.readbyte(extended_sprite.y_low + i),
			id = memory.readbyte(extended_sprite.number + i),
			st = 0
		}

		e.x = signed(e.x, 16)+8
    	e.y = signed(e.y, 16)+8

    	local screen_x, screen_y = screenCoordinates(e.x, e.y, memory.readwordsigned(camera.x), memory.readwordsigned(camera.y))

		if e.id ~= 0 then
			table.insert(extended, e)
			drawExtendedSprite(screen_x, screen_y, "red", e.id, e.st)
		end
	end

	return extended
end

function getTile(map16_x, map16_y)
	local game_x = math.floor((getPlayer().x+map16_x+8)/16)
	local game_y = math.floor((getPlayer().y+map16_y)/16)
	local id = math.floor(game_x/0x10)*0x1B0 + game_y*0x10 + game_x%0x10

	return (game_x*16)+8, (game_y*16)+8, memory.readbyte(0x7FC800 + id)
end

function getBlocks()
	local blocks = {}

	local size = 160

	for m16_y=-size, size, 16 do
		for m16_x=-size, size, 16 do
			local game_x, game_y, tile = getTile(m16_x, m16_y)

			-- debugger(game_x, game_y, tile)

			if tile == 1 then
				local screen_x, screen_y = screenCoordinates(game_x, game_y, memory.readwordsigned(camera.x), memory.readwordsigned(camera.y))

				local b = {
					x = game_x,
					y = game_y,
					st = 0,
					id = tile
				}

				drawBlock(screen_x, screen_y, 16, 16, "green")

				table.insert(blocks, b)
			end
		end
	end

	return blocks
end

function generateSituation(elements)
	local s = {
		id = "",
		st = "",
		pos = 0
	}

	if #elements ~= 0 then
		for i=1, #elements, 1 do
			s.id = s.id .. tostring(elements[i].id)
			s.st = s.st .. tostring(elements[i].st)
			s.pos = s.pos + elements[i].y
		end
		s.pos = s.pos / #elements
	end

   	return s
end

function getClosestElements()
	local cs = {}

	local sprites = getSprites()
	local blocks = getBlocks()
	local extended = getExtendedSprites()

	for i=1, #sprites, 1 do
		if math.abs(getPlayer().x - sprites[i].x) <= player.reaction.x and math.abs(getPlayer().y - sprites[i].y) <= player.reaction.y then
			table.insert(cs, sprites[i])
		end
	end

	for i=1, #blocks, 1 do
		if math.abs(getPlayer().x - blocks[i].x) <= player.reaction.x and math.abs(getPlayer().y - blocks[i].y) <= player.reaction.y then
			table.insert(cs, blocks[i])
		end
	end

	for i=1, #extended, 1 do
		if math.abs(getPlayer().x - extended[i].x) <= player.reaction.x and math.abs(getPlayer().y - extended[i].y) <= player.reaction.y then
			table.insert(cs, extended[i])
		end
	end

	return cs
end

function playerDeath(situation, reactionIndex)
	optimizeVariation(reactionIndex)

	local newReact = {
		action = variations[1].action,
		index = 1,
		variations = variations
	}

	if reactions[situation.id] == nil then
		reactions[situation.id] = {}
		reactions[situation.id][situation.st] = {}
		reactions[situation.id][situation.st][situation.pos] = newReact
	elseif reactions[situation.id][situation.st] == nil then
		reactions[situation.id][situation.st] = {
			[situation.pos] = newReact
		}
	elseif reactions[situation.id][situation.st][situation.pos] == nil then
		reactions[situation.id][situation.st][situation.pos] = newReact
	else
		local react = reactions[situation.id][situation.st][situation.pos]

		if react ~= nil and react.index < #react.variations then
			react.index = react.index + 1
			react.action = react.variations[react.index].action
			reactions[situation.id][situation.st][situation.pos] = react
		else
			print("you shall not pass!")
		end
	end

	updateTree(reactions)

	print(situation, reactions[situation.id][situation.st][situation.pos].action)

	saveFile(getFilePath("db.lua"), reactions)

	reload(1)
end

local stuckCount = 0
local stuckDelay = 100
local player_last_x = getPlayer().x

function frameCount()
	stuckCount = stuckCount + 1

	if stuckCount >= stuckDelay then
		if getPlayer().x <= player_last_x then
			playerDeath(generateSituation(getClosestElements()))
		else
			player_last_x = getPlayer().x
		end

		stuckCount = 0
	end
end

function playerAction()
	local situation = generateSituation(getClosestElements())

	local observation = {situation.id, situation.st, situation.pos}
	local react = decision_tree.run(observation)
	for k, v in pairs(react) do
		react = k
	end
	-- print(observation, react.action)
	joypad.set(react.action)

	if memory.readbyte(player.animation_trigger) == 9 then
		playerDeath(situation, react.index)
	end

	if memory.readbyte(player.speed) <= 7 then
		frameCount()
	else
		stuckCount = 0
		player_last_x = getPlayer().x
	end
end


local data_base_file = loadFile("db.lua")
-- reactions = loadstring("return ".. data_base_file)()
-- MOCK
reactions = {['']={['']={[0]={action={Y=false, right=true, A=false, B=false}, index=1}}}}
updateTree(reactions)
generateVariations({}, 1)

-- Update
while true do
	playerAction()
	console()
	drawFieldOfView()

	emu.frameadvance()
end
