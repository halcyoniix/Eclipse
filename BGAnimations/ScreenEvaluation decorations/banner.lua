local sizes = Var('sizes')
local stageStats = Var('stageStats')


local t = Def.ActorFrame{
	InitCommand = function(self)
		self:xy(sizes.bannerContainer.x, sizes.bannerContainer.y)
	end,
	Def.Quad {
		Name = 'bg',
		InitCommand = function(self)
			self:setsize(sizes.bannerContainer.w + sizes.border, sizes.bannerContainer.h + sizes.border)
			self:diffuse(0.1,0.1,0.1,1)
		end
	},
}



t[#t+1] = Def.ActorFrame {
	Def.Sprite {
		Name = 'bannerImg',
		InitCommand = function(self)
			self:scaletoclipped(sizes.bannerSize.w, sizes.bannerSize.h)
			self:addy( -(sizes.bannerContainer.h - sizes.bannerSize.h) / 2 )
		end,
		OnCommand = function(self)
			self:finishtweening()
			if stageStats.song then
				local bnpath = stageStats.song:GetBannerPath()
				if not bnpath or bnpath == '' then
					bnpath = THEME:GetPathG("Common", "fallback banner")
				end
				self:Load(bnpath)
			end
		end,
	},
	Def.ActorFrame {
		Name = 'songMetadata',
		InitCommand = function(self)
			self:RunCommandsOnChildren(function(self)
				self:halign(0):valign(1)
			end)
		end,
		LoadSizedFont ('medium') .. {
			Name = 'songTitle',
			InitCommand = function(self)
				self:settext(GAMESTATE:GetCurrentSong():GetDisplayMainTitle())
				self:xy( -(sizes.bannerContainer.w/2) + sizes.hPadding/2, (sizes.bannerContainer.h/2) - sizes.vPadding*2 )
				self:maxwidth(sizes.bannerContainer.w+150)
			end
		},
		LoadSizedFont ('header') .. {
			Name = 'songArtist',
			InitCommand = function(self)
				self:settext(GAMESTATE:GetCurrentSong():GetDisplayArtist())
				self:xy( -(sizes.bannerContainer.w/2) + sizes.hPadding/2, (sizes.bannerContainer.h/2) - sizes.vPadding/2 )
				self:maxwidth(sizes.bannerContainer.w+60)
			end
		},
	},
	Def.ActorFrame {
		Name = 'songDifficulty',
		InitCommand = function(self)
			self:xy( (sizes.bannerContainer.w/2) - sizes.hPadding/2, sizes.bannerContainer.h/2 - sizes.vPadding + 1 )
			self:RunCommandsOnChildren(function(self)
				self:halign(1):valign(1)
			end)
		end,
		LoadSizedFont ('large') .. {
			Name = 'songMSD',
			InitCommand = function(self)
				if stageStats.steps then
					local msd = stageStats.steps:GetMSD(stageStats.score:GetMusicRate(), 1)
					self:settextf('%5.2f',msd)
					self:diffuse(colorByMSD(msd))
					self:maxwidth(120)
				end
			end
		},
		Def.Quad {
			OnCommand = function(self)
				self:setsize(1,23)
				self:diffuse(0.3,0.3,0.3,1)
				self:halign(1)
				self:xy( -sizes.scoreContainer.w/sizes.magicVPadding + sizes.hPadding, 1)
			end
		},
		LoadSizedFont ('large') .. {
			Name = 'difficultySlot',
			InitCommand = function(self)
				local diff = getDifficulty(stageStats.steps:GetDifficulty())
				self:settext(getShortDifficulty(diff))
				self:diffuse(colorByDifficulty(GetCustomDifficulty(stageStats.steps:GetStepsType(), stageStats.steps:GetDifficulty())))
				self:x( -sizes.scoreContainer.w/sizes.magicVPadding )
			end
		},
		Def.ActorFrame {
			Name = 'musicRate',
			InitCommand = function(self)
				local txt = self:GetChild('rateMod')
				local rate = getRateString(stageStats.score:GetMusicRate())
				self:xy(
					-txt:GetWidth()/2,
					-sizes.bannerContainer.h + sizes.bannerSize.h
				)
				self:addy(3)
				if rate == '1x' then
					self:visible(false)
				end
			end,
			Def.Quad {
				Name = 'triangle',
				OnCommand = function(self)
					local txt = self:GetParent():GetChild('rateMod')
					self:setsize(50 + sizes.hPadding, (20 / 720) * 480)
					self:diffuse(0.1,0.1,0.1,1)
					self:skewx(-0.25)
					self:cropleft(0.5)
					self:x((-txt:GetWidth()/2) - 8)
				end
			},
			Def.Quad {
				Name = 'bg',
				OnCommand = function(self)
					local txt = self:GetParent():GetChild('rateMod')
					self:addx((sizes.border/2) + 2)
					self:setsize((txt:GetWidth() + sizes.hPadding) - 4, (20 / 720) * 480)
					self:diffuse(0.1,0.1,0.1,1)
					--self:skewx(-0.25)
				end
			},
			LoadSizedFont ('small') .. {
				Name = 'rateMod',
				InitCommand = function(self)
					local diff = getDifficulty(stageStats.steps:GetDifficulty())
					self:settextf('%s Rate', getRateString(stageStats.score:GetMusicRate()))
				end
			},
		}
	}
}

return t