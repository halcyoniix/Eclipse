local t = Def.ActorFrame{}
local stageStats = {
	song = GAMESTATE:GetCurrentSong(),
	steps = GAMESTATE:GetCurrentSteps(),
	score = SCOREMAN:GetMostRecentScore() or SCOREMAN:GetTempReplayScore(),
	pss = STATSMAN:GetCurStageStats():GetPlayerStageStats(),
	judgeSetting = forcedScreenEntryJudgeWindow
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



t[#t+1] = LoadActorWithParams('banner.lua', {
	sizes = sizes,
	stageStats = stageStats,
})

t[#t+1] = LoadActorWithParams('main.lua', {
	sizes = sizes,
	stageStats = stageStats,
})




t[#t + 1] = LoadActor("../_mousewheelscroll")
collectgarbage()
return t