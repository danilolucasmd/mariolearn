local u8 = memory.readbyte;
local s8 =  memory.readbytesigned
local s16 = memory.readwordsigned;

local player = {
	x = 0x0094,
	y = 0x0096,
	speed = 0x007b,
	animationTrigger = 0x0071,
	onAir = 0x0072,
};

local actions = [
	["A"],
	["B"],
	["X"],
	["Y"],
	["right"],
	["left"],
	["up"],
	["down"]
];
local diePlaces = {};
local lastPos;
local pause = false;

--functions
local function backtrack(action)
	joypad.set(1, action);

	while pause do end
	pause = true;
	
	for i,v in actions do
		action[v] = true;
		backtrack(action);
		action[v] = false;
	end
end
--backtrack({});

local function action()
	joypad.set(1, {Y=1});
	joypad.set(1, {right=1});

	local count = s16(player.x);
	while count < s16(player.x)+50 do
		if u8(player.onAir) == 0 and diePlaces[count] == true then
			joypad.set(1, {B=1});
			break;
		end
		count = count + 1;
	end

	lastPos = (math.floor(s16(player.x)/10)*10);
end

local function console()
	gui.text(10, 190, "X: " .. s16(player.x));
	gui.text(10, 200, "Y: " .. s16(player.y));
	gui.text(10, 210, "Speed: " .. s8(player.speed));

	local count = 40;
	for i,v in pairs(diePlaces) do
	    gui.text(200, count, "Die: " .. tostring(i));
	    count = count + 10;
	end
end

--start
local function start()
	joypad.set(1, {B=0});
	diePlaces[lastPos] = true;
end
savestate.registerload(start);

--update
while true do
	action();
	console();

	emu.frameadvance();--important
end