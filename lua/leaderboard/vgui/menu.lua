	
--THIS IS OLD GUI CODE AND NO LONGER USED--
--YOU CAN DELETE THIS FILE IF YOU WISH--

include( "leaderboard/misc.lua" )
include( "leaderboard/vgui/controlmenu.lua" )
include( "leaderboard/config/lb_config.lua" )
include( "leaderboard/vgui/elements/switch.lua" )
include( "leaderboard/vgui/elements/rankbar.lua" )

local X = 300
local Y = 300

local sb = sb or {}
local scores = {}
local banlist = {}
local dtreeDone = false

local lastOpened = "Innocent Kills"
local tmpLast = false
tmpSwitch = nil 
	
--Open up and builds the main menu part
-- Ply: The player object this is the person openning the board
-- Scoreboard: Most important part keeps hold of all the data on all the boards
function OpenMenu(ply, scoreboard)
	sb = scoreboard
	dtreeDone = false

	net.Start("LB_RequestBanlist")
	net.SendToServer()

	net.Receive("LB_SendBanlist", function(le) 
		banlist = net.ReadTable()
	end )

	local mainPanel = vgui.Create("DFrame")
	mainPanel:SetSize(650, 500)
	mainPanel:SetPos(X, Y)
	mainPanel:SetTitle("")
	mainPanel:SetVisible(true)
	mainPanel:SetDraggable(true)
	mainPanel:SetKeyBoardInputEnabled(true)
	mainPanel:MakePopup()

	mainPanel.Paint = function(_, w, h)
		surface.SetDrawColor(242,240,240, 250)
        surface.DrawRect(0, 0, w, h)
        surface.DrawOutlinedRect(0, 0, w, h)
        surface.DrawLine(0, 23, w, 23)

		surface.SetDrawColor(LB.ColorScheme)
		surface.DrawRect(0,0, mainPanel:GetWide(), 30)
		
		surface.SetFont("LB_Title")
		surface.SetTextColor(255,255,255,250)
		surface.SetTextPos(3, 3)
		surface.DrawText(LB.LeaderboardTitle)
	end

	tmpSwitch = vgui.Create("LBSwitch", mainPanel)
	tmpSwitch:SetPos(35,35)
	tmpSwitch:SetSize(100,20)
	tmpSwitch:SetBothText("All Time", "Monthly")
	
	if ( tmpLast ~= nil ) then
		tmpSwitch:SetState(tmpLast)
	end

	local callback = function() updateLeaderboard(lastOpened, mainPanel, ply, false, tmpSwitch:IsActivated()) end 
	tmpSwitch:SetCallback(callback)

	createDTree(mainPanel, ply, tmpSwitch)
	updateLeaderboard(lastOpened, mainPanel, ply, true, tmpLast)
end

--Creates the selection of boards that contain sub catagorieys 
function createDTree(mainPanel, ply, tmpSwitch)

	if ( dtreeDone ) then
		return
	end 

	local dtree = vgui.Create("DTree", mainPanel)
	dtree:SetPos(10, 60) --10, 40
	dtree:SetPadding(5)
	dtree:SetSize(150, 420) --150, 440

	local pvp = dtree:AddNode( "PvP" )
	local misc = dtree:AddNode( "Misc" )
	local fun = dtree:AddNode( "Fun" )
	local nodes = {}

	net.Start("LB_GetRefName")
	net.SendToServer()


	net.Receive("LB_SendRefName", function()
		refName = net.ReadTable()

		if ( refName ~= nil ) then
			
			for k, v in pairs(refName) do
				
				local node = nil

				if ( v == "pvp" ) then
					node = pvp:AddNode( k )
					node.DoClick = function() updateLeaderboard(k, mainPanel, ply, false, tmpSwitch:IsActivated()) end
				end

				if ( v == "misc" ) then
					node = misc:AddNode( k )
					node.DoClick = function() updateLeaderboard(k, mainPanel, ply, false, tmpSwitch:IsActivated()) end
				end

				if ( v == "fun" ) then
					node = fun:AddNode( k )
					node.DoClick = function() updateLeaderboard(k, mainPanel, ply, false, tmpSwitch:IsActivated()) end
				end

				nodes[node] = true

			end

		end
	end )

	--SuperAdmins or keensta :)
	if ( ply:IsSuperAdmin() or contains(LB.Admins, ply:SteamID()) ) then
		local control = dtree:AddNode( "ControlMenu" )

		control.DoClick = function() createControlMenu(ply) end
	end 

	dtreeDone = true
end


function updateLeaderboard(selectedOption, mainPanel, ply, intilizeGui, tmp)

	if ( selectedOption == nil || selectedOption == "" ) then
		selectedOption = lastOpened
	end

	lastOpened = selectedOption
	tmpLast = tmp

	if ( getTable(selectedOption, tmp) ~= nil ) then
		scores = getTable(selectedOption, tmp)
	else 
		scores = nil
	end

	if ( intilizeGui ~= false ) then
		title = vgui.Create("DLabel", mainPanel)
		desc = vgui.Create("DLabel", mainPanel)
		playerRank = vgui.Create("DLabel", mainPanel)
		SPanel = vgui.Create("DScrollPanel", mainPanel)
		bar = vgui.Create("DPanel", mainPanel)
	end

	local typeN = "All Time"

	if ( tmp == true ) then
		typeN = "Monthly"
	end

	title:SetPos(170, 35)
	title:SetSize(250, 30)
	title:SetTextColor( Color(0,0,0,255) )
	title:SetFont("LB_Menu")
	title:SetText(selectedOption .. " - " .. typeN)

	desc:SetPos(180, 45)
	desc:SetSize(450, 65)
	desc:SetTextColor( Color(170,170,170,255) )
	desc:SetFont("LB_MenuDesc")
	desc:SetText(getDescription(selectedOption))

	playerRank:SetPos(560, 45)
	playerRank:SetSize(140, 30)
	playerRank:SetTextColor( Color(175,175,175,255) )
	playerRank:SetFont("LB_MenuDesc")
	playerRank:SetText("Rank# N/A")

	--Scroll panel for ranks positions
	SPanel:Clear() -- Clearing just incase it's been used already
	SPanel:SetSize(460 , 390)
	SPanel:SetPos(170, 105)

	pos = 1
	Ypos = 20
	barHolder = {}

	if ( scores == nil ) then 
		SPanel:Clear() 
		bar:SetVisible(false) --SetVisible false so we don't actually delete the element itself using :Remove()
		return 
	end

	for k, v in spairs(scores, function(t,a,b) return t[b] < t[a] end) do

		if ( pos > LB.MaxPos ) then break end

		local nickname = getNickname(k)
		
		if ( isBanned(nickname) == false ) then
			
			if ( nickname == ply:Nick() or tostring(k) == ply:SteamID() ) then
				playerRank:SetText("Rank# " .. pos)
			end

			local rankB = vgui.Create("LBRankBar", SPanel)
			rankB:SetPos(0, Ypos)
			rankB:SetPosition(pos)
			rankB:SetScore(v)
			rankB:SetData(k, nickname)
			rankB:SetBoard(selectedOption)

			barHolder[rankB] = true
    		SPanel:AddItem(rankB)

    		if ( pos <= 3 ) then
    			Ypos = Ypos + 35
    		else
    			Ypos = Ypos + 27
    		end

    		pos = pos + 1
		end
	end

	--Put this here so ranks disapear behind it rather then infrount
	bar:SetPos(170, 105)
	bar:SetSize(mainPanel:GetWide() - 185, 25)
	bar:SetVisible(true)

	bar.Paint = function(_, w, h)
		surface.SetDrawColor(LB.ColorScheme)
		surface.DrawRect(0, 0, w - 20, h)

		surface.SetTextColor( Color(255,255,255,255) )
		surface.SetFont("LB_Board")

		--Postion Character
		surface.SetTextPos(10, h - 20)
		surface.DrawText("#")

		--Name Text
		surface.SetTextPos(55, h - 20)
		surface.DrawText("Name")

		--Ranking Reasons
		// surface.SetTextPos(360, h - 20)
		// surface.DrawText(selectedOption)
		draw.SimpleText(selectedOption, "LB_Board", 390, h - 20, Color(255,255,255,255), TEXT_ALIGN_CENTER)
	end
end

function isBanned(userName)
	if ( banlist == nil ) then
		return false
	end

	if ( banlist[userName] ~= nil ) then
		return true
	end
	
	return false
end

function getTable(tableName, tmp)

	if ( tmp == true ) then
		tmp = "true"
	else
		tmp = "false"
	end

	if ( sb == nil ) then
		return nil
	end

	if ( sb[tableName] ~= nil and sb[tableName][tmp] ~= nil ) then
	 	return sb[tableName][tmp]
	end

 	return nil
end

function getDescription(selectedOption)
	return LB.Descriptions[selectedOption] or "Hmmm, It seem's nobody has set this description correctly."
end