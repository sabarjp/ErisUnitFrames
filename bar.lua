-- This class represents a resource bar in the UI
bar = {}
bar.__index = bar

-- Constructor
function bar:new(params)
  local instance               = setmetatable({}, bar)

  -- internal variables
  instance._bar_left           = images.new({
    flags = {
      draggable = false
    }
  })

  instance._bar_right          = images.new({
    flags = {
      draggable = false
    }
  })

  instance._bar_bg             = images.new({
    flags = {
      draggable = false
    }
  })

  instance._bar_fg             = images.new({
    flags = {
      draggable = false
    }
  })

  instance._bar_text           = texts.new({
    flags = {
      draggable = false
    }
  })

  instance._x                  = params.x or 0
  instance._y                  = params.y or 0
  instance._isVisible          = false
  instance._width              = params.width or 50
  instance._height             = params.height or 10
  instance._text_font          = params.text_font or 'Calibri'
  instance._text_color         = params.text_color or { 255, 255, 255 }
  instance._text_alpha         = params.text_alpha or 255
  instance._text_size          = params.text_size or 12
  instance._text_right_align   = params.text_right_align or false
  instance._text_offset        = params.text_offset or { x = 0, y = 0 }
  instance._background_color   = params.background_color or { 150, 150, 150 }
  instance._background_alpha   = params.background_alpha or 128
  instance._foreground_color   = params.foreground_color or { 255, 255, 255 }
  instance._foreground_alpha   = params.foreground_alpha or 255
  instance._disable_text       = params.disable_text or false
  instance._disable_foreground = params.disable_foreground or false
  instance._disable_background = params.disable_background or false


  -- class variables

  instance:init()
  return instance
end

function bar:init()
  local tempx, tempy

  self._bar_left:alpha(self._background_alpha)
  self._bar_left:color(unpack(self._background_color))
  self._bar_left:height(self._height)
  self._bar_left:width(2)
  self._bar_left:path(windower.addon_path .. 'bar_left_1.png')
  self._bar_left:fit(false)
  self._bar_left:repeat_xy(1, 1)
  self._bar_left:pos(self._x - 2, self._y)
  self._bar_left:draggable(false)
  self._bar_left:hide()

  self._bar_right:alpha(self._background_alpha)
  self._bar_right:color(unpack(self._background_color))
  self._bar_right:height(self._height)
  self._bar_right:width(2)
  self._bar_right:path(windower.addon_path .. 'bar_right_1.png')
  self._bar_right:fit(false)
  self._bar_right:repeat_xy(1, 1)
  self._bar_right:pos(self._x + self._width, self._y)
  self._bar_right:draggable(false)
  self._bar_right:hide()

  self._bar_bg:alpha(self._background_alpha)
  self._bar_bg:color(unpack(self._background_color))
  self._bar_bg:size(self._width, self._height)
  self._bar_bg:width(self._width)
  self._bar_bg:path(windower.addon_path .. 'bar_bg_1.png')
  self._bar_bg:fit(true)
  self._bar_bg:repeat_xy(1, 1)
  self._bar_bg:pos(self._x, self._y)
  self._bar_bg:draggable(false)
  self._bar_bg:hide()

  self._bar_fg:alpha(self._foreground_alpha)
  self._bar_fg:color(unpack(self._foreground_color))
  self._bar_fg:size(self._width, self._height)
  self._bar_fg:width(self._width)
  self._bar_fg:path(windower.addon_path .. 'bar_fg_1.png')
  self._bar_fg:fit(true)
  self._bar_fg:repeat_xy(1, 1)
  self._bar_fg:pos(self._x, self._y)
  self._bar_fg:draggable(false)
  self._bar_fg:hide()

  self._bar_text:font('Calibri')
  self._bar_text:size(self._text_size)
  self._bar_text:alpha(self._text_alpha)
  self._bar_text:stroke_transparency(0.5)
  self._bar_text:stroke_width(1.5)
  self._bar_text:stroke_color(0, 0, 0)
  self._bar_text:color(unpack(self._text_color))
  self._bar_text:bg_visible(false)
  tempx, tempy = self._bar_fg:pos()
  if self._text_right_align then
    self._bar_text:right_justified(true)
  end
  self._bar_text:pos(self:justX(tempx) + self._text_offset.x, tempy - 3 + self._text_offset.y)
  self._bar_text:draggable(false)
  self._bar_text:hide()
end

function bar:pos(x, y)
  if not x then
    return self._x, self._y
  end

  self._x = x
  self._y = y

  -- reposition
  self._bar_bg:pos(self.x, self.y)
  self._bar_fg:pos(self.x, self.y)
  local tempx, tempy = self._bar_fg:pos()
  self._bar_text:pos(self:justX(tempx) + self._text_offset.x, tempy - 3 + self._text_offset.y)
end

function bar:pos_x(x)
  if not x then
    return self._x
  end

  self._x = x

  -- reposition
  self._bar_bg:pos(self.x, self.y)
  self._bar_fg:pos(self.x, self.y)
  local tempx, tempy = self._bar_fg:pos()
  self._bar_text:pos(self:justX(tempx) + self._text_offset.x, tempy - 3 + self._text_offset.y)
end

function bar:pos_y(y)
  if not y then
    return self._y
  end

  self._y = y

  -- reposition
  self._bar_bg:pos(self.x, self.y)
  self._bar_fg:pos(self.x, self.y)
  local tempx, tempy = self._bar_fg:pos()
  self._bar_text:pos(self:justX(tempx) + self._text_offset.x, tempy - 3 + self._text_offset.y)
end

function bar:height(h)
  if not h then
    return self._height
  end

  self._height = h

  -- redo bar height
  self._bar_bg:height(self._width)
  self._bar_fg:height(self._width)
end

function bar:width(w)
  if not w then
    return self._width
  end

  self._width = w

  -- redo bar width
  self._bar_bg:width(self._width)
  self._bar_fg:width(self._width)
end

function bar:color(r, g, b)
  self._bar_fg:color(r, g, b)
end

function bar:text_color(r, g, b)
  self._bar_text:color(r, g, b)
end

function bar:components()
  return { self._bar_text, self._bar_fg, self._bar_bg }
end

-- show a fill of the bar from 0 to 1.0, percent/ratio
function bar:fill(r)
  self:width(self:width())
  self._bar_fg:width(self._width * r)
end

function bar:visible()
  return self._isVisible
end

function bar:show()
  self._isVisible = true
  if not self._disable_background then self._bar_bg:show() end
  if not self._disable_background then self._bar_left:show() end
  if not self._disable_background then self._bar_right:show() end
  if not self._disable_foreground then self._bar_fg:show() end
  if not self._disable_text then self._bar_text:show() end
end

function bar:hide()
  self._isVisible = false
  self._bar_left:hide()
  self._bar_right:hide()
  self._bar_bg:hide()
  self._bar_fg:hide()
  self._bar_text:hide()
end

function bar:text(str)
  if not str then
    return self._bar_text:text()
  end

  self._bar_text:text(str)
end

function bar:justX(xNormal)
  if self._text_right_align then
    return xNormal - windower.get_windower_settings().ui_x_res + self._width
  else
    return xNormal
  end
end

return bar
