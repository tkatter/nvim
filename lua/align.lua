local function do_align(align_to, start_lnum, end_lnum)
    local lines = vim.api.nvim_buf_get_lines(0, start_lnum, end_lnum, false)
    local new_lines = {}
    local g_idx = 0

    for i, l in ipairs(lines) do
      local s_idx, e_idx = string.find(l, align_to, 1, true)
      if not s_idx then
        goto continue
      end

      local front = vim.fn.trim(string.sub(l, 1, s_idx - 1), '', 2)
      local align_pt = string.sub(l, s_idx, e_idx)
      local back = vim.fn.trim(string.sub(l, e_idx + 1), '', 1)

      if string.len(front) > g_idx then
        g_idx = string.len(front)
      end

      new_lines[i] = { front, align_pt, back }
      ::continue::
    end

    for k, v in pairs(new_lines) do
      local space = string.rep(' ', g_idx - string.len(v[1]) + 1)
      lines[k] = string.format('%s%s%s %s', v[1], space, v[2], v[3])
    end

    vim.api.nvim_buf_set_lines(0, start_lnum, end_lnum, false, lines)
end

vim.api.nvim_create_user_command(
  'Align',
  function(opts)
    do_align(opts.args, opts.line1 - 1, opts.line2)
  end,
  { nargs = 1, range = true }
)

vim.keymap.set('v', '<Leader>aa', function()
  local pos = vim.fn.getpos('.')
  local line = vim.fn.getline(pos[2])
  local match = vim.fn.matchstr(line, '\\S*\\%' .. pos[3] .. 'c\\S*')
  if match == '' then
    return nil
  end

  local other_pos = vim.fn.getpos('v')[2]
  if other_pos < pos[2] then
    do_align(match, other_pos - 1, pos[2])
  end
  if other_pos > pos[2] then
    do_align(match, pos[2] - 1, other_pos)
  end
end, { desc = 'Align the selection to the WORD under the cursor' })
