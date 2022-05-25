local sizes = Var('sizes')
local stageStats = Var('stageStats')

local t = Def.ActorFrame{
	InitCommand = function(self)
		self:xy(sizes.scoreContainer.x, sizes.scoreContainer.y)
	end,
	Def.Quad {
		Name = 'bg',
		InitCommand = function(self)
			self:zoomto(sizes.scoreContainer.w + sizes.border, sizes.scoreContainer.h + sizes.border)
			self:diffuse(0.1,0.1,0.1,1)
		end
	},
}

local function gatherRadarValue(radar, score)
	local n = score:GetRadarValues():GetValue(radar)
	if n == -1 then
		return stageStats.pss:GetRadarActual():GetValue(radar)
	end
	return n
end

local judges = {
	'TapNoteScore_W1',
	'TapNoteScore_W2',
	'TapNoteScore_W3',
	'TapNoteScore_W4',
	'TapNoteScore_W5',
	'TapNoteScore_Miss',
}

local extraJudges = {
	{'Holds','RadarCategory_Holds'},
	{'Rolls','RadarCategory_Rolls'},
	{'Mines','RadarCategory_Mines'}
}

local totalTaps = 0

for k,v in pairs(judges) do
	totalTaps = totalTaps + stageStats.score:GetTapNoteScore(v)
end

local makeJudgments = function()
	local f = Def.ActorFrame {}
	local bar = function(i)
		local jud = stageStats.score:GetTapNoteScore(judges[i])
		return Def.ActorFrame {
			InitCommand = function(self)
				self:addy(i*sizes.judgment.barPadding)
				self:RunCommandsOnChildren(function(self)
					self:halign(0)
				end)
			end,
			Def.Quad {
				Name = 'barBg',
				OnCommand = function(self)
					self:zoomto(sizes.judgment.barLength, sizes.judgment.barGirth)
					self:diffuse(0.3,0.3,0.3,1)
				end
			},
			Def.Quad {
				Name = 'barFill',
				OnCommand = function(self)
					self:zoomto(sizes.judgment.barLength, sizes.judgment.barGirth)
					self:diffuse(colorByJudgment(judges[i]))
					self:cropright(1)
					self:sleep(0.2)
					self:smooth(0.4)
					self:cropright( 1-(jud / totalTaps))
				end
			},
			Def.ActorFrame {
				Name = 'judgmentThingy',
				InitCommand = function(self)
					self:y(-sizes.judgment.barGirth - sizes.vPadding)
				end,
				LoadSizedFont('small') .. {
					Name = 'judgmentName',
					InitCommand = function(self)
						self:settext(THEME:GetString('TapNoteScore', judges[i]))
						self:halign(0)
						self:maxwidth(150)
					end
				},
				LoadSizedFont('small') .. {
					Name = 'judgmentCount',
					OnCommand = function(self)
						self:settext(jud)
						self:halign(1)
						self:x(sizes.judgment.barLength)
					end
				},
				LoadSizedFont('small') .. {
					Name = 'judgmentCountPercentage',
					OnCommand = function(self)
						self:settextf('%5.2f%s', (jud / totalTaps) * 100, '%')
						self:diffuse(0.5,0.5,0.5,1)
						self:halign(1)
						self:x(sizes.judgment.barLength - self:GetParent():GetChild('judgmentCount'):GetZoomedWidth() - sizes.hPadding/4)
					end
				},
			},
		}
	end

	for k,v in pairs(judges) do
		f[#f+1] = bar(k)
	end

	return f
end


local makeExtraJudgments = function()
	local f = Def.ActorFrame {}
	local bar = function(i)
		local rV = gatherRadarValue(extraJudges[i][2], stageStats.score)
		local rP = stageStats.pss:GetRadarPossible():GetValue(extraJudges[i][2])
		local num = rV ..'/'.. rP
		return Def.ActorFrame {
			InitCommand = function(self)
				self:addy(i*sizes.judgment.barPadding + sizes.judgment.barPadding*#judges)
				self:RunCommandsOnChildren(function(self)
					self:halign(0)
				end)
			end,
			Def.Quad {
				Name = 'barBg',
				OnCommand = function(self)
					self:zoomto(sizes.judgment.barLength, sizes.judgment.barGirth)
					self:diffuse(0.3,0.3,0.3,1)
				end
			},
			Def.Quad {
				Name = 'barFill',
				OnCommand = function(self)
					self:zoomto(sizes.judgment.barLength, sizes.judgment.barGirth)
					self:cropright(1)
					self:sleep(0.2)
					self:smooth(0.4)
					self:cropright(1 - (rV / rP))
				end
			},
			Def.ActorFrame {
				Name = 'judgmentThingy',
				InitCommand = function(self)
					self:y(-sizes.judgment.barGirth - sizes.vPadding)
				end,
				LoadSizedFont('small') .. {
					Name = 'judgmentName',
					InitCommand = function(self)
						self:settext(THEME:GetString('OptionTitles', extraJudges[i][1]))
						self:halign(0)
						self:maxwidth(150)
					end
				},
				LoadSizedFont('small') .. {
					Name = 'judgmentCount',
					OnCommand = function(self)
						self:settext(num)
						self:halign(1)
						self:x(sizes.judgment.barLength)
					end
				},
			},
		}
	end

	for k,v in pairs(extraJudges) do
		f[#f+1] = bar(k)
	end

	return f
end

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
					local percent = stageStats.score:GetWifeScore() * 100
					local grade = THEME:GetString("Grade", ToEnumShortString(GetGradeFromPercent(percent / 100)))
					self:settextf('%s %s', grade, string.format('%5.2f',percent) .. '%')
					self:diffuse(colorByGrade(GetGradeFromPercent(percent / 100)))
				else
					self:settext('wtf no score?')
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
			end
		},
		Def.Quad {
			OnCommand = function(self)
				self:zoomto(1,23)
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
				self:zoomto(sizes.scoreContainer.w - sizes.hPadding*2, 1)
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
				self:zoomto(sizes.scoreContainer.w - sizes.hPadding*2,1)
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
		makeJudgments() .. {},
		makeExtraJudgments() .. {},
		Def.ActorFrame {
			Name = 'judgmentData',
			InitCommand = function(self)
				self:y(-sizes.judgment.barGirth - sizes.vPadding + (((#extraJudges + #judges) + 1) * sizes.judgment.barPadding))
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
				end
			},
		},
	},
	Def.Quad {
		OnCommand = function(self)
			self:zoomto(1, (280 / 720 * sh))
			self:diffuse(0.3,0.3,0.3,1)
			self:halign(0):valign(1)
			self:y( sizes.scoreContainer.h/2 - sizes.vPadding )
		end
	}
}


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
			self:zoomto(sizes.lifeGraph.w, sizes.lifeGraph.h)
			self:y(-sizes.scoreContainer.h/2 + (sizes.modList.vMargin + sizes.vPadding*3))
			self:halign(0)
		end,
		OnCommand = function(self)
			if stageStats.song then
				self:SetWithoutStageStats(stageStats.pss, stageStats.song:GetStepsSeconds() / stageStats.score:GetMusicRate())
			end
		end
	},
	Def.Quad {
		OnCommand = function(self)
			self:zoomto(sizes.scoreContainer.w/2 - sizes.hPadding*2, 1)
			self:diffuse(0.3,0.3,0.3,1)
			self:halign(0):valign(1)
			self:y( -sizes.scoreContainer.h/2 + (sizes.modList.vMargin + sizes.vPadding*4) + sizes.lifeGraph.h )
		end
	},
}

return t