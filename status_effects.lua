status_effects = {
  is_initialized = false,

  -- this will be by target id, for now
  buffs = {}
}

function status_effects:initialize()
  self.is_initialized = true
end

function status_effects:update()
  for _, target_buffs in pairs(self.buffs) do
    for buff_id, buff in pairs(target_buffs) do
      buff.remaining_time = buff.end_time - os.clock()
      if buff.remaining_time <= 0 then
        target_buffs[buff_id] = nil -- Remove expired buff
        --print('Removed buff with ID: ' .. tostring(buff_id))
      end
    end
  end
end

function status_effects:handle_action(data)
  local message_id = data.targets[1].actions[1].message

  --print('action=' .. message_id)

  if message_id == 2       -- cast and deal damage
      or message_id == 252 -- cast and magic burst
      or message_id == 230 -- cast and gain status defensive
      or message_id == 236 -- cast and gain status offensive
      or message_id == 237 -- cast and gain status generic
      or message_id == 268 -- cast and magic burst plus status
      or message_id == 271 -- cast and magic burst plus status
  then
    -- magic spell
    --print('capturing')

    local spell_id = data.param
    local buff_id = res.spells[spell_id].status or data.targets[1].actions[1].param
    local actor_id = data.actor_id

    --print(spell_id .. ' into ' .. buff_id)

    if buff_id then
      for _, target in pairs(data.targets) do
        local target_id = target.id
        --print('gain via action -- ' .. target_id)
        self:add_buff(target_id, spell_id, buff_id)
      end
    end
  else
    --print('did not capture ' .. message_id)
  end
end

function status_effects:handle_action_message(data)
  print('action_message=' .. data.message_id)

  if data.message_id == 203     -- gains status
      or data.message_id == 205 -- gains status
  then
    print('gain via action message')
  elseif data.message_id == 204 -- wears off
      or data.message_id == 206 -- wears off
  then
    print('lose via action message')
    self:remove_buff(data.target_id, data.buff_id)
  end
end

function status_effects:add_buff(target_id, spell_id, buff_id)
  local spell = res.spells[spell_id]
  if spell and spell.duration then
    -- first, delete any overwrites
    if spell.overwrites then
      for _, overwritten_id in pairs(spell.overwrites) do
        print(overwritten_id)
        self:remove_buff_given_by_spell(target_id, overwritten_id)
      end
    end

    -- prepare for new buff
    if not self.buffs[target_id] then
      self.buffs[target_id] = {}
    end

    -- then create the new buff
    self.buffs[target_id][buff_id] = {
      end_time = os.clock() + spell.duration,
      originating_spell_id = spell_id
    }
  else
    --print('Invalid spell or missing duration for spell ID: ' .. tostring(spell_id))
  end
end

function status_effects:remove_buff_given_by_spell(target_id, spell_id)
  if not self.buffs[target_id] then
    return
  end

  for buff_id, buff in pairs(self.buffs[target_id]) do
    if buff.originating_spell_id == spell_id then
      self:remove_buff(target_id, buff_id)
    end
  end
end

function status_effects:remove_buff(target_id, buff_id)
  if not self.buffs[target_id] then
    return
  end

  if self.buffs[target_id][buff_id] then
    self.buffs[target_id][buff_id] = nil
    --print("Removed buff ID: " .. tostring(buff_id) .. " from target ID: " .. tostring(target_id))

    -- Clean up target entry if it's empty
    if next(self.buffs[target_id]) == nil then
      self.buffs[target_id] = nil
    end
  else
    --print("Buff ID: " .. tostring(buff_id) .. " not found for target ID: " .. tostring(target_id))
  end
end

function status_effects:get_buffs_for_target(target_id)
  return self.buffs[target_id]
end

windower.register_event('prerender', function()
  if status_effects.is_initialized then
    status_effects:update()
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

return status_effects
