local util = Var('util')
local sizes = Var('sizes')
local stageStats = Var('stageStats')

local t = Def.ActorFrame{
	InitCommand = function(self)
		self:xy(sizes.scoreContainer.x, sizes.scoreContainer.y)
	end,
	Def.Quad {
		Name = 'bg',
		InitCommand = function(self)
			self:setsize(sizes.scoreContainer.w + sizes.border, sizes.scoreContainer.h + sizes.border)
			self:diffuse(0.1,0.1,0.1,1)
		end
	},
}




t[#t+1] = Def.ActorFrame {
	Name = 'judgmentData',
	Def.ActorFrame {
		Name = 'percentageFrame',
		InitCommand = function(self)
			self:RunCommandsOnChildren(function(self)
				self:xy(-sizes.scoreContainer.w/2 + sizes.hPadding, -sizes.scoreContainer.h/2 + sizes.vPadding - sizes.magicVPadding/4)
			end)
		end,
		LoadSizedFont('large').. {
			Name = 'scorePercentage',
			OnCommand = function(self)
				self:halign(0):valign(0)
				self:maxwidth(294)
				if stageStats.score then
					local p = stageStats.score:GetWifeScore() * 100
					local grade = THEME:GetString("Grade", ToEnumShortString(GetGradeFromPercent(p / 100)))
					self:settextf('%s %5.2f%%', grade, p)
					self:diffuse(colorByGrade(GetGradeFromPercent(p / 100)))
				else
					self:settext('wtf no score?')
				end
			end,
			SelectedEvalScoreMessageCommand = function(self, curScore)
				if curScore.score then
					local p = curScore.percent
					local g = curScore.grade
					self:settextf('%s %5.2f%%', g, p)
					self:diffuse(colorByGrade(GetGradeFromPercent(p / 100)))
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
			Name = 'songSSR',
			OnCommand = function(self)
				if stageStats.score then
					local ssr = stageStats.score:GetSkillsetSSR("Overall")
					self:settextf('%5.2f', ssr)
					self:diffuse(colorByMSD(ssr))
					self:maxwidth(120)
				end
			end,
			SelectedEvalScoreMessageCommand = function(self, curScore)
				if curScore.score then
					local ssr = curScore.ssr
					self:settextf('%5.2f', ssr)
					self:diffuse(colorByMSD(ssr))
				end
			end
		},
		Def.Quad {
			OnCommand = function(self)
				self:setsize(1,23)
				self:diffuse(0.3,0.3,0.3,1)
				self:halign(1)
				self:xy( -sizes.scoreContainer.w/sizes.magicVPadding + sizes.hPadding, -1)
			end
		},
		LoadSizedFont('large') .. {
			Name = 'judgeWindow',
			OnCommand = function(self)
				local judge = PREFSMAN:GetPreference("SortBySSRNormPercent") and 4 or GetTimingDifficulty()
				self:settext('J'..judge)
				self:diffuse(0.5,0.5,0.5,1)
				self:x( -sizes.scoreContainer.w/sizes.magicVPadding )
			end
		},
	},
	Def.ActorFrame{
		Name = 'modList',
		InitCommand = function(self)
			self:xy( 0, -sizes.scoreContainer.h/2 + (sizes.modList.vMargin ))
		end,
		Def.Quad {
			OnCommand = function(self)
				self:setsize(sizes.scoreContainer.w - sizes.hPadding*2, 1)
				self:diffuse(0.3,0.3,0.3,1)
				self:halign(0.5):valign(1)
			end
		},
		LoadSizedFont('small') .. {
			Name = 'modString',
			OnCommand = function(self)
				local mstr = stageStats.score:GetModifiers()
				self:settext(mstr:gsub(',', ''))
				self:maxwidth((sizes.scoreContainer.w*2) - sizes.hPadding*4)
				self:diffuse(0.7,0.7,0.7,1)
				self:y( sizes.modList.vPadding/2 )
			end
		},
		Def.Quad {
			OnCommand = function(self)
				self:setsize(sizes.scoreContainer.w - sizes.hPadding*2,1)
				self:diffuse(0.3,0.3,0.3,1)
				self:halign(0.5):valign(1)
				self:y( sizes.modList.vPadding )
			end
		},
	},

	Def.ActorFrame {
		Name = 'judgmentFrame',
		InitCommand = function(self)
			self:xy(-sizes.scoreContainer.w/2 + sizes.hPadding, -sizes.scoreContainer.h/2 + (sizes.modList.vMargin + sizes.vPadding*2))
		end,
		util.makeJudgments() .. {},
		util.makeExtraJudgments() .. {},
		Def.ActorFrame {
			Name = 'judgmentData',
			InitCommand = function(self)
				self:y(-sizes.judgment.barGirth - sizes.vPadding + (((3 + 6) + 1) * sizes.judgment.barPadding)) -- never do this
			end,
			LoadSizedFont('small') .. {
				Name = 'judgmentName',
				InitCommand = function(self)
					self:settext(THEME:GetString('JudgmentLine', 'MaxCombo'))
					self:halign(0)
					self:maxwidth(150)
				end
			},
			LoadSizedFont('small') .. {
				Name = 'judgmentCount',
				OnCommand = function(self)
					self:settext(stageStats.score:GetMaxCombo())
					self:halign(1)
					self:x(sizes.judgment.barLength)
				end,
				SelectedEvalScoreMessageCommand = function(self, curScore)
					if curScore.score then
						self:settext(curScore.score:GetMaxCombo())
					end
				end
			},
		},
	},
	Def.Quad {
		OnCommand = function(self)
			self:setsize(1, (280 / 720 * sh))
			self:diffuse(0.3,0.3,0.3,1)
			self:halign(0):valign(1)
			self:y( sizes.scoreContainer.h/2 - sizes.vPadding )
		end
	}
}

local pdf_score = stageStats.score

t[#t+1] = Def.ActorFrame {
	Name = 'timingData',
	InitCommand = function(self)
		self:x(sizes.hPadding)
	end,
	Def.GraphDisplay {
		Name = 'lifeGraph',
		InitCommand = function(self)
			self:Load('GraphDisplay')
			self:valign(0)
			self:GetChild('Backing'):visible(false)
			self:GetChild('Line'):visible(false)
			self:setsize(sizes.lifeGraph.w, sizes.lifeGraph.h)
			self:y(-sizes.scoreContainer.h/2 + (sizes.modList.vMargin + sizes.vPadding*3))
			self:halign(0)
		end,
		OnCommand = function(self)
			if stageStats.song then
				self:SetWithoutStageStats(stageStats.pss, stageStats.song:GetStepsSeconds() / stageStats.score:GetMusicRate())
			end
		end,
	},
	Def.Quad {
		OnCommand = function(self)
			self:setsize(sizes.scoreContainer.w/2 - sizes.hPadding*2, 1)
			self:diffuse(0.3,0.3,0.3,1)
			self:halign(0):valign(1)
			self:y( -sizes.scoreContainer.h/2 + (sizes.modList.vMargin + sizes.vPadding*4) + sizes.lifeGraph.h )
		end
	},
	Def.ActorFrame{
		Name = 'timingGraph',
		InitCommand = function(self)
			self:y(-sizes.scoreContainer.h/2 + (sizes.modList.vMargin + sizes.vPadding*5) + sizes.lifeGraph.h)
		end,
		LoadActorWithParams('pdf.lua', {sizes = sizes}) .. {
			InitCommand = function(self)
				self:RunCommandsOnChildren(function(self)
					self:halign(0)
				end)
			end,
			SelectedEvalScoreMessageCommand = function(self, params)
				pdf_score = params.score
				self:playcommand('Prep', params)
			end,
			UIElements.QuadButton(1,1) .. {
				Name = 'BG',
				OnCommand = function(self)
					self:setsize(sizes.lifeGraph.w, sizes.lifeGraph.h):valign(0)
					self:diffuse(1,1,1,0.1)
				end,
				MouseOverCommand = function(self)
					local s, cb = util.calcStatData(pdf_score, 4)
					local txt = string.format(
						'%s: %5.2fms\n%s: %5.2fms\n%s: %5.2fms\n%s: %s/%s',
						'Mean', s.mean,
						'Std Dev', s.sd,
						'Largest', s.largest,
						'Left/Right CBs', cb[1] + cb[2], cb[3] + cb[4]
					)
					TOOLTIP:SetText(txt)
					TOOLTIP:Show()
				end,
				MouseOutCommand = function(self)
					TOOLTIP:Hide()
				end
			}
		},
		util.makeRatios() .. {}
	},

}


return t