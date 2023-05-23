local sizes = Var('sizes')
local stageStats = Var('stageStats')
local util = Var('util')

local numWheelItems = 14

local wheelItemBase = function()
	return Def.ActorFrame {
		Name = 'WheelItemBase',
		Def.Quad {
			Name = 'ItemBG',
			InitCommand = function(self)
				self:SetSize(sizes.wheel.songPanel.w + sizes.border, sizes.wheel.songPanel.h + sizes.border)
				self:diffuse(0.1, 0.1, 0.1, 1)
			end
		}
	}
end

local function groupBannerSetter(self, group, isCurrentItem)
	if not useWheelBanners() then
		self:visible(false)
		return
	end

	if isCurrentItem and useVideoBanners() then
		self:SetDecodeMovie(true)
	else
		self:SetDecodeMovie(false)
	end

	local bnpath = WHEELDATA:GetFolderBanner(group)
	-- we load the fallback banner but for aesthetic purpose at the moment, invisible
	if not showBanners() then
		self:visible(false)
	elseif not bnpath or bnpath == '' then
		bnpath = THEME:GetPathG('Common', 'fallback banner')
		self:visible(false)
	else
		self:visible(true)
	end
	if self.bnpath ~= bnpath then
		self:Load(bnpath)
	end
	self.bnpath = bnpath
end

local function songBannerSetter(self, song, isCurrentItem)
	if not useWheelBanners() then
		self:visible(false)
		return
	end

	if isCurrentItem and useVideoBanners() then
		self:SetDecodeMovie(true)
	else
		self:SetDecodeMovie(false)
	end

	if song then
		local bnpath = song:GetBannerPath()
		-- we load the fallback banner but for aesthetic purpose at the moment, invisible
		if not showBanners() then
			self:visible(false)
		elseif not bnpath then
			bnpath = THEME:GetPathG('Common', 'fallback banner')
			self:visible(false)
		else
			self:visible(true)
		end
		if self.bnpath ~= bnpath then
			self:Load(bnpath)
		end
		self.bnpath = bnpath
	end
end

local function groupActorUpdater(groupFrame, packName, isCurrentItem)
	local packCount = WHEELDATA:GetFolderCount(packName)
	local packAverageDiff = WHEELDATA:GetFolderAverageDifficulty(packName)
	local clearstats = WHEELDATA:GetFolderClearStats(packName)

	groupFrame.Title:settext(packName)
	groupFrame.GroupInfo:playcommand('SetInfo', {count = packCount, avg = packAverageDiff[1]})
	groupFrame.ClearStats:playcommand('SetInfo', {stats = clearstats})
	groupFrame.ScoreStats:playcommand('SetInfo', {stats = clearstats, count = packCount})
	groupBannerSetter(groupFrame.Banner, packName, isCurrentItem)
end

local function songActorUpdater(songFrame, song, isCurrentItem)
	songFrame.Title:settext(song:GetDisplayMainTitle())
	songFrame.SubTitle:settext(song:GetDisplaySubTitle())
	songFrame.Artist:settext('~'..song:GetDisplayArtist())
	songFrame.Grade:playcommand('SetGrade', {grade = song:GetHighestGrade()})
	songFrame.Favorited:diffusealpha(song:IsFavorited() and 1 or 0)
	songFrame.Permamirror:diffusealpha(song:IsPermaMirror() and 1 or 0)
	songBannerSetter(songFrame.Banner, song, isCurrentItem)
end

local groupActorBuilder = function()
	local leftOffset = (-sizes.wheel.songPanel.w/2) + sizes.wheel.bannerIcon.w/2
	local d = (sizes.wheel.songPanel.h/4)
	return Def.ActorFrame {
		Name = 'GroupFrame',
		wheelItemBase(),
		LoadSizedFont('medium') .. {
			Name = 'GroupName',
			BeginCommand = function(self)
				self:GetParent().Title = self
				self:playcommand('SetPosition')
			end,
			SetPositionCommand = function(self)
				self:xy((-sizes.wheel.songPanel.w/2) + sizes.wheel.bannerIcon.w + sizes.hPadding, (-sizes.wheel.songPanel.h/2) + sizes.vPadding*2)
				self:halign(0)
				self:maxwidth(500)
			end
		},
		LoadSizedFont('small') .. {
			Name = 'GroupInfo',
			BeginCommand = function(self)
				self:GetParent().GroupInfo = self
			end,
		},
		LoadSizedFont('small') .. {
			Name = 'ClearStats',
			BeginCommand = function(self)
				self:GetParent().ClearStats = self
			end,
		},
		LoadSizedFont('small') .. {
			Name = 'ScoreStats',
			BeginCommand = function(self)
				self:GetParent().ScoreStats = self
			end,
		},
		Def.Sprite {
			Name = 'Banner',
			BeginCommand = function(self)
				self:GetParent().Banner = self
				self:playcommand('SetPosition')
			end,
			InitCommand = function(self)
				self:scaletoclipped(sizes.wheel.bannerIcon.w, sizes.wheel.bannerIcon.h)
				self:SetDecodeMovie(false)
			end,
			SetPositionCommand = function(self)
				self:x(leftOffset)
			end
		},
	}
end


local songActorBuilder = function()
	local leftOffset = (-sizes.wheel.songPanel.w/2) + sizes.wheel.bannerIcon.w/2
	local d = (sizes.wheel.songPanel.h/4)
	return Def.ActorFrame {
		Name = 'SongFrame',
		wheelItemBase(),
		LoadSizedFont('header') .. {
			Name = 'Title',
			BeginCommand = function(self)
				self:GetParent().Title = self
				self:playcommand('SetPosition')
			end,
			SetPositionCommand = function(self)
				self:xy((-sizes.wheel.songPanel.w/2) + sizes.wheel.bannerIcon.w + sizes.hPadding, (-sizes.wheel.songPanel.h/2) + sizes.vPadding)
				self:halign(0)
				self:maxwidth(500)
			end
		},
		LoadSizedFont('small') .. {
			Name = 'Artist',
			BeginCommand = function(self)
				self:GetParent().Artist = self
				self:playcommand('SetPosition')
			end,
			SetPositionCommand = function(self)
				self:xy((-sizes.wheel.songPanel.w/2) + sizes.wheel.bannerIcon.w + sizes.hPadding, (-sizes.wheel.songPanel.h/2) + sizes.vPadding + d)
				self:halign(0)
				self:maxwidth(sizes.wheel.songPanel.w - (sizes.wheel.bannerIcon.w/2) + sizes.hPadding)
			end
		},
		Def.Quad {
			InitCommand = function(self)
				self:halign(0)
				self:setsize((sizes.wheel.songPanel.w - sizes.wheel.bannerIcon.w) - sizes.hPadding*2, 1)
				self:xy((-sizes.wheel.songPanel.w/2) + sizes.wheel.bannerIcon.w + sizes.hPadding, 18)
				self:diffusealpha(0.3)
			end
		},
		LoadSizedFont('small') .. {
			Name = 'SubTitle',
			BeginCommand = function(self)
				self:GetParent().SubTitle = self
				self:playcommand('SetPosition')
			end,
			SetPositionCommand = function(self)
				self:xy((-sizes.wheel.songPanel.w/2) + sizes.wheel.bannerIcon.w + sizes.hPadding, (-sizes.wheel.songPanel.h/2) + sizes.vPadding + d*3)
				self:halign(0)
				self:maxwidth(sizes.wheel.songPanel.w + sizes.hPadding*2)
				self:diffusealpha(0.5)
			end
		},
		LoadSizedFont('small') .. {
			Name = 'Grade',
			BeginCommand = function(self)
				self:GetParent().Grade = self
				self:playcommand('SetPosition')
			end,
			SetPositionCommand = function(self)
				self:xy((-sizes.wheel.songPanel.w/2) + sizes.wheel.bannerIcon.w + sizes.hPadding, (-sizes.wheel.songPanel.h/2) + sizes.vPadding + d*2)
				self:halign(0)
				self:maxwidth(sizes.wheel.songPanel.w + sizes.hPadding*2)
			end,
			SetGradeCommand = function(self, params)
				if params.grade and params.grade ~= 'Grade_Invalid' then
					self:settext(THEME:GetString('Grade', params.grade:sub(#'Grade_T')))
					self:diffuse(colorByGrade(params.grade))
				else
					self:settext('')
				end
			end,
		},
		Def.Sprite {
			Name = 'Banner',
			BeginCommand = function(self)
				self:GetParent().Banner = self
				self:playcommand('SetPosition')
			end,
			InitCommand = function(self)
				self:scaletoclipped(sizes.wheel.bannerIcon.w, sizes.wheel.bannerIcon.h)
				self:SetDecodeMovie(false)
			end,
			SetPositionCommand = function(self)
				self:x(leftOffset)
			end
		},
		Def.Sprite {
			Name = 'FavoriteIcon',
			BeginCommand = function(self)
				self:GetParent().Favorited = self
			end,
		},
		Def.Sprite {
			Name = 'PermamirrorIcon',
			BeginCommand = function(self)
				self:GetParent().Permamirror = self
			end,
		},
	}
end


local function getFrameTransformer()
	return function(frame, offsetFromCenter, index, total)
		frame:xy(0, offsetFromCenter * (sizes.wheel.songPanel.h + sizes.vPadding))
	end
end


local visible = true
local t = Def.ActorFrame {
	Name = 'WheelContainer',
	InitCommand = function(self)
		self:xy(sizes.wheel.x, scy)
	end,
	BeginCommand = function(self)
		SCREENMAN:GetTopScreen():GetMusicWheel():visible(false)
	end,
	MusicWheel:new({
		count = 14,
		startOnPreffered = true,
		songActorUpdater = songActorUpdater,
		songActorBuilder = songActorBuilder,
		groupActorUpdater = groupActorUpdater,
		groupActorBuilder = groupActorBuilder,
		frameTransformer = getFrameTransformer(),
		highlightBuilder = function()
			return Def.ActorFrame {
				Name = 'HighlightFrame',
				Def.Quad {
					Name = 'Highlight',
					InitCommand = function(self)
						self:playcommand('SetPosition')
						self:faderight(1)
						self:diffuseramp()
						self:effectclock('bgm')
						self:effectcolor1(1,1,1,0)
						self:effectcolor2(1,1,1,0.25)
					end,
					SetPositionCommand = function(self)
						self:SetSize(sizes.wheel.songPanel.w + sizes.border, sizes.wheel.songPanel.h + sizes.border)
					end,
					UpdateWheelPositionCommand = function(self)
						self:playcommand('SetPosition')
					end,
					UpdateWheelBannersCommand = function(self)
						self:playcommand('SetPosition')
					end,
				}
			}
		end,
		frameBuilder = function()
			local f
			f = Def.ActorFrame {
				Name = 'ItemFrame',
				InitCommand = function(self)
					f.actor = self
				end,
				UIElements.QuadButton(1) .. {
					Name = 'WheelItemClickBox',
					InitCommand = function(self)
						self:diffusealpha(0.1)
						self:SetSize(sizes.wheel.songPanel.w, sizes.wheel.songPanel.h)
					end,
					MouseDownCommand = function(self, params)
						if not visible then return end
						if params.event == 'DeviceButton_left mouse button' then
							local index = self:GetParent().index
							-- subtract 1 here BASED ON numWheelItems
							-- ... i know its dumb but it works for the params i set myself
							-- if you mess with numWheelItems YOU NEED TO MAKE SURE THIS WORKS
							local distance = math.floor(index - numWheelItems / 2) - 1
							local wheel = self:GetParent():GetParent()
							if distance ~= 0 then
								-- clicked a nearby item
								wheel:playcommand('Move', {direction = distance})
								wheel:playcommand('OpenIfGroup')
							else
								-- clicked the current item
								wheel:playcommand('SelectCurrent')
							end
						end
					end
				},

				groupActorBuilder() .. {
					BeginCommand = function(self)
						f.actor.g = self
					end
				},
				songActorBuilder() .. {
					BeginCommand = function(self)
						f.actor.s = self
					end
				}
			}
			return f
		end,
		frameUpdater = function(frame, songOrPack, offset, isCurrentItem)
			if songOrPack.GetAllSteps then
				-- This is a song
				local s = frame.s
				s:visible(true)
				local g = frame.g
				g:visible(false)
				songActorUpdater(s, songOrPack, isCurrentItem)
			else
				-- This is a group
				local s = frame.s
				s:visible(false)
				local g = (frame.g)
				g:visible(true)
				groupActorUpdater(g, songOrPack, isCurrentItem)
			end
		end
	}),
	Def.Quad {
		Name = 'MouseWheelRegion',
		InitCommand = function(self)
			self:diffuse(1, 0, 0, 0)
			self:playcommand('SetPosition')
			self:SetSize(sizes.wheel.w, sh)
		end,
		SetPositionCommand = function(self)
		end,
		UpdateWheelPositionCommand = function(self)
			self:playcommand('SetPosition')
		end,
		MouseScrollMessageCommand = function(self, params)
			if isOver(self) and visible then
				if params.direction == 'Up' then
					self:GetParent():GetChild('Wheel'):playcommand('Move', {direction = -1})
				else
					self:GetParent():GetChild('Wheel'):playcommand('Move', {direction = 1})
				end
			end
		end,
		MouseClickPressMessageCommand = function(self, params)
			if params ~= nil and params.button ~= nil and visible then
				if params.button == 'DeviceButton_right mouse button' then
					if isOver(self) then
						SCREENMAN:GetTopScreen():PauseSampleMusic()
					end
				end
			end
		end
	},
}

return t