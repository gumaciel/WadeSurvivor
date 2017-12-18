local shine = require 'data/shaders/Shine'

-- load the effects you want
local scanlines = shine.scanlines()
local filmgrain = shine.filmgrain()
-- many effects can be parametrized
--grain.opacity = 0.2 
-- multiple parameters can be set at once
local colorgradesimple = shine.colorgradesimple()
--colorgradesimple.parameters = {radius = 0.9} --,opacity = 0.7  
-- you can also provide parameters on effect construction
local desaturate1 = shine.desaturate{strength = 0, tint = {0,0,0}} 
local desaturate2 = shine.desaturate{strength = -6, tint = {255,0,0}} 
-- you can chain multiple effects
post_effect1 = desaturate1:chain(scanlines):chain(colorgradesimple)
post_effect2 = desaturate2:chain(filmgrain):chain(colorgradesimple)
-- warning - setting parameters affects all chained effects:
p_eOpacity = 0.6 --0.88
post_effect2.opacity = p_eOpacity
-- affects both vignette and film grain
-- Shader loaded --


local isFinished = true

function update_shader(dt)
	if isFinished then
		p_eOpacity = p_eOpacity + 0.001
		post_effect2.opacity = p_eOpacity
		if p_eOpacity >= 0.8 then
			isFinished = false 
		end
	else
		p_eOpacity = p_eOpacity - 0.001
		post_effect2.opacity = p_eOpacity
		if p_eOpacity <= 0.5 then
			isFinished = true 
		end
	end

    if love.keyboard.isDown("-") and p_eOpacity > 0 then
        p_eOpacity = p_eOpacity - 0.5 * dt
        post_effect2.opacity = p_eOpacity
    end

    if love.keyboard.isDown("=") and p_eOpacity < 2 then
        p_eOpacity = p_eOpacity + 0.5 * dt
        post_effect2.opacity = p_eOpacity
    end
end