local t = Def.ActorFrame {}

local util = {}
local pStats = {}
local sizes = {
	headerHeight = (30 / 720) * sh,
	footerHeight = (80 / 720) * sh,
	avatarSize = (80 / 720) * sh,
	hPadding = (10 / 1280) * sw,
	vPadding = (10 / 720) * sh,
}
pStats.profile = GetPlayerOrMachineProfile(PLAYER_1)
pStats.profileName = pStats.profile:GetDisplayName()
pStats.playCount = SCOREMAN:GetTotalNumberOfScores()
pStats.playTime = pStats.profile:GetTotalSessionSeconds()
pStats.noteCount = pStats.profile:GetTotalTapsAndHolds()
pStats.playerRating = pStats.profile:GetPlayerRating()


util.menuIsOpen = false
util.playerStats = {
	string.format('%s: %5.2f', pStats.profileName, pStats.profile:GetPlayerRating()),
	string.format('%s %s', pStats.playCount, THEME:GetString('GeneralInfo', 'ProfilePlays')),
	string.format('%s %s', pStats.noteCount, THEME:GetString('GeneralInfo', 'ProfileTapsHit')),
}

--[[if DLMAN:IsLoggedIn() then
	playerStats[1] = string.format('%s: %5.2f', DLMAN:GetUsername(), DLMAN:GetSkillsetRating('Overall'))
end--]]

util.miscStats = {
	GAMESTATE:GetEtternaVersion(),
	string.format('%s %s', THEME:GetString('GeneralInfo', 'ProfileJudge'), GetTimingDifficulty()),
	string.format('%s %s', SecondsToHHMMSS(pStats.playTime), THEME:GetString('GeneralInfo', 'ProfilePlaytime')),
}

util.drawPlayerStats = function()
	local f = Def.ActorFrame {}
	local t = util.playerStats
	local m = function(i)
		return LoadSizedFont('header').. {
			InitCommand = function(self)
				self:settext(t[i])
				self:xy(sizes.avatarSize/2 + sizes.hPadding, sizes.vPadding + (sizes.footerHeight - sizes.vPadding) * ((i-1)/#t) )
			end
		}
	end
	for k,v in pairs(t) do
		f[#f+1] = m(k)
	end
	return f
end


util.drawMiscStats = function()
	local f = Def.ActorFrame {}
	local t = util.miscStats
	local m = function(i)
		return LoadSizedFont('header').. {
			InitCommand = function(self)
				self:settext(t[i])
				self:xy(-sizes.avatarSize/2 + sw - sizes.hPadding, sizes.vPadding + (sizes.footerHeight - sizes.vPadding) * ((i-1)/#t) )
			end
		}
	end
	for k,v in pairs(t) do
		f[#f+1] = m(k)
	end
	return f
end

t[#t+1] = LoadActorWithParams('menu.lua', {
	sizes = sizes,
	pStats = pStats,
	util = util
})

t[#t+1] = LoadActorWithParams('frame.lua', {
	sizes = sizes,
	pStats = pStats,
	util = util
})

return t