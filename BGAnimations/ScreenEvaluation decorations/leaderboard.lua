local sizes = Var('sizes')
local stageStats = Var('stageStats')


local t = Def.ActorFrame{
	InitCommand = function(self)
		self:xy(sizes.leaderboardContainer.x, sizes.leaderboardContainer.y)
	end,
	Def.Quad {
		Name = 'bg',
		InitCommand = function(self)
			self:zoomto(sizes.leaderboardContainer.w + sizes.border, sizes.leaderboardContainer.h + sizes.border)
			self:diffuse(0.1,0.1,0.1,1)
		end
	},
}

local makeScores = function(params)
	local f = Def.ActorFrame{}
	local score = nil
	local s = function(i)
	return 
		Def.ActorFrame {
			OnCommand = function(self)
				self:addy((sizes.leaderboardScore.h + sizes.vPadding) * i)
			end,
			Def.Quad {
				Name = 'bg',
				InitCommand = function(self)
					self:zoomto(sizes.leaderboardScore.w, sizes.leaderboardScore.h)
					self:diffuse(0.2,0.2,0.2,1)
				end
			},
			--[[LoadSizedFont('header') .. {
				Name = 'percentage',
				OnCommand = function(self)
					self:settext('ass'):halign(0):valign(0)
					self:xy(-sizes.leaderboardScore.w/2 + sizes.hPadding, -sizes.leaderboardScore.h/2 + sizes.vPadding)
				end
			}--]]
			LoadSizedFont('header') .. {
				Name = 'percentage',
				OnCommand = function(self)
					self:settext('ass'):halign(0):valign(0)
					self:xy(-sizes.leaderboardScore.w/2 + sizes.hPadding, -sizes.leaderboardScore.h/2 + sizes.vPadding)
				end
			}
		}
	end
	for i = 0,5 do
		f[#f+1] = s(i)
	end
	return f
end



t[#t+1] = Def.ActorFrame {
	Name = 'scoreFrame',
	InitCommand = function(self)
		self:y((-sizes.leaderboardContainer.h/2) + sizes.leaderboardScore.h / 2 + sizes.vPadding)
	end,
	Def.ActorFrame{
		Name = 'scores',
		makeScores() .. {}
	}
}

return t