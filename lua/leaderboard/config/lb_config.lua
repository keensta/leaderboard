--Title at top right of leaderboard
LB.LeaderboardTitle = "Test Server - TTT Leaderboard"

--What saving and loading method we are using
LB.DefaultDataHandler = "json"

--Defult Key to open with Goto -> (http://wiki.garrysmod.com/page/Enums/KEY) for all key names
LB.Key = KEY_F4

--Default board that is displyed when a user opens the leaderboards for the first time. After that it opens on what they closed it on
LB.DefaultBoard = "Innocent Kills"

--This is the amount of postions the board will display. Anyone after this will not be listed.
LB.MaxPos = 100 

--All those here will be able to see the Control Menu (SuperAdmins see by default)  Current SteamIDs are there to show you how it works  
LB.Admins = { "STEAM_0:1:42143180", } 

--What catagorys should be loaded and shown
LB.boardCats = { "PvP", "Misc", "Fun", }


--Contain's all boards and there releated catagory (Mainly for vgui, However is used to check that a board should be created) **Table Layout** (TableName, Dtree SubZone)
LB.boardRef = { ["Innocent Kills"] = "PvP", ["Traitor Kills"] = "PvP", ["Detective Kills"] = "PvP", ["Knife Kills"] = "PvP", ["C4 Kills"] = "PvP", ["TimePlayed"] = "Misc", ["Suicides"] = "Misc", 
	["Headshot Kills"] = "Fun", ["Crowbar Kills"] = "Fun", ["Total Score"] = "Misc"}


--Descriptions for each leaderboard ranking 
LB.Descriptions = { ["Innocent Kills"] = "All those poor innocent terrorists have been slain by \nthese beasts.", ["Traitor Kills"] = "Good news, these heroes have killed some of them \nbloody traitors. May justice rule the land!", 
	["Knife Kills"] = "Many foes, one strike. WUJU style!", ["Detective Kills"] = "ANARCHY!", ["Suicides"] = "They just couldn't take it any more. RIP",
	["C4 Kills"] = "What's that noise?", ["TimePlayed"] = "And you have no life.", ["Crowbar Kills"] = "He swings for it, Oh he hit's it out of the park!!",
	["Headshot Kills"] = "Bang! Headshot", ["Total Score"] = "Too good for us norms!"}


--Coloring Gui - Most Elements can be colored

--Main frame Coloring
LB.Background = Color(236, 236, 236)
	LB.TopBar = Color(40, 44, 45)
	LB.LeftBar = Color(45, 62, 80)
	LB.RankInfoBar = Color(39, 174, 97)
	LB.RankingBar = Color(220, 224, 225) -- Bar that contains # Name and InnocentKills(OR what ever is selected)

--Control Menu Coloring
LB.CMBackground = Color(236, 236, 236)
	LB.CMTopBar = Color(40, 44, 45)
	LB.ControlButton = Color(39, 174, 97)
	LB.CMMenuBar = Color(45, 62, 80)

--Standard Text Colors
LB.TitleColor = Color(236, 236, 236) --Color for LB.LeaderboardTitle
LB.MenuText = Color(236, 236, 236) --All normal menu based text, except ranking entries
LB.BoardTitle = Color(255, 255, 255) -- Current Selected board text so "Innocent Kills or Traitor Kills " Etc
LB.TitleDesc = Color(255, 255, 255, 255) --This is the title to a description if it has a title that is ""
LB.MenuDesc = Color(255, 255, 255, 255) --This is all descriptive textes like "4 out of 100"


--Button Highlighting code
LB.MenuHighlight = Color(53, 152, 219)


--Custom element colors
	--RankBar
	LB.RankHighlight = Color(53, 152, 219)
	LB.RankBarText = Color(128, 140, 140)
	LB.RankBarTextBg = Color(220, 224, 225)

	--Switch
	LB.SwitchBg = Color(70, 70, 70, 225)
	LB.SwitchText = Color(255, 255, 255, 205)
	LB.SwitchActive = Color(39, 174, 97)


-- New colors

--Backgrounds Main

	--Header
	LB.HeaderBackground = Color(228, 77, 80)
	--Button bar
	LB.ButtonBarBackground = Color(139, 139, 139, 180)
	--Leaderboard Data 
	LB.DataBackground = Color(93, 98, 98, 180)

--Text Colors
	LB.TitleColor = Color(255, 255, 255) -- Color for LB.LeaderboardTitle (Title in top left)
	

--Custom Elements
	--RankBar
	LB.RankHighlight = Color(163, 77, 80)
	LB.RankBarText = Color(255, 255, 255)
	LB.RankBartextBg = Color(93, 98, 98, 180)