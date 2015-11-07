AddCSLuaFile( "leaderboard/cl_init.lua" )
AddCSLuaFile( "leaderboard/misc.lua" )
AddCSLuaFile( "leaderboard/config/lb_config.lua" )
AddCSLuaFile( "leaderboard/vgui/guiMenu.lua" )
AddCSLuaFile( "leaderboard/vgui/controlmenu.lua" )
AddCSLuaFile( "leaderboard/vgui/elements/switch.lua" )
AddCSLuaFile( "leaderboard/vgui/elements/rankbar.lua" )
AddCSLuaFile( "leaderboard/vgui/elements/fancyavatar.lua" )

resource.AddFile("resources/fonts/Dense-Regular.otff")
resource.AddFile("resources/fonts/Geometria-Light.otf")
resource.AddFile("resources/fonts/SourceCodePro-Light.otf")
resource.AddFile("resources/fonts/SourceCodePro-Medium.otf")

include( "leaderboard/data/data.lua" )
include( "leaderboard/config/lb_config.lua" )
include( "leaderboard/config/cb_config.lua" )
include( "leaderboard/data/score.lua" )
include( "leaderboard/data/ScoringHandler.lua" )


//Create the data directory, if it doesn't already exist
if ( file.IsDir("leaderboarddata", "DATA") == false ) then
	file.CreateDir("leaderboarddata")
end

// //Move old dir to new one if they used older version
if ( file.IsDir("leaderboardData", "DATA") == true ) then

	local files, dirs = file.Find("leaderboardData", "DATA")

	for k, v in pairs(files) do
		file.Write("leaderboarddata/"..v, file.Read("leaderboardData/"..v))
	end

end

--[[TODO:
]]--
