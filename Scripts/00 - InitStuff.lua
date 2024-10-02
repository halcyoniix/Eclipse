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

makeDivider = function(params)
	params.x = params.x or 0
	params.y = params.y or 0
	return Def.ActorMultiVertex {
		InitCommand = function(self)
			local verts = {
				{{0,0,0}, {1,1,1,1}},
				{{params.x,params.y,0}, {1,1,1,1}},
			}
			self:SetDrawState{Mode = 'DrawMode_LineStrip'}
			self:SetLineWidth(1)
			self:SetVertices(verts)
			self:diffusealpha(0.3)
		end
	}
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
