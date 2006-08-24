
local function create(name, source, size, r, g, b, a)
	local obj = CreateFont(name)
	obj:SetFont("Interface\\AddOns\\Serenity\\Fonts\\"..source..".ttf", size)
	obj:SetTextColor(r, g, b, a)
end


create("SerenityFontNormal",		"Normal",	13, 1.00, 0.82, 0.00, 1.00)
create("SerenityFontNormalSmall",	"Bold",		12, 1.00, 0.82, 0.00, 1.00)
create("SerenityFontNormalLarge",	"Bold",		17, 1.00, 0.82, 0.00, 1.00)

create("SerenityChatFontNormal",	"Normal",	14, 0.00, 0.00, 0.00, 1.00)
