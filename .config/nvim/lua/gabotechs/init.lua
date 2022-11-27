local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
local install_plugins = false

if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  print('Installing packer...')
  local packer_url = 'https://github.com/wbthomason/packer.nvim'
  vim.fn.system({'git', 'clone', '--depth', '1', packer_url, install_path})
  print('Done.')

  vim.cmd('packadd packer.nvim')
  install_plugins = true
end

require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use 'ms-jpq/coq.nvim'
  use 'neovim/nvim-lspconfig'
  use "rafamadriz/neon"
  use 'preservim/nerdtree'

  if install_plugins then
    require('packer').sync()
  end
end)

if install_plugins then
  return
end

local lsp = require "lspconfig"
local coq = require "coq"

lsp.tsserver.setup{}
lsp.pyright.setup{}
lsp.rust_analyzer.setup{}
lsp.gopls.setup{}

vim.opt.nu = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.smartindent = true

vim.opt.clipboard = "unnamedplus"
vim.opt.termguicolors = true

vim.opt.wrap = false

vim.g.mapleader = " "

vim.cmd[[
    syntax on
    colorscheme neon
    autocmd StdinReadPre * let s:std_in=1
    autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists('s:std_in') |
        \ execute 'NERDTree' argv()[0] | wincmd p | enew | execute 'cd '.argv()[0] | endif
    COQnow
]]

vim.keymap.set('n', '<leader>w', '<cmd>w<cr>')
vim.keymap.set('n', '<leader>q', '<cmd>q<cr>')
vim.keymap.set('n', '<leader>Q', '<cmd>q!<cr>')
vim.api.nvim_set_keymap('i', 'kj'        , '<Esc>'               , {noremap = true, silent = false})
vim.api.nvim_set_keymap('n', '<leader>pv', '<cmd>Ex<CR>'         , {noremap = true, silent = false})
vim.api.nvim_set_keymap('n', '<leader>n' , ':NERDTreeFocus<CR>'  , {noremap = true, silent = false})
vim.api.nvim_set_keymap('n', '<C-n>'     , ':NERDTree<CR>'       , {noremap = true, silent = false})
vim.api.nvim_set_keymap('n', '<C-t>'     , ':NERDTreeToggle<CR>' , {noremap = true, silent = false})
vim.api.nvim_set_keymap('n', '<C-t>'     , ':NERDTreeFind<CR>'   , {noremap = true, silent = false})

