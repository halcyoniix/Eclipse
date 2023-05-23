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
	border = 4,
	headerHeight = 30,
	footerHeight = 80,
	avatarSize = 80,
	hPadding = 10,
	vPadding = 10,
	iconSize = 18,

	bannerSize = {
		w = 460,
		h = 140,
	},

	bannerContainer = {
		w = 460,
		h = 190,
		x = capWideScale(240, 390),
		y = 145,
	},

	scoreContainer = {
		w = 460,
		h = 370,
		x = capWideScale(240, 390),
		y = 435,
	},

	leaderboardContainer = {
		w = 460,
		h = 370,
		x = sw - capWideScale(240, 390),
		y = 235,
	},

	scatterplotContainer = {
		w = 460,
		h = 190,
		x = sw - capWideScale(240, 390),
		y = 525,
	},

	magicVPadding = 3,

	modList = {
		vMargin = 50,
		vPadding = 20,
	},

	judgment = {
		barLength = 210,
		barGirth = 3,
		barPadding = 30,
	},

	lifeGraph = {
		w = 210,
		h = 100
	},

	leaderboardScore = {
		w = 440,
		h = 50,
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
local fuckyou = {
	'W1',
	'W2',
	'W3',
	'W4',
	'W5',
	'Miss',
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
					self:setsize(sizes.judgment.barLength, sizes.judgment.barGirth)
					self:diffuse(0.3,0.3,0.3,1)
				end
			},
			Def.Quad {
				Name = 'barFill',
				OnCommand = function(self)
					self:setsize(sizes.judgment.barLength, sizes.judgment.barGirth)
					self:diffuse(colorByJudgment(judges[i]))
					self:cropright(1)
					self:sleep(0.2)
					self:smooth(0.2)
					self:cropright( 1-(jud / totalTaps))
				end,
				SelectedEvalScoreMessageCommand = function(self, curScore)
					if curScore.score then
						local jud = curScore.judgments[i]
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
						self:settext(THEME:GetString('TapNoteScore', fuckyou[i]))
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
					SelectedEvalScoreMessageCommand = function(self, curScore)
						if curScore.score then
							local jud = curScore.judgments[i]
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
						self:x(sizes.judgment.barLength - self:GetParent():GetChild('judgmentCount'):GetWidth())
						--self:x(sizes.judgment.barLength - self:GetParent():GetChild('judgmentCount'):GetWidth() - sizes.hPadding/4)
					end,
					SelectedEvalScoreMessageCommand = function(self, curScore)
						if curScore.score then
							local jud = curScore.judgments[i]
							self:settextf('%5.2f%s', (jud / totalTaps) * 100, '%')
							self:x(sizes.judgment.barLength - self:GetParent():GetChild('judgmentCount'):GetWidth())
							--self:x(sizes.judgment.barLength - self:GetParent():GetChild('judgmentCount'):GetWidth() - sizes.hPadding/4)
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
					self:setsize(sizes.judgment.barLength, sizes.judgment.barGirth)
					self:diffuse(0.3,0.3,0.3,1)
				end
			},
			Def.Quad {
				Name = 'barFill',
				OnCommand = function(self)
					self:setsize(sizes.judgment.barLength, sizes.judgment.barGirth)
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
					self:setsize(sizes.judgment.barLength, 1):y(-sizes.vPadding*2)
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
						self:settextf('%s:1',tostring(fuck[i]) == 'inf' and '∞' or string.format('%.1f',fuck[i]))
						self:halign(1)
						self:x(sizes.judgment.barLength)
					end,
					SelectedEvalScoreMessageCommand = function(self, curScore)
						if curScore.score then
							local accData = util.calcAccData(curScore.score)
							local fuck = {accData.ma, accData.pa}
							self:settextf('%s:1',tostring(fuck[i]) == 'inf' and '∞' or string.format('%.1f',fuck[i]))
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

util.allTheScores = {}
util.curPage = 1
util.pageSize = 6
local currentScoreIndex
util.curRate = string.format('%.1fx',stageStats.score:GetMusicRate())
--ms.ok(util.curRate)
for rate, scoreTable in pairs(getRateTable(getScoresByKey(PLAYER_1))) do
	if not util.allTheScores[rate] then
		util.allTheScores[rate] = {}
	end
	for _, curScore in pairs(scoreTable) do
		ms.ok(GAMESTATE:GetCurrentSteps())
		local percentage = curScore:GetWifeScore() * 100
		if percentage ~= 0 then
			local a = {0,0,0,0,0,0}
			for i = 1,#judges do
				a[i] = curScore:GetTapNoteScore(judges[i])
			end
			table.insert(util.allTheScores[rate], {
				score = curScore,
				judgments = a,
				percent = percentage,
				grade = THEME:GetString("Grade", ToEnumShortString(GetGradeFromPercent(percentage / 100))),
				date = curScore:GetDate(),
				ssr = string.format('%5.2f',curScore:GetSkillsetSSR('Overall')),
				rate = rate,
				steps = GAMESTATE:GetCurrentSteps()
			})
		end
	end
end

table.sort(util.allTheScores, function(a, b)
	return a.score > b.score
end)


util.makeScores = function(score)

	util.selectedScore = score
	local s = function(i, p)
		local y_pos = math.mod(i-1, util.pageSize)
		return Def.ActorFrame {
			OnCommand = function(self)
				self:addy(sizes.vPadding + (sizes.leaderboardScore.h + sizes.vPadding/2) * (y_pos))
				self:playcommand('CheckPage', {page = p})
			end,
			CheckPageCommand = function(self, params)
				self:visible(params.page == util.curPage)
			end,
			UIElements.QuadButton(1,1) .. {
				Name = 'bg',
				OnCommand = function(self)
					self:setsize(sizes.leaderboardScore.w, sizes.leaderboardScore.h)
					self:diffuse(0.15,0.15,0.15,1)
				end,
				MouseOverCommand = function(self)
					self:finishtweening():smooth(0.1):diffuse(0.2,0.2,0.2,1)
					self:GetParent():finishtweening():smooth(0.1):zoom(1.01)
				end,
				MouseOutCommand = function(self)
					self:finishtweening():smooth(0.1):diffuse(0.15,0.15,0.15,1)
					self:GetParent():finishtweening():smooth(0.1):zoom(1)
				end,
				MouseDownCommand = function(self)
					if currentScoreIndex ~= i then
						currentScoreIndex = i
						MESSAGEMAN:Broadcast('SelectedEvalScore', util.allTheScores[util.curRate][i])
					end
				end
			},
			Def.Quad {
				Name = 'selector',
				OnCommand = function(self)
					self:setsize(sizes.leaderboardScore.w, sizes.leaderboardScore.h)
					self:diffuse(0.25,0.25,0.25,0)
					--self:xy(-sizes.leaderboardScore.w/2, -sizes.leaderboardScore.h/2)
					--self:visible(util.allTheScores[util.curRate][i].score == score)
				end,
				SelectedEvalScoreMessageCommand = function(self)
					if currentScoreIndex == i then
						self:smooth(0.1):diffusealpha(1)
					else
						self:smooth(0.1):diffusealpha(0)
					end
					--self:visible(currentScoreIndex == i)
				end
			},
			UIElements.TextToolTip(1, 1, 'Common Normal') .. {
				Name = 'percentage',
				OnCommand = function(self)
					local p = util.allTheScores[util.curRate][i].percent
					local grade = util.allTheScores[util.curRate][i].grade
					self:zoom(FONTSIZE.header)
					self:settextf('%s %5.2f%%',grade, p)
					self:diffuse(colorByGrade(GetGradeFromPercent(p / 100)))
					self:halign(1):valign(0)
					self:xy(sizes.leaderboardScore.w/2 - sizes.hPadding, -sizes.leaderboardScore.h/2 + sizes.vPadding)
				end,
				MouseOverCommand = function(self)
					local p = util.allTheScores[util.curRate][i].percent
					TOOLTIP:SetText(string.format('%5.5f%%', p))
					TOOLTIP:Show()
				end,
				MouseOutCommand = function(self)
					TOOLTIP:Hide()
				end
			},
			LoadSizedFont('header') .. {
				Name = 'judgments',
				OnCommand = function(self)
					local txt = string.format(
					'%s - %s - %s - %s - %s - %s', unpack(util.allTheScores[util.curRate][i].judgments))
					self:settext(txt)
					self:halign(0):valign(0)
					self:xy(-sizes.leaderboardScore.w/2 + sizes.hPadding, -sizes.leaderboardScore.h/2 + sizes.vPadding)
				end
			},
			LoadSizedFont('small') .. {
				Name = 'ssr',
				OnCommand = function(self)
					local ssr = util.allTheScores[util.curRate][i].ssr
					self:settext(ssr):diffuse(colorByMSD(ssr))
					self:halign(1):valign(0)
					self:xy(sizes.leaderboardScore.w/2 - sizes.hPadding, sizes.hPadding/2)
				end
			},
			LoadSizedFont('small') .. {
				Name = 'rate',
				OnCommand = function(self)
					local rate = util.allTheScores[util.curRate][i].rate
					self:settext(rate)
					self:halign(1):valign(0)
					self:xy(sizes.leaderboardScore.w/2 - self:GetParent():GetChild('ssr'):GetZoomedWidth() - sizes.hPadding*2, sizes.hPadding/2)
				end
			},
			LoadSizedFont('small') .. {
				Name = 'date',
				OnCommand = function(self)
					local date = util.allTheScores[util.curRate][i].date
					self:settext(date):diffuse(0.5,0.5,0.5,1)
					self:halign(0):valign(0)
					self:xy(-sizes.leaderboardScore.w/2 + sizes.hPadding, sizes.hPadding/2)
				end
			},
		}
	end

	local f = Def.ActorFrame{
		OnCommand = function(self)
			MESSAGEMAN:Broadcast('UpdateLeaderboardScorePage', {page = util.curPage})
		end
	}
	local _list_0 = util.allTheScores[util.curRate]
	local _max_0 = util.pageSize * (util.curPage)
	for _index_0 = (util.pageSize * (util.curPage - 1)) + 1, _max_0 < 0 and #_list_0 + _max_0 or _max_0 do
		local scoreObject = _list_0[_index_0]
		if scoreObject then
			local page = util.curPage
			if not f[page] then f[page] = Def.ActorFrame{} end
			f[page][#f[page]+1] = s(_index_0, page)
		end
	end

--[[	for i = 1,#util.allTheScores[util.curRate] do
		local page = math.floor((i-1)/pageLimit) + 1
		if not f[page] then f[page] = Def.ActorFrame{} end
		f[page][#f[page]+1] = s(i, page)
	end
--]]

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
	util = util
})

t[#t+1] = LoadActorWithParams('leaderboard.lua', {
	sizes = sizes,
	stageStats = stageStats,
	util = util
})


return t