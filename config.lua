-- doom_config - Doom Nvim user configurations file
--
-- This file contains the user-defined configurations for Doom nvim.
-- Just override stuff in the `doom` global table (it's injected into scope
-- automatically).

-- ADDING A PACKAGE
--
-- doom.use_package("EdenEast/nightfox.nvim", "sainnhe/sonokai")
-- doom.use_package({
--   "ur4ltz/surround.nvim",
--   config = function()
--     require("surround").setup({mappings_style = "sandwich"})
--   end
-- })

-- ADDING A KEYBIND
--
-- doom.use_keybind({
--   -- The `name` field will add the keybind to whichkey
--   {"<leader>s", name = '+search', {
--     -- Bind to a vim command
--     {"g", "Telescope grep_string<CR>", name = "Grep project"},
--     -- Or to a lua function
--     {"p", function()
--       print("Not implemented yet")
--     end, name = ""}
--   }}
-- })

-- ADDING A COMMAND
--
-- doom.use_cmd({
--   {"CustomCommand1", function() print("Trigger my custom command 1") end},
--   {"CustomCommand2", function() print("Trigger my custom command 2") end}
-- })

-- ADDING AN AUTOCOMMAND
--
-- doom.use_autocmd({
--   { "FileType", "javascript", function() print('This is a javascript file') end }
-- })

doom.indent = 2
doom.core.treesitter.settings.show_compiler_warning_message = false
doom.core.reloader.settings.reload_on_save = false
doom.max_columns = 120

vim.opt.mouse = nil
vim.opt.colorcolumn = '0'
vim.opt.foldcolumn = '0'

vim.opt.foldlevelstart = 99
vim.opt.foldmethod = 'expr'
vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
vim.opt.foldtext = [[substitute(getline(v:foldstart),'\\\\t',repeat('\\ ',&tabstop),'g').'...'.trim(getline(v:foldend)) . ' (' . (v:foldend - v:foldstart + 1) . ' lines)']]

vim.opt.ignorecase = true
vim.opt.smartcase = true

doom.use_package(
  -- for the repeated blaming
  "tpope/vim-fugitive",

  -- get the right formating for your languge
  -- this only really is helpful when formatting the entire buffer
  -- lsp region_format is better
  "sbdchd/neoformat",

  -- Branches everywhere
  "mbbill/undotree",

  -- vscode style lightbulb for code actions
  "kosayoda/nvim-lightbulb",

  -- OSC 52 yanking goodness
  "ojroques/vim-oscyank"
)

function vim.getVisualSelection()
	vim.cmd('noau normal! "vy"')
	local text = vim.fn.getreg('v')
	vim.fn.setreg('v', {})

	text = string.gsub(text, "\n", "")
	if #text > 0 then
		return text
	else
		return ''
	end
end

local function telescope()
  -- lazily require telescope
  local telescope = require("telescope.builtin")
  return telescope
end

doom.use_keybind({
  { "<leader>", name = '+prefix', {
    { ",", "<cmd>Telescope buffers sort_mru=true<cr>", name = "Buffer MRU list", },
    { "*", "<cmd>Telescope grep_string<cr>", name = "Grep project for symbol", },
    { "f", name = '+file', {
      { "d", function() telescope().find_files({ cwd = vim.fn.expand("%:p:h") }) end,
        name = "Find file from cwd" },
    } },
    { "o", name = "+open/close", {
      { "u", "<cmd>UndotreeToggle<cr><cmd>UndotreeFocus<cr>", name ="Open undotree"}
    } },
    { "g", name = '+git', {
      { "gb", "<cmd>Git blame<cr>", name = "Fugitive git blame" },
    } },
    { "j", name = '+jump', {
      { "o", "<cmd>ClangdSwitchSourceHeader<cr>", name = "Jump to header/source via clangd" },
      { "O",
        function() telescope().find_files({ find_command = { "fd", "--type", "f", vim.fn.expand("%:t:r") } }) end,
        name = "Jump to files with same stem" },
    } },
    { "c", name = '+code', {
      { "la", vim.lsp.buf.code_action, name = "Suggest code actions" },
    } },
  } },
  { mode = "v", {
    { "gF", vim.lsp.formatexpr, name = "LSP format region" },
    { "<leader>*", function() telescope().grep_string({ search = vim.getVisualSelection() }) end, name = "Grep project for symbol", },
  } },
})

doom.use_autocmd({
  { "CursorHold,CursorHoldI", "*", require('nvim-lightbulb').update_lightbulb }
})

doom.langs.cc.settings.language_server_name = "clangd"

-- vim: sw=2 sts=2 ts=2 expandtab
