local _, _addon = ...;
local _, playerClass = UnitClass("player");
if playerClass ~= "PRIEST" then
    return;
end

local DEVOURING_PLAGUE = GetSpellInfo(19276);
local MIND_BLAST = GetSpellInfo(8092);
local SHADOWGUARD = GetSpellInfo(19331);
local SHADOW_WORD_PAIN = GetSpellInfo(589);
local MIND_FLAY = GetSpellInfo(17312);
local GREATER_HEAL = GetSpellInfo(10963);
local POWER_WORD_SHIELD = GetSpellInfo(17);
local FLASH_HEAL = GetSpellInfo(10917);
local HEAL = GetSpellInfo(2054);
local SMITE = GetSpellInfo(585);
local DESPERATE_PRAYER = GetSpellInfo(13908);
local PRAYER_OF_HEALING = GetSpellInfo(10960);
local HOLY_FIRE = GetSpellInfo(14914);
local HOLY_NOVA = GetSpellInfo(15237);
local RENEW = GetSpellInfo(139);


local MIND_BLAST_GENERIC = {
    school = _addon.SCHOOL.SHADOW,
    ttMinMax = "(%d+).-%s(%d+)",
    coef = 1.5/3.5
};

local SMITE_GENERIC = {
    school = _addon.SCHOOL.HOLY,
    ttMinMax = "(%d+).-%s(%d+)",
    coef = 2.5/3.5
};

local DESPERATE_PRAYER_GENERIC = {
    school = _addon.SCHOOL.HOLY,
    isHeal = true,
    ttMinMax = "(%d+).-%s(%d+)",
    coef = 1.5/3.5
};

local SHADOW_WORD_PAIN_GENERIC = {
    school = _addon.SCHOOL.SHADOW,
    isDuration = true,
    ttDuration = ".*%s(%d+)",
    tickPeriod = 3,
    ttMinMax = "(%d+)",
    coef = 0.2
}

_addon.spellData = {
    [8092] = _addon:SpellDataMerge(MIND_BLAST_GENERIC, {level = 10}),
    [8102] = _addon:SpellDataMerge(MIND_BLAST_GENERIC, {level = 16}),
    [MIND_BLAST] = MIND_BLAST_GENERIC,

    [585] = _addon:SpellDataMerge(SMITE_GENERIC, {level = 1}),
    [591] = _addon:SpellDataMerge(SMITE_GENERIC, {level = 6}),
    [598] = _addon:SpellDataMerge(SMITE_GENERIC, {level = 14}),
    [SMITE] = SMITE_GENERIC,

    [13908] = _addon:SpellDataMerge(DESPERATE_PRAYER_GENERIC, {level = 10}),
    [DESPERATE_PRAYER] = DESPERATE_PRAYER_GENERIC,

    [HOLY_NOVA] = {
        school = _addon.SCHOOL.HOLY,
        primary = {
            ttMinMax = "(%d+).-%s(%d+)",
            coef = 0.071
        },
        secondary = {
            isHeal = true,
            ttMinMax = ".*%s(%d+).-%s(%d+)",
            coef = 0.071
        },
    },

    [HOLY_FIRE] = {
        school = _addon.SCHOOL.HOLY,
        primary = {
            ttMinMax = "(%d+).-%s(%d+)",
            coef = 0.6,
        },
        secondary = {
            isDuration = true,
            duration = 10,
            tickPeriod = 2,
            ttMinMax = ".*%s(%d+).*%s%d",
            coef = 0.27/5,
        }
    },

    [MIND_FLAY] = {
        school = _addon.SCHOOL.SHADOW,
        isDuration = true,
        isChannel = true,
        duration = 3,
        tickPeriod = 1,
        ttMinMax = "(%d+)",
        coef = 0.15
    },

    [589] = _addon:SpellDataMerge(SHADOW_WORD_PAIN_GENERIC, {level = 4}),
    [594] = _addon:SpellDataMerge(SHADOW_WORD_PAIN_GENERIC, {level = 10}),
    [970] = _addon:SpellDataMerge(SHADOW_WORD_PAIN_GENERIC, {level = 18}),
    [SHADOW_WORD_PAIN] = SHADOW_WORD_PAIN_GENERIC,

    [DEVOURING_PLAGUE] = {
        school = _addon.SCHOOL.SHADOW,
        isDuration = true,
        duration = 24,
        tickPeriod = 3,
        ttMinMax = "(%d+)",
        coef = 1/16
    },

    [SHADOWGUARD] = {
        school = _addon.SCHOOL.SHADOW,
        isDmgShield = true,
        charges = 3,
        ttMinMax = "(%d+)",
        coef = 1/3
    },
};

_addon.talentData = {
    -- Meditation
    {
        tree = 1,
        talent = 8,
        effects = {
            {
                type = _addon.EFFECT_TYPE.FSR_REGEN,
                perPoint = 5
            }
        }
    },
    -- Improved Power Word: Shield
    {
        tree = 1,
        talent = 5,
        effects = {
            {
                type = _addon.EFFECT_TYPE.MOD_EFFECT,
                affectSpell = {POWER_WORD_SHIELD},
                perPoint = 5
            }
        }
    },
    -- Force of will
    {
        tree = 1,
        talent = 14,
        effects = {
            {
                type = _addon.EFFECT_TYPE.MOD_DMG_DONE,
                affectSchool = _addon.SCHOOL_MASK.ALL_SPELL,
                perPoint = 1
            },
            {
                type = _addon.EFFECT_TYPE.MOD_CRIT,
                affectSpell = {SMITE, MIND_BLAST, HOLY_FIRE, HOLY_NOVA},
                perPoint = 1
            }
        }
    },

    -- Improved Renew
    {
        tree = 2,
        talent = 2,
        effects = {
            {
                type = _addon.EFFECT_TYPE.MOD_EFFECT,
                affectSpell = {RENEW},
                perPoint = 5
            }
        }
    },
    -- Holy Spec
    {
        tree = 2,
        talent = 3,
        effects = {
            {
                type = _addon.EFFECT_TYPE.MOD_CRIT,
                affectSchool = _addon.SCHOOL_MASK.HOLY,
                perPoint = 1
            }
        }
    },
    { -- Searing Light
        tree = 2,
        talent = 11,
        effects = {
            {
                type = _addon.EFFECT_TYPE.MOD_EFFECT,
                affectSpell = {SMITE, HOLY_FIRE},
                perPoint = 5
            }
        }
    },
    { -- Spiritual Healing
        tree = 2,
        talent = 14,
        effects = {
            {
                type = _addon.EFFECT_TYPE.MOD_HEALING_DONE,
                perPoint = 2
            }
        }
    },

    -- Improved Shadow Word: Pain
    {
        tree = 3,
        talent = 4,
        effects = {
            {
                type = _addon.EFFECT_TYPE.MOD_DURATION,
                affectSpell = {SHADOW_WORD_PAIN},
                perPoint = 3
            }
        }
    },
    -- Shadow Focus
    {
        tree = 3,
        talent = 5,
        effects = {
            {
                type = _addon.EFFECT_TYPE.MOD_HIT_SPELL,
                affectSchool = _addon.SCHOOL_MASK.SHADOW,
                perPoint = 2
            }
        }
    },
    -- Darkness
    {
        tree = 3,
        talent = 15,
        effects = {
            {
                type = _addon.EFFECT_TYPE.MOD_DMG_DONE,
                affectSchool = _addon.SCHOOL_MASK.SHADOW,
                perPoint = 2
            }
        }
    },
};

-- Shadowform
_addon.buffData[15473] = {
    effect = _addon.EFFECT_TYPE.MOD_DMG_DONE,
    affectSchool = _addon.SCHOOL_MASK.SHADOW,
    value = 15,
}

-- Inner Focus
_addon.buffData[14751] = {
    effect = _addon.EFFECT_TYPE.MOD_CRIT,
    affectSchool = _addon.SCHOOL_MASK.ALL,
    value = 25
}