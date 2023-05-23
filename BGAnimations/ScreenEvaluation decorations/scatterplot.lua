local sizes = Var('sizes')
local stageStats = Var('stageStats')
local util = Var('util')
local pss = STATSMAN:GetCurStageStats():GetPlayerStageStats()
local judgeSetting = (PREFSMAN:GetPreference("SortBySSRNormPercent") and 4 or GetTimingDifficulty())
local usingCustomWindows = false

local t = Def.ActorFrame{
	InitCommand = function(self)
		self:xy(sizes.scatterplotContainer.x, sizes.scatterplotContainer.y)
	end,
	OnCommand = function(self)
		local score = SCOREMAN:GetMostRecentScore() or SCOREMAN:GetTempReplayScore()

		-- use this to force J4 init for SSRNorm
		local forcedScreenEntryJudgeWindow = nil
		if PREFSMAN:GetPreference("SortBySSRNormPercent") then
			forcedScreenEntryJudgeWindow = 4
		end

		SCREENMAN:GetTopScreen():RescoreReplay(pss, ms.JudgeScalers[forcedScreenEntryJudgeWindow or judgeSetting], score, usingCustomWindows and currentCustomWindowConfigUsesOldestNoteFirst())

		self:playcommand("Set", {
			song = GAMESTATE:GetCurrentSong(),
			steps = GAMESTATE:GetCurrentSteps(),
			score = score,
			judgeSetting = forcedScreenEntryJudgeWindow
		})
	end,
	Def.Quad {
		Name = 'bg',
		InitCommand = function(self)
			self:setsize(sizes.scatterplotContainer.w + sizes.border, sizes.scatterplotContainer.h + sizes.border)
			self:diffuse(0.1,0.1,0.1,1)
		end
	},
	LoadActorWithParams("../_offsetplot.lua", {sizing = {Width = sizes.scatterplotContainer.w, Height = sizes.scatterplotContainer.h}, extraFeatures = true, textsize = FONTSIZE.small}) .. {
		Name = 'offsetPlot',
		InitCommand = function(self)
			self:xy(-sizes.scatterplotContainer.w/2, -(sizes.scatterplotContainer.h/2))
		end,
		SelectedEvalScoreMessageCommand = function(self, params)
			self:playcommand('Set', params)
		end,
		SetCommand = function(self, params)
			--ms.ok(params)
			if params.score ~= nil and params.steps ~= nil then
				if params.score:HasReplayData() then
					local replay = REPLAYS:GetActiveReplay()
					local offsets = usingCustomWindows and replay:GetOffsetVector() or params.score:GetOffsetVector()
					-- for online offset vectors a 180 offset is a miss
					for i, o in ipairs(offsets) do
						if o >= 180 then
							offsets[i] = 1000
						end
					end
					local tracks = usingCustomWindows and replay:GetTrackVector() or params.score:GetTrackVector()
					local types = usingCustomWindows and replay:GetTapNoteTypeVector() or params.score:GetTapNoteTypeVector()
					local noterows = usingCustomWindows and replay:GetNoteRowVector() or params.score:GetNoteRowVector()
					local holds = usingCustomWindows and replay:GetHoldNoteVector() or params.score:GetHoldNoteVector()
					local timingdata = params.steps:GetTimingData()
					local lastSecond = params.steps:GetLastSecond()

					self:playcommand("LoadOffsets", {
						offsetVector = offsets,
						trackVector = tracks,
						timingData = timingdata,
						noteRowVector = noterows,
						typeVector = types,
						holdVector = holds,
						maxTime = lastSecond,
						judgeSetting = params.judgeSetting,
						columns = params.steps:GetNumColumns(),
						rejudged = params.rejudged,
						usingCustomWindows = usingCustomWindows,
					})
				end
			end
		end
	}
}

return t