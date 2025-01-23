local theme = {}

theme.texture = {
  bar_left = windower.addon_path .. 'bar_left_1.png',
  bar_right = windower.addon_path .. 'bar_right_1.png',
  bar_foreground = windower.addon_path .. 'bar_fg_1.png',
  bar_background = windower.addon_path .. 'bar_bg_1.png',
}

theme.player = {
  nameplate = {
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
    width = 150,
    height = 15,
    text = {
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
      alpha = 255,
      red = 18,
      green = 211,
      blue = 14,
    },
    background = {
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
    width = 105,
    height = 12,
    text = {
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
      alpha = 255,
      red = 0,
      green = 82,
      blue = 211,
    },
    background = {
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
    width = 150,
    height = 5,
    text = {
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
      alpha = 255,
      red = 209,
      green = 184,
      blue = 0,
      full_red = 209,
      full_green = 149,
      full_blue = 0
    },
    background = {
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
  buffs = {
    height = 32,
    width = 120,
    buff_height = 16,
    buff_width = 16,
    rel_pos = {
      x = 0,
      y = 54
    }
  }
}

theme.pet = {
  nameplate = {
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
    width = 100,
    height = 15,
    text = {
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
      alpha = 255,
      red = 18,
      green = 211,
      blue = 14,
    },
    background = {
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
    width = 65,
    height = 12,
    text = {
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
      alpha = 255,
      red = 0,
      green = 82,
      blue = 211,
    },
    background = {
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
    width = 100,
    height = 4,
    text = {
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
      alpha = 255,
      red = 209,
      green = 184,
      blue = 0,
      full_red = 209,
      full_green = 149,
      full_blue = 0
    },
    background = {
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
  },
  buffs = {
    height = 32,
    width = 100,
    buff_height = 16,
    buff_width = 16,
    rel_pos = {
      x = 0,
      y = 54
    }
  }
}

theme.target = {
  nameplate = {
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
    width = 150,
    height = 15,
    text = {
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
      alpha = 255,
      use_dynamic_colors = true,
      red = 18,
      green = 211,
      blue = 14,
    },
    background = {
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
  },
  buffs = {
    height = 32,
    width = 120,
    buff_height = 16,
    buff_width = 16,
    rel_pos = {
      x = 0,
      y = 36
    }
  }
}

theme.sub_target = {
  nameplate = {
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
    width = 150,
    height = 15,
    text = {
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
      alpha = 255,
      use_dynamic_colors = true,
      red = 120,
      green = 120,
      blue = 255,
    },
    background = {
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

theme.battle_target = {
  nameplate = {
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

theme.party = {
  nameplate = {
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
    width = 110,
    height = 15,
    text = {
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
      alpha = 255,
      red = 18,
      green = 211,
      blue = 14,
    },
    background = {
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
    width = 70,
    height = 12,
    text = {
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
      alpha = 255,
      red = 0,
      green = 82,
      blue = 211,
    },
    background = {
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
    width = 110,
    height = 4,
    text = {
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
      alpha = 255,
      red = 209,
      green = 184,
      blue = 0,
      full_red = 209,
      full_green = 149,
      full_blue = 0
    },
    background = {
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
  },
  buffs = {
    height = 32,
    width = 110,
    buff_height = 16,
    buff_width = 16,
    rel_pos = {
      x = 8,
      y = 44
    }
  }
}

theme.alliance = {
  nameplate = {
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
    width = 70,
    height = 38,
    text = {
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
      alpha = 255,
      red = 18,
      green = 211,
      blue = 14,
    },
    background = {
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
    width = 70,
    height = 8,
    text = {
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
      alpha = 255,
      red = 0,
      green = 82,
      blue = 211,
    },
    background = {
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
    width = 70,
    height = 4,
    text = {
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
      alpha = 255,
      red = 209,
      green = 184,
      blue = 0,
      full_red = 209,
      full_green = 149,
      full_blue = 0
    },
    background = {
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

return theme
