local u8 = memory.readbyte;
local s8 =  memory.readbytesigned
local s16 = memory.readwordsigned;

-- variables
local player = {
	x = 0x0094,
	y = 0x0096,
	speed = 0x007b,
	animation_trigger = 0x0071,
	on_air = 0x0072,
	on_ground = 0x13ef,
	reaction = {
		x = 55,
		y = 30,
	},
	blocked_status = 0x0077,
};

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

function Set (list)
	local set = {}
	for _, l in ipairs(list) do set[l] = true end
	return set
end

local block = {
	semi = Set {0, 1, 3, 4},
	solid = Set {51, 52, 53, 54, 69}
};

local camera = {
	x = 0x001a,
	y = 0x001c,
	screens_number = 0x005d,
	hscreen_number = 0x005e,
	vscreen_number = 0x005f,
	vertical_scroll = 0x1412,
	camera_scroll_timer = 0x1401,
}

local spriteReactions = {};
local sprites = {};

local blockReactions = {};
local blocks = {};

local actions = {"Y", "B", "right", "left"};
local variations = {};

-- calculation actions.
-- TODO change it to a recursive function
for i=1, 16, 1 do
    variations[i] = {
    	A = (math.floor(i/8%2) == 1),
    	Y = (math.floor(i/4%2) == 1),
    	B = (math.floor(i/2%2) == 1),
    	right = (math.floor(i%2) == 1)
    }
end

-- get the fucking savestate #1
-- local save_state = savestate.create(1);

-- functions
-- file IO functions
local function saveFile(filename, obj)
	local file = io.open(filename, "w");
	file:write(tostring(obj));
	file:flush();
	file:close();
end

local function loadFile(filename)
	local file = io.open(filename, "r");
	if file == nil then
		saveFile(filename, {});
		file = io.open(filename, "r");
	end
	local response = file:read();
	file:close();
	return response;
end

local function cleanFile(filename)
	local file = io.open(filename, "w");
	file:write("");
	file:flush();
	file:close();
end

local function removeFile(filename)
	os.remove(filename);
end

local function signed(num, bits)
    local maxval = 2^(bits - 1);

    if num < maxval then
    	return num;
    else
    	return num - 2*maxval;
    end
end

local function console()
	local count = 50;
	for i=1, #sprites, 1 do
		gui.text(110, count, "sprite: " .. tostring(sprites[i]));
		count = count + 10;
	end
	gui.text(10, 200, "X: " .. s16(player.x));
	gui.text(10, 210, "Y: " .. s16(player.y));
	gui.text(50, 210, "Speed: " .. u8(player.speed));
end

local function screenCoordinates(x, y, camera_x, camera_y)
    local x_screen = (x - camera_x);
    local y_screen = (y - camera_y) - 1;

    return x_screen, y_screen;
end

local function drawSprite(screen_x, screen_y, color, num, st)
	gui.line(screen_x+5, screen_y+5, screen_x+15, screen_y+5, color);
	gui.line(screen_x+10, screen_y, screen_x+10, screen_y+10, color);
	gui.text(screen_x, screen_y, num);
	gui.text(screen_x+16, screen_y, st);
end

local function drawBlock(screen_x, screen_y, width, height, color)
	gui.line(screen_x, screen_y, screen_x+width, screen_y, color);
	gui.line(screen_x, screen_y+height, screen_x+width, screen_y+height, color);

	gui.line(screen_x, screen_y, screen_x, screen_y+height, color);
	gui.line(screen_x+width, screen_y, screen_x+width, screen_y+height, color);
end

local function drawFieldOfView()
	local x_screen, y_screen = screenCoordinates(s16(player.x), s16(player.y)+15, s16(camera.x), s16(camera.y));

	x_screen = x_screen - player.reaction.x;
	y_screen = y_screen - player.reaction.y;

	local width = (player.reaction.x*2)+15;
	local height = (player.reaction.y*2)+15;

	drawBlock(x_screen, y_screen, width, height, "grey");
end

-- debug by game position
local function debugger(game_x, game_y, text)
	local screen_x, screen_y = screenCoordinates(game_x, game_y, s16(camera.x), s16(camera.y));
	drawBlock(screen_x, screen_y, "purple");
	gui.text(screen_x+3, screen_y+5, text);
end

local function getSprites()
	sprites = {};

	for i=0, 12, 1 do
		local e = {
			x = 256*u8(sprite.x_high + i) + u8(sprite.x_low + i),
			y = 256*u8(sprite.y_high + i) + u8(sprite.y_low + i),
			num = u8(sprite.number + i),
			st = u8(sprite.status + i)
		};

		e.x = signed(e.x, 16);
    	e.y = signed(e.y, 16);

    	local screen_x, screen_y = screenCoordinates(e.x, e.y, s16(camera.x), s16(camera.y));

		if e.st ~= 0 then
			table.insert(sprites, e);
			drawSprite(screen_x, screen_y, "red", e.num, e.st);
		end
	end
end

local function getTile(map16_x, map16_y)
	local game_x = math.floor((s16(player.x)+map16_x+8)/16);
	local game_y = math.floor((s16(player.y)+map16_y)/16);
	local id = math.floor(game_x/0x10)*0x1B0 + game_y*0x10 + game_x%0x10;

	return game_x*16, game_y*16, u8(0x7EC800 + id);
end

local function getBlocks()
	-- size = 6*16
	local size = 160;

	for m16_y=-size, size, 16 do
		for m16_x=-size, size, 16 do
			local game_x, game_y, tile = getTile(m16_x, m16_y);

			-- debugger(game_x, game_y, tile);

			-- Green ground
			if block.semi[tile] then
				local screen_x, screen_y = screenCoordinates(game_x, game_y, s16(camera.x), s16(camera.y));
				drawBlock(screen_x, screen_y, 15, 15, "green");
			end

			if block.solid[tile] then
				local screen_x, screen_y = screenCoordinates(game_x, game_y, s16(camera.x), s16(camera.y));
				drawBlock(screen_x, screen_y, 15, 15, "red");

				local b = {
					x = game_x,
					y = game_y,
					num = tile
				};

				table.insert(blocks, b);
			end
		end
	end
end

-- situation model
------------------------------
-- situation_number
	-- situation_state
		-- situation_position
			-- action
			-- index
------------------------------
local function generateSituation(elements)
	local s = {
		num = "",
		st = "",
		y = ""
	};

	for i=1, #elements, 1 do
		s.num = s.num .. tostring(elements[i].num);
		s.st = s.st .. tostring(elements[i].st);
		s.y = s.y .. tostring(elements[i].y);
	end

   	return s;
end

local function getClosestSprites()
	local cs = {};

	for i=1, #sprites, 1 do
		if math.abs(s16(player.x) - sprites[i].x) <= player.reaction.x and math.abs(s16(player.y) - sprites[i].y) <= player.reaction.y then
			table.insert(cs, sprites[i]);
		end
	end

	return cs;
end

local function playerDeath(situation)
	local newReact = {
		action = variations[1],
		index = 1
	};

	if spriteReactions[situation.num] == nil then
		spriteReactions[situation.num] = {
			[situation.st] = {
				[situation.y] = newReact;
			}
		};
	else if spriteReactions[situation.num][situation.st] == nil then
		spriteReactions[situation.num][situation.st] = {
			[situation.y] = newReact;
		}
	else if spriteReactions[situation.num][situation.st][situation.y] == nil then
		spriteReactions[situation.num][situation.st][situation.y] = newReact;
	else
		local index = spriteReactions[situation.num][situation.st][situation.y].index;

		if index < #variations then
			index = index + 1;
			spriteReactions[situation.num][situation.st][situation.y].action = variations[index];
			spriteReactions[situation.num][situation.st][situation.y].index = index;
		else
			print("you shall not pass!");
		end
	end
	end
	end

	-- save new values in the base
	-- TODO find a way to get this path dynamically
	-- linux
	saveFile("/home/daniloluca/Documents/mario-ia/src/rsprite.lua", spriteReactions);
	-- windows
	-- saveFile("C:/Users/dsme/Documents/my_documents/mario-ia/src/rsprite.lua", spriteReactions);

	-- reload level
	savestate.load(savestate.create(1));
end

local function playerBlock()

end

-- player stuck validate
local stuckCount = 0;
local stuckDelay = 100;
local player_last_x = s16(player.x);

function frameCount()
	stuckCount = stuckCount + 1;
	
	if stuckCount >= stuckDelay then
		if s16(player.x) <= player_last_x then
			playerDeath(generateSituation(getClosestSprites()));
		else
			player_last_x = s16(player.x);
		end

		stuckCount = 0;
	end
end

local function playerAction()
	-- block action
	for i=1, #blocks, 1 do
		if (blocks[i].y - s16(player.y)) > 0 and math.abs(blocks[i].x - s16(player.x)) < player.reaction.x then -- FIXME '0' of the first condition need to be fix
			if blockReactions[blocks[i].num] ~= nil then
				joypad.set(blockReactions[blocks[i].num]);
			end
		end
	end

	-- FIXME
	if u8(player.blocked_status) == 5 then
		joypad.set(1, {Y=true, right=true, A=true});
	end
	
	-- sprite action
	local situation = generateSituation(getClosestSprites());

	if spriteReactions[situation.num] ~= nil then
		if spriteReactions[situation.num][situation.st] ~= nil then
			if spriteReactions[situation.num][situation.st][situation.y] ~= nil then
				joypad.set(spriteReactions[situation.num][situation.st][situation.y].action);
			end
		end
	end

	-- player die
	if u8(player.animation_trigger) ~= 0 then
		playerDeath(situation);
	end

	-- player stuck
	if u8(player.speed) <= 6 then
		frameCount();
	else
		stuckCount = 0;
		player_last_x = s16(player.x);
	end
end

-- start
-- loading sprite reactions from file.
local rsprite_file = loadFile("rsprite.lua"); -- ok
local rblock_file = loadFile("rblock.lua"); -- nok
spriteReactions = loadstring("return ".. rsprite_file)();
blockReactions = loadstring("return ".. rblock_file)();

-- update
while true do
	getSprites();
	getBlocks();
	playerAction();
	console();
	drawFieldOfView();

	emu.frameadvance();-- important
end
