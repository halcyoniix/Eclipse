local sizes = Var('sizes')
local stageStats = Var('stageStats')
local util = Var('util')


local t = Def.ActorFrame{
	InitCommand = function(self)
		self:xy(sizes.scoreContainer.x, sizes.scoreContainer.y)
	end,
	CurrentSongChangedMessageCommand = function(self)
		self:playcommand('Modify', {
			song = GAMESTATE:GetCurrentSong(),
			steps = GAMESTATE:GetCurrentSteps(),
		})
	end,
	Def.Quad {
		Name = 'bg',
		InitCommand = function(self)
			self:zoomto(sizes.scoreContainer.w + sizes.border, sizes.scoreContainer.h + sizes.border)
			self:diffuse(0.1,0.1,0.1,1)
		end,
	},
}




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
		TabSelectedMessageCommand = function(self, params)
			ms.ok(params)
		end
	},
	util.makeTabs() .. {
		InitCommand = function(self)
			self:xy(
					-sizes.scoreContainer.w/2,
					sizes.scoreContainer.h/2 - sizes.tab.h/2 - sizes.hPadding
				)
		end
	}
}

return t