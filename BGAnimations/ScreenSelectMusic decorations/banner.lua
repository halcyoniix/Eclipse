local sizes = Var('sizes')
local stageStats = Var('stageStats')


local t = Def.ActorFrame{
	InitCommand = function(self)
		self:xy(sizes.bannerContainer.x, sizes.bannerContainer.y)
	end,
	CurrentSongChangedMessageCommand = function(self)
		self:playcommand('Modify', {
			song = GAMESTATE:GetCurrentSong(),
			steps = GAMESTATE:GetCurrentSteps(),
		})
	end,
	Def.Quad {
		Name = 'bg',
		InitCommand = function(self)
			self:setsize(sizes.bannerContainer.w + sizes.border, sizes.bannerContainer.h + sizes.border)
			self:diffuse(0.1,0.1,0.1,1)
		end,
	},
}


local selectPressed = false
local selectMusicInput = function(event)
	if event.type == "InputEventType_FirstPress" then
		if event.button == "EffectUp" then
			changeMusicRate(1, selectPressed)
		elseif event.button == "EffectDown" then
			changeMusicRate(-1, selectPressed)
		elseif event.button == "Select" then
			selectPressed = true
		end
	elseif event.type == "InputEventType_Release" then
		if event.button == "Select" then
			selectPressed = false
		end
	end
	
end

t.BeginCommand = function(self)
	SCREENMAN:GetTopScreen():AddInputCallback(selectMusicInput)
end


local johnathan = false


t[#t+1] = Def.ActorFrame {
	Name = 'holyFuck',
	Def.Sprite {
		Name = 'bannerImg',
		InitCommand = function(self)
			self:scaletoclipped(sizes.bannerSize.w, sizes.bannerSize.h)
			self:addy( -(sizes.bannerContainer.h - sizes.bannerSize.h) / 2 )
		end,

		ModifyCommand = function(self, params)
			local bnpath = THEME:GetPathG('Common', 'fallback banner')
			self:finishtweening()
			if params.song then
				bnpath = params.song:GetBannerPath()
			else
				bnpath = SONGMAN:GetSongGroupBannerPath(SCREENMAN:GetTopScreen():GetMusicWheel():GetSelectedSection())
				if not bnpath or bnpath == '' then
					bnpath = THEME:GetPathG('Common', 'fallback banner')
				end
			end
			self:Load(bnpath)
			self:diffusealpha(1)
		end
	},
	Def.ActorFrame {
		Name = 'songDifficulty',
		InitCommand = function(self)
			self:xy( (sizes.bannerContainer.w/2) - sizes.hPadding/2, sizes.bannerContainer.h/2 - sizes.vPadding + 1 )
			self:RunCommandsOnChildren(function(self)
				self:halign(1):valign(1)
			end)
		end,
		UIElements.TextToolTip (1, 1, 'Common Large') .. {
			Name = 'songMSD',
			OnCommand = function(self)
				self:halign(1):valign(1)
				self:maxwidth(120):zoom(FONTSIZE.large)
			end,
			UpdateTooltipCommand = function(self, params)
				-- stay away from ternary, kids
				local txt = ''
				local msd = {}
				if params.steps then
					for k,v in pairs(ms.SkillSetsTranslated) do
						if k ~= 1 then
							txt = txt .. v ..': '..string.format('%5.2f',params.steps:GetMSD(getCurRateValue(), k)) .. (k == #ms.SkillSetsTranslated and '' or '\n')
						end
					end
				else
					TOOLTIP:Hide()
				end
				if not johnathan then
					TOOLTIP:SetText(txt)
					johnathan = false
				end
			end,
			MouseOverCommand = function(self)
				TOOLTIP:Show()
				self:playcommand('UpdateTooltip', {
					song = GAMESTATE:GetCurrentSong(),
					steps = GAMESTATE:GetCurrentSteps(),
				})
			end,
			MouseOutCommand = function(self)
				TOOLTIP:Hide()
			end,
			CurrentStepsChangedMessageCommand = function(self)
				self:playcommand('Modify', {
					song = GAMESTATE:GetCurrentSong(),
					steps = GAMESTATE:GetCurrentSteps(),
				})
			end,
			CurrentRateChangedMessageCommand = function(self)
				self:playcommand('Modify', {
					song = GAMESTATE:GetCurrentSong(),
					steps = GAMESTATE:GetCurrentSteps(),
				})
			end,
			ModifyCommand = function(self, params)
				local rating = params.steps and params.steps:GetMSD(getCurRateValue(), 1) or '0'
				self:playcommand('UpdateTooltip', params)
				self:settextf('%5.2f', rating)
				self:finishtweening()
				self:smooth(0.2)
				self:diffuse(colorByMSD(rating))
			end
		},
		Def.Quad {
			OnCommand = function(self)
				self:setsize(1,23)
				self:diffuse(0.3,0.3,0.3,1)
				self:halign(1)
				self:xy( -sizes.scoreContainer.w/sizes.magicVPadding + sizes.hPadding, 1)
			end
		},
		Def.ActorFrame {
			Name = 'musicRate',
			OnCommand = function(self)
				local txt = self:GetChild('rateMod')
				local rate = getRateString(stageStats.score:GetMusicRate())
				self:y(-sizes.bannerContainer.h + sizes.bannerSize.h)
				self:addy(3)
				self:RunCommandsOnChildren(function(self)
					self:halign(1)
				end)
			end,
			Def.Quad {
				OnCommand = function(self)
					self:setsize(48, self:GetParent():GetChild('rateMod'):GetHeight()*2)
					self:diffuse(0.1,0.1,0.1,1)
					self:x((sizes.hPadding/2)+1)
				end,
			},
			Def.Quad {
				OnCommand = function(self)
					self:setsize(self:GetParent():GetChild('rateMod'):GetHeight()*2, self:GetParent():GetChild('rateMod'):GetHeight()*2)
					self:diffuse(0.1,0.1,0.1,1)
					self:halign(0)
					self:x(-50)
					self:skewx(-1)
				end,
				ModifyCommand = function(self, params)
					if params.song then
						for k,v in pairs(params.song:GetAllSteps()) do
							ms.ok(v:GetDifficulty() .. ' | ' .. v:GetMeter())
						end
					end
				end
			},
			UIElements.TextToolTip (1, 1, 'Common Normal') .. {
				Name = 'rateMod',
				BeginCommand = function(self)
					self:zoom(FONTSIZE.small)
					self:settextf('%s Rate', getRateString(getCurRateValue()))
				end,
				CurrentRateChangedMessageCommand = function(self)
					self:settextf('%s Rate', getRateString(getCurRateValue()))
				end,
				MouseOverCommand = function(self)
					local txt = 'Press + or - to change rate.\nHold / for half rates.'
					johnathan = true
					TOOLTIP:SetText(txt)
					TOOLTIP:Show()
				end,
				MouseOutCommand = function(self)
					johnathan = false
					TOOLTIP:Hide()
				end,
			},
		}
	}
}

return t