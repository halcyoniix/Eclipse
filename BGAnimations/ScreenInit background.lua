local scx,scy = SCREEN_CENTER_X,SCREEN_CENTER_Y
local sw,sh = SCREEN_WIDTH,SCREEN_HEIGHT
local dw,dh = DISPLAY:GetDisplayWidth(),DISPLAY:GetDisplayHeight()

local t = Def.ActorFrame{}
local strings = {
	'Hello, world!',
	'This is a test theme.',
	MonthOfYear()+1 ..'/'.. DayOfMonth() ..'/'.. Year(),
	THEMEINFO.name .. ' v'.. THEMEINFO.version
}

t[#t+1] = LoadActorWithParams('_parallax.lua', {diffuse = {1,1,1,1}})


t[#t+1] = Def.ActorFrame{
	OnCommand = function(self)
		self:xy(scx,scy)
	end,
	LoadSizedFont('large') .. {
	OnCommand = function(self)
		self:settext(strings[math.random(1,#strings)]):diffusealpha(0)
		self:smooth(1):diffusealpha(1)
	end
	}
}

return t