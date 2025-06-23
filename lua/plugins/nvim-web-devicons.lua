
return {
    {
        "nvim-tree/nvim-web-devicons",
        -- Lots of plugins require this
        lazy = true,
        opts = {
            -- Make the icon for query files more visible
            override = {
                scm = {
                    icon = '󰘧',
                    color = '#A9ABAC',
                    name = 'Scheme',
                },
            },
        },
    },
}
