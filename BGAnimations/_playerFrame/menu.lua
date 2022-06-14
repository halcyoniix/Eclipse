local sizes = Var('sizes')
local pStats = Var('pStats')
local util = Var('util')
local t = Def.ActorFrame {}

t[#t+1] = Def.ActorFrame {
	InitCommand = function(self)
		self:diffusealpha(0):visible(false)
	end,
	OpenProfileMenuMessageCommand = function(self)
		self:finishtweening():queuecommand('Show'):smooth(0.1):diffusealpha(1)
	end,
	CloseProfileMenuMessageCommand = function(self)
		self:finishtweening():smooth(0.1):diffusealpha(0):queuecommand('Hide')
	end,
	ShowCommand = function(self)
		self:visible(true)
	end,
	HideCommand = function(self)
		self:visible(false)
	end,
	Def.Quad {
		InitCommand = function(self)
			self:Center():setsize(sw,sh):diffuse(0,0,0,0.5)
		end
	}
}

return t