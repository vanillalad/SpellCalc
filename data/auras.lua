local _, _addon = ...;

local BLESSING_OF_WISDOM = GetSpellInfo(19852);
local GREATER_BLESSING_OF_WISDOM = GetSpellInfo(25918);
local MANA_SPRING = GetSpellInfo(10491);

-- Buffs the player can have
_addon.buffData = {
    [16609] = { -- Warchief's Blessing
        effect = _addon.EFFECT_TYPE_MP5,
        value = 10,
    },
    [BLESSING_OF_WISDOM] = {
        effect = _addon.EFFECT_TYPE_MP5,
        ttValue = "(%d+)",
    },
    [GREATER_BLESSING_OF_WISDOM] = {
        effect = _addon.EFFECT_TYPE_MP5,
        ttValue = "(%d+)",
    },
    [MANA_SPRING] = {
        effect = _addon.EFFECT_TYPE_MP5,
        ttValue = "(%d+)",
    },
    [18194] = { -- Nightfin Soup?
        effect = _addon.EFFECT_TYPE_MP5,
        value = 8,
    },
    -- TODO: Other buffs that are outside the scope of base API queries
};

-- Buffs the target can have (NYI)
_addon.targetBuffs = {
    -- TODO: buffs on the target
    -- e.g. pala blessing for more heal, mage magic buffy thingy, etc.
};

-- Debuffs the target can have (NYI)
_addon.debuffData = {
    -- TODO: debuffs on the target
    -- e.g. shadow weaving, mage frosty thingy, etc.
};