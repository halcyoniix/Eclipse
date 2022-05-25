local t = Def.ActorFrame {}
local profile = GetPlayerOrMachineProfile(PLAYER_1)

-- this table has a bunch of funny ratio math so that i'm able to translate my design from affinity to etterna down to the pixel
-- height ratio = (n / 720) * sh
-- width ratio = (n / 1280) * sh
-- thanks poco
local sizes = {
	headerHeight = (30 / 720) * sh,
	footerHeight = (80 / 720) * sh,
	avatarSize = (80 / 720) * sh,
	hPadding = (10 / 1280) * sw,
	vPadding = (10 / 720) * sh,
}

local profileName = profile:GetDisplayName()
local playCount = SCOREMAN:GetTotalNumberOfScores()
local playTime = profile:GetTotalSessionSeconds()
local noteCount = profile:GetTotalTapsAndHolds()
local playerRating = profile:GetPlayerRating()


local playerStats = {
	string.format('%s: %5.2f', profileName, profile:GetPlayerRating()),
	string.format('%s %s', playCount, THEME:GetString('GeneralInfo', 'ProfilePlays')),
	string.format('%s %s', noteCount, THEME:GetString('GeneralInfo', 'ProfileTapsHit')),
}

local miscStats = {
	GAMESTATE:GetEtternaVersion(),
	string.format('%s %s', THEME:GetString('GeneralInfo', 'ProfileJudge'), GetTimingDifficulty()),
	string.format('%s %s', SecondsToHHMMSS(playTime), THEME:GetString('GeneralInfo', 'ProfilePlaytime')),
}

local drawPlayerStats = function()
	local f = Def.ActorFrame {}
	local t = playerStats
	local m = function(i)
		return LoadSizedFont('header').. {
			InitCommand = function(self)
				local actualHeight = self:GetHeight()
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


local drawMiscStats = function()
	local f = Def.ActorFrame {}
	local t = miscStats
	local m = function(i)
		return LoadSizedFont('header').. {
			InitCommand = function(self)
				local actualHeight = self:GetHeight()
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

t[#t+1] = Def.ActorFrame {
	Name = 'header',
	InitCommand = function(self)
		self:x(scx)
		self:SetUpdateFunction(function()
		local year = Year()
		local month = MonthOfYear() + 1
		local day = DayOfMonth()
		local hour = Hour()
		local minute = Minute()
		local second = Second()
		self:GetChild("currentTime"):settextf("%04d-%02d-%02d %02d:%02d:%02d", year, month, day, hour, minute, second)
		local sessiontime = GAMESTATE:GetSessionTime()
		self:GetChild('sessionTime'):settextf('%s: %s', THEME:GetString('GeneralInfo', 'SessionTime'), SecondsToHHMMSS(sessiontime))
		end)
	end,
	Def.Quad {
		Name = 'bg',
		InitCommand = function(self)
			self:diffuse(0.1,0.1,0.1,1)
			self:zoomto(sw,sizes.headerHeight)
			self:valign(0)
		end
	},
	LoadSizedFont('header') .. {
		Name = 'sessionTime',
		InitCommand = function(self)
			self:zoom(0.5)
			self:y(sizes.headerHeight/2)
		end
	},
	LoadSizedFont('header') .. {
		Name = 'currentTime',
		InitCommand = function(self)
			self:halign(0)
			self:xy(-scx + sizes.hPadding, sizes.headerHeight/2)
		end
	},
	LoadSizedFont('header') .. {
		Name = 'currentScreen',
		OnCommand = function(self)
			local name = SCREENMAN:GetTopScreen():GetName()
			self:maxwidth(500)
			self:halign(1)
			self:xy(scx - sizes.hPadding, sizes.headerHeight/2)
			self:settextf('%s' .. ((name == 'ScreenEvaluationNormal' or name == 'ScreenSelectMusic') and ': %s' or ''), THEME:GetString(name, 'HeaderText'), GAMESTATE:GetCurrentSong():GetGroupName())
		end,
		CurrentSongChangedMessageCommand = function(self)
			local name = SCREENMAN:GetTopScreen():GetName()
			if not GAMESTATE:GetCurrentSong() then
				return
			else
				self:settextf('%s' .. ((name == 'ScreenEvaluationNormal' or name == 'ScreenSelectMusic') and ': %s' or ''), THEME:GetString(name, 'HeaderText'), GAMESTATE:GetCurrentSong():GetGroupName())
			end
		end
	},
}

t[#t+1] = Def.ActorFrame {
	Name = 'footer',
	InitCommand = function(self) 
		self:xy(scx,sh) 
	end,
	Def.Quad {
		Name = 'bg',
		InitCommand = function(self)
			self:diffuse(0.1,0.1,0.1,1)
			self:zoomto(sw,sizes.footerHeight)
			self:valign(1)
		end
	},
	Def.ActorFrame {
		Name = 'playerStats',
		InitCommand = function(self)
			self:xy(-scx + sizes.avatarSize/2, -sizes.footerHeight)
			self:diffusealpha(1)
		end,
		UIElements.SpriteButton(1, 1, nil) .. {
			Name = 'avatar',
			BeginCommand = function(self)
				self:queuecommand("ModifyAvatar")
			end,
			ModifyAvatarCommand = function(self)
				self:finishtweening()
				self:Load(getAvatarPath(PLAYER_1))
				self:valign(0)
				self:zoomto(sizes.avatarSize,sizes.avatarSize)
			end,
			MouseOverCommand = function(self)
				if SCREENMAN:GetTopScreen():GetName() ~= 'ScreenEvaluationNormal' then
					self:finishtweening()
					self:smooth(0.1)
					self:diffuse(0.5,0.5,0.5,1)
					--TOOLTIP:SetText('Open assets menu')
					--TOOLTIP:Show()
				end
			end,
			MouseOutCommand = function(self)
				if SCREENMAN:GetTopScreen():GetName() ~= 'ScreenEvaluationNormal' then
					self:finishtweening()
					self:smooth(0.1)
					self:diffuse(1,1,1,1)
					--TOOLTIP:Hide()
				end
			end,
			MouseDownCommand = function(self, params)
				if params.event == "DeviceButton_left mouse button" and not SCREENMAN:get_input_redirected(PLAYER_1) and SCREENMAN:GetTopScreen():GetName() ~= 'ScreenEvaluationNormal' then
					--SCREENMAN:SetNewScreen("ScreenAssetSettings")
					ms.ok('open assets')
				end
			end
		},
		drawPlayerStats() .. {
			InitCommand = function(self)
				self:RunCommandsOnChildren(function(self)
					self:halign(0):valign(0)
				end)
			end
		}
	},

	Def.ActorFrame {
		Name = 'miscStats',
		InitCommand = function(self)
			self:xy(-scx + sizes.avatarSize/2, -sizes.footerHeight)
			self:diffusealpha(1)
		end,
		drawMiscStats() .. {
			InitCommand = function(self)
				self:RunCommandsOnChildren(function(self)
					self:halign(1):valign(0)
				end)
			end
		}
	}
}


return t