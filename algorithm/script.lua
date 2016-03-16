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
local lastPos = 0;
local currentAction = {};
local varCount = 1;
local pause = true;
local currentPos;

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

local function execute()
	local count = s16(player.x);
	while count < s16(player.x)+50 do
		if diePlaces[count] ~= nil then
			currentAction = diePlaces[count];
			break;
		end
		count = count + 1;
	end

	joypad.set(currentAction);
end

local function console()
	gui.text(10, 190, "X: " .. s16(player.x));
	gui.text(10, 200, "Y: " .. s16(player.y));
	gui.text(50, 200, "lastPos: " .. lastPos);
end

local function backTrack(action, index)

	table.insert(diePlaces, lastPos, action);

	print(action);

	--update
	while pause do
		console();
		gui.text(50, 190, "Rec: " .. tostring(index));
		gui.text(10, 210, "Move: " .. tostring(action));

		--joypad.set(action);
		execute();

		currentPos = s16(player.x);
		
		emu.frameadvance();
	end
	pause = true;

	if s16(player.x) > lastPos then
		for i=1, 16, 1 do
			backTrack(variations[i], index+1);
		end
	end

	table.remove(diePlaces, lastPos);
end

local function load()
	lastPos = currentPos;
	pause = false;
end
savestate.registerload(load);

--start
for i=1, 16, 1 do
	backTrack(variations[i], 1);
end

--end
print(":(");

--update
--[[while true do
	action();
	console();

	emu.frameadvance();--important
end]]