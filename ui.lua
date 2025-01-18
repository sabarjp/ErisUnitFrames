local grouper = require("component_group")

-- singleton table-style global
ui = {
  -- whether the whole ui is visible or not
  isVisible = true,
  isCreated = false,

  -- whether drag-n-drop is off or on, locked means cannot move
  isLocked = true,
  -- if a group is being dragged, then this contains metadata on it
  dragged = {
    element = nil,
    x = 0,
    y = 0
  },

  config = {},              -- note: this is the merged config for settings + theme
  settings = {},            -- these are user defined settings that are written back on save
  theme = {},               -- this is the loaded theme file, it should be carefully managed so not to save these settings

  format_string_cache = {}, -- helps track data that has changed and stores string formats

  -- for string formatting, this tracks what data references we need to monitor for
  -- changes, used heavily in the cache
  format_dependencies = {
    ["%name"] = { "party_data.name", "mob_data.name", "party_data.zone" },
    ["%name_short"] = { "party_data.name", "mob_data.name", "party_data.zone" },
    ["%mob_type"] = { "mob_data.id", "mob_data.hpp", "mob_data.in_party", "mob_data.in_alliance", "mob_data.is_npc", "mob_data.spawn_type", "mob_data.claim_id" },
    ["%distance"] = { "mob_data.distance" },
    ["%hp_current"] = { "party_data.hp" },
    ["%hp_max"] = { "party_data.max_hp", "party_data.hp", "party_data.hpp", "mob_data.hp", "mob_data.hpp" },
    ["%hp_percent"] = { "party_data.hpp", "mob_data.hpp" },
    ["%tp_current"] = { "party_data.tp", "mob_data.tp" },
    ["%tp_max"] = {}, -- Static value
    ["%tp_percent"] = { "party_data.tp", "mob_data.tp" },
    ["%mp_current"] = { "party_data.mp" },
    ["%mp_percent"] = { "party_data.mpp", "mob_data.mpp" },
    ["%mp_max"] = { "party_data.max_mp", "party_data.mp", "party_data.mpp", "mob_data.mp", "mob_data.mpp" },
    ["%id"] = { "mob_data.id" },
    ["%idh"] = { "mob_data.id" },
    ["%id3"] = { "mob_data.id" },
    ["%idh3"] = { "mob_data.id" },
    ["%speed"] = { "mob_data.speed" },
    ["%x"] = { "mob_data.x" },
    ["%y"] = { "mob_data.y" },
    ["%z"] = { "mob_data.z" },
    ["%zone"] = { "party_data.zone" },
    ["%zone_short"] = { "party_data.zone" },
  },

  player = {
    group = {}, -- grouping metadata to handle this UI element as one object
    text = {},
    health_bar = {},
    magic_bar = {},
    tp_bar = {},
    buffs = {}
  },

  pet = {
    group = {}, -- grouping metadata to handle this UI element as one object
    text = {},
    health_bar = {},
    magic_bar = {},
    tp_bar = {},
    buffs = {}
  },

  target = {
    group = {}, -- grouping metadata to handle this UI element as one object
    text = {},
    health_bar = {},
    locked_text = {},
    buffs = {}
  },

  sub_target = {
    group = {}, -- grouping metadata to handle this UI element as one object
    text = {},
    health_bar = {}
  },

  battle_target = {
    group = {}, -- grouping metadata to handle this UI element as one object
    text = {}
  },

  party = {
    group = {},

    p1 = {},
    p2 = {},
    p3 = {},
    p4 = {},
    p5 = {},
  },

  alliance = {
    group = {},

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
  },

  -- convenience variable to access all our draggable component groups
  draggable_groups = {}
}

local alliance_range = { 10, 11, 12, 13, 14, 15, 20, 21, 22, 23, 24, 25 }

function ui:merge_configs(t1, t2)
  for k, v in pairs(t2) do
    if type(v) == "table" and type(t1[k]) == "table" then
      -- Recursively merge if both are tables
      self:merge_configs(t1[k], v)
    else
      -- Overwrite or add the key-value pair
      t1[k] = v
    end
  end
  return t1
end

function ui:initialize(settings, theme)
  --print('initializing UI')
  self.settings = settings
  self.theme = theme
  self.config = ui:merge_configs(self.theme, self.settings)
  self:create()
  status_effects:initialize()
end

function ui:destroy()
  -- Step 1: Set the UI in a shutdown state
  self.isLocked = true
  self.isCreated = false
  self.isVisible = false

  -- Step 2: Let pending render actions complete
  coroutine.sleep(0.5)

  -- Step 3: Set all UI elements to empty tables immediately
  self.action_handlers = {}
  self.player = {
    click_group = {},
    drag_group = {},
    text = {},
    health_bar = {},
    magic_bar = {},
    tp_bar = {},
    buffs = {}
  }
  self.pet = {
    click_group = {},
    drag_group = {},
    text = {},
    health_bar = {},
    magic_bar = {},
    tp_bar = {},
    buffs = {}
  }
  self.target = {
    click_group = {},
    drag_group = {},
    text = {},
    health_bar = {},
    locked_text = {},
    buffs = {}
  }
  self.sub_target = {
    click_group = {},
    drag_group = {},
    text = {},
    health_bar = {}
  }
  self.battle_target = {
    click_group = {},
    drag_group = {},
    text = {}
  }
  self.party = {
    drag_group = {},
    p1 = {},
    p2 = {},
    p3 = {},
    p4 = {},
    p5 = {}
  }
  self.alliance = {
    drag_group = {},
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
  }
  self.config = {}
  self.settings = {}
  self.theme = {}
  self.format_string_cache = {}
  self.dragged = {}


  -- Step 4: Destroy drag_groups, which destroys all components
  for _, drag_group in ipairs(self.draggable_groups) do
    if drag_group then
      drag_group:destroy()
    end
  end
  self.draggable_groups = {}

  coroutine.sleep(1.5)
  self.isVisible = true
end

function ui:create()
  self:create_player()
  self:create_pet()
  self:create_target()
  self:create_sub_target()
  self:create_battle_target()
  self:create_party()
  self:create_alliance()
  buffs:create_global_tooltip()

  self.isCreated = true
end

-- reads a standard configuration for a nameplate to
-- convert it into what a text object expects for creation
function ui:create_text_from_config(config_element, start_x, start_y)
  local config = {
    value = config_element.value,
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
    value = config_element.value,
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

-- reads a standard configuration for a buff to
-- convert it into what a buff object expects for creation
function ui:create_buff_from_config(config_element, start_x, start_y)
  local config = {
    x = start_x + config_element.rel_pos.x,
    y = start_y + config_element.rel_pos.y,
    width = config_element.width,
    height = config_element.height,
    buff_width = config_element.buff_width,
    buff_height = config_element.buff_height,
    tooltip_disabled = config_element.tooltip_disabled
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
  self:init_format_string_cache(tostring(self.player.text), ui.config.player.nameplate.value)

  self.player.health_bar = bar:new(
    self:create_bar_from_config(self.config.player.health_bar, start_pos_x, start_pos_y)
  )
  self:init_format_string_cache(tostring(self.player.health_bar), ui.config.player.health_bar.value)

  self.player.magic_bar = bar:new(
    self:create_bar_from_config(self.config.player.magic_bar, start_pos_x, start_pos_y)
  )
  self:init_format_string_cache(tostring(self.player.magic_bar), ui.config.player.magic_bar.value)

  self.player.tp_bar = bar:new(
    self:create_bar_from_config(self.config.player.tp_bar, start_pos_x, start_pos_y)
  )
  self:init_format_string_cache(tostring(self.player.tp_bar), ui.config.player.tp_bar.value)

  -- player buffs
  self.player.buffs = buffs:new(
    self:create_buff_from_config(self.config.player.buffs, start_pos_x, start_pos_y)
  )

  -- clickable group
  self.player.click_group = grouper.create_component_group(
    {
      relative_to = self.config.player.pos.relative_to,
      x = self.config.player.pos.x,
      y = self.config.player.pos.y
    },
    grouper.flatten({
      { self.player.text },
      self.player.health_bar:components(),
      self.player.magic_bar:components(),
      self.player.tp_bar:components()
    })
  )

  -- dragable group
  self.player.drag_group = grouper.create_component_group(
    self.config.player.pos, -- note: config pass by ref, this can be saved
    grouper.flatten({
      { self.player.text },
      self.player.health_bar:components(),
      self.player.magic_bar:components(),
      self.player.tp_bar:components()
    }),
    { self.player.buffs }
  )
  table.insert(self.draggable_groups, self.player.drag_group)

  if self.config.player.actions then
    for event, action in pairs(self.config.player.actions) do
      self:register_handler(event, action, self.player.click_group, '<me>')
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
  self:init_format_string_cache(tostring(self.pet.text), ui.config.pet.nameplate.value)

  self.pet.health_bar = bar:new(
    self:create_bar_from_config(self.config.pet.health_bar, start_pos_x, start_pos_y)
  )
  self:init_format_string_cache(tostring(self.pet.health_bar), ui.config.pet.health_bar.value)

  self.pet.magic_bar = bar:new(
    self:create_bar_from_config(self.config.pet.magic_bar, start_pos_x, start_pos_y)
  )
  self:init_format_string_cache(tostring(self.pet.magic_bar), ui.config.pet.magic_bar.value)

  self.pet.tp_bar = bar:new(
    self:create_bar_from_config(self.config.pet.tp_bar, start_pos_x, start_pos_y)
  )
  self:init_format_string_cache(tostring(self.pet.tp_bar), ui.config.pet.tp_bar.value)

  -- pet buffs
  self.pet.buffs = buffs:new(
    self:create_buff_from_config(self.config.pet.buffs, start_pos_x, start_pos_y)
  )

  -- clickable group
  self.pet.click_group = grouper.create_component_group(
    {
      relative_to = self.config.pet.pos.relative_to,
      x = self.config.pet.pos.x,
      y = self.config.pet.pos.y
    },
    grouper.flatten({
      { self.pet.text },
      self.pet.health_bar:components(),
      self.pet.magic_bar:components(),
      self.pet.tp_bar:components()
    })
  )

  --dragable group
  self.pet.drag_group = grouper.create_component_group(
    self.config.pet.pos, -- note: config pass by ref, this can be saved
    grouper.flatten({
      { self.pet.text },
      self.pet.health_bar:components(),
      self.pet.magic_bar:components(),
      self.pet.tp_bar:components()
    }),
    { self.pet.buffs }
  )
  table.insert(self.draggable_groups, self.pet.drag_group)

  if self.config.pet.actions then
    for event, action in pairs(self.config.pet.actions) do
      self:register_handler(event, action, self.pet.click_group, '<pet>')
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
  self:init_format_string_cache(tostring(self.target.text), ui.config.target.nameplate.value)


  self.target.health_bar = bar:new(
    self:create_bar_from_config(self.config.target.health_bar, start_pos_x, start_pos_y)
  )
  self:init_format_string_cache(tostring(self.target.health_bar), ui.config.target.health_bar.value)


  -- target lock text
  self.target.locked_text = texts.new(
    self:create_text_from_config(self.config.target.locked_text, start_pos_x, start_pos_y)
  )
  self:init_format_string_cache(tostring(self.target.locked_text), ui.config.target.locked_text.value)

  self.target.locked_text:text('> LOCKED <')

  -- target buffs
  self.target.buffs = buffs:new(
    self:create_buff_from_config(self.config.target.buffs, start_pos_x, start_pos_y)
  )

  -- clickable group
  self.target.click_group = grouper.create_component_group(
    {
      relative_to = self.config.target.pos.relative_to,
      x = self.config.target.pos.x,
      y = self.config.target.pos.y
    },
    grouper.flatten({
      { self.target.text },
      self.target.health_bar:components()
    })
  )

  -- dragable group
  self.target.drag_group = grouper.create_component_group(
    self.config.target.pos, -- note: config pass by ref, this can be saved
    grouper.flatten({
      { self.target.text },
      self.target.health_bar:components(),
    }),
    { self.target.buffs }
  )
  table.insert(self.draggable_groups, self.target.drag_group)
  if self.config.target.actions then
    for event, action in pairs(self.config.target.actions) do
      self:register_handler(event, action, self.target.click_group, '<t>')
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
  self:init_format_string_cache(tostring(self.sub_target.text), ui.config.sub_target.nameplate.value)


  self.sub_target.health_bar = bar:new(
    self:create_bar_from_config(self.config.sub_target.health_bar, start_pos_x, start_pos_y)
  )
  self:init_format_string_cache(tostring(self.sub_target.health_bar), ui.config.sub_target.health_bar.value)


  -- click group
  self.sub_target.click_group = grouper.create_component_group(
    self.config.sub_target.pos, -- note: config pass by ref, this can be saved
    grouper.flatten({
      { self.sub_target.text },
      self.sub_target.health_bar:components()
    })
  )

  --drag group
  self.sub_target.drag_group = self.sub_target.click_group
  table.insert(self.draggable_groups, self.sub_target.drag_group)
  if self.config.sub_target.actions then
    for event, action in pairs(self.config.sub_target.actions) do
      self:register_handler(event, action, self.sub_target.click_group, '<st>')
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
  self:init_format_string_cache(tostring(self.battle_target.text), ui.config.battle_target.nameplate.value)


  -- click group
  self.battle_target.click_group = grouper.create_component_group(
    self.config.battle_target.pos, -- note: config pass by ref, this can be saved
    grouper.flatten({
      { self.battle_target.text },
    })
  )

  -- drag group
  self.battle_target.drag_group = self.battle_target.click_group
  table.insert(self.draggable_groups, self.battle_target.drag_group)
  if self.config.battle_target.actions then
    for event, action in pairs(self.config.battle_target.actions) do
      self:register_handler(event, action, self.battle_target.click_group, '<bt>')
    end
  end
end

function ui:create_party()
  local center_x = (windower.get_windower_settings().ui_x_res / 2)
  local center_y = (windower.get_windower_settings().ui_y_res / 2)

  local start_pos_x, start_pos_y

  start_pos_x = ((self.config.party.pos.relative_to == 'center') and (center_x + self.config.party.pos.x) or self.config.party.pos.x)
  start_pos_y = ((self.config.party.pos.relative_to == 'center') and (center_y + self.config.party.pos.y) or self.config.party.pos.y)

  local all_party_groups = {}
  local all_party_buff_components = {}

  for i = 1, 5, 1 do
    local key = 'p' .. i
    local party_pos_x = start_pos_x + ((i - 1) * self.config.party.pos.offset_x)
    local party_pos_y = start_pos_y + ((i - 1) * self.config.party.pos.offset_y)

    self.party[key].text = texts.new(self:create_text_from_config(self.config.party.nameplate, party_pos_x, party_pos_y))
    self:init_format_string_cache(tostring(self.party[key].text), ui.config.party.nameplate.value)

    self.party[key].health_bar = bar:new(
      self:create_bar_from_config(self.config.party.health_bar, party_pos_x, party_pos_y)
    )
    self:init_format_string_cache(tostring(self.party[key].health_bar), ui.config.party.health_bar.value)

    self.party[key].magic_bar = bar:new(
      self:create_bar_from_config(self.config.party.magic_bar, party_pos_x, party_pos_y)
    )
    self:init_format_string_cache(tostring(self.party[key].magic_bar), ui.config.party.magic_bar.value)

    self.party[key].tp_bar = bar:new(
      self:create_bar_from_config(self.config.party.tp_bar, party_pos_x, party_pos_y)
    )
    self:init_format_string_cache(tostring(self.party[key].tp_bar), ui.config.party.tp_bar.value)

    -- party buffs
    self.party[key].buffs = buffs:new(
      self:create_buff_from_config(self.config.party.buffs, party_pos_x, party_pos_y)
    )

    -- this group is just for click handling
    self.party[key].click_group = grouper.create_component_group(
      {
        relative_to = self.config.party.pos.relative_to,
        x = self.config.party.pos.x,
        y = self.config.party.pos.y
      },
      grouper.flatten({
        { self.party[key].text },
        self.party[key].health_bar:components(),
        self.party[key].magic_bar:components(),
        self.party[key].tp_bar:components()
      })
    )

    -- prepare the larger group for dragging
    table.insert(all_party_groups, self.party[key].click_group)
    table.insert(all_party_buff_components, self.party[key].buffs)

    -- small group for click handlers
    if self.config.party.actions then
      for event, action in pairs(self.config.party.actions) do
        self:register_handler(event, action, self.party[key].click_group, '<' .. key .. '>')
      end
    end
  end

  local all_components = {}
  -- add standard components
  for _, group in pairs(all_party_groups) do
    for _, component in pairs(group.components) do
      table.insert(all_components, component)
    end
  end

  self.party.drag_group = grouper.create_component_group(
    self.config.party.pos, -- note: config pass by ref, this can be saved
    grouper.flatten({
      all_components
    }),
    all_party_buff_components
  )
  table.insert(self.draggable_groups, self.party.drag_group)

  for _, group in pairs(all_party_groups) do
    group:set_parent(self.party.drag_group)
  end
end

function ui:create_alliance()
  local center_x = (windower.get_windower_settings().ui_x_res / 2)
  local center_y = (windower.get_windower_settings().ui_y_res / 2)

  local start_pos_x, start_pos_y

  start_pos_x = ((self.config.alliance.pos.relative_to == 'center') and (center_x + self.config.alliance.pos.x) or self.config.alliance.pos.x)
  start_pos_y = ((self.config.alliance.pos.relative_to == 'center') and (center_y + self.config.alliance.pos.y) or self.config.alliance.pos.y)

  local all_alliance_groups = {}

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
    self:init_format_string_cache(tostring(self.alliance[key].text), ui.config.alliance.nameplate.value)

    self.alliance[key].health_bar = bar:new(
      self:create_bar_from_config(self.config.alliance.health_bar, alliance_pos_x, alliance_pos_y)
    )
    self:init_format_string_cache(tostring(self.alliance[key].health_bar), ui.config.alliance.health_bar.value)

    self.alliance[key].magic_bar = bar:new(
      self:create_bar_from_config(self.config.alliance.magic_bar, alliance_pos_x, alliance_pos_y)
    )
    self:init_format_string_cache(tostring(self.alliance[key].magic_bar), ui.config.alliance.magic_bar.value)

    self.alliance[key].tp_bar = bar:new(
      self:create_bar_from_config(self.config.alliance.tp_bar, alliance_pos_x, alliance_pos_y)
    )
    self:init_format_string_cache(tostring(self.alliance[key].tp_bar), ui.config.alliance.tp_bar.value)

    -- this group is for click handling
    self.alliance[key].click_group = grouper.create_component_group(
      {
        relative_to = self.config.alliance.pos.relative_to,
        x = self.config.alliance.pos.x,
        y = self.config.alliance.pos.y
      },
      grouper.flatten({
        { self.alliance[key].text },
        self.alliance[key].health_bar:components(),
        self.alliance[key].magic_bar:components(),
        self.alliance[key].tp_bar:components()
      })
    )

    -- prepare the larger group for dragging
    table.insert(all_alliance_groups, self.alliance[key].click_group)

    -- click handlers for small groups
    if self.config.alliance.actions then
      for event, action in pairs(self.config.alliance.actions) do
        self:register_handler(event, action, self.alliance[key].click_group, '<' .. key .. '>')
      end
    end

    n = n + 1
  end

  local all_components = {}
  for _, group in pairs(all_alliance_groups) do
    for _, component in pairs(group.components) do
      table.insert(all_components, component)
    end
  end

  self.alliance.drag_group = grouper.create_component_group(
    self.config.alliance.pos, -- note: config pass by ref, this can be saved
    grouper.flatten({
      all_components
    })
  )

  table.insert(self.draggable_groups, self.alliance.drag_group)

  for _, group in pairs(all_alliance_groups) do
    group:set_parent(self.alliance.drag_group)
  end
end

function ui:register_handler(event, action, group_object, target)
  local actual_action = action:gsub("%%this", target)
  if not self.action_handlers[event] then
    self.action_handlers[event] = {}
  end
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
  self.player.buffs:hide()

  self.target.text:hide()
  self.target.health_bar:hide()
  self.target.locked_text:hide()
  self.target.buffs:hide()

  self.sub_target.text:hide()
  self.sub_target.health_bar:hide()

  self.pet.text:hide()
  self.pet.health_bar:hide()
  self.pet.magic_bar:hide()
  self.pet.tp_bar:hide()
  self.pet.buffs:hide()

  self.battle_target.text:hide()

  for i = 1, 5, 1 do
    local key = 'p' .. i
    self.party[key].text:hide()
    self.party[key].health_bar:hide()
    self.party[key].magic_bar:hide()
    self.party[key].tp_bar:hide()
    self.party[key].buffs:hide()
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

local function get_type_from_mob(mob_data)
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

  return type_text
end

-- creates an empty cache for a given UI element so we can
-- track values that change and prevent uncessary re-rendering
function ui:init_format_string_cache(element_id, format_string)
  if not self.format_string_cache[element_id] then
    self.format_string_cache[element_id] = {
      last_values = {},
      dependencies = self:extract_dependencies(format_string)
    }
  end
end

-- helper to cache the string formatting keys so it operates faster
-- and is cacheable
function ui:extract_dependencies(format_string)
  local dependencies = {}
  format_string:gsub("%%([%w_]+)", function(key)
    local deps = self.format_dependencies["%" .. key]
    if deps then
      for _, dep in ipairs(deps) do
        dependencies[dep] = true
      end
    end
  end)
  return dependencies
end

-- helper function to see if entity data has changed from the
-- cached values
function ui:has_string_dep_changed(element_id, party_data, mob_data)
  local element = self.format_string_cache[element_id]
  local dependencies = element.dependencies
  local changed = false
  for dep in pairs(dependencies) do
    local value
    if party_data and dep:find("^party_data") then
      value = party_data[dep:match("%.([%w_]+)$")]
    elseif mob_data and dep:find("^mob_data") then
      value = mob_data[dep:match("%.([%w_]+)$")]
    end

    if element.last_values[dep] ~= value then
      changed = true
      element.last_values[dep] = value
    end
  end

  return changed
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
  set_visibility(self.player.buffs, self.config.player.buffs.disabled)

  if size_state_changed then
    self.player.click_group:calculate_bounding_box(0.1)
  end
end

function ui:round(num)
  return string.format("%.1f", num)
end

function ui:format_text(text, party_data, mob_data)
  -- Ensure party_data and mob_data are tables or default to empty tables
  party_data = party_data or {}
  mob_data = mob_data or {}

  local function short_name(name)
    if name then
      if #name > 7 then
        return name:sub(1, 7) .. "..."
      end
    end

    return name
  end

  local replacements = {
    ["%name"] = party_data.name or mob_data.name or "",
    ["%name_short"] = short_name(party_data.name) or short_name(mob_data.name) or "",
    ["%mob_type"] = mob_data and get_type_from_mob(mob_data) or "",
    ["%distance"] = mob_data.distance and ui:round(mob_data.distance:sqrt()) or "",
    ["%hp_current"] = party_data.hp or "",
    ["%hp_max"] = party_data.max_hp or
        party_data.hp and party_data.hpp and math.floor(party_data.hp / (party_data.hpp / 100))
        or mob_data.hp and mob_data.hpp and math.floor(mob_data.hp / (mob_data.hpp / 100))
        or "",
    ["%hp_percent"] = party_data.hpp or mob_data.hpp or "",
    ["%tp_current"] = party_data.tp or mob_data.tp or "",
    ["%tp_max"] = "3000",
    ["%tp_percent"] = (party_data.tp or mob_data.tp) and math.floor((party_data.tp or mob_data.tp) / 3000 * 100) or "",
    ["%mp_current"] = party_data.mp or "",
    ["%mp_percent"] = party_data.mpp or mob_data.mp or "",
    ["%mp_max"] = party_data.max_mp or
        party_data.mp and party_data.mpp and math.floor(party_data.mp / (party_data.mpp / 100))
        or mob_data.mp and mob_data.mpp and math.floor(mob_data.mp / (mob_data.mpp / 100))
        or "",
    ["%id"] = mob_data.id or "",
    ["%idh"] = mob_data.id and string.format("0x%X", mob_data.id) or "",
    ["%id3"] = mob_data.id and string.format("%d", mob_data.id):sub(-3) or "",
    ["%idh3"] = mob_data.id and string.format("0x%X", mob_data.id):sub(-3) or "",
    ["%speed"] = mob_data.speed or "",
    ["%x"] = mob_data.x and ui:round(mob_data.x) or "",
    ["%y"] = mob_data.y and ui:round(mob_data.y) or "",
    ["%z"] = mob_data.z and ui:round(mob_data.z) or "",
    ["%zone"] = party_data.zone and res.zones[party_data.zone].en or "",
    ["%zone_short"] = party_data.zone and res.zones[party_data.zone].en or "",
  }

  -- Use gsub to replace keys including the %
  return text:gsub("%%([%w_]+)", function(key)
    return replacements["%" .. key] or ""
  end)
end

function ui:update_player_frame(player)
  -- calculate nameplate
  local player_as_mob = windower.ffxi.get_mob_by_target('me')
  local player_as_party = windower.ffxi.get_party()['p0']
  local size_changed = false

  if player_as_party and player_as_mob then
    local function update_bar(bar, config_value, fill_value, text_color)
      if self:has_string_dep_changed(tostring(bar), player_as_party, player_as_mob) then
        local formatted_text = self:format_text(config_value, player_as_party, player_as_mob)
        bar:text(formatted_text)
        size_changed = true
      end
      if text_color and (not bar:text_color() or not table_equals(bar:text_color(), text_color)) then
        bar:text_color(unpack(text_color))
      end
      if fill_value and bar:fill() ~= fill_value then
        bar:fill(fill_value)
      end
    end

    -- Insert critical data for player specific
    if player.vitals then
      player_as_party.max_hp = player.vitals.max_hp
      player_as_party.max_mp = player.vitals.max_mp
    end

    -- Update nameplate
    if self:has_string_dep_changed(tostring(self.player.text), player_as_party, player_as_mob) then
      local formatted_nameplate = self:format_text(self.config.player.nameplate.value, player_as_party, player_as_mob)
      self.player.text:text(formatted_nameplate)
      size_changed = true
    end

    -- Update bars
    update_bar(self.player.health_bar, self.config.player.health_bar.value, player.vitals.hpp / 100,
      get_hp_text_color(player.vitals.hpp))
    update_bar(self.player.magic_bar, self.config.player.magic_bar.value, player.vitals.mpp / 100)
    update_bar(self.player.tp_bar, self.config.player.tp_bar.value, math.min(1000, player.vitals.tp) / 1000)

    -- update buffs
    local buffs = status_effects:get_buffs_for_target(player_as_mob.id)
    self.player.buffs:update_buffs(buffs)

    -- Adjust bounding box if needed
    if size_changed then
      self.player.click_group:calculate_bounding_box(2.0)
    end
  end

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

  if not self.isLocked then
    -- create fake data so the frame can always be positioned
    pet = {
      name = 'TestPet',
      hpp = 80,
      id = player.id
    }
    mpp = 75
    tp = 500
  end

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
  set_visibility(self.pet.buffs, self.config.pet.buffs.disabled)

  if size_state_changed then
    self.pet.click_group:calculate_bounding_box(0.1)
  end
end

function ui:update_pet_frame(pet, mpp, tp)
  local player = windower.ffxi.get_player()

  -- a very minmal party type data for the pet
  local pet_as_party = {
    hpp = pet and pet.hpp or self.pet.health_bar.last_known_hpp,
    mpp = mpp or self.pet.magic_bar.last_known_mpp,
    tp = tp or self.pet.tp_bar.last_known_tp
  }

  if player and player.main_job_id == 18 then
    -- puppetmaster gets additional data on pets, pretty cool
    local pup_data = windower.ffxi.get_mjob_data()
    if pup_data and pup_data.hp then pet_as_party.hp = pup_data.hp end
    if pup_data and pup_data.max_hp then pet_as_party.max_hp = pup_data.max_hp end
    if pup_data and pup_data.mp then pet_as_party.mp = pup_data.mp end
    if pup_data and pup_data.max_mp then pet_as_party.max_mp = pup_data.max_mp end
  end

  local size_changed = false

  local function update_bar(bar, config_value, fill_value, text_color)
    if self:has_string_dep_changed(tostring(bar), pet_as_party, pet, true) then
      local formatted_text = self:format_text(config_value, pet_as_party, pet)
      bar:text(formatted_text)
      size_changed = true
    end
    if text_color and (not bar:text_color() or not table_equals(bar:text_color(), text_color)) then
      bar:text_color(unpack(text_color))
    end
    if fill_value and bar:fill() ~= fill_value then
      bar:fill(fill_value)
    end
  end

  if pet ~= nil then
    -- Update nameplate
    if self:has_string_dep_changed(tostring(self.pet.text), pet_as_party, pet) then
      local formatted_nameplate = self:format_text(self.config.pet.nameplate.value, pet_as_party, pet)
      self.pet.text:text(formatted_nameplate)
      size_changed = true
    end

    update_bar(self.pet.health_bar, self.config.pet.health_bar.value, pet.hpp / 100, get_hp_text_color(pet.hpp))
    self.pet.health_bar.last_known_hpp = pet.hpp

    -- update buffs
    local buffs = status_effects:get_buffs_for_target(pet.id)
    self.pet.buffs:update_buffs(buffs)
  end

  if mpp ~= nil then
    update_bar(self.pet.magic_bar, self.config.pet.magic_bar.value, mpp / 100)
    self.pet.magic_bar.last_known_mpp = mpp
  end

  if tp ~= nil then
    update_bar(self.pet.tp_bar, self.config.pet.tp_bar.value, math.min(1000, tp) / 1000)
    self.pet.tp_bar.last_known_tp = tp
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

  -- Adjust bounding box if needed
  if size_changed then
    self.pet.click_group:calculate_bounding_box(2.0)
  end
end

function ui:update_target()
  local player = windower.ffxi.get_player()
  local target = windower.ffxi.get_mob_by_target('t')

  if not self.isLocked then
    -- create fake data so the frame can always be positioned
    target = windower.ffxi.get_mob_by_target('me')
  end

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
      -- Update nameplate
      if self:has_string_dep_changed(tostring(self.target.text), {}, target) then
        local formatted_nameplate = self:format_text(self.config.target.nameplate.value, {}, target)
        self.target.text:text(formatted_nameplate)
        size_state_changed = true
      end

      local r, g, b = get_text_color_from_mob(target)
      if self.config.target.nameplate.text.use_dynamic_colors then
        self.target.text:color(r, g, b)
      end

      if self.config.target.health_bar.foreground.use_dynamic_colors then
        self.target.health_bar:color(r, g, b)
      end

      -- set bar size and text
      if self:has_string_dep_changed(tostring(self.target.health_bar), {}, target) then
        local formatted_hp = self:format_text(self.config.target.health_bar.value, {}, target)
        self.target.health_bar:text(formatted_hp)
        size_state_changed = true
      end

      local text_color = get_hp_text_color(target.hpp)
      if text_color and (not self.target.health_bar:text_color() or not table_equals(self.target.health_bar:text_color(), text_color)) then
        self.target.health_bar:text_color(unpack(text_color))
      end

      local fill_value = target.hpp / 100
      if fill_value and self.target.health_bar:fill() ~= fill_value then
        self.target.health_bar:fill(target.hpp / 100)
      end

      -- update buffs
      local buffs = status_effects:get_buffs_for_target(target.id)
      self.target.buffs:update_buffs(buffs)

      should_show = true
    end
  end

  -- locked text is separate logic due to not relying explicitly on the target existing such as after death
  if self:has_string_dep_changed(tostring(self.target.locked_text), {}, target) then
    local formatted_locktext = self:format_text(self.config.target.locked_text.value, {}, target)
    self.target.text:text(formatted_locktext)
    size_state_changed = true
  end

  if (not self.config.target.locked_text.disabled) and player and player.target_locked == true then
    self.target.locked_text:show()
  else
    self.target.locked_text:hide()
  end

  -- update visibility as needed
  set_visibility(self.target.text, self.config.target.nameplate.disabled)
  set_visibility(self.target.health_bar, self.config.target.health_bar.disabled)
  set_visibility(self.target.buffs, self.config.target.buffs.disabled)

  if size_state_changed then
    self.target.click_group:calculate_bounding_box(0.1)
  end
end

function ui:update_sub_target()
  local player = windower.ffxi.get_player()
  local sub_target = windower.ffxi.get_mob_by_target('st')

  if not self.isLocked then
    -- create fake data so the frame can always be positioned
    sub_target = windower.ffxi.get_mob_by_target('me')
  end

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
      -- Update nameplate
      if self:has_string_dep_changed(tostring(self.sub_target.text), {}, sub_target) then
        local formatted_nameplate = self:format_text(self.config.sub_target.nameplate.value, {}, sub_target)
        self.sub_target.text:text(formatted_nameplate)
        size_state_changed = true
      end

      local r, g, b = get_text_color_from_mob(sub_target)

      if self.config.sub_target.nameplate.text.use_dynamic_colors then
        self.sub_target.text:color(r, g, b)
      end

      if self.config.sub_target.health_bar.foreground.use_dynamic_colors then
        self.sub_target.health_bar:color(r, g, b)
      end

      -- set bar size and text
      if self:has_string_dep_changed(tostring(self.sub_target.health_bar), {}, sub_target) then
        local formatted_hp = self:format_text(self.config.sub_target.health_bar.value, {}, sub_target)
        self.sub_target.health_bar:text(formatted_hp)
        size_state_changed = true
      end

      local text_color = get_hp_text_color(sub_target.hpp)
      if text_color and (not self.target.health_bar:text_color() or not table_equals(self.target.health_bar:text_color(), text_color)) then
        self.sub_target.health_bar:text_color(unpack(text_color))
      end

      local fill_value = sub_target.hpp / 100
      if fill_value and self.sub_target.health_bar:fill() ~= fill_value then
        self.sub_target.health_bar:fill(sub_target.hpp / 100)
      end

      should_show = true
    end
  end

  -- update visibility as needed
  set_visibility(self.sub_target.text, self.config.sub_target.nameplate.disabled)
  set_visibility(self.sub_target.health_bar, self.config.sub_target.health_bar.disabled)

  if size_state_changed then
    self.sub_target.click_group:calculate_bounding_box(0.1)
  end
end

function ui:update_battle_target()
  local target = windower.ffxi.get_mob_by_target('t')
  local battle_target = windower.ffxi.get_mob_by_target('bt')

  if not self.isLocked then
    -- create fake data so the frame can always be positioned
    battle_target = windower.ffxi.get_mob_by_target('me')
  end

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
    -- Update nameplate
    if self:has_string_dep_changed(tostring(self.battle_target.text), {}, battle_target) then
      local formatted_nameplate = self:format_text(self.config.battle_target.nameplate.value, {}, battle_target)
      self.battle_target.text:text(formatted_nameplate)
      size_state_changed = true
    end

    should_show = true
  end

  -- update visibility as needed
  set_visibility(self.battle_target.text, self.config.battle_target.nameplate.disabled)

  if size_state_changed then
    self.battle_target.click_group:calculate_bounding_box(0.1)
  end
end

function ui:update_party()
  local party = windower.ffxi.get_party()
  local player = windower.ffxi.get_player()

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

        if party_member ~= nil or not self.isLocked then
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
    set_visibility(key, element.buffs, self.config.party.buffs.disabled or element.missing_bar_data)

    if size_state_changed[key] then
      element.click_group:calculate_bounding_box(0.1)
    end
  end
end

function ui:update_party_frame(element, party_member)
  local size_changed = false
  local current_zone = windower.ffxi.get_info().zone

  if not self.isLocked then
    -- create fake data so the frame can always be positioned
    party_member = windower.ffxi.get_party()['p0']
    if math.floor(os.clock()) % 5 == 0 then
      party_member.zone = 131
    end
    if math.floor(os.clock()) % 7 == 0 then
      party_member.mob = nil
    end
  end

  if party_member then
    if party_member.zone ~= current_zone then
      -- party member in another zone

      if self:has_string_dep_changed(tostring(element.text), party_member, party_member.mob) then
        local temp_name = party_member.name .. '\n   ~ ' .. res.zones[party_member.zone].search
        element.text:text(temp_name)
        element.missing_bar_data = true
        size_changed = true
      end
    else
      -- party member is in our zone
      local function update_bar(bar, config_value, fill_value, text_color)
        if self:has_string_dep_changed(tostring(bar), party_member, party_member.mob) then
          local formatted_text = self:format_text(config_value, party_member, party_member.mob)
          bar:text(formatted_text)
          size_changed = true
        end
        if text_color and (not bar:text_color() or not table_equals(bar:text_color(), text_color)) then
          bar:text_color(unpack(text_color))
        end
        if fill_value and bar:fill() ~= fill_value then
          bar:fill(fill_value)
        end
      end

      element.missing_bar_data = false

      -- Update nameplate
      if self:has_string_dep_changed(tostring(element.text), party_member, party_member.mob) then
        local formatted_nameplate = self:format_text(self.config.party.nameplate.value, party_member, party_member.mob)
        element.text:text(formatted_nameplate)
        size_changed = true
      end

      -- Update bars
      update_bar(element.health_bar, self.config.party.health_bar.value, party_member.hpp / 100,
        get_hp_text_color(party_member.hpp))
      update_bar(element.magic_bar, self.config.party.magic_bar.value, party_member.mpp / 100)
      update_bar(element.tp_bar, self.config.party.tp_bar.value, math.min(1000, party_member.tp) / 1000)

      -- update buffs
      if party_member.mob and party_member.mob.id then
        local buffs = status_effects:get_buffs_for_target(party_member.mob.id)
        element.buffs:update_buffs(buffs)
      end

      -- Adjust bounding box if needed
      if size_changed then
        element.click_group:calculate_bounding_box(2.0)
      end

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
end

function ui:update_alliance()
  local alliance = windower.ffxi.get_party()
  local player = windower.ffxi.get_player()

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

        if alliance_member ~= nil or not self.isLocked then
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
      element.click_group:calculate_bounding_box(0.1)
    end
  end
end

function ui:update_alliance_frame(element, alliance_member)
  local size_changed = false
  local current_zone = windower.ffxi.get_info().zone

  if not self.isLocked then
    -- create fake data so the frame can always be positioned
    alliance_member = windower.ffxi.get_party()['p0']
  end

  if alliance_member then
    if alliance_member.zone ~= current_zone then
      -- party member in another zone

      if self:has_string_dep_changed(tostring(element.text), alliance_member, alliance_member.mob) then
        local temp_name = alliance_member.name .. '\n   ~ ' .. res.zones[alliance_member.zone].search
        element.text:text(temp_name)
        element.missing_bar_data = true
        size_changed = true
      end
    else
      -- alliance member is in our zone
      local function update_bar(bar, config_value, fill_value, text_color)
        if self:has_string_dep_changed(tostring(bar), alliance_member, alliance_member.mob) then
          local formatted_text = self:format_text(config_value, alliance_member, alliance_member.mob)
          bar:text(formatted_text)
          size_changed = true
        end
        if text_color and (not bar:text_color() or not table_equals(bar:text_color(), text_color)) then
          bar:text_color(unpack(text_color))
        end
        if fill_value and bar:fill() ~= fill_value then
          bar:fill(fill_value)
        end
      end

      element.missing_bar_data = false

      -- Update nameplate
      if self:has_string_dep_changed(tostring(element.text), alliance_member, alliance_member.mob) then
        local formatted_nameplate = self:format_text(self.config.alliance.nameplate.value, alliance_member,
          alliance_member.mob)
        element.text:text(formatted_nameplate)
        size_changed = true
      end

      -- Update bars
      update_bar(element.health_bar, self.config.alliance.health_bar.value, alliance_member.hpp / 100,
        get_hp_text_color(alliance_member.hpp))
      update_bar(element.magic_bar, self.config.alliance.magic_bar.value, alliance_member.mpp / 100)
      update_bar(element.tp_bar, self.config.alliance.tp_bar.value, math.min(1000, alliance_member.tp) / 1000)

      -- Adjust bounding box if needed
      if size_changed then
        element.click_group:calculate_bounding_box(2.0)
      end

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
  if self.isCreated == false or self.isVisible == false then
    return
  end

  self:update_pet_frame(nil, nil, tp)
end

function ui:update_pet_mp(mpp)
  if self.isCreated == false or self.isVisible == false then
    return
  end

  self:update_pet_frame(nil, mpp, nil)
end

function ui:handle_mouse(type, x, y, delta)
  if self.isCreated == false or self.isVisible == false then
    return false
  end

  local action = nil
  local intercepted = false
  local onDown = false

  -- pass events onto our buffs for tooltips
  if not self.target.buffs:handle_mouse(type, x, y) then
    if not self.player.buffs:handle_mouse(type, x, y) then
      if not self.pet.buffs:handle_mouse(type, x, y) then
        -- now check party
        for i = 1, 5, 1 do
          local key = 'p' .. i
          local element = self.party[key]
          if element.buffs:handle_mouse(type, x, y) then break end
        end
      end
    end
  end

  if self.isLocked then
    -- ui is locked, so normal click events apply
    -- note: need to capture down AND up click to not mess things up with interception

    if type == 0 then
      action = nil
    elseif type == 1 then
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
  else
    -- ui is unlocked, so click and drag mode is on
    local center_x = (windower.get_windower_settings().ui_x_res / 2)
    local center_y = (windower.get_windower_settings().ui_y_res / 2)

    -- mouse move
    if type == 0 then
      if self.dragged and self.dragged.element then
        self.dragged.element:pos(x - self.dragged.x, y - self.dragged.y)
        return true
      end

      -- Mouse left click
    elseif type == 1 then
      for _, group in pairs(self.draggable_groups) do
        if group:is_inside(x, y) == true then
          local pos_x = ((group.root.relative_to == 'center') and (center_x + group.root.x) or group.root.x)
          local pos_y = ((group.root.relative_to == 'center') and (center_y + group.root.y) or group.root.y)

          self.dragged = {
            element = group,
            x = x - pos_x, -- x diff from the root
            y = y - pos_y  -- y diff from the root
          }

          return true
        end
      end

      -- Mouse left release
    elseif type == 2 then
      if self.dragged then
        -- recalculate bounds
        local group = self.dragged.element
        self.dragged = nil
        if group then
          group:calculate_bounding_box(0.1)
        end
        return true
      end
    end
  end
end

return ui
