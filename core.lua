local select, UnitBuff, UnitDebuff, UnitAura, UnitGUID, tonumber, strfind, hooksecurefunc =
	select, UnitBuff, UnitDebuff, UnitAura, UnitGUID, tonumber, strfind, hooksecurefunc

local function addBuffLine(self, func, unit, index, filter)
	local srcUnit = select(8, func(unit, index, filter))
	local id = select(11, func(unit, index, filter))

	if srcUnit then
		self:AddLine("|cffff0000 --")
		self:AddDoubleLine("|cffff0000Номер:", "|cffff0000"..id)

		local src = GetUnitName(srcUnit, true)

		if srcUnit == "pet" or srcUnit == "vehicle" then
			src = format("%s (%s)", src, GetUnitName("player", true))
		else
			local partypet = srcUnit:match("^partypet(%d+)$")
			local raidpet = srcUnit:match("^raidpet(%d+)$")

			if partypet then
				src = format("%s (%s)", src, GetUnitName("party"..partypet, true))
			elseif raidpet then
				src = format("%s (%s)", src, GetUnitName("raid"..raidpet, true))
			end
		end

		self:AddDoubleLine("|cffff0000Наложивший:", "|cffff0000" ..src)
		self:Show()
	end
end

local function addItemLine(self, id)
	self:AddDoubleLine("|cffff0000Номер:","|cffff0000"..id)
	self:Show()
end

local function addSpellLine(self, id)
	self:AddDoubleLine("|cffff0000Номер:","|cffff0000"..id)
	self:Show()
end

GameTooltip:HookScript("OnTooltipSetUnit", function(self)
	if C_PetBattles.IsInBattle() then
		return
	end

	local unit = select(2, self:GetUnit())

	if unit then
        local guid = UnitGUID(unit) or ""
        local id = tonumber(guid:match("-(%d+)-%x+$"), 10)

		if id and guid:match("%a+") ~= "Player" then
			addItemLine(GameTooltip, id)
		end
    end
end)

GameTooltip:HookScript("OnTooltipSetSpell", function(self)
	local id = select(3, self:GetSpell())

	if id then
		addSpellLine(self, id)
	end
end)

hooksecurefunc("SetItemRef", function(link, ...)
	local id = tonumber(link:match("spell:(%d+)"))

	if id then
		addSpellLine(ItemRefTooltip, id)
	end
end)

hooksecurefunc("SetItemRef", function(link, ...)
	local id = tonumber(link:match("quest:(%d+)"))

	if (id) then
		ItemRefTooltip:AddDoubleLine("|cffff0000Номер:","|cffff0000"..id)
		ItemRefTooltip:Show();
   end
end)

hooksecurefunc("SetItemRef", function(link, ...)
	local id = tonumber(link:match("achievement:(%d+)"))

	if (id) then
		ItemRefTooltip:AddDoubleLine("|cffff0000Номер:","|cffff0000"..id)
		ItemRefTooltip:Show();
   	end
end)

local function attachItemTooltip(self)
	local link = select(2, self:GetItem())

	if not link then
		return
	end

	local id = select(3,strfind(link, "^|%x+|Hitem:(%-?%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%-?%d+):(%-?%d+)"))

	if id then
		addItemLine(self, id)
	end
end

GameTooltip:HookScript("OnTooltipSetItem", attachItemTooltip)
ItemRefTooltip:HookScript("OnTooltipSetItem", attachItemTooltip)
ItemRefShoppingTooltip1:HookScript("OnTooltipSetItem", attachItemTooltip)
ItemRefShoppingTooltip2:HookScript("OnTooltipSetItem", attachItemTooltip)
ItemRefShoppingTooltip3:HookScript("OnTooltipSetItem", attachItemTooltip)
ShoppingTooltip1:HookScript("OnTooltipSetItem", attachItemTooltip)
ShoppingTooltip2:HookScript("OnTooltipSetItem", attachItemTooltip)
ShoppingTooltip3:HookScript("OnTooltipSetItem", attachItemTooltip)

-- For unit kaster name
GameTooltip.OldSetUnitAura = GameTooltip.SetUnitAura
GameTooltip.OldSetUnitBuff = GameTooltip.SetUnitBuff
GameTooltip.OldSetUnitDebuff = GameTooltip.SetUnitDebuff

function GameTooltip:SetUnitAura(unit, index, filter, ...)
	self:OldSetUnitAura(unit, index, filter, ...)
	addBuffLine(self, UnitAura, unit, index, filter)
end

function GameTooltip:SetUnitBuff(unit, index, filter, ...)
	self:OldSetUnitBuff(unit, index, filter, ...)
	addBuffLine(self, UnitBuff, unit, index, filter)
end

function GameTooltip:SetUnitDebuff(unit, index, filter, ...)
	self:OldSetUnitDebuff(unit, index, filter, ...)
	addBuffLine(self, UnitDebuff, unit, index, filter)
end
