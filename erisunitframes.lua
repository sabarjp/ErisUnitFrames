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
_addon.version = '1.1'
_addon.language = 'english'
_addon.command = 'euf'

texts = require('texts')     -- global from windower
images = require('images')   -- global from windower
packets = require('packets') -- global from windower
res = require('resources')   -- global from windower
config = require('config')   -- global from windower

defaults = require('defaults')
bar = require('bar')
buffs = require('buffs')
ui = require('ui')
ja_overwrites = require('ja_overwrites')
stackable_spells = require('stackable_spells')
blocking_spells = require('blocking_spells')
status_effects = require('status_effects')

local isLoaded = false

local function initialize()
  --  load up settings
  local settings = config.load(defaults)
  local success, theme = pcall(require, 'themes/' .. settings.theme)
  if not success then
    windower.add_to_chat(8, 'EUF Failed to find: themes/' .. settings.theme .. '.lua')
  else
    config.save(settings)
    ui:initialize(settings, theme)
  end
end

-- initial load
windower.register_event('load', function()
  if isLoaded == false then
    isLoaded = true
    initialize()
  end
end)

windower.register_event('login', function()
  if isLoaded == false then
    isLoaded = true
    initialize()
  end
end)


-- click events
windower.register_event('mouse', function(type, x, y, delta, blocked)
  local ret = nil
  if blocked then
    return ret
  end

  if isLoaded then
    ret = ui:handle_mouse(type, x, y, delta)
  end
  return ret
end)

windower.register_event('target change', function(index)
  if isLoaded then
    ui:update_gui()
  end
end)

windower.register_event('prerender', function()
  if isLoaded then
    ui:update_gui()
  end
end)

windower.register_event('status change', function(new_status_id)
  -- hide/show bar in cutscenes --
  if new_status_id == 4 then
    ui:hide()
  else
    ui:show()
  end
end)

-- World is loaded or zoning
windower.register_event('incoming chunk', function(id, original, modified, injected, blocked)
  if id == 0x00B then     -- unload old zone
    ui:hide()
  elseif id == 0x00A then -- load new zone
    --ui:show()
  elseif id == 0x01D then -- complete load
    ui:show()
  end
end)

--Pet status update
windower.register_event('incoming chunk', function(id, original, modified, injected, blocked)
  if isLoaded == true then
    local packet = packets.parse('incoming', original)
    if id == 0x068 then
      if packet['Owner ID'] == windower.ffxi.get_player().id then
        ui:update_pet_tp(packet['Pet TP'])
        ui:update_pet_mp(packet['Current MP%'])
      end
    end
  end
end)


---- COMMANDS
windower.register_event('addon command', function(command, ...)
  local args = { ... }

  if not command or command:lower() == 'help' then
    windower.add_to_chat(8, '---------------------------------------------')
    windower.add_to_chat(8, 'ErisUnitFrames: //euf <command>')
    windower.add_to_chat(8, '> help: shows this message.')
    windower.add_to_chat(8, '> unlock: allows the UI elements to be moved with the mouse.')
    windower.add_to_chat(8, '> theme <x>: applies the theme file <x>.')
    windower.add_to_chat(8, '> lock: prevents the UI elements from being moved.')
    windower.add_to_chat(8, '> save: saves the current positions of the frames.')
    windower.add_to_chat(8, '> reset: loads the default settings, in case you want to go back.')
    windower.add_to_chat(8, '> reload: reloads the UI.')
  elseif command:lower() == 'lock' then
    ui.isLocked = true
    windower.add_to_chat(8, '---------------------------------------------')
    windower.add_to_chat(8, 'EUF components locked, click events re-enabled.')
    windower.add_to_chat(8, 'You must save to keep these changes.')
  elseif command:lower() == 'unlock' then
    ui.isLocked = false
    windower.add_to_chat(8, '---------------------------------------------')
    windower.add_to_chat(8, 'EUF components unlocked, you can move things.')
    windower.add_to_chat(8, 'You must lock, then save to keep these changes.')
  elseif command:lower() == 'save' then
    if ui.isLocked then
      config.save(ui.settings)
      windower.add_to_chat(8, '---------------------------------------------')
      windower.add_to_chat(8, 'EUF changes saved.')
    else
      windower.add_to_chat(8, '---------------------------------------------')
      windower.add_to_chat(8, 'You must lock EUF before saving!')
    end
  elseif command:lower() == 'theme' then
    if args[1] == nil then
      windower.add_to_chat(8, 'Missing theme name. Usage:')
      windower.add_to_chat(8, '  //euf theme <name>')
    else
      local theme_name = args[1]
      local success, theme = pcall(require, 'themes/' .. theme_name)
      if not success then
        windower.add_to_chat(8, 'EUF Failed to find: themes/' .. theme_name .. '.lua')
      else
        ui:destroy()

        local settings = config.load(defaults)
        ui:initialize(settings, theme)
        ui.settings.theme = theme_name
        windower.add_to_chat(8, '---------------------------------------------')
        windower.add_to_chat(8, 'Loaded theme: ' .. theme_name .. '.')
        windower.add_to_chat(8, 'You must save to keep these changes.')
      end
    end
  elseif command:lower() == 'reset' then
    --  load up default settings explicitly
    ui:destroy()

    local settings = defaults
    local theme = require('themes/' .. settings.theme)

    ui:initialize(settings, theme)

    windower.add_to_chat(8, '---------------------------------------------')
    windower.add_to_chat(8, 'Reset EUF settings to defaults.')
    windower.add_to_chat(8, 'You must save to keep these changes.')
  elseif command:lower() == 'reload' then
    windower.add_to_chat(8, '---------------------------------------------')
    windower.add_to_chat(8, 'Reloading EUF...')
    ui:destroy()
    initialize()
    windower.add_to_chat(8, 'Reload complete.')
  end
end)

-- icon_extractor = require('icon_extractor')
-- for id = 0, 633, 1 do
--   local icon_path = string.format('%sicons/%s.bmp', windower.addon_path, id)
--   if not windower.file_exists(icon_path) then
--     icon_extractor.buff_by_id(id, icon_path)
--   end
-- end

-- global helpers
function table_equals(t1, t2)
  if t1 == t2 then return true end
  if not t1 or not t2 then return false end
  if #t1 ~= #t2 then return false end
  for i = 1, #t1 do
    if t1[i] ~= t2[i] then return false end
  end
  return true
end
