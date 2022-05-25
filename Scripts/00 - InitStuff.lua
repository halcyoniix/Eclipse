scx = SCREEN_CENTER_X
scy = SCREEN_CENTER_Y
sw = SCREEN_WIDTH
sh = SCREEN_HEIGHT

THEMEINFO = {
	name = 'Eclipse',
	version = '0.8',
	date = '5-24-2022'
}

FONTSIZE = {
	header = 0.5,
	medium = 0.4,
	large = 0.6,
	small = 0.4
}

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