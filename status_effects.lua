status_effects = {
  is_initialized = false,

  -- this will be by target id, for now
  buffs = {},

  -- we track what zone a buff was applied in, because many buffs fall off when zoning
  current_zone = -1,

  -- lookup table for a target id and the last known zone they were in -- a change here will remove their ja buffs
  target_zone = {},

  -- lookup table for a player name to an id, because their id is lost when the are in a different zone.
  party_player_ids = {},

  current_tick = 1,
}

function status_effects:initialize()
  self.is_initialized = true
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

    -- Clean up empty target entry
    if next(target_buffs) == nil then
      self.buffs[target_id] = nil
    end
  end

  -- check party / alliance zones every few seconds to keep them up-to-date and
  -- purge buffs that fall off across zones

  if self.current_tick % 120 then
    if self.current_tick % 120000 then
      -- reset the list once an hour or so
      self.party_player_ids = {}
    end

    local party = windower.ffxi.get_party()
    if party ~= nil then
      for _, key in ipairs({ 'p1', 'p2', 'p3', 'p4', 'p5', 'a10', 'a11', 'a12', 'a13', 'a14', 'a15', 'a20', 'a21', 'a22', 'a23', 'a24', 'a25' })
      do
        local party_member = party[key]
        if party_member ~= nil then
          -- update id mapping
          if party_member.mob then
            self.party_player_ids[party_member.name] = party_member.mob.id
          end

          -- update zone
          self:update_target_zone(self:get_id_from_player_name(party_member.name), party_member.zone)
        end
      end
    end
  end

  self.current_tick = self.current_tick + 1
end

function status_effects:handle_action(data)
  -- local message_id = data.targets[1].actions[1].message

  local actor_id = data.actor_id

  if data.targets then
    local source = 'UNKNOWN' -- UNKNOWN, MAGIC, ABILITY, WEASPONSKILL

    for _, target in pairs(data.targets) do
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
              self:add_buff(target.id, source, spell_id, buff_id, type, actor_id)
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
              self:add_buff(target.id, source, ability_id, buff_id, type, actor_id)
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
                  self:add_buff(target_id, source, ability_id, single_buff_id, type, actor_id)
                end
              end
            else
              -- It is not a damage event, so the buff should come across in the chat message.
              local buff_id_parsed = action.param
              local target_id = target.id
              if buff_id_parsed and buff_id_parsed ~= 0 then
                --print('ws explicit gain via action ' ..
                --  message_id .. ': ' .. ability_id .. '-- ' .. buff_id_parsed .. ' -> ' .. target_id)
                self:add_buff(target_id, source, ability_id, buff_id_parsed, type, actor_id)
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
            self:add_buff_pup(target.id, nil, 299)

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
                  self:add_buff(target_id, source, source_id, single_buff_id, type, actor_id)
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
              self:add_buff(target.id, source, source_id, buff_id, type, actor_id)
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

  if data.message_id == 6       -- x defeats target
      or data.message_id == 20  -- target falls to the ground
      or data.message_id == 113 -- target falls to the ground after ma
      or data.message_id == 406 -- target falls to the ground after ws
      or data.message_id == 605 -- target falls to the ground after additional effect
      or data.message_id == 646 -- target falls to the ground after ja
  then
    debug_print('death detected for ' .. data.target_id)
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

function status_effects:add_buff(target_id, source_type, source_id, buff_id, type, actor_id)
  if source_type == 'MAGIC' then
    self:add_buff_ma(target_id, source_id, buff_id, type, actor_id)
  elseif source_type == 'ABILITY' then
    self:add_buff_ja(target_id, source_id, buff_id, type, actor_id)
  elseif source_type == 'WEAPONSKILL' then
    self:add_buff_ws(target_id, source_id, buff_id, type, actor_id)
  end

  -- update target last known zone
  self:update_target_zone(target_id, self.current_zone)
end

function status_effects:get_known_duration(spell_id)
  if spell_id == 112 then
    return 6
  elseif spell_id == 136 then
    return 600
  elseif spell_id == 137 then
    return 600
  elseif spell_id == 138 then
    return 600
  end
end

function status_effects:add_buff_ma(target_id, spell_id, buff_id, type, actor_id)
  local spell = res.spells[spell_id]
  local duration = spell.duration or self:get_known_duration(spell_id) or 60

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
    --   2. max songs on a target from a specific player is either 2 for a main job bard with an instrument equipped, or 1 for eitehr a sub job bard or a main job bard with no instrument.
    --   3. max rolls on a target from a specific player is eitehr 2 for a main job corsair or 1 for a sub job corsair.
    --   4. when a new song is sung and the specific bard has used up its slots, then if the new song is the same as an existing song, just update the existing song duration, but if its a new song, replace the song with the lowest duration.
    --      however, if a new song is sung and the target has used its 12 combined song/roll slots, the the oldest one is replaced unless a song is being "refreshed" in duration
    if type == 'BardSong' then
      local bard_id = actor_id
      local target_buffs = self.buffs[target_id]

      -- Count songs/rolls
      local total_songs_rolls = 0
      local bard_songs = {}

      for b_id, spell_table in pairs(target_buffs) do
        for c_id, buff in pairs(spell_table) do
          if buff.type == 'BardSong' or buff.type == 'CorsairRoll' then
            total_songs_rolls = total_songs_rolls + 1
            if buff.actor_id == bard_id and buff.type == 'BardSong' then
              table.insert(bard_songs, { buff_id = b_id, composite_id = c_id, duration = buff.end_time - os.clock() })
            end
          end
        end
      end

      -- Determine max songs allowed for this bard
      local max_songs = self:get_max_songs_for_actor(actor_id)

      -- Check if the song already exists and can just be refreshed
      for _, song in ipairs(bard_songs) do
        if song.buff_id == buff_id and song.composite_id == composite_key then
          -- Refresh the duration
          self.buffs[target_id][buff_id][composite_key].end_time = os.clock() + duration
          return -- Stop here since we just refreshed
        end
      end

      -- If bard has reached max songs
      if #bard_songs >= max_songs then
        -- Find the shortest duration song
        table.sort(bard_songs, function(a, b) return a.duration < b.duration end)
        local shortest_song = bard_songs[1]
        self.buffs[target_id][shortest_song.buff_id][shortest_song.composite_id] = nil -- Replace it

        -- Clean up if the spell table is empty
        if next(self.buffs[target_id][shortest_song.buff_id]) == nil then
          self.buffs[target_id][shortest_song.buff_id] = nil
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
      buff_id = buff_id,
      end_time = os.clock() + duration,
      originating_spell = spell.en,
      originating_id = composite_key,
      actor_id = actor_id,
      target_id = target_id,
      type = type,
      category = buff_types[buff_id] or "",
    }
  end
end

function status_effects:add_buff_ws(target_id, ability_id, buff_id, type, actor_id)
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
      buff_id = buff_id,
      end_time = os.clock() + ability.duration,
      originating_spell = ability.en,
      originating_id = composite_key,
      actor_id = actor_id,
      target_id = target_id,
      type = type,
      category = buff_types[buff_id] or ""
    }
  end
end

function status_effects:add_buff_ja(target_id, ability_id, buff_id, type, actor_id)
  local ability = res.job_abilities[ability_id]
  if ability and ability.duration then
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


    -- Ensure the table structure exists
    if not self.buffs[target_id] then
      self.buffs[target_id] = {}
    end
    if not self.buffs[target_id][buff_id] then
      self.buffs[target_id][buff_id] = {}
    end

    -- Add the new buff
    self.buffs[target_id][buff_id][composite_key] = {
      buff_id = buff_id,
      end_time = os.clock() + ability.duration,
      originating_spell = ability.en,
      originating_id = composite_key,
      actor_id = actor_id,
      target_id = target_id,
      type = type,
      category = buff_types[buff_id] or ""
    }
  end
end

function status_effects:add_buff_pup(target_id, ability_id, buff_id)
  if ability_id == nil then
    -- Prepare composite key
    local composite_key = 'ja:' .. ability_id

    -- overloaded status
    -- remove all maneuvers
    for _, overwritten_id in pairs({ 141, 142, 143, 144, 145, 146, 147, 148 }) do
      self:remove_buff_given_by_id(target_id, 'ja:' .. overwritten_id)
    end

    -- add overloaded
    if not self.buffs[target_id] then
      self.buffs[target_id] = {}
    end
    if not self.buffs[target_id][buff_id][0] then
      self.buffs[target_id][buff_id] = {}
    end

    self.buffs[target_id][buff_id][composite_key] = {
      buff_id = buff_id,
      end_time = os.clock() + 60,
      originating_spell = 'Maneuver',
      originating_id = composite_key,
      actor_id = target_id,
      target_id = target_id,
      type = 'Maneuver',
      category = buff_types[buff_id] or ""
    }
  end
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

-- either removes all buffs matching an id, or only the oldest
function status_effects:remove_buff_with_priority(target_id, buff_id, remove_all)
  if not self.buffs[target_id] then
    return
  end

  if not buff_id then
    -- If no buff_id is provided, remove all buffs for the target
    self.buffs[target_id] = nil
  elseif remove_all then
    -- If remove_all is true, remove all buffs of the given buff_id
    if self.buffs[target_id][buff_id] then
      self.buffs[target_id][buff_id] = nil
    end
  else
    -- Remove only the "oldest" buff (based on the smallest end_time)
    if self.buffs[target_id][buff_id] then
      local oldest_composite_key, oldest_end_time = nil, math.huge

      -- Find the buff with the smallest end_time
      for composite_key, buff_data in pairs(self.buffs[target_id][buff_id]) do
        if buff_data.end_time < oldest_end_time then
          oldest_composite_key = composite_key
          oldest_end_time = buff_data.end_time
        end
      end

      -- Remove the oldest buff if found
      if oldest_composite_key then
        self.buffs[target_id][buff_id][oldest_composite_key] = nil
      end

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

-- this removes every buff from everyone other than the player and the party, used
-- when zoning to reset the buff table since we don't know what is happening after
-- we zone out
function status_effects:remove_all_non_party_buffs()
  -- Fetch the current player ID
  local player_id = windower.ffxi.get_player().id

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

windower.register_event('prerender', function()
  if status_effects.is_initialized then
    status_effects:update()
  end
end)

windower.register_event('incoming chunk', function(id, original, modified, injected, blocked)
  if id == 0x01D then -- complete load
    local info = windower.ffxi.get_info()
    status_effects.current_zone = (info.mog_house and -1) or windower.ffxi.get_info().zone
    status_effects:update_target_zone(windower.ffxi.get_player().id, status_effects.current_zone)
    status_effects:remove_all_non_party_buffs()
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
