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

	wheel = {
		w = 460,
		h = sh,
		x = 890,
		songPanel = {
			w = 460 ,
			h = 70
		},
		bannerIcon = {
			w = 140,
			h = 70
		},
	},

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
	},

	tab = {
		w = 40,
		h = 14,
	}
}

sizes.tab.vPadding = sizes.scoreContainer.h/2 - sizes.tab.h/2 - sizes.hPadding

local util = {
	tab = {}
}
util.tab.buttons = {
	{'General'},
	{'Scores'},
	{'Goals'},
	{'Search'},
	{'Playlists'},
	{'Tags'},
}
util.tab.curSelected = util.tab.buttons[1][1]

util.makeTabs = function()
	local f = Def.ActorFrame{
		OnCommand = function(self) self:playcommand('Check') end,
		TabSelectedMessageCommand = function(self, params)
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
				txt:maxwidth((sizes.tab.w*2)+50)
				txt:zoom(FONTSIZE.small)
				local s = #util.tab.buttons-1 -- fuck you lua
				self:x( (sizes.tab.w/2) + (sizes.hPadding) + ((sizes.scoreContainer.w - sizes.tab.w - sizes.hPadding*2) / s) * (i-1) )
			end,
			OnCommand = function(self)
				MESSAGEMAN:Broadcast('TabSelected', {name = util.tab.curSelected, index = 1})
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
				end
			end
		}
	end
	for i = 1,#util.tab.buttons do
		f[#f+1] = tab(i)
	end
	return f
end

t[#t+1] = LoadActorWithParams('wheel', {
	sizes = sizes,
	util = util
})

t[#t+1] = LoadActorWithParams('main.lua', {
	sizes = sizes,
	stageStats = stageStats,
	util = util
})

t[#t+1] = LoadActorWithParams('banner.lua', {
	sizes = sizes,
	stageStats = stageStats,
	util = util
})

t[#t+1] = LoadActorWithParams('tab_general.lua', {
	sizes = sizes,
	stageStats = stageStats,
	util = util
})

t[#t+1] = LoadActorWithParams('tab_scores.lua', {
	sizes = sizes,
	stageStats = stageStats,
	util = util
})

t[#t+1] = LoadActorWithParams('tab_goals.lua', {
	sizes = sizes,
	stageStats = stageStats,
	util = util
})

t[#t+1] = LoadActorWithParams('tab_search.lua', {
	sizes = sizes,
	stageStats = stageStats,
	util = util
})

t[#t+1] = LoadActorWithParams('tab_playlists.lua', {
	sizes = sizes,
	stageStats = stageStats,
	util = util
})

t[#t+1] = LoadActorWithParams('tab_tags.lua', {
	sizes = sizes,
	stageStats = stageStats,
	util = util
})





--t[#t + 1] = LoadActor("../_mousewheelscroll")
collectgarbage()
return t