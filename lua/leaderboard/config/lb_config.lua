--Title at top right of leaderboard
LB.LeaderboardTitle = "Traitors United - Leaderboards"

--Defult Key to open with Goto -> (http://wiki.garrysmod.com/page/Enums/KEY) for all key names
LB.Key = KEY_F4

--Default board that is displyed when a user opens the leaderboards for the first time. After that it opens on what they closed it on
LB.DefaultBoard = "Innocent Kills"

--This is the amount of postions the board will display. Anyone after this will not be listed.
LB.MaxPos = 100 

--All those here will be able to see the Control Menu (SuperAdmins see by default)  Current SteamIDs are there to show you how it works  
LB.Admins = { "STEAM_0:1:61028337" } 

--What catagorys should be loaded and shown
LB.boardCats = { "TTT", "Weapons", "Other", }


--Contain's all boards and there releated catagory (Mainly for vgui, However is used to check that a board should be created) **Table Layout** (TableName, Dtree SubZone)
LB.boardRef = { ["Innocent Kills"] = "TTT", ["Traitor Kills"] = "TTT", ["Detective Kills"] = "TTT", ["Knife Kills"] = "Weapons", ["Explosive Kills"] = "TTT", ["TimePlayed"] = "Other", ["Suicides"] = "Other", 
	["Headshot Kills"] = "TTT",	["Crowbar Kills"] = "Weapons", ["Harpoon Kills"] = "Weapons", ["Knife Kills"] = "Weapons", ["Shuriken Kills"] = "Weapons", ["Assault Rifle Kills"] = "Weapons", ["Sniper Rifle Kills"] = "Weapons", ["Shotgun Kills"] = "Weapons", ["SMG Kills"] = "Weapons", ["Heavy Gun Kills"] = "Weapons", ["Pistol Kills"] = "Weapons", ["Prop Kills"] = "TTT", ["Incendiary Kills"] = "TTT" }


--Descriptions for each leaderboard ranking 
LB.Descriptions = { ["Innocent Kills"] = "All those poor innocent terrorists have been slain by \nthese beasts.", ["Traitor Kills"] = "Good news, these heroes have killed some of them \nbloody traitors. May justice rule the land!", 
	["Knife Kills"] = "Many foes, one strike. WUJU style!", ["Detective Kills"] = "ANARCHY!", ["Suicides"] = "They just couldn't take it any more. RIP",
	["Explosive Kills"] = "What's that noise?", ["TimePlayed"] = "And you have no life.", ["Crowbar Kills"] = "He swings for it, Oh he hit's it out of the park!!",
	["Headshot Kills"] = "Bang! Headshot", ["Total Score"] = "Just wow, just wow", ["Harpoon Kills"] = "The ultimate javelin thrower.", ["Knife Kills"] = "When you're too cheap to use a real weapon.", ["Shuriken Kills"] = "A ninja's favorite weapon.", ["Assault Rifle Kills"] = "Kills with assault rifles.", ["Sniper Rifle Kills"] = "Kills with sniper rifles.", ["Shotgun Kills"] = "Kills with shotguns.", ["SMG Kills"] = "Kills with sub-machine guns.", ["Heavy Gun Kills"] = "Kills with heavy guns.", ["Pistol Kills"] = "Kills with pistols and handguns.", ["Prop Kills"] = "Kills with props", ["Incendiary Kills"] = "Kills with fire" }


--Coloring Gui - Most Elements can be colored

--Main frame Coloring
LB.Background = Color(53, 70, 92)
	LB.TopBar = Color(22, 37, 57)
	LB.LeftBar = Color(0, 25, 51)
	LB.RankInfoBar = Color(153, 0, 0)
	LB.RankingBar = Color(102, 0, 0) -- Bar that contains # Name and InnocentKills(OR what ever is selected)

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
LB.MenuHighlight = Color(75, 105, 145)


--Custom element colors
	--RankBar
	LB.RankHighlight = Color(0, 25, 51)
	LB.RankBarText = Color(192, 192, 192)
    LB.RankBarTextBg = Color(53, 70, 92)

	--Switch
	LB.SwitchBg = Color(70, 70, 70, 225)
	LB.SwitchText = Color(255, 255, 255, 205)
	LB.SwitchActive = Color(153, 0, 0)