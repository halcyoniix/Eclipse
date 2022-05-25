local sizes = Var('sizes')
local stageStats = Var('stageStats')


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
	
}

return t