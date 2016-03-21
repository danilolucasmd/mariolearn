local u8 = memory.readbyte;
local s8 =  memory.readbytesigned
local s16 = memory.readwordsigned;

local player = {
	x = 0x0094,
	y = 0x0096,
	speed = 0x007b,
	animationTrigger = 0x0071,
	onAir = 0x0072,
	reaction = 55,
};

local enemy = {
	number = 0x009e,
	status = 0x14c8,
	x_high = 0x14e0,
	x_low = 0x00e4,
	y_high = 0x14d4,
	y_low = 0x00d8,
}

local enemyReactions = {
	[5] = {Y=false, right=false, A=true},
	[0] = {Y=false, right=false, B=true},
	[189] = {Y=false, right=false, A=true},
	[171] = {Y=false, right=true, A=true},
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

--[[local function getClosestEnemy()
	local closest;
	for i=1, table.getn(enemies), 1 do
		if i==1 then 
			closest = enemies[i];
		end
		if math.abs(enemies[i].x - s16(player.x)) < math.abs(closest.x - s16(player.x)) then
			closest = enemies[i];
		end
	end
	closestEnemy = closest;	
end]]

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

		if e.st ~= 0 then
			table.insert(enemies, e);
		end
	end
end

local function playerAction()
	joypad.set(1, {Y=true});
	joypad.set(1, {right=true});

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