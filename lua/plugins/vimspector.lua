return {
    "puremourning/vimspector",
    lazy = false,
    keys = {
        { "<Leader>dl", "<cmd>VimspectorLoadSession<CR>", desc = "Load Vimspector-Session" },
        { "<Leader>db", "<cmd>call vimspector#ToggleBreakpoint()<CR>", desc = "Toggle Vimspector Breakpoint" },
        { "<Leader>dw", "<cmd>call vimspector#AddWatch()<CR>", desc = "Vimspector add watch" },
        { "<Leader>de", "<cmd>call vimspector#Evaluate()<CR>", desc = "Vimspector evaluate" },
        { "<Leader>dr", "<cmd>call vimspector#Launch()<CR>", desc = "Vimspector Launch" },
        { "<F8>", "<cmd>call vimspector#StepOver()<CR>" },
        { "<F7>", "<cmd>call vimspector#StepInto()<CR>" },
        --{ "<Leader><F8>", "<cmd>call vimspector#StepOut()<CR>" },
    },
}
