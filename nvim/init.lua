local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
vim.opt.rtp:prepend(lazypath)
-- ========================
-- BASIC SETTINGS
-- ========================

vim.opt.number = true          -- line numbers
vim.opt.relativenumber = true  -- relative numbers
vim.opt.tabstop = 4            -- tab width
vim.opt.shiftwidth = 4         -- indent width
vim.opt.expandtab = true       -- tabs -> spaces
vim.opt.smartindent = true     -- auto indent
vim.opt.wrap = true            -- no line wrap

-- ========================
-- CLIPBOARD
-- ========================

vim.opt.clipboard = "unnamedplus"  -- system clipboard (needs xclip/xsel)

-- ========================
-- SEARCH
-- ========================

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.incsearch = true

-- ========================
-- UI / EXPERIENCE
-- ========================

vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 50

vim.cmd([[
  hi StatusLine guibg=#1e1e2e guifg=#cdd6f4
  hi StatusLineNC guibg=#181825 guifg=#6c7086
]])

-- ========================
-- KEYMAPS (QOL)
-- ========================

vim.g.mapleader = " "

-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-l>", "<C-w>l")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")

-- Clear search highlight
vim.keymap.set("n", "<leader>h", ":nohlsearch<CR>")

-- Quick save & quit
vim.keymap.set("n", "<leader>w", ":w<CR>")
vim.keymap.set("n", "<leader>q", ":q<CR>")

-- Move selected lines up/down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Keep cursor centered when scrolling
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- ========================
-- MISC
-- ========================

vim.opt.clipboard:append("unnamed") -- fallback safety
vim.opt.mouse = "a"                 -- enable mouse (optional)

-- LSP keymaps
vim.keymap.set("n", "K", vim.lsp.buf.hover)
vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "gr", vim.lsp.buf.references)
vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename)
vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)

-- ========================
-- NICE STATUSLINE (NO PLUGINS)
-- ========================

local function git_branch()
local branch = vim.fn.system("git branch --show-current 2>/dev/null"):gsub("\n", "")
if branch ~= "" then
return " " .. branch
end
return ""
end

local function diagnostics()
local errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
local warns  = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })

local result = ""
if errors > 0 then
result = result .. "  " .. errors
end
if warns > 0 then
result = result .. "  " .. warns
end
return result
end

local modes = {
n = " NORM",
i = "󰏫 INS",
v = " VIS",
V = " V-LINE",
[""] = " V-BLK",
c = " CMD",
R = " REPL",
}

function _G.statusline()
local mode = modes[vim.fn.mode()] or "?"
local file = "%t"
local modified = "%m"
local readonly = "%r"

local branch = git_branch()
local diag = diagnostics()

local left = string.format(" %s › %s%s%s ", mode, file, modified, readonly)
local mid = string.format("%s %s", branch, diag)
local right = string.format(" %%= %s", "%l:%c")

return left .. "%=" .. mid .. right
end

vim.o.statusline = "%!v:lua.statusline()"

require("lazy").setup({
    {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
        require("catppuccin").setup({
            flavour = "mocha",
            transparent_background = true,
            color_overrides = {
                mocha = {
                    -- Deep dark background
                    base = "#0a0a0f",
                    
                    -- Brighter Foreground for readability
                    text = "#f1f1f1",      -- Pure white-ish for maximum contrast
                    subtext1 = "#e0e0e0",  -- Lighter grey
                    subtext0 = "#d1d1d1",
                    
                    -- Vibrant accents (pop against blur)
                    pink = "#ffb3e6",      -- Brightened light pink
                    mauve = "#d8b4fe",     -- Brightened light purple
                },
            },
            custom_highlights = function(colors)
                return {
                    -- Current line number (very bright purple)
                    LineNrAbove = { fg = colors.subtext0 }, 
                    LineNr = { fg = "#ffffff", style = { "bold" } }, -- Active line is bold white
                    LineNrBelow = { fg = colors.subtext0 },
                    
                    -- If you use relative numbers, this makes them pop
                    CursorLineNr = { fg = colors.mauve, style = { "bold" } }, 
                }
            end,
        })
        vim.cmd.colorscheme("catppuccin")
    end,
},
    {
        "hrsh7th/nvim-cmp",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
        },
        config = function()
            local cmp = require("cmp")

            cmp.setup({
                mapping = cmp.mapping.preset.insert({
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                }),
                sources = {
                    { name = "nvim_lsp" },
                },
            })
        end,
    },
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = function()
            require("nvim-autopairs").setup({})
        end,
    },

    {
        "neovim/nvim-lspconfig", -- still useful as a dependency layer
        config = function()
            local cmp_lsp = require("cmp_nvim_lsp")

            vim.lsp.config("clangd", {
                cmd = { "clangd" },
                filetypes = { "c", "cpp" },
                capabilities = cmp_lsp.default_capabilities(),
            })

            vim.lsp.enable("clangd")
        end,
    },

})

vim.diagnostic.config({
    virtual_text = true,
    signs = true,
    underline = true,
})
