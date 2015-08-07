include("leaderboard/misc.lua")
include("leaderboard/vgui/controlmenu.lua") --May intergrate this into this menu (To be decided)
include("leaderboard/config/lb_config.lua")
include("leaderboard/vgui/elements/switch.lua")
include("leaderboard/vgui/elements/rankbar.lua")

local X = 225
local Y = 75
local isOpen = false

local scores = nil
local banList = {}

local guiElements = {}

local lastOpened = LB.DefaultBoard
local tmpLast = false
local received = false


function OpenGuiMenu(ply)

	--Get BanList
	net.Start("LB_RequestBanList")
	net.SendToServer()

	net.Receive("LB-SendBanlist", function(le)
		banList = net.ReadTable()
	end )

	local lbMain = vgui.Create("DFrame")
	lbMain:SetSize(800, 600)
	lbMain:SetPos(X, Y)
	lbMain:SetTitle("")
	lbMain:SetVisible(true)
	lbMain:SetDraggable(true)
	lbMain:ShowCloseButton(false)
	lbMain:MakePopup()

	isOpen = true

	lbMain.Paint = function(_, w, h)

		--Header
		surface.SetDrawColor(LB.HeaderBackground)
		surface.DrawRect(0, 0, w, 150)

		--Button Bar
		surface.SetDrawColor(LB.ButtonBarBackground)
		surface.DrawRect(0, 150, w, 150)

		--Leaderboard Data
		surface.SetDrawColor(LB.DataBackground)
		surface.DrawRect(0, 300, w, h - 300)

		--Leaderboard Title
		surface.SetFont("LB_Title")
		surface.SetTextColor(LB.TitleColor)
		surface.SetTextPos(5, 5)
		surface.DrawText(LB.LeaderboardTitle)

		--Opening Player stuff (TODO at later date)
	end

	//Not designing close button just yet
	// local closeButton = vgui.Create("DButton", lbMain)
	// closeButton:SetText("")
	// closeButton:SetPos(770, 0)
	// closeButton:SetSize(20, 20)

	// closeButton.Paint = function(_, w, h)
	// 	--Draw Close Button
	// 	surface.SetDrawColor( Color( ) )
	// end

	guiElements["Main"] = lbMain
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
