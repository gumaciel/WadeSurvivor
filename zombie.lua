local Grid 			= require ("jumper.grid")
local Pathfinder 	= require ("jumper.pathfinder")
local anim 			= require "anim8"
local spritezombie  = "data/sprites/zombie/"

ClassZombie = {}

function ClassZombie.new(_x, _y)
	return {
		zombie = {
			direction = {
				x = nil,
				y = nil
			},
			x = _x,
			y = _y,
			live = true,
			speed = 200,
			walkable = 0,
			walking = true,
			randomMove = math.random(1, 4),
			timeWalking = 0.5,
			nostop = false,
			sound = {
				[1] = la.newSource("data/sounds/zombie-18.mp3"),
				[2] = la.newSource("data/sounds/zombie-19.mp3")
			},
			hp = {
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

			animation = {
				up = nil, down = nil, left = nil, right = nil
			},
			sprite = {
				down = lg.newImage(spritezombie .. "down.png"),
				left_right = lg.newImage(spritezombie .. "left_right.png"),
				up = lg.newImage(spritezombie .. "up.png")
			}
		},
		delete = function(self)
			local zombie = self.zombie
			zombie.live = false
			removeCollision(zombie)
		end,
		addZombie = function (self)
			local zombie = self.zombie

			zombie.map = ObjWorld.map[ObjWorld.n_actualWorld].map
			zombie.grid = Grid(zombie.map)
			zombie.myFinder = Pathfinder(zombie.grid, 'DIJKSTRA', zombie.walkable)

			zombie.w = (zombie.sprite.down:getWidth()/4)
			zombie.h = (zombie.sprite.down:getHeight())

			local animZombie = anim.newGrid(
				zombie.sprite.down:getWidth()/4,
				zombie.sprite.down:getHeight(),
				zombie.sprite.down:getWidth(),
				zombie.sprite.down:getHeight()
			)
			zombie.animation.up = anim.newAnimation(animZombie ("1-4", 1), 0.1)
			zombie.animation.down = anim.newAnimation(animZombie ("1-4", 1), 0.1)
			zombie.animation.left = anim.newAnimation(animZombie ("1-4", 1), 0.1)
			zombie.animation.right = zombie.animation.left:clone():flipH()
			zombie.w = (zombie.sprite.down:getWidth()/4)/2.5
			zombie.h = (zombie.sprite.down:getHeight())/4

			addCollision(zombie)
		end,
		mov_zombie = function(self, dt)
			local zombie = self.zombie
			local dx, dy = 0, 0
			local directionX, directionY = zombie.direction.x, zombie.direction.y
			

			zombie.startx, zombie.starty = math.floor(zombie.x/40) + 1, math.floor(zombie.y/40) - 1
			zombie.endx, zombie.endy = math.floor(ObjPlayer.player.x/40) + 1, math.floor(ObjPlayer.player.y/40) - 1

			
			if checkCollision(
					zombie.x - 4, 
					zombie.y - 4, 
					zombie.w + 8, 
					zombie.h + 8, 
					ObjPlayer.player.x - 4, 
					ObjPlayer.player.y - 4, 
					ObjPlayer.player.w + 8, 
					ObjPlayer.player.h + 8
				) then
				ObjPlayer.player.hp.points = ObjPlayer.player.hp.points - 1
				print("retirado 1 de vida do personagem, vida atual: " .. ObjPlayer.player.hp.points)
			end

			local distance_catch = ObjPlayer.player.distance_catch


			if zombie.live == true then
				if not ObjPlayer.player.live then
					zombie.nostop = false
				end					
				if checkCollision(zombie.x,
					zombie.y,
					zombie.w,
					zombie.h,
					(ObjPlayer.player.x - ObjPlayer.player.w/1.35) - distance_catch / 2, 
					(ObjPlayer.player.y - ObjPlayer.player.h*3) - distance_catch / 2, 
					(ObjPlayer.player.img:getWidth()/4) + distance_catch, 
					(ObjPlayer.player.img:getHeight()) + distance_catch) and ObjPlayer.player.live
					or zombie.nostop then

					zombie.sound[2]:setVolume(0.3)
					zombie.sound[2]:play()

					zombie.path = zombie.myFinder:getPath(zombie.startx, zombie.starty, zombie.endx, zombie.endy)
					zombie.nostop = true
					for node, count in zombie.path:nodes() do
						if zombie.path:getLength() == 0 then
							if not checkCollision(
									zombie.x, 
									zombie.y, 
									zombie.w, 
									zombie.h, 
									ObjPlayer.player.x, 
									ObjPlayer.player.y, 
									ObjPlayer.player.w, 
									ObjPlayer.player.h) then
					
								if zombie.x > ObjPlayer.player.x then
									dx = dx - zombie.speed * dt 
								elseif zombie.x < ObjPlayer.player.x then
									dx = dx + zombie.speed * dt 
								end
								if zombie.y > ObjPlayer.player.y then
									dy = dy - zombie.speed * dt 
								elseif zombie.y < ObjPlayer.player.y then
									dy = dy + zombie.speed * dt 
								end
							end
						end
						if count == 2 then
							if node:getX() < math.floor(zombie.x/40) + 1 then
								directionX 	= false
								directionY	= true
								zombie.animation.left:update(dt)
								dx = dx - zombie.speed * dt
								for i,v in ipairs(ObjWorld.map[ObjWorld.n_actualWorld].box) do
									if checkCollision(zombie.x, zombie.y, zombie.w, zombie.h, v.x + 1, v.y, 40, 40) 
										and not (node:getY() > math.floor(zombie.y/40) - 1) 
										and not (node:getY() < math.floor(zombie.y/40) - 1)then
										dy = dy - zombie.speed * dt
									end
								end
							end
							if node:getX() > math.floor(zombie.x/40) + 1 then
								directionX 	= true
								directionY 	= false
								zombie.animation.right:update(dt)
								dx = dx + zombie.speed * dt
								for i,v in ipairs(ObjWorld.map[ObjWorld.n_actualWorld].box) do
									if checkCollision(zombie.x, zombie.y, zombie.w, zombie.h, v.x - 1, v.y, 40, 40) 
										and not (node:getY() > math.floor(zombie.y/40) - 1) 
										and not (node:getY() < math.floor(zombie.y/40) - 1)then
										dy = dy - zombie.speed * dt
									end
								end
							end
							if node:getY() < math.floor(zombie.y/40) - 1 and zombie.y >= 110 then
								directionX	= true
								directionY 	= true
								zombie.animation.up:update(dt)
								dy = dy - zombie.speed * dt
								for i,v in ipairs(ObjWorld.map[ObjWorld.n_actualWorld].box) do
									if checkCollision(zombie.x, zombie.y, zombie.w, zombie.h, v.x, v.y + 1, 40, 40) 
										and not (node:getX() > math.floor(zombie.x/40) + 1) 
										and not (node:getX() < math.floor(zombie.x/40) + 1)then
										dx = dx - zombie.speed * dt
									end
								end
							end
							if node:getY() > math.floor(zombie.y/40) - 1 then
								directionX	= false
								directionY 	= false
								zombie.animation.down:update(dt)
								dy = dy + zombie.speed * dt
								for i,v in ipairs(ObjWorld.map[ObjWorld.n_actualWorld].box) do
									if checkCollision(zombie.x, zombie.y, zombie.w, zombie.h, v.x, v.y - 1, 40, 40) 
										and not (node:getX() > math.floor(zombie.x/40) + 1) 
										and not (node:getX() < math.floor(zombie.x/40) + 1)then
										dx = dx - zombie.speed * dt
									end
								end
							end
						end
					end
				elseif zombie.walking then
					zombie.sound[1]:setVolume(0.3)
					zombie.sound[1]:play()

					if zombie.randomMove == 1 and zombie.x >= 90 then
						directionX 	= false
						directionY	= true
						zombie.animation.left:update(dt)
						dx = (dx - zombie.speed * dt) / 2
					elseif zombie.randomMove == 2 and zombie.x <= 1190 then
						directionX 	= true
						directionY 	= false
						zombie.animation.right:update(dt)
						dx = (dx + zombie.speed * dt) / 2
					elseif zombie.randomMove == 3 and zombie.y >= 180 then
						directionX	= true
						directionY 	= true
						zombie.animation.up:update(dt)
						dy = (dy - zombie.speed * dt) / 2
					elseif zombie.randomMove == 4 and zombie.y <= 600 then
						directionX	= false
						directionY 	= false
						zombie.animation.down:update(dt)
						dy = (dy + zombie.speed * dt) / 2
					end

				zombie.timeWalking = zombie.timeWalking - 1 * dt
				if zombie.timeWalking < 0  then
					zombie.walking = false
				end

				elseif not zombie.walking then
					zombie.timeWalking = 0.5
					zombie.randomMove = math.random(1, 4)
					zombie.walking = true
				end

					
				zombie.direction.x, zombie.direction.y = directionX, directionY

				moveCollision(zombie, dx, dy)
			end
		end,

		drawStuff = function(self)
			local zombie = self.zombie
			local zx, zy, zw, zh 		= zombie.x, zombie.y, zombie.w, zombie.h

			love.graphics.setColor(255, 50, 100)
			lg.rectangle("fill", 
				zx - zw/1.35, 
				zy - zh*3, 
				zombie.sprite.down:getWidth()/4, 
				zombie.sprite.down:getHeight()
			)
			love.graphics.setColor(255, 255, 255)

			lg.rectangle("fill", zx, zy, zw, zh)

		end,
		draw = function(self)
			local zombie = self.zombie
			local zx, zy, zw, zh 		= zombie.x, zombie.y, zombie.w, zombie.h

			local IMGx, IMGy 			= zx - zw/1.35, zy - zh*3

												 zombie.hp[1].x, zombie.hp[1].y = zombie.x - 7, zombie.y - 70
			love.graphics.draw(zombie.hp[1].img, zombie.hp[1].x, zombie.hp[1].y, 0, 1, 1)

												 zombie.hp[2].x, zombie.hp[2].y = zombie.x - 6 , zombie.y - 69 
			love.graphics.draw(zombie.hp[2].img, zombie.hp[2].x, zombie.hp[2].y, 0, zombie.hp.points/100, 1)


			local directionX, directionY = zombie.direction.x, zombie.direction.y
			if zombie.live == true then
				if 		not directionY and 	not directionX then
					zombie.animation.down:draw (zombie.sprite.down, IMGx, IMGy, 0, 1, 1)
				elseif 	not directionX and 		directionY then
					zombie.animation.left:draw (zombie.sprite.left_right, IMGx, IMGy, 0, 1, 1)
				elseif 		directionX and 	not directionY then
					zombie.animation.right:draw (zombie.sprite.left_right, IMGx, IMGy, 0, 1, 1)
				elseif 		directionY and 		directionX then
					zombie.animation.up:draw (zombie.sprite.up, IMGx, IMGy, 0, 1, 1)				
				end		
			end
		end
	}
end

return ClassZombie