
local SerenityCastingBar, obj

function onEvent(self, event, arg1)
	if ( event == "PLAYER_ENTERING_WORLD" ) then
		local nameChannel  = UnitChannelInfo(this.unit);
		local nameSpell  = UnitCastingInfo(this.unit);
		if ( nameChannel ) then
			event = "UNIT_SPELLCAST_CHANNEL_START";
			arg1 = this.unit;
		elseif ( nameSpell ) then
			event = "UNIT_SPELLCAST_START";
			arg1 = this.unit;
		end
	end

	if ( arg1 ~= this.unit ) then
		return;
	end

	local barFlash = self.Flash

	if ( event == "UNIT_SPELLCAST_START" ) then
		local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill = UnitCastingInfo(this.unit);
		if ( not name or (not this.showTradeSkills and isTradeSkill)) then
			this:Hide();
			return;
		end

		--this.Bar:SetStatusBarColor(1.0, 0.7, 0.0);
		this.Bar:SetStatusBarColor(0.0, 1.0, 0.0);
		if ( barSpark ) then
			barSpark:Show();
		end
		this.startTime = startTime / 1000;
		this.maxValue = endTime / 1000;

		-- startTime to maxValue		no endTime
		this.Bar:SetMinMaxValues(this.startTime, this.maxValue);
		this.Bar:SetValue(this.startTime);
		if ( barText ) then
			barText:SetText(text);
		end
		if ( barIcon ) then
			barIcon:SetTexture(texture);
		end
		this:SetAlpha(1.0);
		this.holdTime = 0;
		this.casting = 1;
		this.channeling = nil;
		this.fadeOut = nil;
		if ( this.showCastbar ) then
			this:Show();
		end

	elseif ( event == "UNIT_SPELLCAST_STOP" or event == "UNIT_SPELLCAST_CHANNEL_STOP" ) then
		if ( not this:IsVisible() ) then
			this:Hide();
		end
		if ( this:IsShown() ) then
			if ( barSpark ) then
				barSpark:Hide();
			end
			--[[if ( barFlash ) then
				barFlash:SetAlpha(0.0);
				barFlash:Show();
			end]]
			this.Bar:SetValue(this.maxValue);
			if ( event == "UNIT_SPELLCAST_STOP" ) then
				--this.Bar:SetStatusBarColor(0.0, 1.0, 0.0);
				this.casting = nil;
			else
				this.channeling = nil;
			end
			this.flash = 1;
			this.fadeOut = 1;
			this.holdTime = 0;
		end
	elseif ( event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_INTERRUPTED" ) then
		if ( this:IsShown() and not this.channeling ) then
			this.Bar:SetValue(this.maxValue);
			this.Bar:SetStatusBarColor(1.0, 0.0, 0.0);
			if ( barSpark ) then
				barSpark:Hide();
			end
			barFlash:SetAlpha(0.0);
			barFlash:Show();
			if ( barText ) then
				if ( event == "UNIT_SPELLCAST_FAILED" ) then
					barText:SetText(FAILED);
				else
					barText:SetText(INTERRUPTED);
				end
			end
			this.flash = 1;
			this.casting = nil;
			this.channeling = nil;
			this.fadeOut = 1;
			this.holdTime = GetTime() + CASTING_BAR_HOLD_TIME;
		end
	elseif ( event == "UNIT_SPELLCAST_DELAYED" ) then
		if ( this:IsShown() ) then
			local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill = UnitCastingInfo(this.unit);
			if ( not name or (not this.showTradeSkills and isTradeSkill)) then
				-- if there is no name, there is no bar
				this:Hide();
				return;
			end
			this.startTime = startTime / 1000;
			this.maxValue = endTime / 1000;
			this.Bar:SetMinMaxValues(this.startTime, this.maxValue);
			if ( not this.casting ) then
				this.Bar:SetStatusBarColor(1.0, 0.7, 0.0);
				if ( barSpark ) then
					barSpark:Show();
				end
				if ( barFlash ) then
					barFlash:SetAlpha(0.0);
					barFlash:Hide();
				end
				this.casting = 1;
				this.channeling = nil;
				this.flash = 0;
				this.fadeOut = 0;
			end
		end
	elseif ( event == "UNIT_SPELLCAST_CHANNEL_START" ) then
		local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill = UnitChannelInfo(this.unit);
		if ( not name or (not this.showTradeSkills and isTradeSkill)) then
			-- if there is no name, there is no bar
			this:Hide();
			return;
		end

		this.Bar:SetStatusBarColor(0.0, 1.0, 0.0);
		this.startTime = startTime / 1000;
		this.endTime = endTime / 1000;
		this.duration = this.endTime - this.startTime;
		this.maxValue = this.startTime;

		-- startTime to endTime		no maxValue
		this.Bar:SetMinMaxValues(this.startTime, this.endTime);
		this.Bar:SetValue(this.endTime);
		if ( barText ) then
			barText:SetText(text);
		end
		if ( barIcon ) then
			barIcon:SetTexture(texture);
		end
		this:SetAlpha(1.0);
		this.holdTime = 0;
		this.casting = nil;
		this.channeling = 1;
		this.fadeOut = nil;
		if ( this.showCastbar ) then
			this:Show();
		end
	elseif ( event == "UNIT_SPELLCAST_CHANNEL_UPDATE" ) then
		if ( this:IsShown() ) then
			local name, nameSubtext, text, texture, startTime, endTime, isTradeSkill = UnitChannelInfo(this.unit);
			if ( not name or (not this.showTradeSkills and isTradeSkill)) then
				-- if there is no name, there is no bar
				this:Hide();
				return;
			end
			this.startTime = startTime / 1000;
			this.endTime = endTime / 1000;
			this.maxValue = this.startTime;
			this.Bar:SetMinMaxValues(this.startTime, this.endTime);
		end
	end
end

function onUpdate(self)
	local barFlash = self.Flash

	if ( this.casting ) then
		local status = GetTime();
		if ( status > this.maxValue ) then
			status = this.maxValue;
		end
		if ( status == this.maxValue ) then
			this.Bar:SetValue(this.maxValue);
			finishSpell();
			return;
		end
		this.Bar:SetValue(status);
		if ( barFlash ) then
			barFlash:Hide();
		end
		local sparkPosition = ((status - this.startTime) / (this.maxValue - this.startTime)) * this:GetWidth();
		if ( sparkPosition < 0 ) then
			sparkPosition = 0;
		end
		if ( barSpark ) then
			barSpark:SetPoint("CENTER", this, "LEFT", sparkPosition, 2);
		end
	elseif ( this.channeling ) then
		local time = GetTime();
		if ( time > this.endTime ) then
			time = this.endTime;
		end
		if ( time == this.endTime ) then
			finishSpell();
			return;
		end
		local barValue = this.startTime + (this.endTime - time);
		this.Bar:SetValue( barValue );
		if ( barFlash ) then
			barFlash:Hide();
		end
	elseif ( GetTime() < this.holdTime ) then
		return;
	elseif ( this.flash ) then
		local alpha = 0;
		if ( barFlash ) then
			alpha = barFlash:GetAlpha() + 1.0 / ( GetFramerate() * 0.3 );
		end
		if ( alpha < 1 ) then
			if ( barFlash ) then
				barFlash:SetAlpha(alpha);
			end
		else
			if ( barFlash ) then
				barFlash:SetAlpha(1.0);
			end
			this.flash = nil;
		end
	elseif ( this.fadeOut ) then
		local alpha = this:GetAlpha() - 1.0 / ( GetFramerate() * 1.0 );
		if ( alpha > 0 ) then
			this:SetAlpha(alpha);
		else
			this.fadeOut = nil;
			this:Hide();
		end
	end
end

function finishSpell(barSpark, barFlash)
	--this.Bar:SetStatusBarColor(0.0, 1.0, 0.0);
	if ( barSpark ) then
		barSpark:Hide();
	end
	if ( barFlash ) then
		barFlash:SetAlpha(0.0);
		barFlash:Show();
	end
	this.flash = 1;
	this.fadeOut = 1;
	this.casting = nil;
	this.channeling = nil;
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

SerenityCastingBar:RegisterEvent("UNIT_SPELLCAST_START");
SerenityCastingBar:RegisterEvent("UNIT_SPELLCAST_STOP");
SerenityCastingBar:RegisterEvent("UNIT_SPELLCAST_FAILED");
SerenityCastingBar:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED");
SerenityCastingBar:RegisterEvent("UNIT_SPELLCAST_DELAYED");
SerenityCastingBar:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START");
SerenityCastingBar:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE");
SerenityCastingBar:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP");
SerenityCastingBar:RegisterEvent("PLAYER_ENTERING_WORLD");

SerenityCastingBar:SetScript("OnEvent", onEvent)
SerenityCastingBar:SetScript("OnUpdate", onUpdate)

SerenityCastingBar.unit = "player"
SerenityCastingBar.showTradeSkills = true
SerenityCastingBar.holdTime = 0
SerenityCastingBar.showCastbar = true

SerenityCastingBar:Hide()

--CastingBarFrame:UnregisterAllEvents()
