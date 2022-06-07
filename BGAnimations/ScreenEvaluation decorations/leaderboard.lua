local sizes = Var('sizes')
local stageStats = Var('stageStats')
local util = Var('util')


local t = Def.ActorFrame{
	InitCommand = function(self)
		self:xy(sizes.leaderboardContainer.x, sizes.leaderboardContainer.y)
	end,
	Def.Quad {
		Name = 'bg',
		InitCommand = function(self)
			self:setsize(sizes.leaderboardContainer.w + sizes.border, sizes.leaderboardContainer.h + sizes.border)
			self:diffuse(0.1,0.1,0.1,1)
			self:visible(true)
		end
	},
}




t[#t+1] = Def.ActorFrame {
	Name = 'scoreFrame',
	InitCommand = function(self)
		self:y((-sizes.leaderboardContainer.h/2) + sizes.leaderboardScore.h / 2)
	end,
	util.makeScores(stageStats.score) .. {},
	LoadSizedFont('header') .. {
		Name = 'pageCount',
		OnCommand = function(self)
			self:settext('Page '.. util.curPage ..' of '.. #util.allTheScores)
			self:valign(1)
			self:y(sizes.leaderboardContainer.h - (sizes.leaderboardScore.h / 2) - sizes.vPadding)
		end,
		UpdateLeaderboardScorePageMessageCommand = function(self, params)
			--ms.ok(params)
		end
	},
}

return t