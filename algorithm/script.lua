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

local actions = {"Y", "B", "right", "left"};
local variations = {};
local diePlaces = {};
local lastPos;
local varCount = 1;

--functions
--TODO: change it to a recursive function
for i=1, 16, 1 do
    variations[i] = {
    	Y = (math.floor(i/8%2) == 1), 
    	B = (math.floor(i/4%2) == 1),
    	right = (math.floor(i/2%2) == 1),
    	left = (math.floor(i%2) == 1)
    }
end

local function action()
	joypad.set(variations[varCount])
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

local function load()
	varCount = varCount + 1;
	print(variations[varCount]);
end
savestate.registerload(load);

--start

--update
while true do
	action();
	console();

	emu.frameadvance();--important
end