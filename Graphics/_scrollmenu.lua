local gc = Var("GameCommand")
-- A scroller that can be loaded from elsewhere
-- It is placed into redir files to save space

return Def.ActorFrame {
	LoadFont("Common Normal") ..
		{
			OnCommand = function(self)
				self:settext(THEME:GetString(SCREENMAN:GetTopScreen():GetName(), gc:GetText()))
				self:halgin()
			end,
			GainFocusCommand = function(self)
				self:finishtweening()
				self:linear(0.02)
				self:zoom(1.2)
				self:diffuse(1,1,1,1)
			end,
			LoseFocusCommand = function(self)
				self:finishtweening()
				self:linear(0.02)
				self:zoom(1)
				self:diffuse(0.7,0.7,0.7,1)
			end
		}
}
