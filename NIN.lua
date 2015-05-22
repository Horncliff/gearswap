-------------------------------------------------------------------------------------------------------------------
-- Initialization function that defines sets and variables to be used.
-------------------------------------------------------------------------------------------------------------------
-- gs c toggle hastemode -- Toggles whether or not you're getting Haste II
function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')
    include('organizer-lib')
end


-- Setup vars that are user-independent.
function job_setup()
    state.Buff.Migawari = buffactive.migawari or false
    state.Buff.Sange = buffactive.sange or false
    state.Buff.Innin = buffactive.innin or false
    
    include('Mote-TreasureHunter')
    state.TreasureMode:set('Tag')

    state.HasteMode = M{['description']='Haste Mode', 'Normal', 'Hi' }
    state.Runes = M{['description']='Runes', "Ignis", "Gelus", "Flabra", "Tellus", "Sulpor", "Unda", "Lux", "Tenebrae"}
    state.UseRune = M(false, 'Use Rune')

    run_sj = player.sub_job == 'RUN' or false

    select_ammo()
    LugraWSList = S{'Blade: Shun', 'Blade: Ku', 'Blade: Jin'}
    state.CapacityMode = M(false, 'Capacity Point Mantle')
    gear.RegularAmmo = 'Happo Shuriken'
    gear.SangeAmmo = 'Hachiya Shuriken'
    
    wsList = S{'Blade: Hi'}

    --determine_haste_group()
    update_combat_form()
    
    state.warned = M(false)
    options.ammo_warning_limit = 25
    -- For th_action_check():
    -- JA IDs for actions that always have TH: Provoke, Animated Flourish
    info.default_ja_ids = S{35, 204}
    -- Unblinkable JA IDs for actions that always have TH: Quick/Box/Stutter Step, Desperate/Violent Flourish
    info.default_u_ja_ids = S{201, 202, 203, 205, 207}

end


-- Setup vars that are user-dependent.  Can override this function in a sidecar file.
function user_setup()
    -- Options: Override default values
    state.OffenseMode:options('Normal', 'Low', 'Mid', 'Acc')
    state.HybridMode:options('Normal', 'PDT')
    state.RangedMode:options('Normal', 'Acc')
    state.WeaponskillMode:options('Normal', 'Low', 'Mid', 'Acc')
    state.PhysicalDefenseMode:options('PDT')
    state.MagicalDefenseMode:options('MDT')

    select_default_macro_book()

    send_command('bind ^= gs c cycle treasuremode')
    send_command('bind ^[ input /lockstyle on')
    send_command('bind ![ input /lockstyle off')
    send_command('bind != gs c toggle CapacityMode')
    send_command('bind @f9 gs c cycle HasteMode')
    send_command('bind @[ gs c cycle Runes')
    send_command('bind ^] gs c toggle UseRune')
    
    -- auto ws
    --windower.register_event('tp change', autoHi)
    --windower.register_event('tp change', function(new, old)
    --    if player.tp >= 1000 then
    --        --
    --    end
    --end)

    state.time = M(false)
    windower.raw_register_event('time change', time_change)
end


function file_unload()
    send_command('unbind ^[')
    send_command('unbind ![')
    send_command('unbind ^=')
    send_command('unbind !=')
    send_command('unbind @f9')
    send_command('unbind @[')
end


-- Define sets and vars used by this job file.
-- visualized at http://www.ffxiah.com/node/194
-- Happo
-- Hachiya
-- sets.engaged[state.CombatForm][state.CombatWeapon][state.OffenseMode][state.HybridMode][classes.CustomMeleeGroups (any number)

-- Ninjutsu tips
-- To stick Slow (Hojo) lower earth resist with Raiton: Ni
-- To stick poison (Dokumori) or Attack down (Aisha) lower resist with Katon: Ni
-- To stick paralyze (Jubaku) lower resistence with Huton: Ni

function init_gear_sets()
    --------------------------------------
    -- Start defining the sets
    --------------------------------------
    TaeonHands = {}
    TaeonHands.TA = {name="Taeon Gloves", augments={'STR+9','Accuracy+17 Attack+17','"Triple Atk."+2'}}
    TaeonHands.DW = {name="Taeon Gloves", augments={'STR+3 VIT+3', 'Attack+22','"Dual Wield" +5'}}

    -- Precast sets to enhance JAs
    sets.precast.JA['Mijin Gakure'] = { legs="Mochizuki Hakama +1" }
    sets.precast.JA['Futae'] = { hands="Iga Tekko +2" }
    sets.precast.JA['Provoke'] = { 
        ear1="Friomisi Earring",
        ear2="Trux Earring", 
        body="Emet Harness +1",
        feet="Mochizuki Kyahan +1"
    }
    sets.precast.JA.Sange = { ammo=gear.SangeAmmo, body="Mochizuki Chainmail +1" }
    
    sets.reive = {neck="Ygnas's Resolve +1"}
    -- Waltz set (chr and vit)
    sets.precast.Waltz = {
        head="Uk'uxkaj Cap",
        body="Dread Jupon",
        hands="Umuthi Gloves",
        waist="Chaac Belt",
        legs="Nahtirah Trousers",
        feet="Mochizuki Kyahan +1"
    }
    -- Don't need any special gear for Healing Waltz.
    sets.precast.Waltz['Healing Waltz'] = {}
    
    sets.TreasureHunter = { waist="Chaac Belt" }
    sets.CapacityMantle = { back="Mecistopins Mantle" }
    sets.WSDayBonus     = { head="Gavialis Helm" }
    sets.WSBack         = { back="Trepidity Mantle" }
    sets.BrutalLugra    = { ear1="Brutal Earring", ear2="Lugra Earring +1" }
    sets.BrutalTrux     = { ear1="Brutal Earring", ear2="Trux Earring" }
    sets.BrutalMoon     = { ear1="Brutal Earring", ear2="Moonshade Earring" }
    sets.Rajas          = { ring1="Rajas Ring" }

    sets.RegularAmmo    = { ammo=gear.RegularAmmo }
    sets.SangeAmmo      = { ammo=gear.SangeAmmo }
    
    sets.NightAccAmmo   = { ammo="Ginsen" }
    sets.DayAccAmmo     = { ammo="Tengu-no-Hane" }

    -- Set for acc on steps, since Yonin drops acc a fair bit
    sets.precast.Step = {
        head="Gavialis Helm",
        body="Hattori Ningi +1",
        neck="Defiant Collar",
        ear1="Zennaroi Earring",
        hands="Sasuke Tekko +1",
        back="Yokaze Mantle",
        ring1="Mars's Ring",
        waist="Olseni Belt",
        legs="Taeon Tights",
        feet="Mochizuki Kyahan +1"
    }
    -- Ranged
    sets.precast.RA = {
        head="Uk'uxkaj Cap",
        hands="Buremte Gloves",
        legs="Nahtirah Trousers",
        feet="Wurrukatte Boots"
    }
    sets.midcast.RA = {
        head="Taeon Chapeau",
        neck="Iqabi Necklace",
        body="Mochizuki Chainmail +1",
        hands="Hachiya Tekko +1",
        --ring1="Longshot Ring",
        ring2="Hajduk Ring",
        back="Yokaze Mantle",
        --waist="Hurling Belt",
        legs="Hachiya Hakama +1",
        feet="Taeon Boots"
    }
    sets.midcast.RA.Acc = set_combine(sets.midcast.RA, {
        body="Mekosuchinae Harness"
    })
    sets.midcast.RA.TH = set_combine(sets.midcast.RA, set.TreasureHunter)
    
    -- Fast cast sets for spells
    sets.precast.FC = {
        head="Ejekamal Mask",
        ammo="Impatiens",
        ear1="Loquacious Earring",
        ring1="Prolix Ring",
        hands="Buremte Gloves",
        body="Dread Jupon",
        legs="Quiahuiz Trousers",
        feet="Mochizuki Kyahan +1" -- special enhancement for casting ninjutsu III
    }
    sets.precast.FC.Utsusemi = set_combine(sets.precast.FC, { neck="Magoraga Beads", body="Mochizuki Chainmail +1" })
    
    -- Midcast Sets
    sets.midcast.FastRecast = {
        ammo="Impatiens",
        head="Uk'uxkaj Cap",
        body="Dread Jupon",
        ear1="Loquacious Earring",
        ring1="Prolix Ring",
        feet="Mochizuki Kyahan +1"
    }
      
    -- skill ++ 
    sets.midcast.Ninjutsu = {
        head="Hachiya Hatsuburi +1",
        ear1="Lifestorm Earring",
        ear2="Psystorm Earring",
        neck="Stoicheion Medal",
        --neck="Ardor Pendant +1",
        body="Mekosuchinae Harness",
        hands=TaeonHands.TA,
        ring1="Sangoma Ring",
        ring2="Perception Ring",
        back="Yokaze Mantle",
        feet="Mochizuki Kyahan +1"
    }
    -- any ninjutsu cast on self
    sets.midcast.SelfNinjutsu = sets.midcast.Ninjutsu
    sets.midcast.Utsusemi = set_combine(sets.midcast.Ninjutsu, {feet="Iga Kyahan +2"})
    sets.midcast.Migawari = set_combine(sets.midcast.Ninjutsu, {body="Hattori Ningi +1"})

    -- Nuking Ninjutsu (skill & magic attack)
    sets.midcast.ElementalNinjutsu = {
        head="Mochizuki Hatsuburi +1",
        ear1="Friomisi Earring",
        ear2="Crematio Earring",
        neck="Stoicheion Medal",
        body="Mekosuchinae Harness",
        hands=TaeonHands.TA,
        back="Aput Mantle",
        ring1="Shiva Ring",
        ring2="Acumen Ring",
        waist="Caudata Belt",
        legs="Shneddick Tights +1",
        feet="Hachiya Kyahan +1"
    }

    -- Effusions
    sets.precast.Effusion = {}
    sets.precast.Effusion.Lunge = sets.midcast.ElementalNinjutsu
    sets.precast.Effusion.Swipe = sets.midcast.ElementalNinjutsu
    
    sets.idle = {
        ammo=gear.RegularAmmo,
        head="Ptica Headgear",
        neck="Twilight Torque",
        ear1="Zennaroi Earring",
        ear2="Trux Earring",
        body="Emet Harness +1",
        hands="Otronif Gloves +1",
        ring1="Karieyh Ring",
        ring2="Dark Ring",
    	back="Engulfer Cape +1",
        waist="Flume Belt",
        legs="Otronif Brais +1",
        feet="Danzo Sune-ate"
     }

    sets.idle.Regen = set_combine(sets.idle, {
        head="Ocelomeh Headpiece +1",
        body="Kheper Jacket",
        ring2="Paguroidea Ring"
    })
    
    sets.idle.Town = set_combine(sets.idle, {
        head="Ptica Headgear",
        neck="Defiant Collar",
        ear1="Lugra Earring +1",
        ring1="Karieyh Ring",
        hands="Sasuke Tekko +1",
        ring2="Ifrit Ring +1",
        body="Mes'yohi Haubergeon",
        legs="Hachiya Hakama +1",
        back="Yokaze Mantle",
        waist="Windbuffet Belt +1"
    })
    --sets.idle.Town.Adoulin = set_combine(sets.idle.Town, {
    --    body="Councilor's Garb"
    --})
    
    sets.idle.Weak = sets.idle

    -- Defense sets
    sets.defense.PDT = {
        head="Otronif Mask +1",
        neck="Twilight Torque",
        body="Emet Harness +1",
        hands="Otronif Gloves +1",
        ring1="Patricius Ring",
        ring2="Dark Ring",
        back="Repulse Mantle",
        waist="Flume Belt",
        legs="Otronif Brais +1",
        feet="Otronif Boots +1"
    }
    
    sets.defense.MDT = set_combine(sets.defense.PDT, {
        head="Ptica Headgear",
        neck="Twilight Torque",
        hands="Otronif Gloves +1",
        back="Engulfer Cape +1",
        feet="Otronif Boots +1"
    })
    
    sets.DayMovement = {feet="Danzo sune-ate"}
    sets.NightMovement = {feet="Hachiya Kyahan +1"}

    -- Normal melee group without buffs
    sets.engaged = {
        main="Kannagi",
        sub="Achiuchikapu",
        ammo=gear.RegularAmmo,
        head="Ptica Headgear",
        neck="Asperity Necklace",
        ear1="Brutal Earring",
        ear2="Suppanomimi",
        body="Mochizuki Chainmail +1",
        hands=TaeonHands.DW,
        ring1="Oneiros Ring",
        ring2="Epona's Ring",
        back="Bleating Mantle",
        waist="Patentia Sash",
        legs="Mochizuki Hakama +1",
        feet="Taeon Boots"
    }
    -- assumptions made about target, Rancor no longer "OK" 
    sets.engaged.Low = set_combine(sets.engaged, {
        neck="Defiant Collar",
        ear1="Trux Earring",
        back="Bleating Mantle"
    })

    sets.engaged.Mid = set_combine(sets.engaged.Low, {
        ear1="Dudgeon Earring",
        ear2="Heartseeker Earring",
        ring1="Rajas Ring",
        back="Yokaze Mantle"
    })

    sets.engaged.Acc = set_combine(sets.engaged.Mid, {
        hands=TaeonHands.TA,
        ring2="Mars's Ring",
        waist="Olseni Belt",
    })
    
    sets.engaged.Innin = set_combine(sets.engaged, {
        head="Hattori Zukin +1",
        body="Hachiya Chainmail +1",
        ear1="Dudgeon Earring",
        ear2="Heartseeker Earring",
        waist="Windbuffet Belt +1",
    })
    sets.engaged.Innin.Low = set_combine(sets.engaged.Innin, {
        back="Bleating Mantle"
    })
    sets.engaged.Innin.Mid = set_combine(sets.engaged.Innin.Low, {
        ring1="Patricius Ring",
        back="Yokaze Mantle"
    })
    sets.engaged.Innin.Acc = sets.engaged.Acc

    -- Defenseive sets
    sets.NormalPDT = {
        head="Otronif Mask +1",
        body="Emet Harness +1",
        neck="Agitator's Collar",
        hands="Otronif Gloves +1",
        ring1="Patricius Ring",
        legs="Otronif Brais +1",
        feet="Otronif Boots +1"
    }
    sets.AccPDT = {
        head="Lithelimb Cap",
        body="Emet Harness +1",
        neck="Agitator's Collar",
        hands="Umuthi Gloves",
        ring1="Patricius Ring",
        feet="Otronif Boots +1"
    }

    sets.engaged.PDT = set_combine(sets.engaged, sets.NormalPDT)
    sets.engaged.Low.PDT = set_combine(sets.engaged.Low, sets.NormalPDT)
    sets.engaged.Mid.PDT = set_combine(sets.engaged.Mid, sets.NormalPDT)
    sets.engaged.Acc.PDT = set_combine(sets.engaged.Acc, sets.AccPDT)

    sets.engaged.Innin.PDT = set_combine(sets.engaged.Innin, sets.NormalPDT, {head="Hattori Zukin +1"})
    sets.engaged.Innin.Low.PDT = set_combine(sets.engaged.Innin.Low, sets.NormalPDT, {head="Hattori Zukin +1"})
    sets.engaged.Innin.Mid.PDT = set_combine(sets.engaged.Innin.Mid, sets.NormalPDT, {head="Hattori Zukin +1"})
    sets.engaged.Innin.Acc.PDT = set_combine(sets.engaged.Innin.Acc, sets.AccPDT)

    sets.engaged.HastePDT = {
        neck="Agitator's Collar",
        hands="Otronif Gloves +1",
        body="Emet Harness +1",
        waist="Flume Belt",
        ring1="Patricius Ring",
        legs="Otronif Brais +1",
        feet="Otronif Boots +1"
    }

    -- Delay Cap from spell + songs alone
    sets.engaged.MaxHaste = set_combine(sets.engaged, {
        head="Taeon Chapeau",
        ear1="Brutal Earring",
        ear2="Tripudio Earring",
        neck="Asperity Necklace",
        body="Hattori Ningi +1",
        hands=TaeonHands.TA,
        ring1="Oneiros Ring",
        back="Iga Dochugappa",
        waist="Windbuffet Belt +1",
        legs="Taeon Tights",
        feet="Taeon Boots"
    })
    -- Base set for hard content
    sets.engaged.Low.MaxHaste = set_combine(sets.engaged.MaxHaste, {
        neck="Defiant Collar",
        ear1="Bladeborn Earring",
        ear2="Steelflash Earring",
        ring1="Rajas Ring",
        hands=TaeonHands.TA,
        back="Bleating Mantle",
    })
    sets.engaged.Mid.MaxHaste = set_combine(sets.engaged.Low.MaxHaste, {
        ring1="Patricius Ring",
        back="Yokaze Mantle",
    })
    sets.engaged.Acc.MaxHaste = set_combine(sets.engaged.Mid.MaxHaste, {
        head="Gavialis Helm",
        ear1="Zennaroi Earring",
        ear2="Trux Earring",
        ring2="Mars's Ring",
        waist="Olseni Belt"
    })
    -- do nothing here
    sets.engaged.Innin.MaxHaste     = sets.engaged.MaxHaste
    sets.engaged.Innin.Low.MaxHaste = sets.engaged.Low.MaxHaste
    sets.engaged.Innin.Mid.MaxHaste = sets.engaged.Mid.MaxHaste
    sets.engaged.Innin.Acc.MaxHaste = sets.engaged.Acc.MaxHaste
   
    -- Defensive sets
    sets.engaged.PDT.MaxHaste = set_combine(sets.engaged.MaxHaste, sets.NormalPDT)
    sets.engaged.Low.PDT.MaxHaste = set_combine(sets.engaged.Low.MaxHaste, sets.NormalPDT)
    sets.engaged.Mid.PDT.MaxHaste = set_combine(sets.engaged.Mid.MaxHaste, sets.NormalPDT)
    sets.engaged.Acc.PDT.MaxHaste = set_combine(sets.engaged.Acc.MaxHaste, sets.AccPDT)
    
    sets.engaged.Innin.PDT.MaxHaste = set_combine(sets.engaged.Innin.MaxHaste, sets.NormalPDT)
    sets.engaged.Innin.Low.PDT.MaxHaste = set_combine(sets.engaged.Innin.Low.MaxHaste, sets.NormalPDT)
    sets.engaged.Innin.Mid.PDT.MaxHaste = set_combine(sets.engaged.Innin.Mid.MaxHaste, sets.NormalPDT)
    sets.engaged.Innin.Acc.PDT.MaxHaste = sets.engaged.Acc.PDT.MaxHaste
    
    -- 35% Haste 
    sets.engaged.Haste_35 = set_combine(sets.engaged.MaxHaste, {
        head="Ptica Headgear",
        ear1="Brutal Earring",
        ear2="Suppanomimi",
        hands=TaeonHands.TA,
    })
    sets.engaged.Low.Haste_35 = set_combine(sets.engaged.Low.MaxHaste, {
        head="Ptica Headgear",
        neck="Defiant Collar",
        ear1="Brutal Earring",
        ear2="Suppanomimi",
    })
    sets.engaged.Mid.Haste_35 = set_combine(sets.engaged.Mid.MaxHaste, {
        head="Ptica Headgear",
        ear1="Brutal Earring",
        ear2="Suppanomimi",
    })
    sets.engaged.Acc.Haste_35 = set_combine(sets.engaged.Acc.MaxHaste, {
        head="Ptica Headgear",
        ear1="Zennaroi Earring",
        ear2="Steelflash Earring",
    })

    sets.engaged.Innin.Haste_35 = set_combine(sets.engaged.Haste_35, {
        head="Hattori Zukin +1",
    })
    sets.engaged.Innin.Low.Haste_35 = set_combine(sets.engaged.Low.Haste_35, {
        head="Hattori Zukin +1",
    })
    sets.engaged.Innin.Mid.Haste_35 = set_combine(sets.engaged.Mid.Haste_35, {
        head="Hattori Zukin +1",
    })
    sets.engaged.Innin.Acc.Haste_35 = sets.engaged.Acc.Haste_35
    
    sets.engaged.PDT.Haste_35 = set_combine(sets.engaged.Haste_35, sets.engaged.HastePDT)
    sets.engaged.Low.PDT.Haste_35 = set_combine(sets.engaged.Low.Haste_35, sets.engaged.HastePDT)
    sets.engaged.Mid.PDT.Haste_35 = set_combine(sets.engaged.Mid.Haste_35, sets.engaged.HastePDT)
    sets.engaged.Acc.PDT.Haste_35 = set_combine(sets.engaged.Acc.Haste_35, sets.engaged.AccPDT)
    
    sets.engaged.Innin.PDT.Haste_35 = set_combine(sets.engaged.Innin.Haste_35, sets.engaged.HastePDT)
    sets.engaged.Innin.Low.PDT.Haste_35 = set_combine(sets.engaged.Innin.Low.Haste_35, sets.engaged.HastePDT)
    sets.engaged.Innin.Mid.PDT.Haste_35 = set_combine(sets.engaged.Innin.Mid.Haste_35, sets.engaged.HastePDT)
    sets.engaged.Innin.Acc.PDT.Haste_35 = sets.engaged.Acc.PDT.Haste_35
    
    -- 30% Haste
    sets.engaged.Haste_30 = set_combine(sets.engaged.Haste_35, {
        head="Ptica Headgear",
        neck="Asperity Necklace",
        ear1="Brutal Earring",
        ear2="Suppanomimi",
        body="Mochizuki Chainmail +1",
        hands=TaeonHands.TA,
        ring1="Oneiros Ring",
        ring2="Epona's Ring",
        back="Iga Dochugappa",
        waist="Windbuffet Belt +1",
        legs="Taeon Tights",
        feet="Taeon Boots"
    })
    sets.engaged.Low.Haste_30 = set_combine(sets.engaged.Low.Haste_35, {
        ear1="Brutal Earring",
        ear2="Suppanomimi",
        neck="Defiant Collar",
        body="Mochizuki Chainmail +1",
        hands=TaeonHands.TA,
        back="Bleating Mantle"
    })
    sets.engaged.Mid.Haste_30 = set_combine(sets.engaged.Mid.Haste_35, {
        ear1="Trux Earring",
        body="Mochizuki Chainmail +1",
        back="Yokaze Mantle"
    })
    sets.engaged.Acc.Haste_30 = set_combine(sets.engaged.Acc.Haste_35, {
        ear2="Suppanomimi",
        ear1="Zennaroi Earring",
        body="Mochizuki Chainmail +1",
        ring1="Patricius Ring",
        legs="Hachiya Hakama +1"
    })

    sets.engaged.Innin.Haste_30 = set_combine(sets.engaged.Haste_30, {
        head="Hattori Zukin +1",
        body="Hattori Ningi +1",
        hands=TaeonHands.TA,
    })
    sets.engaged.Innin.Low.Haste_30 = set_combine(sets.engaged.Low.Haste_30, {
        head="Hattori Zukin +1",
        body="Hattori Ningi +1",
        hands=TaeonHands.DW,
    })
    sets.engaged.Innin.Mid.Haste_30 = set_combine(sets.engaged.Mid.Haste_30, {
        head="Hattori Zukin +1",
        body="Hattori Ningi +1",
        waist="Patentia Sash"
    })
    sets.engaged.Innin.Acc.Haste_30 = sets.engaged.Acc.Haste_30
    
    sets.engaged.PDT.Haste_30 = set_combine(sets.engaged.Haste_30, sets.engaged.HastePDT)
    sets.engaged.Low.PDT.Haste_30 = set_combine(sets.engaged.Low.Haste_30, sets.engaged.HastePDT)
    sets.engaged.Mid.PDT.Haste_30 = set_combine(sets.engaged.Mid.Haste_30, sets.engaged.HastePDT)
    sets.engaged.Acc.PDT.Haste_30 = set_combine(sets.engaged.Acc.Haste_30, sets.engaged.AccPDT)
    
    sets.engaged.Innin.PDT.Haste_30 = set_combine(sets.engaged.Innin.Haste_30, sets.engaged.HastePDT)
    sets.engaged.Innin.Low.PDT.Haste_30 = set_combine(sets.engaged.Innin.Low.Haste_30, sets.engaged.HastePDT)
    sets.engaged.Innin.Mid.PDT.Haste_30 = set_combine(sets.engaged.Innin.Mid.Haste_30, sets.engaged.HastePDT)
    sets.engaged.Innin.Acc.PDT.Haste_30 = sets.engaged.Acc.PDT.Haste_30
    

    -- 5 - 20% Haste 
    sets.engaged.Haste_15 = set_combine(sets.engaged.Haste_30, {
        head="Ptica Headgear",
        hands=TaeonHands.DW,
        back="Bleating Mantle",
        waist="Patentia Sash",
    })
    sets.engaged.Low.Haste_15 = set_combine(sets.engaged.Low.Haste_30, {
        back="Yokaze Mantle",
        hands=TaeonHands.DW,
        waist="Patentia Sash"
    })
    sets.engaged.Mid.Haste_15 = set_combine(sets.engaged.Mid.Haste_30, {
        ear1="Dudgeon Earring",
        ear2="Heartseeker Earring",
        hands=TaeonHands.DW,
        waist="Patentia Sash"
    })
    sets.engaged.Acc.Haste_15 = set_combine(sets.engaged.Acc.Haste_30, {
        hands=TaeonHands.DW,
        legs="Taeon Tights",
        waist="Patentia Sash"
    })
    
    sets.engaged.Innin.Haste_15 = set_combine(sets.engaged.Haste_15, {
        head="Hattori Zukin +1",
    })
    sets.engaged.Innin.Low.Haste_15 = set_combine(sets.engaged.Low.Haste_15, {
        head="Hattori Zukin +1",
    })
    sets.engaged.Innin.Mid.Haste_15 = set_combine(sets.engaged.Mid.Haste_15, {
        head="Hattori Zukin +1",
    })
    sets.engaged.Innin.Acc.Haste_15 = sets.engaged.Acc.Haste_15
    
    sets.engaged.PDT.Haste_15 = set_combine(sets.engaged.Haste_15, sets.engaged.HastePDT)
    sets.engaged.Low.PDT.Haste_15 = set_combine(sets.engaged.Low.Haste_15, sets.engaged.HastePDT)
    sets.engaged.Mid.PDT.Haste_15 = set_combine(sets.engaged.Mid.Haste_15, sets.engaged.HastePDT)
    sets.engaged.Acc.PDT.Haste_15 = set_combine(sets.engaged.Acc.Haste_15, sets.engaged.AccPDT)
    
    sets.engaged.Innin.PDT.Haste_15 = set_combine(sets.engaged.Innin.Haste_15, sets.engaged.HastePDT)
    sets.engaged.Innin.Low.PDT.Haste_15 = set_combine(sets.engaged.Innin.Low.Haste_15, sets.engaged.HastePDT)
    sets.engaged.Innin.Mid.PDT.Haste_15 = set_combine(sets.engaged.Innin.Mid.Haste_15, sets.engaged.HastePDT)
    sets.engaged.Innin.Acc.PDT.Haste_15 = sets.engaged.Acc.PDT.Haste_15
    
    sets.buff.Migawari = {body="Hattori Ningi +1"}
    
    -- Weaponskills 
    sets.precast.WS = {
        head="Taeon Chapeau",
        neck="Defiant Collar",
        ear1="Brutal Earring",
        ear2="Moonshade Earring",
        body="Hattori Ningi +1",
        hands=TaeonHands.TA,
        ring1="Karieyh Ring",
        ring2="Epona's Ring",
        back="Yokaze Mantle",
        waist="Windbuffet Belt +1",
        legs="Taeon Tights",
        feet="Taeon Boots"
    }

    sets.precast.WS.Mid = set_combine(sets.precast.WS, {
        head="Gavialis Helm",
    })
    sets.precast.WS.Low = sets.precast.WS.Mid
    
    sets.precast.WS.Acc = set_combine(sets.precast.WS.Mid, {
        legs="Taeon Tights",
    })

    sets.Kamu = {
        ammo="Ginsen",
        neck="Breeze Gorget",
        body="Dread Jupon",
        ring1="Karieyh Ring",
        ring2="Ifrit Ring +1",
        back="Yokaze Mantle",
        waist="Windbuffet Belt +1",
    }
    sets.precast.WS['Blade: Kamu'] = set_combine(sets.precast.WS, sets.Kamu)
    sets.precast.WS['Blade: Kamu'].Low = set_combine(sets.precast.WS.Low, sets.Kamu)
    sets.precast.WS['Blade: Kamu'].Mid = set_combine(sets.precast.WS.Mid, sets.Kamu)
    sets.precast.WS['Blade: Kamu'].Acc = set_combine(sets.precast.WS.Acc, sets.Kamu, {waist="Caudata Belt"})
    
    -- BLADE: JIN
    sets.Jin = {
        head="Taeon Chapeau",
        ammo="Yetshila",
        neck="Rancor Collar",
        body="Dread Jupon",
        ring1="Ifrit Ring +1",
        waist="Windbuffet Belt +1",
        back="Yokaze Mantle",
    }
    sets.precast.WS['Blade: Jin'] = set_combine(sets.precast.WS, sets.Jin)
    sets.precast.WS['Blade: Jin'].Low = set_combine(sets.precast.WS['Blade: Jin'], {
        neck="Breeze Gorget",
        waist="Thunder Belt",
    })
    sets.precast.WS['Blade: Jin'].Mid = set_combine(sets.precast.WS['Blade: Jin'].Low, {
        head="Gavialis Helm",
        body="Mes'yohi Haubergeon"
    })
    sets.precast.WS['Blade: Jin'].Acc = set_combine(sets.precast.WS['Blade: Jin'].Mid, {
        ring1="Karieyh Ring",
        legs="Taeon Tights",
    })
    
    -- BLADE: HI
    sets.precast.WS['Blade: Hi'] = set_combine(sets.precast.WS, {
        ammo="Yetshila",
        head="Uk'uxkaj Cap",
        neck="Hope Torque",
        body="Hattori Ningi +1",
        hands="Sasuke Tekko +1",
        ring1="Karieyh Ring",
        waist="Windbuffet Belt +1",
        feet="Taeon Boots"
    })

    sets.precast.WS['Blade: Hi'].Low = set_combine(sets.precast.WS['Blade: Hi'], {
        neck="Shadow Gorget",
        back="Yokaze Mantle"
    })
    sets.precast.WS['Blade: Hi'].Mid = set_combine(sets.precast.WS['Blade: Hi'], {
        head="Ptica Headgear",
        neck="Shadow Gorget",
        waist="Caudata Belt",
        back="Yokaze Mantle",
    })

    sets.precast.WS['Blade: Hi'].Acc = set_combine(sets.precast.WS['Blade: Hi'].Mid, {
        ear1="Trux Earring",
        legs="Taeon Tights",
    })
    
    -- BLADE: SHUN
    sets.Shun = {
        head="Gavialis Helm",
        neck="Flame Gorget",
        ear2="Trux Earring",
        hands="Mochizuki Tekko +1",
        ring1="Ramuh Ring",
        back="Yokaze Mantle",
        waist="Light Belt",
        legs="Taeon Tights",
        feet="Taeon Boots"
    }

    sets.precast.WS['Blade: Shun'] = set_combine(sets.precast.WS, sets.Shun)
    sets.precast.WS['Blade: Shun'].Low = set_combine(sets.precast.WS.Low, sets.Shun)
    sets.precast.WS['Blade: Shun'].Mid = set_combine(sets.precast.WS.Mid, sets.Shun)
    sets.precast.WS['Blade: Shun'].Acc = set_combine(sets.precast.WS.Acc, sets.Shun)
    
    -- BLADE: Rin
    sets.Rin = {
        neck="Rancor Collar",
        ring1="Rajas Ring",
        waist="Windbuffet Belt +1",
        back="Yokaze Mantle",
    }
    sets.precast.WS['Blade: Rin'] = set_combine(sets.precast.WS, sets.Rin)
    sets.precast.WS['Blade: Rin'].Low = set_combine(sets.precast.WS.Low, sets.Rin)
    sets.precast.WS['Blade: Rin'].Mid = set_combine(sets.precast.WS.Mid, sets.Rin)
    sets.precast.WS['Blade: Rin'].Acc = set_combine(sets.precast.WS.Acc, sets.Rin, {waist="Light Belt"})
    
    -- BLADE: KU 
    sets.Ku = {
        head="Felistris Mask",
        ear2="Trux Earring",
        body="Dread Jupon",
        neck="Shadow Gorget",
        waist="Metalsinger Belt",
    }
    sets.precast.WS['Blade: Ku'] = set_combine(sets.precast.WS, sets.Ku)
    sets.precast.WS['Blade: Ku'].Low = set_combine(sets.precast.WS['Blade: Ku'], {
        head="Gavialis Helm",
        body="Hattori Ningi +1",
        waist="Soil Belt"
    })
    sets.precast.WS['Blade: Ku'].Mid = sets.precast.WS['Blade: Ku'].Low
    sets.precast.WS['Blade: Ku'].Acc = set_combine(sets.precast.WS['Blade: Ku'].Mid, {
        legs="Taeon Tights",
        feet="Mochizuki Kyahan +1"
    })
    
    sets.Ten = {
        head="Felistris Mask",
        neck="Shadow Gorget",
        body="Dread Jupon",
        waist="Metalsinger Belt",
    }

    sets.precast.WS['Blade: Ten'] = set_combine(sets.precast.WS, sets.Ten)
    sets.precast.WS['Blade: Ten'].Low = set_combine(sets.precast.WS['Blade: Ten'], {
        head="Gavialis Helm",
        body="Mes'yohi Haubergeon",
    })
    sets.precast.WS['Blade: Ten'].Mid = set_combine(sets.precast.WS['Blade: Ten'].Low, {
        waist="Caudata Belt"
    })
    sets.precast.WS['Blade: Ten'].Acc = set_combine(sets.precast.WS['Blade: Ten'].Mid, {
        legs="Taeon Tights",
        feet="Mochizuki Kyahan +1"
    })
    
    sets.precast.WS['Aeolian Edge'] = set_combine(sets.precast.WS, {
        head="Mochizuki Hatsuburi +1",
        ear1="Friomisi Earring",
        neck="Stoicheion Medal",
        body="Mekosuchinae Harness",
        ring1="Garuda Ring",
        ring2="Acumen Ring",
        legs="Shneddick Tights +1",
        waist="Thunder Belt",
        feet="Hachiya Kyahan +1"
     })
    sets.precast.WS['Blade: Chi'] = set_combine(sets.precast.WS['Aeolian Edge'], {
        ring1="Shiva Ring",
        ring2="Acumen Ring",
        waist="Caudata Belt",
        legs="Shneddick Tights +1",
        feet="Hachiya Kyahan +1"
    })
    sets.precast.WS['Blade: To'] = sets.precast.WS['Blade: Chi']

end



-------------------------------------------------------------------------------------------------------------------
-- Job-specific hooks that are called to process player actions at specific points in time.
-------------------------------------------------------------------------------------------------------------------
function job_pretarget(spell, action, spellMap, eventArgs)
    if state.Buff[spell.english] ~= nil then
        state.Buff[spell.english] = true
    end
    if (spell.type:endswith('Magic') or spell.type == "Ninjutsu") and buffactive.silence then
        cancel_spell()
        send_command('input /item "Echo Drops" <me>')
    end
end
-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
-- Set eventArgs.useMidcastGear to true if we want midcast gear equipped on precast.
function job_precast(spell, action, spellMap, eventArgs)
    --Aftermath for Kannagi
    aw_custom_aftermath_timers_precast(spell)
    
    if spell.skill == "Ninjutsu" and spell.target.type:lower() == 'self' and spellMap ~= "Utsusemi" then
        if spell.english == "Migawari" then
            classes.CustomClass = "Migawari"
        else
            classes.CustomClass = "SelfNinjutsu"
        end
    end
    if spell.name == 'Spectral Jig' and buffactive.sneak then
        -- If sneak is active when using, cancel before completion
        send_command('cancel 71')
    end
    if string.find(spell.english, 'Utsusemi') then
        if buffactive['Copy Image (3)'] or buffactive['Copy Image (4)'] then
            cancel_spell()
            eventArgs.cancel = true
            return
        end
    end

end

function job_post_precast(spell, action, spellMap, eventArgs)
    -- Ranged Attacks 
    if spell.action_type == 'Ranged Attack' then
        equip( sets.SangeAmmo )
    end
    -- protection for lag
    if spell.name == 'Sange' and player.equipment.ammo == gear.RegularAmmo then
        state.Buff.Sange = false
        eventArgs.cancel = true
    end
    if spell.type == 'WeaponSkill' then
        if spell.english == 'Aeolian Edge' and state.TreasureMode.value ~= 'None' then
            equip(sets.TreasureHunter)
        end
        -- Mecistopins Mantle rule
        if state.CapacityMode.value then
            equip(sets.CapacityMantle)
        end
        -- Gavialis Helm rule
        if is_sc_element_today(spell) then
            if state.OffenseMode.current == 'Normal' and wsList:contains(spell.english) then
                -- do nothing
            else
              equip(sets.WSDayBonus)
            end
        end
        -- Swap in special ammo for WS in high Acc mode
        if state.OffenseMode.value == 'Acc' then
            equip(select_ws_ammo())
        end
        -- Use Trepidity mantle on Darksday
        if world.day_element == 'Dark' then
            equip(sets.WSBack)
        end
        -- reive mark
        if buffactive['Reive Mark'] then
            equip(sets.reive)
        end
        -- Lugra Earring for some WS
        if LugraWSList:contains(spell.english) then
            if world.time >= (17*60) or world.time <= (7*60) then
                equip(sets.BrutalLugra)
            else
                equip(sets.BrutalTrux)
            end
        elseif spell.english == 'Blade: Hi' or spell.english == 'Blade: Ten' then
            if world.time >= (17*60) or world.time <= (7*60) then
                equip(sets.BrutalLugra)
            else
                equip(sets.BrutalMoon)
            end
        end

    end
end

-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_midcast(spell, action, spellMap, eventArgs)
    if spell.action_type == 'Magic' then
        equip(sets.midcast.FastRecast)
    end
    if spell.english == "Monomi: Ichi" then
        if buffactive['Sneak'] then
            send_command('@wait 1.7;cancel sneak')
        end
    end
end

-- Run after the general midcast() is done.
-- eventArgs is the same one used in job_midcast, in case information needs to be persisted.
function job_post_midcast(spell, action, spellMap, eventArgs)
    --if state.TreasureMode.value ~= 'None' and spell.action_type == 'Ranged Attack' then
    --    equip(sets.TreasureHunter)
    --end
end


-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_aftercast(spell, action, spellMap, eventArgs)
    -- Aftermath timer creation
    aw_custom_aftermath_timers_aftercast(spell)
    --if spell.type == 'WeaponSkill' then
end

-------------------------------------------------------------------------------------------------------------------
-- Customization hooks for idle and melee sets, after they've been automatically constructed.
-------------------------------------------------------------------------------------------------------------------

-- Called before the Include starts constructing melee/idle/resting sets.
-- Can customize state or custom melee class values at this point.
-- Set eventArgs.handled to true if we don't want any automatic gear equipping to be done.
function job_handle_equipping_gear(status, eventArgs)
end

-- Modify the default idle set after it was constructed.
function customize_idle_set(idleSet)
    if player.hpp < 80 then
        idleSet = set_combine(idleSet, sets.idle.Regen)
    end
    if state.HybridMode.value == 'PDT' then
        if state.Buff.Migawari then
            idleSet = set_combine(idleSet, sets.buff.Migawari)
        else 
            idleSet = set_combine(idleSet, sets.defense.PDT)
        end
    else
        idleSet = set_combine(idleSet, select_movement())
    end
    return idleSet
end

-- Modify the default melee set after it was constructed.
function customize_melee_set(meleeSet)
    if state.TreasureMode.value == 'Fulltime' then
        meleeSet = set_combine(meleeSet, sets.TreasureHunter)
    end
    if state.CapacityMode.value then
        meleeSet = set_combine(meleeSet, sets.CapacityMantle)
    end
    if state.Buff.Migawari and state.HybridMode.value == 'PDT' then
        meleeSet = set_combine(meleeSet, sets.buff.Migawari)
    end
    if player.mp < 100 and state.OffenseMode.value ~= 'Acc' then
        -- use Rajas instead of Oneiros for normal + mid
        meleeSet = set_combine(meleeSet, sets.Rajas)
    end
    meleeSet = set_combine(meleeSet, select_ammo())
    return meleeSet
end

-------------------------------------------------------------------------------------------------------------------
-- General hooks for other events.
-------------------------------------------------------------------------------------------------------------------

-- Called when a player gains or loses a buff.
-- buff == buff gained or lost
-- gain == true if the buff was gained, false if it was lost.
function job_buff_change(buff, gain)
    if state.Buff[buff] ~= nil then
        if not midaction() then
            handle_equipping_gear(player.status)
        end
    end
    
    if buff == 'Innin' and gain  or buffactive['Innin'] then
        state.CombatForm:set('Innin')
        if not midaction() then
            handle_equipping_gear(player.status)
        end
    else
        state.CombatForm:reset()
        if not midaction() then
            handle_equipping_gear(player.status)
        end
    end

    -- If we gain or lose any haste buffs, adjust which gear set we target.
    if S{'haste', 'march', 'embrava', 'haste samba', 'geo-haste', 'indi-haste'}:contains(buff:lower()) then
        determine_haste_group()
        if not midaction() then
            handle_equipping_gear(player.status)
        end
    end
    
end

function job_status_change(newStatus, oldStatus, eventArgs)
    if newStatus == 'Engaged' then
        if buffactive['Innin'] then
            state.CombatForm:set('Innin')
        else
            state.CombatForm:reset()
        end
    end
end

-------------------------------------------------------------------------------------------------------------------
-- User code that supplements self-commands.
-------------------------------------------------------------------------------------------------------------------

-- Called by the default 'update' self-command.
function job_update(cmdParams, eventArgs)
    select_ammo()
    determine_haste_group()
    update_combat_form()
    run_sj = player.sub_job == 'RUN' or false
    --select_movement()
    th_update(cmdParams, eventArgs)
end

-------------------------------------------------------------------------------------------------------------------
-- Utility functions specific to this job.
-------------------------------------------------------------------------------------------------------------------

-- State buff checks that will equip buff gear and mark the event as handled.
-- State buff checks that will equip buff gear and mark the event as handled.
function check_buff(buff_name, eventArgs)
    if state.Buff[buff_name] then
            equip(sets.buff[buff_name] or {})
        if state.TreasureMode.value == 'SATA' or state.TreasureMode.value == 'Fulltime' then
            equip(sets.TreasureHunter)
        end
        eventArgs.handled = true
    end
end
-- Check for various actions that we've specified in user code as being used with TH gear.
-- This will only ever be called if TreasureMode is not 'None'.
-- Category and Param are as specified in the action event packet.
function th_action_check(category, param)
    if category == 2 or -- any ranged attack
        --category == 4 or -- any magic action
        (category == 3 and param == 30) or -- Aeolian Edge
        (category == 6 and info.default_ja_ids:contains(param)) or -- Provoke, Animated Flourish
        (category == 14 and info.default_u_ja_ids:contains(param)) -- Quick/Box/Stutter Step, Desperate/Violent Flourish
        then return true
    end
end

function select_movement()
    -- world.time is given in minutes into each day
    -- 7:00 AM would be 420 minutes
    -- 17:00 PM would be 1020 minutes
    if world.time >= (17*60) or world.time <= (7*60) then
        return sets.NightMovement
    else
        return sets.DayMovement
    end
end

function determine_haste_group()
    
    classes.CustomMeleeGroups:clear()
    -- assuming +4 for marches (ghorn has +5)
    -- Haste (white magic) 15%
    -- Haste Samba (Sub) 5%
    -- Haste (Merited DNC) 10% (never account for this)
    -- Victory March +0/+3/+4/+5    9.4/14%/15.6%/17.1% +0
    -- Advancing March +0/+3/+4/+5  6.3/10.9%/12.5%/14%  +0
    -- Embrava 25%
    -- buffactive[580] = geo haste
    -- buffactive[33] = regular haste
    -- state.HasteMode = toggle for when you know Haste II is being cast on you
    -- Hi = Haste II is being cast. This is clunky to use when both haste II and haste I are being cast
    -- but wtf can  you do..   I macro it, and use it often. 
    if state.HasteMode.value == 'Hi' then
        if ( ((buffactive[33] or buffactive[580]) and buffactive.march) or (buffactive.embrava and buffactive[33]) or (buffactive.embrava and buffactive.march == 1) ) then
            add_to_chat(8, '-------------Max-Haste Mode Enabled--------------')
            classes.CustomMeleeGroups:append('MaxHaste')
        elseif ( (buffactive[33] or buffactive.march == 2) and buffactive['haste samba'] ) or buffactive.embrava then
            add_to_chat(8, '-------------Haste 35%-------------')
            classes.CustomMeleeGroups:append('Haste_35')
        elseif buffactive[580] or buffactive[33] or buffactive.march == 2 then
            add_to_chat(8, '-------------Haste 30%-------------')
            classes.CustomMeleeGroups:append('Haste_30')
        elseif buffactive.march == 1 then
            add_to_chat(8, '-------------Haste 15%-------------')
            classes.CustomMeleeGroups:append('Haste_15')
        end
    else
        if ( buffactive[580] and ( buffactive.march or buffactive[33] or buffactive.embrava) ) or 
           ( buffactive.embrava and buffactive.march == 2 ) or (buffactive[33] and buffactive.march == 2) or 
           ( buffactive.embrava and ( buffactive.march == 1 or buffactive[33] ) ) then
            add_to_chat(8, '-------------Max Haste Mode Enabled--------------')
            classes.CustomMeleeGroups:append('MaxHaste')
        elseif (buffactive[33] and buffactive['haste samba'] and buffactive.march == 1) or buffactive.embrava or (buffactive.march == 2 and buffactive['haste samba']) then
            add_to_chat(8, '-------------Haste 35%-------------')
            classes.CustomMeleeGroups:append('Haste_35')
        elseif buffactive.march == 2 or (buffactive[33] and buffactive.march == 1) or buffactive[580] then
            add_to_chat(8, '-------------Haste 30%-------------')
            classes.CustomMeleeGroups:append('Haste_30')
        elseif buffactive[33] or buffactive.march == 1 then
            add_to_chat(8, '-------------Haste 15%-------------')
            classes.CustomMeleeGroups:append('Haste_15')
        end
    end

end

-- Handle notifications of general user state change.
function job_state_change(stateField, newValue, oldValue)
    if stateField == 'Capacity Point Mantle' then
        gear.Back = newValue
    elseif stateField == 'Runes' then
        local msg = ''
        if newValue == 'Ignis' then
            msg = msg .. 'Increasing resistence against ICE and deals FIRE damage.'
        elseif newValue == 'Gelus' then
            msg = msg .. 'Increasing resistence against WIND and deals ICE damage.'
        elseif newValue == 'Flabra' then
            msg = msg .. 'Increasing resistence against EARTH and deals WIND damage.'
        elseif newValue == 'Tellus' then
            msg = msg .. 'Increasing resistence against LIGHTNING and deals EARTH damage.'
        elseif newValue == 'Sulpor' then
            msg = msg .. 'Increasing resistence against WATER and deals LIGHTNING damage.'
        elseif newValue == 'Unda' then
            msg = msg .. 'Increasing resistence against FIRE and deals WATER damage.'
        elseif newValue == 'Lux' then
            msg = msg .. 'Increasing resistence against DARK and deals LIGHT damage.'
        elseif newValue == 'Tenebrae' then
            msg = msg .. 'Increasing resistence against LIGHT and deals DARK damage.'
        end
        add_to_chat(123, msg)
    elseif stateField == 'Use Rune' then
        send_command('@input /ja '..state.Runes.value..' <me>')
    end
end

--- Custom spell mapping.
--function job_get_spell_map(spell, default_spell_map)
--    if spell.skill == 'Elemental Magic' and default_spell_map ~= 'ElementalEnfeeble' then
--        return 'HighTierNuke'
--    end
--end

-- Set eventArgs.handled to true if we don't want the automatic display to be run.
function display_current_job_state(eventArgs)
    local msg = ''
    msg = msg .. 'Offense: '..state.OffenseMode.current
    msg = msg .. ', Hybrid: '..state.HybridMode.current

    if state.DefenseMode.value ~= 'None' then
        local defMode = state[state.DefenseMode.value ..'DefenseMode'].current
        msg = msg .. ', Defense: '..state.DefenseMode.value..' '..defMode
    end
    if state.HasteMode.value ~= 'Normal' then
        msg = msg .. ', Haste: '..state.HasteMode.current
    end
    if state.RangedMode.value ~= 'Normal' then
        msg = msg .. ', Rng: '..state.RangedMode.current
    end
    if state.Kiting.value then
        msg = msg .. ', Kiting'
    end
    if state.PCTargetMode.value ~= 'default' then
        msg = msg .. ', Target PC: '..state.PCTargetMode.value
    end
    if state.SelectNPCTargets.value then
        msg = msg .. ', Target NPCs'
    end

    add_to_chat(123, msg)
    eventArgs.handled = true
end

-- Call from job_precast() to setup aftermath information for custom timers.
function aw_custom_aftermath_timers_precast(spell)
    if spell.type == 'WeaponSkill' then
        info.aftermath = {}
        
        local empy_ws = "Blade: Hi"
        
        info.aftermath.weaponskill = empy_ws
        info.aftermath.duration = 0
        
        info.aftermath.level = math.floor(player.tp / 1000)
        if info.aftermath.level == 0 then
            info.aftermath.level = 1
        end
        
        if spell.english == empy_ws and player.equipment.main == 'Kannagi' then
            -- nothing can overwrite lvl 3
            if buffactive['Aftermath: Lv.3'] then
                return
            end
            -- only lvl 3 can overwrite lvl 2
            if info.aftermath.level ~= 3 and buffactive['Aftermath: Lv.2'] then
                return
            end
            
            -- duration is based on aftermath level
            info.aftermath.duration = 30 * info.aftermath.level
        end
    end
end

-- Call from job_aftercast() to create the custom aftermath timer.
function aw_custom_aftermath_timers_aftercast(spell)
    if not spell.interrupted and spell.type == 'WeaponSkill' and
       info.aftermath and info.aftermath.weaponskill == spell.english and info.aftermath.duration > 0 then

        local aftermath_name = 'Aftermath: Lv.'..tostring(info.aftermath.level)
        send_command('timers d "Aftermath: Lv.1"')
        send_command('timers d "Aftermath: Lv.2"')
        send_command('timers d "Aftermath: Lv.3"')
        send_command('timers c "'..aftermath_name..'" '..tostring(info.aftermath.duration)..' down abilities/aftermath'..tostring(info.aftermath.level)..'.png')

        info.aftermath = {}
    end
end

function time_change(new, old)
    if new > 17.00 or new < 7.00 then
        if state.time then
            state.time:reset()
            windower.add_to_chat(204, "******************* Dusk *******************")
            send_command('gs c update user')
        end
    else
        if state.time.value == false then
            state.time:set()
            windower.add_to_chat(204, "******************* Dawn *******************")
            send_command('gs c update user')
        end
    end
end

function select_ammo()
    if state.Buff.Sange then
        return sets.SangeAmmo
    else
        return sets.RegularAmmo
    end
end

function select_ws_ammo()
    if world.time >= (18*60) or world.time <= (6*60) then
        return sets.NightAccAmmo
    else
        return sets.DayAccAmmo
    end
end
function update_combat_form()
    if state.Buff.Innin then
        state.CombatForm:set('Innin')
    else
        state.CombatForm:reset()
    end
end

-- Select default macro book on initial load or subjob change.
function select_default_macro_book()
    -- Default macro set/book
    if player.sub_job == 'DNC' then
        set_macro_page(2, 2)
    elseif player.sub_job == 'WAR' then
        set_macro_page(2, 1)
    else
        set_macro_page(2, 2)
    end
end

