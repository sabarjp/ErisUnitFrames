local grouper = {}

grouper.groups_waiting_for_bb = {} -- Holds groups waiting for BB updates

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
function grouper.create_component_group(root, components, related, parent)
  local group = {
    is_destroyed = false,
    root         = root,           -- contains the root position of the group
    components   = components,     -- a list of all the components of the group, used for bounding box calculation
    related      = related or nil, -- optional related object that will be used to reposition, but not for bounding box
    bounding_box = {
      min_x = nil,
      min_y = nil,
      max_x = nil,
      max_y = nil,
    },
    parent       = parent or nil -- an optional parent group -- its bounding calculation will cascade off this one
  }

  function group:set_parent(parent)
    self.parent = parent
  end

  function group:destroy()
    if not self.is_destroyed then
      self.is_destroyed = true
      if self.components then
        for key, component in pairs(self.components) do
          if component then
            --print('destroying linked component')
            component:destroy()
            self.components[key] = nil -- Explicitly clear the table entry
          end
        end
      end
      self.components = nil -- Remove the table itself

      if self.related then
        for key, component in pairs(self.related) do
          if component then
            --print('destroying related component')
            component:destroy()
            self.related[key] = nil -- Explicitly clear the table entry
          end
        end
      end
      self.related = nil -- Remove the table itself

      -- Clear other references
      self.root = nil
      self.bounding_box = nil
      self.parent = nil
    end
  end

  function group:pos(new_root_x, new_root_y)
    local center_x = (windower.get_windower_settings().ui_x_res / 2)
    local center_y = (windower.get_windower_settings().ui_y_res / 2)

    local root_x = ((self.root.relative_to == 'center') and (center_x + self.root.x) or self.root.x)
    local root_y = ((self.root.relative_to == 'center') and (center_y + self.root.y) or self.root.y)

    if self.components then
      for _, component in pairs(self.components) do
        local off_x = component:pos_x() - root_x
        local off_y = component:pos_y() - root_y
        component:pos(new_root_x + off_x, new_root_y + off_y)
      end
    end

    if self.related then
      for _, component in pairs(self.related) do
        local off_x = component:pos_x() - root_x
        local off_y = component:pos_y() - root_y
        component:pos(new_root_x + off_x, new_root_y + off_y)
      end
    end

    -- establish new root
    root.x = ((self.root.relative_to == 'center') and (new_root_x - center_x) or new_root_x)
    root.y = ((self.root.relative_to == 'center') and (new_root_y - center_y) or new_root_y)
  end

  function group:clear_bounding_box()
    self.bounding_box.min_x = nil
    self.bounding_box.min_y = nil
    self.bounding_box.max_x = nil
    self.bounding_box.max_y = nil
  end

  function group:perform_bounding_box_calculation()
    if self.bounding_box == nil then
      -- object was destroyed while waiting, do nothing
      return
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

  -- Function to calculate bounding box dynamically
  function group:calculate_bounding_box(withDelay)
    if not self.bb_pending then
      self.bb_pending = true
      self.bb_frames_remaining = withDelay or 5
      grouper.groups_waiting_for_bb[self] = true

      if self.parent then
        self.parent:calculate_bounding_box(self.bb_frames_remaining + 3)
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

windower.register_event('prerender', function()
  for grp in pairs(grouper.groups_waiting_for_bb) do
    grp.bb_frames_remaining = grp.bb_frames_remaining - 1

    if grp.bb_frames_remaining <= 0 then
      grp.bb_pending = false
      grouper.groups_waiting_for_bb[grp] = nil -- Remove from active list
      grp:perform_bounding_box_calculation()
    end
  end
end)

return grouper
