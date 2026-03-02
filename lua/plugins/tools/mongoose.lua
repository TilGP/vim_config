return {
  "XiaoConstantine/mongoose.nvim",
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    require("mongoose").setup()
    -- Optional: Add local llm for analysis
    require("mongoose").configure_llm({
      provider = "llamacpp",
    })
  end,
}
