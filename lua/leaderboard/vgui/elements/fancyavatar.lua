include( "leaderboard/misc.lua" )

local PANEL = {}
PANEL.Done = false
PANEL.Done2 = false
PANEL.MaskSize = 16

function PANEL:Init()
    self.Avatar = vgui.Create("AvatarImage", self)
    self.Avatar:SetPaintedManually(true)
end

function PANEL:PerformLayout()
    self.Avatar:SetSize(self:GetWide(), self:GetTall())
end

function PANEL:PaintOver(w, h) 
     if ( self.Done2 == true ) then
        return
    end

    self.Done2 = true
end

function PANEL:Paint(w, h)
    if ( self.Done == true ) then
        return
    end

    render.ClearStencil()
    render.SetStencilEnable(true)

    render.SetStencilWriteMask( 1 )
    render.SetStencilTestMask( 1 )

    render.SetStencilFailOperation( STENCIL_REPLACE )
    render.SetStencilPassOperation( STENCIL_ZERO )
    render.SetStencilZFailOperation( STENCIL_ZERO )
    render.SetStencilCompareFunction( STENCIL_NEVER )
    render.SetStencilReferenceValue( 1 )

    surface.SetDrawColor(Color(225, 0, 0))
    draw.NoTexture()
    surface.DrawPoly(MakeCirclePoly(w/2, h/2, self.MaskSize - 4, nil, 0, 360, 32))

    render.SetStencilFailOperation( STENCIL_ZERO )
    render.SetStencilPassOperation( STENCIL_REPLACE )
    render.SetStencilZFailOperation( STENCIL_ZERO )
    render.SetStencilCompareFunction( STENCIL_EQUAL ) -- STENCILCOMPARISONFUNCTION_EQUAL will only draw what you draw as the mask.
    render.SetStencilReferenceValue( 1 )

    self.Avatar:SetPaintedManually(false)
    self.Avatar:PaintManual()
    self.Avatar:SetPaintedManually(true)

    render.SetStencilEnable(false)
    render.ClearStencil()

    self.Done = true
end

function PANEL:SetPlayer(ply, size)
    self.Avatar:SetPlayer(ply, size)
end

function PANEL:SetSteamID(steamid, size)
    self.Avatar:SetSteamID(util.SteamIDTo64(steamid), size)
end

function PANEL:SetMaskSize(maskSize)
    self.MaskSize = maskSize
end

vgui.Register("FancyAvatarImage", PANEL)