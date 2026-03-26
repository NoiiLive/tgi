-- @ScriptType: LocalScript
--[[

TOKYO GHOUL GAME PROGRESSION SYSTEM (REFINED)
Author: Design Draft
Type: Menu-Based, Turn-Based RPG (Luau Structure)

Core Loop:
- Each run = choose GHOUL or CCG
- Progress → Grow stronger → Reach peak rank → Prestige
- Prestige grants scaling advantages + rare starting variants

This is a Design Document, not a script for gameplay.
]]

---------------------------------------------------------------------
-- PRESTIGE SYSTEM
---------------------------------------------------------------------

-- Players restart progression after reaching peak rank
-- Each prestige:
--   - Grants permanent bonuses (scaling multipliers, luck, etc.)
--   - Unlocks rare starting variants at higher prestiges

-- Prestige Milestones:
--   Prestige 0+: Base gameplay
--   Prestige 5+: Chance to start as:
--      - Half-Ghoul (Ghoul path)
--      - Half-Human (CCG path)

-- Prestige Choice:
--   Player selects:
--      "GHOUL" or "CCG" at the start of each run

---------------------------------------------------------------------
-- COMBAT SYSTEM (GLOBAL)
---------------------------------------------------------------------

-- Turn-Based Combat:
--   - Speed determines turn order
--   - Actions consume resources (Hunger or HP)
--   - Menu-based inputs:
--        Attack
--        Ability
--        Item (e.g., eat flesh, use consumables)
--        Defend / Utility

---------------------------------------------------------------------
-- GHOUL PROGRESSION PATH
---------------------------------------------------------------------

-- Core Fantasy:
--   Hunt → Consume → Mutate → Evolve → Dominate

---------------------------------------------------------------------
-- GHOUL STATS
---------------------------------------------------------------------

-- RC Cells act as XP + evolution resource

local GhoulStats = {
	Health = "Max HP pool",
	Strength = "Damage output",
	Speed = "Turn order + dodge chance",
	Defence = "Damage reduction",
	Regeneration = "Healing + lifesteal scaling",
	Hunger = "Energy resource for kagune usage"
}

---------------------------------------------------------------------
-- HUNGER SYSTEM
---------------------------------------------------------------------

-- Hunger = Primary combat resource

-- Rules:
--   - Kagune attacks consume Hunger
--   - Eating restores Hunger
--   - If Hunger reaches 0:
--        - Kagune consumes HP instead
--        - Damage is increased (risk/reward mechanic)

-- Combat Utility:
--   - Players may use a turn to consume stored flesh items

---------------------------------------------------------------------
-- KAGUNE SYSTEM
---------------------------------------------------------------------

-- Each Ghoul rolls a Kagune on creation

local KaguneTypes = {
	Ukaku = {
		Bonus = "+Speed",
		Penalty = "-Hunger Efficiency"
	},
	Koukaku = {
		Bonus = "+Defence",
		Penalty = "-Speed"
	},
	Rinkaku = {
		Bonus = "+Strength +Regeneration",
		Penalty = "-Health -Defence"
	},
	Bikaku = {
		Bonus = "Balanced",
		Penalty = "None"
	}
}

-- Rare Roll:
--   Chimera Kagune (Hybrid of 2 types)

-- Rerolling:
--   Requires "Kakuhou Item"

---------------------------------------------------------------------
-- KAGUNE LEVELING & MUTATIONS
---------------------------------------------------------------------

-- Kagune Levels scale with RC Cells invested

-- On Level Up:
--   Chance to gain a Mutation

local KaguneMutations = {
	"Electric Generation (Shock DOT/Stun chance)",
	"Flame Generation (Burn DOT)",
	"Virus Generation (Poison DOT)",
	"Exploding Cells (AoE damage)",
	"Life Draining (Enhanced lifesteal)",
	"Detached Kagune (Trap/utility abilities)",
	"Adaptive Tissue (temporary stat boosts)",
	"Hardened Cells (damage resistance spikes)"
}

---------------------------------------------------------------------
-- KAKUJA SYSTEM (ENDGAME EVOLUTION)
---------------------------------------------------------------------

-- Unlock Condition:
--   High RC Count + High Kagune Level

-- Effects:
--   - Massive stat amplification
--   - Unique abilities per kagune/mutation combination
--   - Visual + gameplay transformation

---------------------------------------------------------------------
-- GHOUL RATING SYSTEM
---------------------------------------------------------------------

-- Rating increases based on:
--   - Kills (NPC + Players)
--   - Event participation
--   - Territory control
--   - Reputation gain

-- Ratings:
--   C → B → A → S → SS → SSS

-- Reaching SSS:
--   - Unlocks Prestige

---------------------------------------------------------------------
-- GHOUL FACTIONS
---------------------------------------------------------------------

local DefaultGhoulFactions = {
	"Aogiri Tree",
	"Anteiku",
	"Clowns"
}

-- Features:
--   - Players can create custom factions
--   - Shared progression + buffs
--   - Group-based combat and territory wars

---------------------------------------------------------------------
-- TOKYO WARD CONTROL SYSTEM
---------------------------------------------------------------------

-- Map divided into wards

-- Mechanics:
--   - Factions fight for control
--   - Control grants:
--        - Reputation boosts
--        - Passive buffs
--        - Resource/item generation

-- PvP Incentive:
--   - Killing player CCG members:
--        - Large RC gain
--        - Major reputation boost

---------------------------------------------------------------------
-- CCG PROGRESSION PATH
---------------------------------------------------------------------

-- Core Fantasy:
--   Hunt → Extract → Weaponize → Ascend Rank

---------------------------------------------------------------------
-- CCG STATS & TRAINING
---------------------------------------------------------------------

-- Passive Training System:
--   Only one active at a time

local CCGTraining = {
	Defence = "Damage reduction gain over time",
	Strength = "Damage gain over time",
	Speed = "Turn order + dodge gain over time"
}

-- Notes:
--   - Gains are slow and steady
--   - Minimal impact at high levels
--   - Encourages reliance on equipment

---------------------------------------------------------------------
-- QUINQUE SYSTEM (CORE POWER)
---------------------------------------------------------------------

-- Starting Weapon:
--   Basic Quinque (no abilities)

-- Progression:
--   - Killing Ghouls → chance to drop Kakuhou
--   - Kakuhou → Converted into Quinque

-- Quinque Traits:
--   - Inherit stats from Ghoul
--   - Carry mutations as abilities
--   - Fully unique weapons (procedural system)

---------------------------------------------------------------------
-- ARATA SYSTEM (KAKUJA ARMOR)
---------------------------------------------------------------------

-- Source:
--   Kakuja Ghouls drop special Kakuhou

-- Conversion:
--   → Arata Armor

-- Effects:
--   - Massive temporary buffs
--   - Continuous HP drain while active
--   - High-risk, high-reward transformation

---------------------------------------------------------------------
-- CCG RANKING SYSTEM
---------------------------------------------------------------------

-- Progression:
--   - Complete missions
--   - Hunt powerful Ghouls
--   - Gain reputation

-- Ranks:
--   Investigator → First Class → Associate Special Class → Special Class

-- Reaching Special Class:
--   - Unlocks Prestige

---------------------------------------------------------------------
-- CCG SQUAD SYSTEM
---------------------------------------------------------------------

-- Players can form squads

-- Features:
--   - Cooperative hunting
--   - Shared objectives
--   - Squad reputation system

-- Territory Control:
--   - Squads can contest wards against Ghoul factions

-- PvP Incentive:
--   - Killing player Ghouls:
--        - Higher reputation rewards
--        - Increased Kakuhou drop rates

---------------------------------------------------------------------
-- DESIGN NOTES (BALANCING & IDENTITY)
---------------------------------------------------------------------

-- GHOULS:
--   - High scaling, high risk
--   - Resource management (Hunger)
--   - Mutation-driven builds
--   - Stronger late-game potential

-- CCG:
--   - Equipment-driven power
--   - Consistent progression
--   - Team-oriented gameplay
--   - Strong early/mid-game control

-- CORE CONTRAST:
--   Ghouls = Evolution
--   CCG   = Optimization

---------------------------------------------------------------------
-- ENDGOAL LOOP
---------------------------------------------------------------------

-- GHOUL:
--   Reach SSS Rating → Prestige → Unlock stronger mutations/start

-- CCG:
--   Reach Special Class → Prestige → Unlock stronger gear/start

-- LONG-TERM:
--   - Hybrid builds via prestige perks
--   - Rare starting archetypes
--   - Increasingly faster and more powerful runs

---------------------------------------------------------------------
-- END OF DESIGN
---------------------------------------------------------------------