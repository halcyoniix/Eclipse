local sizes = Var('sizes')
local stageStats = Var('stageStats')

local t = Def.ActorFrame{
	InitCommand = function(self)
		self:xy(sizes.scatterplotContainer.x, sizes.scatterplotContainer.y)
	end,
	Def.Quad {
		Name = 'bg',
		InitCommand = function(self)
			self:zoomto(sizes.scatterplotContainer.w + sizes.border, sizes.scatterplotContainer.h + sizes.border)
			self:diffuse(0.1,0.1,0.1,1)
		end
	},
}


t[#t+1] = LoadActorWithParams("../_offsetplot.lua", {sizing = {Width = sizes.scatterplotContainer.w, Height = sizes.scatterplotContainer.h - sizes.vPadding*4}, extraFeatures = true, textsize = FONTSIZE.header}) .. {
	Name = 'offsetPlot',
	InitCommand = function(self)
		self:xy(-sizes.scatterplotContainer.w/2, -(sizes.scatterplotContainer.h/2) + sizes.vPadding*2 )
	end,
	OnCommand = function(self)
		if stageStats.score ~= nil and stageStats.steps ~= nil then
			if stageStats.score:HasReplayData() then
				local offsets = stageStats.score:GetOffsetVector()
				-- for online offset vectors a 180 offset is a miss
				for i, o in ipairs(offsets) do
					if o >= 180 then
						offsets[i] = 1000
					end
				end
				local tracks = stageStats.score:GetTrackVector()
				local types = stageStats.score:GetTapNoteTypeVector()
				local noterows = stageStats.score:GetNoteRowVector()
				local holds = stageStats.score:GetHoldNoteVector()
				local timingdata = stageStats.steps:GetTimingData()
				local lastSecond = stageStats.steps:GetLastSecond()

				self:playcommand("LoadOffsets", {
					offsetVector = offsets,
					trackVector = tracks,
					timingData = timingdata,
					noteRowVector = noterows,
					typeVector = types,
					holdVector = holds,
					maxTime = lastSecond,
					judgeSetting = stageStats.judgeSetting,
					columns = stageStats.steps:GetNumColumns(),
					rejudged = stageStats.rejudged,
				})
			end
		end
	end
}

return t