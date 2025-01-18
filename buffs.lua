-- This class represents a buff area in the UI
buffs = {}
buffs.__index = buffs

-- Global singleton-style tooltip that will be shared among all buffs
buff_tooltip = nil

-- Constructor
function buffs:new(params)
  local instance             = setmetatable({}, buffs)

  -- internal variables
  instance._buffs            = {} -- keyed on buff id

  -- if we are currently hovering on a buff, it is this one
  instance._hovering_on_buff = {}

  instance._x                = params.x or 0
  instance._y                = params.y or 0
  instance._width            = params.width or 100
  instance._height           = params.height or 10
  instance._buff_width       = params.buff_width or 10
  instance._buff_height      = params.buff_height or 10
  instance._disable_tooltips = params.disable_tooltips or false
  instance._isVisible        = false

  -- class variables

  instance:init()
  return instance
end

function buffs:init()

end

-- must be ran after the rest of the UI is created for layering to work correctly.
function buffs:create_global_tooltip()
  if buff_tooltip == nil then
    buff_tooltip = texts.new({
      flags = { draggable = false },
    })

    buff_tooltip:font('Calibri')
    buff_tooltip:size(12)
    buff_tooltip:alpha(255)
    buff_tooltip:stroke_transparency(0.2)
    buff_tooltip:stroke_width(1.5)
    buff_tooltip:stroke_color(0, 0, 0)
    buff_tooltip:color(255, 255, 255)
    buff_tooltip:bg_alpha(128)
    buff_tooltip:bg_color(0, 0, 0)
    buff_tooltip:bg_visible(true)
    buff_tooltip:pad(2)
    buff_tooltip:draggable(false)
    buff_tooltip:hide()
  end
end

function buffs:destroy()
  for _, buff_data in pairs(self._buffs) do
    if buff_data.image then
      buff_data.image:destroy()
    end
    buff_data = nil
  end

  if self._tooltip then
    self._tooltip:destroy()
  end
  self._tooltip = nil
end

function buffs:components()
  local components = {}
  for _, buff_data in pairs(self._buffs) do
    table.insert(components, buff_data.image)
  end
  return components
end

function buffs:pos(x, y)
  if not x then
    return self._x, self._y
  end

  self._x = x
  self._y = y

  -- the buff images will update automatically on the next frame update
end

function buffs:pos_x(x)
  if not x then
    return self._x
  end

  self._x = x

  -- the buff images will update automatically on the next frame update
end

function buffs:pos_y(y)
  if not y then
    return self._y
  end

  self._y = y

  -- the buff images will update automatically on the next frame update
end

-- Helper function to calculate position of a buff based on index
local function calculate_buff_position(index, cols, buff_width, buff_height, buff_spacing, base_x, base_y)
  local col = (index - 1) % cols                        -- Column position
  local row = math.floor((index - 1) / cols)            -- Row position
  local x = base_x + col * (buff_width + buff_spacing)  -- X position
  local y = base_y + row * (buff_height + buff_spacing) -- Y position
  return x, y, row + 1                                  -- Return X, Y, and updated row count
end

-- Helper function to update tooltip text
local function update_tooltip(tooltip, hovering_buff)
  if not hovering_buff or not hovering_buff.id then return end

  local buff_name = hovering_buff.buff_name or 'Unknown'
  local spell_name = hovering_buff.originating_spell or 'Unknown'

  -- Convert remaining time to a readable format
  local readable_time
  if hovering_buff.remaining_time > 3600 then
    readable_time = string.format("%.0f hr", hovering_buff.remaining_time / 3600)
  elseif hovering_buff.remaining_time > 60 then
    local minutes = math.floor(hovering_buff.remaining_time / 60)
    local seconds = math.floor(hovering_buff.remaining_time % 60)
    readable_time = string.format("%d:%02d min", minutes, seconds)
  else
    readable_time = string.format("%.0f sec", hovering_buff.remaining_time)
  end

  if tooltip then
    if buff_name == spell_name then
      tooltip:text(string.format("%s\n%s", buff_name, readable_time))
    else
      tooltip:text(string.format("%s (%s)\n%s", buff_name, spell_name, readable_time))
    end
  end
end

-- Updates buffs as needed, and returns true if the list has changed in dimensions
function buffs:update_buffs(buffs)
  local changed = false
  local near_expiration_threshold = 15 -- seconds
  local blink_interval = 0.5           -- seconds for each blink animation phase
  local blink_phase = math.floor((os.clock() / blink_interval) % 2)

  -- Dimensions for wrapping
  local max_width = self._width
  local max_height = self._height
  local buff_spacing = 1                                                 -- Spacing between buffs
  local cols = math.floor(max_width / (self._buff_width + buff_spacing)) -- Number of buffs per row
  local rows = 0                                                         -- Track row count dynamically

  -- Remove buffs that are no longer active first
  for buff_key, buff_data in pairs(self._buffs) do
    if not (buffs and buffs[buff_key]) then
      -- Buff no longer exists, remove it
      if buff_data.image then
        buff_data.image:hide()
        buff_data.image:destroy()
      end
      self._buffs[buff_key] = nil
      changed = true
    end
  end

  -- Process incoming buffs and update positions
  if buffs then
    local i = 0
    for buff_key, buff in pairs(buffs) do
      i = i + 1

      local new_x, new_y, updated_rows = calculate_buff_position(i, cols, self._buff_width, self._buff_height,
        buff_spacing,
        self._x, self._y)

      -- Update row count
      if updated_rows > rows then
        rows = updated_rows
      end

      if not self._buffs[buff_key] then
        -- Add new buff
        local new_buff_img = images.new({
          flags = {
            draggable = false
          }
        })

        new_buff_img:size(self._buff_width, self._buff_height)
        new_buff_img:path(windower.addon_path .. 'icons/' .. buff.buff_id .. '.bmp')
        new_buff_img:fit(false)
        new_buff_img:repeat_xy(1, 1)
        new_buff_img:pos(new_x, new_y)
        new_buff_img:draggable(false)

        if self._isVisible then
          new_buff_img:show()
        else
          new_buff_img:hide()
        end

        self._buffs[buff_key] = {
          image = new_buff_img,
          remaining_time = buff.end_time - os.clock(),
          originating_spell = buff.originating_spell,
          buff_name = res.buffs[buff.buff_id].en,
          current_x = new_x, -- Track initial position to optimize when pos gets updated
          current_y = new_y  -- Track initial position to optimize when pos gets updated
        }
        changed = true
      else
        -- Update existing buff
        self._buffs[buff_key].remaining_time = buff.end_time - os.clock()

        -- the originating spell can change for certain skills
        if self._buffs[buff_key].originating_spell ~= buff.originating_spell then
          self._buffs[buff_key].originating_spell = buff.originating_spell
        end

        -- Check if the buff is near expiration
        if buff.end_time - os.clock() <= near_expiration_threshold then
          -- Blink effect: alternate opacity or color
          if blink_phase == 0 then
            self._buffs[buff_key].image:alpha(255) -- Fully visible
          else
            self._buffs[buff_key].image:alpha(128) -- Semi-transparent
          end
        else
          -- Reset to fully visible if not near expiration
          self._buffs[buff_key].image:alpha(255)
        end

        -- Only update the position if it is actually changing
        if self._buffs[buff_key].current_x ~= new_x or self._buffs[buff_key].current_y ~= new_y then
          self._buffs[buff_key].image:pos(new_x, new_y) -- Update position
          self._buffs[buff_key].current_x = new_x       -- Store new position
          self._buffs[buff_key].current_y = new_y
        end
      end
    end
  end

  -- Update tooltip
  update_tooltip(buff_tooltip, self._hovering_on_buff)

  -- Return true if dimensions changed
  return changed
end

function buffs:visible()
  return self._isVisible
end

function buffs:show()
  self._isVisible = true
  if self._buffs then
    for _, buff in pairs(self._buffs) do
      if buff.image then
        buff.image:show()
      end
    end
  end
end

function buffs:hide()
  self._isVisible = false
  if self._buffs then
    for _, buff in pairs(self._buffs) do
      if buff.image then
        buff.image:hide()
      end
    end
  end
  if buff_tooltip then
    buff_tooltip:hide()
  end
end

function buffs:handle_mouse(type, cursor_x, cursor_y)
  if self._isVisible then
    if type == 0 then
      -- Detect hover for tooltip
      for buff_id, buff in pairs(self._buffs) do
        if cursor_x >= buff.image:pos_x() and cursor_x <= buff.image:pos_x() + self._buff_width and
            cursor_y >= buff.image:pos_y() and cursor_y <= buff.image:pos_y() + self._buff_height then
          self._hovering_on_buff = buff
          self._hovering_on_buff.id = buff_id
          if buff_tooltip then
            buff_tooltip:pos(cursor_x + 18, cursor_y + 2) -- Offset the tooltip slightly from the cursor
            buff_tooltip:show()
          end
          return true
        else
          self._hovering_on_buff = {}
          if buff_tooltip then
            buff_tooltip:hide()
          end
        end
      end
    end
  end
  return false
end

return buffs
