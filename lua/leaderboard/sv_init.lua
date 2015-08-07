AddCSLuaFile( "leaderboard/cl_init.lua" )
AddCSLuaFile( "leaderboard/misc.lua" )
AddCSLuaFile( "leaderboard/config/lb_config.lua" )
AddCSLuaFile( "leaderboard/vgui/guiMenu.lua" )
AddCSLuaFile( "leaderboard/vgui/controlmenu.lua" )
AddCSLuaFile( "leaderboard/vgui/elements/switch.lua" )
AddCSLuaFile( "leaderboard/vgui/elements/rankbar.lua" )
AddCSLuaFile( "leaderboard/vgui/elements/fancyavatar.lua" )
AddCSLuaFile( "leaderboard/vgui/elements/dfrom.lua" )

resource.AddFile("resources/fonts/Dense-Regular.otff")

include( "leaderboard/data/data.lua" )
include( "leaderboard/config/cb_config.lua" )
include( "leaderboard/data/DataHandler.lua" )
include( "leaderboard/data/score.lua" )
include( "leaderboard/data/ScoringHandler.lua" )

//Create the data directory, if it doesn't already exist
if ( file.IsDir("leaderboardData", "DATA") == false ) then
	file.CreateDir("leaderboardData")
end

--[[TODO:

Comment all Code                                                        [--------------]
Redesign controlmenu                                                    [##------------]
Redesign Gui - In Progress                                              Complete
Go through code and change unneeded globals into locals                 [####----------]
Change steamid into steamid64 (Write code to auto convert current data) [--------------]
Create search bar section (Allows comparing of users as well)           [--------------]

]]--
