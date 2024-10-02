local sizes = Var('sizes')
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
	WheelSettledMessageCommand = function(self, params)
		self:playcommand('UpdateMe', {highscore = GetDisplayScore(), selection = params})
	end
}

local statNames = {
	THEME:GetString("RadarCategory", "Notes"),
	THEME:GetString("RadarCategory", "Jumps"),
	THEME:GetString("RadarCategory", "Hands"),
	THEME:GetString("RadarCategory", "Holds"),
	THEME:GetString("RadarCategory", "Rolls"),
	THEME:GetString("RadarCategory", "Mines"),
}

-- output of the relevant radars function is in a certain order
-- it isnt the order of the above list
-- so this list takes those indices and points them in another direction
local statMapping = {
	   -- output -> desired
	1, -- notes - notes
	2, -- jumps - jumps
	3, -- hands - hands
	4, -- holds - holds
	6, -- mines - rolls
	5, -- rolls - mines
	7, -- lifts
	8, -- fakes
}

local makeChartStats = function()
	local a = function(i)
		return Def.ActorFrame {
			Name = 'stat'..i,
			InitCommand = function(self)
				self:y(20*(i-1))
			end,
			LoadSizedFont('small') .. {
				Name = 'label',
				InitCommand = function(self)
					self:halign(0)
					self:settext(statNames[i])
				end
			},
			LoadSizedFont('small') .. {
				Name = 'count',
				InitCommand = function(self)
					self:halign(1)
					self:x(140 - sizes.hPadding*2)
				end,
				UpdateMeCommand = function(self, params)
					if params.selection.song then
						self:settext(params.selection.steps:GetRelevantRadars()[statMapping[i]])
					else
						self:settext(0)
					end
				end
			},
		}
	end
	local t = Def.ActorFrame{ Name = 'chartStats' }
	for i = 1, #statNames do
		t[#t+1] = a(i)
	end
	return t
end


t[#t+1] = Def.ActorFrame {
	Name = 'topScore',
	Def.ActorFrame {
		Name = 'percentageFrame',
		InitCommand = function(self)
			self:RunCommandsOnChildren(function(self)
				self:xy(-sizes.scoreContainer.w/2 + sizes.hPadding, -sizes.scoreContainer.h/2 + sizes.vPadding/2)
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
				self:playcommand('UpdateMe', {highscore = GetDisplayScore()})
			end,
			UpdateMeCommand = function(self, params)
				if params.highscore then
					local wife = params.highscore:GetWifeScore()
					local p = checkWifeStr(wife)
					local grade = THEME:GetString("Grade", ToEnumShortString(GetGradeFromPercent(wife)))
					self:settextf('%s %s', grade, p)
					self:diffuse(colorByGrade(params.highscore:GetWifeGrade()))
				else
					self:settext('No Score')
					self:diffuse(0.5,0.5,0.5,1)
				end
			end,
			ModifyCommand = function(self, params)
				if util.tab.curSelected == 'General' then
				end
			end
		},
	},
	Def.ActorFrame {
		Name = 'songStuff',
		InitCommand = function(self)
			self:xy( -(sizes.scoreContainer.w/2) + sizes.hPadding, (-sizes.scoreContainer.h/2) + sizes.vPadding + 40)
			self:RunCommandsOnChildren(function(self)
				self:halign(0):valign(0)
			end)
		end,
		LoadSizedFont('small') .. {
			Name = 'clearTypeAndDate',
			UpdateMeCommand = function(self, params)
				if params.highscore then
					local ct = getClearTypeFromScore(params.highscore, 0)
					local date = params.highscore:GetDate()
					self:settextf('%s %s', ct, date)
					self:ClearAttributes()
					self:AddAttribute(0, {Length = #string.format('%s', ct), Diffuse = getClearTypeFromScore(params.highscore, 2)})
				else
					self:ClearAttributes()
					self:settext('')
				end
			end,
		},
	},
	Def.ActorFrame {
		Name = 'stepsAndCDTitle',
		Def.Sprite {
			Name = 'CDTitle',
			UpdateMeCommand = function(self, params)
				if params.selection.song then
					if params.selection.song:HasCDTitle() then
						self:Load(params.selection.song:GetCDTitlePath())
						self:scaletofit(0, -sizes.cdtitle, sizes.cdtitle, 0)
						return
					end
				end
				self:Load(THEME:GetPathG("", "_blank"))
			end
		},
		makeDivider {y = -270} .. {
			OnCommand = function(self)
				self:xy(sizes.scoreContainer.w/5, 
					(sizes.scoreContainer.h/2) - (sizes.tab.h*3) - sizes.vPadding*2
				)
			end
		},
	},
	makeChartStats() .. {
		OnCommand = function(self)
			self:x((sizes.scoreContainer.w/2) - 140 + sizes.hPadding)
		end
	}
}


return t