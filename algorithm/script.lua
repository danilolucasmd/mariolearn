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

local diePlaces = {};
local lastDie = 0;
local jumpCount = 1;

--functions
local function action()
	joypad.set(1, {Y=1});
	joypad.set(1, {right=1});

	if u8(player.onAir) == 0 and diePlaces[jumpCount] ~= nil and s16(player.x) > diePlaces[jumpCount]-50 and s16(player.x) < diePlaces[jumpCount] then
		joypad.set(1, {B=1});
		jumpCount = jumpCount + 1;
	end

	if s8(player.speed) < 10 and s16(player.x) > 50 then
		lastDie = s16(player.x);
	end
end

local function console()
	gui.text(10, 190, "X: " .. s16(player.x));
	gui.text(10, 200, "Y: " .. s16(player.y));
	gui.text(10, 210, "Speed: " .. s8(player.speed));

	gui.text(50, 200, "lastDie: " .. lastDie);
	gui.text(50, 210, "Moving: " .. tostring(u8(player.animationTrigger) == 0));

	gui.text(110, 200, "Jump: " .. jumpCount-1);
	gui.text(110, 210, "NJump: " .. table.getn(diePlaces));
end

--start
local function start()
	if lastDie ~= 0 then
		table.insert(diePlaces, lastDie);
	end

	jumpCount = 1;
end
savestate.registerload(start);

--update
while true do
	action();
	console();

	emu.frameadvance();--important
end