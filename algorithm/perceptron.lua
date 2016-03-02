--algoritmo de machine learnig
--Utilização de redes neurais e programação genetica
--objetivos:
--1 - pegar stats necessarios para gerar um "huk" para implementação do algoritmo.

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
local controls = {};

--functions
local function action()
	joypad.set(1, controls);
end

local function console()
	gui.text(10, 190, "X: " .. s16(player.x));
	gui.text(10, 200, "Y: " .. s16(player.y));
	gui.text(10, 210, "Speed: " .. s8(player.speed));

	--gui.text(50, 200, "lastDie: " .. lastDie);
	gui.text(50, 210, "Moving: " .. tostring(u8(player.animationTrigger) == 0));

	--gui.text(110, 200, "Jump: " .. jumpCount-1);
	--gui.text(110, 210, "NJump: " .. table.getn(diePlaces));
end

--start
local function start()
	controls = {
		A = false,
		B = false,
		X = false,
		Y = false,
		right = false,
		left = false,
		up = false,
		down = false,
	}	
end
savestate.registerload(start);

--update
while true do
	action();
	console();

	emu.frameadvance();--important
end