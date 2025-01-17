-- This class represents a buff area in the UI
buffs = {}
buffs.__index = buffs

-- Constructor
function buffs:new(params)
  local instance             = setmetatable({}, buffs)

  -- internal variables
  instance._buffs            = {} -- keyed on buff id

  instance._tooltip          = texts.new({
    flags = { draggable = false },
  })

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
  self._tooltip:font('Calibri')
  self._tooltip:size(12)
  self._tooltip:alpha(255)
  self._tooltip:stroke_transparency(0.2)
  self._tooltip:stroke_width(1.5)
  self._tooltip:stroke_color(0, 0, 0)
  self._tooltip:color(255, 255, 255)
  self._tooltip:bg_visible(false)
  self._tooltip:draggable(false)
  self._tooltip:hide()
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

  if buff_name == spell_name then
    tooltip:text(string.format("%s\n%s", buff_name, readable_time))
  else
    tooltip:text(string.format("%s (%s)\n%s", buff_name, spell_name, readable_time))
  end
end

-- Updates buffs as needed, and returns true if the list has changed in dimensions
function buffs:update_buffs(buffs)
  local changed = false

  -- Dimensions for wrapping
  local max_width = self._width
  local max_height = self._height
  local buff_spacing = 1                                                 -- Spacing between buffs
  local cols = math.floor(max_width / (self._buff_width + buff_spacing)) -- Number of buffs per row
  local rows = 0                                                         -- Track row count dynamically

  -- Remove buffs that are no longer active first
  for buff_id, buff_data in pairs(self._buffs) do
    if not (buffs and buffs[buff_id]) then
      -- Buff no longer exists, remove it
      if buff_data.image then
        buff_data.image:hide()
        buff_data.image:destroy()
      end
      self._buffs[buff_id] = nil
      changed = true
    end
  end

  -- Process incoming buffs and update positions
  if buffs then
    local i = 0
    for buff_id, buff in pairs(buffs) do
      i = i + 1

      local new_x, new_y, updated_rows = calculate_buff_position(i, cols, self._buff_width, self._buff_height,
        buff_spacing,
        self._x, self._y)

      -- Update row count
      if updated_rows > rows then
        rows = updated_rows
      end

      if not self._buffs[buff_id] then
        -- Add new buff
        local new_buff_img = images.new({
          flags = {
            draggable = false
          }
        })

        new_buff_img:size(self._buff_width, self._buff_height)
        new_buff_img:path(windower.addon_path .. 'icons/' .. buff_id .. '.bmp')
        new_buff_img:fit(false)
        new_buff_img:repeat_xy(1, 1)
        new_buff_img:pos(new_x, new_y)
        new_buff_img:draggable(false)
        new_buff_img:show()

        self._buffs[buff_id] = {
          image = new_buff_img,
          remaining_time = buff.remaining_time,
          originating_spell = res.spells[buff.originating_spell_id].en,
          buff_name = res.buffs[buff_id].en,
          current_x = new_x, -- Track initial position to optimize when pos gets updated
          current_y = new_y  -- Track initial position to optimize when pos gets updated
        }
        changed = true
      else
        -- Update existing buff
        self._buffs[buff_id].remaining_time = buff.remaining_time

        -- Only update the position if it is actually changing
        if self._buffs[buff_id].current_x ~= new_x or self._buffs[buff_id].current_y ~= new_y then
          self._buffs[buff_id].image:pos(new_x, new_y) -- Update position
          self._buffs[buff_id].current_x = new_x       -- Store new position
          self._buffs[buff_id].current_y = new_y
        end
      end
    end
  end

  -- Update tooltip
  update_tooltip(self._tooltip, self._hovering_on_buff)

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
  --if not self._disable_tooltips then self._buffs_text:show() end
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
  --if not self._disable_tooltips then self._buffs_text:hide() end
end

function buffs:handle_mouse(type, cursor_x, cursor_y)
  if type == 0 then
    -- Detect hover for tooltip
    for buff_id, buff in pairs(self._buffs) do
      if cursor_x >= buff.image:pos_x() and cursor_x <= buff.image:pos_x() + self._buff_width and
          cursor_y >= buff.image:pos_y() and cursor_y <= buff.image:pos_y() + self._buff_height then
        self._hovering_on_buff = buff
        self._hovering_on_buff.id = buff_id
        self._tooltip:pos(cursor_x + 10, cursor_y + 10) -- Offset the tooltip slightly from the cursor
        self._tooltip:show()
        return true
      else
        self._hovering_on_buff = {}
        self._tooltip:hide()
      end
    end
  end
  return false
end

return buffs
