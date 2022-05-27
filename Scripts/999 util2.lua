makeJudgmentsActors = function(params)
    local f = Def.ActorFrame {}
    local bar = function(i)
        local jud = params.score:GetTapNoteScore(judges[i])
        return Def.ActorFrame {
            InitCommand = function(self)
                self:addy(i*sizes.judgment.barPadding)
                self:RunCommandsOnChildren(function(self)
                    self:halign(0)
                end)
            end,
            Def.Quad {
                Name = 'barBg',
                OnCommand = function(self)
                    self:zoomto(sizes.judgment.barLength, sizes.judgment.barGirth)
                    self:diffuse(0.3,0.3,0.3,1)
                end
            },
            Def.Quad {
                Name = 'barFill',
                OnCommand = function(self)
                    self:zoomto(sizes.judgment.barLength, sizes.judgment.barGirth)
                    self:diffuse(colorByJudgment(judges[i]))
                    self:cropright(1)
                    self:sleep(0.2)
                    self:smooth(0.4)
                    self:cropright( 1-(jud / totalTaps))
                end
            },
            Def.ActorFrame {
                Name = 'judgmentThingy',
                InitCommand = function(self)
                    self:y(-sizes.judgment.barGirth - sizes.vPadding)
                end,
                LoadSizedFont('small') .. {
                    Name = 'judgmentName',
                    InitCommand = function(self)
                        self:settext(THEME:GetString('TapNoteScore', judges[i]))
                        self:halign(0)
                        self:maxwidth(150)
                    end
                },
                LoadSizedFont('small') .. {
                    Name = 'judgmentCount',
                    OnCommand = function(self)
                        self:settext(jud)
                        self:halign(1)
                        self:x(sizes.judgment.barLength)
                    end
                },
                LoadSizedFont('small') .. {
                    Name = 'judgmentCountPercentage',
                    OnCommand = function(self)
                        self:settextf('%5.2f%s', (jud / totalTaps) * 100, '%')
                        self:diffuse(0.5,0.5,0.5,1)
                        self:halign(1)
                        self:x(sizes.judgment.barLength - self:GetParent():GetChild('judgmentCount'):GetZoomedWidth() - sizes.hPadding/4)
                    end
                },
            },
        }
    end

    for k,v in pairs(judges) do
        f[#f+1] = bar(k)
    end

    return f
end