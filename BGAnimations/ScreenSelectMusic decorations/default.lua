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
	},

	tab = {
		w = 40,
		h = 14
	}
}

local util = {
	tab = {}
}
util.tab.buttons = {
	{'General'},
	{'Scores'},
	{'Goals'},
	{'Search'},
	{'Profile'},
	{'Tags'},
}
util.tab.curSelected = util.tab.buttons[1][1]

util.makeTabs = function()
	local f = Def.ActorFrame{
		OnCommand = function(self) self:playcommand('Check') end,
		CheckCommand = function(self)
			for k,v in pairs(self:GetChildren()) do
				if v:GetName() == util.tab.curSelected then
					v:playcommand('GainFocus')
				else
					v:playcommand('LoseFocus')
				end
			end
		end
	}
	local tab = function(i)
		return UIElements.TextButton(1, 1, 'Common Normal') .. {
			Name = util.tab.buttons[i][1],
			InitCommand = function(self)
				local txt,bg = self:GetChild('Text'), self:GetChild('BG')
				bg:setsize(sizes.tab.w, sizes.tab.h)
				txt:settext(self:GetName())
				txt:maxwidth(sizes.tab.w*2)
				txt:zoom(FONTSIZE.small)
				local s = #util.tab.buttons-1 -- fuck you lua
				self:x( (sizes.tab.w/2) + (sizes.hPadding) + ((sizes.scoreContainer.w - sizes.tab.w - sizes.hPadding*2) / s) * (i-1) )
			end,
			GainFocusCommand = function(self)
				local txt,bg = self:GetChild('Text'), self:GetChild('BG')
				txt:finishtweening():smooth(0.1):diffusealpha(1)
			end,
			LoseFocusCommand = function(self)
				local txt,bg = self:GetChild('Text'), self:GetChild('BG')
				txt:finishtweening():smooth(0.1):diffusealpha(0.6)
			end,
			RolloverUpdateCommand = function(self, params)
				if params.update == 'in' then
					self:playcommand('GainFocus')
				elseif params.update == 'out' then
					if util.tab.curSelected ~= util.tab.buttons[i][1] then
						self:playcommand('LoseFocus')
					end
				end
			end,
			ClickCommand = function(self, params)
				if params.update == 'OnMouseDown' then
					util.tab.curSelected = self:GetName()
					MESSAGEMAN:Broadcast('TabSelected', {name = self:GetName(), index = i})
					self:GetParent():playcommand('Check')
				end
			end
		}
	end
	for i = 1,#util.tab.buttons do
		f[#f+1] = tab(i)
	end
	return f
end


t[#t+1] = LoadActorWithParams('banner.lua', {
	sizes = sizes,
	stageStats = stageStats,
})

t[#t+1] = LoadActorWithParams('main.lua', {
	sizes = sizes,
	stageStats = stageStats,
	util = util
})




t[#t + 1] = LoadActor("../_mousewheelscroll")
collectgarbage()
return t