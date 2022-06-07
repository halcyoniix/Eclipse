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

t.SetMessageCommand = function(self, params)
	if params.Song then
		local hgrade = params.Song:GetHighestGrade() or 'Grade_None'
		local grade = self:GetParent():GetChild('GradeP1')
		if grade ~= nil then
			grade:RunCommandsOnChildren(function(self)
				self:xy(-(sizes.songPanel.w/2) + sizes.bannerIcon.w + 3, 5)
				self:zoom(FONTSIZE.small)
				self:halign(0)
				self:maxwidth(299)
				self:diffuse(colorByGrade(tostring(hgrade)))
			end)
		end
	end
end

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
			if params.HasFocus then
				self:diffuseramp()
				self:effectclock('bgm')
				self:effectcolor1(1,1,1,0)
				self:effectcolor2(1,1,1,0.25)
			else
				self:stopeffect()
			end
		end
	}
}

t[#t+1] = Def.Quad {
	InitCommand = function(self)
		self:halign(0)
		self:setsize((sizes.songPanel.w - sizes.bannerIcon.w) - sizes.hPadding*2 , 1)
		self:xy(-60 + sizes.hPadding/2, 11)
		self:diffusealpha(0.3)
	end
}

t[#t+1] = Def.Sprite {
	Name = 'bannerIcon',
	InitCommand = function(self)
		--self:halign(0)
		self:x((sizes.bannerIcon.w/2)-(sizes.songPanel.w/2) + sizes.border - 3)
	end,
	SetMessageCommand = function(self,params)
		local song = params.Song
		local focus = params.HasFocus
		local bnpath

		if song then 
			bnpath = params.Song:GetBannerPath()
			if bnpath == nil then 
				bnpath = THEME:GetPathG("Common", "fallback banner")
		end
		local sx, sy = sizes.bannerIcon.w - sizes.border, sizes.bannerIcon.h - sizes.border
		self:Load(bnpath)
		self:setsize(sizes.bannerIcon.w - sizes.border, sizes.bannerIcon.h - sizes.border)
		--self:scaletocover(-sx/2, -sy/2, sx/2, sy/2) -- ???
		end
	end
}



return t