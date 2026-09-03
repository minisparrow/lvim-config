local M = {}
local timer = nil

function M.start(interval)
  if timer then timer:stop() end

  timer = vim.loop.new_timer()
  timer:start(0, interval, vim.schedule_wrap(function()
    if vim.fn.line('.') >= vim.fn.line('$') then
      timer:stop()
    else
      require("neoscroll").scroll(1, true, interval)
    end
  end))
end

function M.stop()
  if timer then
    timer:stop()
    timer = nil
  end
end

return M
