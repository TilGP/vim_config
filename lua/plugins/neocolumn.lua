return {
    "parmeniong/neocolumn.nvim",
    opts = {
        -- these colors will be used on the neocolumn
        colors = {
            normal = "#7d7d7d", -- the color of the neocolumn
            error = "#db4b4b", -- the color of the neocolumn to display errors
            warn = "#e0af68", -- the color of the neocolumn to display warnings
            info = "#0db9d7", -- the color of the neocolumn info diagnostics
            hint = "#1abc9c", -- the color of the neocolumn hint diagnostics
            bg = nil, -- the background color of the neocolumn. Set to nil to use whatever
            -- color happens to be behind the neocolumn
            cursor_bg = nil, -- the background color of the neocolumn on the same line as the
            -- cursor. Set to nil to use whatever color happens to be behind the
            -- neocolumn
        },
        -- neocolumn.nvim will be disabled in buffers with these filetypes
        exclude_filetypes = {
            "help",
            "man",
        },
        -- When enabled, the neocolumn will be colored depending on each line's diagnostics
        diagnostics = true,
        -- If `diagnostics` is `true` then diagnostic with a severity lower than this will be ignored
        min_diagnostic_severity = vim.diagnostic.severity.HINT,
        -- The maximum allowed length for a line. The neocolumn will be placed one column to the right
        max_line_length = 100,
        -- The character use as the neocolumn
        character = "│",
        -- The neocolumn will be shown only if the length of the current line is this close to it
        -- zero will make the neocolumn always visible
        max_distance = 0,
    },
}
