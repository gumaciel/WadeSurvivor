
local anim 			= require "anim8"
local lg 			= love.graphics
local lk 			= love.keyboard
local spriteboy 	= "data/sprites/wade/"

local ClassPlayer = {}

function ClassPlayer.new(_x, _y)
	return {
		player = {
			direction = {
				x = false, -- using on mov_player(dt)
				y = false -- ^
			},
			x 		= _x,  
			y 		= _y,
			w 		= nil, -- inicialized on add player
			h 		= nil, -- ^
			running = false, -- still not using
			speed  	= 150,
			live 	= true,
			distance_catch = 200,
			img		= lg.newImage(spriteboy .. "running/n_shooting_down.png"),
			key 	= {
				status = false, 
				sound = la.newSource("data/sounds/key.wav"),
			},
			hp 		= {
				points = 100,
				[1] = {
					x = _x,
					y = _y,
					img = lg.newImage("data/GUI/hp1.png"),
				},
		
				[2] = {
					x = _x,
					y = _y,
					img = lg.newImage("data/GUI/hp2.png")
				}
			},

			weapon = {
				pistol = {
					isShooting 	= false, --shot
					delayShot 	= 0.3, --shot
					timeToShot 	= 0.3, -- = delayShot
					speed 	 	= 1800,
					animShot 	= false,
					img 		= lg.newImage("data/textures/bala.png"),
					sound 		= la.newSource("data/sounds/shot.mp3"),
					bullets = {
						reload_effect = la.newSource("data/sounds/reload_effect.mp3"),
						reload = function(self, value)
							la.rewind(self.reload_effect)
							self.reload_effect:play()
							for i=self.using, 11 do
								self.using = self.using + 1
							end
						end,
						shot = function(self)
							if self.using > 0 then
								self.using = self.using -1
							end
						end,
						using = 12,
					},
					running = {
						animation = {
							not_shooting 	= {down = nil, left = nil, right = nil, up = nil},
							shooting 		= {down = nil, left = nil, right = nil, up = nil}
						},
						sprite = {
							not_shooting = {
								down 		= lg.newImage(spriteboy .. "running/n_shooting_down.png"),
								left_right	= lg.newImage(spriteboy .. "running/n_shooting_left_right.png"),
								up 			= lg.newImage(spriteboy .. "running/shooting_up.png")
							},
							shooting = {
								down 		= lg.newImage(spriteboy .. "running/y_shooting_down.png"),
								left_right  = lg.newImage(spriteboy .. "running/y_shooting_left_right.png"),
								up 			= lg.newImage(spriteboy .. "running/shooting_up.png")
							}
						}
					},
					immobile = {
						animation = {down = nil, left = nil, right = nil},
						sprite = {
							down 		= lg.newImage(spriteboy .. "immobile/down.png"),
							left_right	= lg.newImage(spriteboy .. "immobile/left_right.png"),
							up 			= lg.newImage(spriteboy .. "running/shooting_up.png") -- so vou pegar a primeira img desse sprite
						}
					},
					shots = { --shot
						right 	= {}, 
						left 	= {}, 
						down 	= {}, 
						up 		= {}
					}
				}
			},
		},
--
		switchMap_count = 0.3,
		setPosXY = function(self, new_x, new_y) -- move the player to 0, 0
			moveCollision(self.player, new_x - self.player.x, new_y - self.player.y) 					-- move him to the position that i declareer
		end,
		delete = function(self)
			local player = self.player
			player.live = false
			removeCollision(player)
		end,
		addPlayer = function(self)
			local player = self.player
			local pistol = player.weapon.pistol

			player.hp.points = 100
			player.live = true
			player.w = (player.img:getWidth()/4)/2.5
			player.h = (player.img:getHeight())/4

			local animPlayerRunning = anim.newGrid(
				pistol.running.sprite.shooting.down:getWidth()/4, 
				pistol.running.sprite.shooting.down:getHeight()/1, 
				pistol.running.sprite.shooting.up:getWidth(), 
				pistol.running.sprite.shooting.up:getHeight()
			)
			pistol.running.animation.not_shooting.down 	= anim.newAnimation(animPlayerRunning ("1-4", 1), 0.1)
			pistol.running.animation.not_shooting.left 	= anim.newAnimation(animPlayerRunning ("1-4", 1), 0.1)
			pistol.running.animation.not_shooting.right = pistol.running.animation.not_shooting.left:clone():flipH()
			pistol.running.animation.not_shooting.up 	= anim.newAnimation(animPlayerRunning ("1-4", 1), 0.1)
			
			
			pistol.running.animation.shooting.down 	= anim.newAnimation(animPlayerRunning ("1-4", 1), 0.1)
			local animPlayerRunningShotLeftRight = anim.newGrid(
				pistol.running.sprite.shooting.left_right:getWidth()/4, 
				pistol.running.sprite.shooting.left_right:getHeight()/1, 
				pistol.running.sprite.shooting.left_right:getWidth(), 
				pistol.running.sprite.shooting.left_right:getHeight()
			)
			
			pistol.running.animation.shooting.left 	= anim.newAnimation(animPlayerRunningShotLeftRight ("1-4", 1), 0.1)
			pistol.running.animation.shooting.right = pistol.running.animation.shooting.left:clone():flipH()
			pistol.running.animation.shooting.up 	= anim.newAnimation(animPlayerRunning ("1-4", 1), 0.1)

			local animPlayerImmobileDown = anim.newGrid(
				pistol.immobile.sprite.down:getWidth()/2, 
				pistol.immobile.sprite.down:getHeight()/1, 
				pistol.immobile.sprite.down:getWidth(), 
				pistol.immobile.sprite.down:getHeight()
			)
			local animPlayerImmobileLeftRight = anim.newGrid(
				pistol.immobile.sprite.left_right:getWidth()/2, 
				pistol.immobile.sprite.left_right:getHeight()/1, 
				pistol.immobile.sprite.left_right:getWidth(), 
				pistol.immobile.sprite.left_right:getHeight()
			)

			pistol.immobile.animation.down 	= anim.newAnimation(animPlayerImmobileDown ("1-2", 1), 0.1)
			pistol.immobile.animation.left 	= anim.newAnimation(animPlayerImmobileLeftRight ("1-2", 1), 0.1)
			pistol.immobile.animation.right = pistol.immobile.animation.left:clone():flipH()


			addCollision(player)
		end,
		mov_player 	= function(self, dt)
			local player = self.player
			local pistol = player.weapon.pistol
			local ObjWorldLocal = ObjWorld.map[ObjWorld.n_actualWorld]
			local directionX, directionY = player.direction.x, player.direction.y
			
			if player.hp.points <= 0 and player.live then
				self:delete()
			end
			
			local dx, dy = 0, 0

			--shot

			if player.live == true then
				if pistol.isShooting == false then
					pistol.timeToShot = pistol.timeToShot - (1 * dt)
					if pistol.timeToShot < 0 then
						pistol.isShooting = true
						pistol.bullets.reloading = false
					end
				end

				if pistol.bullets.using <= 0 then
					pistol.bullets:reload()
					pistol.isShooting = false
					pistol.bullets.reloading = true
					pistol.timeToShot = 1
				elseif pistol.bullets.using < 12 and lk.isDown("r") then
					pistol.bullets:reload()
					pistol.isShooting = false
					pistol.bullets.reloading = true
					pistol.timeToShot = 1
				end

				if pistol.bullets.using <= 0 or pistol.bullets.reloading then
					pistol.immobile.animation.right:gotoFrame(1)
					pistol.immobile.animation.left:gotoFrame(1)
					pistol.immobile.animation.down:gotoFrame(1)
					pistol.animShot = false
				end
				if pistol.bullets.using > 0 and not pistol.bullets.reloading then
					if 		lk.isDown ("right") then
						pistol.running.animation.shooting.right:update(dt)
						pistol.immobile.animation.right:update(dt)
						pistol.animShot = true
						directionX 	= true
						directionY 	= false
						if pistol.isShooting == true then
							local newShot = {
								x 		= player.x + 30,
								y 		= player.y + 7,
								w 		= pistol.img:getWidth(), 
								h 		= pistol.img:getHeight(),
								limit 	= player.x + 1200,
								img		= self.imgShot
							}

							table.insert(pistol.shots.right, newShot)

							la.rewind(pistol.sound)
							pistol.sound:play()
							pistol.bullets:shot()
							pistol.isShooting = false
							pistol.timeToShot = pistol.delayShot
						end
					elseif 	lk.isDown ("left") 	then				
						pistol.running.animation.shooting.left:update(dt)
						pistol.immobile.animation.left:update(dt)
						pistol.animShot = true
						directionX 	= false
						directionY	= true
						if pistol.isShooting == true then
							local newShot = {
								x 		= player.x,
								y 		= player.y + 7,
								w 		= pistol.img:getWidth(), 
								h 		= pistol.img:getHeight(),
								limit 	= player.x - 1200,
								img		= self.imgShot
							}
							table.insert(pistol.shots.left, newShot)	

							la.rewind(pistol.sound)
							pistol.sound:play()						
							pistol.bullets:shot()
								
							pistol.isShooting = false
							pistol.timeToShot = pistol.delayShot
						end
					elseif 	lk.isDown ("down") 	then				
						pistol.running.animation.shooting.down:update(dt)
						pistol.immobile.animation.down:update(dt)
						pistol.animShot = true
						directionX	= false
						directionY 	= false
						if pistol.isShooting == true then
							local newShot = {
								x 		= player.x + 22.5,
								y 		= player.y + 10,
								w 		= pistol.img:getWidth(), 
								h 		= pistol.img:getHeight(),
								limit 	= player.y + 1200,
								img		= self.imgShot
							}
							table.insert(pistol.shots.down, newShot)	

							la.rewind(pistol.sound)
							pistol.sound:play()						
							pistol.bullets:shot()
								
							pistol.isShooting = false
							pistol.timeToShot = pistol.delayShot
						end
					elseif 	lk.isDown ("up") 	then				
						pistol.running.animation.shooting.up:update(dt)
						pistol.animShot = true
						directionX	= true
						directionY 	= true
						if pistol.isShooting == true then
							local newShot = {
								x 		= player.x + 22.5,
								y 		= player.y,
								w 		= pistol.img:getWidth(), 
								h 		= pistol.img:getHeight(),
								limit 	= player.y - 1200,
								img		= self.imgShot
							}
							table.insert(pistol.shots.up, newShot)		

							la.rewind(pistol.sound)
							pistol.sound:play()
							pistol.bullets:shot()
							pistol.isShooting = false
							pistol.timeToShot = pistol.delayShot
						end
					else pistol.animShot = false end
				end
				function checkCollisionShot(shot, z)
					return checkCollision(shot.x - pistol.img:getWidth(), shot.y - pistol.img:getHeight(), shot.w, shot.h, z.zombie.x - z.zombie.w/1.35, z.zombie.y - z.zombie.h*3, z.zombie.sprite.down:getWidth()/4, z.zombie.sprite.down:getHeight()) and z.zombie.live == true
				end

				for i, shot in ipairs(pistol.shots.right) do 
					for j,z in ipairs(ObjWorldLocal.ObjZombie) do
						if checkCollisionShot(shot, z) then
							z.zombie.hp.points = z.zombie.hp.points - 20
							z.zombie.x = z.zombie.x + 10
							z.zombie.nostop = true
							table.remove(pistol.shots.right, i)
						end
					end
					if ObjWorldLocal.ObjBoss ~= nil then
						for k,b in ipairs(ObjWorldLocal.ObjBoss) do
							if checkCollisionShot(shot, b) then
								b.zombie.hp.points = b.zombie.hp.points - 10
								b.zombie.x = b.zombie.x + 10
								b.zombie.nostop = true
								table.remove(pistol.shots.right, i)
							end
						end
					end
					shot.x = shot.x + (pistol.speed * dt)
					if shot.x > shot.limit or ObjWorld.change_map == true then
						table.remove(pistol.shots.right, i)
					end
				end
				for i, shot in ipairs(pistol.shots.left) do 
					for j,z in ipairs(ObjWorldLocal.ObjZombie) do
						if checkCollisionShot(shot, z) then
							z.zombie.hp.points = z.zombie.hp.points - 20
							z.zombie.x = z.zombie.x - 10
							z.zombie.nostop = true
							table.remove(pistol.shots.left, i)
						end
					end
					if ObjWorldLocal.ObjBoss ~= nil then
						for k,b in ipairs(ObjWorldLocal.ObjBoss) do
							if checkCollisionShot(shot, b) then
								b.zombie.hp.points = b.zombie.hp.points - 10
								b.zombie.x = b.zombie.x - 10
								b.zombie.nostop = true
								table.remove(pistol.shots.left, i)
							end
						end
					end
					shot.x = shot.x - (pistol.speed * dt)				
					if shot.x < shot.limit or ObjWorld.change_map == true then
						table.remove(pistol.shots.left, i)
					end
				end
				for i, shot in ipairs(pistol.shots.down) do 
					for j,z in ipairs(ObjWorldLocal.ObjZombie) do
						if checkCollisionShot(shot, z) then
							z.zombie.hp.points = z.zombie.hp.points - 20
							z.zombie.y = z.zombie.y + 10
							z.zombie.nostop = true
							table.remove(pistol.shots.down, i)
						end
					end
					if ObjWorldLocal.ObjBoss ~= nil then
						for k,b in ipairs(ObjWorldLocal.ObjBoss) do
							if checkCollisionShot(shot, b) then
								b.zombie.hp.points = b.zombie.hp.points - 10
								b.zombie.y = b.zombie.y + 10
								b.zombie.nostop = true
								table.remove(pistol.shots.down, i)
							end
						end
					end
					shot.y = shot.y + (pistol.speed * dt)
					if shot.y > shot.limit or ObjWorld.change_map == true then
						table.remove(pistol.shots.down, i)
					end
				end
				for i, shot in ipairs(pistol.shots.up) do 
					for j,z in ipairs(ObjWorldLocal.ObjZombie) do
						if checkCollisionShot(shot, z) then
							z.zombie.hp.points = z.zombie.hp.points - 20
							z.zombie.y = z.zombie.y - 10
							z.zombie.nostop = true
							table.remove(pistol.shots.up, i)
						end
					end
					if ObjWorldLocal.ObjBoss ~= nil then
						for k,b in ipairs(ObjWorldLocal.ObjBoss) do
							if checkCollisionShot(shot, b) then
								b.zombie.hp.points = b.zombie.hp.points - 10
								b.zombie.y = b.zombie.y - 10
								b.zombie.nostop = true
								table.remove(pistol.shots.up, i)
							end
						end
					end
					shot.y = shot.y - (pistol.speed * dt)
					if shot.y < shot.limit or ObjWorld.change_map == true or shot.y <= 90 then
						table.remove(pistol.shots.up, i)
					end
				end

				if ObjWorld.change_map == true then
					self.switchMap_count = self.switchMap_count - 1 * dt
					if self.switchMap_count < 0 then
						ObjWorld.change_map = false
						self.switchMap_count = 0.3
					end
				end
				--shot



				if lk.isDown ("s") and player.y <= 665 then
					dy 			= dy + player.speed * dt
					directionX	= false
					directionY 	= false
					player.running = true	
					pistol.running.animation.not_shooting.down:update(dt)
				end
				if lk.isDown ("a") and player.x >= 40 then
					dx 			= dx - player.speed * dt
					directionX 	= false
					directionY	= true
					player.running = true
					pistol.running.animation.not_shooting.left:update(dt)
				end
				if lk.isDown ("d") and player.x <= 1230 then
					dx 			= dx + player.speed * dt
					directionX 	= true
					directionY 	= false
					player.running = true
					pistol.running.animation.not_shooting.right:update(dt)
				end
				if lk.isDown ("w") and player.y >= 110 then
					dy 			= dy - player.speed * dt
					directionX	= true
					directionY 	= true
					player.running = true
					pistol.running.animation.not_shooting.up:update(dt)
				end

				function love.keyreleased(key, unicode)
					if key == "w" or key == "s" or key == "a" or key == "d" then
						player.running = false
						pistol.running.animation.not_shooting.up:pauseAtStart()
						pistol.running.animation.not_shooting.up:resume()
					end
					if key == "left" or key == "right" or key == "down" then
						pistol.immobile.animation.right:pauseAtStart()
						pistol.immobile.animation.right:resume()

						pistol.immobile.animation.left:pauseAtStart()
						pistol.immobile.animation.left:resume()
						
						pistol.immobile.animation.down:pauseAtStart()
						pistol.immobile.animation.down:resume()
					end
				end

				player.direction.x, player.direction.y = directionX, directionY -- pra alterar o valor da tabela player
				
				moveCollision(self.player, dx, dy)
			end
		end,

		drawStuff = function(self)
			local pistol = self.player.weapon.pistol

			love.graphics.setColor(55, 50, 100)

			lg.rectangle	("fill", 
				(self.player.x - self.player.w/1.35) - self.player.distance_catch / 2, 
				(self.player.y - self.player.h*3) - self.player.distance_catch / 2, 
				(self.player.img:getWidth()/4) + self.player.distance_catch, 
				(self.player.img:getHeight()) + self.player.distance_catch
			)

			love.graphics.setColor(255, 255, 255)

			lg.rectangle	("fill", self.player.x, self.player.y, self.player.w, self.player.h)

			for i, shot in ipairs(pistol.shots.right) do --shot
				lg.rectangle	("fill", shot.x - pistol.img:getWidth(), shot.y - pistol.img:getHeight(), pistol.img:getWidth(), pistol.img:getHeight())
			end
			for i, shot in ipairs(pistol.shots.left) do --shot
				lg.rectangle	("fill", shot.x - pistol.img:getWidth(), shot.y - pistol.img:getHeight(), pistol.img:getWidth(), pistol.img:getHeight())
			end
			for i, shot in ipairs(pistol.shots.down) do --shot
				lg.rectangle	("fill", shot.x - pistol.img:getWidth(), shot.y - pistol.img:getHeight(), pistol.img:getWidth(), pistol.img:getHeight())
			end
			for i, shot in ipairs(pistol.shots.up) do --shot
				lg.rectangle	("fill", shot.x - pistol.img:getWidth(), shot.y - pistol.img:getHeight(), pistol.img:getWidth(), pistol.img:getHeight())
			end
			lg.print("posX player = " .. self.player.x, 300, 380)
			lg.print("posY player = " .. self.player.y, 300, 400)
			lg.print("timeToShot = " .. self.player.weapon.pistol.timeToShot, 300, 420)
			lg.print("X = " .. math.floor((self.player.x/40)) + 1, 300, 440)
			lg.print("Y = " .. math.floor((self.player.y/40)) - 1, 300, 460)
			lg.print("on use bullets: " .. self.player.weapon.pistol.bullets.using, 300, 480)
			if self.player.key.status then
				lg.print("key: true", 300, 500)
			else
				lg.print("key: false", 300, 500)
			end
			lg.print("life: " .. self.player.hp.points, 300, 520)
		end,
		draw = function(self)
			local player = self.player
			local px, py, pw, ph 		= player.x, player.y, player.w, player.h
			local directionX, directionY = player.direction.x, player.direction.y
			local pistol = player.weapon.pistol

			local IMGx, IMGy 			= px - pw/1.35, py - ph*3


			for i, shot in ipairs(pistol.shots.right) do --shot
				lg.draw(pistol.img, shot.x, shot.y, 0, 1, 1, pistol.img:getWidth(), pistol.img:getHeight())
			end
			for i, shot in ipairs(pistol.shots.left) do --shot
				lg.draw(pistol.img, shot.x, shot.y, 0, 1, 1, pistol.img:getWidth(), pistol.img:getHeight())
			end
			for i, shot in ipairs(pistol.shots.down) do --shot
				lg.draw(pistol.img, shot.x, shot.y, 11, -1, 1, pistol.img:getWidth(), pistol.img:getHeight())
			end
			for i, shot in ipairs(pistol.shots.up) do --shot
				lg.draw(pistol.img, shot.x, shot.y, 11, -1, 1, pistol.img:getWidth(), pistol.img:getHeight())
			end
			if player.live == true then
													 player.hp[1].x, player.hp[1].y = px - 7, py - 70
				love.graphics.draw(player.hp[1].img, player.hp[1].x, player.hp[1].y, 0, 1, 1)

													 player.hp[2].x, player.hp[2].y = px - 6, py - 69
				love.graphics.draw(player.hp[2].img, player.hp[2].x, player.hp[2].y, 0, player.hp.points/100, 1)
				
				if not pistol.animShot then
					if player.running then
						if 		not directionY and 	not directionX then
							pistol.running.animation.not_shooting.down:draw		(pistol.running.sprite.not_shooting.down, 		IMGx, IMGy, 0, 1, 1)
						elseif 	not directionX and 		directionY then
							pistol.running.animation.not_shooting.left:draw		(pistol.running.sprite.not_shooting.left_right, IMGx, IMGy, 0, 1, 1)
						elseif 		directionX and 	not directionY then
							pistol.running.animation.not_shooting.right:draw	(pistol.running.sprite.not_shooting.left_right, IMGx, IMGy, 0, 1, 1)
						elseif 		directionY and 		directionX then
							pistol.running.animation.not_shooting.up:draw		(pistol.running.sprite.not_shooting.up, 		IMGx, IMGy, 0, 1, 1)
						end
					elseif not player.running then
						if 		not directionY and 	not directionX then
							pistol.immobile.animation.down:draw				(pistol.immobile.sprite.down, 			IMGx, IMGy, 0, 1, 1)
						elseif 	not directionX and 		directionY then
							pistol.immobile.animation.left:draw				(pistol.immobile.sprite.left_right, 	IMGx - 10, IMGy, 0, 1, 1)
						elseif 		directionX and 	not directionY then
							pistol.immobile.animation.right:draw			(pistol.immobile.sprite.left_right, 	IMGx, IMGy, 0, 1, 1)
						elseif 		directionY and 		directionX then
							pistol.running.animation.not_shooting.up:draw 	(pistol.running.sprite.not_shooting.up,	IMGx, IMGy, 0, 1, 1)
						end
					end					
				elseif pistol.animShot then
					if player.running then 
						if lk.isDown("right") then
							pistol.running.animation.shooting.right:draw	(pistol.running.sprite.shooting.left_right, IMGx, IMGy, 0, 1, 1)
						elseif lk.isDown("left") then
							pistol.running.animation.shooting.left:draw		(pistol.running.sprite.shooting.left_right, IMGx - 10, IMGy, 0, 1, 1)
						elseif lk.isDown("down") then
							pistol.running.animation.shooting.down:draw		(pistol.running.sprite.shooting.down, IMGx, IMGy, 0, 1, 1)
						elseif lk.isDown("up") then
							pistol.running.animation.shooting.up:draw		(pistol.running.sprite.shooting.up, IMGx, IMGy, 0, 1, 1)
						end
					elseif not player.running then 
						if lk.isDown("right") then
							pistol.immobile.animation.right:draw			(pistol.immobile.sprite.left_right, IMGx, IMGy, 0, 1, 1)
						elseif lk.isDown("left") then
							pistol.immobile.animation.left:draw				(pistol.immobile.sprite.left_right, IMGx - 10, IMGy, 0, 1, 1)
						elseif lk.isDown("down") then
							pistol.immobile.animation.down:draw				(pistol.immobile.sprite.down, IMGx, IMGy, 0, 1, 1)
						elseif lk.isDown("up") then
							pistol.running.animation.not_shooting.up:draw 	(pistol.running.sprite.not_shooting.up,	IMGx, IMGy, 0, 1, 1)
						end
					end
				end
			end
		end
	}
end

return ClassPlayer

-- falta ajeitar o local da bala e fazer uma img pra ela, e provavelmente ajeitar o tempo e o limite da distancia