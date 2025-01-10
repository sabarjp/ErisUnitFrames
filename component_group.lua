local grouper = {}

-- helper to get components in
function grouper.flatten(t)
  local result = {}
  for _, item in ipairs(t) do
    if type(item) == "table" then
      -- Flatten and insert each item in the nested table
      for _, inner in ipairs(item) do
        table.insert(result, inner)
      end
    end
  end
  return result
end

-- Composite Component Structure
function grouper.create_component_group(components)
  local group = {
    components = components,
    bounding_box = {
      min_x = nil,
      min_y = nil,
      max_x = nil,
      max_y = nil,
    },
  }

  function group:clear_bounding_box()
    self.bounding_box.min_x = nil
    self.bounding_box.min_y = nil
    self.bounding_box.max_x = nil
    self.bounding_box.max_y = nil
  end

  -- Function to calculate bounding box dynamically
  function group:calculate_bounding_box(withDelay)
    -- delay is needed if text was recently updated
    if withDelay then
      coroutine.sleep(withDelay)
    end

    self.bounding_box.min_x = nil
    self.bounding_box.min_y = nil
    self.bounding_box.max_x = nil
    self.bounding_box.max_y = nil

    for _, component in pairs(self.components) do
      local pos_x, pos_y = component:pos()
      local end_x, end_y

      if component.extents then
        -- text type
        local off_x, off_y = component:extents()

        if component.right_justified and component:right_justified() then
          pos_x = windower.get_windower_settings().ui_x_res + pos_x - off_x
        end

        end_x = pos_x + off_x
        end_y = pos_y + off_y
      else
        -- image type
        end_x, end_y = component:get_extents()
      end

      local comp_min_x = pos_x
      local comp_min_y = pos_y
      local comp_max_x = end_x
      local comp_max_y = end_y

      if not self.bounding_box.min_x or comp_min_x < self.bounding_box.min_x then
        self.bounding_box.min_x = comp_min_x
      end
      if not self.bounding_box.min_y or comp_min_y < self.bounding_box.min_y then
        self.bounding_box.min_y = comp_min_y
      end
      if not self.bounding_box.max_x or comp_max_x > self.bounding_box.max_x then
        self.bounding_box.max_x = comp_max_x
      end
      if not self.bounding_box.max_y or comp_max_y > self.bounding_box.max_y then
        self.bounding_box.max_y = comp_max_y
      end
    end
  end

  -- Function to check if a click is within the group's bounding box
  function group:is_inside(x, y)
    local bb = self.bounding_box
    if bb.min_x == nil then
      return false
    end

    return x >= bb.min_x and x <= bb.max_x and y >= bb.min_y and y <= bb.max_y
  end

  -- Initial bounding box calculation
  group:calculate_bounding_box()
  return group
end

return grouper
