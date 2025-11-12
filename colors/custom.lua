-- A slightly altered version of catppucchin mocha
local mocha = {
  rosewater = '#F5E0DC',
  flamingo = '#F2CDCD',
  pink = '#F5C2E7',
  mauve = '#CBA6F7',
  red = '#F38BA8',
  maroon = '#EBA0AC',
  peach = '#FAB387',
  yellow = '#F9E2AF',
  green = '#A6E3A1',
  teal = '#94E2D5',
  sky = '#89DCEB',
  sapphire = '#74C7EC',
  blue = '#89B4FA',
  lavender = '#B4BEFE',
  text = '#CDD6F4',
  subtext1 = '#BAC2DE',
  subtext0 = '#A6ADC8',
  overlay2 = '#9399B2',
  overlay1 = '#7F849C',
  overlay0 = '#6C7086',
  surface2 = '#585B70',
  surface1 = '#45475A',
  surface0 = '#313244',
  base = '#1F1F28',
  mantle = '#181825',
  crust = '#11111B',
}

local kanagawa = {
  background = '#1F1F28',
  foreground = '#DCD7BA',

  tab_bar = {
    background = '#1F1F28',

    active_tab = {
      bg_color = '#2D4F67',
      fg_color = '#C8C093',
    },
    inactive_tab = {
      bg_color = '#1F1F28',
      fg_color = '#DCD7BA',
    },
    new_tab = {
      bg_color = '#1F1F28',
      fg_color = '#DCD7BA',
    },
  },

  cursor_bg = '#C8C093',
  cursor_fg = '#C8C093',
  cursor_border = '#C8C093',

  selection_fg = '#C8C093',
  selection_bg = '#2D4F67',

  scrollbar_thumb = '#16161D',
  split = '#16161D',

  ansi = { '#090618', '#C34043', '#76946A', '#C0A36E', '#7E9CD8', '#957FB8', '#6A9589', '#C8C093' },
  brights = { '#727169', '#E82424', '#98BB6C', '#E6C384', '#7FB4CA', '#938AA9', '#7AA89F', '#DCD7BA' },
  indexed = { [16] = '#FFA066', [17] = '#FF5D62' },
}

local colorscheme = {
  foreground = mocha.text,
  background = mocha.base,
  cursor_bg = mocha.rosewater,
  cursor_border = mocha.rosewater,
  cursor_fg = mocha.crust,
  selection_bg = mocha.surface2,
  selection_fg = mocha.text,
  ansi = {
    '#0C0C0C', -- black
    '#C50F1F', -- red
    '#13A10E', -- green
    '#C19C00', -- yellow
    '#0037DA', -- blue
    '#881798', -- magenta/purple
    '#3A96DD', -- cyan
    '#CCCCCC', -- white
  },
  brights = {
    '#767676', -- black
    '#E74856', -- red
    '#16C60C', -- green
    '#F9F1A5', -- yellow
    '#3B78FF', -- blue
    '#B4009E', -- magenta/purple
    '#61D6D6', -- cyan
    '#F2F2F2', -- white
  },
  tab_bar = {
    background = 'rgba(0, 0, 0, 0.4)',
    active_tab = {
      bg_color = mocha.surface2,
      fg_color = mocha.text,
    },
    inactive_tab = {
      bg_color = mocha.surface0,
      fg_color = mocha.subtext1,
    },
    inactive_tab_hover = {
      bg_color = mocha.surface0,
      fg_color = mocha.text,
    },
    new_tab = {
      bg_color = mocha.base,
      fg_color = mocha.text,
    },
    new_tab_hover = {
      bg_color = mocha.mantle,
      fg_color = mocha.text,
      italic = true,
    },
  },
  visual_bell = mocha.red,
  indexed = {
    [16] = mocha.peach,
    [17] = mocha.rosewater,
  },
  scrollbar_thumb = mocha.surface2,
  split = mocha.overlay0,
  compose_cursor = mocha.flamingo,
}

return kanagawa
