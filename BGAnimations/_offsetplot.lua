local sizing = Var("sizing") -- specify init sizing
if sizing == nil then sizing = {} end
local extraFeatures = Var("extraFeatures") -- toggle offset hovering and input events for highlighting
if extraFeatures == nil then extraFeatures = false end
--[[
	We are expecting the sizing table to be provided on file load.
	It should contain these attributes:
	Width
	Height
]]
-- all elements are placed relative to default valign - 0 halign
-- this means relatively to center vertically and relative to the left end horizontally

local judgeSetting = (PREFSMAN:GetPreference("SortBySSRNormPercent") and 4 or GetTimingDifficulty())
local timingScale = ms.JudgeScalers[judgeSetting]

-- cap the graph to this
local maxOffset = 180
local lineThickness = 1
local lineAlpha = 0.2
local textPadding = 5
local textSize = Var("textsize") or 0.65
local instructionTextSize = 0.55

local dotAnimationSeconds = 0.4
local resizeAnimationSeconds = 0.1
local unHighlightedAlpha = 0

-- the dot sizes
-- the "classic" default is 1.0
local dotLineLength = 04
local dotLineUpperBound = 0.6
local dotLineLowerBound = 0.5
-- length of the dot lines for the mine X
local mineXSize = 3
local mineXThickness = 1

-- judgment windows to display on the plot
local barJudgments = {
	"TapNoteScore_W2",
	"TapNoteScore_W3",
	"TapNoteScore_W4",
	"TapNoteScore_W5",
}

-- tracking the index of dot highlighting for each column
local highlightIndex = 1
-- each index corresponds to a type of column setup to highlight
local highlightTable = {}

local function columnIsHighlighted(column)
	return column == nil or #highlightTable == 0 or highlightTable[highlightIndex][column] == true
end

-- allow moving the highlightIndex in either direction and loop around if under/overflow
local function moveHighlightIndex(direction)
	local newg = (((highlightIndex) + direction) % (#highlightTable + 1))
	if newg == 0 then
		newg = direction > 0 and 1 or #highlightTable
	end
	highlightIndex = newg
end

local function getMineColor(column)
	local mineColor = COLORS:getColor("offsetPlot", "MineHit")
	-- cant highlight or currently set to highlight this column
	if columnIsHighlighted(column) then
		return mineColor
	else
		-- not highlighting this column
		local c = {}
		for i,v in ipairs(mineColor) do
			c[i] = v
		end
		c[4] = unHighlightedAlpha
		return c
	end
end

local function getHoldColor(column, type)
	local color = color("#FFFFFF")
	if type == "TapNoteSubType_Roll" then
		color = COLORS:getColor("offsetPlot", "RollDrop")
	elseif type == "TapNoteSubType_Hold" then
		color = COLORS:getColor("offsetPlot", "HoldDrop")
	end

	-- cant highlight or currently set to highlight this column
	if columnIsHighlighted(column) then
		return color
	else
		-- not highlighting this column
		local c = {}
		for i,v in ipairs(color) do
			c[i] = v
		end
		c[4] = unHighlightedAlpha
		return c
	end
end

-- produces the highlightTable in the format:
-- { {x,y,z...}, {x,y,z...} ... } where each subtable is a list of columns to highlight, the keys are the columns
local function calcDotHighlightTable(tracks, columns)
	local out = {}
	if tracks ~= nil and #tracks ~= 0 then
		-- all columns
		out = {{}}
		for i = 1, columns do
			out[1][i] = true
		end

		if columns % 2 == 0 then
			out[#out+1] = {}
			out[#out+1] = {}
			-- even columns, 1 per hand
			for i = 1, columns / 2 do
				out[2][i] = true
			end
			for i = columns / 2 + 1, columns do
				out[3][i] = true
			end

		else
			out[#out+1] = {}
			out[#out+1] = {}
			out[#out+1] = {}
			-- odd columns, 1 left - 1 middle - 1 right
			for i = 1, math.floor(columns / 2) do
				out[2][i] = true
			end
			out[3][math.ceil(columns / 2)] = true
			for i = math.ceil(columns / 2) + 1, columns do
				out[4][i] = true
			end
		end
		-- add single highlights for each column
		for i = 1, columns do
			out[#out+1] = {[i] = true}
		end
	end
	return out
end

-- convert number to another number out of a given width
-- relative to left side of the graph
local function fitX(x, maxX)
	-- dont let the x go way off the end of the graph
	x = clamp(x, x, maxX)
	return x / maxX * sizing.Width
end

-- convert millisecond values to a y position in the graph
-- relative to vertical center
local function fitY(y, maxY)
	return -1 * y / maxY * sizing.Height / 2 + sizing.Height / 2
end

-- 4 xyz coordinates are given to make up the 4 corners of a quad to draw
local function placeDotVertices(vertList, x, y, color)
	vertList[#vertList + 1] = {{x - dotLineLength, y + dotLineLength, 0}, color}
	vertList[#vertList + 1] = {{x + dotLineLength, y + dotLineLength, 0}, color}
	vertList[#vertList + 1] = {{x + dotLineLength, y - dotLineLength, 0}, color}
	vertList[#vertList + 1] = {{x - dotLineLength, y - dotLineLength, 0}, color}
end

-- 2 pairs of 4 coordinates to draw a big X
local function placeMineVertices(vertList, x, y, color)
	vertList[#vertList + 1] = {{x - mineXSize - mineXThickness / 2, y - mineXSize, 0}, color}
	vertList[#vertList + 1] = {{x + mineXSize - mineXThickness / 2, y + mineXSize, 0}, color}
	vertList[#vertList + 1] = {{x - mineXSize + mineXThickness / 2, y - mineXSize, 0}, color}
	vertList[#vertList + 1] = {{x + mineXSize + mineXThickness / 2, y + mineXSize, 0}, color}

	vertList[#vertList + 1] = {{x + mineXSize + mineXThickness / 2, y - mineXSize, 0}, color}
	vertList[#vertList + 1] = {{x - mineXSize + mineXThickness / 2, y + mineXSize, 0}, color}
	vertList[#vertList + 1] = {{x + mineXSize - mineXThickness / 2, y - mineXSize, 0}, color}
	vertList[#vertList + 1] = {{x - mineXSize - mineXThickness / 2, y + mineXSize, 0}, color}
end

-- 2 pairs of 4 coordinates to draw a ^
local function placeNoodleVertices(vertList, x, y, color)
	vertList[#vertList + 1] = {{x - mineXThickness / 2, y + mineXSize, 0}, color}
	vertList[#vertList + 1] = {{x + mineXThickness / 2, y, 0}, color}
	vertList[#vertList + 1] = {{x + mineXThickness / 2, y + mineXSize, 0}, color}
	vertList[#vertList + 1] = {{x - mineXThickness / 2, y, 0}, color}
end

local t = Def.ActorFrame {
	Name = "OffsetPlotFile",
	InitCommand = function(self)
		local hid = false
		if not extraFeatures then return end -- no extra features: dont add the hover
		self:SetUpdateFunction(function()
			local bg = self:GetChild("BG")
			if isOver(bg) then
				local top = SCREENMAN:GetTopScreen()
				-- dont break if it will break (we can only do this from the eval screen)
				if not top.GetReplaySnapshotJudgmentsForNoterow or not top.GetReplaySnapshotWifePercentForNoterow then
					return
				end

				TOOLTIP:Show()

				local x, y = bg:GetLocalMousePos(INPUTFILTER:GetMouseX(), INPUTFILTER:GetMouseY(), 0)
				local percent = clamp(x / bg:GetZoomedWidth(), 0, 1)
				-- 48 rows per beat, multiply the current beat by 48 to get the current row
				local td = GAMESTATE:GetCurrentSteps():GetTimingData()
				local lastsec = GAMESTATE:GetCurrentSteps():GetLastSecond()
				local row = td:GetBeatFromElapsedTime(percent * lastsec) * 48

				local judgments = top:GetReplaySnapshotJudgmentsForNoterow(row)
				local wifescore = top:GetReplaySnapshotWifePercentForNoterow(row) * 100
				local time = SecondsToHHMMSS(td:GetElapsedTimeFromNoteRow(row))
				local mean = top:GetReplaySnapshotMeanForNoterow(row)
				local sd = top:GetReplaySnapshotSDForNoterow(row)

				local marvCount = judgments[10]
				local perfCount = judgments[9]
				local greatCount = judgments[8]
				local goodCount = judgments[7]
				local badCount = judgments[6]
				local missCount = judgments[5]

				-- excessively long string format for translation support
				--[[local txt = string.format(
					"%5.6f%%\n%s: %d\n%s: %d\n%s: %d\n%s: %d\n%s: %d\n%s: %d\n%s: %0.2fms\n%s: %0.2fms\n%s: %s",
					wifescore,
					"Marvelous", marvCount,
					"Perfect", perfCount,
					"Great", greatCount,
					"Good", goodCount,
					"Bad", badCount,
					"Miss", missCount,
					"Std. Dev", sd,
					"Mean", mean,
					"Time", time
				)--]]

				local txt = string.format(
					'%5.6f%%\n%s - %s - %s - %s - %s - %s\nStd Dev: %0.2fms\nMean: %0.2fms\nTime: %s',
					wifescore,
					marvCount,
					perfCount,
					greatCount,
					goodCount,
					badCount,
					missCount,
					sd,
					mean,
					time
					)

				local mp = self:GetChild("MousePosition")
				mp:visible(true)
				mp:x(x)
				TOOLTIP:SetText(txt)
				hid = false
			else
				if not hid then
					self:GetChild("MousePosition"):visible(false)
					TOOLTIP:Hide()
					hid = true
				end
			end
		end)
	end,
	BeginCommand = function(self)
		if not extraFeatures then return end -- no extra features: dont add the input highlight
		SCREENMAN:GetTopScreen():AddInputCallback(function(event)
			if #highlightTable ~= 0 then
				if event.type == "InputEventType_FirstPress" then
					if event.button == "MenuDown" or event.button == "Down" then
						moveHighlightIndex(1)
						self:playcommand("DrawOffsets")
						self:hurrytweening(0.2)
					elseif event.button == "MenuUp" or event.button == "Up" then
						moveHighlightIndex(-1)
						self:playcommand("DrawOffsets")
						self:hurrytweening(0.2)
					end
				end
			end
		end)
	end,
	UpdateSizingCommand = function(self, params)
		if params.sizing ~= nil then
			sizing = params.sizing
		end
		if params.judgeSetting ~= nil then
			judgeSetting = params.judgeSetting
			timingScale = ms.JudgeScalers[judgeSetting]
		end
	end
}

t[#t+1] = Def.Quad {
	Name = "BG",
	InitCommand = function(self)
		self:halign(0)
		self:diffusealpha(0)
		registerActorToColorConfigElement(self, "offsetPlot", "Background")
		self:playcommand("UpdateSizing")
		self:finishtweening()
	end,
	UpdateSizingCommand = function(self)
		self:finishtweening()
		self:smooth(resizeAnimationSeconds)
		self:y(sizing.Height / 2)
		self:zoomto(sizing.Width, sizing.Height)
	end
}

if extraFeatures then
	t[#t+1] = Def.Quad {
		Name = "MousePosition",
		InitCommand = function(self)
			self:valign(0)
			self:diffusealpha(1)
			registerActorToColorConfigElement(self, "offsetPlot", "HoverLine")
			self:zoomx(lineThickness)
			self:playcommand("UpdateSizing")
			self:finishtweening()
		end,
		UpdateSizingCommand = function(self)
			self:finishtweening()
			self:smooth(resizeAnimationSeconds)
			self:zoomy(sizing.Height)
		end
	}
end

t[#t+1] = Def.Quad {
	Name = "CenterLine",
	InitCommand = function(self)
		self:halign(0)
		self:diffusealpha(lineAlpha)
		registerActorToColorConfigElement(self, "judgment", "TapNoteScore_W1")
		self:playcommand("UpdateSizing")
		self:finishtweening()
	end,
	UpdateSizingCommand = function(self)
		self:finishtweening()
		self:smooth(resizeAnimationSeconds)
		self:y(sizing.Height / 2)
		self:zoomto(sizing.Width, lineThickness)
	end
}

for i, j in ipairs(barJudgments) do
	t[#t+1] = Def.Quad {
		Name = j.."_Late",
		InitCommand = function(self)
			self:halign(0)
			self:diffusealpha(lineAlpha)
			registerActorToColorConfigElement(self, "judgment", j)
			self:playcommand("UpdateSizing")
			self:finishtweening()
		end,
		UpdateSizingCommand = function(self)
			self:finishtweening()
			self:smooth(resizeAnimationSeconds)
			local window = ms.getLowerWindowForJudgment(j, timingScale)
			self:y(fitY(window, maxOffset))
			self:zoomto(sizing.Width, lineThickness)
		end
	}
	t[#t+1] = Def.Quad {
		Name = j.."_Early",
		InitCommand = function(self)
			self:halign(0)
			self:diffusealpha(lineAlpha)
			registerActorToColorConfigElement(self, "judgment", j)
			self:playcommand("UpdateSizing")
			self:finishtweening()
		end,
		UpdateSizingCommand = function(self)
			self:finishtweening()
			self:smooth(resizeAnimationSeconds)
			local window = ms.getLowerWindowForJudgment(j, timingScale)
			self:y(fitY(-window, maxOffset))
			self:zoomto(sizing.Width, lineThickness)
		end
	}
end

t[#t+1] = LoadSizedFont("small") .. {
	Name = "LateText",
	InitCommand = function(self)
		self:halign(0):valign(0)
		--self:zoom(textSize)
		registerActorToColorConfigElement(self, "offsetPlot", "Text")
		self:playcommand("UpdateSizing")
		self:finishtweening()
	end,
	UpdateSizingCommand = function(self)
		self:finishtweening()
		self:smooth(resizeAnimationSeconds)
		local bound = ms.getUpperWindowForJudgment(barJudgments[#barJudgments], timingScale)
		self:xy(textPadding, textPadding)
		self:addy(-textPadding*3)
		self:settextf("Late (+%dms)", bound)
	end
}

t[#t+1] = LoadSizedFont("small") .. {
	Name = "EarlyText",
	InitCommand = function(self)
		self:halign(0):valign(1)
		--self:zoom(textSize)
		registerActorToColorConfigElement(self, "offsetPlot", "Text")
		self:playcommand("UpdateSizing")
		self:finishtweening()
	end,
	UpdateSizingCommand = function(self)
		self:finishtweening()
		self:smooth(resizeAnimationSeconds)
		local bound = ms.getUpperWindowForJudgment(barJudgments[#barJudgments], timingScale)
		self:xy(textPadding, sizing.Height - textPadding)
		self:addy(textPadding*3)
		self:settextf("Early (-%dms)", bound)
	end
}

t[#t+1] = LoadSizedFont("small") .. {
	Name = "InstructionText",
	InitCommand = function(self)
		self:valign(1)
		--self:zoom(instructionTextSize)
		self:settext("")
		registerActorToColorConfigElement(self, "offsetPlot", "Text")
		self:playcommand("UpdateSizing")
		self:finishtweening()
	end,
	UpdateSizingCommand = function(self)
		self:finishtweening()
		self:halign(1)
		self:smooth(resizeAnimationSeconds)
		self:xy(sizing.Width - textPadding, sizing.Height - textPadding)
		self:addy(textPadding*3)
		self:maxwidth((sizing.Width - self:GetParent():GetChild("EarlyText"):GetZoomedWidth()) / instructionTextSize - textPadding)
	end,
	UpdateTextCommand = function(self)
		local cols = {}
		local shit = {'[All]','[Left Hand]','[Right Hand]','[Left]','[Down]','[Up]','[Right]'}
		if #highlightTable == 0 or highlightTable[highlightIndex] == nil or not extraFeatures then
			self:settext("")
		else
			for col, _ in pairs(highlightTable[highlightIndex]) do
				cols[#cols+1] = col
				cols[#cols+1] = " "
			end
			cols[#cols] = nil
			cols = table.concat(cols)
			self:settextf("Press [UP/DOWN] to toggle highlights %s", shit[highlightIndex])
		end
	end
}

-- keeping track of stuff for persistence dont look at this
local lastOffsets = {}
local lastTracks = {}
local lastTiming = {}
local lastTimingData = nil
local lastTypes = {}
local lastHolds = {}
local lastMaxTime = 0
local lastColumns = nil

t[#t+1] = Def.ActorMultiVertex {
	Name = "Dots",
	InitCommand = function(self)
		--self:zoomto(0, 0)
		self:playcommand("UpdateSizing")
	end,
	UpdateSizingCommand = function(self)

	end,
	ColorConfigUpdatedMessageCommand = function(self)
		self:finishtweening()
		self:linear(0.5)
		self:queuecommand("DrawOffsets")
	end,
	LoadOffsetsCommand = function(self, params)
		-- makes sure all sizes are updated
		self:GetParent():playcommand("UpdateSizing", params)

		lastOffsets = params.offsetVector
		lastTracks = params.trackVector
		lastTimingData = params.timingData
		lastTypes = params.typeVector
		lastHolds = params.holdVector
		lastTiming = {}
		for i, row in ipairs(params.noteRowVector) do
			lastTiming[i] = lastTimingData:GetElapsedTimeFromNoteRow(row)
		end

		lastMaxTime = params.maxTime
		lastColumns = params.columns
		if not params.rejudged then
			highlightTable = calcDotHighlightTable(lastTracks, lastColumns)
			highlightIndex = 1
		end

		-- draw dots
		self:playcommand("DrawOffsets")
	end,
	DrawOffsetsCommand = function(self)
		local vertices = {}
		local offsets = lastOffsets
		local tracks = lastTracks
		local timing = lastTiming
		local types = lastTypes
		local holds = lastHolds
		local maxTime = lastMaxTime
		self:GetParent():playcommand("UpdateText")

		if offsets == nil or #offsets == 0 then
			self:SetVertices(vertices)
			self:SetDrawState {Mode = "DrawMode_Quads", First = 1, Num = 0}
			return
		end

		-- dynamically change the dot size depending on the number of dots
		-- for clarity on ultra dense scores
		dotLineLength = clamp(scale(#offsets, 1000, 5000, dotLineUpperBound, dotLineLowerBound), dotLineLowerBound, dotLineUpperBound)

		-- taps and mines
		for i, offset in ipairs(offsets) do
			local x = fitX(timing[i], maxTime)
			local y = fitY(offset, maxOffset)
			local column = tracks ~= nil and tracks[i] ~= nil and tracks[i] + 1 or nil

			local cappedY = math.max(maxOffset, (maxOffset) * timingScale)
			if y < 0 or y > sizing.Height then
				y = fitY(cappedY, maxOffset)
			end


			if types[i] ~= "TapNoteType_Mine" then
				-- handle highlighting logic
				local dotColor = colorByTapOffset(offset, timingScale)
				if not columnIsHighlighted(column) then
					dotColor[4] = unHighlightedAlpha
				end
				placeDotVertices(vertices, x, y, dotColor)
			else
				-- this function handles the highlight logic
				local mineColor = getMineColor(column)
				placeMineVertices(vertices, x, fitY(-maxOffset, maxOffset), mineColor)
			end
		end

		-- holds and rolls
		--[[
		if holds ~= nil and #holds > 0 then
			for i, h in ipairs(holds) do
				local row = h.row
				local holdtype = h.TapNoteSubType
				local column = h.track + 1
				local holdColor = getHoldColor(column, holdtype)
				local rowtime = lastTimingData:GetElapsedTimeFromNoteRow(row) 
				local x = fitX(rowtime, maxTime)
				placeNoodleVertices(vertices, x, fitY(-maxOffset, maxOffset), holdColor)
			end
		end
		]]

		-- animation breaks if we start from nothing
		if self:GetNumVertices() ~= 0 then
			self:finishtweening()
			self:smooth(dotAnimationSeconds)
		end
		self:SetVertices(vertices)
		self:SetDrawState {Mode = "DrawMode_Quads", First = 1, Num = #vertices}
	end
}



return t