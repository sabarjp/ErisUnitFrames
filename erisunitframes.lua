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

texts = require('texts')     -- global from windower
images = require('images')   -- global from windower
packets = require('packets') -- global from windower
res = require('resources')   -- global from windower
bar = require('bar')
local ui = require('ui')
local isLoaded = false

-- config
local config = {
  player = {
    disabled = false,
    only_show_in_combat = false,
    actions = {
      on_left_click = '/target <me>'
    },
    pos = {
      relative_to = 'center', -- center or topleft
      x           = -200,
      y           = 130
    },
    nameplate = {
      disabled = false,
      text = {
        font = 'Calibri',
        size = 12,
        alpha = 255,
        red = 255,
        green = 255,
        blue = 255,
        stroke = {
          alpha = 200,
          red = 0,
          green = 0,
          blue = 0,
          width = 1.4
        }
      },
      rel_pos = {
        x = 0,
        y = 0
      }
    },
    health_bar = {
      disabled = false,
      width = 150,
      height = 15,
      text = {
        disabled = false,
        font = 'Calibri',
        offset = {
          x = 0,
          y = 0
        },
        right_aligned = true,
        size = 12,
        alpha = 255,
        red = 255,
        green = 255,
        blue = 255,
        stroke = {
          alpha = 128,
          red = 0,
          green = 0,
          blue = 0,
          width = 2
        }
      },
      foreground = {
        disabled = false,
        alpha = 255,
        red = 250,
        green = 140,
        blue = 140,
      },
      background = {
        disabled = false,
        alpha = 128,
        red = 150,
        green = 150,
        blue = 150,
      },
      rel_pos = {
        x = 0,
        y = 20
      }
    },
    magic_bar = {
      disabled = false,
      width = 105,
      height = 12,
      text = {
        disabled = false,
        font = 'Calibri',
        offset = {
          x = 0,
          y = 0
        },
        right_aligned = true,
        size = 11,
        alpha = 255,
        red = 255,
        green = 255,
        blue = 255,
        stroke = {
          alpha = 128,
          red = 0,
          green = 0,
          blue = 0,
          width = 2
        }
      },
      foreground = {
        disabled = false,
        alpha = 255,
        red = 203,
        green = 201,
        blue = 134,
      },
      background = {
        disabled = false,
        alpha = 128,
        red = 150,
        green = 150,
        blue = 150,
      },
      rel_pos = {
        x = 45,
        y = 38
      }
    },
    tp_bar = {
      disabled = false,
      width = 150,
      height = 5,
      text = {
        disabled = false,
        font = 'Calibri',
        offset = {
          x = 0,
          y = 0
        },
        right_aligned = false,
        size = 11,
        alpha = 255,
        red = 255,
        green = 255,
        blue = 255,
        stroke = {
          alpha = 128,
          red = 0,
          green = 0,
          blue = 0,
          width = 2
        }
      },
      foreground = {
        disabled = false,
        alpha = 255,
        red = 155,
        green = 185,
        blue = 185,
        full_red = 55,
        full_green = 145,
        full_blue = 245
      },
      background = {
        disabled = false,
        alpha = 128,
        red = 150,
        green = 150,
        blue = 150,
      },
      rel_pos = {
        x = 0,
        y = 34
      }
    }
  },
  pet = {
    disabled = false,
    only_show_in_combat = false,
    actions = {
      on_left_click = '/target <pet>'
    },
    pos = {
      relative_to = 'center', -- center or topleft
      x           = -400,
      y           = 130
    },
    nameplate = {
      disabled = false,
      text = {
        font = 'Calibri',
        size = 12,
        alpha = 255,
        red = 195,
        green = 255,
        blue = 255,
        stroke = {
          alpha = 200,
          red = 0,
          green = 0,
          blue = 0,
          width = 1.4
        }
      },
      rel_pos = {
        x = 0,
        y = 0
      }
    },
    health_bar = {
      disabled = false,
      width = 100,
      height = 15,
      text = {
        disabled = false,
        font = 'Calibri',
        offset = {
          x = 0,
          y = 0
        },
        right_aligned = true,
        size = 12,
        alpha = 255,
        red = 255,
        green = 255,
        blue = 255,
        stroke = {
          alpha = 128,
          red = 0,
          green = 0,
          blue = 0,
          width = 2
        }
      },
      foreground = {
        disabled = false,
        alpha = 255,
        red = 250,
        green = 140,
        blue = 140
      },
      background = {
        disabled = false,
        alpha = 128,
        red = 150,
        green = 150,
        blue = 150,
      },
      rel_pos = {
        x = 0,
        y = 20
      }
    },
    magic_bar = {
      disabled = false,
      width = 65,
      height = 12,
      text = {
        disabled = false,
        font = 'Calibri',
        offset = {
          x = 0,
          y = 0
        },
        right_aligned = true,
        size = 11,
        alpha = 255,
        red = 255,
        green = 255,
        blue = 255,
        stroke = {
          alpha = 128,
          red = 0,
          green = 0,
          blue = 0,
          width = 2
        }
      },
      foreground = {
        disabled = false,
        alpha = 255,
        red = 203,
        green = 201,
        blue = 134,
      },
      background = {
        disabled = false,
        alpha = 128,
        red = 150,
        green = 150,
        blue = 150,
      },
      rel_pos = {
        x = 35,
        y = 38
      }
    },
    tp_bar = {
      disabled = false,
      width = 100,
      height = 4,
      text = {
        disabled = false,
        font = 'Calibri',
        offset = {
          x = 0,
          y = 0
        },
        right_aligned = false,
        size = 11,
        alpha = 255,
        red = 255,
        green = 255,
        blue = 255,
        stroke = {
          alpha = 128,
          red = 0,
          green = 0,
          blue = 0,
          width = 2
        }
      },
      foreground = {
        disabled = false,
        alpha = 255,
        red = 155,
        green = 185,
        blue = 185,
        full_red = 55,
        full_green = 145,
        full_blue = 245
      },
      background = {
        disabled = false,
        alpha = 128,
        red = 150,
        green = 150,
        blue = 150,
      },
      rel_pos = {
        x = 0,
        y = 35
      }
    }
  },
  target = {
    disabled = false,
    only_show_in_combat = false,
    actions = {
      on_right_click = '/check <t>'
    },
    pos = {
      relative_to = 'center', -- center or topleft
      x           = 100,
      y           = 130
    },
    nameplate = {
      disabled = false,
      text = {
        font = 'Calibri',
        size = 12,
        alpha = 255,
        use_dynamic_colors = true,
        red = 255,
        green = 255,
        blue = 255,
        stroke = {
          alpha = 200,
          red = 0,
          green = 0,
          blue = 0,
          width = 1.4
        }
      },
      rel_pos = {
        x = 0,
        y = 0
      }
    },
    health_bar = {
      disabled = false,
      width = 150,
      height = 15,
      text = {
        disabled = false,
        font = 'Calibri',
        offset = {
          x = 0,
          y = 0
        },
        right_aligned = true,
        size = 12,
        alpha = 255,
        red = 255,
        green = 255,
        blue = 255,
        stroke = {
          alpha = 128,
          red = 0,
          green = 0,
          blue = 0,
          width = 2
        }
      },
      foreground = {
        disabled = false,
        alpha = 255,
        use_dynamic_colors = true,
        red = 250,
        green = 140,
        blue = 140,
      },
      background = {
        disabled = false,
        alpha = 128,
        red = 150,
        green = 150,
        blue = 150,
      },
      rel_pos = {
        x = 0,
        y = 20
      }
    },
    locked_text = {
      disabled = false,
      text = {
        font = 'Calibri',
        size = 12,
        alpha = 255,
        red = 232,
        green = 60,
        blue = 60,
        stroke = {
          alpha = 128,
          red = 0,
          green = 0,
          blue = 0,
          width = 2
        }
      },
      rel_pos = {
        x = 0,
        y = -16
      }
    }
  },
  sub_target = {
    disabled = false,
    only_show_in_combat = false,
    pos = {
      relative_to = 'center', -- center or topleft
      x           = 100,
      y           = 80
    },
    nameplate = {
      disabled = false,
      text = {
        font = 'Calibri',
        size = 12,
        alpha = 255,
        red = 255,
        green = 255,
        blue = 255,
        stroke = {
          alpha = 255,
          red = 120,
          green = 120,
          blue = 255,
          width = 2
        }
      },
      rel_pos = {
        x = 0,
        y = 0
      }
    },
    health_bar = {
      disabled = false,
      width = 150,
      height = 15,
      text = {
        disabled = false,
        font = 'Calibri',
        offset = {
          x = 0,
          y = 0
        },
        right_aligned = true,
        size = 12,
        alpha = 255,
        use_dynamic_colors = false,
        red = 255,
        green = 255,
        blue = 255,
        stroke = {
          alpha = 128,
          red = 0,
          green = 0,
          blue = 0,
          width = 2
        }
      },
      foreground = {
        disabled = false,
        alpha = 255,
        use_dynamic_colors = true,
        red = 120,
        green = 120,
        blue = 255,
      },
      background = {
        disabled = false,
        alpha = 128,
        red = 150,
        green = 150,
        blue = 150,
      },
      rel_pos = {
        x = 0,
        y = 20
      }
    }
  },
  battle_target = {
    disabled = false,
    actions = {
      on_left_click = '/attack <bt>',
      on_right_click = '/target <bt>'
    },
    pos = {
      relative_to = 'center', -- center or topleft
      x           = 130,
      y           = 55
    },
    nameplate = {
      disabled = false,
      text = {
        font = 'Calibri',
        size = 12,
        alpha = 255,
        red = 255,
        green = 255,
        blue = 255,
        stroke = {
          alpha = 255,
          red = 255,
          green = 0,
          blue = 0,
          width = 2
        }
      },
      rel_pos = {
        x = 0,
        y = 0
      }
    },
  },
  party = {
    disabled = false,
    only_show_in_combat = false,
    actions = {
      on_left_click = '/target %this'
    },
    pos = {
      relative_to = 'center', -- center or topleft
      x           = -700,
      y           = -130,
      offset_x    = 0,
      offset_y    = 60
    },
    nameplate = {
      disabled = false,
      text = {
        font = 'Calibri',
        size = 12,
        alpha = 255,
        red = 255,
        green = 255,
        blue = 255,
        stroke = {
          alpha = 200,
          red = 0,
          green = 0,
          blue = 0,
          width = 1.4
        }
      },
      rel_pos = {
        x = 0,
        y = 0
      }
    },
    health_bar = {
      disabled = false,
      width = 110,
      height = 15,
      text = {
        disabled = false,
        font = 'Calibri',
        offset = {
          x = 0,
          y = 0
        },
        right_aligned = true,
        size = 12,
        alpha = 255,
        red = 255,
        green = 255,
        blue = 255,
        stroke = {
          alpha = 128,
          red = 0,
          green = 0,
          blue = 0,
          width = 2
        }
      },
      foreground = {
        disabled = false,
        alpha = 255,
        red = 250,
        green = 140,
        blue = 140,
      },
      background = {
        disabled = false,
        alpha = 128,
        red = 150,
        green = 150,
        blue = 150,
      },
      rel_pos = {
        x = 12,
        y = 12
      }
    },
    magic_bar = {
      disabled = false,
      width = 70,
      height = 12,
      text = {
        disabled = false,
        font = 'Calibri',
        offset = {
          x = 0,
          y = 0
        },
        right_aligned = true,
        size = 11,
        alpha = 255,
        red = 255,
        green = 255,
        blue = 255,
        stroke = {
          alpha = 128,
          red = 0,
          green = 0,
          blue = 0,
          width = 2
        }
      },
      foreground = {
        disabled = false,
        alpha = 255,
        red = 203,
        green = 201,
        blue = 134,
      },
      background = {
        disabled = false,
        alpha = 128,
        red = 150,
        green = 150,
        blue = 150,
      },
      rel_pos = {
        x = 52,
        y = 29
      }
    },
    tp_bar = {
      disabled = false,
      blink_when_full = true,
      width = 110,
      height = 4,
      text = {
        disabled = false,
        font = 'Calibri',
        offset = {
          x = 0,
          y = 2
        },
        right_aligned = false,
        size = 11,
        alpha = 255,
        red = 255,
        green = 255,
        blue = 255,
        stroke = {
          alpha = 128,
          red = 0,
          green = 0,
          blue = 0,
          width = 2
        }
      },
      foreground = {
        disabled = false,
        alpha = 255,
        red = 155,
        green = 185,
        blue = 185,
        full_red = 55,
        full_green = 145,
        full_blue = 245
      },
      background = {
        disabled = false,
        alpha = 128,
        red = 150,
        green = 150,
        blue = 150,
      },
      rel_pos = {
        x = 12,
        y = 26
      }
    }
  },
  alliance = {
    disabled = false,
    only_show_in_combat = false,
    actions = {
      on_left_click = '/target %this'
    },
    pos = {
      relative_to = 'center', -- center or topleft
      x           = -800,
      y           = -130,
      offset_x    = 0,
      offset_y    = 60,
      grouping    = 6,
      grouping_x  = -100,
      grouping_y  = 0,
    },
    nameplate = {
      disabled = false,
      text = {
        font = 'Calibri',
        size = 12,
        alpha = 255,
        red = 255,
        green = 255,
        blue = 255,
        stroke = {
          alpha = 200,
          red = 0,
          green = 0,
          blue = 0,
          width = 1.4
        }
      },
      rel_pos = {
        x = 0,
        y = 0
      }
    },
    health_bar = {
      disabled = false,
      width = 70,
      height = 38,
      text = {
        disabled = false,
        font = 'Calibri',
        offset = {
          x = 0,
          y = 19
        },
        right_aligned = true,
        size = 12,
        alpha = 255,
        red = 255,
        green = 255,
        blue = 255,
        stroke = {
          alpha = 128,
          red = 0,
          green = 0,
          blue = 0,
          width = 2
        }
      },
      foreground = {
        disabled = false,
        alpha = 255,
        red = 250,
        green = 140,
        blue = 140,
      },
      background = {
        disabled = false,
        alpha = 128,
        red = 150,
        green = 150,
        blue = 150,
      },
      rel_pos = {
        x = 0,
        y = 0
      }
    },
    magic_bar = {
      disabled = false,
      width = 70,
      height = 8,
      text = {
        disabled = false,
        font = 'Calibri',
        offset = {
          x = 0,
          y = 0
        },
        right_aligned = true,
        size = 11,
        alpha = 255,
        red = 255,
        green = 255,
        blue = 255,
        stroke = {
          alpha = 128,
          red = 0,
          green = 0,
          blue = 0,
          width = 2
        }
      },
      foreground = {
        disabled = false,
        alpha = 255,
        red = 203,
        green = 201,
        blue = 134,
      },
      background = {
        disabled = false,
        alpha = 128,
        red = 150,
        green = 150,
        blue = 150,
      },
      rel_pos = {
        x = 0,
        y = 34
      }
    },
    tp_bar = {
      disabled = false,
      blink_when_full = true,
      width = 70,
      height = 4,
      text = {
        disabled = false,
        font = 'Calibri',
        offset = {
          x = -8,
          y = -4
        },
        right_aligned = false,
        size = 11,
        alpha = 255,
        red = 255,
        green = 255,
        blue = 255,
        stroke = {
          alpha = 128,
          red = 0,
          green = 0,
          blue = 0,
          width = 2
        }
      },
      foreground = {
        disabled = true,
        alpha = 255,
        red = 155,
        green = 185,
        blue = 185,
        full_red = 55,
        full_green = 145,
        full_blue = 245
      },
      background = {
        disabled = true,
        alpha = 128,
        red = 150,
        green = 150,
        blue = 150,
      },
      rel_pos = {
        x = 0,
        y = 26
      }
    }
  }
}


-- initial load
windower.register_event('load', function()
  if isLoaded == false then
    isLoaded = true
    ui:initialize(config)
  end
end)

windower.register_event('login', function()
  if isLoaded == false then
    isLoaded = true
    ui:initialize(config)
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
