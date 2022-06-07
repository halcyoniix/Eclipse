local t = Def.ActorFrame {}
local scale16x9 = {
	sw = 854, sh = 480
}
local sizes = {
	border = 3,
	headerHeight = (30 / 720) * sh,
	footerHeight = (80 / 720) * sh,
	avatarSize = (80 / 720) * sh,
	hPadding = (10 / 1280) * scale16x9.sw,
	vPadding = (10 / 720) * scale16x9.sh,

	songPanel = {
		w = (460 / 1280) * scale16x9.sw,
		h = (70 / 720) * scale16x9.sh
	},

	bannerIcon = {
		w = (140 / 1280) * scale16x9.sw,
		h = (70 / 720) * scale16x9.sh
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