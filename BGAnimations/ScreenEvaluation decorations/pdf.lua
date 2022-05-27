-- originally by External#7270, i fudged the rest of it

local sizes = Var('sizes')

local score = SCOREMAN:GetMostRecentScore() or SCOREMAN:GetTempReplayScore()
local offsets = score:GetOffsetVector()
local bin_size = (180*2) / 90
local resolution = 3

local pdf = {}


local prep = function()
	for i = -180, 180, bin_size do
		pdf[i] = 0
	end
end

local triangle = function(t, center)
	local out = (1 - math.abs(t -center)/resolution)/resolution
	return out < 0 and 0 or out
end

local gaussian = function(offset, n)
	for i = -180, 180, bin_size do
		pdf[i] = pdf[i] + triangle(offset, i) / n
	end
end

local t = Def.ActorFrame {
	OnCommand = function(self)
		prep()
		for k,v in ipairs(offsets) do
			if v >= 180 then
				offsets[k] = 180
			end
			gaussian(offsets[k], #offsets)
		end
		self:playcommand('UpdatePDF')
	end,
}

local clamp = function(low, n, high)
	return math.min(math.max(n, low), high)
end

for i = -180, 180, bin_size do
	t[#t+1] = Def.Quad { 
		UpdatePDFCommand = function(self)
			self:valign(1)
			self:diffuse(unpack(colorByTapOffset(i)))
			self:zoomto(
				(bin_size/2) + 0.5,
				clamp(0, (pdf[i] * 2000), sizes.lifeGraph.h)
			)
			-- vomit emoji
			self:x((sizes.lifeGraph.w/2) + (bin_size/4) * ((i/180)*sizes.lifeGraph.w/2) - (bin_size/2))
			self:y(sizes.lifeGraph.h)
		end
	}
end

return t