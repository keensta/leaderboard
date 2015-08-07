
--Custom Vgui (Switch)

SWITCH = {}
SWITCH.Active = false -- If Active(false) then left side selected if is true right side Selected
SWITCH.TextLeft = "Left"
SWITCH.TextRight = "Right"
SWITCH.BGColor = LB.SwitchBg
SWITCH.TColor = LB.SwitchText 
SWITCH.AColor = LB.SwitchActive
SWITCH.Callback = nil

function SWITCH:Init()
	self:SetSize(75, 45)
	self:Center()
end

function SWITCH:SetBothText(text1, text2)
	self.TextLeft = text1
	self.TextRight = text2
end

function SWITCH:SetBackgroundColor(Color)
	self.BGColor = Color
end

function SWITCH:SetTextColor(Color)
	self.TColor = Color
end

function SWITCH:SetActiveColor(Color)
	self.AColor = Color
end

function SWITCH:IsActivated()
	return self.Active
end

function SWITCH:StateLeft()
	self.Active = false
end

function SWITCH:StateRight()
	self.Active = true
end

function SWITCH:FlipState(currentState)
	if ( self.Active == true ) then
		self:StateLeft()
	else
		self:StateRight()
	end

	if ( self.Callback ~= nil ) then
		self.Callback()
	end
end

function SWITCH:SetCallback(callback)
	self.Callback = callback
end

function SWITCH:SetState(state)
	self.Active = state
end

function SWITCH:Paint(w, h)

	draw.RoundedBox( 4, 0, 0, w, h, self.BGColor)

	if ( self.Active == false ) then
		draw.RoundedBoxEx(4, 0, 0, w / 2, h, self.AColor, true, false, true, false)
	else
		draw.RoundedBoxEx(4, w / 2, 0, w / 2, h, self.AColor, false, true, false, true)
	end

	local widthPos = (w/2)/2

	draw.SimpleText(self.TextLeft, "Default", widthPos, h/4, self.TColor, TEXT_ALIGN_CENTER)
	draw.SimpleText(self.TextRight, "Default", (w/2) + widthPos, h/4, self.TColor, TEXT_ALIGN_CENTER)

	return true
end

function SWITCH:OnMousePressed( mousecode )
	self:FlipState(self.Active)
	return DLabel.OnMousePressed(self, mousecode)
end

vgui.Register("LBSwitch", SWITCH, "DButton")