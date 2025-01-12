local _, _addon = ...;

local ITEM_SLOTS = {
    [1] = "head",
    [2] = "neck",
    [3] = "shoulder",
    [5] = "chest",
    [6] = "waist",
    [7] = "legs",
    [8] = "feet",
    [9] = "wrist",
    [10] = "hands",
    [11] = "finger 1", 
    [12] = "finger 2", 
    [13] = "trinket 1",
    [14] = "trinket 2",
    [15] = "back",
    [16] = "main hand",
    [17] = "off hand",
    [18] = "ranged",
};

local items = {};
local sets = {};

--- Apply or remove effect for destination
-- @param value The effect value, negative to remove buff
-- @param dest The destination table
-- @param name The name of the buff
local function ApplyOrRemove(value, dest, name)
    dest.val = dest.val + value;
    if value > 0 then
        table.insert(dest.buffs, name);
    else
        _addon:RemoveTableEntry(dest.buffs, name);
    end
end

--- Update set item count and add/remove buffs as needed
-- @param setId The set id
-- @param change The item count change
local function UpdateSet(setId, change)
    if sets[setId] == nil then
        sets[setId] = change;
    else
        sets[setId] = sets[setId] + change;
    end

    local newCount, oldCount = sets[setId], sets[setId]-change;
    local setData = _addon.itemSetData[setId];

    _addon:PrintDebug(("Updating set: %s (%d -> %d)"):format(setData.name, oldCount, newCount));

    for k, effectData in ipairs(setData.effects) do
        if effectData.need <= newCount then
            if effectData.need > oldCount then
                if type(effectData.effect) ~= "table" then
                    _addon:PrintWarn(("Set bonus %d not implemented for %s: %s"):format(effectData.need, setData.name, effectData.effect));
                else
                    local ed = effectData.effect;
                    local bname = setData.name .. effectData.need;
                    _addon:PrintDebug(("Add set bonus %s"):format(bname));
                    _addon:ApplyBuff(bname, ed.effect, ed.value, ed.affectSchool, ed.affectSpell);
                end
            end

        else
            if effectData.need <= oldCount then
                if type(effectData.effect) == "table" then
                    local ed = effectData.effect;
                    local bname = setData.name .. effectData.need;
                    _addon:PrintDebug(("Remove set bonus %s"):format(bname));
                    _addon:RemoveBuff(bname, ed.effect, ed.value, ed.affectSchool, ed.affectSpell);
                end
            end
        end
    end
end

local function ChangeItemEffects(itemData, itemName, remove)
    local val;
    if itemData.mp5 then
        val = remove and -itemData.mp5 or itemData.mp5;
        ApplyOrRemove(val, _addon.stats.mp5, itemName);
    end

    if itemData.hit then
        val = remove and -itemData.hit or itemData.hit;
        ApplyOrRemove(val, _addon.stats.hitBonus, itemName);
    end

    if itemData.spellHit then
        val = remove and -itemData.spellHit or itemData.spellHit;
        ApplyOrRemove(val, _addon.stats.hitBonusSpell, itemName);
    end

    if itemData.spellPen then
        val = remove and -itemData.spellPen or itemData.spellPen;
        for i=3,7 do
            ApplyOrRemove(val, _addon.stats.spellPen[i], itemName);
        end
    end

    _addon.lastChange = time();
end

--- Equip item for slot
-- @param itemId The item ID to equip
-- @param slotId The slot item is equipped into
local function EquipItem(itemId, slotId)
    _addon:PrintDebug("Item " .. itemId .. " -> Slot " .. slotId);
    local itemData = _addon.itemData[itemId];
    local itemName = GetItemInfo(itemId);
    local setId = _addon.setItemData[itemId];

    if itemData then
        _addon:PrintDebug("Item has effect");
        ChangeItemEffects(itemData, itemName);
    end

    if _addon.itemEffects[itemId] then
        for _, effect in ipairs(_addon.itemEffects[itemId]) do
            _addon:ApplyBuff(itemName, effect.type, effect.value, effect.affectSchool, effect.affectSpell);
        end
        _addon.lastChange = time();
    end

    if setId then
        _addon:PrintDebug("Item is in a set");
        UpdateSet(setId, 1);
    end

    items[slotId] = itemId;
end

--- Unequip previously equipped item
-- @param slotId The slot item was in
local function UnequipItem(slotId)
    local itemData = _addon.itemData[items[slotId]];
    local itemName = GetItemInfo(items[slotId]);
    local setId = _addon.setItemData[items[slotId]];

    if itemData then
        _addon:PrintDebug("Item had effect");
        ChangeItemEffects(itemData, itemName, true);
    end

    if _addon.itemEffects[items[slotId]] then
        for _, effect in ipairs(_addon.itemEffects[items[slotId]]) do
            _addon:RemoveBuff(itemName, effect.type, effect.value, effect.affectSchool, effect.affectSpell);
        end
        _addon.lastChange = time();
    end

    if setId then
        _addon:PrintDebug("Item was in a set");
        UpdateSet(setId, -1);
    end

    items[slotId] = nil;
    _addon:PrintDebug("Slot " .. slotId .. " empty");
end

--- Update all item slots
function _addon:UpdateItems()
    _addon:PrintDebug("Update items");

    for slot, slotName in pairs(ITEM_SLOTS) do
        local itemId = GetInventoryItemID("player", slot);

        if itemId ~= nil then
            local durability = GetInventoryItemDurability(slot);

            if items[slot] ~= itemId  then
                if items[slot] ~= nil then
                    _addon:PrintDebug("Unequip old item from slot "..slotName);
                    UnequipItem(slot);
                end

                if durability == nil or durability > 0 then
                    _addon:PrintDebug("Equip new item " .. itemId .. " in slot "..slotName);
                    EquipItem(itemId, slot);
                end

            else
                if durability ~= nil and durability == 0 then
                    _addon:PrintDebug("Unequip item " .. itemId .. " in slot "..slotName.." because it is broken");
                    UnequipItem(slot);
                end
            end

        else
            if items[slot] ~= nil then
                _addon:PrintDebug("Unequip old item from slot "..slotName);
                UnequipItem(slot);
            end
        end

    end
end