------------------------------------------------------------------------------------------
-- Inspired by https://github.com/wez/wezterm/discussions/628#discussioncomment-1874614 --
------------------------------------------------------------------------------------------

local wezterm = require('wezterm')
local Cells = require('utils.cells')

local nf = wezterm.nerdfonts
local attr = Cells.attr

local GLYPH_SCIRCLE_LEFT = nf.ple_left_half_circle_thick --[[  ]]
local GLYPH_SCIRCLE_RIGHT = nf.ple_right_half_circle_thick --[[  ]]
local GLYPH_CIRCLE = nf.fa_circle --[[  ]]
local GLYPH_ADMIN = nf.md_shield_half_full --[[ 󰞀 ]]
local GLYPH_LINUX = nf.cod_terminal_linux --[[  ]]
local GLYPH_DEBUG = nf.fa_bug --[[  ]]
-- local GLYPH_SEARCH = nf.fa_search --[[  ]]
local GLYPH_SEARCH = '🔭'

local GLYPH_UNSEEN_OUTPUT = {
  [1] = nf.md_numeric_1_box_multiple, --[[ 󰼏 ]]
  [2] = nf.md_numeric_2_box_multiple, --[[ 󰼐 ]]
  [3] = nf.md_numeric_3_box_multiple, --[[ 󰼑 ]]
  [4] = nf.md_numeric_4_box_multiple, --[[ 󰼒 ]]
  [5] = nf.md_numeric_5_box_multiple, --[[ 󰼓 ]]
  [6] = nf.md_numeric_6_box_multiple, --[[ 󰼔 ]]
  [7] = nf.md_numeric_7_box_multiple, --[[ 󰼕 ]]
  [8] = nf.md_numeric_8_box_multiple, --[[ 󰼖 ]]
  [9] = nf.md_numeric_9_box_multiple, --[[ 󰼗 ]]
  [10] = nf.md_numeric_9_plus_box_multiple, --[[ 󰼘 ]]
}

local TITLE_INSET = {
  DEFAULT = 6,
  ICON = 8,
}

local M = {}

local RENDER_VARIANTS = {
  { 'scircle_left', 'title', 'padding',       'scircle_right' },
  { 'scircle_left', 'title', 'unseen_output', 'padding',       'scircle_right' },
  { 'scircle_left', 'admin', 'title',         'padding',       'scircle_right' },
  { 'scircle_left', 'admin', 'title',         'unseen_output', 'padding',      'scircle_right' },
  { 'scircle_left', 'wsl',   'title',         'padding',       'scircle_right' },
  { 'scircle_left', 'wsl',   'title',         'unseen_output', 'padding',      'scircle_right' },
}

local SETUP_OPTS = {
  numbered_unseen_glyphs = true,
  hide_active_tab_unseen = true,
}

---@type table<string, Cells.SegmentColors>
-- stylua: ignore
local colors = {
  text_default          = { bg = '#45475A', fg = '#1C1B19' },
  text_hover            = { bg = '#587D8C', fg = '#1C1B19' },
  text_active           = { bg = '#7FB4CA', fg = '#11111B' },

  unseen_output_default = { bg = '#45475A', fg = '#FFA066' },
  unseen_output_hover   = { bg = '#587D8C', fg = '#FFA066' },
  unseen_output_active  = { bg = '#7FB4CA', fg = '#FFA066' },

  scircle_default       = { bg = 'rgba(0, 0, 0, 0.4)', fg = '#45475A' },
  scircle_hover         = { bg = 'rgba(0, 0, 0, 0.4)', fg = '#587D8C' },
  scircle_active        = { bg = 'rgba(0, 0, 0, 0.4)', fg = '#7FB4CA' },
}

---@param proc string
local function clean_process_name(proc)
  local a = string.gsub(proc, '(.*[/\\])(.*)', '%2')
  return a:gsub('%.exe$', '')
end

---@param process_name string
---@param base_title string
---@param max_width number
---@param inset number
local function create_title(process_name, base_title, max_width, inset)
  local title

  if process_name:len() > 0 then
    title = process_name .. ' ~ ' .. base_title
  else
    title = base_title
  end

  if base_title == 'Debug' then
    title = GLYPH_DEBUG .. ' DEBUG'
    inset = inset - 2
  end

  if base_title:match('^InputSelector:') ~= nil then
    title = base_title:gsub('InputSelector:', GLYPH_SEARCH)
    inset = inset - 2
  end

  if title:len() > max_width - inset then
    local diff = title:len() - max_width + inset
    title = title:sub(1, title:len() - diff)
  else
    local padding = max_width - title:len() - inset
    title = title .. string.rep(' ', padding)
  end

  return title
end

---@param panes any[] WezTerm https://wezfurlong.org/wezterm/config/lua/pane/index.html
local function check_unseen_output(panes)
  local unseen_output = false
  local unseen_output_count = 0

  for i = 1, #panes, 1 do
    if panes[i].has_unseen_output then
      unseen_output = true
      if unseen_output_count >= 10 then
        unseen_output_count = 10
        break
      end
      unseen_output_count = unseen_output_count + 1
    end
  end

  return unseen_output, unseen_output_count
end

---@class Tab
---@field title string
---@field cells Cells
---@field title_locked boolean
---@field locked_title string
---@field is_wsl boolean
---@field is_admin boolean
---@field unseen_output boolean
---@field unseen_output_count number
---@field is_active boolean
local Tab = {}
Tab.__index = Tab

function Tab:new()
  local tab = {
    title = '',
    cells = Cells:new(),
    title_locked = false,
    locked_title = '',
    is_wsl = false,
    is_admin = false,
    unseen_output = false,
    unseen_output_count = 0,
  }
  return setmetatable(tab, self)
end

---@param active_pane any WezTerm https://wezfurlong.org/wezterm/config/lua/pane/index.html
---@param panes any[] WezTerm https://wezfurlong.org/wezterm/config/lua/pane/index.html
---@param is_active boolean
---@param max_width number
function Tab:set_info(active_pane, panes, is_active, max_width)
  local process_name = clean_process_name(active_pane.foreground_process_name)

  self.is_wsl = process_name:match('^wsl') ~= nil
  self.is_admin = (
    active_pane.title:match('^Administrator: ') or active_pane.title:match('(Admin)')
  ) ~= nil
  self.unseen_output = false
  self.unseen_output_count = 0

  if not SETUP_OPTS.hide_active_tab_unseen or not is_active then
    self.unseen_output, self.unseen_output_count = check_unseen_output(panes)
  end

  local inset = (self.is_admin or self.is_wsl) and TITLE_INSET.ICON or TITLE_INSET.DEFAULT
  if self.unseen_output then
    inset = inset + 2
  end

  if self.title_locked then
    self.title = create_title('', self.locked_title, max_width, inset)
    return
  end
  self.title = create_title(process_name, active_pane.title, max_width, inset)
end

function Tab:create_cells()
  self.cells
      :add_segment('scircle_left', GLYPH_SCIRCLE_LEFT)
      :add_segment('admin', ' ' .. GLYPH_ADMIN)
      :add_segment('wsl', ' ' .. GLYPH_LINUX)
      :add_segment('title', ' ', nil, attr(attr.intensity('Bold')))
      :add_segment('unseen_output', ' ' .. GLYPH_CIRCLE)
      :add_segment('padding', ' ')
      :add_segment('scircle_right', GLYPH_SCIRCLE_RIGHT)
end

---@param title string
function Tab:update_and_lock_title(title)
  self.locked_title = title
  self.title_locked = true
end

---@param is_active boolean
---@param hover boolean
function Tab:update_cells(is_active, hover)
  local tab_state = 'default'
  if is_active then
    tab_state = 'active'
  elseif hover then
    tab_state = 'hover'
  end

  self.cells:update_segment_text('title', ' ' .. self.title)

  if SETUP_OPTS.numbered_unseen_glyphs and self.unseen_output then
    self.cells:update_segment_text(
      'unseen_output',
      ' ' .. GLYPH_UNSEEN_OUTPUT[self.unseen_output_count]
    )
  end

  self.cells
      :update_segment_colors('scircle_left', colors['scircle_' .. tab_state])
      :update_segment_colors('admin', colors['text_' .. tab_state])
      :update_segment_colors('wsl', colors['text_' .. tab_state])
      :update_segment_colors('title', colors['text_' .. tab_state])
      :update_segment_colors('unseen_output', colors['unseen_output_' .. tab_state])
      :update_segment_colors('padding', colors['text_' .. tab_state])
      :update_segment_colors('scircle_right', colors['scircle_' .. tab_state])
end

---@return FormatItem[] (ref: https://wezfurlong.org/wezterm/config/lua/wezterm/format.html)
function Tab:render()
  local variant_idx = self.is_admin and 3 or 1
  if self.is_wsl then
    variant_idx = 5
  end

  if self.unseen_output then
    variant_idx = variant_idx + 1
  end
  return self.cells:render(RENDER_VARIANTS[variant_idx])
end

---@type Tab[]
local tab_list = {}

---@param opts? {numbered_unseen_glyphs?: boolean, hide_active_tab_unseen?: boolean} Default: {numbered_unseen_glyphs = true, hide_active_tab_unseen = true}
M.setup = function(opts)
  if opts then
    if opts.numbered_unseen_glyphs ~= nil then
      assert(
        type(opts.numbered_unseen_glyphs) == 'boolean',
        'numbered_unseen_glyphs must be a boolean'
      )
      SETUP_OPTS.numbered_unseen_glyphs = opts.numbered_unseen_glyphs
    end

    if opts.hide_active_tab_unseen ~= nil then
      assert(
        type(opts.hide_active_tab_unseen) == 'boolean',
        'hide_active_tab_unseen must be a boolean'
      )
      SETUP_OPTS.hide_active_tab_unseen = opts.hide_active_tab_unseen
    end
  end

  -- CUSTOM EVENT
  -- Event listener to manually update the tab name
  -- Tab name will remain locked until the `reset-tab-title` is triggered
  wezterm.on('tabs.manual-update-tab-title', function(window, pane)
    window:perform_action(
      wezterm.action.PromptInputLine({
        description = wezterm.format({
          { Foreground = { Color = '#FFFFFF' } },
          { Attribute = { Intensity = 'Bold' } },
          { Text = 'Enter new name for tab' },
        }),
        action = wezterm.action_callback(function(_window, _pane, line)
          if line ~= nil then
            local tab = window:active_tab()
            local id = tab:tab_id()
            tab_list[id]:update_and_lock_title(line)
          end
        end),
      }),
      pane
    )
  end)

  -- CUSTOM EVENT
  -- Event listener to unlock manually set tab name
  wezterm.on('tabs.reset-tab-title', function(window, _pane)
    local tab = window:active_tab()
    local id = tab:tab_id()
    tab_list[id].title_locked = false
  end)

  -- CUSTOM EVENT
  -- Event listener to manually update the tab name
  wezterm.on('tabs.toggle-tab-bar', function(window, _pane)
    local effective_config = window:effective_config()
    window:set_config_overrides({
      enable_tab_bar = not effective_config.enable_tab_bar,
      background = effective_config.background,
    })
  end)

  -- BUILTIN EVENT
  wezterm.on('format-tab-title', function(tab, _tabs, _panes, _config, hover, max_width)
    if not tab_list[tab.tab_id] then
      tab_list[tab.tab_id] = Tab:new()
      tab_list[tab.tab_id]:set_info(tab.active_pane, tab.panes, tab.is_active, max_width)
      tab_list[tab.tab_id]:create_cells()
      return tab_list[tab.tab_id]:render()
    end

    tab_list[tab.tab_id]:set_info(tab.active_pane, tab.panes, tab.is_active, max_width)
    tab_list[tab.tab_id]:update_cells(tab.is_active, hover)
    return tab_list[tab.tab_id]:render()
  end)
end

return M