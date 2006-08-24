
local SerenityDisplay, obj

local function subFrame(unitID)
	local frame = CreateFrame("Button", nil, SerenityDisplay)
	frame:SetWidth(396)
	frame:SetHeight(12)
	frame:SetFrameStrata("LOW")
	
	frame.name = frame:CreateFontString(nil, "OVAERLAY")
	frame.name:SetPoint("LEFT", frame, "LEFT", 6, 0)
	frame.name:SetWidth(64)
	frame.name:SetHeight(12)
	frame.name:SetFontObject(SerenityFontNormalSmall)
	frame.name:SetJustifyH("LEFT")
	
	frame.value = frame:CreateFontString(nil, "OVAERLAY")
	frame.value:SetPoint("RIGHT", frame, "RIGHT", -6, 0)
	frame.value:SetWidth(22)
	frame.value:SetHeight(12)
	frame.value:SetFontObject(SerenityFontNormalSmall)
	frame.value:SetJustifyH("LEFT")

	frame.bar = CreateFrame("StatusBar", nil, frame)
	frame.bar:SetPoint("LEFT", frame.name, "RIGHT", 6, 0)
	frame.bar:SetWidth(frame:GetWidth() - 14 - 6 - 64 - 22 - 6)
	frame.bar:SetHeight(12)
	frame.bar:SetStatusBarTexture("Interface\\AddOns\\Serenity\\Textures\\Solid")
	frame.bar:SetStatusBarColor(1.0, 0.82, 0.0)
	
	frame.bar:SetBackdrop({ bgFile = "Interface\\AddOns\\Serenity\\Textures\\Solid" })
	frame.bar:SetBackdropColor(1.0, 0.82, 0.0, 0.3)	
	
	SerenityDisplay[unitID] = frame
	
	return frame
end

local function updateBar(unitID)
	local frame = SerenityDisplay[unitID]
	if (UnitExists(unitID)) then
		frame.name:SetText(UnitName(unitID))
		frame.value:SetText(math.ceil(UnitHealth(unitID) / UnitHealthMax(unitID) * 100))
		
		frame.bar:SetMinMaxValues(0, UnitHealthMax(unitID))
		frame.bar:SetValue(UnitHealth(unitID))
		
		frame:Show()
	else
		frame:Hide()
	end
end

local function onEvent()
	if (event == "PLAYER_ENTERING_WORLD") then
		updateBar("player")
		updateBar("target")
	elseif (event == "PLAYER_TARGET_CHANGED") then
		updateBar("target")
	else
		if (SerenityDisplay[arg1]) then
			updateBar(arg1)
		end
	end
end

local function onUpdate()
	this.delay = (this.delay or 0) + arg1
	if (this.delay > 0.2) then
		local unitID = "targettarget"
		if (UnitExists(unitID)) then
			SerenityDisplay[unitID]:Show()
			updateBar(unitID)
		else
			SerenityDisplay[unitID]:Hide()
		end
		
		this.delay = 0
	end
end

SerenityDisplay = CreateFrame("Frame", nil, SerenityParent)
SerenityDisplay:SetWidth(512)
SerenityDisplay:SetHeight(64)
SerenityDisplay:SetFrameStrata("LOW")
SerenityDisplay:SetPoint("BOTTOM", SerenityParent, "BOTTOM", 0, 300)

obj = SerenityDisplay:CreateTexture(nil, "BACKGROUND")
obj:SetPoint("CENTER", SerenityDisplay)
obj:SetTexture("Interface\\AddOns\\Serenity\\Textures\\SerenityDisplay")
obj:SetWidth(512)
obj:SetHeight(64)

frame = subFrame("player")
frame:SetPoint("TOP", SerenityDisplay, "TOP", 0, -10)
frame:SetScript("OnClick", PlayerFrame:GetScript("OnClick"))
frame:RegisterForClicks("RightButtonUp")

frame = subFrame("target")
frame:SetPoint("TOP", SerenityDisplay["player"], "BOTTOM", 0, -4)
frame:SetScript("OnClick", TargetFrame:GetScript("OnClick"))
frame:RegisterForClicks("RightButtonUp")

frame = subFrame("targettarget")
frame:SetPoint("TOP", SerenityDisplay["target"], "BOTTOM", 0, -4)


SerenityDisplay:RegisterEvent("PLAYER_ENTERING_WORLD")
SerenityDisplay:RegisterEvent("PLAYER_TARGET_CHANGED")
SerenityDisplay:RegisterEvent("UNIT_HEALTH")
SerenityDisplay:RegisterEvent("UNIT_MAXHEALTH")

SerenityDisplay:SetScript("OnEvent", onEvent)
SerenityDisplay:SetScript("OnUpdate", onUpdate)
