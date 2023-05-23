scx = SCREEN_CENTER_X
scy = SCREEN_CENTER_Y
sw = SCREEN_WIDTH
sh = SCREEN_HEIGHT

THEMEINFO = {
	name = 'Eclipse',
	version = '-1???',
	date = 'MM-DD-YYYY'
}

FONTSIZE = {
	large = 1,
	medium = 0.6,
	header = 0.75,
	small = 0.6
}

FUCKMETRICS = {}

local m = -60

FUCKMETRICS.TitleOnCommand = function(self)
	self:halign(0)
	self:zoom(FONTSIZE.header)
	self:xy(m, -20)
	self:maxwidth(400)
	self:diffuse(1,1,1,1)
end

FUCKMETRICS.ArtistOnCommand = function(self)
	self:halign(0)
	self:zoom(FONTSIZE.small)
	self:xy(m, -5)
	self:maxwidth(415)
	self:diffuse(1,1,1,1)
end

FUCKMETRICS.SubtitleOnCommand = function(self)
	self:halign(0)
	self:zoom(FONTSIZE.small)
	self:xy(m, 28)
	self:maxwidth(574)
	self:diffuse(0.6,0.6,0.6,1)
end

FUCKMETRICS.SectionCollapsedOnCommand = function(self)
	self:stopeffect()
	self:halign(0)
	self:x(m)
	self:zoom(FONTSIZE.header):maxwidth(400)
end

FUCKMETRICS.SectionExpandedOnCommand = function(self)
	self:stopeffect()
	self:halign(0)
	self:x(m)
	self:zoom(FONTSIZE.header):maxwidth(400)
end

LoadSizedFont = function(s)
	local s = tostring(s)
	if s then
		return LoadFont((s == 'large' or s == 'medium') and 'Common Large' or 'Common Normal') .. {
			InitCommand = function(self)
				self:zoom(FONTSIZE[s])
			end
		}
	end
end