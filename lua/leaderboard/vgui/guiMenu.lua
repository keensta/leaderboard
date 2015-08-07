include( "leaderboard/misc.lua" )
include( "leaderboard/vgui/controlmenu.lua" )
include( "leaderboard/config/lb_config.lua" )
include( "leaderboard/vgui/elements/switch.lua" )
include( "leaderboard/vgui/elements/rankbar.lua" )

local X = 100
local Y = 75
local isOpen = false

local scores = nil
local banlist = {}

local guiElements = {}

local lastOpened = LB.DefaultBoard
local tmpLast = false
local received = false
local sT = 0

--[[--------------------------------------------------
		OpenMenu - ply

		ply -> Player that has opened the leaderboard
---------------------------------------------------]]
function OpenGuiMenu(ply)

	--Get BanList Start
	net.Start("LB_RequestBanlist")
	net.SendToServer()

	net.Receive("LB_SendBanlist", function(le)
		banlist = net.ReadTable()
	end )
	--Get BanList End

	local lbMain = vgui.Create("DFrame")
	lbMain:SetSize(750, 750)
	lbMain:SetPos(X, Y)
	lbMain:SetTitle("")
	lbMain:SetVisible(true)
	lbMain:SetDraggable(true)
	lbMain:ShowCloseButton(false)
	lbMain:MakePopup()

	isOpen = true

	lbMain.Paint = function(_, w, h)
		surface.SetDrawColor(LB.Background)
		surface.DrawRect(0, 0, w, h)

		--Start Drawing main Box's

		--Top Bar
		surface.SetDrawColor(LB.TopBar)
		surface.DrawRect(0,0, w, 65)

		--Left Bar
		surface.SetDrawColor(LB.LeftBar)
		surface.DrawRect(0,65, 125, h)

		--RankInfo Bar
		draw.RoundedBox(0, 145, 85, w - 165, 40, LB.RankInfoBar)

		--Draw Title in top left corner
		surface.SetFont("LB_Title")
		surface.SetTextColor(LB.TitleColor)
		surface.SetTextPos(3, 3)
		surface.DrawText(LB.LeaderboardTitle)

		--Draw Opening Player Stuff
		surface.SetFont("LB_Desc_L")
		surface.SetTextColor(LB.MenuText)
		surface.SetTextPos(w - 115, 20)
		surface.DrawText(ply:Nick())

		local plyAv = vgui.Create("FancyAvatarImage", lbMain)
		plyAv:SetSize(64, 64)
		plyAv:SetPos(w - 180, -2.5)
		plyAv:SetMaskSize(32)
		plyAv:SetSteamID(ply:SteamID(), 64)
	end 

	local closeButton = vgui.Create("DButton", lbMain)
	closeButton:SetText("")
	closeButton:SetPos(727, 3)
	closeButton:SetSize(19, 19)

	closeButton.Paint =  function(_, w, h)
		--Draw Close button
		surface.SetDrawColor( Color(192, 57, 43) )
		draw.NoTexture()
		surface.DrawPoly(MakeCirclePoly(w/2,h/2,8,nil,0,360,32))

		--Draw X for close button
		draw.SimpleText('r', 'marlett', 2.5, 2, Color(32, 36, 39))
	end

	closeButton.DoClick = function()
		isOpen = false
		lbMain:Close()
	end

	local boardTitle = vgui.Create("DLabel", lbMain)
	surface.SetFont("LB_Board_Title")
	local w, h = surface.GetTextSize(lastOpened)
	boardTitle:SetPos((lbMain:GetWide() / 2 - 125) - w/2, 35)
	boardTitle:SetSize(150, 30)
	boardTitle:SetFont("LB_Board_Title")
	boardTitle:SetColor(LB.BoardTitle)
	boardTitle:SetText(lastOpened)

	local rankTitle = vgui.Create("DLabel", lbMain)
	rankTitle:SetPos(185, 90)
	rankTitle:SetSize(150,30)
	rankTitle:SetFont("LB_Desc")
	rankTitle:SetColor(LB.TitleDesc)
	rankTitle:SetText("Current Rank")

	local rankDesc = vgui.Create("DLabel", lbMain)
	rankDesc:SetPos(275, 90)
	rankDesc:SetSize(200,30)
	rankDesc:SetFont("LB_Desc_Info")
	rankDesc:SetColor(LB.MenuDesc)
	rankDesc:SetText("UnRanked")

	local scoreTitle = vgui.Create("DLabel", lbMain)
	scoreTitle:SetPos(515, 90)
	scoreTitle:SetSize(150,30)
	scoreTitle:SetFont("LB_Desc")
	scoreTitle:SetColor(LB.TitleDesc)
	scoreTitle:SetText("Total Score")

	local scoreDesc = vgui.Create("DLabel", lbMain)
	scoreDesc:SetPos(605, 90)
	scoreDesc:SetSize(200,30)
	scoreDesc:SetFont("LB_Desc_Info")
	scoreDesc:SetColor(LB.MenuDesc)
	scoreDesc:SetText("No Score")

	local tmpSwitch = vgui.Create("LBSwitch", lbMain)
	tmpSwitch:SetPos(12.5, 75)
	tmpSwitch:SetSize(100, 20)
	tmpSwitch:SetBothText("All Time", "Monthly")

	if ( tmpLast ~= nil ) then
		tmpSwitch:SetState(tmpLast)
	end

	local callback = function() updateBoard(lastOpened, lbMain, ply, false, tmpSwitch:IsActivated()) end
	tmpSwitch:SetCallback(callback)

	guiElements["Main"] = lbMain
	guiElements["BoardTitle"] = boardTitle
	guiElements["RankDesc"] = rankDesc
	guiElements["ScoreDesc"] = scoreDesc
	guiElements["TempSwitch"] = tmpSwitch

	createTree(ply, lbMain)
	updateBoard(lastOpened, lbMain, ply, true, tmpLast)
end

--[[--------------------------------------------------
		createTree - ply, mainPanel

		ply -> Player that has opened the leaderboard
		
		lbMain -> Main frame so we can build ontop of it.

		We create the tree on the left gui bar so people
			can navigate through the boards.
---------------------------------------------------]]
function createTree(ply, lbMain)
	local boardList = vgui.Create("DListLayout", lbMain)
	boardList:SetPos(0, 115)
	boardList:SetSize(125, 500)
	boardList.Paint = function() end

	local panelOptions = vgui.Create("DPanelList")
	panelOptions:SetPos(0, 115)
	panelOptions:SetSpacing(10)
	panelOptions:SetWide(125)
	panelOptions:SetHeight(500)

	boardList:Add(panelOptions)

	cats = {}
	catsPanel = {}

	for _, v in pairs(LB.boardCats) do
		local cat = nil
		local catPanel = nil

		cat = vgui.Create("DForm")
		cat:SetName("")
		cat:SetPos(0,0)
		cat:SetSize(125, 40)
		cat:SetExpanded(false)

		cat.Paint = function(_, w, h)
			--We check if the category or it's it's holder is being hovered over
			if (  cat:IsHovered() or cat:IsChildHovered( 3 ) ) then
				surface.SetDrawColor(LB.MenuHighlight)
				surface.DrawRect(0, 0, w, h)
			end


			surface.SetFont("LB_Menu_Title")

			local text = tostring(v)	
			local textW, textH = surface.GetTextSize(text)
			local x = 61

			x = x - (textW / 2)

			surface.SetTextPos(math.ceil(x), -2)
			surface.SetTextColor(LB.MenuText)
			surface.DrawText(v)
		end

		catPanel = vgui.Create("DPanel")
		catPanel:SetPos(0,0)
		catPanel:SetWide(125)
		catPanel:SetHeight(100)
		catPanel.Paint = function(_, w, h)
		end

		cat:AddItem(catPanel)
		panelOptions:AddItem(cat)

		cats[v] = cat
		catsPanel[v] = catPanel
	end

	--Control Menu

	if ( contains(LB.Admins, ply:SteamID()) ) then
		local cat = nil

		cat = vgui.Create("DButton", panelOptions)
		cat:SetDrawBackground(false)
		cat:SetDrawBorder(false)
		cat:SetText(" ")
		cat:SetPos(0,0)
		cat:SetSize(50, 40)

		cat.Paint = function(_, w, h)

			surface.SetFont("LB_Menu_Title")

			local text = "Control Menu"
			local textW, textH = surface.GetTextSize(text)
			local x = 61

			if (  cat:IsHovered() or cat:IsChildHovered( 3 ) ) then
				surface.SetDrawColor(LB.MenuHighlight)
				surface.DrawRect(0, 0, w, textH)
			end

			x = x - (textW / 2)

			surface.SetTextPos(math.ceil(x), -2)
			surface.SetTextColor(LB.MenuText)
			surface.DrawText(text)
		end

		cat.DoClick = function()
			createControlMenu(ply)
		end
	
		panelOptions:AddItem(cat)

		cats["Control Menu"] = cat
	end
	--Control menu end

	boards = {}
	catY = {} --We do this so they all stick together nicly otherwise they will all use the same Y value and not line up correctly

	for k, v in pairs(LB.boardRef) do
		local labelB = nil
		local catPanelOp = nil
		local y = catY[v]

		if ( y == nil ) then
			y = 0
		end

		catPanelOp = catsPanel[v]

		if ( catPanelOp ~= nil ) then
			labelB = vgui.Create("DButton", catPanelOp)
			labelB:SetDrawBackground(false)
			labelB:SetDrawBorder(false)
			labelB:SetPos(0, y)
			labelB:SetSize(110, 15)
			labelB:SetFont("LB_Desc")
			labelB:SetColor(Color(255, 255, 255))
			labelB:SetText("        ")
			labelB:SetTooltip(getDescription(k))

			labelB.DoClick = function( self, val )
				local switch = guiElements["TempSwitch"]
				updateBoard(k, lbMain, ply, false, switch:IsActivated())
			end

			labelB.Paint = function(_, w, h)
				surface.SetTextPos(18, 0)
				surface.SetFont("LB_Desc")
				surface.SetTextColor(LB.MenuText)
				surface.DrawText(k)
			end

			y = y + 20
			catY[v] = y

			boards[k] = labelB
		end
	end

	--Adjust Panel Hights (Stops them being extremely large on opening when not needed)
	for k, v in pairs(catY) do
		local catPanelOp = catsPanel[k]

		if ( catPanelOp != nil ) then
			catPanelOp:SetHeight(v)
		end
	end

end

--[[--------------------------------------------------
		updateBoard - selectedBoard, lbMain, ply, intilizeGui, tmp
---------------------------------------------------]]
function updateBoard(selectedBoard, lbMain, ply, intilizeGui, tmp)
	
	if ( selectedBoard == nil or selectedBoard == "" ) then
		selectedBoard = lastOpened
	end

	lastOpened = selectedBoard
	tmpLast = tmp

	if ( intilizeGui ~= false ) then
		SPanel = vgui.Create("DScrollPanel", lbMain)
		bar = vgui.Create("DPanel", lbMain)
		loading = vgui.Create("DLabel", lbMain)
	end

	local boardTitle = guiElements["BoardTitle"]
	boardTitle:SetPos((lbMain:GetWide() / 2) - string.len(lastOpened), 35)
	boardTitle:SetText(lastOpened)

	loading:SetSize(100,100)
	loading:SetPos(375, 350)
	loading:SetFont("LB_Title")
	loading:SetText("Loading...")
	loading:SetVisible(true)

	--Set Up scrollpanel for ranking postions
	SPanel:Clear() -- Just incase it contains old data still
	SPanel:SetSize(585, (lbMain:GetTall() - 180))
	SPanel:SetPos(145, 180)

	bar:SetPos(145, 155)
	bar:SetSize(lbMain:GetWide() - 165, 25)
	bar:SetVisible(true)

	bar.Paint = function(_, w, h)
		surface.SetDrawColor(LB.RankingBar)
		surface.DrawRect(0, 0, w, h)

		surface.SetTextColor(LB.RankBarText)
		surface.SetFont("LB_Board_Bold")

		--Postion Character
		surface.SetTextPos(12.5, h - 20)
		surface.DrawText("#")

		--Name Text
		surface.SetTextPos(120, h - 20)
		surface.DrawText("Username")

		--Ranking Reasons
		draw.SimpleText(selectedBoard, "LB_Board_Bold", 430, h - 20, LB.RankBarText, TEXT_ALIGN_CENTER)
	end

	--Start grabbing board data

	net.Start("LB_GetTable")
		net.WriteString(lastOpened)
		net.WriteBit(tmp)
		received = false
	net.SendToServer()

	net.Receive("LB_SendTable", function(le)
		local stringCheck = net.ReadString()

		if ( stringCheck == "tableNil" ) then
			scores = nil
		end

		if ( stringCheck == "tableFine") then
			local dataLength = net.ReadUInt(32)
			local boardDecompressed = util.Decompress(net.ReadData(dataLength))
			scores = util.JSONToTable(boardDecompressed)
		end

		received = true

		if ( lbMain ~=  nil ) then
			updateView(SPanel, loading, scores, ply)
		end
	end )

end

--[[--------------------------------------------------
		updateView - username

		username -> username to check for ban status
---------------------------------------------------]]
function updateView(SPanel, loading, scores, ply)
	pos = 1
	Ypos = 5
	barHolder = {}
	plyUpdated = false
		
	if ( scores == nil ) then
		SPanel:Clear()
		updateData(nil, 0)
		loading:SetText("No Data")
		return
	end

	loading:SetVisible(false)

	for k, v in spairs(scores, function(t,a,b) return t[b] < t[a] end) do

		if ( pos > LB.MaxPos ) then break end

		local nickname = getNickname(k)
		
		if ( isBanned(nickname) == false ) then
			
			if ( nickname == ply:Nick() or tostring(k) == ply:SteamID() ) then
				updateData(pos, v)
				plyUpdated = true
			end

			local rankB = vgui.Create("LBRankBar", SPanel)
			rankB:SetPos(0, Ypos)
			rankB:SetPosition(pos)
			rankB:SetScore(v)
			rankB:SetData(k, nickname)
			rankB:SetBoard(lastOpened)

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

	if ( plyUpdated == false ) then
		score = 0

		if ( scores[ply:SteamID()] ~= nil ) then
			score = scores[ply:SteamID()]
		end

		updateData(nil, score)
	end
end

--[[--------------------------------------------------
		isBanned - username

		username -> username to check for ban status
---------------------------------------------------]]
function isBanned(userName)
	if ( banlist == nil ) then
		return false
	end

	if ( banlist[userName] ~= nil ) then
		return true
	end
	
	return false
end

--[[--------------------------------------------------
		getDescription - selectedOption

		selectedOption -> The board name that you want the
			description for.
		
---------------------------------------------------]]
function getDescription(selectedOption)
	return LB.Descriptions[selectedOption] or "Hmmm, It seem's nobody has set this description correctly."
end

--[[--------------------------------------------------
		updateData - pos, score

		pos -> Postion on board of the player
		score -> Current players score on the board
---------------------------------------------------]]
function updateData(pos, score)
	local rankDesc = guiElements["RankDesc"]
	local scoreDesc = guiElements["ScoreDesc"]

	if( pos == nil ) then
		rankDesc:SetText("Unranked")
	else
		rankDesc:SetText(tostring(pos) .. " out of " .. tostring(LB.MaxPos))
	end

	scoreDesc:SetText(tostring(score))

	guiElements["RankDesc"] = rankDesc
	guiElements["ScoreDesc"] = scoreDesc
end

--[[--------------------------------------------------
		GuiMenuIsOpen - 

		Checks if the menu is already open and returns it
		
---------------------------------------------------]]
function GuiMenuIsOpen()
	return isOpen
end

function CloseGuiMenu()
	local lbMain = guiElements["Main"]

	isOpen = false
	lbMain:Close()
end
