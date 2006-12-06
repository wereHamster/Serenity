
local frames = {
	"PlayerFrame",
	"TargetFrame",
	
	"PartyMemberFrame1",
	"PartyMemberFrame1PetFrame",
	"PartyMemberFrame2",
	"PartyMemberFrame2PetFrame",
	"PartyMemberFrame3",
	"PartyMemberFrame3PetFrame",
	"PartyMemberFrame4",
	"PartyMemberFrame4PetFrame",
	
	"MainMenuBar",
}

local function onEvent()
end

local function onShow()
	this:Hide()
end

local function clear(obj)	
	obj:SetScript("OnEvent", onEvent)
	obj:SetScript("OnShow", onShow)
	
	obj:Hide()
end

for _, name in pairs(frames) do
	clear(getglobal(name))
end

