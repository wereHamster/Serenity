
local SerenityPlayer, hp, mp, obj

local function subFrame()
	local frame = nil
	frame = CreateFrame("Frame", nil, SerenityPlayer)
	frame:SetWidth(340)
	frame:SetHeight(12)
	frame:SetFrameStrata("LOW")

	frame.bar = CreateFrame("StatusBar", nil, frame)
	frame.bar:SetPoint("LEFT", frame, "LEFT", 6, 0)
	frame.bar:SetWidth(frame:GetWidth() - 6 - 8 - 38 - 8)
	frame.bar:SetHeight(12)
	frame.bar:SetStatusBarTexture("Interface\\AddOns\\Serenity\\Textures\\Solid")
	frame.bar:SetStatusBarColor(1.0, 0.82, 0.0)

	frame.bar:SetBackdrop({ bgFile = "Interface\\AddOns\\Serenity\\Textures\\Solid" })
	frame.bar:SetBackdropColor(1.0, 0.82, 0.0, 0.3)
	
	frame.value = frame:CreateFontString(nil, "OVAERLAY")
	frame.value:SetPoint("RIGHT", frame, "RIGHT", -8, 0)
	frame.value:SetWidth(38)
	frame.value:SetHeight(12)
	frame.value:SetFontObject(SerenityFontNormalSmall)
	frame.value:SetJustifyH("RIGHT")
	
	return frame
end

local function updateBar(frame, cur, max)
	frame.value:SetText(cur("player"))
		
	frame.bar:SetMinMaxValues(0, max("player"))
	frame.bar:SetValue(cur("player"))
end

local function onEvent()
	if (event == "PLAYER_ENTERING_WORLD") then
		updateBar(hp, UnitHealth, UnitHealthMax)
		updateBar(mp, UnitMana, UnitManaMax)
	elseif (arg1 == "player") then
		if (event == "UNIT_HEALTH" or event == "UNIT_MAXHEALTH") then
			updateBar(hp, UnitHealth, UnitHealthMax)
		else
			updateBar(mp, UnitMana, UnitManaMax)
		end
	end
end

SerenityPlayer = CreateFrame("Frame", nil, SerenityParent)
SerenityPlayer:SetPoint("BOTTOMLEFT", SerenityParent)
SerenityPlayer:SetWidth(512)
SerenityPlayer:SetHeight(64)
SerenityPlayer:SetFrameStrata("LOW")

obj = SerenityPlayer:CreateTexture(nil, "BACKGROUND")
obj:SetPoint("BOTTOMLEFT", SerenityPlayer)
obj:SetTexture("Interface\\AddOns\\Serenity\\Textures\\SerenityPlayer")
obj:SetWidth(512)
obj:SetHeight(64)

obj = CreateFrame("Button", nil, SerenityPlayer)
obj:SetPoint("BOTTOMLEFT", SerenityPlayer, "BOTTOMLEFT", 14, 45)
obj:SetWidth(16)
obj:SetHeight(16)
obj:SetNormalTexture("Interface\\AddOns\\Serenity\\Textures\\Player\\MenuButton-Normal")
obj:SetTextFontObject(SerenityFontNormalSmall)

obj = SerenityPlayer:CreateFontString(nil, "OVERLAY")
obj:SetPoint("BOTTOMLEFT", SerenityPlayer, "BOTTOMLEFT", 34, 44)
obj:SetWidth(128)
obj:SetFontObject(SerenityFontNormalLarge)
obj:SetJustifyH("LEFT")
obj:SetText(UnitName("player"))

hp = subFrame()
hp:SetPoint("BOTTOMLEFT", SerenityPlayer, "BOTTOMLEFT", 8, 30)

mp = subFrame()
mp:SetPoint("BOTTOMLEFT", SerenityPlayer, "BOTTOMLEFT", 8, 14)

SerenityPlayer:RegisterEvent("PLAYER_ENTERING_WORLD")

SerenityPlayer:RegisterEvent("UNIT_HEALTH")
SerenityPlayer:RegisterEvent("UNIT_MAXHEALTH")

SerenityPlayer:RegisterEvent("UNIT_MANA");
SerenityPlayer:RegisterEvent("UNIT_MAXMANA");

SerenityPlayer:RegisterEvent("UNIT_RAGE");
SerenityPlayer:RegisterEvent("UNIT_MAXRAGE");

SerenityPlayer:RegisterEvent("UNIT_ENERGY");
SerenityPlayer:RegisterEvent("UNIT_MAXENERGY");

SerenityPlayer:SetScript("OnEvent", onEvent)
