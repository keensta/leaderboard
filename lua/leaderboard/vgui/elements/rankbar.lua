include( "leaderboard/misc.lua" )
include( "leaderboard/vgui/elements/fancyavatar.lua" )
include( "leaderboard/misc.lua" )
--Custom Vgui (RankBar)

--Enums Type to get specific suffixs related to type
KILL = 0
TIME =  1
DMG = 2

RB = {}

RB.Pos = "0"
RB.Username = "N/A"
RB.Score = "0"
RB.SteamId = "STEAM:0:"
RB.SelectedBoard = "N/A"
RB.Suffix = ""
RB.HighlightColor = LB.RankHighlight
RB.Type = KILL
RB.MouseHovered = false

--Need's to be started

function RB:Init()
	self:SetSize(585, 35)
	self:Center()
end

function RB:SetPosition(pos)
	self.Pos = tostring(pos)
end

function RB:SetScore(score)
	self.Score = tostring(score)
end

function RB:SetData(steamid, nickname)
	self.SteamId = steamid
	self.Username = nickname
end

function RB:SetBoard(board)
	self.SelectedBoard = board

	if ( self.SelectedBoard == "TimePlayed" ) then
		local score = self.Score
		local time = tonumber(score)

		self.Score = timeToStr(time)
	end

	if ( self.SelectedBoard == "Turtles" ) then
		self.Type = DMG
	end
end

function RB:SetScoreType(sType)
	self.Type = sType
end

function RB:GetSuffix()
	if ( self.Type == KILL ) then
		return ""
	end

	if ( self.Type == TIME ) then
		return ""
	end

	if ( self.Type == DMG ) then
		return " Dmg"
	end
end

function RB:Paint(w, h)

	if ( self.MouseHovered ) then
		surface.SetDrawColor(self.HighlightColor)

		if ( tonumber(self.Pos) <= 3 ) then
			surface.DrawRect(0, 5, w, 35)
		else
			surface.DrawRect(0, 5, w, 25)
		end
	end
	
	if ( tonumber(self.Pos) <= 3 ) then
		local avatar = vgui.Create("FancyAvatarImage", self)
		avatar:SetSize(32, 32)
		avatar:SetPos(70, 4)
		avatar:SetMaskSize(16)
		avatar:SetSteamID(self.SteamId, 32)

		surface.SetFont("LB_Board_Bold")

		NL = 2.5 + (surface.GetTextSize(self.Pos))
		UL = 10 + (surface.GetTextSize(self.Username))
		SL = 5 + (surface.GetTextSize(self.Score))

		draw.RoundedBox(4, 13, 7.5, NL, 21.5, LB.RankBarTextBg)
		draw.SimpleText(self.Pos, "LB_Board_Bold", 14.05, 12.25, LB.RankBarText, TEXT_ALIGN_LEFT)
		draw.RoundedBox(6, 110, 7, UL, 25, LB.RankBarTextBg)
		draw.SimpleText(self.Username, "LB_Board_Bold", 115, 12.5, LB.RankBarText, TEXT_ALIGN_LEFT)
		draw.RoundedBox(6, 431.5 - SL / 2, 7, SL, 25, LB.RankBarTextBg)
		draw.SimpleText(self.Score, "LB_Board_Bold", 434 - SL / 2, 12.5, LB.RankBarText, TEXT_ALIGN_LEFT)
	else
		surface.SetFont("LB_Board")

		NL = 5 + (surface.GetTextSize(self.Pos))
		UL = 10 + (surface.GetTextSize(self.Username))
		SL = 5 + (surface.GetTextSize(self.Score))

		draw.RoundedBox(6, 11.5, 7.5, NL, 20, LB.RankBarTextBg)
		draw.SimpleText(self.Pos, "LB_Board", 15, 10, LB.RankBarText, TEXT_ALIGN_LEFT)
		draw.RoundedBox(6, 110, 7, UL, 21, LB.RankBarTextBg)
		draw.SimpleText(self.Username, "LB_Board", 115, 9, LB.RankBarText, TEXT_ALIGN_LEFT)
		draw.RoundedBox(6, 432.5 - SL / 2, 7, SL, 21, LB.RankBarTextBg)
		draw.SimpleText(self.Score, "LB_Board", 435 - SL / 2, 9, LB.RankBarText, TEXT_ALIGN_LEFT)
	end

end

function RB:DoRightClick()
	local menu = DermaMenu(self)

	menu:AddOption("Copy SteamId", function() SetClipboardText(self.SteamId) end):SetImage("icon16/tag_blue.png")
	menu:AddOption("Line Copy", function() SetClipboardText(self.Username .. " is ranked " .. self.Pos .. " with a score of " .. self.Score .. " on " .. self.SelectedBoard) end):SetImage("icon16/page_copy.png")
	menu:Open()
end

function RB:OnCursorEntered()
	self.MouseHovered = true
end

function RB:OnCursorExited()
	self.MouseHovered = false
end

function RB:OnMouseReleased( mousecode )

	if ( mousecode == MOUSE_RIGHT ) then
		self:DoRightClick()
	end

end

vgui.Register("LBRankBar", RB, "DPanel")