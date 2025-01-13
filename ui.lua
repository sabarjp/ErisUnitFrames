local grouper = require("component_group")

-- singleton table-style global
ui = {
  -- whether the whole ui is visible or not
  isVisible = true,
  isCreated = false,

  config = {},

  player = {
    group = {},
    text = {},
    health_bar = {},
    magic_bar = {},
    tp_bar = {}
  },

  pet = {
    group = {},
    text = {},
    health_bar = {},
    magic_bar = {},
    tp_bar = {}
  },

  target = {
    group = {},
    text = {},
    health_bar = {},
    locked_text = {}
  },

  sub_target = {
    group = {},
    text = {},
    health_bar = {}
  },

  battle_target = {
    group = {},
    text = {}
  },

  party = {
    p1 = {},
    p2 = {},
    p3 = {},
    p4 = {},
    p5 = {}
  },

  alliance = {
    a10 = {},
    a11 = {},
    a12 = {},
    a13 = {},
    a14 = {},
    a15 = {},

    a20 = {},
    a21 = {},
    a22 = {},
    a23 = {},
    a24 = {},
    a25 = {}
  },

  action_handlers = {
    on_left_click = {},
    on_right_click = {}
  }
}

local alliance_range = { 10, 11, 12, 13, 14, 15, 20, 21, 22, 23, 24, 25 }

function ui:initialize(config)
  self.config = config
  self:create()
end

function ui:create()
  self:create_player()
  self:create_pet()
  self:create_target()
  self:create_sub_target()
  self:create_battle_target()
  self:create_party()
  self:create_alliance()

  self.isCreated = true
end

-- reads a standard configuration for a nameplate to
-- convert it into what a text object expects for creation
function ui:create_text_from_config(config_element, start_x, start_y)
  local config = {
    text = {
      font = config_element.text.font,
      alpha = config_element.text.alpha,
      red = config_element.text.red,
      green = config_element.text.green,
      blue = config_element.text.blue,
      stroke = {
        alpha = config_element.text.stroke.alpha,
        red = config_element.text.stroke.red,
        green = config_element.text.stroke.green,
        blue = config_element.text.stroke.blue,
        width = config_element.text.stroke.width
      }
    },
    bg = {
      visible = false,
    },
    pos = {
      x = start_x + config_element.rel_pos.x,
      y = start_y + config_element.rel_pos.y
    },
    flags = {
      draggable = false
    },
    status = {
      visible = false
    }
  }

  return config
end

-- reads a standard configuration for a bar to
-- convert it into what a bar object expects for creation
function ui:create_bar_from_config(config_element, start_x, start_y)
  local config = {
    x = start_x + config_element.rel_pos.x,
    y = start_y + config_element.rel_pos.y,
    width = config_element.width,
    height = config_element.height,
    text_color = {
      config_element.text.red,
      config_element.text.green,
      config_element.text.blue
    },
    text_alpha = config_element.text.alpha,
    text_size = config_element.text.size,
    text_font = config_element.text.font,
    text_right_align = config_element.text.right_aligned,
    text_offset = config_element.text.offset,
    foreground_color = {
      config_element.foreground.red,
      config_element.foreground.green,
      config_element.foreground.blue
    },
    foreground_alpha = config_element.foreground.alpha,
    background_color = {
      config_element.background.red,
      config_element.background.green,
      config_element.background.blue
    },
    background_alpha = config_element.background.alpha,
    left_right_color = {
      config_element.left_right_cap.red,
      config_element.left_right_cap.green,
      config_element.left_right_cap.blue
    },
    left_right_alpha = config_element.left_right_cap.alpha,
    texture_bar_left = self.config.texture.bar_left,
    texture_bar_right = self.config.texture.bar_right,
    texture_bar_foreground = self.config.texture.bar_foreground,
    texture_bar_background = self.config.texture.bar_background,
    disable_text = config_element.text.disabled,
    disable_foreground = config_element.foreground.disabled,
    disable_background = config_element.background.disabled
  }

  return config
end

function ui:create_player()
  local center_x = (windower.get_windower_settings().ui_x_res / 2)
  local center_y = (windower.get_windower_settings().ui_y_res / 2)

  local start_pos_x, start_pos_y

  start_pos_x = ((self.config.player.pos.relative_to == 'center') and (center_x + self.config.player.pos.x) or self.config.player.pos.x)
  start_pos_y = ((self.config.player.pos.relative_to == 'center') and (center_y + self.config.player.pos.y) or self.config.player.pos.y)


  self.player.text = texts.new(
    self:create_text_from_config(self.config.player.nameplate, start_pos_x, start_pos_y)
  )

  self.player.health_bar = bar:new(
    self:create_bar_from_config(self.config.player.health_bar, start_pos_x, start_pos_y)
  )

  self.player.magic_bar = bar:new(
    self:create_bar_from_config(self.config.player.magic_bar, start_pos_x, start_pos_y)
  )

  self.player.tp_bar = bar:new(
    self:create_bar_from_config(self.config.player.tp_bar, start_pos_x, start_pos_y)
  )

  self.player.group = grouper.create_component_group(
    grouper.flatten({
      { self.player.text },
      self.player.health_bar:components(),
      self.player.magic_bar:components(),
      self.player.tp_bar:components()
    })
  )

  if self.config.player.actions then
    for event, action in pairs(self.config.player.actions) do
      self:register_handler(event, action, self.player.group, '<me>')
    end
  end
end

function ui:create_pet()
  local center_x = (windower.get_windower_settings().ui_x_res / 2)
  local center_y = (windower.get_windower_settings().ui_y_res / 2)

  local start_pos_x, start_pos_y

  start_pos_x = ((self.config.pet.pos.relative_to == 'center') and (center_x + self.config.pet.pos.x) or self.config.pet.pos.x)
  start_pos_y = ((self.config.pet.pos.relative_to == 'center') and (center_y + self.config.pet.pos.y) or self.config.pet.pos.y)

  -- pet text
  self.pet.text = texts.new(
    self:create_text_from_config(self.config.pet.nameplate, start_pos_x, start_pos_y)
  )

  self.pet.health_bar = bar:new(
    self:create_bar_from_config(self.config.pet.health_bar, start_pos_x, start_pos_y)
  )

  self.pet.magic_bar = bar:new(
    self:create_bar_from_config(self.config.pet.magic_bar, start_pos_x, start_pos_y)
  )

  self.pet.tp_bar = bar:new(
    self:create_bar_from_config(self.config.pet.tp_bar, start_pos_x, start_pos_y)
  )

  self.pet.group = grouper.create_component_group(
    grouper.flatten({
      { self.pet.text },
      self.pet.health_bar:components(),
      self.pet.magic_bar:components(),
      self.pet.tp_bar:components()
    })
  )

  if self.config.pet.actions then
    for event, action in pairs(self.config.pet.actions) do
      self:register_handler(event, action, self.pet.group, '<pet>')
    end
  end
end

function ui:create_target()
  local center_x = (windower.get_windower_settings().ui_x_res / 2)
  local center_y = (windower.get_windower_settings().ui_y_res / 2)

  local start_pos_x, start_pos_y

  start_pos_x = ((self.config.target.pos.relative_to == 'center') and (center_x + self.config.target.pos.x) or self.config.target.pos.x)
  start_pos_y = ((self.config.target.pos.relative_to == 'center') and (center_y + self.config.target.pos.y) or self.config.target.pos.y)

  -- target text
  self.target.text = texts.new(
    self:create_text_from_config(self.config.target.nameplate, start_pos_x, start_pos_y)
  )

  self.target.health_bar = bar:new(
    self:create_bar_from_config(self.config.target.health_bar, start_pos_x, start_pos_y)
  )

  -- target lock text
  self.target.locked_text = texts.new(
    self:create_text_from_config(self.config.target.locked_text, start_pos_x, start_pos_y)
  )
  self.target.locked_text:text('> LOCKED <')

  self.target.group = grouper.create_component_group(
    grouper.flatten({
      { self.target.text },
      self.target.health_bar:components()
    })
  )

  if self.config.target.actions then
    for event, action in pairs(self.config.target.actions) do
      self:register_handler(event, action, self.target.group, '<t>')
    end
  end
end

function ui:create_sub_target()
  local center_x = (windower.get_windower_settings().ui_x_res / 2)
  local center_y = (windower.get_windower_settings().ui_y_res / 2)

  local start_pos_x, start_pos_y

  start_pos_x = ((self.config.sub_target.pos.relative_to == 'center') and (center_x + self.config.sub_target.pos.x) or self.config.sub_target.pos.x)
  start_pos_y = ((self.config.sub_target.pos.relative_to == 'center') and (center_y + self.config.sub_target.pos.y) or self.config.sub_target.pos.y)

  -- sub_target text
  self.sub_target.text = texts.new(
    self:create_text_from_config(self.config.sub_target.nameplate, start_pos_x, start_pos_y)
  )

  self.sub_target.health_bar = bar:new(
    self:create_bar_from_config(self.config.sub_target.health_bar, start_pos_x, start_pos_y)
  )

  self.sub_target.group = grouper.create_component_group(
    grouper.flatten({
      { self.sub_target.text },
      self.sub_target.health_bar:components()
    })
  )

  if self.config.sub_target.actions then
    for event, action in pairs(self.config.sub_target.actions) do
      self:register_handler(event, action, self.sub_target.group, '<st>')
    end
  end
end

function ui:create_battle_target()
  local center_x = (windower.get_windower_settings().ui_x_res / 2)
  local center_y = (windower.get_windower_settings().ui_y_res / 2)

  local start_pos_x, start_pos_y

  -- battle target text
  start_pos_x = ((self.config.battle_target.pos.relative_to == 'center') and (center_x + self.config.battle_target.pos.x) or self.config.battle_target.pos.x)
  start_pos_y = ((self.config.battle_target.pos.relative_to == 'center') and (center_y + self.config.battle_target.pos.y) or self.config.battle_target.pos.y)

  -- battle_target text
  self.battle_target.text = texts.new(
    self:create_text_from_config(self.config.battle_target.nameplate, start_pos_x, start_pos_y)
  )

  -- battle target action handlers
  self.battle_target.group = grouper.create_component_group(
    grouper.flatten({
      { self.battle_target.text },
    })
  )

  if self.config.battle_target.actions then
    for event, action in pairs(self.config.battle_target.actions) do
      self:register_handler(event, action, self.battle_target.group, '<bt>')
    end
  end
end

function ui:create_party()
  local center_x = (windower.get_windower_settings().ui_x_res / 2)
  local center_y = (windower.get_windower_settings().ui_y_res / 2)

  local start_pos_x, start_pos_y

  start_pos_x = ((self.config.party.pos.relative_to == 'center') and (center_x + self.config.party.pos.x) or self.config.party.pos.x)
  start_pos_y = ((self.config.party.pos.relative_to == 'center') and (center_y + self.config.party.pos.y) or self.config.party.pos.y)

  for i = 1, 5, 1 do
    local key = 'p' .. i
    local party_pos_x = start_pos_x + ((i - 1) * self.config.party.pos.offset_x)
    local party_pos_y = start_pos_y + ((i - 1) * self.config.party.pos.offset_y)

    self.party[key].text = texts.new(
      self:create_text_from_config(self.config.party.nameplate, party_pos_x, party_pos_y)
    )

    self.party[key].health_bar = bar:new(
      self:create_bar_from_config(self.config.party.health_bar, party_pos_x, party_pos_y)
    )

    self.party[key].magic_bar = bar:new(
      self:create_bar_from_config(self.config.party.magic_bar, party_pos_x, party_pos_y)
    )

    self.party[key].tp_bar = bar:new(
      self:create_bar_from_config(self.config.party.tp_bar, party_pos_x, party_pos_y)
    )

    self.party[key].group = grouper.create_component_group(
      grouper.flatten({
        { self.party[key].text },
        self.party[key].health_bar:components(),
        self.party[key].magic_bar:components(),
        self.party[key].tp_bar:components()
      })
    )

    if self.config.party.actions then
      for event, action in pairs(self.config.party.actions) do
        self:register_handler(event, action, self.party[key].group, '<' .. key .. '>')
      end
    end
  end
end

function ui:create_alliance()
  local center_x = (windower.get_windower_settings().ui_x_res / 2)
  local center_y = (windower.get_windower_settings().ui_y_res / 2)

  local start_pos_x, start_pos_y

  start_pos_x = ((self.config.alliance.pos.relative_to == 'center') and (center_x + self.config.alliance.pos.x) or self.config.alliance.pos.x)
  start_pos_y = ((self.config.alliance.pos.relative_to == 'center') and (center_y + self.config.alliance.pos.y) or self.config.alliance.pos.y)

  local n = 1
  for _, i in ipairs(alliance_range) do
    local key = 'a' .. i

    -- Calculate group number and local offset within the group
    local group_number = math.floor((n - 1) / self.config.alliance.pos.grouping)
    local local_index = (n - 1) % self.config.alliance.pos.grouping

    -- Adjust positions based on group and offset
    local alliance_pos_x = start_pos_x
        + (local_index * self.config.alliance.pos.offset_x)
        + (group_number * self.config.alliance.pos.grouping_x)

    local alliance_pos_y = start_pos_y
        + (local_index * self.config.alliance.pos.offset_y)
        + (group_number * self.config.alliance.pos.grouping_y)

    -- local alliance_pos_x = start_pos_x + ((n - 1) * self.config.alliance.pos.offset_x)
    -- local alliance_pos_y = start_pos_y + ((n - 1) * self.config.alliance.pos.offset_y)

    self.alliance[key].text = texts.new(
      self:create_text_from_config(self.config.alliance.nameplate, alliance_pos_x, alliance_pos_y)
    )

    self.alliance[key].health_bar = bar:new(
      self:create_bar_from_config(self.config.alliance.health_bar, alliance_pos_x, alliance_pos_y)
    )

    self.alliance[key].magic_bar = bar:new(
      self:create_bar_from_config(self.config.alliance.magic_bar, alliance_pos_x, alliance_pos_y)
    )

    self.alliance[key].tp_bar = bar:new(
      self:create_bar_from_config(self.config.alliance.tp_bar, alliance_pos_x, alliance_pos_y)
    )

    self.alliance[key].group = grouper.create_component_group(
      grouper.flatten({
        { self.alliance[key].text },
        self.alliance[key].health_bar:components(),
        self.alliance[key].magic_bar:components(),
        self.alliance[key].tp_bar:components()
      })
    )

    if self.config.alliance.actions then
      for event, action in pairs(self.config.alliance.actions) do
        self:register_handler(event, action, self.alliance[key].group, '<' .. key .. '>')
      end
    end

    n = n + 1
  end
end

function ui:register_handler(event, action, group_object, target)
  local actual_action = action:gsub("%%this", target)
  self.action_handlers[event][group_object] = actual_action
end

function ui:show()
  self.isVisible = true
  -- no need to actually show all items since the gui loop will do it next tick
end

function ui:hide()
  self.isVisible = false

  self.player.text:hide()
  self.player.health_bar:hide()
  self.player.magic_bar:hide()
  self.player.tp_bar:hide()

  self.target.text:hide()
  self.target.health_bar:hide()
  self.target.locked_text:hide()

  self.sub_target.text:hide()
  self.sub_target.health_bar:hide()

  self.pet.text:hide()
  self.pet.health_bar:hide()
  self.pet.magic_bar:hide()
  self.pet.tp_bar:hide()

  self.battle_target.text:hide()

  for i = 1, 5, 1 do
    local key = 'p' .. i
    self.party[key].text:hide()
    self.party[key].health_bar:hide()
    self.party[key].magic_bar:hide()
    self.party[key].tp_bar:hide()
  end

  for _, i in ipairs(alliance_range) do
    local key = 'a' .. i
    self.alliance[key].text:hide()
    self.alliance[key].health_bar:hide()
    self.alliance[key].magic_bar:hide()
    self.alliance[key].tp_bar:hide()
  end
end

--- helpers
---
local function is_claimed_by_you(claim_id)
  if tostring(windower.ffxi.get_player().id) == tostring(claim_id) then
    return true
  else
    for i = 1, 5, 1 do
      local party_member = windower.ffxi.get_mob_by_target('p' .. i)
      if party_member ~= nil and tostring(party_member.id) == tostring(claim_id) then
        return true
      end
    end
  end
  return false
end

local function get_text_color_from_mob(mob_data)
  if mob_data == nil then
    return 255, 255, 255
  end

  local pet = windower.ffxi.get_mob_by_target('pet') or nil
  if pet ~= nil then
    if mob_data.id == pet.id then
      return 195, 255, 255
    end
  end

  if mob_data.id == windower.ffxi.get_player().id then
    return 255, 255, 255
  elseif mob_data.hpp == 0 then
    return 188, 188, 188
  elseif mob_data.in_party == true then
    return 195, 255, 255
  elseif mob_data.in_alliance == true then
    return 211, 255, 255
  elseif mob_data.is_npc == true then
    if mob_data.spawn_type == 2 then
      -- npc
      return 193, 254, 193
    elseif mob_data.spawn_type == 34 then
      -- interactive object
      return 193, 254, 193
    else
      -- monster of some kind
      if mob_data.claim_id ~= 0 then
        if is_claimed_by_you(mob_data.claim_id) == true then
          return 244, 124, 124
        else
          return 255, 130, 255
        end
      else
        -- normal unclaimed mob
        return 255, 255, 194
      end
    end
  else
    return 255, 255, 255
  end
end

local function get_hp_text_color(hpp)
  if hpp < 25 then
    return { 255, 25, 0 }
  elseif hpp < 50 then
    return { 255, 127, 0 }
  elseif hpp < 75 then
    return { 255, 216, 0 }
  else
    return { 255, 255, 255 }
  end
end

local function get_name_and_type_from_mob(mob_data)
  if mob_data == nil then
    return ''
  end

  local type_text = nil

  local pet = windower.ffxi.get_mob_by_target('pet') or nil
  if pet ~= nil and mob_data.id == pet.id then
    type_text = 'pet'
  elseif mob_data.id == windower.ffxi.get_player().id then
    type_text = 'you'
  elseif mob_data.hpp == 0 then
    type_text = 'dead'
  elseif mob_data.in_party == true then
    type_text = 'party'
  elseif mob_data.in_alliance == true then
    type_text = 'ally'
  elseif mob_data.is_npc == true then
    if mob_data.spawn_type == 2 then
      -- npc
      type_text = 'npc'
    elseif mob_data.spawn_type == 34 then
      -- interactive object
      type_text = 'obj'
    else
      -- monster of some kind
      if mob_data.claim_id ~= 0 then
        if is_claimed_by_you(mob_data.claim_id) == true then
          type_text = 'claim'
        else
          type_text = 'o.claim'
        end
      else
        -- normal unclaimed mob
        type_text = 'mob'
      end
    end
  else
    type_text = 'pc'
  end

  local name_text = mob_data.name
  if type_text ~= nil then
    name_text = mob_data.name .. ' (' .. type_text .. ')'
  end
  return name_text
end

function ui:update_player()
  local player = windower.ffxi.get_player()
  local should_show = false
  local size_state_changed = false

  -- Helper function to update visibility and detect changes
  local function set_visibility(element, is_disabled)
    local current_state = element:visible()
    local new_state = not is_disabled and should_show

    if current_state ~= new_state then
      size_state_changed = true
      if new_state then
        element:show()
      else
        element:hide()
      end
    end
  end

  if player ~= nil and not self.config.player.disabled then
    if self.config.player.only_show_in_combat == false or (self.config.player.only_show_in_combat == true and player.in_combat == true) then
      self:update_player_frame(player)
      should_show = true
    end
  end

  -- update visibility as needed
  set_visibility(self.player.text, self.config.player.nameplate.disabled)
  set_visibility(self.player.health_bar, self.config.player.health_bar.disabled)
  set_visibility(self.player.magic_bar, self.config.player.magic_bar.disabled)
  set_visibility(self.player.tp_bar, self.config.player.tp_bar.disabled)

  if size_state_changed then
    self.player.group:calculate_bounding_box(0.1)
  end
end

function ui:update_player_frame(player)
  if player.name ~= self.player.text:text() then
    self.player.text:text(player.name)
    self.player.group:calculate_bounding_box(2.0)
  end

  -- set bar size and text
  self.player.health_bar:text(tostring(player.vitals.hp))
  self.player.health_bar:text_color(unpack(get_hp_text_color(player.vitals.hpp)))
  self.player.health_bar:fill(player.vitals.hpp / 100)

  self.player.magic_bar:text(tostring(player.vitals.mp))
  self.player.magic_bar:fill(player.vitals.mpp / 100)

  self.player.tp_bar:text(tostring(player.vitals.tp))
  self.player.tp_bar:fill(math.min(1000, player.vitals.tp) / 1000)

  if player.vitals.tp >= 1000 then
    self.player.tp_bar:color(self.config.player.tp_bar.foreground.full_red,
      self.config.player.tp_bar.foreground.full_green,
      self.config
      .player.tp_bar.foreground.full_blue)
  else
    self.player.tp_bar:color(self.config.player.tp_bar.foreground.red, self.config.player.tp_bar.foreground.green,
      self.config
      .player.tp_bar.foreground.blue)
  end
end

function ui:update_pet()
  local player = windower.ffxi.get_player()
  local pet = windower.ffxi.get_mob_by_target('pet')
  local should_show = false
  local size_state_changed = false

  -- Helper function to update visibility and detect changes
  local function set_visibility(element, is_disabled)
    local current_state = element:visible()
    local new_state = not is_disabled and should_show

    if current_state ~= new_state then
      size_state_changed = true
      if new_state then
        element:show()
      else
        element:hide()
      end
    end
  end

  if pet ~= nil and not self.config.pet.disabled then
    if self.config.pet.only_show_in_combat == false or (self.config.pet.only_show_in_combat == true and player.in_combat == true) then
      self:update_pet_frame(pet)
      should_show = true
    end
  end

  -- update visibility as needed
  set_visibility(self.pet.text, self.config.pet.nameplate.disabled)
  set_visibility(self.pet.health_bar, self.config.pet.health_bar.disabled)
  set_visibility(self.pet.magic_bar, self.config.pet.magic_bar.disabled or self.pet.tp_bar.missing_bar_data)
  set_visibility(self.pet.tp_bar, self.config.pet.tp_bar.disabled or self.pet.tp_bar.missing_bar_data)

  if size_state_changed then
    self.pet.group:calculate_bounding_box(0.1)
  end
end

function ui:update_pet_frame(pet, mpp, tp)
  local player = windower.ffxi.get_player()
  if pet ~= nil then
    if pet.name ~= self.pet.text:text() then
      self.pet.text:text(pet.name)
      self.pet.group:calculate_bounding_box(2.0)
    end

    -- set bar size and text
    self.pet.health_bar:text(tostring(pet.hpp) .. '%')
    self.pet.health_bar:text_color(unpack(get_hp_text_color(pet.hpp)))
    self.pet.health_bar:fill(pet.hpp / 100)
  end

  if mpp ~= nil then
    self.pet.magic_bar:text(tostring(mpp) .. '%')
    self.pet.magic_bar:fill(mpp / 100)
  end

  if tp ~= nil then
    self.pet.tp_bar.last_known_tp = tp
    self.pet.tp_bar:text(tostring(tp))
    self.pet.tp_bar:fill(math.min(1000, tp) / 1000)
  end

  if self.pet.tp_bar.last_known_tp then
    self.pet.tp_bar.missing_bar_data = false
    if self.pet.tp_bar.last_known_tp >= 1000 then
      self.pet.tp_bar:color(self.config.pet.tp_bar.foreground.full_red,
        self.config.pet.tp_bar.foreground.full_green,
        self.config
        .pet.tp_bar.foreground.full_blue)
    else
      self.pet.tp_bar:color(self.config.pet.tp_bar.foreground.red, self.config.pet.tp_bar.foreground.green,
        self.config
        .pet.tp_bar.foreground.blue)
    end
  else
    self.pet.tp_bar.missing_bar_data = true
  end
end

function ui:update_target()
  local player = windower.ffxi.get_player()
  local target = windower.ffxi.get_mob_by_target('t')
  local should_show = false
  local size_state_changed = false

  -- Helper function to update visibility and detect changes
  local function set_visibility(element, is_disabled)
    local current_state = element:visible()
    local new_state = not is_disabled and should_show

    if current_state ~= new_state then
      size_state_changed = true
      if new_state then
        element:show()
      else
        element:hide()
      end
    end
  end

  if target ~= nil and not self.config.target.disabled then
    if self.config.target.only_show_in_combat == false or (self.config.target.only_show_in_combat == true and player.in_combat == true) then
      local r, g, b = get_text_color_from_mob(target)

      if self.target.text:text() ~= get_name_and_type_from_mob(target) then
        self.target.text:text(get_name_and_type_from_mob(target))
        size_state_changed = true
      end

      if self.config.target.nameplate.text.use_dynamic_colors then
        self.target.text:color(r, g, b)
      end

      if self.config.target.health_bar.foreground.use_dynamic_colors then
        self.target.health_bar:color(r, g, b)
      end

      -- set bar size and text
      self.target.health_bar:text(tostring(target.hpp) .. '%')
      self.target.health_bar:text_color(unpack(get_hp_text_color(target.hpp)))
      self.target.health_bar:fill(target.hpp / 100)

      -- locked text
      if (not self.config.target.locked_text.disabled) and windower.ffxi.get_player().target_locked == true then
        self.target.locked_text:show()
      else
        self.target.locked_text:hide()
      end

      should_show = true
    end
  end

  -- update visibility as needed
  set_visibility(self.target.text, self.config.target.nameplate.disabled)
  set_visibility(self.target.health_bar, self.config.target.health_bar.disabled)

  if size_state_changed then
    self.target.group:calculate_bounding_box(0.1)
  end
end

function ui:update_sub_target()
  local player = windower.ffxi.get_player()
  local sub_target = windower.ffxi.get_mob_by_target('st')
  local should_show = false
  local size_state_changed = false

  -- Helper function to update visibility and detect changes
  local function set_visibility(element, is_disabled)
    local current_state = element:visible()
    local new_state = not is_disabled and should_show

    if current_state ~= new_state then
      size_state_changed = true
      if new_state then
        element:show()
      else
        element:hide()
      end
    end
  end

  if sub_target ~= nil and not self.config.sub_target.disabled then
    if self.config.sub_target.only_show_in_combat == false or (self.config.sub_target.only_show_in_combat == true and player.in_combat == true) then
      local r, g, b = get_text_color_from_mob(sub_target)

      local name = get_name_and_type_from_mob(sub_target)
      local filled_name = 'ST >> ' .. name
      if self.sub_target.text:text() ~= filled_name then
        self.sub_target.text:text(filled_name)
        size_state_changed = true
      end

      if self.config.sub_target.nameplate.text.use_dynamic_colors then
        self.sub_target.text:color(r, g, b)
      end

      if self.config.sub_target.health_bar.foreground.use_dynamic_colors then
        self.sub_target.health_bar:color(r, g, b)
      end

      -- set bar size and text
      self.sub_target.health_bar:text(tostring(sub_target.hpp) .. '%')
      self.sub_target.health_bar:text_color(unpack(get_hp_text_color(sub_target.hpp)))
      self.sub_target.health_bar:fill(sub_target.hpp / 100)

      should_show = true
    end
  end

  -- update visibility as needed
  set_visibility(self.sub_target.text, self.config.sub_target.nameplate.disabled)
  set_visibility(self.sub_target.health_bar, self.config.sub_target.health_bar.disabled)

  if size_state_changed then
    self.sub_target.group:calculate_bounding_box(0.1)
  end
end

function ui:update_battle_target()
  local target = windower.ffxi.get_mob_by_target('t')
  local battle_target = windower.ffxi.get_mob_by_target('bt')
  local should_show = false
  local size_state_changed = false

  -- Helper function to update visibility and detect changes
  local function set_visibility(element, is_disabled)
    local current_state = element:visible()
    local new_state = not is_disabled and should_show

    if current_state ~= new_state then
      size_state_changed = true
      if new_state then
        element:show()
      else
        element:hide()
      end
    end
  end

  if battle_target ~= nil and (not self.config.battle_target.disabled) and battle_target.hpp > 0 and (target == nil or (target ~= nil and battle_target.id ~= target.id)) then
    local filled_name = 'BT >> ' .. battle_target.name
    if self.battle_target.text:text() ~= filled_name then
      self.battle_target.text:text(filled_name)
      size_state_changed = true
    end

    should_show = true
  end

  -- update visibility as needed
  set_visibility(self.battle_target.text, self.config.battle_target.nameplate.disabled)

  if size_state_changed then
    self.battle_target.group:calculate_bounding_box(0.1)
  end
end

function ui:update_party()
  local party = windower.ffxi.get_party()
  local should_show = {
    p0 = false,
    p1 = false,
    p2 = false,
    p3 = false,
    p4 = false,
    p5 = false
  }
  local size_state_changed = {
    p0 = false,
    p1 = false,
    p2 = false,
    p3 = false,
    p4 = false,
    p5 = false
  }

  -- Helper function to update visibility and detect changes
  local function set_visibility(party_key, element, is_disabled)
    local current_state = element:visible()
    local new_state = not is_disabled and should_show[party_key]

    if current_state ~= new_state then
      size_state_changed[party_key] = true
      if new_state then
        element:show()
      else
        element:hide()
      end
    end
  end

  if party ~= nil and not self.config.party.disabled then
    if self.config.party.only_show_in_combat == false or (self.config.party.only_show_in_combat == true and player.in_combat == true) then
      for i = 1, 5, 1 do
        local key = 'p' .. i
        local element = self.party[key]
        local party_member = party[key]

        if party_member ~= nil then
          -- this slot is actually in use
          self:update_party_frame(element, party_member)
          should_show[key] = true
        end
      end
    end
  end

  -- update visibility as needed
  for i = 1, 5, 1 do
    local key = 'p' .. i
    local element = self.party[key]

    set_visibility(key, element.text, self.config.party.nameplate.disabled)
    set_visibility(key, element.health_bar, self.config.party.health_bar.disabled or element.missing_bar_data)
    set_visibility(key, element.magic_bar, self.config.party.magic_bar.disabled or element.missing_bar_data)
    set_visibility(key, element.tp_bar, self.config.party.tp_bar.disabled or element.missing_bar_data)

    if size_state_changed[key] then
      element.group:calculate_bounding_box(0.1)
    end
  end
end

function ui:update_party_frame(element, party_member)
  local short_name = party_member.name
  if #party_member.name > 12 then
    short_name = party_member.name:sub(1, 12) .. "..."
  end

  if party_member.mob == nil then
    -- party member in another zone
    local temp_name = short_name .. '\n   ~ ' .. res.zones[party_member.zone].search
    if temp_name ~= element.text:text() then
      element.text:text(temp_name)
      element.missing_bar_data = true
      element.group:calculate_bounding_box(0.1)
    end
  else
    -- party member is in our zone
    if short_name ~= element.text:text() then
      element.text:text(short_name)
      element.missing_bar_data = false
      element.group:calculate_bounding_box(0.1)
    end

    -- set bar size and text
    element.health_bar:text(tostring(party_member.hp))
    element.health_bar:fill(party_member.hpp / 100)
    element.health_bar:text_color(unpack(get_hp_text_color(party_member.hpp)))


    element.magic_bar:text(tostring(party_member.mp))
    element.magic_bar:fill(party_member.mpp / 100)

    element.tp_bar:text(tostring(party_member.tp))
    element.tp_bar:fill(math.min(1000, party_member.tp) / 1000)

    if party_member.tp >= 1000 then
      element.tp_bar:color(self.config.party.tp_bar.foreground.full_red,
        self.config.party.tp_bar.foreground.full_green,
        self.config
        .party.tp_bar.foreground.full_blue)
    else
      element.tp_bar:color(self.config.party.tp_bar.foreground.red, self.config.party.tp_bar.foreground.green,
        self.config
        .party.tp_bar.foreground.blue)
    end
  end
end

function ui:update_alliance()
  local alliance = windower.ffxi.get_party()
  
  local should_show = {
    a10 = false,
    a11 = false,
    a12 = false,
    a13 = false,
    a14 = false,
    a15 = false,

    a20 = false,
    a21 = false,
    a22 = false,
    a23 = false,
    a24 = false,
    a25 = false
  }
  local size_state_changed = {
    a10 = false,
    a11 = false,
    a12 = false,
    a13 = false,
    a14 = false,
    a15 = false,

    a20 = false,
    a21 = false,
    a22 = false,
    a23 = false,
    a24 = false,
    a25 = false
  }

  -- Helper function to update visibility and detect changes
  local function set_visibility(alliance_key, element, is_disabled)
    local current_state = element:visible()
    local new_state = not is_disabled and should_show[alliance_key]

    if current_state ~= new_state then
      size_state_changed[alliance_key] = true
      if new_state then
        element:show()
      else
        element:hide()
      end
    end
  end

  if alliance ~= nil and not self.config.alliance.disabled then
    if self.config.alliance.only_show_in_combat == false or (self.config.alliance.only_show_in_combat == true and player.in_combat == true) then
      for _, i in ipairs(alliance_range) do
        local key = 'a' .. i
        local element = self.alliance[key]
        local alliance_member = alliance[key]

        if alliance_member ~= nil then
          -- this slot is actually in use
          self:update_alliance_frame(element, alliance_member)
          should_show[key] = true
        end
      end
    end
  end

  -- update visibility as needed
  for _, i in ipairs(alliance_range) do
    local key = 'a' .. i
    local element = self.alliance[key]

    set_visibility(key, element.text, self.config.alliance.nameplate.disabled)
    set_visibility(key, element.health_bar, self.config.alliance.health_bar.disabled or element.missing_bar_data)
    set_visibility(key, element.magic_bar, self.config.alliance.magic_bar.disabled or element.missing_bar_data)
    set_visibility(key, element.tp_bar, self.config.alliance.tp_bar.disabled or element.missing_bar_data)

    if size_state_changed[key] then
      element.group:calculate_bounding_box(0.1)
    end
  end
end

function ui:update_alliance_frame(element, alliance_member)
  local short_name = alliance_member.name
  if #alliance_member.name > 7 then
    short_name = alliance_member.name:sub(1, 7) .. "..."
  end

  if alliance_member.mob == nil then
    -- alliance member in another zone
    local temp_name = short_name .. '\n~' .. res.zones[alliance_member.zone].search:sub(1, 7)
    if temp_name ~= element.text:text() then
      element.text:text(temp_name)
      element.missing_bar_data = true
      element.group:calculate_bounding_box(0.1)
    end
  else
    -- alliance member is in our zone
    if short_name ~= element.text:text() then
      element.text:text(short_name)
      element.missing_bar_data = false
      element.group:calculate_bounding_box(0.1)
    end

    -- set bar size and text
    element.health_bar:text(tostring(alliance_member.hp))
    element.health_bar:fill(alliance_member.hpp / 100)
    element.health_bar:text_color(unpack(get_hp_text_color(alliance_member.hpp)))


    element.magic_bar:text(tostring(alliance_member.mp))
    element.magic_bar:fill(alliance_member.mpp / 100)

    element.tp_bar:text(tostring(alliance_member.tp))
    element.tp_bar:fill(math.min(1000, alliance_member.tp) / 1000)

    if alliance_member.tp >= 1000 then
      element.tp_bar:color(self.config.alliance.tp_bar.foreground.full_red,
        self.config.alliance.tp_bar.foreground.full_green,
        self.config
        .alliance.tp_bar.foreground.full_blue)
    else
      element.tp_bar:color(self.config.alliance.tp_bar.foreground.red, self.config.alliance.tp_bar.foreground.green,
        self.config
        .alliance.tp_bar.foreground.blue)
    end
  end
end

function ui:update_gui()
  if self.isCreated == false or self.isVisible == false then
    return
  end

  self:update_player()
  self:update_pet()
  self:update_target()
  self:update_sub_target()
  self:update_battle_target()
  self:update_party()
  self:update_alliance()
end

function ui:update_pet_tp(tp)
  self:update_pet_frame(nil, nil, tp)
end

function ui:update_pet_mp(mpp)
  self:update_pet_frame(nil, mpp, nil)
end

function ui:handle_click(type, x, y, delta)
  local action = nil
  local intercepted = false
  local onDown = false

  -- need to capture down and up click to not mess things up
  if type == 1 then
    action = 'on_left_click'
    onDown = true
  elseif type == 2 then
    action = 'on_left_click'
  elseif type == 4 then
    action = 'on_right_click'
    onDown = true
  elseif type == 5 then
    action = 'on_right_click'
  elseif type == 7 then
    action = 'on_middle_click'
    onDown = true
  elseif type == 8 then
    action = 'on_middle_click'
  elseif type == 10 then
    action = 'on_scroll_wheel'
  elseif type == 11 then
    action = 'on_mouse_4'
    onDown = true
  elseif type == 12 then
    action = 'on_mouse_4'
  elseif type == 14 then
    action = 'on_horizontal'
  elseif type == 15 then
    action = 'on_mouse_5'
    onDown = true
  elseif type == 16 then
    action = 'on_mouse_5'
  end

  if action then
    local groups = self.action_handlers[action]
    if groups then
      for group, action in pairs(groups) do
        --print(action)
        if group:is_inside(x, y) == true then
          if onDown then
            windower.chat.input(action)
          end
          intercepted = true
        end
      end
    end
  end

  return intercepted
end

return ui
