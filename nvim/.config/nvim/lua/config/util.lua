-- Shared helpers used across `config.*` modules.
--
-- This module is pure Lua with no plugin dependencies, so `init.lua` can
-- require it before the first `vim.pack.add()` call.

local M = {}

---Expand a `owner/repo` shorthand into a full GitHub URL for `vim.pack.add()`.
---@param repo string
---@return string
function M.gh(repo)
  return "https://github.com/" .. repo
end

local pack_group = vim.api.nvim_create_augroup("slim-pack", { clear = true })

---Run `callback` when a plugin is installed/updated by `vim.pack`.
---
---Build hooks (e.g. `:TSUpdate` after nvim-treesitter changes) need the plugin
---on the runtimepath before they can run -- `ev.data.active` is false when the
---plugin was installed during this session but not yet sourced, hence the
---`packadd`. See `:h vim.pack-events`.
---
---@param plugin_name string as it appears in `ev.data.spec.name`
---@param kinds string[] which `ev.data.kind` values to react to, e.g. `{ "install", "update" }`
---@param callback fun(data: table)
---@param desc string
function M.on_packchanged(plugin_name, kinds, callback, desc)
  vim.api.nvim_create_autocmd("PackChanged", {
    group = pack_group,
    desc = desc,
    callback = function(ev)
      if ev.data.spec.name ~= plugin_name or not vim.tbl_contains(kinds, ev.data.kind) then
        return
      end
      if not ev.data.active then
        vim.cmd.packadd(plugin_name)
      end
      callback(ev.data)
    end,
  })
end

return M
