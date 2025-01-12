local _, _addon = ...;
local L = _addon:GetLocalization();

local VALUE_COLOR = "|cFFAAFFAA";
local UNIT_COLOR = "|cFFFFFFCC";
local KEY_COLOR = "|cFFFFAAAA";

local stats = _addon.stats;
local lastRow;
local singleStats = {};
local uniformStats = {};
local spellLists = {};

-------------------------------------------------------
-- Setup UI

local frame = CreateFrame("Frame", "SpellCalcStatScreen", UIParent);
frame:SetPoint("CENTER", 0, 0);
frame:SetWidth(400);
frame:SetHeight(500);
frame:SetClampedToScreen(true);
frame:SetMovable(true);
frame:EnableMouse(true);
frame:RegisterForDrag("LeftButton");
frame:SetScript("OnDragStart", frame.StartMoving);
frame:SetScript("OnDragStop", frame.StopMovingOrSizing);
frame:Hide();
frame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", tile = true, tileSize = 16, edgeSize = 16});
frame:SetBackdropColor(0,0,0,1);

local scrollFrame = CreateFrame("ScrollFrame", "SpellCalcStatScreenScroll", frame, "UIPanelScrollFrameTemplate");
local scrollChild = CreateFrame("Frame", nil, scrollFrame);
scrollFrame:SetPoint("TOPLEFT", 0, 0);
scrollFrame:SetPoint("BOTTOMRIGHT", 0, 0);
scrollFrame:SetClipsChildren(true);
scrollFrame.ScrollBar:ClearAllPoints();
scrollFrame.ScrollBar:SetPoint("TOPRIGHT", scrollFrame, "TOPRIGHT", 0, -17);
scrollFrame.ScrollBar:SetPoint("BOTTOMRIGHT", scrollFrame, "BOTTOMRIGHT", 0, 17);
scrollChild:SetSize(scrollFrame:GetWidth()-24, 1);
scrollFrame:SetScrollChild(scrollChild);


-------------------------------------------------------
-- UI functions

--- Creates a row and appends it to the scroll list
local function CreateStatRow()
    local f = CreateFrame("Frame", nil, scrollChild);
    if not lastRow then
        f:SetPoint("TOPLEFT", 5, -5);
        f:SetPoint("TOPRIGHT", 5, -5);
    else
        f:SetPoint("TOPLEFT", lastRow, "BOTTOMLEFT", 0, 0);
        f:SetPoint("TOPRIGHT", lastRow, "BOTTOMRIGHT", 0, 0);
    end
    lastRow = f;
    f:SetHeight(1);
    return f;
end

--- Add single stat value pair to the list
-- @param label The label for the stat
-- @param inTable The table its value is found in
-- @param key The key of the value
-- @param unit The unit of the value, if any
local function AddSingleStat(label, inTable, key, unit)
    local row = CreateStatRow();
    local text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    text:SetPoint("TOPLEFT", 0, 0);
    text:SetText("-");
    row:SetHeight(text:GetHeight());
    table.insert(singleStats, {
        title = label,
        tab = inTable,
        key = key,
        unit = unit,
        f = text
    });
end

--- Add strings to a frame for stat data display
-- @param parent The parent frame to add strings to
local function CreateUniformStatStrings(parent)
    local text = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight");
    text:SetPoint("TOPLEFT", 0, 0);
    text:SetText("-");
    local affectedBy = parent:CreateFontString(nil, "OVERLAY", "GameFontWhiteTiny");
    affectedBy:SetPoint("TOPLEFT", text, "BOTTOMLEFT", 9, 0);
    affectedBy:SetText("-");
    parent:SetHeight(text:GetHeight() + affectedBy:GetHeight());
    return text, affectedBy;
end

--- Add a "uniform" stat to the list
-- @param title The label for the stat
-- @param statTable The table of the stat
-- @param unit The unit of the value, if any
local function AddUniformStatTable(statTable, title, unit)
    local row = CreateStatRow();
    local text, affectedBy = CreateUniformStatStrings(row);
    table.insert(uniformStats, {
        title = title,
        tab = statTable,
        unit = unit,
        f = text,
        b = affectedBy
    });
end

--- Add a school stat list with single primitive values to the list
-- @param schoolTable The table containing the per school values
-- @param title The label for the stat
-- @param unit The unit of the value, if any
local function AddSchoolTableSingle(schoolTable, title, unit)
    if title then
        local row = CreateStatRow();
        local text = row:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2");
        text:SetPoint("LEFT", 0, 0);
        text:SetText(title);
        row:SetHeight(text:GetHeight() + 10);
    end
    for schoolNum, _ in pairs(schoolTable) do
        AddSingleStat(SCHOOL_STRINGS[schoolNum], schoolTable, schoolNum, unit);
    end
end

--- Add a school stat list with "uniform stat entries" to the list
-- @param schoolTable The table containing the per school tables
-- @param title The label for the stat
-- @param unit The unit of the value, if any
local function AddSchoolTableUniform(schoolTable, title, unit)
    if title then
        local row = CreateStatRow();
        local text = row:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2");
        text:SetPoint("LEFT", 0, 0);
        text:SetText(title);
        row:SetHeight(text:GetHeight() + 10);
    end
    for schoolNum, _ in pairs(schoolTable) do
        AddUniformStatTable(schoolTable[schoolNum], SCHOOL_STRINGS[schoolNum], unit);
    end
end

--- Add a list of spell specific stats to the list
-- @param spellTable The table containing the spell tables
-- @param title The label for the stat
-- @param unit The unit of the value, if any
local function AddSpellTable(spellTable, title, unit)
    if title then
        local row = CreateStatRow();
        local text = row:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2");
        text:SetPoint("LEFT", 0, 0);
        text:SetText(title);
        row:SetHeight(text:GetHeight() + 10);
    end
    table.insert(spellLists, {
        row = CreateStatRow(),
        listFrames = {},
        spells = spellTable,
        unit = unit
    });
end

--- Add a title
-- @param title The label for the stat
local function AddTitle(title)
    if title then
        local row = CreateStatRow();
        local text = row:CreateFontString(nil, "OVERLAY", "GameFontNormalMed2");
        text:SetPoint("LEFT", 0, 0);
        text:SetText(title);
        row:SetHeight(text:GetHeight() + 10);
    end
end

-------------------------------------------------------
-- Update UI

local timePassed = 0;
local function UpdateDisplay(self, passed)
    timePassed = timePassed + passed;
    if timePassed < 1 then
        return;
    end
    timePassed = 0;

    for k, data in ipairs(singleStats) do
        local ostr = KEY_COLOR .. data.title .. ": " .. VALUE_COLOR .. math.floor(data.tab[data.key]*100 + 0.5)/100;
        if data.unit then
            ostr = ostr .. UNIT_COLOR .. data.unit;
        end
        data.f:SetText(ostr);
    end

    for k, data in ipairs(uniformStats) do
        local ostr = KEY_COLOR .. data.title .. ": " .. VALUE_COLOR .. math.floor(data.tab.val*100 + 0.5)/100;
        if data.unit then
            ostr = ostr .. UNIT_COLOR .. data.unit;
        end
        data.f:SetText(ostr);
        data.b:SetText("Src: " .. table.concat(data.tab.buffs, ", "));
    end

    for k, spellList in ipairs(spellLists) do
        local pos = 1;
        for spellIdOrName, uniformStat in pairs(spellList.spells) do
            if spellList.listFrames[pos] == nil then
                local f = CreateFrame("Frame", nil, spellList.row);
                local text, affectedBy = CreateUniformStatStrings(f);
                f.text = text; f.affectedBy = affectedBy;
                spellList.listFrames[pos] = f;
                if pos == 1 then
                    f:SetPoint("TOPLEFT", 0, 0);
                    f:SetPoint("TOPRIGHT", 0, 0);
                else
                    f:SetPoint("TOPLEFT", spellList.listFrames[pos-1], "BOTTOMLEFT", 0, 0);
                    f:SetPoint("TOPRIGHT", spellList.listFrames[pos-1], "BOTTOMRIGHT", 0, 0);
                end
            else
                spellList.listFrames[pos]:Show()
            end
            local label = type(spellIdOrName) == "number" and GetSpellInfo(spellIdOrName) or spellIdOrName;
            local ostr = KEY_COLOR .. label .. ": " .. VALUE_COLOR .. math.floor(uniformStat.val*100 + 0.5)/100;
            if spellList.unit then
                ostr = ostr .. UNIT_COLOR .. spellList.unit;
            end
            spellList.listFrames[pos].text:SetText(ostr);
            spellList.listFrames[pos].affectedBy:SetText("Src: " .. table.concat(uniformStat.buffs, ", "));
            pos = pos+1;
        end

        for i = pos, #spellList.listFrames do
            spellList.listFrames[i]:Hide();
        end

        if pos > 1 then
            spellList.row:SetHeight((pos-1) * spellList.listFrames[1]:GetHeight());
        end
    end
end

frame:SetScript("OnShow", function(self)
    self:SetScript("OnUpdate", UpdateDisplay);
end);

frame:SetScript("OnHide", function(self)
    self:SetScript("OnUpdate", nil);
end);

-------------------------------------------------------
-- Add stats to UI

AddSingleStat("Mana", stats, "mana");
AddSingleStat("Spirit regen", stats, "baseManaReg", " mana/s");
AddSingleStat("FSR regen", stats, "manaReg", " mana/s");
AddUniformStatTable(stats.fsrRegenMult, "FSR regen mult", "%");
AddUniformStatTable(stats.mp5, "Mp5 regen", " mana/5s");

AddSchoolTableSingle(stats.spellPower, "Spell power");
AddSingleStat("Healing bonus", stats, "spellHealing");

AddSchoolTableSingle(stats.spellCrit, "Spell crit", "%");
AddSchoolTableUniform(stats.critMods.school, "Crit mods", "%");
AddSpellTable(stats.critMods.spell, nil, "%");
AddSchoolTableUniform(stats.critMult.school, "Crit mult mods", "%");
AddSpellTable(stats.critMult.spell, nil, "%");

AddSchoolTableUniform(stats.spellPen, "Spell pen", "");

AddSchoolTableUniform(stats.hitMods.school, "Hit mods", "%");
AddUniformStatTable(stats.hitBonusSpell, "Spell +hit", "%");
AddSpellTable(stats.hitMods.spell, nil, "%");

AddSchoolTableUniform(stats.dmgDoneMods, "Dmg done mods", "x");
AddUniformStatTable(stats.healingDoneMod, "Healing done mod", "x");

AddSchoolTableUniform(stats.effectMods.school, "Effect mods", "x");
AddSpellTable(stats.effectMods.spell, nil, "x");

AddSpellTable(stats.durationMods, "Duration mods:", "s");
AddSpellTable(stats.flatMods, "Flat mods", "");
AddSpellTable(stats.extraSp, "Extra SP", "");
AddSpellTable(stats.mageNWRProc, "Mage NWR proc", "");

AddTitle("Clearcast");
AddUniformStatTable(stats.clearCastChance, "Clearcast chance", "%");
AddUniformStatTable(stats.clearCastChanceDmg, "Clearcast chance dmg", "%");

AddTitle("Misc");
AddUniformStatTable(stats.illumination, "Illumination", "%");
AddUniformStatTable(stats.ignite, "Ignite", "");
AddUniformStatTable(stats.impShadowBolt, "Imp Shadow Bolt", "%");