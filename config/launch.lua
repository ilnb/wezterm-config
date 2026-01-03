local platform = require 'utils.platform'

---@type Config
local options = {
  initial_rows = 30,
  initial_cols = 93,
}

if platform.is_win then
  options.default_prog = { 'pwsh', '-NoLogo' }
  options.launch_menu = {
    { label = 'PowerShell Core',    args = { 'pwsh', '-NoLogo' } },
    { label = 'PowerShell Desktop', args = { 'powershell' } },
    { label = 'Command Prompt',     args = { 'cmd' } },
    { label = 'Nushell',            args = { 'nu' } },
    -- { label = 'Git Bash', args = { 'C:\\Users\\kevin\\scoop\\apps\\git\\current\\bin\\bash.exe' }, },
  }
elseif platform.is_mac then
  options.default_prog = { '/opt/homebrew/bin/fish', '-l' }
  options.launch_menu = {
    { label = 'Bash',    args = { 'bash', '-l' } },
    { label = 'Fish',    args = { '/opt/homebrew/bin/fish', '-l' } },
    { label = 'Nushell', args = { '/opt/homebrew/bin/nu', '-l' } },
    { label = 'Zsh',     args = { 'zsh', '-l' } },
  }
elseif platform.is_linux then
  options.default_prog = { 'zsh' }
  options.launch_menu = {
    { label = 'Bash', args = { 'bash' } },
    { label = 'Fish', args = { 'fish' } },
    { label = 'Zsh',  args = { 'zsh' } },
  }
end

return options
