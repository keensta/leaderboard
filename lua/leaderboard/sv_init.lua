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

Comment all Code                                                        [--------------]
Redesign controlmenu                                                    [#######--]  (With new gui redesgin this might need redesigning again we will see - Maybe intergrate it into new design gui rather then extra interface pop up)
Re redesign Gui - In Progress                                              [-----------]
Change steamid into steamid64 (Write code to auto convert current data)  Complete (In Data.lua Doesn't auto start needs user interaction)
Create search bar section (Allows comparing of users as well)           [--------------] (With new Re Redesign of gui this will be implemented, have to also implement server code to do searching and return data to client)

]]--
