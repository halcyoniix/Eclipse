local gc = Var("GameCommand")
local t = Def.ActorFrame {}

t[#t+1] = Def.ActorFrame {
	OnCommand = function(self)
		self:x(-scx + 40)
		local txt, bg = self:GetChild('Button'):GetChild('Text'), self:GetChild('Button'):GetChild('BG')
		local selectionName = THEME:GetString(SCREENMAN:GetTopScreen():GetName(), gc:GetText())
		txt:settext(selectionName)
		txt:halign(0)
		bg:zoomto(txt:GetZoomedWidth() + 10,30):addx(-5)
		bg:diffuse(0.1, 0.1, 0.1, 1)
		bg:halign(0)
	end,
	UIElements.TextButton(1, 1, 'Common Normal') .. {
		Name = 'Button',
		GainFocusCommand = function(self)
			self:GetParent():linear(0.06)
			self:GetParent():zoom(1.02)

			self:finishtweening()
			self:linear(0.02)
			self:diffuse(1,1,1,1)
		end,
		LoseFocusCommand = function(self)
			self:GetParent():linear(0.06)
			self:GetParent():zoom(1)

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