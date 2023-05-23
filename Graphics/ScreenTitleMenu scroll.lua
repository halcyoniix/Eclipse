local gc = Var("GameCommand")
local t = Def.ActorFrame {}


local s = 0.6

t[#t+1] = Def.ActorFrame {
	OnCommand = function(self)
		self:zoom(s)
		self:y(-scy + ((sh/3)*2))
		local txt, bg = self:GetChild('Button'):GetChild('Text'), self:GetChild('Button'):GetChild('BG')
		local selectionName = THEME:GetString(SCREENMAN:GetTopScreen():GetName(), gc:GetText())
		txt:settext(selectionName)
		bg:zoomto(400, 60)
		bg:diffuse(0.1, 0.1, 0.1, 1)
	end,
	UIElements.TextButton(1, 1, 'Common Large') .. {
		Name = 'Button',
		GainFocusCommand = function(self)
			self:GetParent():linear(0.06)
			self:GetParent():zoom(s+0.02)

			self:finishtweening()
			self:linear(0.02)
			self:diffuse(1,1,1,1)
		end,
		LoseFocusCommand = function(self)
			self:GetParent():linear(0.06)
			self:GetParent():zoom(s)

			self:finishtweening()
			self:linear(0.02)
			self:diffuse(0.7,0.7,0.7,1)
		end,
		ClickCommand = function(self, params)
			if params.update == 'OnMouseDown' then
				if gc:GetName() == 'GameStart' then
					GAMESTATE:JoinPlayer()
				end
				GAMESTATE:ApplyGameCommand(THEME:GetMetric('ScreenTitleMenu', 'Choice'..gc:GetName()))
			end
		end,
		RolloverUpdateCommand = function(self, params)
			if params.update == 'in' then
				self:playcommand('GainFocus')
				curName = gc:GetText()
			elseif params.update == 'out' then
				self:playcommand('LoseFocus')
			end
		end
	}
}

return t