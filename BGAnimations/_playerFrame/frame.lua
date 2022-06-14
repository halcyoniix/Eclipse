local sizes = Var('sizes')
local pStats = Var('pStats')
local util = Var('util')
local t = Def.ActorFrame {}

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
			self:setsize(sw,sizes.headerHeight)
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
			self:setsize(sw,sizes.footerHeight)
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
				self:setsize(sizes.avatarSize,sizes.avatarSize)
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
					--OOLTIP:Hide()
				end
			end,
			MouseDownCommand = function(self, params)
				if params.event == "DeviceButton_left mouse button" and not SCREENMAN:get_input_redirected(PLAYER_1) and SCREENMAN:GetTopScreen():GetName() ~= 'ScreenEvaluationNormal' then
					if util.menuIsOpen then
						MESSAGEMAN:Broadcast('CloseProfileMenu')
						util.menuIsOpen = false
					else
						MESSAGEMAN:Broadcast('OpenProfileMenu')
						util.menuIsOpen = true
					end
				end
			end
		},
		util.drawPlayerStats() .. {
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
		util.drawMiscStats() .. {
			InitCommand = function(self)
				self:RunCommandsOnChildren(function(self)
					self:halign(1):valign(0)
				end)
			end
		}
	}
}


return t