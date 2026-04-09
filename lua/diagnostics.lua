-- It's good practice to namespace custom handlers to avoid collisions
-- vim.diagnostic.handlers["my/notify"] = {
--   show = function(namespace, bufnr, diagnostics, opts)
--     -- In our example, the opts table has a "log_level" option
--     local level = opts["my/notify"].log_level
--
--     local name = vim.diagnostic.get_namespace(namespace).name
--     local msg = string.format("%d diagnostics in buffer %d from %s",
--                               #diagnostics,
--                               bufnr,
--                               name)
--     vim.notify(msg, level)
--   end,
-- }

-- diagnostic-on-jump-example
-- diagnostic-loclist-example
-- diagnostic-handlers-example

vim.diagnostic.config {
    severity_sort = true,
    float = {
      border = 'rounded',
      scope = 'line',
      source = 'if_many',
      suffix = nil,
      prefix = nil,
      format = function(diag)
        return diag.message
      end
    },
    underline = {
      severity = {
        vim.diagnostic.severity.ERROR,
        vim.diagnostic.severity.WARN,
      }
    },
    virtual_text = {
        current_line = true,
        spacing = 2,
        format = function(diagnostic)
            local diagnostic_message = {
                [vim.diagnostic.severity.ERROR] = diagnostic.message,
                [vim.diagnostic.severity.WARN] = diagnostic.message,
                [vim.diagnostic.severity.INFO] = diagnostic.message,
                [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
        end,
    },
  -- ["my/notify"] = {
  --   log_level = vim.log.levels.INFO,
  --   -- This handler will only receive "error" diagnostics.
  --   severity = vim.diagnostic.severity.WARN,
  -- },
}

-- Existing handlers can be overridden. For example, use the following to only
-- show a sign for the highest severity diagnostic on a given line: >lua
--
--     -- Create a custom namespace. This will aggregate signs from all other
--     -- namespaces and only show the one with the highest severity on a
--     -- given line
--     local ns = vim.api.nvim_create_namespace("my_namespace")
--
--     -- Get a reference to the original signs handler
--     local orig_signs_handler = vim.diagnostic.handlers.signs
--
--     -- Override the built-in signs handler
--     vim.diagnostic.handlers.signs = {
--       show = function(_, bufnr, _, opts)
--         -- Get all diagnostics from the whole buffer rather than just the
--         -- diagnostics passed to the handler
--         local diagnostics = vim.diagnostic.get(bufnr)
--
--         -- Find the "worst" diagnostic per line
--         local max_severity_per_line = {}
--         for _, d in pairs(diagnostics) do
--           local m = max_severity_per_line[d.lnum]
--           if not m or d.severity < m.severity then
--             max_severity_per_line[d.lnum] = d
--           end
--         end
--
--         -- Pass the filtered diagnostics (with our custom namespace) to
--         -- the original handler
--         local filtered_diagnostics = vim.tbl_values(max_severity_per_line)
--         orig_signs_handler.show(ns, bufnr, filtered_diagnostics, opts)
--       end,
--       hide = function(_, bufnr)
--         orig_signs_handler.hide(ns, bufnr)
--       end,
--     }
