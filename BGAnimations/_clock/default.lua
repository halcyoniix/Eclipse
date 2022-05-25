local scx,scy = SCREEN_CENTER_X,SCREEN_CENTER_Y
local sw,sh = SCREEN_WIDTH,SCREEN_HEIGHT
local dw,dh = DISPLAY:GetDisplayWidth(),DISPLAY:GetDisplayHeight()

local c = Def.ActorFrame{}
c[#c+1] = Def.ActorFrame{
	OnCommand = function(self)
		self:xy(scx,scy):zoom(1):diffusealpha(1)
	end,
	LoadActor('clock/base')..{},
	LoadActor('clock/flare1')..{
		OnCommand = function(self) self:spin():effectmagnitude(0,0,-1) end,
	},
	LoadActor('clock/flare2')..{
		OnCommand = function(self) self:spin():effectmagnitude(0,0,1) end,
	},
	LoadActor('clock/inner1')..{
		OnCommand = function(self) self:spin():effectmagnitude(0,0,6) end,
	},
	LoadActor('clock/inner2')..{
		OnCommand = function(self) self:spin():effectmagnitude(0,0,-4) end,
	},
	LoadActor('clock/inner3')..{
		OnCommand = function(self) self:spin():effectmagnitude(0,0,2) end,
	},
	LoadActor('clock/outer1')..{
		OnCommand = function(self) self:spin():effectmagnitude(0,0,-0.5) end,
	},
	LoadActor('clock/outer2')..{
		OnCommand = function(self) self:spin():effectmagnitude(0,0,0.5) end,
	},
	LoadActor('clock/hour')..{
		OnCommand = function(self) self:queuecommand('Loop') end,
		LoopCommand = function(self) self:decelerate(0.2):rotationz(scale(Hour(),0,12,0,360)) self:sleep(1):queuecommand('Loop') end,
	},
	LoadActor('clock/minute')..{
		OnCommand = function(self) self:queuecommand('Loop') end,
		LoopCommand = function(self) self:decelerate(0.2):rotationz(scale(Minute(),0,60,0,360)) self:sleep(1):queuecommand('Loop') end,
	},
	LoadActor('clock/second')..{
		OnCommand = function(self) self:queuecommand('Loop') end,
		LoopCommand = function(self) self:decelerate(0.2):rotationz(scale(Second(),0,60,0,360)) self:sleep(1):queuecommand('Loop') end,
	},
}

return c