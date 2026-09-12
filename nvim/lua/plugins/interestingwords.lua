return {
  {
    "lfv89/vim-interestingwords",
    lazy = false,

    config = function()
      vim.g.interestingWordsGUIColors = {
        "#8CCBEA",
        "#A4E57E",
        "#FFDB72",
        "#FF7272",
        "#FFB3FF",
        "#9999FF",
      }

      vim.keymap.set(
        "n",
        "<leader>hw",
        "<cmd>call InterestingWords('n')<CR>",
        { silent = true, desc = "Highlight word" }
      )

      vim.keymap.set(
        "n",
        "<leader>hC",
        "<cmd>call UncolorAllWords()<CR>",
        { silent = true, desc = "Clear all highlights" }
      )

      vim.keymap.set(
        "n",
        "<leader>hn",
        "<cmd>call WordNavigation('forward')<CR>",
        { silent = true, desc = "Next highlighted word" }
      )

      vim.keymap.set(
        "n",
        "<leader>hp",
        "<cmd>call WordNavigation('backward')<CR>",
        { silent = true, desc = "Previous highlighted word" }
      )
    end,
  },
}
