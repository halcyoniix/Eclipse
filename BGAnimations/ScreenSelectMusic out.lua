local t = Def.ActorFrame {}

local translated_info = {
	PressStart = THEME:GetString("ScreenSelectMusic","PressStartForOptions"),
	EnteringOptions = THEME:GetString("ScreenSelectMusic","EnteringOptions"),
}

--black fade
t[#t + 1] = Def.Quad {
	InitCommand = function(self)
		self:Center():zoomto(SCREEN_WIDTH, SCREEN_HEIGHT)
	end,
	OnCommand = function(self)
		self:diffuse(color("0,0,0,0")):sleep(0.1):linear(0.1):diffusealpha(1)
	end
}

-- skip showing the prompt
--if not themeConfig:get_data().global.ShowPlayerOptionsHint then return t end




--enter options prompt
t[#t + 1] = LoadSizedFont("large") ..  {
	InitCommand=function(self)
		self:Center()
	end,
	ShowPressStartForOptionsCommand=function(self)
		self:settext(translated_info["PressStart"]):diffusealpha(0):zoom(0.8)
		self:decelerate(0.2):zoom(0.55):diffusealpha(1)
	end,
	ShowEnteringOptionsCommand=function(self)
		self:finishtweening():settext(translated_info["EnteringOptions"])
	end,
	HidePressStartForOptionsCommand=function(self)
		self:decelerate(0.2):diffusealpha(0)
	end
}


return t
