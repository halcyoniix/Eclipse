local sizes = Var('sizes')
local stageStats = Var('stageStats')
local util = Var('util')


local t = Def.ActorFrame{
	InitCommand = function(self)
		self:xy(sizes.scoreContainer.x, sizes.scoreContainer.y)
	end,
	Def.Quad {
		Name = 'bg',
		InitCommand = function(self)
			self:zoomto(sizes.scoreContainer.w + sizes.border, sizes.scoreContainer.h + sizes.border)
			self:diffuse(0.1,0.1,0.1,1)
		end,
	},
}

local thingy = function(event)
	local num = tonumber(event.char)
	if type(num) == 'number' then
		if event.type == 'InputEventType_FirstPress' then
			if num >= 1 and num <= #util.tab.buttons then
				util.tab.curSelected = util.tab.buttons[num][1]
				MESSAGEMAN:Broadcast('TabSelected', {name = util.tab.buttons[num][1], index = num})
			end
		end
	end
end


t[#t+1] = Def.ActorFrame {
	Def.Quad {
		InitCommand = function(self)
			self:valign(0)
			self:setsize(sizes.scoreContainer.w - sizes.hPadding*2, 1)
			self:xy(
				0,
				sizes.scoreContainer.h/2 - sizes.tab.h - sizes.hPadding*2
			)
			self:diffusealpha(0.3)
		end,
		BeginCommand = function(self)
			SCREENMAN:GetTopScreen():AddInputCallback(thingy)
		end
	},
	util.makeTabs() .. {
		InitCommand = function(self)
			self:xy(
					-sizes.scoreContainer.w/2,
					sizes.tab.vPadding
				)
		end
	}
}

return t