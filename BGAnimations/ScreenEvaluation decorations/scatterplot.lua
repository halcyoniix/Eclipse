local sizes = Var('sizes')
local stageStats = Var('stageStats')
local util = Var('util')

local t = Def.ActorFrame{
	InitCommand = function(self)
		self:xy(sizes.scatterplotContainer.x, sizes.scatterplotContainer.y)
	end,
	Def.Quad {
		Name = 'bg',
		InitCommand = function(self)
			self:setsize(sizes.scatterplotContainer.w + sizes.border, sizes.scatterplotContainer.h + sizes.border)
			self:diffuse(0.1,0.1,0.1,1)
		end
	},
}

t[#t+1] = LoadActorWithParams("../_offsetplot.lua", {sizing = {Width = sizes.scatterplotContainer.w, Height = sizes.scatterplotContainer.h - sizes.vPadding*4}, extraFeatures = true, textsize = FONTSIZE.header}) .. {
	Name = 'offsetPlot',
	InitCommand = function(self)
		self:xy(-sizes.scatterplotContainer.w/2, -(sizes.scatterplotContainer.h/2) + sizes.vPadding*2 )
		self:queuecommand('Set', {score = stageStats.score})
	end,
	SelectedEvalScoreMessageCommand = function(self, params)
		self:playcommand('Set', params)
	end,
	SetCommand = function(self, params)
		if stageStats.score ~= nil and stageStats.steps ~= nil then
			if stageStats.score:HasReplayData() then
				local offsets = stageStats.score:GetOffsetVector()
				-- for online offset vectors a 180 offset is a miss
				for i, o in ipairs(offsets) do
					if o >= 180 then
						offsets[i] = 1000
					end
				end

				self:playcommand("LoadOffsets", {
					offsetVector = offsets,
					trackVector = stageStats.score:GetTrackVector(),
					timingData = stageStats.steps:GetTimingData(),
					noteRowVector = stageStats.score:GetNoteRowVector(),
					typeVector = stageStats.score:GetTapNoteTypeVector(),
					holdVector = stageStats.score:GetHoldNoteVector(),
					maxTime = stageStats.steps:GetLastSecond(),
					judgeSetting = stageStats.judgeSetting,
					columns = stageStats.steps:GetNumColumns(),
					rejudged = stageStats.rejudged,
				})
			end
		end
	end
}

return t