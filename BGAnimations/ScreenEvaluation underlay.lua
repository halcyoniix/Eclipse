local t = Def.ActorFrame {}

t[#t+1] = LoadActorWithParams('_parallax.lua', {image = GAMESTATE:GetCurrentSong():GetBackgroundPath(), diffuse = {0.5, 0.5, 0.5, 1}})

return t