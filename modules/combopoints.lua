local Combo = {}
ShadowUF:RegisterModule(Combo, "comboPoints", ShadowUFLocals["Combo points"])

function Combo:OnEnable(frame)
	frame.comboPoints = frame.comboPoints or CreateFrame("Frame", nil, frame)
	self:OnLayoutApplied(frame)
	
	frame:RegisterNormalEvent("UNIT_COMBO_POINTS", self, "Update")
	frame:RegisterUpdateFunc(self, "Update")
end

function Combo:OnLayoutApplied(frame)
	if( not frame.visibility.comboPoints ) then	return end
	local config = ShadowUF.db.profile.units[frame.unitType].comboPoints
	
	-- Hide the active combo points
	if( frame.comboPoints.points ) then
		for _, texture in pairs(frame.comboPoints.points) do
			texture:Hide()
		end
	end
	
	-- Setup for bar display!
	if( config.isBar ) then
		frame.comboPoints.blocks = frame.comboPoints.blocks or {}
		frame.comboPoints.points = frame.comboPoints.blocks
	
		-- Position bars, the 5 accounts for borders
		local blockWidth = (frame.comboPoints:GetWidth() - 4 ) / MAX_COMBO_POINTS
		for id=1, MAX_COMBO_POINTS do
			frame.comboPoints.blocks[id] = frame.comboPoints.blocks[id] or frame.comboPoints:CreateTexture(nil, "OVERLAY")
			local texture = frame.comboPoints.blocks[id]
			texture:SetVertexColor(1, 0.80, 0)
			texture:SetTexture(ShadowUF.Layout.mediaPath.statusbar)
			texture:SetHeight(frame.comboPoints:GetHeight())
			texture:SetWidth(blockWidth)
			texture:ClearAllPoints()
			
			if( config.growth == "LEFT" ) then
				if( id > 1 ) then
					texture:SetPoint("TOPRIGHT", frame.comboPoints.blocks[id - 1], "TOPLEFT", -1, 0)
				else
					texture:SetPoint("TOPRIGHT", frame.comboPoints, "TOPRIGHT", 0, 0)
				end
			else
				if( id > 1 ) then
					texture:SetPoint("TOPLEFT", frame.comboPoints.blocks[id - 1], "TOPRIGHT", 0, 0)
				else
					texture:SetPoint("TOPLEFT", frame.comboPoints, "TOPLEFT", 0, 0)
				end
			end
		end

	-- guess not, will have to do icons :(
	else
		local point, relativePoint
		local x, y = 0, 0
		
		if( config.growth == "LEFT" ) then
			point, relativePoint = "BOTTOMRIGHT", "BOTTOMLEFT"
			x = config.spacing
		elseif( config.growth == "RIGHT" ) then
			point, relativePoint = "BOTTOMLEFT", "BOTTOMRIGHT"
			x = config.spacing
		elseif( config.growth == "UP" ) then
			point, relativePoint = "BOTTOMLEFT", "TOPLEFT"
			y = config.spacing
		elseif( config.growth == "DOWN" ) then
			point, relativePoint = "TOPLEFT", "BOTTOMLEFT"
			y = config.spacing
		end
		

		frame.comboPoints.icons = frame.comboPoints.icons or {}
		frame.comboPoints.points = frame.comboPoints.icons
		
		for id=1, MAX_COMBO_POINTS do
			frame.comboPoints.icons[id] = frame.comboPoints.icons[id] or frame.comboPoints:CreateTexture(nil, "OVERLAY")
			local texture = frame.comboPoints.icons[id]
			texture:SetTexture("Interface\\AddOns\\ShadowedUnitFrames\\media\\textures\\combo")
			texture:SetHeight(config.size)
			texture:SetWidth(config.size)
			
			if( id > 1 ) then
				texture:ClearAllPoints()
				texture:SetPoint(point, frame.comboPoints.icons[id - 1], relativePoint, x, y)
			else
				texture:ClearAllPoints()
				texture:SetPoint("CENTER", frame.comboPoints, "CENTER", 0, 0)
			end
		end
	end
end

function Combo:OnDisable(frame)
	frame:UnregisterAll(self)
end

function Combo:ToggleVisibility(frame, status)
	local wasShown = frame.comboPoints:IsShown()
	ShadowUF.Layout:ToggleVisibility(frame.comboPoints, status)
	if( wasShown and not status or not wasShown and status ) then
		ShadowUF.Layout:PositionWidgets(frame, ShadowUF.db.profile.units[frame.unitType])
	end
end

function Combo:Update(frame)
	-- For Malygos dragons, they also self cast their CP on themselves, which is why we check CP on ourself!
	local points = GetComboPoints(ShadowUF.playerUnit)
	if( points == 0 ) then
		points = GetComboPoints(ShadowUF.playerUnit, ShadowUF.playerUnit)
	end
	
	-- Bar display, hide it if we don't have any combo points
	if( ShadowUF.db.profile.units[frame.unitType].comboPoints.isBar ) then
		self:ToggleVisibility(frame, points > 0)
	end
	
	for id, pointTexture in pairs(frame.comboPoints.points) do
		if( id <= points ) then
			pointTexture:Show()
		else
			pointTexture:Hide()
		end
	end
end
