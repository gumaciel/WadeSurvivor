local bump = require "bump"
local world = bump.newWorld()

function addCollision(object)
	world:add(object, object.x, object.y, object.w, object.h)	
end
function removeCollision(object)
	world:remove(object, object.x, object.y, object.w, object.h)
end

function moveCollision(object, dx, dy)
	if dx ~= 0 or dy ~= 0 then
		object.x, object.y, cols, len = world:move(object, object.x + dx, object.y + dy)
	end
end

function checkCollision(x1, y1, w1, h1, x2, y2, w2, h2)
  return x1 < x2 + w2 and
		 x2 < x1 + w1 and
		 y1 < y2 + h2 and
		 y2 < y1 + h1
end

--[[
local ClasseColisao = {}

function ClasseColisao.novo()
	return {
		player = {},
		caixas = {}, -- array (o player tb é uma array)

		add = function(self, variavel, X, Y, W, H)
			self.world:add(variavel, X, Y, W, H)
		end,
		addplayer = function(self, objeto)
			self.player = objeto
			self.world:add(player, player.x, player.y, player.w, player.h)
		end,

		desenharplayer = function(self)
			self.desenharCaixa(self.player, 200, 100, 50)
		end,

		desenharCaixa = function(caixa, r, g, b)
			love.graphics.setColor(r,g,b,70)
			love.graphics.rectangle("fill", caixa.x, caixa.y, caixa.w, caixa.h)
			love.graphics.setColor(r,g,b)
			love.graphics.rectangle("line", caixa.x, caixa.y, caixa.w, caixa.h)
		end,

		desenharBlocos = function (self)
			for i,caixa in ipairs(self.caixas) do
				self.desenharCaixa(caixa, 255, 0, 0)
			end
		end,
		mov_player = function(self, dt)  -- x,y, width, height
			velocidade = self.player.velocidade
			dx, dy = 0, 0
			if love.keyboard.isDown ("left") then
				dx = dx - velocidade * dt
			end
			if love.keyboard.isDown ("right") then
				dx = dx + velocidade * dt
			end
			if love.keyboard.isDown ("up") then
				dy = dy - velocidade * dt
			end
			if love.keyboard.isDown ("down") then
				dy = dy + velocidade * dt
			end
			if dx ~= 0 or dy ~= 0 then
				self.player.x, self.player.y, cols, len = self.world:move(self.player, self.player.x + dx, self.player.y + dy)
			end
		end
	}
end
return ClasseColisao]]