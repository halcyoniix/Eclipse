local t = Def.ActorFrame {}

t[#t+1] = LoadActor('_playerFrame/default.lua')
t[#t+1] = LoadActor('_mouse.lua')

local key = 'X8ca18c993d793f4bc2bb63a40139170a901504bc'
t[#t+1] = Def.ActorFrame{
	OnCommand = function(self)
		self:xy(scx,sh-20)
		local txt, bg = self:GetChild('Button'):GetChild('Text'), self:GetChild('Button'):GetChild('BG')
		txt:settext('go to eval')
		bg:zoomto(txt:GetZoomedWidth(),25)
		bg:diffusealpha(0)
		self:zoom(0.7)
	end,
	UIElements.TextButton(1, 1, 'Common Normal') .. {
		Name = 'Button',
		OnCommand = function(self)
			self:diffuse(0.7,0.7,0.7,1)
		end,
		GainFocusCommand = function(self)
			self:finishtweening()
			self:linear(0.02)
			self:diffuse(1,1,1,1)
		end,
		LoseFocusCommand = function(self)
			self:finishtweening()
			self:linear(0.02)
			self:diffuse(0.7,0.7,0.7,1)
		end,
		CurrentSongChangedMessageCommand = function(self, params)
			--ms.ok(params.ptr)
			if params.ptr then
				self:playcommand('Modify', {
					song = params.ptr,
					steps = params.ptr:GetAllSteps(),
				})
			end
		end,
		ModifyCommand = function(self, params)
			key = params.steps[1]:GetChartKey()
		end,
		ClickCommand = function(self, params)
			if params.update == 'OnMouseDown' then
				local score = SCOREMAN:GetScoresByKey(key)

				for k,v in pairs(score['1.0x']:GetScores()) do
					if v:HasReplayData() then
						SCREENMAN:GetTopScreen():ShowEvalScreenForScore(v)
						break
					end
				end
			end
		end,
		RolloverUpdateCommand = function(self, params)
			if params.update == 'in' then
				self:playcommand('GainFocus')
			elseif params.update == 'out' then
				self:playcommand('LoseFocus')
			end
		end
	}
}



return t