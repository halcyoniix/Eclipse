scx = SCREEN_CENTER_X
scy = SCREEN_CENTER_Y
sw = SCREEN_WIDTH
sh = SCREEN_HEIGHT

THEMEINFO = {
	name = 'Eclipse',
	version = '0.8',
	date = 'MM-DD-YYYY'
}

FONTSIZE = {
	header = 0.5,
	medium = 0.4,
	large = 0.6,
	small = 0.4
}

FUCKMETRICS = {}

FUCKMETRICS.TitleOnCommand = function(self)
	self:halign(0)
	self:zoom(FONTSIZE.header)
	self:xy(-60, -15)
	self:maxwidth(400)
end

FUCKMETRICS.ArtistOnCommand = function(self)
	self:halign(0)
	self:zoom(0.35)
	self:xy(-60, -5)
	self:maxwidth(415)
end

FUCKMETRICS.SubtitleOnCommand = function(self)
	self:halign(0)
	self:zoom(0.35)
	self:xy(-60, 18)
	self:maxwidth(574)
	self:diffuse(0.6,0.6,0.6,1)
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