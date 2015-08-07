--UI needs a redesign
include( "leaderboard/config/lb_config.lua" )

local X = 400
local Y = 400

local createdBefore = false
local activePanel = nil
local clicked = false

function createControlMenu(ply)
	if ( createdBefore ) then activePanel = nil return end

	--Create a how new menu for admin menu
	local controlMenu = vgui.Create("DFrame")
	controlMenu:SetSize(350, 350)
	controlMenu:SetPos(X, Y)
	controlMenu:SetTitle("")
	controlMenu:SetVisible(true)
	controlMenu:SetDraggable(true)
	controlMenu:ShowCloseButton(false)
	controlMenu:MakePopup()

	controlMenu.Paint = function(_, w, h)
		surface.SetDrawColor(LB.CMBackground)
		surface.DrawRect(0, 0, w, h)

		surface.SetDrawColor(LB.CMTopBar)
		surface.DrawRect(0, 0, w, 40)

		surface.SetFont("LB_Title")
		surface.SetTextColor( Color(255, 255, 255) )
		surface.SetTextPos(3, 5)
		surface.DrawText("Control Menu")
	end

	local controlButton = vgui.Create("DButton", controlMenu)
	controlButton:SetDrawBackground(false)
	controlButton:SetDrawBorder(false)
	controlButton:SetSize(30, 28)
	controlButton:SetPos(305, 5)
	controlButton:SetText(" ")

	controlButton.Paint = function(_, w, h)
		surface.SetDrawColor( LB.ControlButton )

		surface.DrawLine(0, 1, w, 1)
		surface.DrawLine(0, 2, w, 2)
		surface.DrawLine(0, 3, w, 3)
		surface.DrawLine(0, 4, w, 4)

		surface.DrawLine(0, 12, w, 12)
		surface.DrawLine(0, 13, w, 13)
		surface.DrawLine(0, 14, w, 14)
		surface.DrawLine(0, 15, w, 15)

		surface.DrawLine(0, 24, w, 24)
		surface.DrawLine(0, 25, w, 25)
		surface.DrawLine(0, 26, w, 26)
		surface.DrawLine(0, 27, w, 27)
	end

	controlButton.DoClick = function()
		clicked = false
		local functions = { ["Ban Management"] = function() createBanSection(controlMenu) end, ["User Management"] = function() createScoreEditting(controlMenu, ply) end, 
		["Board Management"] = function() createBoardEditting(controlMenu) end, ["Close"] = function() closeMenu(controlMenu) end,}

		local menuButtons = {}
		local y = 40

		for menuName, func in pairs(functions) do
			
			local button = vgui.Create("DButton", controlMenu)
			button:SetDrawBackground(false)
			button:SetDrawBorder(false)
			button:SetSize(120, 25)
			button:SetPos(225, y)
			button:SetText(" ")

			button.Paint = function(_, w, h)

				if ( clicked == true ) then return end

				surface.SetDrawColor(LB.CMMenuBar)
				surface.DrawRect(0, 0, w, h)

				if (  button:IsHovered() or button:IsChildHovered( 1 ) ) then
					surface.SetDrawColor(LB.MenuHighlight)
					surface.DrawRect(0, 0, w, h)
				end

				surface.SetFont("LB_Desc")

				local textW, textH = surface.GetTextSize(menuName)
				local x = w / 2
				x = x - (textW / 2)

				surface.SetTextPos(math.ceil(x), 5)
				surface.SetTextColor( Color(255, 255, 255) )
				surface.DrawText(menuName)
			end

			button.DoClick = function()
				clicked = true
				func()
			end
		
			y = y + 25
		end

	end
	
	createdBefore = true
end

function createBanSection(controlMenu)
	if (activePanel ~= nil) then
		activePanel:SetVisible(false)
	end

	local panel = vgui.Create("DPanel", controlMenu)
	panel:SetSize(350, 310)
	panel:SetPos(0, 40)
	panel:SetVisible(true)
	activePanel = panel

	local adminDesc = vgui.Create("DLabel", panel)
	adminDesc:SetSize(270,25)
	adminDesc:SetPos(5,5)
	adminDesc:SetColor( Color(0,0,0) )
	adminDesc:SetText("Ban List - All players here don't appear on leaderboards")

	local bannedList = vgui.Create("DListView", panel)
	bannedList:SetSize(280, 200)
	bannedList:SetPos(5, 30)

	bannedList:AddColumn("Name")
	bannedList:AddColumn("Reason")

	bannedList:Clear()
	bannedList:AddLine("LOADING....")

	bannedList.OnRowRightClick = function(panel, line)
		local menu = DermaMenu(panel)

		menu:AddOption( "Remove", function() 
			net.Start("LB_RemoveBan")
				net.WriteString(bannedList:GetLine(line):GetValue(1))
				net.WriteInt(tonumber(line), 32)
			net.SendToServer()

			net.Start("LB_RequestBanlist")
			net.SendToServer()

			bannedList:Clear()
			bannedList:AddLine("LOADING....")
		end )

		menu:Open()
	end

	local banIdEntry = vgui.Create("DTextEntry", panel)
	banIdEntry:SetSize(120, 20)
	banIdEntry:SetPos(5, 235)
	banIdEntry:SetText("SteamID")

	local banReasonEntry = vgui.Create("DTextEntry", panel)
	banReasonEntry:SetSize(120, 20)
	banReasonEntry:SetPos(5, 260)
	banReasonEntry:SetText("Reason")

	local banButton = vgui.Create("DButton", panel)
	banButton:SetSize(53, 20)
	banButton:SetPos(130, 235)
	banButton:SetText("Ban User")
	banButton.DoClick = function()
		net.Start("LB_AddBan")
			net.WriteString(banIdEntry:GetText())
			net.WriteString(banReasonEntry:GetText())
		net.SendToServer()

		--Update players banlist with new entry
		net.Start("LB_RequestBanlist")
		net.SendToServer()

		bannedList:Clear()
		bannedList:AddLine("LOADING....")
	end

	net.Start("LB_RequestBanlist")
	net.SendToServer()

	net.Receive("LB_SendBanlist", function()
		local banTable = net.ReadTable()

		bannedList:Clear()

		if ( banTable ~= nil ) then
			for k, v in pairs(banTable) do
				bannedList:AddLine(tostring(k), tostring(v))
			end
		end
	end )

end


function createScoreEditting(controlMenu, ply)
	local selectedValue = nil
	local selectedData = nil

	if (activePanel ~= nil) then
		activePanel:SetVisible(false)
	end

	local panel = vgui.Create("DPanel", controlMenu)
	panel:SetSize(350, 310)
	panel:SetPos(0, 40)
	panel:SetVisible(true)
	activePanel = panel

	local scoreIdEntry = vgui.Create("DTextEntry", panel)
	scoreIdEntry:SetSize(110, 20)
	scoreIdEntry:SetPos(5, 5)
	scoreIdEntry:SetText("Steam ID")

	local scoreNumEntry = vgui.Create("DTextEntry", panel)
	scoreNumEntry:SetSize(110, 20)
	scoreNumEntry:SetPos(120, 5)
	scoreNumEntry:SetText("Score To Set")

	local scoreComboBox = vgui.Create("DComboBox", panel)
	scoreComboBox:SetSize(110, 20)
	scoreComboBox:SetPos(5, 30)
	scoreComboBox:SetValue("Board")

	for k, v in pairs(LB.boardRef) do
		scoreComboBox:AddChoice(k, k)
		scoreComboBox:AddChoice(k .. " -M", k)
	end
	
	scoreComboBox.OnSelect = function(panel, index, value, data)
		selectedData = data
		selectedValue = value
	end

	local scoreButton = vgui.Create("DButton", panel)
	scoreButton:SetSize(75, 20)
	scoreButton:SetPos(120, 30)
	scoreButton:SetText("Update score")
	scoreButton.DoClick = function()
		if ( selectedData == nil or selectedData == "Board" ) then return end

		net.Start("LB_UpdatePlayerScore")
			net.WriteString(scoreIdEntry:GetText())
			net.WriteString(scoreNumEntry:GetText())
			net.WriteString(selectedData)

			if ( string.sub(selectedValue, -2) == "-M") then
				net.WriteBit(true)
			else
				net.WriteBit(false)
			end
		net.SendToServer()
	end
end

function createBoardEditting(controlMenu, ply)
	local selectedValue = nil
	local selectedData = nil
	local selectedValue2 = nil
	local selectedData2 = nil

	if (activePanel ~= nil) then
		activePanel:SetVisible(false)
	end

	local panel = vgui.Create("DPanel", controlMenu)
	panel:SetSize(350, 310)
	panel:SetPos(0, 40)
	panel:SetVisible(true)
	activePanel = panel

	local resetTemp = vgui.Create("DButton", panel)
	resetTemp:SetSize(125, 20)
	resetTemp:SetPos(5, 5)
	resetTemp:SetText("Reset Monthly Scores")

	resetTemp.DoClick = function()
		Derma_Query("Do you really want to reset monthly data?", "Reset Monthly Data",
				"Yes", function() net.Start("LB_ResetTmpBoard") net.SendToServer() end,
				"No", function() end
		)
	end

	local resetAll = vgui.Create("DButton", panel)
	resetAll:SetSize(125, 20)
	resetAll:SetPos(5, 30)
	resetAll:SetText("Reset All Scores")

	resetAll.DoClick = function()
		Derma_Query("Do you really want to remove monthly data?", "Reset Monthly Data",
				"Yes", function() net.Start("LB_ResetData") net.SendToServer() end,
				"No", function() end
		)
	end

	// local boardCopyDesc = vgui.Create("DLabel", panel)
	// boardCopyDesc:SetSize(270,25)
	// boardCopyDesc:SetPos(5,50)
	// boardCopyDesc:SetColor( Color(0,0,0) )
	// boardCopyDesc:SetText("Board to Copy")

	// local boardCopyDesc1 = vgui.Create("DLabel", panel)
	// boardCopyDesc1:SetSize(270,25)
	// boardCopyDesc1:SetPos(130,50)
	// boardCopyDesc1:SetColor( Color(0,0,0) )
	// boardCopyDesc1:SetText("Board getting Data")

	// local boardComboBox = vgui.Create("DComboBox", panel)
	// boardComboBox:SetSize(120, 20)
	// boardComboBox:SetPos(5, 75)
	// boardComboBox:SetValue("Board")

	// local boardComboBox2 = vgui.Create("DComboBox", panel)
	// boardComboBox2:SetSize(120, 20)
	// boardComboBox2:SetPos(130, 75)
	// boardComboBox2:SetValue("Board")

	// for k, v in pairs(LB.boardRef) do
	// 	boardComboBox:AddChoice(k, k)
	// 	boardComboBox:AddChoice(k .. " -M", k)
	// 	boardComboBox2:AddChoice(k, k)
	// 	boardComboBox2:AddChoice(k .. " -M", k)
	// end
	
	// boardComboBox.OnSelect = function(panel, index, value, data)
	// 	selectedValue = value
	// 	selectedData = data
	// end

	// boardComboBox2.OnSelect = function(panel, index2, value2, data2)
	// 	selectedValue2 = value2
	// 	selectedData2 = data2
	// end

	// local copyButton =  vgui.Create("DButton", panel)
	// copyButton:SetSize(100, 20)
	// copyButton:SetPos(5, 100)
	// copyButton:SetText("Just Copy")

	// copyButton.DoClick = function()
	// 	net.Start("LB_CopyBoard")
	// 		net.WriteString(selectedData)

	// 		if ( string.sub(selectedValue, -2) == "-M" ) then
	// 			net.WriteBit(true)
	// 		else
	// 			net.WriteBit(false)
	// 		end

	// 		net.WriteString(selectedData2)

	// 		if ( string.sub(selectedValue2, -2) == "-M" ) then
	// 			net.WriteBit(true)
	// 		else
	// 			net.WriteBit(false)
	// 		end

	// 		net.WriteBit(false)
	// 	net.SendToServer()
	// end


	// local copyDeleteButton =  vgui.Create("DButton", panel)
	// copyDeleteButton:SetSize(100, 20)
	// copyDeleteButton:SetPos(130, 100)
	// copyDeleteButton:SetText("Copy & Delete")

	// copyDeleteButton.DoClick = function()
	// 	net.Start("LB_CopyBoard")
	// 		net.WriteString(selectedData)

	// 		if ( string.sub(selectedValue, -2) == "-M" ) then
	// 			net.WriteBit(true)
	// 		else
	// 			net.WriteBit(false)
	// 		end

	// 		net.WriteString(selectedData2)

	// 		if ( string.sub(selectedValue2, -2) == "-M" ) then
	// 			net.WriteBit(true)
	// 		else
	// 			net.WriteBit(false)
	// 		end

	// 		net.WriteBit(false)
	// 	net.SendToServer()
	// end

end

function closeMenu(controlMenu)
	controlMenu:Close()
	createdBefore = false
	activePanel = nil
end