local ClassWorld = require "world"
local ClassPlayer = require "player"

require "collision"
require "fileshine"

local posXstart, posYstart = 350, 350
local startGame = {[1] = true, [2] = true}
pause = true

lg = love.graphics
lk = love.keyboard
la = love.audio

function love.load()
	music = {}
	music[1] = la.newSource("data/sounds/fantasy.mp3")
    music[1]:setLooping(true)
    music[1]:play()
	music[1]:setVolume(0.05)
	controls = lg.newImage("data/GUI/controls.png")
	mainmenu = lg.newImage("data/GUI/mainmenu.png")
	pauseimg = lg.newImage("data/GUI/pause.png")
	deadimg = lg.newImage("data/GUI/dead.png")

	ObjWorld 	= ClassWorld.new()
	ObjPlayer 	= ClassPlayer.new(posXstart, posYstart)

	ObjPlayer:addPlayer()
	
	ObjWorld:load(ObjWorld.n_actualWorld, ObjWorld.n_pastWorld)
end

function love.draw(dt)
	love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 5, 5)
	post_effect1:draw(function() --fileshine
		post_effect2:draw(function()	
			ObjWorld:draw_actualWorld()
			drawStuff()
			ObjPlayer:draw()
			ObjWorld:draw_effects()
			if pause then 
				lg.draw(pauseimg, love.graphics.getWidth()/3.2, love.graphics.getHeight()/2.5)
			end
			if startGame[1] then
				lg.draw(mainmenu, 0, 0)
				if lk.isDown("return") then
					startGame[1] = false
				end
			elseif startGame[2] then
				lg.draw(controls, 0, 0)
				if lk.isDown("w", "d", "a", "s", "p", "up", "down", "left", "right", "up", "q", "e", 'r', 't', 'y', 'u', 'i', 'o', 'p', 'f', 'g', 'h', 'j', 'k', 'l', 'ç', 'z', 'x', 'c', 'v', 'b', 'n', 'm', ',', '.', ';', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0') then
					startGame[2] = false					
					pause = false
				end
			end
			if not ObjPlayer.player.live then
				lg.draw(deadimg, love.graphics.getWidth()/3.2, love.graphics.getHeight()/2.5)				
			end
		end) 
	end)	
end

function love.keypressed(key)
	if key == "p" and not startGame[1] and not startGame[2] then
		if not pause then
			pause = true
			ObjPlayer.player.weapon.pistol.animShot = false
		elseif pause then
			pause = false
		end
	end

	if not ObjPlayer.player.live then
		if key == "return" then
			ObjPlayer.player.x = posXstart
			ObjPlayer.player.y = posYstart
			ObjPlayer.player.key.status = false
			ObjPlayer.player.weapon.pistol.bullets.using = 12
			ObjPlayer:addPlayer()
			ObjWorld.map[ObjWorld.n_actualWorld]:delete()
			ObjWorld.map[3].key = {x = 280, y = 320, img = lg.newImage("data/textures/key.png")}
			ObjWorld.map[6].ObjBoss = {}
			ObjWorld.n_actualWorld = 1
			ObjWorld.map[ObjWorld.n_actualWorld]:load()
		end
	end
end

function love.update(dt)
	if not pause then
		ObjPlayer:mov_player(dt)
		ObjWorld:update(dt)
		update_shader(dt)

		if love.keyboard.isDown("c") then
			ObjPlayer.player.speed = 220
		else ObjPlayer.player.speed = 150 end
	end
end

--

function drawStuff(...)
--[[	if love.keyboard.isDown("tab") then -- desenhar besteira
		if ObjPlayer.player.live then
			ObjPlayer:drawStuff()
		end
		ObjWorld:drawStuff()

		love.graphics.print("Current FPS: " .. tostring(love.timer.getFPS()), 100, 26)
		love.graphics.print("p_eOpacity: " .. p_eOpacity, 100, 16)
	end]]
end


function love.run(dt)
	if love.math then
		love.math.setRandomSeed(os.time())
	end

	if love.load then love.load(arg) end

	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end

	local dt = 0

	-- Main loop time.
	while true do
	-- Process events.
	if love.event then
		love.event.pump()
		for name, a,b,c,d,e,f in love.event.poll() do
			if name == "quit" then
				if not love.quit or not love.quit() then
					return a
				end
			end
		love.handlers[name](a,b,c,d,e,f)
		end
	end

	-- Update dt, as we'll be passing it to update
	if love.timer then
		love.timer.step()
		dt = love.timer.getDelta()
	end

	-- Call update and draw
	if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled

	if love.graphics and love.graphics.isActive() then
		love.graphics.clear(love.graphics.getBackgroundColor())
		love.graphics.origin()
		if love.draw then love.draw() end
		love.graphics.present()
	end

	if love.timer then love.timer.sleep(0.015) end
	end
end