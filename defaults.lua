local defaults = {}

defaults.texture = {
  bar_left = windower.addon_path .. 'bar_left_1.png',
  bar_right = windower.addon_path .. 'bar_right_1.png',
  bar_foreground = windower.addon_path .. 'bar_fg_1.png',
  bar_background = windower.addon_path .. 'bar_bg_1.png',
}

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
    left_right_cap = {
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
    left_right_cap = {
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
    left_right_cap = {
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
    left_right_cap = {
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
    left_right_cap = {
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
    left_right_cap = {
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
    left_right_cap = {
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
    left_right_cap = {
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
    left_right_cap = {
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
    left_right_cap = {
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
    left_right_cap = {
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
    left_right_cap = {
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
    left_right_cap = {
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
    left_right_cap = {
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

return defaults
