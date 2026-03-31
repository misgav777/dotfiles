return {
  "mfussenegger/nvim-lint",
  opts = {
    linters_by_ft = {
      markdown = {}, -- disable markdownlint; marksman LSP handles the important stuff
    },
  },
}
