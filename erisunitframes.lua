--[[    BSD License Disclaimer

        Redistribution and use in source and binary forms, with or without
        modification, are permitted provided that the following conditions are met:

            * Redistributions of source code must retain the above copyright
              notice, this list of conditions and the following disclaimer.
            * Redistributions in binary form must reproduce the above copyright
              notice, this list of conditions and the following disclaimer in the
              documentation and/or other materials provided with the distribution.
            * Neither the name of ui.xivhotbar/xivhotbar2 nor the
              names of its contributors may be used to endorse or promote products
              derived from this software without specific prior written permission.

        THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
        ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
        WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
        DISCLAIMED. IN NO EVENT SHALL SirEdeonX OR Akirane BE LIABLE FOR ANY
        DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
        (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
        LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
        ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
        (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
        SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]


_addon.name = 'ErisUnitFrames'
_addon.author = 'Sabarjp'
_addon.version = '0.1'
_addon.language = 'english'
_addon.commands = {}

texts = require('texts')
images = require('images')

-- config
local bar_width = 170

-- initial load
local center_x = (windower.get_windower_settings().ui_x_res / 2)
local center_y = (windower.get_windower_settings().ui_y_res / 2)

local tempx, tempy

-- target
-- target text
local target_text = texts.new({
  flags = {
    draggable = true
  }
})

target_text:font('Calibri')
target_text:alpha(255)
target_text:stroke_transparency(0)
target_text:stroke_width(2)
target_text:stroke_color(0, 0, 0)
target_text:color(255, 255, 255)
target_text:bg_visible(false)
target_text:pos(center_x + 100, center_y + 130)
target_text:hide()

-- target health bar
local target_health_bar_bg = images.new({
  flags = {
    draggable = false
  }
})
target_health_bar_bg:alpha(255)
target_health_bar_bg:color(150, 0, 0)
target_health_bar_bg:size(bar_width, 15)
target_health_bar_bg:width(bar_width)
target_health_bar_bg:path(windower.addon_path .. 'bar_bg_1.png')
target_health_bar_bg:fit(true)
target_health_bar_bg:repeat_xy(1, 1)
tempx, tempy = target_text:pos()
target_health_bar_bg:pos(tempx, tempy + 20)
target_health_bar_bg:hide()

local target_health_bar_fg = images.new({
  flags = {
    draggable = false
  }
})
target_health_bar_fg:alpha(255)
target_health_bar_fg:color(227, 118, 118)
target_health_bar_fg:size(bar_width, 15)
target_health_bar_fg:width(bar_width)
target_health_bar_fg:path(windower.addon_path .. 'bar_fg_1.png')
target_health_bar_fg:fit(true)
target_health_bar_fg:repeat_xy(1, 1)
tempx, tempy = target_text:pos()
target_health_bar_fg:pos(tempx, tempy + 20)
target_health_bar_fg:hide()

-- target health bar text
local target_health_bar_text = texts.new({
  flags = {
    draggable = false
  }
})

target_health_bar_text:font('Calibri')
target_health_bar_text:alpha(255)
target_health_bar_text:stroke_transparency(0)
target_health_bar_text:stroke_width(2)
target_health_bar_text:stroke_color(0, 0, 0)
target_health_bar_text:color(255, 255, 255)
target_health_bar_text:bg_visible(false)
tempx, tempy = target_health_bar_fg:pos()
target_health_bar_text:pos(tempx - 28, tempy - 3)
target_health_bar_text:hide()

-- target lock text
local target_locked_text = texts.new({
  flags = {
    draggable = false
  }
})

target_locked_text:font('Calibri')
target_locked_text:alpha(255)
target_locked_text:stroke_transparency(0)
target_locked_text:stroke_width(2)
target_locked_text:stroke_color(0, 0, 0)
target_locked_text:color(232, 60, 60)
target_locked_text:text('> LOCKED <')
target_locked_text:bg_visible(false)
tempx, tempy = target_text:pos()
target_locked_text:pos(tempx, tempy - 16)
target_locked_text:hide()

-- sub target
-- sub target text
local sub_target_text = texts.new({
  flags = {
    draggable = false
  }
})

sub_target_text:font('Calibri')
sub_target_text:alpha(255)
sub_target_text:stroke_transparency(0)
sub_target_text:stroke_width(2)
sub_target_text:stroke_color(120, 120, 255)
sub_target_text:color(255, 0, 255)
sub_target_text:bg_visible(false)
sub_target_text:pos(center_x + 100, center_y + 85)
sub_target_text:hide()

-- sub_target health bar
local sub_target_health_bar_bg = images.new({
  flags = {
    draggable = false
  }
})
sub_target_health_bar_bg:alpha(255)
sub_target_health_bar_bg:color(0, 0, 150)
sub_target_health_bar_bg:size(bar_width, 15)
sub_target_health_bar_bg:width(bar_width)
sub_target_health_bar_bg:path(windower.addon_path .. 'bar_bg_1.png')
sub_target_health_bar_bg:fit(true)
sub_target_health_bar_bg:repeat_xy(1, 1)
tempx, tempy = sub_target_text:pos()
sub_target_health_bar_bg:pos(tempx, tempy + 20)
sub_target_health_bar_bg:hide()

local sub_target_health_bar_fg = images.new({
  flags = {
    draggable = false
  }
})
sub_target_health_bar_fg:alpha(255)
sub_target_health_bar_fg:color(120, 120, 255)
sub_target_health_bar_fg:size(bar_width, 15)
sub_target_health_bar_fg:width(bar_width)
sub_target_health_bar_fg:path(windower.addon_path .. 'bar_fg_1.png')
sub_target_health_bar_fg:fit(true)
sub_target_health_bar_fg:repeat_xy(1, 1)
tempx, tempy = sub_target_text:pos()
sub_target_health_bar_fg:pos(tempx, tempy + 20)
sub_target_health_bar_fg:hide()

-- sub_target health bar text
local sub_target_health_bar_text = texts.new({
  flags = {
    draggable = false
  }
})

sub_target_health_bar_text:font('Calibri')
sub_target_health_bar_text:alpha(255)
sub_target_health_bar_text:stroke_transparency(0)
sub_target_health_bar_text:stroke_width(2)
sub_target_health_bar_text:stroke_color(0, 0, 0)
sub_target_health_bar_text:color(255, 255, 255)
sub_target_health_bar_text:bg_visible(false)
tempx, tempy = sub_target_health_bar_fg:pos()
sub_target_health_bar_text:pos(tempx - 28, tempy - 3)
sub_target_health_bar_text:hide()

-- battle target
-- battle target text
local battle_target_text = texts.new({
  flags = {
    draggable = false
  }
})

battle_target_text:font('Calibri')
battle_target_text:alpha(255)
battle_target_text:stroke_transparency(0)
battle_target_text:stroke_width(2)
battle_target_text:stroke_color(255, 0, 0)
battle_target_text:color(255, 255, 255)
battle_target_text:bg_visible(false)
battle_target_text:pos(center_x + 130, center_y + 65)
battle_target_text:hide()


--- debug
---
windower.register_event('incoming chunk', function(id, original, modified, injected, blocked)
  --print('in ' .. id)
end)

windower.register_event('outgoing chunk', function(id, original, modified, injected, blocked)
  if (id == 21) then
    --print('target_locked=' .. tostring(windower.ffxi.get_player().target_locked))
  else
    --print('out ' .. id)
  end
end)

windower.register_event('status change', function(new_status_id, old_status_id)
  --print('status ' .. new_status_id)
end)

--- stuff happening
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

local function set_text_color_and_name_and_type(mob_data, text_object)
  if mob_data == nil then
    return
  end

  local type_text = nil

  if mob_data.id == windower.ffxi.get_player().id then
    text_object:color(255, 255, 255)
    type_text = 'you'
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

local function update_gui()
  -- nil is no target
  local target = windower.ffxi.get_mob_by_target('t')
  local sub_target = windower.ffxi.get_mob_by_target('st')
  local battle_target = windower.ffxi.get_mob_by_target('bt')


  if target ~= nil then
    set_text_color_and_name_and_type(target, target_text)

    -- set bar size and text
    target_health_bar_text:text(tostring(target.hpp))
    target_health_bar_bg:width(bar_width)
    target_health_bar_fg:width(bar_width * (target.hpp / 100))

    target_text:show()
    target_health_bar_bg:show()
    target_health_bar_fg:show()
    target_health_bar_text:show()

    if windower.ffxi.get_player().target_locked == true then
      target_locked_text:show()
    else
      target_locked_text:hide()
    end
  else
    target_text:text('')
    target_text:hide()
    target_health_bar_bg:hide()
    target_health_bar_fg:hide()
    target_health_bar_text:hide()
    target_locked_text:hide()
  end

  if sub_target ~= nil then
    set_text_color_and_name_and_type(sub_target, sub_target_text)
    local name = sub_target_text:text()
    sub_target_text:text('ST >> ' .. name)

    -- set bar size and text
    sub_target_health_bar_text:text(tostring(sub_target.hpp))
    sub_target_health_bar_bg:width(bar_width)
    sub_target_health_bar_fg:width(bar_width * (sub_target.hpp / 100))

    sub_target_text:show()
    sub_target_health_bar_bg:show()
    sub_target_health_bar_fg:show()
    sub_target_health_bar_text:show()
  else
    sub_target_text:text('')
    sub_target_text:hide()
    sub_target_health_bar_bg:hide()
    sub_target_health_bar_fg:hide()
    sub_target_health_bar_text:hide()
  end

  if battle_target ~= nil and battle_target.hpp > 0 and (target == nil or (target ~= nil and battle_target.id ~= target.id)) then
    battle_target_text:text('BT >> ' .. battle_target.name)
    battle_target_text:show()
  else
    battle_target_text:text('')
    battle_target_text:hide()
  end
end

-- click events
windower.register_event('mouse', function(type, x, y, delta, blocked)
  if blocked then
    return
  end

  -- left click
  if type == 1 then
    -- moused on the battle text
    if battle_target_text:hover(x, y) == true then
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
end)

windower.register_event('target change', function(index)
  update_gui()
end)

windower.register_event('prerender', function()
  update_gui()
end)
