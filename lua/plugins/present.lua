return {
    -- LINUX PATH
    dir = '/home/thomas/plugins/present.nvim',

    -- MAC PATH
    -- dir = '/Users/thomaskatter/Plugins/nvim-plugins/present.nvim',
    config = function()
        require('present').setup {
            -- Set up the present.nvim plugin with default options
        }
    end,
}
