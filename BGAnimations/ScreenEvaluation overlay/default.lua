local t = Def.ActorFrame {}

t[#t+1] = LoadActor('../_playerFrame/default.lua')
t[#t+1] = LoadActor('../_mouse.lua')

return t