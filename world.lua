local ClassZombie = require "zombie"
local ClassBoss = require "boss"
local widthWindow = love.graphics.getWidth()
local heightWindow = love.graphics.getHeight()

local ClassWorld = {}
local door = false
local bossimg = false
function ClassWorld.new( ... )
	return {
		-- começo do codigo do map
		
		n_actualWorld = 1,
		n_pastWorld = 1,
		change_map = true,
		update = function(self, dt) --função para ficar testando se o player está colidindo com uma das exits
			local function exitTop() -- função auxiliar para a "colisão" com a exit do map de cima
				print("exitTop Working")
				return ObjPlayer.player.x >= 610 and -- entre 600 e 680
						ObjPlayer.player.x <= 696 and 
						ObjPlayer.player.y >= 105 and -- entre 60 e 145
						ObjPlayer.player.y <= 160 and 
						self.map[self.n_actualWorld].exit.top ~= nil -- e se existir uma porta no lado de cima do map atual, então vai retornar true
			end

			local function exitDown()
				print("exitDown Working")
				return ObjPlayer.player.x >= 610 and -- "porta" bot
						ObjPlayer.player.x <= 696 and 
						ObjPlayer.player.y >= 632 and 
						ObjPlayer.player.y <= 690 and
						self.map[self.n_actualWorld].exit.bot ~= nil
			end

			local function exitLeft(...)
				print("exitLeft Working")
				return ObjPlayer.player.x >= 20 and -- "porta" left
						ObjPlayer.player.x <= 65 and 
						ObjPlayer.player.y >= 320 and 
						ObjPlayer.player.y <= 420 and
						self.map[self.n_actualWorld].exit.left ~= nil
			end

			local function exitRight(...)
				print("exitRight Working")
				return ObjPlayer.player.x >= 1220 and -- "porta" right
						ObjPlayer.player.x <= 1260 and 
						ObjPlayer.player.y >= 320 and 
						ObjPlayer.player.y <= 420 and
						self.map[self.n_actualWorld].exit.right ~= nil
			end

			local function load(n_actualWorld, n_pastWorld)
				local function att_PosXY(...) -- função pra atualizar a posiçãoX quando change_mapr de map de acordo com a "porta" que ele pegou no map passado	
					if self.map[n_pastWorld].exit.bot == true then -- se a exit do world passado foi a de bot, then
						ObjPlayer:setPosXY(640, 180) -- coordenadas para o player se mover para a posição mais alta do map
						self.map[n_pastWorld].exit.bot = false -- retornar pra false pra não dar bug
					elseif self.map[n_pastWorld].exit.top == true then--mesma coisa aqui, mas ele vai pra cima do map
						ObjPlayer:setPosXY(640, 580) -- coordenadas para o player se mover para a posição mais baixa do map
						self.map[n_pastWorld].exit.top = false
					elseif self.map[n_pastWorld].exit.left == true then
						ObjPlayer:setPosXY(1050, 380) -- coordenadas para o player se mover para a right do map
						self.map[n_pastWorld].exit.left = false
					elseif self.map[n_pastWorld].exit.right == true then
						ObjPlayer:setPosXY(120, 380) -- coordenadas para o player se mover para a left do map
						self.map[n_pastWorld].exit.right = false
					end
				end
				att_PosXY() --  atualize o map de acordo com a porta do map anterior
				self.map[n_actualWorld]:load() -- load colisões e outras coisas do map atual
				self.change_map = true
			end

			local function nextMap(num) -- função pra load o proximo map
				self.map[self.n_actualWorld]:delete()
				self.n_pastWorld = self.n_actualWorld
				self.n_actualWorld = num
				load(self.n_actualWorld, self.n_pastWorld)
			end
			local random_map = nil
			if self.n_actualWorld == 1 then
				random_map = math.random(1, 4) -- variavel auxiliar pra pegar o valor do map
			else
				random_map = math.random(2, 5)
			end

			if self.n_actualWorld == 5 then
				if checkCollision(ObjPlayer.player.x, ObjPlayer.player.y, ObjPlayer.player.w, ObjPlayer.player.h, self.map[self.n_actualWorld].gate.x, self.map[self.n_actualWorld].gate.y, self.map[self.n_actualWorld].gate.w, self.map[self.n_actualWorld].gate.h) then
					door = true
					if ObjPlayer.player.key.status then
						self.map[self.n_actualWorld].exit.top = true
						nextMap(6)
						self.map[self.n_pastWorld].exit.top = nil
					end
				else 
					door = false
				end
			elseif self.n_actualWorld == 6 then
				if checkCollision(ObjPlayer.player.x, ObjPlayer.player.y, ObjPlayer.player.w, ObjPlayer.player.h, self.map[self.n_actualWorld].gate.x, self.map[self.n_actualWorld].gate.y, self.map[self.n_actualWorld].gate.w, self.map[self.n_actualWorld].gate.h) then
					if self.map[self.n_actualWorld].ObjBoss ~= nil then
						bossimg = true
					else
						self.map[self.n_actualWorld].ObjBoss = {}
						self.map[self.n_actualWorld].exit.top = true
						nextMap(2)
						self.map[self.n_pastWorld].exit.top = nil
					end
				else 
					bossimg = false
				end
			else
				door = false
				bossimg = false
			end

			if random_map ~= self.n_actualWorld then -- se o numero do map aleatorio for diferente do numero atual (pode ser do boss também) then;
				if exitTop() then -- se o player estiver colidindo com a exit do top:
					if self.map[random_map].exit.bot ~= nil then -- se a exit do proximo map não for inexistente então:
						self.map[self.n_actualWorld].exit.top = true -- a exit do top dele vai ficar verdadeira (e se for verdadeira, o código dentro da função att_posXY vai ser útil)
						nextMap(random_map) -- ele vai executar o carregamento do proximo map, assim como a atualização da posição X do personagem
					end
				elseif exitDown() then
					if self.map[random_map].exit.top ~= nil then
						self.map[self.n_actualWorld].exit.bot = true -- mesma coisa, se a porta for em cima, a exit vai ser em bot do map, etc
						nextMap(random_map) 
					end
				elseif exitLeft() then
					if self.map[random_map].exit.right ~= nil then
						self.map[self.n_actualWorld].exit.left = true
						nextMap(random_map) 
					end
				elseif exitRight() then
					if self.map[random_map].exit.left ~= nil then		
						self.map[self.n_actualWorld].exit.right = true
						nextMap(random_map) 
					end
				end
			end
		
			if self.map[self.n_actualWorld].light ~= nil then
				if self.map[self.n_actualWorld].light.on then -- codigo da luz
					local numberOn = math.random(0, 15)
					numberOn = numberOn - 1 * dt
					if numberOn < 0  then
						self.map[self.n_actualWorld].light.on = false
					end
				elseif not self.map[self.n_actualWorld].light.on then
					local numberOff = math.random(0, 5)
					numberOff = numberOff - 1 * dt
					if numberOff < 0 then
						self.map[self.n_actualWorld].light.on = true
					end
				end
			end

			for i, zombie in ipairs(self.map[self.n_actualWorld].ObjZombie) do
				zombie:mov_zombie(dt)
			end
			if self.map[self.n_actualWorld].ObjBoss ~= nil then
				for i, boss in ipairs(self.map[self.n_actualWorld].ObjBoss) do
					boss:mov_zombie(dt)
				end
			end
		end,

		load = function(self, n_actualWorld, n_pastWorld) --função pra load o map, tais como a coordenada do jogador, colisões, background e tileset
			local function att_PosXY(...) -- função pra atualizar a posiçãoX quando change_mapr de map de acordo com a "porta" que ele pegou no map passado	
				if self.map[n_pastWorld].exit.bot == true then -- se a exit do world passado foi a de bot, then
					ObjPlayer:setPosXY(640, 180) -- coordenadas para o player se mover para a posição mais alta do map
					self.map[n_pastWorld].exit.bot = false -- retornar pra false pra não dar bug
				elseif self.map[n_pastWorld].exit.top == true then--mesma coisa aqui, mas ele vai pra cima do map
					ObjPlayer:setPosXY(640, 580) -- coordenadas para o player se mover para a posição mais baixa do map
					self.map[n_pastWorld].exit.top = false
				elseif self.map[n_pastWorld].exit.left == true then
					ObjPlayer:setPosXY(1050, 380) -- coordenadas para o player se mover para a right do map
					self.map[n_pastWorld].exit.left = false
				elseif self.map[n_pastWorld].exit.right == true then
					ObjPlayer:setPosXY(120, 380) -- coordenadas para o player se mover para a left do map
					self.map[n_pastWorld].exit.right = false
				end
			end
			att_PosXY() --  atualize o map de acordo com a porta do map anterior
			self.map[n_actualWorld]:load() -- load colisões e outras coisas do map atual
			self.change_map = true
		end,

		draw_actualWorld = function(self)
			self.map[self.n_actualWorld]:draw()
		end,
		draw_effects = function(self)
			if self.map[self.n_actualWorld].light ~= nil then
				if self.map[self.n_actualWorld].light.on == true then -- light
					love.graphics.draw(self.map[self.n_actualWorld].light.effect, 245, 100)
					love.graphics.draw(self.map[self.n_actualWorld].light.effect, 920, 100)
				end
			end
		end,

		drawStuff = function(self)	
			love.graphics.print("world actual: " .. self.n_actualWorld, 500, 500)
			love.graphics.print("world past: " .. self.n_pastWorld, 500, 520)
			lg.setColor(100, 100, 100)
			for x=0, heightWindow, 40 do
				lg.rectangle("fill", 0, x, widthWindow , 1)
			end
			for y=0, widthWindow, 40 do
				lg.rectangle("fill", y, 0, 1, heightWindow)
			end
			lg.setColor(255, 255, 255)

			self.map[self.n_actualWorld]:drawStuff()
		end,

		-- fim do codigo do map
		map = {
			[1] = {
				background = lg.newImage("data/maps/map1.png"),
				tile = {},
				box = {},
				light = nil,
--					on = false, 
--					effect = love.graphics.newImage("luz.png") -- light
				ObjZombie = {},

				-- variaveis do map
				tile_w = 40, -- largura do tile
				tile_h = 40, -- altura do tile
				map_w = 20, -- largura do map = 40*20 (serão 20 tiles colocados no eixo x com o tamanho de 40x40)
				map_h = 20, -- ^
				map_x = 0, -- posição inicial do desenho no eixo x
				map_y = 0, -- eixo y
				map_display_w = 31, -- isso serve para desenhar o map, se mudar o valor pode ser bom para não usar muita memoria do sistema (usar com cameras)
				map_display_h = 16, -- ^
				map_offset_x = -40, -- reposicionar a camera/desenho para o eixo x 
				map_offset_y = 40, -- eixo y

				-- map 1: top
				-- map 2: bot, left, right
				-- map 3: top, right
				-- map 4: bot
				-- map 5: left
				exit = {
					top = false,
					bot = nil,
					right = nil,
					left = nil
				},
				limits = {},

				map = {
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --1
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --2
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --3
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --4
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --5
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --6
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --7
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --8
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --9
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --10
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --12
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --13
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --14
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --15
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --16
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}  --17 (map_h)
				}, --1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32    X   (map_w)
				
				draw = function(self)			
					lg.draw(self.background, 0, 0)
					for i,v in ipairs(self.box) do
						lg.draw(self.tile[self.box[i].num], self.box[i].x, self.box[i].y)
					end
					for i in ipairs(self.ObjZombie) do
						self.ObjZombie[i]:draw()
						if self.ObjZombie[i].zombie.hp.points <= 0 then
							self.ObjZombie[i]:delete()
							table.remove(self.ObjZombie, i)
						end
					end
				end,
				drawStuff = function(self)
					local _limits = self.limits
					local _zombie = self.ObjZombie

					for i in ipairs(_limits) do			
						lg.setColor(10, 140, 130)
						lg.rectangle("fill", 
							_limits[i].x, 
							_limits[i].y, 
							_limits[i].w, 
							_limits[i].h
						)
						lg.setColor(255, 255, 255)
					end
					for i, ObjZombie in ipairs(_zombie) do
						if ObjZombie.zombie.live == true then
							ObjZombie:drawStuff()
						end
					end
					lg.print("nzombie: " .. #self.ObjZombie, 600, 500)	
				
				end,
				--[[]]
				delete = function(self)
					for i in ipairs(self.limits) do
						removeCollision(self.limits[i])
						self.limits[i] = nil
					end
					for i in ipairs(self.box) do
						removeCollision(self.box[i])
						self.box[i] = nil
					end
					self:deleteZombie()
				end,
				deleteZombie = function(self)
					for i in ipairs(self.ObjZombie) do
						if self.ObjZombie[i].zombie.live == true then
							self.ObjZombie[i]:delete()
						end
						self.ObjZombie[i] = nil
					end
				end,
				loadZombie = function(self)
					for i = 1, 2 do
						table.insert(self.ObjZombie, #self.ObjZombie+1, ClassZombie.new(math.random(200, 900), math.random(200, 400)))
						self.ObjZombie[#self.ObjZombie]:addZombie() -- light
					end
				end,
				load = function(self)
					--limite do map
					local _limits = self.limits
					_limits[1] = {x = 0, 			y = 630,	 	w = widthWindow, 	h = 5} -- pra bot
					_limits[2] = {x = 80, 			y = 0, 			w = 5, 				h = heightWindow} -- left
					_limits[3] = {x = 1220,		 	y = 0, 			w = 5, 			 	h = heightWindow} -- right
					_limits[4] = {x = 0, 			y = 170 - 85, 	w = 610, 		 	h = 90} -- de cima pra left
					_limits[5] = {x = 715, 			y = 170 - 85, 	w = widthWindow, 	h = 90} -- de cima pra right
					for i in ipairs(_limits) do
						addCollision(_limits[i])
					end

					self:loadZombie()
					--limite do map ^ 

					for i=0,4 do -- adicionar os tilesets
						self.tile[i] = lg.newImage("data/textures/tile"..i..".png" )
					end
					--desenhar os tiles e load na colisao
					for y=1, self.map_display_h do -- para que a variavel local y = 1 chegue até 10 faça; (no final add +1 a y)
						for x=1, self.map_display_w do -- para que a variavel local y = 1 chegue até 15 faça; (no final add +1 a x)
							if (self.map[y+self.map_y][x+self.map_x]) == 3 then
								self.box[#self.box+1] = {num = self.map[y+self.map_y][x+self.map_x], x = (x * self.tile_w)+self.map_offset_x, y =(y*self.tile_h)+self.map_offset_y, w = self.tile_w, h = self.tile_h}
								addCollision(self.box[#self.box])
							end
						end
					end
				end
			},
			--
			[2] = {
				background = lg.newImage("data/maps/map2.png"),
				tile = {},
				box = {},
				light = {
					on = false, 
					effect = love.graphics.newImage("data/textures/light.png") -- light
				},
				ObjZombie = {},

				-- variaveis do map
				tile_w = 40, -- largura do tile
				tile_h = 40, -- altura do tile
				map_w = 20, -- largura do map = 40*20 (serão 20 tiles colocados no eixo x com o tamanho de 40x40)
				map_h = 20, -- ^
				map_x = 0, -- posição inicial do desenho no eixo x
				map_y = 0, -- eixo y
				map_display_w = 31, -- isso serve para desenhar o map, se mudar o valor pode ser bom para não usar muita memoria do sistema (usar com cameras)
				map_display_h = 16, -- ^
				map_offset_x = -40, -- reposicionar a camera/desenho para o eixo x 
				map_offset_y = 40, -- eixo y

				-- map 1: top
				-- map 2: bot, left, right
				-- map 3: top, right
				-- map 4: bot
				-- map 5: left
				exit = {
					top = false,
					bot = false,
					right = false,
					left = false
				},
				limits = {},

				map = {
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --1
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --2
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --3
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --4
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --5
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --6
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --7
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --8
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --9
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --10
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --12
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --13
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --14
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --15
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --16
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}  --17	 (map_h)
				}, --1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32      X   (map_w)
				
				draw = function(self)			
					lg.draw(self.background, 0, 0)
					for i,v in ipairs(self.box) do
						lg.draw(self.tile[self.box[i].num], self.box[i].x, self.box[i].y)
					end
					for i in ipairs(self.ObjZombie) do
						self.ObjZombie[i]:draw()
						if self.ObjZombie[i].zombie.hp.points <= 0 then
							self.ObjZombie[i]:delete()
							table.remove(self.ObjZombie, i)
						end
					end
				end,
				drawStuff = function(self)
					local _limits = self.limits
					local _zombie = self.ObjZombie

					for i in ipairs(_limits) do			
						lg.setColor(10, 140, 130)
						lg.rectangle("fill", 
							_limits[i].x, 
							_limits[i].y, 
							_limits[i].w, 
							_limits[i].h
						)
						lg.setColor(255, 255, 255)
					end


					for i, ObjZombie in ipairs(_zombie) do
						if ObjZombie.zombie.live == true then
							ObjZombie:drawStuff()
						end
					end
					lg.print("nzombie: " .. #self.ObjZombie, 600, 500)	
				
				end,
				--[[]]
				delete = function(self)
					for i in ipairs(self.limits) do
						removeCollision(self.limits[i])
						self.limits[i] = nil
					end
					for i in ipairs(self.box) do
						removeCollision(self.box[i])
						self.box[i] = nil
					end
					self:deleteZombie()
				end,
				deleteZombie = function(self)
					for i in ipairs(self.ObjZombie) do
						if self.ObjZombie[i].zombie.live == true then
							self.ObjZombie[i]:delete()
						end
						self.ObjZombie[i] = nil
					end
				end,
				loadZombie = function(self)
					for i = 1, 1 do
						table.insert(self.ObjZombie, #self.ObjZombie+1, ClassZombie.new(math.random(200, 900), math.random(200, 400)))
						self.ObjZombie[#self.ObjZombie]:addZombie() -- light
					end
				end,
				load = function(self)
					--limite do map
					local _limits = self.limits

					_limits[1] = {x = 0, 			y = 630,	 	w = 610, 			h = 90} -- pra bot
					_limits[2] = {x = 715, 			y = 630,	 	w = 610, 			h = 90} -- pra bot
					
					_limits[3] = {x = 80 - 85, 		y = 0, 			w = 90, 			h = 320} -- left
					_limits[4] = {x = 80 - 85, 		y = 440, 		w = 90, 			h = 320} -- left
					
					_limits[5] = {x = 1220,		 	y = 0, 			w = 90, 		 	h = 320} -- right
					_limits[6] = {x = 1220,		 	y = 440, 		w = 90, 		 	h = 320} -- right
					
					_limits[7] = {x = 0, 			y = 170 - 85, 	w = 610, 		 	h = 90} -- de cima pra left
					_limits[8] = {x = 715, 			y = 170 - 85, 	w = 610, 			h = 90} -- de cima pra right
					for i in ipairs(_limits) do
						addCollision(_limits[i])
					end

					self:loadZombie()
					--limite do map ^ 

					for i=0,4 do -- adicionar os tilesets
						self.tile[i] = lg.newImage("data/textures/tile"..i..".png" )
					end
					--desenhar os tiles e load na colisao
					for y=1, self.map_display_h do -- para que a variavel local y = 1 chegue até 10 faça; (no final add +1 a y)
						for x=1, self.map_display_w do -- para que a variavel local y = 1 chegue até 15 faça; (no final add +1 a x)
							if (self.map[y+self.map_y][x+self.map_x]) == 3 then
								self.box[#self.box+1] = {num = self.map[y+self.map_y][x+self.map_x], x = (x * self.tile_w)+self.map_offset_x, y =(y*self.tile_h)+self.map_offset_y, w = self.tile_w, h = self.tile_h}
								addCollision(self.box[#self.box])
							end
						end
					end
				end
			},
			[3] = {
				background = lg.newImage("data/maps/map3.png"),
				tile = {},
				box = {},
				light = {
					on = false, 
					effect = love.graphics.newImage("data/textures/light.png") -- light
				},
				ObjZombie = {},

				-- variaveis do map
				tile_w = 40, -- largura do tile
				tile_h = 40, -- altura do tile
				map_w = 20, -- largura do map = 40*20 (serão 20 tiles colocados no eixo x com o tamanho de 40x40)
				map_h = 20, -- ^
				map_x = 0, -- posição inicial do desenho no eixo x
				map_y = 0, -- eixo y
				map_display_w = 31, -- isso serve para desenhar o map, se mudar o valor pode ser bom para não usar muita memoria do sistema (usar com cameras)
				map_display_h = 16, -- ^
				map_offset_x = -40, -- reposicionar a camera/desenho para o eixo x 
				map_offset_y = 40, -- eixo y

				-- map 1: top
				-- map 2: bot, left, right
				-- map 3: top, right
				-- map 4: bot
				-- map 5: left
				exit = {
					top = nil,
					bot = false,
					right = false,
					left = nil
				},
				limits = {},
				key = {x = 280, y = 320, img = lg.newImage("data/textures/key.png")},
				map = {
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --1
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --2
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --3
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --4
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --5
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --6
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --7
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --8
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --9
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --10
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --12
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --13
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --14
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --15
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --16
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}  --17	 (map_h)
				}, --1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32      X   (map_w)
				
				draw = function(self)			
					lg.draw(self.background, 0, 0)
					for i,v in ipairs(self.box) do
						lg.draw(self.tile[self.box[i].num], self.box[i].x, self.box[i].y)
					end
					if self.key ~= nil then
						lg.draw(self.key.img, self.key.x, self.key.y)
						if checkCollision(ObjPlayer.player.x, ObjPlayer.player.y, ObjPlayer.player.w, ObjPlayer.player.h,
							self.key.x, self.key.y, self.key.img:getWidth(), self.key.img:getHeight()) then
							self.key = nil
							ObjPlayer.player.key.status = true
							ObjPlayer.player.key.sound:play()
						end
					end
					for i in ipairs(self.ObjZombie) do
						self.ObjZombie[i]:draw()
						if self.ObjZombie[i].zombie.hp.points <= 0 then
							self.ObjZombie[i]:delete()
							table.remove(self.ObjZombie, i)
						end
					end

				end,
				drawStuff = function(self)
					local _limits = self.limits
					local _zombie = self.ObjZombie

					for i in ipairs(_limits) do			
						lg.setColor(10, 140, 130)
						lg.rectangle("fill", 
							_limits[i].x, 
							_limits[i].y, 
							_limits[i].w, 
							_limits[i].h
						)
						lg.setColor(255, 255, 255)
					end


					for i, ObjZombie in ipairs(_zombie) do
						if ObjZombie.zombie.live == true then
							ObjZombie:drawStuff()
						end
					end
					lg.print("nzombie: " .. #self.ObjZombie, 600, 500)	
				
				end,
				--[[]]
				delete = function(self)
					for i in ipairs(self.limits) do
						removeCollision(self.limits[i])
						self.limits[i] = nil
					end
					for i in ipairs(self.box) do
						removeCollision(self.box[i])
						self.box[i] = nil
					end
					self:deleteZombie()
				end,
				deleteZombie = function(self)
					for i in ipairs(self.ObjZombie) do
						if self.ObjZombie[i].zombie.live == true then
							self.ObjZombie[i]:delete()
						end
						self.ObjZombie[i] = nil
					end
				end,
				loadZombie = function(self)
					for i = 1, 1 do
						table.insert(self.ObjZombie, #self.ObjZombie+1, ClassZombie.new(math.random(200, 900), math.random(200, 400)))
						self.ObjZombie[#self.ObjZombie]:addZombie() -- light
					end
				end,
				load = function(self)
					--limite do map
					local _limits = self.limits

					_limits[1] = {x = 0, 			y = 630,	 	w = 610, 			h = 90} -- pra bot
					_limits[2] = {x = 715, 			y = 630,	 	w = 610, 			h = 90} -- pra bot
					
					_limits[3] = {x = 80, 			y = 0, 			w = 5, 				h = heightWindow} -- left
					
					_limits[4] = {x = 1220,		 	y = 0, 			w = 90, 		 	h = 320} -- right
					_limits[5] = {x = 1220,		 	y = 440, 		w = 90, 		 	h = 320} -- right
					
					_limits[6] = {x = 0, 			y = 170, 		w = widthWindow,  	h = 5} -- top
					for i in ipairs(_limits) do
						addCollision(_limits[i])
					end

					self:loadZombie()
					--limite do map ^ 

					for i=0,4 do -- adicionar os tilesets
						self.tile[i] = lg.newImage("data/textures/tile"..i..".png" )
					end
					--desenhar os tiles e load na colisao
					for y=1, self.map_display_h do -- para que a variavel local y = 1 chegue até 10 faça; (no final add +1 a y)
						for x=1, self.map_display_w do -- para que a variavel local y = 1 chegue até 15 faça; (no final add +1 a x)
							if (self.map[y+self.map_y][x+self.map_x]) == 3 then
								self.box[#self.box+1] = {num = self.map[y+self.map_y][x+self.map_x], x = (x * self.tile_w)+self.map_offset_x, y =(y*self.tile_h)+self.map_offset_y, w = self.tile_w, h = self.tile_h}
								addCollision(self.box[#self.box])
							end
						end
					end
				end
			},	
			[4] = {
				background = lg.newImage("data/maps/map4.png"),
				tile = {},
				box = {},
				light = {
					on = false, 
					effect = love.graphics.newImage("data/textures/light.png") -- light
				},
				ObjZombie = {},

				-- variaveis do map
				tile_w = 40, -- largura do tile
				tile_h = 40, -- altura do tile
				map_w = 20, -- largura do map = 40*20 (serão 20 tiles colocados no eixo x com o tamanho de 40x40)
				map_h = 20, -- ^
				map_x = 0, -- posição inicial do desenho no eixo x
				map_y = 0, -- eixo y
				map_display_w = 31, -- isso serve para desenhar o map, se mudar o valor pode ser bom para não usar muita memoria do sistema (usar com cameras)
				map_display_h = 16, -- ^
				map_offset_x = -40, -- reposicionar a camera/desenho para o eixo x 
				map_offset_y = 40, -- eixo y

				-- map 1: top
				-- map 2: bot, left, right
				-- map 3: top, right
				-- map 4: bot
				-- map 5: left
				exit = {
					top = false,
					bot = false,
					right = nil,
					left = false
				},
				limits = {},

				map = {
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --1
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --2
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --3
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --4
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --5
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --6
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --7
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --8
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --9
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --10
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --12
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --13
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --14
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --15
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --16
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}  --17	 (map_h)
				}, --1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32      X   (map_w)
				
				draw = function(self)			
					lg.draw(self.background, 0, 0)
					for i,v in ipairs(self.box) do
						lg.draw(self.tile[self.box[i].num], self.box[i].x, self.box[i].y)
					end
					for i in ipairs(self.ObjZombie) do
						self.ObjZombie[i]:draw()
						if self.ObjZombie[i].zombie.hp.points <= 0 then
							self.ObjZombie[i]:delete()
							table.remove(self.ObjZombie, i)
						end
					end
				end,
				drawStuff = function(self)
					local _limits = self.limits
					local _zombie = self.ObjZombie

					for i in ipairs(_limits) do			
						lg.setColor(10, 140, 130)
						lg.rectangle("fill", 
							_limits[i].x, 
							_limits[i].y, 
							_limits[i].w, 
							_limits[i].h
						)
						lg.setColor(255, 255, 255)
					end


					for i, ObjZombie in ipairs(_zombie) do
						if ObjZombie.zombie.live == true then
							ObjZombie:drawStuff()
						end
					end
					lg.print("nzombie: " .. #self.ObjZombie, 600, 500)	
				
				end,
				--[[]]
				delete = function(self)
					for i in ipairs(self.limits) do
						removeCollision(self.limits[i])
						self.limits[i] = nil
					end
					for i in ipairs(self.box) do
						removeCollision(self.box[i])
						self.box[i] = nil
					end
					self:deleteZombie()
				end,
				deleteZombie = function(self)
					for i in ipairs(self.ObjZombie) do
						if self.ObjZombie[i].zombie.live == true then
							self.ObjZombie[i]:delete()
						end
						self.ObjZombie[i] = nil
					end
				end,
				loadZombie = function(self)
					for i = 1, 1 do
						table.insert(self.ObjZombie, #self.ObjZombie+1, ClassZombie.new(math.random(200, 900), math.random(200, 400)))
						self.ObjZombie[#self.ObjZombie]:addZombie() -- light
					end
				end,
				load = function(self)
					--limite do map
					local _limits = self.limits

					_limits[1] = {x = 0, 			y = 630,	 	w = 610, 			h = 90} -- pra bot
					_limits[2] = {x = 715, 			y = 630,	 	w = 610, 			h = 90} -- pra bot
					
					_limits[3] = {x = 80 - 85, 		y = 0, 			w = 90, 			h = 320} -- left
					_limits[4] = {x = 80 - 85, 		y = 440, 		w = 90, 			h = 320} -- left
					
					_limits[5] = {x = 1220,		 	y = 0, 			w = 5, 			 	h = heightWindow} -- right
					
					_limits[6] = {x = 0, 			y = 170 - 85, 	w = 610, 		 	h = 90} -- de cima pra left
					_limits[7] = {x = 715, 			y = 170 - 85, 	w = 610, 			h = 90} -- de cima pra right
					for i in ipairs(_limits) do
						addCollision(_limits[i])
					end

					self:loadZombie()
					--limite do map ^ 

					for i=0,4 do -- adicionar os tilesets
						self.tile[i] = lg.newImage("data/textures/tile"..i..".png" )
					end
					--desenhar os tiles e load na colisao
					for y=1, self.map_display_h do -- para que a variavel local y = 1 chegue até 10 faça; (no final add +1 a y)
						for x=1, self.map_display_w do -- para que a variavel local y = 1 chegue até 15 faça; (no final add +1 a x)
							if (self.map[y+self.map_y][x+self.map_x]) == 3 then
								self.box[#self.box+1] = {num = self.map[y+self.map_y][x+self.map_x], x = (x * self.tile_w)+self.map_offset_x, y =(y*self.tile_h)+self.map_offset_y, w = self.tile_w, h = self.tile_h}
								addCollision(self.box[#self.box])
							end
						end
					end
				end
			},	
			[5] = {
				background = lg.newImage("data/maps/map5.png"),
				door = lg.newImage("data/GUI/door.png"),
				tile = {},
				box = {},
				light = {
					on = false, 
					effect = love.graphics.newImage("data/textures/light.png") -- light
				},
				ObjZombie = {},

				-- variaveis do map
				tile_w = 40, -- largura do tile
				tile_h = 40, -- altura do tile
				map_w = 20, -- largura do map = 40*20 (serão 20 tiles colocados no eixo x com o tamanho de 40x40)
				map_h = 20, -- ^
				map_x = 0, -- posição inicial do desenho no eixo x
				map_y = 0, -- eixo y
				map_display_w = 31, -- isso serve para desenhar o map, se mudar o valor pode ser bom para não usar muita memoria do sistema (usar com cameras)
				map_display_h = 16, -- ^
				map_offset_x = -40, -- reposicionar a camera/desenho para o eixo x 
				map_offset_y = 40, -- eixo y

				-- map 1: top
				-- map 2: bot, left, right
				-- map 3: top, right
				-- map 4: bot
				-- map 5: left
				exit = {
					top = nil,
					bot = false,
					right = nil,
					left = nil
				},
				limits = {},
				gate = {x = 610, y = 175, w = 105, h = 5},
				map = {
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --1
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --2
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --3
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --4
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --5
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --6
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --7
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --8
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --9
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --10
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --12
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --13
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --14
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --15
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --16
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}  --17	 (map_h)
				}, --1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32      X   (map_w)
				
				draw = function(self)			
					lg.draw(self.background, 0, 0)
					for i,v in ipairs(self.box) do
						lg.draw(self.tile[self.box[i].num], self.box[i].x, self.box[i].y)
					end
					for i in ipairs(self.ObjZombie) do
						self.ObjZombie[i]:draw()
						if self.ObjZombie[i].zombie.hp.points <= 0 then
							self.ObjZombie[i]:delete()
							table.remove(self.ObjZombie, i)
						end
					end
					if door then
						lg.draw(self.door, widthWindow/3.2, heightWindow/2.5)
					end
				end,
				drawStuff = function(self)
					local _limits = self.limits
					local _zombie = self.ObjZombie

					for i in ipairs(_limits) do			
						lg.setColor(10, 140, 130)
						lg.rectangle("fill", 
							_limits[i].x, 
							_limits[i].y, 
							_limits[i].w, 
							_limits[i].h
						)
						lg.setColor(255, 255, 255)
					end
					lg.rectangle("fill", self.gate.x, self.gate.y, self.gate.w, self.gate.h)

					for i, ObjZombie in ipairs(_zombie) do
						if ObjZombie.zombie.live == true then
							ObjZombie:drawStuff()
						end
					end
					lg.print("nzombie: " .. #self.ObjZombie, 600, 500)	
				
				end,
				--[[]]
				delete = function(self)
					for i in ipairs(self.limits) do
						removeCollision(self.limits[i])
						self.limits[i] = nil
					end
					for i in ipairs(self.box) do
						removeCollision(self.box[i])
						self.box[i] = nil
					end
					self:deleteZombie()
				end,
				deleteZombie = function(self)
					for i in ipairs(self.ObjZombie) do
						if self.ObjZombie[i].zombie.live == true then
							self.ObjZombie[i]:delete()
						end
						self.ObjZombie[i] = nil
					end
				end,
				loadZombie = function(self)
					for i = 1, 1 do
						table.insert(self.ObjZombie, #self.ObjZombie+1, ClassZombie.new(math.random(200, 900), math.random(200, 400)))
						self.ObjZombie[#self.ObjZombie]:addZombie() -- light
					end
				end,
				load = function(self)
					--limite do map
					local _limits = self.limits

					_limits[1] = {x = 0, 			y = 630,	 	w = 610, 			h = 90} -- pra bot
					_limits[2] = {x = 715, 			y = 630,	 	w = 610, 			h = 90} -- pra bot
					
					_limits[3] = {x = 80, 			y = 0, 			w = 5, 				h = heightWindow} -- left
					
					_limits[4] = {x = 1220,		 	y = 0, 			w = 5, 			 	h = heightWindow} -- right
					
					_limits[5] = {x = 0, 			y = 170 - 85, 	w = 610, 		 	h = 90} -- de cima pra left
					_limits[6] = {x = 715, 			y = 170 - 85, 	w = 610, 			h = 90} -- de cima pra right
				
					_limits[7] = {x = 0, 			y = 170, 		w = widthWindow, 	h = 5} -- key top
	
					for i in ipairs(_limits) do
						addCollision(_limits[i])
					end

					self:loadZombie()
					--limite do map ^ 

					for i=0,4 do -- adicionar os tilesets
						self.tile[i] = lg.newImage("data/textures/tile"..i..".png" )
					end
					--desenhar os tiles e load na colisao
					for y=1, self.map_display_h do -- para que a variavel local y = 1 chegue até 10 faça; (no final add +1 a y)
						for x=1, self.map_display_w do -- para que a variavel local y = 1 chegue até 15 faça; (no final add +1 a x)
							if (self.map[y+self.map_y][x+self.map_x]) == 3 then
								self.box[#self.box+1] = {num = self.map[y+self.map_y][x+self.map_x], x = (x * self.tile_w)+self.map_offset_x, y =(y*self.tile_h)+self.map_offset_y, w = self.tile_w, h = self.tile_h}
								addCollision(self.box[#self.box])
							end
						end
					end
				end
			},
			[6] = {
				background = lg.newImage("data/maps/map1.png"),
				bossmsg = lg.newImage("data/GUI/boss.png"),
				tile = {},
				box = {},
				light = nil,
				--[[
				{
					on = false, 
					effect = love.graphics.newImage("luz.png") -- light
				},]]
				ObjZombie = {},
				ObjBoss = {},
				-- variaveis do map
				tile_w = 40, -- largura do tile
				tile_h = 40, -- altura do tile
				map_w = 20, -- largura do map = 40*20 (serão 20 tiles colocados no eixo x com o tamanho de 40x40)
				map_h = 20, -- ^
				map_x = 0, -- posição inicial do desenho no eixo x
				map_y = 0, -- eixo y
				map_display_w = 31, -- isso serve para desenhar o map, se mudar o valor pode ser bom para não usar muita memoria do sistema (usar com cameras)
				map_display_h = 16, -- ^
				map_offset_x = -40, -- reposicionar a camera/desenho para o eixo x 
				map_offset_y = 40, -- eixo y

				-- map 1: top
				-- map 2: bot, left, right
				-- map 3: top, right
				-- map 4: bot
				-- map 5: left
				exit = {
					top = nil,
					bot = nil,
					right = nil,
					left = nil
				},
				limits = {},
				gate = {x = 610, y = 175, w = 105, h = 5},
				map = {
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --1
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --2
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --3
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --4
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --5
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --6
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --7
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --8
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --9
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --10
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --12
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --13
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --14
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --15
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}, --16
					{0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}  --17	 (map_h)
				}, --1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32      X   (map_w)
				
				draw = function(self)			
					lg.draw(self.background, 0, 0)
					for i,v in ipairs(self.box) do
						lg.draw(self.tile[self.box[i].num], self.box[i].x, self.box[i].y)
					end
					for i in ipairs(self.ObjZombie) do
						self.ObjZombie[i]:draw()
						if self.ObjZombie[i].zombie.hp.points <= 0 then
							self.ObjZombie[i]:delete()
							table.remove(self.ObjZombie, i)
						end
					end
					if self.ObjBoss ~= nil then
						for i in ipairs(self.ObjBoss) do
							self.ObjBoss[i]:draw()
							if self.ObjBoss[i].zombie.hp.points <= 0 then
								self.ObjBoss[i]:delete()
								table.remove(self.ObjBoss, i)
								self.ObjBoss = nil
							end
						end
					end
					if bossimg then
						lg.draw(self.bossmsg, widthWindow/3.2, heightWindow/2.5)
					end
				end,
				drawStuff = function(self)
					local _limits = self.limits
					local _zombie = self.ObjZombie

					for i in ipairs(_limits) do			
						lg.setColor(10, 140, 130)
						lg.rectangle("fill", 
							_limits[i].x, 
							_limits[i].y, 
							_limits[i].w, 
							_limits[i].h
						)
						lg.setColor(255, 255, 255)
					end
					lg.rectangle("fill", self.gate.x, self.gate.y, self.gate.w, self.gate.h)

					for i, ObjZombie in ipairs(_zombie) do
						if ObjZombie.zombie.live == true then
							ObjZombie:drawStuff()
						end
					end
					if self.ObjBoss ~= nil then
						for i, ObjBoss in ipairs(self.ObjBoss) do
							if ObjBoss.zombie.live == true then
								ObjBoss:drawStuff()
							end
						end
					end
					lg.print("nzombie: " .. #self.ObjZombie, 600, 500)	
				
				end,
				--[[]]
				delete = function(self)
					for i in ipairs(self.limits) do
						removeCollision(self.limits[i])
						self.limits[i] = nil
					end
					for i in ipairs(self.box) do
						removeCollision(self.box[i])
						self.box[i] = nil
					end
					self:deleteZombie()
				end,
				deleteZombie = function(self)
					for i in ipairs(self.ObjZombie) do
						if self.ObjZombie[i].zombie.live == true then
							self.ObjZombie[i]:delete()
						end
						self.ObjZombie[i] = nil
					end
				end,
				loadZombie = function(self)
					for i = 1, 1 do
						table.insert(self.ObjZombie, #self.ObjZombie+1, ClassZombie.new(math.random(200, 900), math.random(200, 400)))
						self.ObjZombie[#self.ObjZombie]:addZombie() -- light
					end
					table.insert(self.ObjBoss, #self.ObjBoss+1, ClassBoss.new(math.random(200, 900), math.random(200, 400)))
					self.ObjBoss[#self.ObjBoss]:addZombie() -- light
				end,
				load = function(self)
					--limite do map
					local _limits = self.limits

					_limits[1] = {x = 0, 			y = 630,	 	w = widthWindow, 	h = 90} -- pra bot
					
					_limits[2] = {x = 80, 			y = 0, 			w = 5, 				h = heightWindow} -- left
					
					_limits[3] = {x = 1220,		 	y = 0, 			w = 5, 			 	h = heightWindow} -- right
					
					_limits[4] = {x = 0, 			y = 170 - 85, 	w = 610, 		 	h = 90} -- de cima pra left
					_limits[5] = {x = 715, 			y = 170 - 85, 	w = 610, 			h = 90} -- de cima pra right
				
					_limits[6] = {x = 0, 			y = 170, 		w = widthWindow, 	h = 5} -- key top
	
					for i in ipairs(_limits) do
						addCollision(_limits[i])
					end

					self:loadZombie()
					--limite do map ^ 

					for i=0,4 do -- adicionar os tilesets
						self.tile[i] = lg.newImage("data/textures/tile"..i..".png" )
					end
					--desenhar os tiles e load na colisao
					for y=1, self.map_display_h do -- para que a variavel local y = 1 chegue até 10 faça; (no final add +1 a y)
						for x=1, self.map_display_w do -- para que a variavel local y = 1 chegue até 15 faça; (no final add +1 a x)
							if (self.map[y+self.map_y][x+self.map_x]) == 3 then
								self.box[#self.box+1] = {num = self.map[y+self.map_y][x+self.map_x], x = (x * self.tile_w)+self.map_offset_x, y =(y*self.tile_h)+self.map_offset_y, w = self.tile_w, h = self.tile_h}
								addCollision(self.box[#self.box])
							end
						end
					end
				end
			}
		}
	}
end
return ClassWorld