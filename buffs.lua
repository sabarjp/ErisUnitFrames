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
  instance._buff_order       = {} -- sorted buffs

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
    if buff_data.background then
      buff_data.background:destroy()
    end
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
  local category = hovering_buff.buff_category

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

  -- **Step 1: Determine order of buffs**
  self._buff_order = {} -- Maintain a sorted order of keys
  if buffs then
    for buff_key, buff_data in pairs(buffs) do
      table.insert(self._buff_order, {
        key = buff_key,
        category = buff_data.category,
        end_time = buff_data.end_time
      })
    end

    -- Sort by category priority first, then by remaining time (longest-lasting buffs first)
    table.sort(self._buff_order, function(a, b)
      -- Define category priorities
      local category_priority = {
        ["dispelable buff"] = 1,
        ["buff"] = 1
      }

      -- Get the priorities of the categories
      local a_priority = category_priority[a.category] or 2 -- Default priority for other categories
      local b_priority = category_priority[b.category] or 2

      -- First, sort by category priority (lower numbers = higher priority)
      if a_priority ~= b_priority then
        return a_priority < b_priority
      end

      -- If categories are the same priority, sort by remaining time (longest-lasting first)
      return a.end_time > b.end_time
    end)
  end

  -- **Step 2: Remove inactive buffs**
  for buff_key, buff_data in pairs(self._buffs) do
    if not (buffs and buffs[buff_key]) then
      -- Buff no longer exists, remove it
      if buff_data.background then
        buff_data.background:hide()
        buff_data.background:destroy()
      end
      if buff_data.image then
        buff_data.image:hide()
        buff_data.image:destroy()
      end
      self._buffs[buff_key] = nil
      changed = true
    end
  end

  -- **Step 3: Process and render buffs**
  if buffs then
    local i = 0
    for _, sorted_entry in ipairs(self._buff_order) do
      local buff_key = sorted_entry.key
      local buff = buffs[buff_key]

      -- just because its in the sorted order, doesn't mean it wasn't removed in step 2
      if buff then
        i = i + 1

        local new_x, new_y, updated_rows = calculate_buff_position(i, cols, self._buff_width, self._buff_height,
          buff_spacing,
          self._x, self._y)

        -- Update row count
        if updated_rows > rows then
          rows = updated_rows
        end

        if not self._buffs[buff_key] then
          -- if an ability is a certain category, we give it a background to make it
          -- stand out more for curing it.

          local target_data = windower.ffxi.get_mob_by_id(buff.target_id)
          local is_friendly = target_data.in_party or target_data.in_alliance or (not target_data.is_npc)
          local new_buff_bg = nil
          local is_creating_background = false
          local bg_color = { 0, 0, 0 }

          if is_friendly then
            if buff.category == "sleep" then
              is_creating_background = true
              bg_color = { 0, 0, 0 }
            elseif buff.category == "poison" then
              is_creating_background = true
              bg_color = { 26, 209, 3 }
            elseif buff.category == "paralyze" then
              is_creating_background = true
              bg_color = { 255, 216, 0 }
            elseif buff.category == "blind" then
              is_creating_background = true
              bg_color = { 128, 128, 128 }
            elseif buff.category == "silence" then
              is_creating_background = true
              bg_color = { 102, 255, 183 }
            elseif buff.category == "petrify" then
              is_creating_background = true
              bg_color = { 112, 78, 0 }
            elseif buff.category == "disease" then
              is_creating_background = true
              bg_color = { 187, 131, 226 }
            elseif buff.category == "curse" then
              is_creating_background = true
              bg_color = { 83, 0, 226 }
            elseif buff.category == "uncurable" then
              is_creating_background = true
              bg_color = { 228, 0, 0 }
            elseif buff.category == "erase" then
              is_creating_background = true
              bg_color = { 0, 182, 255 }
            end
          else
            if buff.category == "dispelable buff" then
              is_creating_background = true
              bg_color = { 226, 62, 189 }
            end
          end

          if is_creating_background then
            new_buff_bg = images.new({
              flags = {
                draggable = false
              }
            })

            new_buff_bg:size(self._buff_width, self._buff_height)
            new_buff_bg:path(windower.addon_path .. 'icons/bg.png')
            new_buff_bg:repeat_xy(1, 1)
            new_buff_bg:pos(new_x, new_y)
            new_buff_bg:draggable(false)
            new_buff_bg:alpha(255)
            new_buff_bg:color(unpack(bg_color))
            new_buff_bg:fit(false)
          end

          local new_buff_img = images.new({
            flags = {
              draggable = false
            }
          })

          new_buff_img:size(self._buff_width - 2, self._buff_height - 2)
          new_buff_img:path(windower.addon_path .. 'icons/' .. buff.buff_id .. '.bmp')
          new_buff_img:fit(false)
          new_buff_img:repeat_xy(1, 1)
          new_buff_img:pos(new_x + 1, new_y + 1)
          new_buff_img:draggable(false)
          new_buff_img:alpha(255)


          if self._isVisible then
            if new_buff_bg then
              new_buff_bg:show()
            end
            new_buff_img:show()
          else
            if new_buff_bg then
              new_buff_bg:hide()
            end
            new_buff_img:hide()
          end

          self._buffs[buff_key] = {
            background = new_buff_bg,
            image = new_buff_img,
            remaining_time = buff.end_time - os.clock(),
            originating_spell = buff.originating_spell,
            buff_name = res.buffs[buff.buff_id].en,
            buff_category = buff.category,
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
            if self._buffs[buff_key].background then
              self._buffs[buff_key].background:pos(new_x, new_y)  -- Update position
            end
            self._buffs[buff_key].image:pos(new_x + 1, new_y + 1) -- Update position
            self._buffs[buff_key].current_x = new_x               -- Store new position
            self._buffs[buff_key].current_y = new_y
          end
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
      if buff.background then
        buff.background:show()
      end
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
      if buff.background then
        buff.background:hide()
      end
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
