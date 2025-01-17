local defaults = {}

defaults.theme = "ff11"


defaults.player = {
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
    value = '%name',
  },
  health_bar = {
    disabled = false,
    value = '%hp_current',
    text = {
      disabled = false,
    },
    foreground = {
      disabled = false,
    },
    background = {
      disabled = false,
    },
  },
  magic_bar = {
    disabled = false,
    value = '%mp_current',
    text = {
      disabled = false,
    },
    foreground = {
      disabled = false,
    },
    background = {
      disabled = false,
    },
  },
  tp_bar = {
    disabled = false,
    value = '%tp_current',
    text = {
      disabled = false,
    },
    foreground = {
      disabled = false,
    },
    background = {
      disabled = false,
    },
  }
}

defaults.pet = {
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
    value = '%name',
  },
  health_bar = {
    disabled = false,
    value = '%hp_percent%',
    text = {
      disabled = false,
    },
    foreground = {
      disabled = false,
    },
    background = {
      disabled = false,
    },
  },
  magic_bar = {
    disabled = false,
    value = '%mp_percent%',
    text = {
      disabled = false,
    },
    foreground = {
      disabled = false,
    },
    background = {
      disabled = false,
    },
  },
  tp_bar = {
    disabled = false,
    value = '%tp_current',
    text = {
      disabled = false,
    },
    foreground = {
      disabled = false,
    },
    background = {
      disabled = false,
    },
  }
}

defaults.target = {
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
    value = '%name (%mob_type) - %distance',
  },
  health_bar = {
    disabled = false,
    value = '%hp_percent%',
    text = {
      disabled = false,
    },
    foreground = {
      disabled = false,
    },
    background = {
      disabled = false,
    },
  },
  locked_text = {
    disabled = false,
    value = '> LOCKED <',
  },
  buffs = {
    disabled = false,
    tooltip_disabled = false
  }
}

defaults.sub_target = {
  disabled = false,
  only_show_in_combat = false,
  pos = {
    relative_to = 'center', -- center or topleft
    x           = 100,
    y           = 80
  },
  nameplate = {
    disabled = false,
    value = 'ST >> %name (%mob_type)',
  },
  health_bar = {
    disabled = false,
    value = '%hp_percent%',
    text = {
      disabled = false,
    },
    foreground = {
      disabled = false,
    },
    background = {
      disabled = false,
    },
  }
}

defaults.battle_target = {
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
    value = 'BT >> %name',
  },
}

defaults.party = {
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
    value = '%name',
  },
  health_bar = {
    disabled = false,
    value = '%hp_current',
    text = {
      disabled = false,
    },
    foreground = {
      disabled = false,
    },
    background = {
      disabled = false,
    },
  },
  magic_bar = {
    disabled = false,
    value = '%mp_current',
    text = {
      disabled = false,
    },
    foreground = {
      disabled = false,
    },
    background = {
      disabled = false,
    },
  },
  tp_bar = {
    disabled = false,
    value = '%tp_current',
    text = {
      disabled = false,
    },
    foreground = {
      disabled = false,
    },
    background = {
      disabled = false,
    },
  }
}

defaults.alliance = {
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
    value = '%name_short',
  },
  health_bar = {
    disabled = false,
    value = '%hp_current',
    text = {
      disabled = false,
    },
    foreground = {
      disabled = false,
    },
    background = {
      disabled = false,
    },
  },
  magic_bar = {
    disabled = false,
    value = '%mp_current',
    text = {
      disabled = false,
    },
    foreground = {
      disabled = false,
    },
    background = {
      disabled = false,
    },
  },
  tp_bar = {
    disabled = false,
    value = '%tp_current',
    text = {
      disabled = false,
    },
    foreground = {
      disabled = true,
    },
    background = {
      disabled = true,
    },
  }
}

return defaults
