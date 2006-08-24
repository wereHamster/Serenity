
local SerenityControl, obj

local function onEvent()
end

local function onUpdate()
	this.delay = (this.delay or 0) + arg1
	if (this.delay > 0.2) then
		this.delay = 0
	end
end

SerenityControl = CreateFrame("Frame", nil, SerenityParent)
SerenityControl:SetWidth(512)
SerenityControl:SetHeight(64)
SerenityControl:SetFrameStrata("LOW")
SerenityControl:SetPoint("BOTTOMRIGHT", SerenityParent)

obj = SerenityControl:CreateTexture(nil, "BACKGROUND")
obj:SetPoint("BOTTOMRIGHT", SerenityControl)
obj:SetTexture("Interface\\AddOns\\Serenity\\Textures\\SerenityControl")
obj:SetWidth(512)
obj:SetHeight(64)

obj = SerenityControl:CreateTexture(nil, "BACKGROUND")
obj:SetPoint("BOTTOMRIGHT", SerenityControl, "BOTTOMRIGHT", -6, 10)
obj:SetTexture("Interface\\AddOns\\Serenity\\Textures\\Control\\Marvin")
obj:SetWidth(50)
obj:SetHeight(50)

SerenityControl:RegisterEvent("PLAYER_ENTERING_WORLD")
SerenityControl:RegisterEvent("PARTY_MEMBERS_CHANGED")
SerenityControl:RegisterEvent("RAID_ROSTER_UPDATE")

SerenityControl:SetScript("OnEvent", onEvent)
SerenityControl:SetScript("OnUpdate", onUpdate)
