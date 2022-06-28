local sizes = Var('sizes')
local stageStats = Var('stageStats')
local util = Var('util')


local t = Def.ActorFrame {
	Name = 'General',
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

t[#t+1] = Def.ActorFrame {
	Name = 'topScore',
	Def.ActorFrame {
		Name = 'percentageFrame',
		InitCommand = function(self)
			self:RunCommandsOnChildren(function(self)
				self:xy(-sizes.scoreContainer.w/2 + sizes.hPadding, -sizes.scoreContainer.h/2 + sizes.vPadding - sizes.magicVPadding/4)
			end)
		end,
		LoadSizedFont('large').. {
			Name = 'scorePercentage',
			CurrentStepsChangedMessageCommand = function(self)
				self:playcommand('Modify', {
					song = GAMESTATE:GetCurrentSong(),
					steps = GAMESTATE:GetCurrentSteps(),
				})
			end,
			CurrentRateChangedMessageCommand = function(self)
				self:playcommand('Modify', {
					song = GAMESTATE:GetCurrentSong(),
					steps = GAMESTATE:GetCurrentSteps(),
				})
			end,
			OnCommand = function(self)
				self:halign(0):valign(0)
				self:maxwidth(294)
				self:settextf('%s %5.2f%%', 'AA', '74.83')
				--if stageStats.score then
				--local p = stageStats.score:GetWifeScore() * 100
				--local grade = THEME:GetString("Grade", ToEnumShortString(GetGradeFromPercent(p / 100)))
				--self:settextf('%s %5.2f%%', grade, p)
				--	self:diffuse(colorByGrade(GetGradeFromPercent(p / 100)))
				--else
				--	self:settext('wtf no score?')
				--end
			end,
			ModifyCommand = function(self, params)
				if util.tab.curSelected == 'General' then
					--ms.ok(params)
				end
			end
		},
	},
	Def.ActorFrame {
		Name = 'songDifficulty',
		InitCommand = function(self)
			self:xy( (sizes.scoreContainer.w/2) - sizes.hPadding/2, -sizes.scoreContainer.h/2 + sizes.vPadding - sizes.magicVPadding/4)
			self:RunCommandsOnChildren(function(self)
				self:halign(1):valign(0)
				--self:maxwidth(sizes.bannerContainer.w)
			end)
		end,
		LoadSizedFont('large') .. {
			Name = 'clearType',
			OnCommand = function(self)
				--self:settextf('%5.2f', ssr)
				--self:diffuse(colorByMSD(ssr))
				self:maxwidth(120)
				self:settext('SDCB')
			end,
		},
		Def.Quad {
			OnCommand = function(self)
				self:setsize(1,23)
				self:diffuse(0.3,0.3,0.3,1)
				self:halign(1)
				self:xy( -sizes.scoreContainer.w/sizes.magicVPadding + sizes.hPadding, -1)
			end
		},
	},
	Def.Quad {
		OnCommand = function(self)
			self:setsize(sizes.scoreContainer.w - sizes.hPadding*2, 1)
			self:diffuse(0.3,0.3,0.3,1)
			self:halign(0.5):valign(1)
			self:y(-sizes.scoreContainer.h/2 + (sizes.modList.vMargin ))
		end
	},
}


return t