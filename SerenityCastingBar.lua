
local SerenityCastingBar, obj

local function onEvent()
	if ( event == "SPELLCAST_START" ) then
		SerenityCastingBar.Bar:SetStatusBarColor(0.0, 1.0, 0.0)
		this.startTime = GetTime();
		this.maxValue = this.startTime + (arg2 / 1000);
		SerenityCastingBar.Bar:SetMinMaxValues(this.startTime, this.maxValue);
		SerenityCastingBar.Bar:SetValue(this.startTime);
		this:SetAlpha(1.0);
		this.holdTime = 0;
		this.casting = 1;
		this.fadeOut = nil;
		this:Show();
		SerenityCastingBar.Flash:SetAlpha(0.0);
	elseif ( event == "SPELLCAST_STOP" or event == "SPELLCAST_CHANNEL_STOP" ) then
		if ( not this:IsVisible() ) then
			this:Hide();
		end
		if ( this:IsShown() ) then
			SerenityCastingBar.Bar:SetValue(this.maxValue);
			SerenityCastingBar.Bar:SetStatusBarColor(0.0, 1.0, 0.0)
			if ( event == "SPELLCAST_STOP" ) then
				this.casting = nil;
			else
				this.channeling = nil;
			end
			--this.flash = 1;
			this.fadeOut = 1;
			
			SerenityCastingBar.Flash:SetAlpha(0.0);
			SerenityCastingBar.Flash:Show();
		end
	elseif ( event == "SPELLCAST_FAILED" or event == "SPELLCAST_INTERRUPTED" ) then
		if ( this:IsShown() and not this.channeling ) then
			SerenityCastingBar.Bar:SetValue(this.maxValue);
			SerenityCastingBar.Bar:SetStatusBarColor(1.0, 0.0, 0.0);
			this.casting = nil;
			this.fadeOut = 1;
			this.flash = 1;
			SerenityCastingBar.Flash:SetAlpha(0.0);
			SerenityCastingBar.Flash:Show();
		end
	elseif ( event == "SPELLCAST_DELAYED" ) then
		if( this:IsShown() ) then
			this.startTime = this.startTime + (arg1 / 1000);
			this.maxValue = this.maxValue + (arg1 / 1000);
			SerenityCastingBar.Bar:SetMinMaxValues(this.startTime, this.maxValue);
		end
	elseif ( event == "SPELLCAST_CHANNEL_START" ) then
		SerenityCastingBar.Bar:SetStatusBarColor(1.0, 0.82, 0.0)
		this.maxValue = 1;
		this.startTime = GetTime();
		this.endTime = this.startTime + (arg1 / 1000);
		this.duration = arg1 / 1000;
		SerenityCastingBar.Bar:SetMinMaxValues(this.startTime, this.endTime);
		SerenityCastingBar.Bar:SetValue(this.endTime);
		CastingBarText:SetText(arg2);
		this:SetAlpha(1.0);
		this.holdTime = 0;
		this.casting = nil;
		this.channeling = 1;
		this.fadeOut = nil;
		this:Show();
	elseif ( event == "SPELLCAST_CHANNEL_UPDATE" ) then
		if ( this:IsShown() ) then
			local origDuration = this.endTime - this.startTime
			this.endTime = GetTime() + (arg1 / 1000)
			this.startTime = this.endTime - origDuration
			--this.endTime = this.startTime + (arg1 / 1000);
			SerenityCastingBar.Bar:SetMinMaxValues(this.startTime, this.endTime);
		end
	end
end

local function onUpdate()
	if ( this.casting ) then
		local status = GetTime();
		if ( status > this.maxValue ) then
			status = this.maxValue
		end
		SerenityCastingBar.Bar:SetValue(status);
	elseif ( this.channeling ) then
		local time = GetTime();
		if ( time > this.endTime ) then
			time = this.endTime
		end
		if ( time == this.endTime ) then
			this.channeling = nil;
			this.fadeOut = 1;
			return;
		end
		local barValue = this.startTime + (this.endTime - time);
		SerenityCastingBar.Bar:SetValue( barValue );
	elseif ( GetTime() < this.holdTime ) then
		return;
	elseif ( this.flash ) then
		local alpha = SerenityCastingBar.Flash:GetAlpha() + 1.0 / ( GetFramerate() * 0.3 ) -- CASTING_BAR_FLASH_STEP;
		if ( alpha < 1 ) then
			SerenityCastingBar.Flash:SetAlpha(alpha);
		else
			SerenityCastingBar.Flash:SetAlpha(1.0);
			this.flash = nil;
		end
	elseif ( this.fadeOut ) then
		local alpha = this:GetAlpha() - 1.0 / ( GetFramerate() * 1.0 ) -- CASTING_BAR_ALPHA_STEP;
		if ( alpha > 0 ) then
			this:SetAlpha(alpha);
		else
			this.fadeOut = nil;
			this:Hide();
		end
	end
end

SerenityCastingBar = CreateFrame("Frame", "SerenityCastingBar", SerenityParent)
SerenityCastingBar:SetWidth(384)
SerenityCastingBar:SetHeight(32)
SerenityCastingBar:SetFrameStrata("LOW")
SerenityCastingBar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 268)

obj = SerenityCastingBar:CreateTexture(nil, "BACKGROUND")
obj:SetPoint("CENTER", SerenityCastingBar)
obj:SetTexture("Interface\\AddOns\\Serenity\\Textures\\SerenityCastingBar")
obj:SetWidth(512)
obj:SetHeight(32)

SerenityCastingBar.Flash = SerenityCastingBar:CreateTexture(nil, "OVERLAY")
SerenityCastingBar.Flash:SetPoint("CENTER", SerenityCastingBar)
SerenityCastingBar.Flash:SetTexture("Interface\\AddOns\\Serenity\\Textures\\SerenityCastingBarFlash")
SerenityCastingBar.Flash:SetVertexColor(1.0, 0.0, 0.0)
SerenityCastingBar.Flash:SetWidth(512)
SerenityCastingBar.Flash:SetHeight(32)

SerenityCastingBar.Bar = CreateFrame("StatusBar", nil, frame)
SerenityCastingBar.Bar:SetParent(SerenityCastingBar)
SerenityCastingBar.Bar:SetPoint("CENTER", SerenityCastingBar)
SerenityCastingBar.Bar:SetWidth(SerenityCastingBar:GetWidth() - 20)
SerenityCastingBar.Bar:SetHeight(16)
SerenityCastingBar.Bar:SetStatusBarTexture("Interface\\AddOns\\Serenity\\Textures\\Solid")
SerenityCastingBar.Bar:SetStatusBarColor(0.0, 1.0, 0.0)

SerenityCastingBar:RegisterEvent("SPELLCAST_START")
SerenityCastingBar:RegisterEvent("SPELLCAST_STOP")
SerenityCastingBar:RegisterEvent("SPELLCAST_INTERRUPTED")
SerenityCastingBar:RegisterEvent("SPELLCAST_FAILED")
SerenityCastingBar:RegisterEvent("SPELLCAST_DELAYED")
SerenityCastingBar:RegisterEvent("SPELLCAST_CHANNEL_START")
SerenityCastingBar:RegisterEvent("SPELLCAST_CHANNEL_UPDATE")
SerenityCastingBar:RegisterEvent("SPELLCAST_CHANNEL_STOP")

SerenityCastingBar:SetScript("OnEvent", onEvent)
SerenityCastingBar:SetScript("OnUpdate", onUpdate)

SerenityCastingBar:Hide()

CastingBarFrame:UnregisterAllEvents()
