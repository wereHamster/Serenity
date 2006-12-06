
local SerenityConsole, obj

SerenityConsole = CreateFrame("EditBox", nil, SerenityParent)
SerenityConsole:SetWidth(500)
SerenityConsole:SetHeight(40)
SerenityConsole:SetFrameStrata("DIALOG")
SerenityConsole:SetPoint("BOTTOM", SerenityParent, "BOTTOM", 0, 8)

obj = SerenityConsole:CreateTexture(nil, "BACKGROUND")
obj:SetPoint("BOTTOM", SerenityConsole)
obj:SetTexture("Interface\\AddOns\\Serenity\\Textures\\SerenityConsole")
obj:SetWidth(512)
obj:SetHeight(64)

SerenityConsole.Header = SerenityConsole:CreateFontString(nil, "ARTWORK")
SerenityConsole.Header:SetPoint("TOPLEFT", SerenityConsole, "TOPLEFT", 0, -4)
SerenityConsole.Header:SetFontObject(SerenityChatFontNormal)

SerenityConsole:SetFontObject(SerenityChatFontNormal)
SerenityConsole:SetMaxBytes(256)
SerenityConsole:SetMaxLetters(255)
SerenityConsole:SetMultiLine(nil)
SerenityConsole:SetHistoryLines(32)
SerenityConsole:SetAltArrowKeyMode(1)

do
	SerenityConsole.chatType = "SAY";
	SerenityConsole.stickyType = "SAY";
	SerenityConsole.chatLanguage = GetDefaultLanguage();

	SerenityConsole.lastTell = {};
	for i = 1, NUM_REMEMBERED_TELLS, 1 do
		SerenityConsole.lastTell[i] = "";
	end
	
	SerenityConsole:SetTextInsets(0, 0, 16, 0);
end

function SerenityConsole_OnUpdate()
	if ( this.setText == 1) then
		this:SetText(this.text);
		this.setText = 0;
		SerenityConsole_ParseText(this, 0);
	end
end

function SerenityConsole_OnShow()
	if ( this.chatType == "PARTY" and UnitName("party1") == "" ) then
		this.chatType = "SAY";
	end
	if ( this.chatType == "RAID" and (GetNumRaidMembers() == 0) ) then
		this.chatType = "SAY";
	end
	if ( (this.chatType == "GUILD" or this.chatType == "OFFICER") and not IsInGuild() ) then
		this.chatType = "SAY";
	end
	this.tabCompleteIndex = 1;
	this.tabCompleteText = nil;
	SerenityConsole_UpdateHeader(this);
	SerenityConsole_OnInputLanguageChanged();
	this:SetFocus();
end

function SerenityConsole_GetLastTellTarget(editBox)
	for index, value in pairs(editBox.lastTell) do
		if ( value and (strlen(value) > 0) ) then
			return value;
		end
	end
	return "";
end

function SerenityConsole_GetLastToldTarget(editBox)
	local lastTold = editBox.toldTarget;
	if(not (lastTold == nil)) then
		return lastTold
	else
		--Error
		return ""
	end
end

function SerenityConsole_SetLastToldTarget(editBox, name)
	editBox.toldTarget = name;
end

function SerenityConsole_SetLastTellTarget(editBox, target)
	editBox = SerenityConsole
	local found = NUM_REMEMBERED_TELLS;
	for index, value in pairs(editBox.lastTell) do
		if ( strupper(target) == strupper(value) ) then
			found = index;
			break;
		end
	end

	for i = found, 2, -1 do
		editBox.lastTell[i] = editBox.lastTell[i-1];
	end
	editBox.lastTell[1] = target;
end

function SerenityConsole_GetNextTellTarget(editBox, target)
	if ( not target or (strlen(target) == 0) ) then
		return editBox.lastTell[1];
	end

	for i = 1, NUM_REMEMBERED_TELLS - 1, 1 do
		if ( strlen(editBox.lastTell[i]) == 0 ) then
			break;
		elseif ( strupper(target) == strupper(editBox.lastTell[i]) ) then
			if ( strlen(editBox.lastTell[i+1]) > 0 ) then
				return editBox.lastTell[i+1];
			else
				break;
			end
		end
	end

	return editBox.lastTell[1];
end

function SerenityConsole_UpdateHeader(editBox)
	local type = editBox.chatType;
	if ( not type ) then
		return;
	end

	local info = ChatTypeInfo[type];
	local header = SerenityConsole.Header
	if ( not header ) then
		return;
	end

	if ( type == "WHISPER" ) then
		header:SetText(format(TEXT(getglobal("CHAT_WHISPER_SEND")), editBox.tellTarget));
	elseif ( type == "EMOTE" ) then
		header:SetText(format(TEXT(getglobal("CHAT_EMOTE_SEND")), UnitName("player")));
	elseif ( type == "CHANNEL" ) then
		local channel, channelName, instanceID = GetChannelName(editBox.channelTarget);
		if ( channelName ) then
			if ( instanceID > 0 ) then
				channelName = channelName.." "..instanceID;
			end
			info = ChatTypeInfo["CHANNEL"..channel];
			editBox.channelTarget = channel;
			header:SetText(format(TEXT(getglobal("CHAT_CHANNEL_SEND")), channel, channelName));
		end
	else
		header:SetText(TEXT(getglobal("CHAT_"..type.."_SEND")));
	end

	header:SetTextColor(info.r, info.g, info.b);
	
	editBox:SetTextColor(info.r, info.g, info.b);
end

function SerenityConsole_AddHistory(editBox)
	local text = "";
	local type = editBox.chatType;
	local header = getglobal("SLASH_"..type.."1");
	if ( header ) then
		text = header;
	end

	if ( type == "WHISPER" ) then
		text = text.." "..editBox.tellTarget;
	elseif ( type == "CHANNEL" ) then
		text = "/"..editBox.channelTarget;
	end

	local editBoxText = editBox:GetText();
	if ( strlen(editBoxText) > 0 ) then
		text = text.." "..editBox:GetText();
	end

	if ( strlen(text) > 0 ) then
		editBox:AddHistoryLine(text);
	end
end

function SerenityConsole_SendText(editBox, addHistory)
	SerenityConsole_ParseText(editBox, 1);

	local type = editBox.chatType;
	local text = editBox:GetText();
	if ( strlen(gsub(text, "%s*(.*)", "%1")) > 0 ) then
		if ( type == "WHISPER") then
			if(strlen(text) > 0) then
				SerenityConsole_SetLastToldTarget(editBox, editBox.tellTarget);
			end
			SendChatMessage(text, type, editBox.language, editBox.tellTarget);
		elseif ( type == "CHANNEL") then
			SendChatMessage(text, type, editBox.language, editBox.channelTarget);
		else
			SendChatMessage(text, type, editBox.language);
		end
		if ( addHistory ) then
			SerenityConsole_AddHistory(editBox);
		end
	end
end

function SerenityConsole_OnEnterPressed()
	SerenityConsole_SendText(this, 1);

	local type = this.chatType;
	if ( ChatTypeInfo[type].sticky == 1 ) then
		this.stickyType = type;
	end
	
	SerenityConsole_OnEscapePressed();
end

function SerenityConsole_OnEscapePressed()
	SerenityConsole.chatType = SerenityConsole.stickyType;
	SerenityConsole:SetText("");
	SerenityConsole:Hide();
end

function SerenityConsole_OnSpacePressed()
	SerenityConsole_ParseText(this, 0);
end

function SerenityConsole_OnTabPressed()
	if ( this.chatType == "WHISPER" ) then
		local newTarget = SerenityConsole_GetNextTellTarget(this, this.tellTarget);
		if ( newTarget and (strlen(newTarget) > 0) ) then
			this.tellTarget = newTarget;
			SerenityConsole_UpdateHeader(this);
		end
		return;
	end

	local text = this.tabCompleteText;
	if ( not text ) then
		text = this:GetText();
		this.tabCompleteText = text;
	end

	if ( strsub(text, 1, 1) ~= "/" ) then
		return;
	end

	-- Increment the current tabcomplete count
	local tabCompleteIndex = this.tabCompleteIndex;
	this.tabCompleteIndex = tabCompleteIndex + 1;

	-- If the string is in the format "/cmd blah", command will be "cmd"
	local command = gsub(text, "/([^%s]+)%s(.*)", "/%1", 1);

	for index, value in pairs(ChatTypeInfo) do
		local i = 1;
		local cmdString = TEXT(getglobal("SLASH_"..index..i));
		while ( cmdString ) do
			if ( strfind(cmdString, command, 1, 1) ) then
				tabCompleteIndex = tabCompleteIndex - 1;
				if ( tabCompleteIndex == 0 ) then
					this.ignoreTextChange = 1;
					this:SetText(cmdString);
					return;
				end
			end
			i = i + 1;
			cmdString = TEXT(getglobal("SLASH_"..index..i));
		end
	end

	for index, value in pairs(SlashCmdList) do
		local i = 1;
		local cmdString = TEXT(getglobal("SLASH_"..index..i));
		while ( cmdString ) do
			if ( strfind(cmdString, command, 1, 1) ) then
				tabCompleteIndex = tabCompleteIndex - 1;
				if ( tabCompleteIndex == 0 ) then
					this.ignoreTextChange = 1;
					this:SetText(cmdString);
					return;
				end
			end
			i = i + 1;
			cmdString = TEXT(getglobal("SLASH_"..index..i));
		end
	end

	local i = 1;
	local j = 1;
	local cmdString = TEXT(getglobal("EMOTE"..i.."_CMD"..j));
	while ( cmdString ) do
		if ( strfind(cmdString, command, 1, 1) ) then
			tabCompleteIndex = tabCompleteIndex - 1;
			if ( tabCompleteIndex == 0 ) then
				this.ignoreTextChange = 1;
				this:SetText(cmdString);
				return;
			end
		end
		j = j + 1;
		cmdString = TEXT(getglobal("EMOTE"..i.."_CMD"..j));
		if ( not cmdString ) then
			i = i + 1;
			j = 1;
			cmdString = TEXT(getglobal("EMOTE"..i.."_CMD"..j));
		end
	end

	-- No tab completion
	this:SetText(this.tabCompleteText);
end

function SerenityConsole_OnTextChanged()
	if ( not this.ignoreTextChange ) then
		this.tabCompleteIndex = 1;
		this.tabCompleteText = nil;
	end
	this.ignoreTextChange = nil;
end

function SerenityConsole_OnTextSet()
	SerenityConsole_ParseText(this, 0);
end

function SerenityConsole_OnInputLanguageChanged()
end

function SerenityConsole_ParseText(editBox, send)

	local text = editBox:GetText();
	if ( strlen(text) <= 0 ) then
		return;
	end

	if ( strsub(text, 1, 1) ~= "/" ) then
		return;
	end

	-- If the string is in the format "/cmd blah", command will be "cmd"
	local command = gsub(text, "/([^%s]+)%s(.*)", "/%1", 1);
	local msg = "";


	if ( command ~= text ) then
		msg = strsub(text, strlen(command) + 2);
	end

	command = gsub(command, "%s+", "");
	command = strupper(command);

	local channel = gsub(command, "/([0-9]+)", "%1");

	if( strlen(channel) > 0 and channel >= "0" and channel <= "9" ) then
		local channelNum, channelName = GetChannelName(channel);
		if ( channelNum > 0 ) then
			editBox.channelTarget = channelNum;
			command = strupper(SLASH_CHANNEL1);
			editBox.chatType = "CHANNEL";
			editBox:SetText(msg);
			SerenityConsole_UpdateHeader(editBox);
			return;
		end
	else
		for index, value in pairs(ChatTypeInfo) do
			local i = 1;
			local cmdString = TEXT(getglobal("SLASH_"..index..i));
			while ( cmdString ) do
				cmdString = strupper(cmdString);
				if ( cmdString == command ) then
					if ( index == "WHISPER" ) then
						SerenityConsole_ExtractTellTarget(editBox, msg);
					elseif ( index == "REPLY" ) then
						local lastTell = SerenityConsole_GetLastTellTarget(editBox);
						if ( strlen(lastTell) > 0 ) then
							editBox.chatType = "WHISPER";
							editBox.tellTarget = lastTell;
							editBox:SetText(msg);
							SerenityConsole_UpdateHeader(editBox);
						else
							if ( send == 1 ) then
								SerenityConsole_OnEscapePressed();
							end
							return;
						end
					elseif (index == "CHANNEL") then
						SerenityConsole_ExtractChannel(editBox, msg);
					else
						editBox.chatType = index;
						editBox:SetText(msg);
						SerenityConsole_UpdateHeader(editBox);
					end
					return;
				end
				i = i + 1;
				cmdString = TEXT(getglobal("SLASH_"..index..i));
			end
		end
	end

	if ( send == 0 ) then
		return;
	end


	for index, value in pairs(SlashCmdList) do
		local i = 1;
		local cmdString = TEXT(getglobal("SLASH_"..index..i));
		while ( cmdString ) do
			cmdString = strupper(cmdString);
			if ( cmdString == command ) then
				value(msg);
				editBox:AddHistoryLine(text);
				SerenityConsole_OnEscapePressed();
				return;
			end
			i = i + 1;
			cmdString = TEXT(getglobal("SLASH_"..index..i));
		end
	end

	local i = 1;
	local j = 1;
	local cmdString = TEXT(getglobal("EMOTE"..i.."_CMD"..j));
	while ( cmdString ) do
		if ( strupper(cmdString) == command ) then
			local token = getglobal("EMOTE"..i.."_TOKEN");
			if ( token ) then
				DoEmote(token, msg);
			end
			editBox:AddHistoryLine(text);
			SerenityConsole_OnEscapePressed();
			return;
		end
		j = j + 1;
		cmdString = TEXT(getglobal("EMOTE"..i.."_CMD"..j));
		if ( not cmdString ) then
			i = i + 1;
			j = 1;
			cmdString = TEXT(getglobal("EMOTE"..i.."_CMD"..j));
		end
	end


	-- Unrecognized chat command, show simple help text
	local info = ChatTypeInfo["SYSTEM"];
	DEFAULT_CHAT_FRAME:AddMessage(TEXT(HELP_TEXT_SIMPLE), info.r, info.g, info.b, info.id);
	SerenityConsole_OnEscapePressed();
	return;
end

function SerenityConsole_ExtractTellTarget(editBox, msg)
	-- Grab the first "word" in the string
	local target = gsub(msg, "(%s*)([^%s]+)(.*)", "%2", 1);
	if ( (strlen(target) <= 0) or (strsub(target, 1, 1) == "|") ) then
		return;
	end

	msg = strsub(msg, strlen(target) + 2);

	editBox.tellTarget = target;
	editBox.chatType = "WHISPER";
	editBox:SetText(msg);
	SerenityConsole_UpdateHeader(editBox);
end

function SerenityConsole_ExtractChannel(editBox, msg)
	local target = gsub(msg, "(%s*)([^%s]+)(.*)", "%2", 1);
	if ( strlen(target) <= 0 ) then
		return;
	end
	
	local channelNum, channelName = GetChannelName(target);
	if ( channelNum <= 0 ) then
		return;
	end

	msg = strsub(msg, strlen(target) + 2);

	editBox.channelTarget = channelNum;
	editBox.chatType = "CHANNEL";
	editBox:SetText(msg);
	SerenityConsole_UpdateHeader(editBox);
end

function SerenityConsole_OpenChat(text)
	SerenityConsole:Show();
	SerenityConsole.setText = 1;
	SerenityConsole.text = text;

	if ( SerenityConsole.chatType == SerenityConsole.stickyType ) then
		if ( (SerenityConsole.stickyType == "PARTY") and (GetNumPartyMembers() == 0) ) then
			SerenityConsole.chatType = "SAY";
			ChatEdit_UpdateHeader(SerenityConsole);
		elseif ( (SerenityConsole.stickyType == "RAID") and (GetNumRaidMembers() == 0) ) then
			SerenityConsole.chatType = "SAY";
			ChatEdit_UpdateHeader(SerenityConsole);
		end
	end
end

ChatFrame_OpenChat = SerenityConsole_OpenChat
ChatEdit_SetLastTellTarget = SerenityConsole_SetLastTellTarget

function ChatFrameEditBox:IsShown()
	return SerenityConsole:IsShown()
end

function ChatFrameEditBox:IsVisible()
	return SerenityConsole:IsVisible()
end

function ChatFrameEditBox:Insert(text)
	SerenityConsole:Insert(text)
end


SerenityConsole:SetScript("OnLoad",					SerenityConsole_OnLoad)
SerenityConsole:SetScript("OnShow",					SerenityConsole_OnShow)
SerenityConsole:SetScript("OnUpdate",				SerenityConsole_OnUpdate)
SerenityConsole:SetScript("OnEnterPressed",			SerenityConsole_OnEnterPressed)
SerenityConsole:SetScript("OnEscapePressed",		SerenityConsole_OnEscapePressed)
SerenityConsole:SetScript("OnSpacePressed",			SerenityConsole_OnSpacePressed)
SerenityConsole:SetScript("OnTabPressed",			SerenityConsole_OnTabPressed)
SerenityConsole:SetScript("OnTextChanged",			SerenityConsole_OnTextChanged)
SerenityConsole:SetScript("OnTextSet",				SerenityConsole_OnTextSet)
SerenityConsole:SetScript("OnInputLanguageChanged",	SerenityConsole_OnInputLanguageChanged)

SerenityConsole:Hide()
