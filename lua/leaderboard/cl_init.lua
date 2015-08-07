include( "config/lb_config.lua" )
include( "leaderboard/vgui/guiMenu.lua")

--Create all font's for VGUI
hook.Add("Initialize", "CreateFont", function()
	--Main title name
	surface.CreateFont( "LB_Title", {
		font = "Geometria-Light",
		size = 26,
		weight = 500,
	})

	--Menu Title (Ex: PvP, Misc, Fun)
	surface.CreateFont( "LB_Menu_Title", {
		font = "SourceCodePro-Medium",
		size = 23,
		weight = 545,
	})

	--Menu Item (Ex: Innocent Kills, Traitor Kills, Headshots, TimePlayed)
	surface.CreateFont( "LB_Menu_Item", {
		font = "SourceCodePro-Light",
		size = 16,
		weight = 530,
	})

	--All descriptive text
	surface.CreateFont( "LB_Desc", {
		font = "SourceCodePro-Light",
		size = 16,
		weight = 535,
	})

	--Descriptive text title if the descriptive text has one that is. (UNUSED)
	surface.CreateFont( "LB_Desc_Info", {
		font = "Dense-Regular",
		size = 23,
		weight = 590,
	})

	--Slightly larger version of LB_Desc (UNUSED)
	surface.CreateFont( "LB_Desc_L", {
		font = "Dense-Regular",
		size = 19,
		weight = 550,
	})

	--This is for the name of the selected board so "Innocent Kills or Traitor Kills" Etc
	surface.CreateFont( "LB_Board_Title", {
		font = "Geometria-Light",
		size = 23,
		weight = 550,
	})

	--Used for the rankbar gui to display information in the ranking part 
	surface.CreateFont( "LB_Board", {
		font = "SourceCodePro-Light",
		size = 18,
		weight = 530,
	})

	--Bolder version of LB_Board
	surface.CreateFont( "LB_Board_Bold", {
		font = "SourceCodePro-Medium",
		size = 15,
		weight = 650,
	})
end)

net.Receive("LB_ToggleMenu", function(le)
	OpenGuiMenu(LocalPlayer())
end )

--Thanks to DamageLogs(Tommy228) for this code Check it out -> (http://facepunch.com/showthread.php?t=1416843)

LB.pressed_key = false
function LB:Think()
	if input.IsKeyDown(self.Key) and not self.pressed_key then
		self.pressed_key = true

		if (GuiMenuIsOpen() == false) then
			OpenGuiMenu(LocalPlayer())
		else
			CloseGuiMenu()
		end
		
	elseif self.pressed_key and not input.IsKeyDown(self.Key) then
		self.pressed_key = false
	end
end

hook.Add("Think", "LB_Think", function()
	LB:Think()
end)
