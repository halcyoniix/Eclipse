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
		w = (460 / 1280) * scale16x9.sw,
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
					self:smooth(0.2)
					self:cropright( 1-(jud / totalTaps))
				end,
				SelectedEvalScoreMessageCommand = function(self, params)
					if params.score then
						local jud = params.score.judgments[i]
						self:finishtweening():smooth(0.2):cropright( 1-(jud / totalTaps))
					end
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
					end,
					SelectedEvalScoreMessageCommand = function(self, params)
						if params.score then
							local jud = params.score.judgments[i]
							self:settext(jud)
						end
					end
				},
				LoadSizedFont('small') .. {
					Name = 'judgmentCountPercentage',
					OnCommand = function(self)
						self:settextf('%5.2f%s', (jud / totalTaps) * 100, '%')
						self:diffuse(0.5,0.5,0.5,1)
						self:halign(1)
						self:x(sizes.judgment.barLength - self:GetParent():GetChild('judgmentCount'):GetZoomedWidth() - sizes.hPadding/4)
					end,
					SelectedEvalScoreMessageCommand = function(self, params)
					if params.score then
							local jud = params.score.judgments[i]
							self:settextf('%5.2f%s', (jud / totalTaps) * 100, '%')
							self:x(sizes.judgment.barLength - self:GetParent():GetChild('judgmentCount'):GetZoomedWidth() - sizes.hPadding/4)
						end
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

util.makeRatios = function()
	local accData = util.calcAccData(stageStats.score)
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
					end,
					SelectedEvalScoreMessageCommand = function(self, params)
						local accData = util.calcAccData(params.score.hs)
						local fuck = {accData.ma, accData.pa}
						if params.score then
							self:settextf('%.1f:1', fuck[i] or '??')
						end
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


local allTheScores = {}
local pageLimit = 6
local curPage = 1
local currentSelectedScore
util.makeScores = function(score)
	local curRate = string.format('%.1fx',score:GetMusicRate()) -- haha
	for rate, scoreTable in pairs(getRateTable(getScoresByKey(PLAYER_1))) do
		if rate == curRate then
		for _, curScore in pairs(scoreTable) do
			local percentage = curScore:GetWifeScore() * 100
			if percentage ~= 0 then
				local a = {0,0,0,0,0,0}
				for i = 1,#judges do
					a[i] = curScore:GetTapNoteScore(judges[i])
				end
				table.insert(allTheScores, {
					hs = curScore,
					judgments = a,
					percent = percentage,
					grade = THEME:GetString("Grade", ToEnumShortString(GetGradeFromPercent(percentage / 100))),
					date = curScore:GetDate(),
					ssr = string.format('%5.2f',curScore:GetSkillsetSSR('Overall')),
					rate = rate
				})
			end
		end
		end
	end

	local s = function(i, p)
		local y_pos = math.mod(i-1, pageLimit)
		return Def.ActorFrame {
			OnCommand = function(self)
				self:addy((sizes.leaderboardScore.h + sizes.vPadding/2) * (y_pos))
				self:playcommand('CheckPage', {page = p})
			end,
			CheckPageCommand = function(self, params)
				self:visible(params.page == curPage)
			end,
			UIElements.QuadButton(1,1) .. {
				Name = 'bg',
				OnCommand = function(self)
					self:zoomto(sizes.leaderboardScore.w, sizes.leaderboardScore.h)
					self:diffuse(0.1,0.1,0.1,1)
				end,
				MouseOverCommand = function(self)
					self:finishtweening():smooth(0.1):diffuse(0.2,0.2,0.2,1)
					self:GetParent():finishtweening():smooth(0.1):zoom(1.01)
				end,
				MouseOutCommand = function(self)
					self:finishtweening():smooth(0.1):diffuse(0.1,0.1,0.1,1)
					self:GetParent():finishtweening():smooth(0.1):zoom(1)
				end,
				MouseDownCommand = function(self)
					if currentSelectedScore ~= i then
						MESSAGEMAN:Broadcast('SelectedEvalScore', {score = allTheScores[i]})
					end
					currentSelectedScore = i
				end
			},
			LoadSizedFont('header') .. {
				Name = 'percentage',
				OnCommand = function(self)
					local p = allTheScores[i].percent
					local grade = allTheScores[i].grade
					self:settextf(p > 99.65 and '%s %5.4f%%' or '%s %5.2f%%',grade, p)
					self:diffuse(colorByGrade(GetGradeFromPercent(p / 100)))
					self:halign(1):valign(0)
					self:xy(sizes.leaderboardScore.w/2 - sizes.hPadding, -sizes.leaderboardScore.h/2 + sizes.vPadding)
				end
			},
			LoadSizedFont('header') .. {
				Name = 'judgments',
				OnCommand = function(self)
					local txt = string.format(
					'%s - %s - %s - %s - %s - %s', unpack(allTheScores[i].judgments))
					self:settext(txt)
					self:halign(0):valign(0)
					self:xy(-sizes.leaderboardScore.w/2 + sizes.hPadding, -sizes.leaderboardScore.h/2 + sizes.vPadding)
				end
			},
			LoadSizedFont('small') .. {
				Name = 'ssr',
				OnCommand = function(self)
					local ssr = allTheScores[i].ssr
					self:settext(ssr):diffuse(colorByMSD(ssr))
					self:halign(1):valign(0)
					self:xy(sizes.leaderboardScore.w/2 - sizes.hPadding, sizes.hPadding/2)
				end
			},
			LoadSizedFont('small') .. {
				Name = 'rate',
				OnCommand = function(self)
					local rate = allTheScores[i].rate
					self:settext(rate)
					self:halign(1):valign(0)
					self:xy(sizes.leaderboardScore.w/2 - self:GetParent():GetChild('ssr'):GetZoomedWidth() - sizes.hPadding*2, sizes.hPadding/2)
				end
			},
			LoadSizedFont('small') .. {
				Name = 'date',
				OnCommand = function(self)
					self:settext(allTheScores[i].date):diffuse(0.5,0.5,0.5,1)
					self:halign(0):valign(0)
					self:xy(-sizes.leaderboardScore.w/2 + sizes.hPadding, sizes.hPadding/2)
				end
			},
		}
	end

	local f = Def.ActorFrame{}

	for i = 1,#allTheScores do
		local page = math.floor((i-1)/pageLimit) + 1
		if not f[page] then f[page] = Def.ActorFrame{} end
		f[page][#f[page]+1] = s(i, page)
	end

	return f
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
	util = util
})


return t