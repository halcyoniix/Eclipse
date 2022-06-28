local t = Def.ActorFrame {Name = "OverlayFile"}

t[#t+1] = LoadActor(THEME:GetPathG("", "_crashUploadOptIn"))

t[#t+1] = Def.ActorFrame {
	InitCommand = function(self)
		self:xy(40,sh - 60)
		self:RunCommandsOnChildren(function(self)
			self:halign(0):valign(0)
		end)
		self:playcommand('Thing',{
			name = self:GetChild('name'),
			ver = self:GetChild('ver'),
		})
	end,
	UIElements.TextToolTip(1, 1, 'Common Normal') .. {
		Name = 'name',
		BeginCommand = function(self)
			self:settext(THEMEINFO.name):zoom(FONTSIZE.header)
		end,
		MouseOverCommand = function(self)
			TOOLTIP:SetText('Click for full credits.')
			TOOLTIP:Show()
		end,
		MouseOutCommand = function(self)
			TOOLTIP:Hide()
		end,
		MouseDownCommand = function(self)
			SCREENMAN:SetNewScreen('ScreenCredits')
		end
	},
	LoadSizedFont('small') .. {
		Name = 'ver',
		Text = 'v'..THEMEINFO.version .. ' ('..THEMEINFO.date..')\n'.. GAMESTATE:GetEtternaVersion(),
		OnCommand = function(self)
			self:addy(14)
			self:diffuse(0.6,0.6,0.6,1)
		end
	},
}

t[#t+1] = Def.Sprite {
	OnCommand = function(self)
		local path = THEME:GetPathG('Common', 'logo')
		self:Load(path):zoom(0.3):xy(sw - 60*2,scy):halign(1)
		self:diffusealpha(0):sleep(0.1):cropright(0.5):cropleft(0.5)
		self:decelerate(0.7)
		self:diffusealpha(1):cropright(0):cropleft(0)
	end
}

t[#t+1] = LoadActor("_mouse.lua")
return t