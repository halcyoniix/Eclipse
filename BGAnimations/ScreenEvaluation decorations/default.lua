local t = Def.ActorFrame{}
local stageStats = {
	song = GAMESTATE:GetCurrentSong(),
	steps = GAMESTATE:GetCurrentSteps(),
	score = SCOREMAN:GetMostRecentScore() or SCOREMAN:GetTempReplayScore(),
	pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(),
	judgeSetting = (PREFSMAN:GetPreference("SortBySSRNormPercent") and 4 or GetTimingDifficulty())
}
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

	bannerSize = {
		w = (460 / 1280) * scale16x9.sw,
		h = (140 / 720) * scale16x9.sh,
	},

	bannerContainer = {
		w = (460 / 1280) * scale16x9.sw,
		h = (190 / 720) * scale16x9.sh,
		x = (capWideScale(240, 390) / 1280) * scale16x9.sw,
		y = (145 / 720) * scale16x9.sh,
	},

	scoreContainer = {
		w = (460 / 1280) * scale16x9.sw,
		h = (370 / 720) * scale16x9.sh,
		x = (capWideScale(240, 390) / 1280) * scale16x9.sw,
		y = (435 / 720) * scale16x9.sh,
	},

	leaderboardContainer = {
		w = (460 / 1280) * scale16x9.sw,
		h = (370 / 720) * scale16x9.sh,
		x = sw - (capWideScale(240, 390) / 1280) * scale16x9.sw,
		y = (235 / 720) * scale16x9.sh,
	},

	scatterplotContainer = {
		w = (460 / 1280) * scale16x9.sw,
		h = (190 / 720) * scale16x9.sh,
		x = sw - (capWideScale(240, 390) / 1280) * scale16x9.sw,
		y = (525 / 720) * scale16x9.sh,
	},

	magicVPadding = 3.6,

	modList = {
		vMargin = (50 / 720) * scale16x9.sh,
		vPadding = ((20) / 720) * scale16x9.sh,
	},

	judgment = {
		barLength = (210 / 1280) * scale16x9.sw,
		barGirth = 3,
		barPadding = (30 / 720) * scale16x9.sh,
	},

	lifeGraph = {
		w = (210 / 1280) * scale16x9.sw,
		h = (100 / 720) * scale16x9.sh
	},

	leaderboardScore = {
		w = (440 / 1280) * scale16x9.sw,
		h = (50 / 720) * scale16x9.sh,
	}
}

local util = {}

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
util.makeJudgments = function()
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

util.makeExtraJudgments = function()
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

util.makeRatios = function(accData)
	local fuck = {accData.ma, accData.pa}
	local fuck2 = {'MA Ratio', 'PA Ratio'}
	local f = Def.ActorFrame {}
	local bar = function(i)
		return Def.ActorFrame {
			InitCommand = function(self)
				self:addy(sizes.lifeGraph.h + (sizes.judgment.barPadding*i))
				self:RunCommandsOnChildren(function(self)
					self:halign(0)
				end)
			end,
			Def.Quad {
				OnCommand = function(self)
					self:zoomto(sizes.judgment.barLength, 1):y(-sizes.vPadding*2)
					self:diffuse(0.3,0.3,0.3,1)
					self:halign(0):valign(1)
				end
			},
			Def.ActorFrame {
				Name = 'judgmentThingy',
				InitCommand = function(self)
					self:y(-sizes.judgment.barGirth)
				end,
				LoadSizedFont('small') .. {
					Name = 'judgmentName',
					InitCommand = function(self)
						self:settext(fuck2[i] or 'fuck')
						self:halign(0)
						self:maxwidth(150)
					end
				},
				LoadSizedFont('small') .. {
					Name = 'judgmentCount',
					OnCommand = function(self)
						self:settextf('%.1f:1',fuck[i] or '??')
						self:halign(1)
						self:x(sizes.judgment.barLength)
					end
				},
			},
		}
	end

	for i = 1,2 do
		f[#f+1] = bar(i)
	end

	return f
end

util.calcStatData = function(score, numColumns)
	local tracks = score:GetTrackVector()
	local offsets = score:GetOffsetVector()
	local middleCol = numColumns / 2
	local output = {
		mean = 0,
		sd = 0,
		largest = 0,
		lcb = 0,
		mcb = 0,
		rcb = 0
	}
	local cbInfo = {}
	for _ = 1, numColumns + 1 do
		cbInfo[#cbInfo + 1] = 0
	end

	if not offsets or #offsets == 0 then
		return output, cbInfo
	end

	local cbThreshold = ms.JudgeScalers[stageStats.judgeSetting] * 90

	for k,v in ipairs(offsets) do
		if v == 180 then
			offsets[k] = 1000
			v = 1000
		end
		if tracks[k] then
			if math.abs(v) > cbThreshold then
				if tracks[k] < output.mcb then
					output.lcb = output.lcb + 1
				elseif tracks[k] > output.mcb then
					output.rcb = output.rcb + 1
				else
					output.mcb = output.mcb + 1
				end
				cbInfo[tracks[k]+1] = cbInfo[tracks[k]+1] + 1
			end
		end
	end


	local s, l = wifeRange(offsets)

	output.mean = wifeMean(offsets)
	output.sd = wifeSd(offsets)
	output.largest = l

	return output, cbInfo
end

util.calcAccData = function(score)
	local output = {
		ma = score:GetTapNoteScore(judges[1]),
		pa = score:GetTapNoteScore(judges[2]),
		ga = score:GetTapNoteScore(judges[3]),
	}

	output.ma = output.ma / output.pa
	output.pa = output.pa / output.ga

	return output
end

t[#t+1] = LoadActorWithParams('banner.lua', {
	sizes = sizes,
	stageStats = stageStats,
})

t[#t+1] = LoadActorWithParams('score.lua', {
	sizes = sizes,
	stageStats = stageStats,
	util = util
})

t[#t+1] = LoadActorWithParams('scatterplot.lua', {
	sizes = sizes,
	stageStats = stageStats,
})

t[#t+1] = LoadActorWithParams('leaderboard.lua', {
	sizes = sizes,
	stageStats = stageStats,
})


return t