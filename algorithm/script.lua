local u8 = memory.readbyte;
local s8 =  memory.readbytesigned
local s16 = memory.readwordsigned;

--variables
local player = {
	x = 0x0094,
	y = 0x0096,
	speed = 0x007b,
	animation_trigger = 0x0071,
	on_air = 0x0072,
	on_ground = 0x13ef,
	reaction = 55,
	blocked_status = 0x0077, 
};

local enemy = {
	number = 0x009e,
	status = 0x14c8,
	x_high = 0x14e0,
	x_low = 0x00e4,
	y_high = 0x14d4,
	y_low = 0x00d8,
	x_offscreen = 0x15a0, 
    y_offscreen = 0x186c,
}

local camera = {
	x = 0x001a,
    y = 0x001c,
    screens_number = 0x005d,
    hscreen_number = 0x005e,
    vscreen_number = 0x005f,
    vertical_scroll = 0x1412,
    camera_scroll_timer = 0x1401,
}

local enemyReactions = {};
local enemies = {};
local closestEnemy = {};

--functions
--file IO functions
local function loadFile(filename)
	local file = io.open(filename, "r");
	local response = file:read();
	file:close();
	return response;
end

local function saveFile(filename, obj)
	local file = io.open(filename, "a");
	file:write(tostring(obj));
	file:flush();
	file:close();
end

local function cleanFile(filename)
	local file = io.open(filename, "w");
	file:write("");
	file:flush();
	file:close();
end

local function signed(num, bits)
    local maxval = 2^(bits - 1);
    if num < maxval then return num else return num - 2*maxval end
end

local function console()
	local count = 50;
	for i=1, table.getn(enemies), 1 do
		gui.text(110, count, "enemy: " .. tostring(enemies[i]));
		count = count + 10;
	end
	gui.text(10, 200, "X: " .. s16(player.x));
	gui.text(10, 210, "Y: " .. s16(player.y));
end

local function screenCoordinates(x, y, camera_x, camera_y)    
    local x_screen = (x - camera_x)
    local y_screen = (y - camera_y) - 1
    
    return x_screen, y_screen
end

local function drawEnemy(screen_x, screen_y, color)
	gui.line(screen_x+5, screen_y+5, screen_x+15, screen_y+5, color);
	gui.line(screen_x+10, screen_y, screen_x+10, screen_y+10, color);
end

local function drawBlock(screen_x, screen_y, color)
	gui.line(screen_x, screen_y, screen_x+15, screen_y, color);
	gui.line(screen_x, screen_y+15, screen_x+15, screen_y+15, color);

	gui.line(screen_x, screen_y, screen_x, screen_y+15, color);
	gui.line(screen_x+15, screen_y, screen_x+15, screen_y+15, color);
end

-- debug by game position
local function debugger(game_x, game_y, text)
	local screen_x, screen_y = screenCoordinates(game_x, game_y, s16(camera.x), s16(camera.y));
	drawBlock(screen_x, screen_y, "purple");
	gui.text(screen_x+3, screen_y+5, text);
end

local function getEnemies()
	enemies = {};

	for i=0, 12, 1 do
		local e = {};

		e.x = 256*u8(enemy.x_high + i) + u8(enemy.x_low + i);
		e.y = 256*u8(enemy.y_high + i) + u8(enemy.y_low + i);
		e.num = u8(enemy.number + i);
		e.st = u8(enemy.status + i);

		e.x = signed(e.x, 16);
    	e.y = signed(e.y, 16);

    	local screen_x, screen_y = screenCoordinates(e.x, e.y, s16(camera.x), s16(camera.y));

		if e.st ~= 0 then
			table.insert(enemies, e);
			drawEnemy(screen_x, screen_y, "green");
		end
	end
end

-- m16_x, m16_y from Map16 table.
local function getTile(m16_x, m16_y)
	local x = math.floor((s16(player.x)+m16_x+8)/16);
	local y = math.floor((s16(player.y)+m16_y)/16);

	local id = math.floor(x/0x10)*0x1B0 + y*0x10 + x%0x10;

	-- x, y are game cordinates.
	return x*16, y*16, u8(0x1C800 + id);
end

local function getBlocks()
	-- size = 6*16
	local size = 96;

	for m16_y=-size, size, 16 do
		for m16_x=-size, size, 16 do
			local game_x, game_y, tile = getTile(m16_x, m16_y);

			--debugger(game_x, game_y, tile);

			if tile == 1 then
				local screen_x, screen_y = screenCoordinates(game_x, game_y, s16(camera.x), s16(camera.y));
				drawBlock(screen_x, screen_y, "red");
			end
		end
	end
end

local function playerAction()
	joypad.set(1, {Y=true});
	joypad.set(1, {right=true});

	--mock
	if(u8(player.blocked_status) == 5 or u8(player.on_air) ~= 0) then
		joypad.set(1, {Y=false, right=true, B=true});
	end

	for i=1, table.getn(enemies), 1 do
		if math.abs(enemies[i].x - s16(player.x)) < player.reaction then
			if enemyReactions[enemies[i].num] ~= nil then
				joypad.set(enemyReactions[enemies[i].num]);
			end
		end
	end
end

--start
--loading enemy reactions from file.
local str_file = loadFile("er.lua");
enemyReactions = loadstring("return ".. str_file)();

--update
while true do
	getEnemies();
	getBlocks();
	playerAction();
	console();

	emu.frameadvance();--important
end