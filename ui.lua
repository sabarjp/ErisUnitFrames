-- singleton table-style global
ui = {
  -- whether the whole ui is visible or not
  isVisible = true,
  isCreated = false,

  config = {
    bar_width = 100,
    only_show_player_frame_in_combat = true
  },

  player = {
    text = {},
    health_bar_bg = {},
    health_bar_fg = {},
    health_bar_text = {},
    magic_bar_bg = {},
    magic_bar_fg = {},
    magic_bar_text = {},
    tp_bar_bg = {},
    tp_bar_fg = {},
    tp_bar_text = {}
  },

  target = {
    text = {},
    health_bar_bg = {},
    health_bar_fg = {},
    health_bar_text = {},
    locked_text = {}
  },

  sub_target = {
    text = {},
    health_bar_bg = {},
    health_bar_fg = {},
    health_bar_text = {}
  },

  battle_target = {
    text = {}
  }
}

function ui:initialize(config)
  self.config = config
  self:create()
end

local function justX(xNormal)
  return xNormal - windower.get_windower_settings().ui_x_res
end

function ui:create()
  local center_x = (windower.get_windower_settings().ui_x_res / 2)
  local center_y = (windower.get_windower_settings().ui_y_res / 2)

  local tempx, tempy

  ------------------------------------------------------------------
  -- player
  ------------------------------------------------------------------
  -- player text
  self.player.text = texts.new({
    flags = {
      draggable = true
    }
  })

  self.player.text:font('Calibri')
  self.player.text:alpha(255)
  self.player.text:stroke_transparency(0)
  self.player.text:stroke_width(2)
  self.player.text:stroke_color(0, 0, 0)
  self.player.text:color(255, 255, 255)
  self.player.text:bg_visible(false)
  self.player.text:pos(center_x - 100 - self.config.bar_width, center_y + 130)
  self.player.text:hide()

  -- player health bar
  self.player.health_bar_bg = images.new({
    flags = {
      draggable = false
    }
  })
  self.player.health_bar_bg:alpha(128)
  self.player.health_bar_bg:color(150, 150, 150)
  self.player.health_bar_bg:size(self.config.bar_width, 15)
  self.player.health_bar_bg:width(self.config.bar_width)
  self.player.health_bar_bg:path(windower.addon_path .. 'bar_bg_1.png')
  self.player.health_bar_bg:fit(true)
  self.player.health_bar_bg:repeat_xy(1, 1)
  tempx, tempy = self.player.text:pos()
  self.player.health_bar_bg:pos(tempx, tempy + 20)
  self.player.health_bar_bg:hide()

  self.player.health_bar_fg = images.new({
    flags = {
      draggable = false
    }
  })
  self.player.health_bar_fg:alpha(255)
  self.player.health_bar_fg:color(250, 140, 140)
  self.player.health_bar_fg:size(self.config.bar_width, 15)
  self.player.health_bar_fg:width(self.config.bar_width)
  self.player.health_bar_fg:path(windower.addon_path .. 'bar_fg_1.png')
  self.player.health_bar_fg:fit(true)
  self.player.health_bar_fg:repeat_xy(1, 1)
  tempx, tempy = self.player.text:pos()
  self.player.health_bar_fg:pos(tempx, tempy + 20)
  self.player.health_bar_fg:hide()

  -- player health bar text
  self.player.health_bar_text = texts.new({
    flags = {
      draggable = false,
      right = true
    }
  })

  self.player.health_bar_text:font('Calibri')
  self.player.health_bar_text:alpha(255)
  self.player.health_bar_text:stroke_transparency(0.5)
  self.player.health_bar_text:stroke_width(1.5)
  self.player.health_bar_text:stroke_color(0, 0, 0)
  self.player.health_bar_text:color(255, 255, 255)
  self.player.health_bar_text:bg_visible(false)
  tempx, tempy = self.player.health_bar_fg:pos()
  self.player.health_bar_text:pos(justX(tempx + self.config.bar_width), tempy - 3)
  self.player.health_bar_text:hide()

  -- player magic bar
  self.player.magic_bar_bg = images.new({
    flags = {
      draggable = false
    }
  })
  self.player.magic_bar_bg:alpha(128)
  self.player.magic_bar_bg:color(150, 150, 150)
  self.player.magic_bar_bg:size(self.config.bar_width, 13)
  self.player.magic_bar_bg:width(self.config.bar_width)
  self.player.magic_bar_bg:path(windower.addon_path .. 'bar_bg_1.png')
  self.player.magic_bar_bg:fit(true)
  self.player.magic_bar_bg:repeat_xy(1, 1)
  tempx, tempy = self.player.health_bar_bg:pos()
  self.player.magic_bar_bg:pos(tempx, tempy + self.player.health_bar_bg:height())
  self.player.magic_bar_bg:hide()

  self.player.magic_bar_fg = images.new({
    flags = {
      draggable = false
    }
  })
  self.player.magic_bar_fg:alpha(255)
  self.player.magic_bar_fg:color(203, 201, 134)
  self.player.magic_bar_fg:size(self.config.bar_width, 13)
  self.player.magic_bar_fg:width(self.config.bar_width)
  self.player.magic_bar_fg:path(windower.addon_path .. 'bar_fg_1.png')
  self.player.magic_bar_fg:fit(true)
  self.player.magic_bar_fg:repeat_xy(1, 1)
  tempx, tempy = self.player.health_bar_bg:pos()
  self.player.magic_bar_fg:pos(tempx, tempy + self.player.health_bar_bg:height())
  self.player.magic_bar_fg:hide()

  -- player magic bar text
  self.player.magic_bar_text = texts.new({
    flags = {
      draggable = false,
      right = true
    }
  })

  self.player.magic_bar_text:font('Calibri')
  self.player.magic_bar_text:size(11)
  self.player.magic_bar_text:alpha(255)
  self.player.magic_bar_text:stroke_transparency(0.5)
  self.player.magic_bar_text:stroke_width(1.5)
  self.player.magic_bar_text:stroke_color(0, 0, 0)
  self.player.magic_bar_text:color(255, 255, 255)
  self.player.magic_bar_text:bg_visible(false)
  tempx, tempy = self.player.magic_bar_fg:pos()
  self.player.magic_bar_text:pos(justX(tempx + self.config.bar_width), tempy - 3)
  self.player.magic_bar_text:hide()

  -- player tp bar
  self.player.tp_bar_bg = images.new({
    flags = {
      draggable = false
    }
  })
  self.player.tp_bar_bg:alpha(128)
  self.player.tp_bar_bg:color(150, 150, 150)
  self.player.tp_bar_bg:size(self.config.bar_width, 13)
  self.player.tp_bar_bg:width(self.config.bar_width)
  self.player.tp_bar_bg:path(windower.addon_path .. 'bar_bg_1.png')
  self.player.tp_bar_bg:fit(true)
  self.player.tp_bar_bg:repeat_xy(1, 1)
  tempx, tempy = self.player.magic_bar_bg:pos()
  self.player.tp_bar_bg:pos(tempx, tempy + self.player.magic_bar_bg:height())
  self.player.tp_bar_bg:hide()

  self.player.tp_bar_fg = images.new({
    flags = {
      draggable = false
    }
  })
  self.player.tp_bar_fg:alpha(255)
  self.player.tp_bar_fg:color(155, 185, 185)
  self.player.tp_bar_fg:size(self.config.bar_width, 13)
  self.player.tp_bar_fg:width(self.config.bar_width)
  self.player.tp_bar_fg:path(windower.addon_path .. 'bar_fg_1.png')
  self.player.tp_bar_fg:fit(true)
  self.player.tp_bar_fg:repeat_xy(1, 1)
  tempx, tempy = self.player.magic_bar_bg:pos()
  self.player.tp_bar_fg:pos(tempx, tempy + self.player.magic_bar_bg:height())
  self.player.tp_bar_fg:hide()

  -- player tp bar text
  self.player.tp_bar_text = texts.new({
    flags = {
      draggable = false,
      right = true
    }
  })

  self.player.tp_bar_text:font('Calibri')
  self.player.tp_bar_text:size(11)
  self.player.tp_bar_text:alpha(255)
  self.player.tp_bar_text:stroke_transparency(0.5)
  self.player.tp_bar_text:stroke_width(1.5)
  self.player.tp_bar_text:stroke_color(0, 0, 0)
  self.player.tp_bar_text:color(255, 255, 255)
  self.player.tp_bar_text:bg_visible(false)
  tempx, tempy = self.player.tp_bar_fg:pos()
  self.player.tp_bar_text:pos(justX(tempx + self.config.bar_width), tempy - 3)
  self.player.tp_bar_text:hide()

  ------------------------------------------------------------------
  -- target
  ------------------------------------------------------------------
  -- target text
  self.target.text = texts.new({
    flags = {
      draggable = true
    }
  })

  self.target.text:font('Calibri')
  self.target.text:alpha(255)
  self.target.text:stroke_transparency(0)
  self.target.text:stroke_width(2)
  self.target.text:stroke_color(0, 0, 0)
  self.target.text:color(255, 255, 255)
  self.target.text:bg_visible(false)
  self.target.text:pos(center_x + 100, center_y + 130)
  self.target.text:hide()

  -- target health bar
  self.target.health_bar_bg = images.new({
    flags = {
      draggable = false
    }
  })
  self.target.health_bar_bg:alpha(128)
  self.target.health_bar_bg:color(150, 150, 150)
  self.target.health_bar_bg:size(self.config.bar_width, 15)
  self.target.health_bar_bg:width(self.config.bar_width)
  self.target.health_bar_bg:path(windower.addon_path .. 'bar_bg_1.png')
  self.target.health_bar_bg:fit(true)
  self.target.health_bar_bg:repeat_xy(1, 1)
  tempx, tempy = self.target.text:pos()
  self.target.health_bar_bg:pos(tempx, tempy + 20)
  self.target.health_bar_bg:hide()

  self.target.health_bar_fg = images.new({
    flags = {
      draggable = false
    }
  })
  self.target.health_bar_fg:alpha(255)
  self.target.health_bar_fg:color(227, 118, 118)
  self.target.health_bar_fg:size(self.config.bar_width, 15)
  self.target.health_bar_fg:width(self.config.bar_width)
  self.target.health_bar_fg:path(windower.addon_path .. 'bar_fg_1.png')
  self.target.health_bar_fg:fit(true)
  self.target.health_bar_fg:repeat_xy(1, 1)
  tempx, tempy = self.target.text:pos()
  self.target.health_bar_fg:pos(tempx, tempy + 20)
  self.target.health_bar_fg:hide()

  -- target health bar text
  self.target.health_bar_text = texts.new({
    flags = {
      draggable = false,
      right = true
    }
  })

  self.target.health_bar_text:font('Calibri')
  self.target.health_bar_text:alpha(255)
  self.target.health_bar_text:stroke_transparency(0.5)
  self.target.health_bar_text:stroke_width(1.5)
  self.target.health_bar_text:stroke_color(0, 0, 0)
  self.target.health_bar_text:color(255, 255, 255)
  self.target.health_bar_text:bg_visible(false)
  tempx, tempy = self.target.health_bar_fg:pos()
  self.target.health_bar_text:pos(justX(tempx + self.config.bar_width), tempy - 3)
  self.target.health_bar_text:hide()

  -- target lock text
  self.target.locked_text = texts.new({
    flags = {
      draggable = false
    }
  })

  self.target.locked_text:font('Calibri')
  self.target.locked_text:alpha(255)
  self.target.locked_text:stroke_transparency(0)
  self.target.locked_text:stroke_width(2)
  self.target.locked_text:stroke_color(0, 0, 0)
  self.target.locked_text:color(232, 60, 60)
  self.target.locked_text:text('> LOCKED <')
  self.target.locked_text:bg_visible(false)
  tempx, tempy = self.target.text:pos()
  self.target.locked_text:pos(tempx, tempy - 16)
  self.target.locked_text:hide()

  ------------------------------------------------------------------
  -- sub target
  ------------------------------------------------------------------
  -- sub target text
  self.sub_target.text = texts.new({
    flags = {
      draggable = false
    }
  })

  self.sub_target.text:font('Calibri')
  self.sub_target.text:alpha(255)
  self.sub_target.text:stroke_transparency(0)
  self.sub_target.text:stroke_width(2)
  self.sub_target.text:stroke_color(120, 120, 255)
  self.sub_target.text:color(255, 0, 255)
  self.sub_target.text:bg_visible(false)
  self.sub_target.text:pos(center_x + 100, center_y + 85)
  self.sub_target.text:hide()

  -- sub_target health bar
  self.sub_target.health_bar_bg = images.new({
    flags = {
      draggable = false
    }
  })
  self.sub_target.health_bar_bg:alpha(255)
  self.sub_target.health_bar_bg:color(0, 0, 150)
  self.sub_target.health_bar_bg:size(self.config.bar_width, 15)
  self.sub_target.health_bar_bg:width(self.config.bar_width)
  self.sub_target.health_bar_bg:path(windower.addon_path .. 'bar_bg_1.png')
  self.sub_target.health_bar_bg:fit(true)
  self.sub_target.health_bar_bg:repeat_xy(1, 1)
  tempx, tempy = self.sub_target.text:pos()
  self.sub_target.health_bar_bg:pos(tempx, tempy + 20)
  self.sub_target.health_bar_bg:hide()

  self.sub_target.health_bar_fg = images.new({
    flags = {
      draggable = false
    }
  })
  self.sub_target.health_bar_fg:alpha(255)
  self.sub_target.health_bar_fg:color(120, 120, 255)
  self.sub_target.health_bar_fg:size(self.config.bar_width, 15)
  self.sub_target.health_bar_fg:width(self.config.bar_width)
  self.sub_target.health_bar_fg:path(windower.addon_path .. 'bar_fg_1.png')
  self.sub_target.health_bar_fg:fit(true)
  self.sub_target.health_bar_fg:repeat_xy(1, 1)
  tempx, tempy = self.sub_target.text:pos()
  self.sub_target.health_bar_fg:pos(tempx, tempy + 20)
  self.sub_target.health_bar_fg:hide()

  -- sub_target health bar text
  self.sub_target.health_bar_text = texts.new({
    flags = {
      draggable = false
    }
  })

  self.sub_target.health_bar_text:font('Calibri')
  self.sub_target.health_bar_text:alpha(255)
  self.sub_target.health_bar_text:stroke_transparency(0)
  self.sub_target.health_bar_text:stroke_width(2)
  self.sub_target.health_bar_text:stroke_color(0, 0, 0)
  self.sub_target.health_bar_text:color(255, 255, 255)
  self.sub_target.health_bar_text:bg_visible(false)
  tempx, tempy = self.sub_target.health_bar_fg:pos()
  self.sub_target.health_bar_text:pos(tempx - 28, tempy - 3)
  self.sub_target.health_bar_text:hide()

  ------------------------------------------------------------------
  -- battle target
  ------------------------------------------------------------------
  -- battle target text
  self.battle_target.text = texts.new({
    flags = {
      draggable = false
    }
  })

  self.battle_target.text:font('Calibri')
  self.battle_target.text:alpha(255)
  self.battle_target.text:stroke_transparency(0)
  self.battle_target.text:stroke_width(2)
  self.battle_target.text:stroke_color(255, 0, 0)
  self.battle_target.text:color(255, 255, 255)
  self.battle_target.text:bg_visible(false)
  self.battle_target.text:pos(center_x + 130, center_y + 65)
  self.battle_target.text:hide()

  self.isCreated = true
end

function ui:show()
  self.isVisible = true
  -- no need to actually show all items since the gui loop will do it next tick
end

function ui:hide()
  self.isVisible = false


  self.player.text:hide()
  self.player.health_bar_bg:hide()
  self.player.health_bar_fg:hide()
  self.player.health_bar_text:hide()
  self.player.magic_bar_bg:hide()
  self.player.magic_bar_fg:hide()
  self.player.magic_bar_text:hide()
  self.player.tp_bar_bg:hide()
  self.player.tp_bar_fg:hide()
  self.player.tp_bar_text:hide()

  self.target.text:hide()
  self.target.health_bar_bg:hide()
  self.target.health_bar_fg:hide()
  self.target.health_bar_text:hide()
  self.target.locked_text:hide()

  self.sub_target.text:hide()
  self.sub_target.health_bar_bg:hide()
  self.sub_target.health_bar_fg:hide()
  self.sub_target.health_bar_text:hide()

  self.battle_target.text:hide()
end

function ui:update_player_frame(player)
  self.player.text:text(player.name)

  -- set bar size and text
  self.player.health_bar_text:text(tostring(player.vitals.hp))
  self.player.health_bar_bg:width(self.config.bar_width)
  self.player.health_bar_fg:width(self.config.bar_width * (player.vitals.hpp / 100))
  self.player.magic_bar_text:text(tostring(player.vitals.mp))
  self.player.magic_bar_bg:width(self.config.bar_width)
  self.player.magic_bar_fg:width(self.config.bar_width * (player.vitals.mpp / 100))
  self.player.tp_bar_text:text(tostring(player.vitals.tp))
  self.player.tp_bar_bg:width(self.config.bar_width)
  self.player.tp_bar_fg:width(self.config.bar_width * (math.min(1000, player.vitals.tp) / 1000))
end

--- stuff happening
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

local function set_text_color_and_name_and_type_from_mob(mob_data, text_object)
  if mob_data == nil then
    return
  end

  local type_text = nil

  --print('id=' .. mob_data.id .. ' ' ..
  --  'is_npc=' .. tostring(mob_data.is_npc) .. ' ' ..
  --  'spawn_type=' .. mob_data.spawn_type .. ' '
  --)

  if mob_data.id == windower.ffxi.get_player().id then
    text_object:color(255, 255, 255)
    type_text = 'you'
  elseif mob_data.hpp == 0 then
    text_object:color(188, 188, 188)
    type_text = 'dead'
  elseif mob_data.in_party == true then
    text_object:color(195, 255, 255)
    type_text = 'party'
  elseif mob_data.in_alliance == true then
    text_object:color(211, 255, 255)
    type_text = 'ally'
  elseif mob_data.is_npc == true then
    if mob_data.spawn_type == 2 then
      -- npc
      text_object:color(193, 254, 193)
      type_text = 'npc'
    elseif mob_data.spawn_type == 34 then
      -- interactive object
      text_object:color(193, 254, 193)
      type_text = 'obj'
    else
      -- monster of some kind
      if mob_data.claim_id ~= 0 then
        if is_claimed_by_you(mob_data.claim_id) == true then
          text_object:color(244, 124, 124)
          type_text = 'claim'
        else
          text_object:color(255, 130, 255)
          type_text = 'o.claim'
        end
      else
        -- normal unclaimed mob
        text_object:color(255, 255, 194)
        type_text = 'mob'
      end
    end
  else
    text_object:color(255, 255, 255)
    type_text = 'pc'
  end

  local name_text = mob_data.name
  if type_text ~= nil then
    name_text = mob_data.name .. ' (' .. type_text .. ')'
  end
  text_object:text(name_text)
end

function ui:update_gui()
  if self.isCreated == false or self.isVisible == false then
    return
  end

  -- nil is no target
  local player = windower.ffxi.get_player()
  local target = windower.ffxi.get_mob_by_target('t')
  local sub_target = windower.ffxi.get_mob_by_target('st')
  local battle_target = windower.ffxi.get_mob_by_target('bt')

  if player ~= nil then
    if self.config.only_show_player_frame_in_combat == false or (self.config.only_show_player_frame_in_combat == true and player.in_combat == true) then
      self:update_player_frame(player)
      self.player.text:show()
      self.player.health_bar_bg:show()
      self.player.health_bar_fg:show()
      self.player.health_bar_text:show()
      self.player.magic_bar_bg:show()
      self.player.magic_bar_fg:show()
      self.player.magic_bar_text:show()
      self.player.tp_bar_bg:show()
      self.player.tp_bar_fg:show()
      self.player.tp_bar_text:show()
    else
      self.player.text:hide()
      self.player.health_bar_bg:hide()
      self.player.health_bar_fg:hide()
      self.player.health_bar_text:hide()
      self.player.magic_bar_bg:hide()
      self.player.magic_bar_fg:hide()
      self.player.magic_bar_text:hide()
      self.player.tp_bar_bg:hide()
      self.player.tp_bar_fg:hide()
      self.player.tp_bar_text:hide()
    end
  end

  if target ~= nil then
    set_text_color_and_name_and_type_from_mob(target, self.target.text)

    -- set bar size and text
    self.target.health_bar_text:text(tostring(target.hpp) .. '%')
    self.target.health_bar_bg:width(self.config.bar_width)
    self.target.health_bar_fg:width(self.config.bar_width * (target.hpp / 100))

    self.target.text:show()
    self.target.health_bar_bg:show()
    self.target.health_bar_fg:show()
    self.target.health_bar_text:show()

    if windower.ffxi.get_player().target_locked == true then
      self.target.locked_text:show()
    else
      self.target.locked_text:hide()
    end
  else
    self.target.text:text('')
    self.target.text:hide()
    self.target.health_bar_bg:hide()
    self.target.health_bar_fg:hide()
    self.target.health_bar_text:hide()
    self.target.locked_text:hide()
  end

  if sub_target ~= nil then
    set_text_color_and_name_and_type_from_mob(sub_target, self.sub_target.text)
    local name = self.sub_target.text:text()
    self.sub_target.text:text('ST >> ' .. name)

    -- set bar size and text
    self.sub_target.health_bar_text:text(tostring(sub_target.hpp) .. '%')
    self.sub_target.health_bar_bg:width(self.config.bar_width)
    self.sub_target.health_bar_fg:width(self.config.bar_width * (sub_target.hpp / 100))

    self.sub_target.text:show()
    self.sub_target.health_bar_bg:show()
    self.sub_target.health_bar_fg:show()
    self.sub_target.health_bar_text:show()
  else
    self.sub_target.text:text('')
    self.sub_target.text:hide()
    self.sub_target.health_bar_bg:hide()
    self.sub_target.health_bar_fg:hide()
    self.sub_target.health_bar_text:hide()
  end

  if battle_target ~= nil and battle_target.hpp > 0 and (target == nil or (target ~= nil and battle_target.id ~= target.id)) then
    self.battle_target.text:text('BT >> ' .. battle_target.name)
    self.battle_target.text:show()
  else
    self.battle_target.text:text('')
    self.battle_target.text:hide()
  end
end

function ui:handle_click(type, x, y, delta)
  -- left click
  if type == 1 then
    -- moused on the battle text
    if self.battle_target.text:hover(x, y) == true then
      if windower.ffxi.get_player().in_combat == true then
        -- currently attacking, so switch attacking target
        windower.chat.input('/attack <bt>')
        windower.chat.input('/target <bt>')
      else
        -- just re-target
        windower.chat.input('/target <bt>')
      end
    end
  end
end

return ui
