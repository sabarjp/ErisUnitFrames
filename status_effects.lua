status_effects = {
  is_initialized = false,

  -- this will be by target id, for now
  buffs = {},

  -- we track what zone a buff was applied in, because many buffs fall off when zoning
  current_zone = -1,

  -- lookup table for a target id and the last known zone they were in -- a change here will remove their ja buffs
  target_zone = {},

  -- table that stores the highest known songs slots for a bard
  bard_highest_known_max = {},

  -- lookup table for a player name to an id, because their id is lost when the are in a different zone.
  party_player_ids = {},

  -- lookup table for a player id, to quickly check for party membership
  party_players = {},

  current_tick = 1,

  -- incrementing unique identifier used by some buffs to make them unique in the composite key
  current_buff_id = 1,

  current_player_id = -1
}

function status_effects:initialize()
  self.is_initialized = true
  self.current_player_id = windower.ffxi.get_player().id
end

function status_effects:destroy()
  self.is_initialized = false
  self.buffs = {}
  self.current_zone = -1
  self.target_zone = {}
  self.bard_highest_known_max = {}
  self.party_player_ids = {}
  self.party_players = {}
  self.current_tick = 1
  self.current_buff_id = 1
  self.current_player_id = -1
end

function status_effects:get_id_from_player_name(player_name)
  local player = self.party_player_ids[player_name]

  if player then
    return player
  else
    return -1
  end
end

function status_effects:update_target_zone(target_id, zone)
  if target_id == -1 then
    -- we don't know who it is, have to skip :(
    return
  end

  local existing_zone = self.target_zone[target_id]

  if existing_zone and zone == existing_zone then
    -- Zone hasn't changed, nothing to do
    return
  end

  -- Handle buffs if the zone has changed
  if existing_zone then
    --print(target_id .. ' - Zone has changed from ' .. existing_zone .. ' to ' .. zone .. ', removing JA buffs.')

    if self.buffs[target_id] then
      for buff_id, spell_table in pairs(self.buffs[target_id]) do
        for composite_key in pairs(spell_table) do
          local key_type = composite_key:match("^(%a+):%d+$")

          --print(key_type .. ' ' .. composite_key)

          if key_type == 'ja' then
            spell_table[composite_key] = nil -- Remove JA buff

            -- Clean up empty buff_id entry
            if next(spell_table) == nil then
              self.buffs[target_id][buff_id] = nil
            end
          end
        end
      end

      -- Clean up empty target_id entry
      if next(self.buffs[target_id]) == nil then
        self.buffs[target_id] = nil
      end
    end
  else
    --print('Not tracking target zone yet, setting to ' .. zone)
  end

  -- Update the zone
  self.target_zone[target_id] = zone
end

function status_effects:update()
  for target_id, target_buffs in pairs(self.buffs) do
    for buff_id, spell_table in pairs(target_buffs) do
      for composite_key, buff in pairs(spell_table) do
        if buff.definitive == false then
          -- Update remaining time
          buff.remaining_time = buff.end_time - os.clock()

          -- Remove expired buffs
          if buff.remaining_time <= 0 then
            spell_table[composite_key] = nil -- Remove this specific spell_id entry

            -- Clean up empty buff_id entry
            if next(spell_table) == nil then
              target_buffs[buff_id] = nil
            end
          end
        end
      end
    end

    -- Clean up empty target entry
    if next(target_buffs) == nil then
      self.buffs[target_id] = nil
    end
  end

  -- check party / alliance zones every few seconds to keep them up-to-date and
  -- to help purge buffs that fall off across zones

  if self.current_tick % 120 then
    if self.current_tick % 1200 then
      self.party_players = {}
    end

    if self.current_tick % 120001 then
      -- rebuild the lookup list once in a while
      self.party_player_ids = {}
    end

    local party = windower.ffxi.get_party()
    if party ~= nil then
      for _, key in ipairs({ 'p1', 'p2', 'p3', 'p4', 'p5', 'a10', 'a11', 'a12', 'a13', 'a14', 'a15', 'a20', 'a21', 'a22', 'a23', 'a24', 'a25' })
      do
        local party_member = party[key]
        if party_member ~= nil then
          -- update id mapping if available
          if party_member.mob then
            self.party_player_ids[party_member.name] = party_member.mob.id
          end

          local party_id = self.party_player_ids[party_member.name]
          if party_id then
            self.party_players[party_id] = true
          end

          -- update zone
          self:update_target_zone(self:get_id_from_player_name(party_member.name), party_member.zone)
        end
      end
    end

    self.party_players[self.current_player_id] = true
  end

  self.current_tick = self.current_tick + 1
end

-- This function looks for buff additions and removals in the standard logged actions, such
-- as from spells, abilities, weaponskills, erase, etc.
function status_effects:find_buffs_in_action(data)
  -- local message_id = data.targets[1].actions[1].message

  local actor_id = data.actor_id

  if data.targets then
    local source = 'UNKNOWN' -- UNKNOWN, MAGIC, ABILITY, WEASPONSKILL

    for _, target in pairs(data.targets) do
      if self.party_players[target.id] then
        return -- do not parse if definitive data will exist
      end

      if target.actions then
        for _, action in pairs(target.actions) do
          local message_id = action.message

          --------------------------------------------------------------------------------
          -- MAGIC SPELL APPLY BUFF
          --------------------------------------------------------------------------------
          if message_id == 2       -- cast and deal damage
              or message_id == 252 -- cast and magic burst
              or message_id == 230 -- cast and gain status defensive
              or message_id == 236 -- cast and gain status offensive
              or message_id == 237 -- cast and gain status generic
              or message_id == 268 -- cast and magic burst plus status
              or message_id == 271 -- cast and magic burst plus status_effects
          then
            source = 'MAGIC'
            local spell_id = data.param -- data.param will capture ${spell} in original message
            local buff_id = res.spells[spell_id].status

            -- for non-damaging events, we can try to pull the status from the action params
            if message_id ~= 2 and message_id ~= 252 then
              if not buff_id then
                buff_id = action.param
              end
            end

            local type = res.spells[spell_id].type

            if buff_id then
              --print('gain via action -- ' .. target.id .. ' <- ' .. buff_id .. ' from ' .. spell_id)
              self:add_parsed_buff(target.id, source, spell_id, buff_id, type, actor_id)
            end

            --------------------------------------------------------------------------------
            -- JOB ABILITY APPLY BUFF
            --------------------------------------------------------------------------------
          elseif message_id == 100 -- use ability, no target
              or message_id == 115 -- use ability, enhance self
              or message_id == 116 -- use ability, enhance self
              or message_id == 117 -- use ability, enhance self
              or message_id == 118 -- use ability, enhance self
              or message_id == 119 -- use ability, on target
              or message_id == 120 -- use ability, enhance self
              or message_id == 121 -- use ability, enhance self
              or message_id == 126 -- use ability, enhance self
              or message_id == 127 -- use ability, status target
              or message_id == 131 -- use ability, defend against mob type
              or message_id == 134 -- use ability, defend against mob type
              or message_id == 141 -- use ability, status target
              or message_id == 143 -- use ability, enhance self
              or message_id == 144 -- use ability, debuff target
              or message_id == 146 -- use ability, debuff target
              or message_id == 148 -- use ability, defend against mob type
              or message_id == 149 -- use ability, defend against mob type
              or message_id == 150 -- use ability, defend against mob type
              or message_id == 151 -- use ability, defend against mob type
              or message_id == 303 -- divine seal
              or message_id == 304 -- ele seal
              or message_id == 305 -- trick attack
              or message_id == 420 -- rolls
              or message_id == 421 -- various ja, i.e. rolls
          then
            source = 'ABILITY'
            local ability_id = data.param -- data.param will capture ${ability} in original message
            local buff_id = res.job_abilities[ability_id].status or action.param
            local type = res.job_abilities[ability_id].type

            if buff_id then
              --print('gain via action -- ' .. buff_id .. ' -> ' .. target_id)
              self:add_parsed_buff(target.id, source, ability_id, buff_id, type, actor_id)
            end

            --------------------------------------------------------------------------------
            -- WEAPON SKILL / MOB ABILITY APPLY BUFF
            --------------------------------------------------------------------------------
          elseif message_id == 185 -- use weaponskill, target damange
              or message_id == 186 -- use weaponskill, target status
              or message_id == 194 -- use weaponskill, target status
              or message_id == 242 -- use weaponskill, target status
              or message_id == 243 -- use weaponskill, target status
          then
            source = 'WEAPONSKILL'
            local ability_id = data.param -- data.param will capture ${weaponskill} in original message
            local buff_id_lookup = monster_abilities[ability_id] and monster_abilities[ability_id].status
            local type = 'Weaponskill'

            if ability_id < 256 then
              local ws = res.weapon_skills[ability_id]
              debug_print(ws.en .. ' ' .. tostring(ability_id))
            else
              local ws = res.monster_abilities[ability_id]
              debug_print(ws.en .. ' ' .. tostring(ability_id))
            end

            if message_id == 185 then
              -- It is a damage event, so we have to perform a lookup for its status.
              if buff_id_lookup then
                for _, single_buff_id in pairs(buff_id_lookup) do
                  local target_id = target.id
                  --print('ws gain via lookup action ' ..
                  --  message_id .. ': ' .. ability_id .. '-- ' .. single_buff_id .. ' -> ' .. target_id)
                  self:add_parsed_buff(target_id, source, ability_id, single_buff_id, type, actor_id)
                end
              end
            else
              -- It is not a damage event, so the buff should come across in the chat message.
              local buff_id_parsed = action.param
              local target_id = target.id
              if buff_id_parsed and buff_id_parsed ~= 0 then
                --print('ws explicit gain via action ' ..
                --  message_id .. ': ' .. ability_id .. '-- ' .. buff_id_parsed .. ' -> ' .. target_id)
                self:add_parsed_buff(target_id, source, ability_id, buff_id_parsed, type, actor_id)
              end
            end

            --------------------------------------------------------------------------------
            -- CORSAIR ROLL BUST
            --------------------------------------------------------------------------------
          elseif message_id == 426 then
            local ability_id = data.param
            local buff_id = res.job_abilities[ability_id].status or action.param

            if buff_id then
              local target_id = target.id
              --print('lost via action -- ' .. buff_id .. ' -> ' .. target_id)
              self:remove_buff_with_priority(target_id, buff_id, true)
            end

            --------------------------------------------------------------------------------
            -- PUPPET OVERLOAD
            --------------------------------------------------------------------------------
          elseif message_id == 799 then
            self:add_parsed_buff_pup(target.id, 299)


            --------------------------------------------------------------------------------
            -- PUPPET MANEUVER
            --------------------------------------------------------------------------------
          elseif message_id == 798 then
            source = 'ABILITY'
            local ability_id = data.param -- data.param will capture ${ability} in original message
            local type = res.job_abilities[ability_id].type
            local buff_id

            if ability_id == 141 then
              buff_id = 300
            elseif ability_id == 141 then
              buff_id = 300
            elseif ability_id == 142 then
              buff_id = 301
            elseif ability_id == 143 then
              buff_id = 302
            elseif ability_id == 144 then
              buff_id = 303
            elseif ability_id == 145 then
              buff_id = 304
            elseif ability_id == 146 then
              buff_id = 305
            elseif ability_id == 147 then
              buff_id = 306
            elseif ability_id == 148 then
              buff_id = 307
            end

            if buff_id then
              self:add_parsed_buff(target.id, source, ability_id, buff_id, type, actor_id)
            end

            --------------------------------------------------------------------------------
            -- MAGIC REMOVE BUFF
            --------------------------------------------------------------------------------
          elseif message_id == 341 -- erase
              or message_id == 342 -- erase
              or message_id == 83  -- na spell
          then
            debug_print('ma removal   ability=' .. data.param .. ', param=' .. action.param)

            local ability_id = data.param
            local buff_id = action.param

            if buff_id then
              self:remove_buff_with_priority(target.id, buff_id)
            end

            --------------------------------------------------------------------------------
            -- JA REMOVE BUFF
            --------------------------------------------------------------------------------
          elseif message_id == 123
          then
            debug_print('ja removal   ability=' .. data.param .. ', param=' .. action.param)


            local ability_id = data.param
            local buff_id = action.param

            if buff_id then
              self:remove_buff_with_priority(target.id, buff_id)
            end

            --------------------------------------------------------------------------------
            -- TAKE DAMAGE, NO EXPLICIT SOURCE
            --------------------------------------------------------------------------------
          elseif message_id == 264       -- take damage
          then
            local source_id = data.param -- data.param will capture the source id in original message

            if source == "WEAPONSKILL" then
              local buff_id_lookup = monster_abilities[source_id] and monster_abilities[source_id].status

              -- It is a damage event, so we have to perform a lookup for its status.
              if buff_id_lookup then
                for _, single_buff_id in pairs(buff_id_lookup) do
                  local target_id = target.id
                  self:add_parsed_buff(target_id, source, source_id, single_buff_id, type, actor_id)
                end
              end
            end

            --------------------------------------------------------------------------------
            -- GAIN STATUS, NO EXPLICIT SOURCE
            --------------------------------------------------------------------------------
          elseif message_id == 266       -- gain effect
              or message_id == 267       -- gain effect
              or message_id == 277       -- gain effect
              or message_id == 278       -- gain effect
              or message_id == 279       -- gain effect
          then
            local source_id = data.param -- data.param will capture the source id in original message
            local buff_id = action.param

            local type = ''
            if source == 'MAGIC' then
              type = res.spells[source_id].type
            elseif source == 'ABILITY' then
              type = res.job_abilities[source_id].type
            end

            if buff_id then
              --print('gain via action -- ' .. buff_id .. ' -> ' .. target_id)
              self:add_parsed_buff(target.id, source, source_id, buff_id, type, actor_id)
            end

            --------------------------------------------------------------------------------
            -- NOT FOUND
            --------------------------------------------------------------------------------
          else
            local spell_id = data.param
            if spell_id > 256 and spell_id < 4500 then
              debug_print('did not ha capture ' .. spell_id .. ' -> ' .. message_id)
            end
          end
        end
      end
    end
  end
end

-- This function looks through an action to see if it consumes any existing buffs, such as
-- divine seal being consumed by a healing spell.
function status_effects:find_buff_consumptions_in_action(data)
  local actor_id = data.actor_id

  if data.targets then
    for _, target in pairs(data.targets) do
      if self.party_players[target.id] then
        return -- do not parse if definitive data will exist
      end

      if target.actions then
        for _, action in pairs(target.actions) do
          local message_id = action.message

          --------------------------------------------------------------------------------
          -- MAGIC SPELL (damage check for sleep removal)
          --------------------------------------------------------------------------------
          if message_id == 2                                                       -- cast and deal damage
              or message_id == 252                                                 -- cast and magic burst
              or message_id == 265                                                 -- magic burst
              or message_id == 648                                                 -- cast and damage
              or message_id == 650                                                 -- cast and magic burst
          then
            self:remove_buff_with_priority(target.id, { 2, 19, 69, 70, 71 }, true) -- wake up sleep, remove sneak/invis
          end

          --------------------------------------------------------------------------------
          -- MAGIC SPELL
          --------------------------------------------------------------------------------
          if message_id == 2            -- cast and deal damage
              or message_id == 7        -- cast and recover hp
              or message_id == 252      -- cast and magic burst
              or message_id == 230      -- cast and gain status defensive
              or message_id == 236      -- cast and gain status offensive
              or message_id == 237      -- cast and gain status generic
              or message_id == 268      -- cast and magic burst plus status
              or message_id == 271      -- cast and magic burst plus status_effects
          then
            local spell_id = data.param -- data.param will capture ${spell} in original message
            local spell = res.spells[spell_id]

            local buffs_to_remove = {
              76, -- hide
              77, -- camo
              69, -- invis
            }

            -- CURES
            if spell_id == 1 -- Cure 1-6
                or spell_id == 2
                or spell_id == 3
                or spell_id == 4
                or spell_id == 5
                or spell_id == 6
                or spell_id == 7 -- Curaga 1-5
                or spell_id == 8
                or spell_id == 9
                or spell_id == 10
                or spell_id == 11
                or spell_id == 93 -- Cura1-2
                or spell_id == 474
                or spell_id == 475
                or spell_id == 893                                       -- Full Cure
            then
              table.insert(buffs_to_remove, 78)                          -- divine seal

              self:remove_buff_with_priority(target.id, { 2, 19 }, true) -- wake up sleep
            end

            -- -NA SPELLS
            if spell_id == 14
                or spell_id == 15
                or spell_id == 16
                or spell_id == 17
                or spell_id == 18
                or spell_id == 19
                or spell_id == 20
                or spell_id == 143
            then
              table.insert(buffs_to_remove, 78)  -- divine seal
              table.insert(buffs_to_remove, 453) -- divine caress
              table.insert(buffs_to_remove, 458) -- divine caress
            end

            -- Offensive spells
            if spell.targets['Enemy'] then
              table.insert(buffs_to_remove, 70) -- sneak
              table.insert(buffs_to_remove, 71) -- deodorize

              table.insert(buffs_to_remove, 79) -- elemental seal

              -- Offensive Elemental spells
              if spell.element >= 0 and spell.element <= 7 then
                table.insert(buffs_to_remove, 598) -- cascade
                table.insert(buffs_to_remove, 517) -- collimated favor
              end
            end

            -- Enfeebles
            if spell.skill == 35 then
              table.insert(buffs_to_remove, 494) -- stymie
            end

            -- Divine spells
            if spell.skill == 32 then
              table.insert(buffs_to_remove, 438) -- divine emblem
            end

            -- Dark spells
            if spell.skill == 37 then
              table.insert(buffs_to_remove, 345) -- dark seal
              table.insert(buffs_to_remove, 439) -- nether void
            end

            -- Enhancing
            if spell.skill == 34 then
              table.insert(buffs_to_remove, 534) -- embolden
            end

            -- Elemental Ninjutsu
            if spell.id >= 320 and spell.id <= 337 then
              table.insert(buffs_to_remove, 441) -- futae
            end

            -- Geomancy
            if spell.type == "Geomancy" then
              table.insert(buffs_to_remove, 569) -- blaze of glory
            end

            -- Indi-skills
            if spell.en:sub(1, 4) == "Indi" then
              table.insert(buffs_to_remove, 584) -- entrust
            end

            -- Blue Magic
            if spell.type == "BlueMagic" then
              if spell.element >= 0 and spell.element <= 7 then
                table.insert(buffs_to_remove, 165) -- burst affinity
                table.insert(buffs_to_remove, 355) -- convergence
                table.insert(buffs_to_remove, 356) -- diffusion
              else
                table.insert(buffs_to_remove, 164) -- chain affinity
                table.insert(buffs_to_remove, 457) -- efflux
              end
            end

            -- White Magic
            if spell.type == "WhiteMagic" then
              table.insert(buffs_to_remove, 360) -- penury
              table.insert(buffs_to_remove, 362) -- celerity
              table.insert(buffs_to_remove, 364) -- rapture
              table.insert(buffs_to_remove, 412) -- altruism
              table.insert(buffs_to_remove, 414) -- tranquility

              if spell.skill == 34 then
                table.insert(buffs_to_remove, 469) -- perpetuance
              end

              if spell.skill == 33 or spell.skill == 34 then
                table.insert(buffs_to_remove, 366) -- accession
              end
            end

            -- Black Magic
            if spell.type == "BlackMagic" then
              table.insert(buffs_to_remove, 361) -- parsimony
              table.insert(buffs_to_remove, 363) -- alacrity
              table.insert(buffs_to_remove, 365) -- ebullience
              table.insert(buffs_to_remove, 413) -- focalization
              table.insert(buffs_to_remove, 415) -- equaniminty

              if spell.skill == 36 then
                table.insert(buffs_to_remove, 470) -- immanence
              end

              if spell.skill == 35 then
                table.insert(buffs_to_remove, 367) -- manifestation
              end
            end

            -- Songs
            if spell.type == "BardSong" then
              if spell.targets['Self'] then
                table.insert(buffs_to_remove, 455) -- tenuto
                table.insert(buffs_to_remove, 409) -- pianissimo
              end

              table.insert(buffs_to_remove, 231) -- marcato
            end

            -- Applies to any spell
            table.insert(buffs_to_remove, 229) -- manawell
            table.insert(buffs_to_remove, 230) -- sponteneity

            if buffs_to_remove then
              self:remove_buff_with_priority(actor_id, buffs_to_remove, true)
            end

            --------------------------------------------------------------------------------
            -- JOB ABILITY (DAMAGE)
            --------------------------------------------------------------------------------
          elseif message_id == 77  -- sange
              or message_id == 110 -- ability damage
              or message_id == 157 -- barrage damage
              or message_id == 163 -- additional damage
              or message_id == 229 -- additional damage
              or message_id == 264 -- straight damage
              or message_id == 317 -- ability damage
              or message_id == 413 -- item damage
              or message_id == 522 -- ability damaage and stun

          then
            local ability_id = data.param -- data.param will capture ${ability} in original message
            local buffs_consumed_by_ja = {
              76,                         -- hide
              77,                         -- camo
              69,                         -- invis
              70,                         -- deodorize
              71                          -- sneak
            }

            local ability = res.job_abilities[ability_id]

            if ability then
              if ability.type == "BloodPactRage" or ability.type == "BloodPactWard" then
                table.insert(buffs_consumed_by_ja, 583) -- apogee
              end
            end

            self:remove_buff_with_priority(actor_id, buffs_consumed_by_ja, true)

            if message_id ~= 188 then
              self:remove_buff_with_priority(target.id, { 2, 19, 69, 70, 71 }, true) -- wake up sleep, remove sneak/invis
            end

            --------------------------------------------------------------------------------
            -- JOB ABILITY (NON_DAMAGE)
            --------------------------------------------------------------------------------
          elseif message_id == 100        -- use ability, no target
              or message_id == 115        -- use ability, enhance self
              or message_id == 116        -- use ability, enhance self
              or message_id == 117        -- use ability, enhance self
              or message_id == 118        -- use ability, enhance self
              or message_id == 119        -- use ability, on target
              or message_id == 120        -- use ability, enhance self
              or message_id == 121        -- use ability, enhance self
              or message_id == 126        -- use ability, enhance self
              or message_id == 127        -- use ability, status target
              or message_id == 131        -- use ability, defend against mob type
              or message_id == 134        -- use ability, defend against mob type
              or message_id == 141        -- use ability, status target
              or message_id == 143        -- use ability, enhance self
              or message_id == 144        -- use ability, debuff target
              or message_id == 146        -- use ability, debuff target
              or message_id == 148        -- use ability, defend against mob type
              or message_id == 149        -- use ability, defend against mob type
              or message_id == 150        -- use ability, defend against mob type
              or message_id == 151        -- use ability, defend against mob type
              or message_id == 158        -- use ability, miss
              or message_id == 324        -- use ability, miss
              or message_id == 303        -- divine seal
              or message_id == 304        -- ele seal
              or message_id == 305        -- trick attack
              or message_id == 420        -- rolls
              or message_id == 421        -- various ja, i.e. rolls
          then
            local ability_id = data.param -- data.param will capture ${ability} in original message
            local buffs_consumed_by_ja = {
              76,                         -- hide
              77,                         -- camo
              69,                         -- invis
            }

            local ability = res.job_abilities[ability_id]

            if ability.type == "BloodPactRage" or ability.type == "BloodPactWard" then
              table.insert(buffs_consumed_by_ja, 583) -- apogee
            end

            if ability.type == "CorsairRoll" then
              table.insert(buffs_consumed_by_ja, 357) -- snake eyes
              table.insert(buffs_consumed_by_ja, 601) -- crooked cards
            end

            if ability.type == "Step" then
              table.insert(buffs_consumed_by_ja, 442) -- presto
            end

            self:remove_buff_with_priority(actor_id, buffs_consumed_by_ja, true)

            if message_id ~= 188 then
              self:remove_buff_with_priority(target.id, { 2, 19, 69, 70, 71 }, true) -- wake up sleep, remove sneak/invis
            end

            --------------------------------------------------------------------------------
            -- WEAPON SKILL
            --------------------------------------------------------------------------------
          elseif message_id == 185 -- use weaponskill, target damage
              or message_id == 186 -- use weaponskill, target status
              or message_id == 187 -- use weaponskill, drains health
              or message_id == 188 -- use weaponskill, miss
              or message_id == 189 -- use weaponskill, no effect
          then
            local buffs_consumed_by_ws = {
              408, -- sekkanoki
              440, -- sengikori
              483, -- hagakure
              45,  -- boost
              65,  -- sneak attack
              87,  -- trick attack
              599, -- consume mana
              76,  -- hide
              77,  -- camo
              69,  -- invis
              70,  -- deodorize
              71   -- sneak
            }

            self:remove_buff_with_priority(actor_id, buffs_consumed_by_ws, true)

            if message_id ~= 188 then
              self:remove_buff_with_priority(target.id, { 2, 19, 69, 70, 71 }, true) -- wake up sleep, remove sneak/invis
            end

            --------------------------------------------------------------------------------
            -- MELEE ATTACK
            --------------------------------------------------------------------------------
          elseif message_id == 1  -- melee attack
              or message_id == 15 -- melee miss
              or message_id == 63 -- melee miss
              or message_id == 67 -- melee attack critical
          then
            local buffs_consumed_by_attack = {
              343, -- feint
              45,  -- boost
              65,  -- sneak attack
              87,  -- trick attack
              599, -- consume mana
              76,  -- hide
              77,  -- camo
              69,  -- invis
              70,  -- deodorize
              71   -- sneak
            }

            self:remove_buff_with_priority(actor_id, buffs_consumed_by_attack, true)

            if message_id ~= 15 and message_id ~= 63 then
              self:remove_buff_with_priority(target.id, { 2, 19, 69, 70, 71 }, true) -- wake up sleep, remove sneak/invis
            end

            --------------------------------------------------------------------------------
            -- RANGED ATTACK
            --------------------------------------------------------------------------------
          elseif message_id == 352 -- ranged attack
              or message_id == 353 -- ranged attack critical
              or message_id == 354 -- ranged attack miss
              or message_id == 355 -- ranged attack no effect
              or message_id == 576 -- ranged attack squarely
              or message_id == 577 -- ranged attack true
          then
            local buffs_consumed_by_attack = {
              115, -- unlimited shot
              73,  -- barrage
              351, -- flashy shot
              350, -- stealth shot
              76,  -- hide
              77,  -- camo
              69,  -- invis
              70,  -- deodorize
              71   -- sneak
            }

            self:remove_buff_with_priority(actor_id, buffs_consumed_by_attack, true)

            if message_id ~= 354 and message_id ~= 355 then
              self:remove_buff_with_priority(target.id, { 2, 19, 69, 70, 71 }, true) -- wake up sleep, remove sneak/invis
            end

            --------------------------------------------------------------------------------
            -- TAKE DAMAGE, NO EXPLICIT SOURCE
            --------------------------------------------------------------------------------
          elseif message_id == 264
          then
            self:remove_buff_with_priority(target.id, { 2, 19, 69, 70, 71 }, true) -- wake up sleep, remove sneak/invis

            --------------------------------------------------------------------------------
            -- RECOVER HEALTH, NO EXPLICIT SOURCE
            --------------------------------------------------------------------------------
          elseif message_id == 24
              or message_id == 26
              or message_id == 263
              or message_id == 306
              or message_id == 267
          then
            self:remove_buff_with_priority(target.id, { 2, 19, 69, 70, 71 }, true) -- wake up sleep, remove sneak/invis
          end
        end
      end
    end
  end
end

function status_effects:handle_action(data)
  self:find_buffs_in_action(data)
  self:find_buff_consumptions_in_action(data)
end

-- unhandled actions... for now
-- 570-572, 757, 792: multi-erase
-- 319-320, 414, 441, 602: target gain status from ja
-- 321-322: target lose status from ja
-- 453: status steal
-- 663-664: geo
-- 669-672: run
-- 804: magic burst and status from ability


function status_effects:handle_action_message(data)
  --print('action_message=' .. data.message_id)

  if self.party_players[data.target_id] then
    return -- do not parse if definitive data will exist
  end

  if data.message_id == 6       -- x defeats target
      or data.message_id == 20  -- target falls to the ground
      or data.message_id == 113 -- target falls to the ground after ma
      or data.message_id == 406 -- target falls to the ground after ws
      or data.message_id == 605 -- target falls to the ground after additional effect
      or data.message_id == 646 -- target falls to the ground after ja
  then
    self:remove_buff(data.target_id)
  elseif data.message_id == 203 -- gains status
      or data.message_id == 205 -- gains status
      or data.message_id == 779 -- pup overloaded
  then
    --print('gain via action message ' .. data.buff_id)
  elseif data.message_id == 64  -- status cured
      or data.message_id == 204 -- wears off
      or data.message_id == 206 -- wears off
      or data.message_id == 350 -- wears off
      or data.message_id == 531 -- wears off
      or data.message_id == 647 -- cast and single erase
      or data.message_id == 805 -- ws and single erase
      or data.message_id == 806 -- single erase
  then
    self:remove_buff_with_priority(data.target_id, data.buff_id)
  else
    local buff_id = data.buff_id
    if buff_id < 5000 then
      debug_print('did not ham capture ' .. buff_id .. ' -> ' .. data.message_id)
    end

    -- local target = windower.ffxi.get_mob_by_target('t')
    -- if (target.id == data.target_id) then
    --   --print('did not ham capture ' .. data.target_id .. ' -> ' .. data.message_id)
    -- end
  end
end

function status_effects:get_max_songs_for_actor(actor_id)
  -- Get player data
  local player = windower.ffxi.get_player()
  if not player then
    return 2
  end

  -- Check if the player is the specified actor
  if player.id ~= actor_id then
    return 2
  end

  -- Main job BRD adds 2 songs, sub job BRD adds 1
  local max_songs = 0
  if player.main_job == "BRD" then
    max_songs = 2
  end
  if player.sub_job == "BRD" then
    max_songs = 1
  end

  if windower.ffxi.get_items() ~= nil then
    if not (windower.ffxi.get_items().equipment.range_bag == 0 and windower.ffxi.get_items().equipment.range == 0) then
      local ranged_weapon = windower.ffxi.get_items(windower.ffxi.get_items().equipment.range_bag,
        windower.ffxi.get_items().equipment.range).id
      if ranged_weapon ~= nil then
        if ranged_weapon == 18571 or ranged_weapon == 18839 then
          -- dauradabla maxed
          max_songs = max_songs + 2
        elseif ranged_weapon == 18574 or ranged_weapon == 18575 or ranged_weapon == 18576 or ranged_weapon == 21407 then
          -- dauradabla / terpander
          max_songs = max_songs + 1
        end
      end
    end
  end

  -- clarion call 499
  if self.buffs[actor_id] and self.buffs[actor_id][499] and self.buffs[actor_id][499]['ja:332'] then
    max_songs = max_songs + 1
  end

  return max_songs
end

function status_effects:get_max_rolls_for_actor(actor_id)
  -- Get player data
  local player = windower.ffxi.get_player()
  if not player then
    return 2
  end

  -- Check if the player is the specified actor
  if player.id ~= actor_id then
    return 2
  end

  -- Main job COR adds 2 rolls, sub job COR adds 1
  local max_rolls = 0
  if player.main_job == "COR" then
    max_rolls = 2
  end
  if player.sub_job == "COR" then
    max_rolls = 1
  end

  return max_rolls
end

function status_effects:add_parsed_buff(target_id, source_type, source_id, buff_id, type, actor_id)
  if source_type == 'MAGIC' then
    self:add_parsed_buff_ma(target_id, source_id, buff_id, type, actor_id)
  elseif source_type == 'ABILITY' then
    self:add_parsed_buff_ja(target_id, source_id, buff_id, type, actor_id)
  elseif source_type == 'WEAPONSKILL' then
    self:add_parsed_buff_ws(target_id, source_id, buff_id, type, actor_id)
  end

  -- update target last known zone
  self:update_target_zone(target_id, self.current_zone)
end

function status_effects:get_known_spell_duration(spell_id)
  if spell_id == 112 then     -- flash
    return 6
  elseif spell_id == 136 then -- invis/sneak/deodorize
    return 600
  elseif spell_id == 137 then
    return 600
  elseif spell_id == 138 then
    return 600
  end
end

function status_effects:get_known_ability_duration(ability_id)
  if ability_id >= 141 and ability_id <= 148 then -- manuevers
    return 60
  end
end

function status_effects:add_parsed_buff_ma(target_id, spell_id, buff_id, type, actor_id)
  local spell = res.spells[spell_id]
  local duration = spell.duration or self:get_known_spell_duration(spell_id) or 60

  if spell then
    -- Prepare composite key
    local composite_key = 'ma:' .. spell_id

    -- Prepare data structures
    if not self.buffs[target_id] then
      self.buffs[target_id] = {}
    end
    if not self.buffs[target_id][buff_id] then
      self.buffs[target_id][buff_id] = {}
    end

    -- check for blocking buffs, such as bio blocking dia
    local blocking_buffs = blocking_spells[spell_id]
    if blocking_buffs then
      for _, blocking_spell_id in ipairs(blocking_buffs) do
        for b_id, spell_table in pairs(self.buffs[target_id]) do
          for s_id, buff in pairs(spell_table) do
            if s_id == blocking_spell_id then
              -- Block the application of this spell
              return
            end
          end
        end
      end
    end

    -- next, delete any explicit overwrites, example dia 2 overwrites dia 1
    if spell.overwrites then
      for _, overwritten_id in pairs(spell.overwrites) do
        self:remove_buff_given_by_id(target_id, 'ma:' .. overwritten_id)
      end
    end

    -- handle special "stackable" spells, such as certain bard songs that stack with
    -- themselves as opposed to overwriting like most spells do
    local is_stackable = stackable_spells[spell_id]
    if not is_stackable and self.buffs[target_id] then
      for existing_buff_id, spell_table in pairs(self.buffs[target_id]) do
        if existing_buff_id == buff_id then
          for existing_composite_key, buff in pairs(spell_table) do
            -- Remove non-stackable buffs of the same type
            self:remove_buff_given_by_id(target_id, existing_composite_key)
          end
        end
      end
    end

    -- Bard songs work with the following logic
    --   1. max songs/rolls combined on a target is 12.
    --   2. max songs on a target from a specific player is either 2 for a main job bard with an instrument equipped, or 1 for
    --      either a sub job bard or a main job bard with no instrument. max songs can increase from instruments or JA buffs.
    --   3. max rolls on a target from a specific player is eitehr 2 for a main job corsair or 1 for a sub job corsair.
    --   4. when a new song is sung AND the singing bard has used up its slots, then:
    --        a. if the new song is the same as an existing song, just update the existing song duration
    --        b. but if its a new song, replace the song with the lowest duration.
    --      however, if a new song is sung and the target has used its 12 combined song/roll slots, then the oldest one is replaced
    --      unless a song is being "refreshed" in duration.
    --
    --   In addition, the following should be considered.
    --    The JA Clarion Call increases the song slots by 1 for the singing bard while active.
    --    Tenuto allows the bard to stack five more songs on itself.
    --
    if type == 'BardSong' then
      local bard_id = actor_id
      local target_buffs = self.buffs[target_id] or {}

      -- Count songs/rolls
      local current_gear_max = self:get_max_songs_for_actor(bard_id)
      local known_max = self.bard_highest_known_max[bard_id] or 0
      local total_songs_rolls = 0
      local bard_songs = {}

      for b_id, spell_table in pairs(target_buffs) do
        for c_id, buff in pairs(spell_table) do
          if buff.type == 'BardSong' or buff.type == 'CorsairRoll' then
            total_songs_rolls = total_songs_rolls + 1
            if buff.type == 'BardSong' and buff.actor_id == bard_id then
              table.insert(bard_songs, {
                buff_id = b_id,
                composite_id = c_id,
                duration = buff.end_time - os.clock()
              })
            end
          end
        end
      end

      -- 1) If we’re just refreshing an existing song, do that and return.
      for _, s in ipairs(bard_songs) do
        if s.buff_id == buff_id and s.composite_id == composite_key then
          self.buffs[target_id][buff_id][composite_key].end_time = os.clock() + duration
          return
        end
      end

      local active_songs_count = #bard_songs

      -- 2) Update or revert known_max if needed:
      --    (a) If the current gear max is higher, raise known_max.
      if current_gear_max > known_max then
        known_max = current_gear_max
      else
        -- (b) If active songs have fallen below known_max AND our gear max is lower,
        --     that means we lost that “extra” slot in practice, so revert known_max.
        if active_songs_count < known_max and current_gear_max < known_max then
          known_max = current_gear_max
        end
      end

      self.bard_highest_known_max[bard_id] = known_max

      -- 3) Now enforce the “effective” (known) max if we’re adding a new song.
      if active_songs_count >= known_max then
        -- Remove the shortest song from this bard
        table.sort(bard_songs, function(a, b) return a.duration < b.duration end)
        local shortest = bard_songs[1]
        self.buffs[target_id][shortest.buff_id][shortest.composite_id] = nil
        if next(self.buffs[target_id][shortest.buff_id]) == nil then
          self.buffs[target_id][shortest.buff_id] = nil
        end
      end

      -- 4) Enforce total combined limit
      if total_songs_rolls >= 12 then
        -- Remove the oldest overall
        local oldest_buff, oldest_time
        oldest_time = math.huge

        for b_id, spell_table in pairs(target_buffs) do
          for c_id, buff in pairs(spell_table) do
            if (buff.type == 'BardSong' or buff.type == 'CorsairRoll') and buff.end_time < oldest_time then
              oldest_time = buff.end_time
              oldest_buff = { buff_id = b_id, composite_key = c_id }
            end
          end
        end

        if oldest_buff then
          self.buffs[target_id][oldest_buff.buff_id][oldest_buff.composite_key] = nil
          if next(self.buffs[target_id][oldest_buff.buff_id]) == nil then
            self.buffs[target_id][oldest_buff.buff_id] = nil
          end
        end
      end
    end

    -- Red Mage Composure Logic
    --   1. Duration < 30 minutes
    --   2. Magic is black or white
    --   3. Enhancing magic only
    --   4. Capped at 30 minutes
    --   5. Only on buffing self

    local composure_buff = nil
    if self.buffs and self.buffs[target_id] and self.buffs[target_id][419] and self.buffs[target_id][419]['ja:247'] then
      composure_buff = self.buffs[target_id][419]['ja:247']
    end

    if composure_buff
        and composure_buff.actor_id == actor_id
        and duration < 1800
        and (type == "WhiteMagic" or type == "BlackMagic")
        and (spell.skill and spell.skill == 34)
    then
      duration = math.min(duration * 3, 1800)
    end

    -- Scholar Perpetuance Logic
    --   1. Duration < 30 minutes
    --   2. Magic is white
    --   3. Enhancing magic only
    --   4. Capped at 30 minutes
    --   5. On buffing anyone, not just self.
    local perpetuance_buff = nil
    if self.buffs and self.buffs[actor_id] and self.buffs[actor_id][469] and self.buffs[actor_id][469]['ja:316'] then
      perpetuance_buff = self.buffs[actor_id][469]['ja:316']
    end

    if perpetuance_buff
        and perpetuance_buff.actor_id == actor_id
        and duration < 1800
        and type == "WhiteMagic"
        and (spell.skill and spell.skill == 34)
    then
      duration = math.min(duration * 2, 1800)
    end

    -- Ensure the table structure exists
    if not self.buffs[target_id] then
      self.buffs[target_id] = {}
    end
    if not self.buffs[target_id][buff_id] then
      self.buffs[target_id][buff_id] = {}
    end

    -- Add the new buff
    self.buffs[target_id][buff_id][composite_key] = {
      definitive = false,
      buff_id = buff_id,
      end_time = os.clock() + duration,
      originating_spell = spell.en,
      originating_id = composite_key,
      actor_id = actor_id,
      target_id = target_id,
      type = type,
      category = buff_types[buff_id] or "",
    }
    self.current_buff_id = self.current_buff_id + 1
  end
end

function status_effects:add_parsed_buff_ws(target_id, ability_id, buff_id, type, actor_id)
  local ability = monster_abilities[ability_id]
  -- if ability then
  --   local target = windower.ffxi.get_mob_by_id(target_id)
  --   print(ability.en .. ' -> ' .. res.buffs[buff_id].en .. ' -> ' .. target.name)
  -- else
  --   print(ability_id .. ' not in monster_abilities, probably has no effect')
  -- end

  if ability and ability.duration then
    -- Prepare composite key
    local composite_key = 'ws:' .. ability_id

    -- Prepare data structures
    if not self.buffs[target_id] then
      self.buffs[target_id] = {}
    end
    if not self.buffs[target_id][buff_id] then
      self.buffs[target_id][buff_id] = {}
    end

    -- Ensure the table structure exists
    if not self.buffs[target_id] then
      self.buffs[target_id] = {}
    end
    if not self.buffs[target_id][buff_id] then
      self.buffs[target_id][buff_id] = {}
    end

    -- Add the new buff
    self.buffs[target_id][buff_id][composite_key] = {
      definitive = false,
      buff_id = buff_id,
      end_time = os.clock() + ability.duration,
      originating_spell = ability.en,
      originating_id = composite_key,
      actor_id = actor_id,
      target_id = target_id,
      type = type,
      category = buff_types[buff_id] or ""
    }
    self.current_buff_id = self.current_buff_id + 1
  end
end

function status_effects:add_parsed_buff_ja(target_id, ability_id, buff_id, type, actor_id)
  local ability = res.job_abilities[ability_id]
  local duration = ability.duration or self:get_known_ability_duration(ability_id)

  if ability and duration then
    -- Prepare composite key
    local composite_key = 'ja:' .. ability_id

    -- Prepare data structures
    if not self.buffs[target_id] then
      self.buffs[target_id] = {}
    end
    if not self.buffs[target_id][buff_id] then
      self.buffs[target_id][buff_id] = {}
    end

    -- first, delete any explicit overwrites
    local overwrites = ja_overwrites[ability_id]
    if overwrites then
      for _, overwritten_id in pairs(overwrites) do
        self:remove_buff_given_by_id(target_id, 'ja:' .. overwritten_id)
      end
    end

    -- Corsair rolls logic
    if type == 'CorsairRoll' then
      local corsair_id = actor_id
      local target_buffs = self.buffs[target_id]

      -- Count songs/rolls
      local total_songs_rolls = 0
      local corsair_rolls = {}

      for b_id, spell_table in pairs(target_buffs) do
        for c_id, buff in pairs(spell_table) do
          if buff.type == 'BardSong' or buff.type == 'CorsairRoll' then
            total_songs_rolls = total_songs_rolls + 1
            if buff.actor_id == corsair_id and buff.type == 'CorsairRoll' then
              table.insert(corsair_rolls, { buff_id = b_id, composite_key = c_id, duration = buff.end_time - os.clock() })
            end
          end
        end
      end

      -- Determine max rolls allowed for this Corsair
      local max_rolls = self:get_max_rolls_for_actor(actor_id)

      -- Check if the roll already exists and can just be refreshed
      for _, roll in ipairs(corsair_rolls) do
        if roll.buff_id == buff_id and roll.composite_key == composite_key then
          -- Refresh the duration
          self.buffs[target_id][buff_id][composite_key].end_time = os.clock() + ability.duration
          return -- Stop here since we just refreshed
        end
      end

      -- If Corsair has reached max rolls
      if #corsair_rolls >= max_rolls then
        -- Find the shortest duration roll
        table.sort(corsair_rolls, function(a, b) return a.duration < b.duration end)
        local shortest_roll = corsair_rolls[1]
        self.buffs[target_id][shortest_roll.buff_id][shortest_roll.composite_key] = nil -- Replace it

        -- Clean up if the spell table is empty
        if next(self.buffs[target_id][shortest_roll.buff_id]) == nil then
          self.buffs[target_id][shortest_roll.buff_id] = nil
        end
      end

      -- If target has exceeded total song/roll limit
      if total_songs_rolls >= 12 then
        -- Find the oldest song/roll
        local oldest_buff = nil
        local oldest_time = math.huge

        for b_id, spell_table in pairs(target_buffs) do
          for c_id, buff in pairs(spell_table) do
            if buff.type == 'BardSong' or buff.type == 'CorsairRoll' then
              if buff.end_time < oldest_time then
                oldest_buff = { buff_id = b_id, composite_key = c_id }
                oldest_time = buff.end_time
              end
            end
          end
        end

        if oldest_buff then
          self.buffs[target_id][oldest_buff.buff_id][oldest_buff.composite_key] = nil -- Remove the oldest

          -- Clean up if the spell table is empty
          if next(self.buffs[target_id][oldest_buff.buff_id]) == nil then
            self.buffs[target_id][oldest_buff.buff_id] = nil
          end
        end
      end
    end

    -- Puppet maneuver logic
    if type == 'PetCommand' and ability.id >= 141 and ability.id <= 148 then
      type = 'Maneuver' -- rename type

      local puppet_id = actor_id
      local target_buffs = self.buffs[target_id]

      -- Count manuevers
      local puppet_manus = {}

      for b_id, spell_table in pairs(target_buffs) do
        for c_id, buff in pairs(spell_table) do
          if buff.type == 'Maneuver' then
            if buff.actor_id == puppet_id and buff.type == 'Maneuver' then
              table.insert(puppet_manus, { buff_id = b_id, composite_key = c_id, duration = buff.end_time - os.clock() })
            end
          end
        end
      end

      -- add unique composite key portion
      composite_key = composite_key .. ":" .. self.current_buff_id

      -- If Puppet has reached max manus
      if #puppet_manus >= 3 then
        -- Find the shortest duration manu
        table.sort(puppet_manus, function(a, b) return a.duration < b.duration end)
        local shortest_manu = puppet_manus[1]
        self.buffs[target_id][shortest_manu.buff_id][shortest_manu.composite_key] = nil -- Replace it

        -- Clean up if the spell table is empty
        if next(self.buffs[target_id][shortest_manu.buff_id]) == nil then
          self.buffs[target_id][shortest_manu.buff_id] = nil
        end
      end
    end

    -- Ensure the table structure exists
    if not self.buffs[target_id] then
      self.buffs[target_id] = {}
    end
    if not self.buffs[target_id][buff_id] then
      self.buffs[target_id][buff_id] = {}
    end

    -- Add the new buff
    self.buffs[target_id][buff_id][composite_key] = {
      definitive = false,
      buff_id = buff_id,
      end_time = os.clock() + duration,
      originating_spell = ability.en,
      originating_id = composite_key,
      actor_id = actor_id,
      target_id = target_id,
      type = type,
      category = buff_types[buff_id] or ""
    }
    self.current_buff_id = self.current_buff_id + 1
  end
end

function status_effects:add_parsed_buff_pup(target_id, buff_id)
  -- Prepare composite key
  local composite_key = 'ja:-1'

  -- overloaded status
  -- remove all maneuvers
  for _, maneuver_buff_id in pairs({ 300, 301, 302, 303, 304, 305, 306, 307 }) do
    self:remove_buff_with_priority(target_id, maneuver_buff_id, true)
  end

  -- add overloaded
  if not self.buffs[target_id] then
    self.buffs[target_id] = {}
  end
  if not self.buffs[target_id][buff_id] then
    self.buffs[target_id][buff_id] = {}
  end

  self.buffs[target_id][buff_id][composite_key] = {
    definitive = false,
    buff_id = buff_id,
    end_time = os.clock() + 60,
    originating_spell = 'Maneuver',
    originating_id = composite_key,
    actor_id = target_id,
    target_id = target_id,
    type = 'Overload',
    category = buff_types[buff_id] or ""
  }
end

function status_effects:remove_buff_given_by_id(target_id, composite_id)
  if not self.buffs[target_id] then
    return
  end

  -- Iterate over all buffs for the target
  for buff_id, ability_table in pairs(self.buffs[target_id]) do
    for composite_key, buff in pairs(ability_table) do
      if buff.originating_id == composite_id then
        self:remove_buff(target_id, buff_id, composite_key) -- Delegate to remove_buff
      end
    end
  end

  -- update target last known zone
  self:update_target_zone(target_id, self.current_zone)
end

function status_effects:remove_buff(target_id, buff_id, composite_key)
  if not self.buffs[target_id] then
    return
  end

  if not buff_id then
    -- If only target_id is provided, remove all buffs for the target
    self.buffs[target_id] = nil
  elseif not composite_key then
    -- If no composite_key  is provided, remove all buffs of buff_id
    if self.buffs[target_id][buff_id] then
      self.buffs[target_id][buff_id] = nil
    end
  else
    -- Remove the specific composite_key entry under the buff_id
    if self.buffs[target_id][buff_id] and self.buffs[target_id][buff_id][composite_key] then
      self.buffs[target_id][buff_id][composite_key] = nil

      -- Clean up buff_id entry if it's empty
      if next(self.buffs[target_id][buff_id]) == nil then
        self.buffs[target_id][buff_id] = nil
      end
    end
  end

  -- Clean up target entry if it's empty
  if self.buffs[target_id] and next(self.buffs[target_id]) == nil then
    self.buffs[target_id] = nil
  end

  -- update target last known zone
  self:update_target_zone(target_id, self.current_zone)
end

function status_effects:remove_buff_with_priority(target_id, buff_id_or_list, remove_all)
  if not self.buffs[target_id] then
    return
  end

  -- If no buff id(s) provided, remove all buffs
  if not buff_id_or_list then
    self.buffs[target_id] = nil
  else
    -- Ensure we have a table of buff IDs, even if just one
    local buff_ids = type(buff_id_or_list) == "table" and buff_id_or_list or { buff_id_or_list }

    -- Process each buff ID in the table
    for _, buff_id in ipairs(buff_ids) do
      if remove_all then
        -- Remove all buffs of buff_id
        if self.buffs[target_id][buff_id] then
          self.buffs[target_id][buff_id] = nil
        end
      else
        -- Remove only the "oldest" buff for buff_id
        if self.buffs[target_id][buff_id] then
          local oldest_composite_key, oldest_end_time = nil, math.huge

          for composite_key, buff_data in pairs(self.buffs[target_id][buff_id]) do
            if buff_data.end_time < oldest_end_time then
              oldest_composite_key = composite_key
              oldest_end_time = buff_data.end_time
            end
          end

          if oldest_composite_key then
            self.buffs[target_id][buff_id][oldest_composite_key] = nil
          end

          if next(self.buffs[target_id][buff_id]) == nil then
            self.buffs[target_id][buff_id] = nil
          end
        end
      end
    end
  end

  if self.buffs[target_id] and next(self.buffs[target_id]) == nil then
    self.buffs[target_id] = nil
  end

  self:update_target_zone(target_id, self.current_zone)
end

function status_effects:add_buffs_raw(target_id, buffs)
  -- Always reset or initialize the target_id structure
  self.buffs[target_id] = {}

  for index, buff_id in ipairs(buffs) do
    local composite_key = 'def:-1'


    -- Always reset or initialize the buff_id substructure
    self.buffs[target_id][buff_id] = {}

    -- Add the new buff
    self.buffs[target_id][buff_id][composite_key] = {
      definitive = true,
      buff_id = buff_id,
      end_time = os.clock() + 99999 - (index * 100),
      originating_spell = 'Unknown',
      originating_id = composite_key,
      actor_id = -1,
      target_id = target_id,
      type = type,
      category = buff_types[buff_id] or "",
    }
    self.current_buff_id = self.current_buff_id + 1
  end
end

-- this removes every buff from everyone other than the player and the party, used
-- when zoning to reset the buff table since we don't know what is happening after
-- we zone out
function status_effects:remove_all_non_party_buffs()
  -- Fetch the current player ID
  local player_id = self.current_player_id

  -- Prepare a set of allowed IDs for quick lookup
  local allowed_ids = {}
  allowed_ids[player_id] = true -- Always keep the player's buffs

  -- Iterate over the party/alliance to populate allowed IDs using self.party_player_ids
  local party = windower.ffxi.get_party()
  if party ~= nil then
    for _, key in ipairs({ 'p1', 'p2', 'p3', 'p4', 'p5', 'a10', 'a11', 'a12', 'a13', 'a14', 'a15', 'a20', 'a21', 'a22', 'a23', 'a24', 'a25' }) do
      local party_member = party[key]
      if party_member and party_member.name then
        -- Lookup the ID from the party_player_ids table
        local party_member_id = self.party_player_ids[party_member.name]
        if party_member_id then
          allowed_ids[party_member_id] = true
        end
      end
    end
  end

  -- Iterate through all buffs and remove non-party ones
  for target_id, _ in pairs(self.buffs) do
    if not allowed_ids[target_id] then
      self.buffs[target_id] = nil -- Remove all buffs for this target
    end
  end
end

-- returns as a composite keyed table
function status_effects:get_buffs_for_target(target_id)
  if not self.buffs[target_id] then
    return nil
  end

  local composite_buffs = {}

  for buff_id, spell_table in pairs(self.buffs[target_id]) do
    for composite_key1, buff in pairs(spell_table) do
      -- Split the composite key (e.g., "s:233", "a:43534", "ws:33")
      local _, key_id = composite_key1:match("^(%a+):(%d+)$")
      key_id = tonumber(key_id) -- Convert the numeric part back to a number

      local composite_key2 = buff_id .. ':' .. composite_key1

      composite_buffs[composite_key2] = {
        definitive = buff.definitive,
        buff_id = buff_id,
        spell_id = key_id, -- need to split spell id out
        end_time = buff.end_time,
        originating_spell = buff.originating_spell,
        originating_id = buff.originating_id,
        actor_id = buff.actor_id,
        target_id = buff.target_id,
        type = buff.type,
        category = buff.category
      }
    end
  end

  return composite_buffs
end

local remove_tick_target = 0

windower.register_event('prerender', function()
  if status_effects.is_initialized then
    status_effects:update()

    if status_effects.current_tick == remove_tick_target then
      status_effects:remove_all_non_party_buffs()
    end
  end
end)

windower.register_event('incoming chunk', function(id, original, modified, injected, blocked)
  if id == 0x01D then -- complete load
    local info = windower.ffxi.get_info()
    status_effects.current_zone = (info.mog_house and -1) or windower.ffxi.get_info().zone
    status_effects:update_target_zone(windower.ffxi.get_player().id, status_effects.current_zone)
    -- need to delay removing all buffs
    remove_tick_target = status_effects.current_tick + 30
  end
end)

windower.register_event('incoming chunk', function(id, data)
  if status_effects.is_initialized then
    if id == 0x028 then
      local packet = windower.packets.parse_action(data)
      status_effects:handle_action(packet)
    end
  end
end)

windower.register_event('incoming chunk', function(id, data)
  if status_effects.is_initialized then
    if id == 0x029 then
      local xcdata = {}
      xcdata.target_id = data:unpack('I', 0x09)
      xcdata.buff_id = data:unpack('I', 0x0D)
      xcdata.message_id = data:unpack('H', 0x19) % 32768

      status_effects:handle_action_message(xcdata)
    end
  end
end)

-- Debugging to discover packet structure
local function hex_dump(data)
  local bytes_per_row = 16
  local hex_str = ""

  for i = 1, #data do
    -- Print the byte as a 2-digit hex value
    local byte = string.byte(data, i)
    hex_str = hex_str .. string.format("%02X ", byte)

    -- Add spacing between groups of 8 bytes for readability
    if i % 8 == 0 then
      hex_str = hex_str .. " "
    end

    -- New line after every row
    if i % bytes_per_row == 0 then
      windower.add_to_chat(8, string.format("%04X  %s", i - bytes_per_row, hex_str))
      hex_str = ""
    end
  end

  -- Print any remaining bytes in the last row
  if #hex_str > 0 then
    windower.add_to_chat(8, string.format("%04X  %s", #data - (#data % bytes_per_row), hex_str))
  end
end

-- Debugging to discover packet structure
local function print_bit_region(data, start_offset, length)
  print("Offset   Hex    Binary")
  for i = 0, length - 1 do
    local byte = string.byte(data, start_offset + i)
    local bits = ""
    for bit_index = 7, 0, -1 do -- Convert byte to binary representation
      bits = bits .. tostring(bit.band(byte, bit.lshift(1, bit_index)) ~= 0 and 1 or 0)
    end
    print(string.format("0x%02X     %02X     %s", start_offset + i - 1, byte, bits))
  end
end

local function get_buff_data_from_packet(data, buff_start_offset, bitmask_offset, indi_buff_offset)
  local buffs = {}

  -- Read and process buffs using unpack('C') for unsigned 8-bit integers
  for i = 0, 31 do
    local buff = data:unpack('C', buff_start_offset + i) -- Direct unpacking
    if buff and buff ~= 0 and buff ~= 255 then           -- Skip if 0 or 255 ("no buff")
      local mask_index = math.floor(i / 4)
      local shift = (i % 4) * 2
      local bitmask_byte = data:unpack('C', bitmask_offset + mask_index) or 0
      local mask_value = bit.band(bit.rshift(bitmask_byte, shift), 0x03)

      -- Adjust buff using the bitmask
      local adjusted_buff = buff + (mask_value * 256)
      table.insert(buffs, adjusted_buff)
    end
  end

  -- Extract the Indi Buff using unpack('b7')
  local indi_buff = data:unpack('b7', indi_buff_offset) -- Read 7 bits directly at offset 0x58

  -- Add the Indi Buff if it exists
  if indi_buff ~= 0 then
    table.insert(buffs, indi_buff)
  end

  return buffs
end

-- Player and Party packets are special and we can straight-up read the buffs from them
-- instead of parsing the combat log -- very very nifty.
windower.register_event('incoming chunk', function(id, data)
  if status_effects.is_initialized then
    if id == 0x037 then
      local buffs = get_buff_data_from_packet(data, 0x04 + 1, 0x4C + 1, 0x58 + 1)
      local player = windower.ffxi.get_player()

      status_effects:add_buffs_raw(player.id, buffs)

      -- windower.add_to_chat(8, 'Player buffs')
      -- printTable(buffs)
    elseif id == 0x076 then
      local buffs = get_buff_data_from_packet(data, 0x14 + 1, 0x0C + 1, 0x58 + 1)
      local id = data:unpack('I', 0x05)

      status_effects:add_buffs_raw(id, buffs)

      -- windower.add_to_chat(8, 'PC buffs')
      -- printTable(buffs)
    end
  end
end)



function printTable(tbl, indent)
  indent = indent or 0
  local indentString = string.rep("  ", indent)

  for key, value in pairs(tbl) do
    if type(value) == "table" then
      windower.add_to_chat(8, indentString .. tostring(key) .. ":")
      printTable(value, indent + 1)
    else
      windower.add_to_chat(8, indentString .. tostring(key) .. ": " .. tostring(value))
    end
  end
end

return status_effects
