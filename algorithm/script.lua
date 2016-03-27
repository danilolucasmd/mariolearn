local u8 = memory.readbyte;
local s8 =  memory.readbytesigned
local s16 = memory.readwordsigned;

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

local enemyReactions = {
	[5] = {Y=false, right=false, A=true},
	[0] = {Y=false, right=false, B=true},
	[189] = {Y=false, right=false, A=true},
	[171] = {Y=false, right=true, A=true},
	[145] = {Y=false, right=true, A=true},
	[159] = {Y=false, down=true, A=false},
	[142] = {Y=false, right=true, A=true},
}

local enemies = {};
local closestEnemy = {};

--functions
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
	gui.box(screen_x, screen_y, screen_x+1, screen_y+1, color);
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

--update
while true do
	getEnemies();
	playerAction();
	console();

	emu.frameadvance();--important
end