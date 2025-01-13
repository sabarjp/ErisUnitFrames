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
_addon.commands = {}

texts = require('texts')     -- global from windower
images = require('images')   -- global from windower
packets = require('packets') -- global from windower
res = require('resources')   -- global from windower
config = require('config')   -- global from windower

bar = require('bar')
local ui = require('ui')
local isLoaded = false

-- initial load
windower.register_event('load', function()
  if isLoaded == false then
    isLoaded = true

    --  load up settings
    local defaults = require('defaults')
    local settings = config.load(defaults)
    config.save(settings)

    ui:initialize(settings)
  end
end)

windower.register_event('login', function()
  if isLoaded == false then
    isLoaded = true

    --  load up settings
    local defaults = require('defaults')
    local settings = config.load(defaults)
    config.save(settings)

    ui:initialize(settings)
  end
end)


-- click events
windower.register_event('mouse', function(type, x, y, delta, blocked)
  local ret = nil
  if blocked or type == 0 then
    return ret
  end

  if isLoaded then
    ret = ui:handle_click(type, x, y, delta)
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
