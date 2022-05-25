local t = Def.ActorFrame{}
local element = {}

local d = Var('diffuse') or {1,1,1,1}
local img = Var('image') or THEME:GetPathG("Common", "fallback background")

local mult = 1.05
t[#t+1] = Def.Sprite {
	OnCommand = function(self)
		self:Load(THEME:GetPathG("Common", "fallback background"))
		self:scaletocover(SCREEN_LEFT*mult,SCREEN_TOP*mult,SCREEN_RIGHT*mult,SCREEN_BOTTOM*mult)
		self:xy(0, 0)
		self:diffuse( unpack({d}) )
	end
}
t[#t+1] = Def.Sprite {
	Name = 'img',
	OnCommand = function(self)
		self:Load(img)
		self:scaletocover(SCREEN_LEFT*mult,SCREEN_TOP*mult,SCREEN_RIGHT*mult,SCREEN_BOTTOM*mult)
		self:xy(0, 0)
		self:diffuse( unpack({d}) )
		if SCREENMAN:GetTopScreen():GetName() == 'ScreenSelectMusic' then
			self:diffusealpha(0)
		end
	end,
	CurrentSongChangedMessageCommand = function(self)
		self:finishtweening():smooth(0.3):diffusealpha(0):queuecommand('ModifySongBackground')
	end,
	ModifySongBackgroundCommand = function(self)
		local bgpath = THEME:GetPathG("Common", "fallback background")
		local curSong = GAMESTATE:GetCurrentSong()
		if curSong and curSong:GetBackgroundPath() then
			bgpath = curSong:GetBackgroundPath()
			self:Load(bgpath)
			self:visible(true)
			self:scaletocover(SCREEN_LEFT*mult,SCREEN_TOP*mult,SCREEN_RIGHT*mult,SCREEN_BOTTOM*mult):xy(0, 0)
			self:smooth(0.3)
			self:diffuse( unpack({d}) )
		else
			self:Load(bgpath)
			self:scaletocover(SCREEN_LEFT*mult,SCREEN_TOP*mult,SCREEN_RIGHT*mult,SCREEN_BOTTOM*mult):xy(0, 0)
			self:smooth(0.3)
			self:diffuse( unpack({d}) )
		end
	end,
	OffCommand = function(self)
		self:smooth(0.3):diffusealpha(0)
	end,
	BGOffMessageCommand = function(self)
		self:finishtweening():visible(false)
	end
}


local div = 100
t.InitCommand = function(self)
	self:SetUpdateFunction(function(self)
		local fx,fy = -(getMousePosition().x-scx),-(getMousePosition().y-scy)
		local mx,my = (fx*(1/div)),(fy*(1/div))
		self:xy(scx+mx, scy+my)
	end)
end

return t