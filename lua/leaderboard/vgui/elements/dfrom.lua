local DF = {}
DF.textData = ""

function DF:Init()
	self.form = vgui.Create("DForm", panelOptions)
	self.form:SetName("")
	self.form:SetPos(0,0)
	self.form:SetSize(125, 25)
	self.form:SetExpanded(false)
end

function DF:PerformLayout()
    self.form:SetSize(self:GetWide(), self:GetTall())
end

function DF:SetTextData(text)
	self.textData = text
end

function DF:Paint(w, h)
	if ( cat.IsHovered ) then
		surface.SetDrawColor( Color(53, 152, 219) )
		surface.DrawRect(0, 0, w, h)
	end

	surface.SetTextPos(w / 2.7 - string.len(v), 0)
	surface.SetFont("LB_Menu_Title")
	surface.SetTextColor(LB.MenuText)
	surface.DrawText(self.textData)
end