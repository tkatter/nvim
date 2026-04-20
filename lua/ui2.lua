local ui2  = require('vim._core.ui2')
local msgs = require('vim._core.ui2.messages')
ui2.enable({
  enable = true,
  msg = {
    targets = {
      ['']         = 'msg',
      bufwrite     = 'msg',
      completion   = 'cmd',
      confirm      = 'cmd',
      echo         = 'msg',
      echoerr      = 'pager',
      echomsg      = 'msg',
      empty        = 'cmd',
      emsg         = 'pager',
      list_cmd     = 'pager',
      lua_error    = 'pager',
      lua_print    = 'msg',
      progress     = 'pager',
      quickfix     = 'msg',
      rpc_error    = 'pager',
      search_cmd   = 'cmd',
      search_count = 'cmd',
      shell_cmd    = 'pager',
      shell_err    = 'pager',
      shell_out    = 'pager',
      shell_ret    = 'msg',
      undo         = 'msg',
      verbose      = 'pager',
      wildlist     = 'cmd',
      wmsg         = 'msg',
    },
    cmd = {
      height  = 0.5,
    },
    dialog = {
      height  = 0.5,
    },
    msg = {
      height  = 0.3,
      timeout = 3000,
    },
    pager = {
      height  = 0.5,
    },
  },
})

-- Notification/toasts
local orig_set_pos = msgs.set_pos
msgs.set_pos = function(tgt)
  orig_set_pos(tgt)
  if (tgt == 'msg' or tgt == nil)
  and vim.api.nvim_win_is_valid(ui2.wins.msg) then
    pcall(vim.api.nvim_win_set_config, ui2.wins.msg, {
      anchor   = 'NE',
      border   = 'rounded',
      col      = vim.o.columns - 1,
      relative = 'editor',
      row      = 1,
      style    = 'minimal',
    })
  end
end
