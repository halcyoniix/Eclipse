local t = Def.ActorFrame {}
local sizes = {
	border = 3,
	headerHeight = 30,
	footerHeight = 80,
	avatarSize = 80,
	hPadding = 10,
	vPadding = 10,

	songPanel = {
		w = 460 ,
		h = 70
	},

	bannerIcon = {
		w = 140,
		h = 70
	},
}

t[#t+1] = Def.ActorFrame{
	Name = 'bg',
	InitCommand = function(self)
		self:RunCommandsOnChildren(function(self)
			self:setsize(sizes.songPanel.w + sizes.border, sizes.songPanel.h + sizes.border)
			self:diffuse(0.1, 0.1, 0.1, 1)
		end)
	end,
	Def.Quad {},
	Def.Quad {
		SetMessageCommand = function(self,params)
			self:faderight(1)
			self:stopeffect()
			if params.HasFocus and params.Song then
				self:diffuseramp()
				self:effectclock('bgm')
				self:effectcolor1(1,1,1,0)
				self:effectcolor2(1,1,1,0.25)
			end
		end
	}
}



return t