-- Simple PDF opening with Sioyek

-- Add command to open PDF with Sioyek
vim.api.nvim_create_user_command("OpenPDF", function()
  local file = vim.fn.expand("%:p")
  if file:match("%.pdf$") then
    os.execute("open -a Sioyek '" .. file:gsub("'", "'\\''") .. "' >/dev/null 2>&1 &")
    vim.notify("Opening " .. vim.fn.fnamemodify(file, ":t") .. " in Sioyek", vim.log.levels.INFO)
  else
    vim.notify("Current file is not a PDF", vim.log.levels.WARN)
  end
end, {})

-- Simple keymap
vim.keymap.set("n", "<leader>po", function()
  vim.cmd("OpenPDF")
end, { noremap = true, silent = true, desc = "Open PDF in Sioyek" })
