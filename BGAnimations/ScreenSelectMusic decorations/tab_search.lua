local sizes = Var('sizes')
local stageStats = Var('stageStats')
local util = Var('util')


local t = Def.ActorFrame{
	Name = 'Search',
	InitCommand = function(self)
		self:xy(sizes.scoreContainer.x, sizes.scoreContainer.y)
	end,
	TabSelectedMessageCommand = function(self, params)
		if params.name == self:GetName() then
			self:playcommand('Show', params)
		else
			self:playcommand('Hide')
		end
	end,
	ShowCommand = function(self, params)
		self:finishtweening():smooth(0.2):diffusealpha(1)
	end,
	HideCommand = function(self, params)
		self:finishtweening():smooth(0.2):diffusealpha(0)
	end,
}

t[#t+1] = LoadSizedFont('large') .. {
	OnCommand = function(self)
		self:settext('Search Tab')
	end
}


return t