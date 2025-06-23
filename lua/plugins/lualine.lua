return {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
  opts = function()
    return {
      icons_enabled = true,
      theme = "auto",
      -- section_separators = { left = "►", right = "◀" },
      -- section_separators = { left = "|", right = "|" },
      -- component_separators = { left = "|", right = "|" },
      -- component_separators = { left = "", right = "" },
      sections = {
        lualine_a = {
          "mode",
          {
            "lsp_status",
            ignore_lsp = { "copilot" },
          },
        },
        lualine_b = { "branch", "diff", { "buffers", hide_filename_extension = true } },
        lualine_c = {
          { "filename", file_status = true, path = 4, shorting_target = 40 },
          "diagnostics",
          "searchcount",
        },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "location", "progress" },
        lualine_z = { {
          "datetime",
          style = "%H:%M",
        } },
      },
    }
  end,
}

-- TODO: remove bloat from LSP section
