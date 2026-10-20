local opt = vim.opt
opt.hidden         = true
opt.backup         = false
opt.writebackup    = false
opt.swapfile       = false
opt.undofile       = true
opt.undodir        = vim.fn.stdpath("data") .. "/undo"
opt.number         = true
opt.relativenumber = true
opt.signcolumn     = "yes"
opt.scrolloff      = 8
opt.splitright     = true
opt.splitbelow     = true
opt.tabstop        = 4
opt.shiftwidth     = 4
opt.expandtab      = true
opt.smartindent    = true
opt.updatetime     = 100
opt.timeoutlen     = 300
opt.ttimeoutlen    = 10
opt.synmaxcol      = 240
vim.opt.termguicolors = true
-- opt.lazyredraw     = true
opt.clipboard      = "unnamedplus"

-- Nerd Font icon helper (codepoints, so the file stays plain ASCII)
local function ic(cp) return vim.fn.nr2char(cp) end

if vim.fn.executable("rg") == 1 then
  opt.grepprg = "rg --vimgrep --no-heading --smart-case"
end

vim.api.nvim_create_user_command("Vr", function(opts)
  vim.cmd("vertical resize " .. opts.args)
end, { nargs = 1 })

vim.g.loaded_perl_provider    = 0
vim.g.loaded_ruby_provider    = 0
vim.g.loaded_node_provider    = 0
vim.g.loaded_python3_provider = 0

vim.g.mapleader = " "

if vim.g.neovide then
  vim.o.guifont                            = "Consolas Nerd Font:20"
  vim.g.neovide_scroll_animation_length   = 0
  vim.g.neovide_cursor_animation_length   = 0
  vim.g.neovide_cursor_trail_size         = 0
  vim.g.neovide_position_animation_length = 0
  vim.g.neovide_scale_factor              = 1.0
  local function change_scale(delta)
    vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
  end
  vim.keymap.set("n", "<D-=>", function() change_scale(1.05) end)
  vim.keymap.set("n", "<D-->", function() change_scale(1 / 1.05) end)
  vim.keymap.set("n", "<D-0>", function() vim.g.neovide_scale_factor = 1.0 end)
end

vim.diagnostic.config({
  virtual_text     = { spacing = 4, prefix = "●" },
  signs            = true,
  underline        = true,
  update_in_insert = false,
  severity_sort    = true,
})

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers.hover, {
    border = "rounded",
    max_width = 80,
    max_height = 20,
    focusable = true,
    style = "minimal",
    title = " docs ",
    title_pos = "center",
  }
)

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
  vim.lsp.handlers.signature_help, {
    border = "rounded",
    max_width = 80,
    focusable = false,
  }
)

vim.api.nvim_create_autocmd("User", {
  pattern = "Visual",
  callback = function() end,
})

local diag_signs = {
  Error = ic(0xF057) .. " ",
  Warn  = ic(0xF071) .. " ",
  Hint  = ic(0xF0EB) .. " ",
  Info  = ic(0xF05A) .. " ",
}
for type, icon in pairs(diag_signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end



local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
{
  "vim-scripts/railscasts",
  lazy = false,
  priority = 1000,
},
  {
    "folke/noice.nvim",
    lazy = false,
    dependencies = { "MunifTanjim/nui.nvim" },  -- nvim-notify removed
    opts = {
      cmdline   = { enabled = false },
      messages  = { enabled = false },
      popupmenu = { enabled = false },
      notify    = { enabled = false },           -- no more top-right popups
      lsp = {
        progress  = { enabled = false },         -- no more "Fetching rust-analyzer"
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
        hover     = { enabled = true },
        signature = { enabled = true },
      },
      presets = {
        bottom_search         = false,
        command_palette       = false,
        long_message_to_split = true,
        lsp_doc_border        = true,
      },
      routes = {
        { filter = { event = "msg_show", kind = "", find = "written" }, opts = { skip = true } },
      },
    },
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {
      indent = {
        char = "┆",
        tab_char = "┆",
      },
      scope = {
        enabled = true,
        show_start = false,  -- hides the underline on scope start
        show_end = false,    -- hides the underline on scope end
        highlight = { "Function", "Label" },  -- color the scope line differently
      },
      exclude = {
        filetypes = { "help", "dashboard", "lazy", "mason", "NvimTree" },
      },
    },
  },



  { "nvim-tree/nvim-web-devicons", lazy = true },

  {
    "echasnovski/mini.icons",
    version  = false,
    lazy     = false,
    priority = 999,
    config   = function()
      require("mini.icons").setup({
        style = "glyph",
        directory = {
          ["default"] = { glyph = ic(0xF07B), hl = "MiniIconsBlue"   },
          src         = { glyph = ic(0xF121), hl = "MiniIconsBlue"   },
          test        = { glyph = "󰙨",        hl = "MiniIconsGreen"  },
          build       = { glyph = ic(0xF085), hl = "MiniIconsOrange" },
          docs        = { glyph = "󰈙",        hl = "MiniIconsCyan"   },
          target      = { glyph = ic(0xF1B2), hl = "MiniIconsRed"    },
          [".git"]    = { glyph = ic(0xF1D3), hl = "MiniIconsOrange" },
          [".vscode"] = { glyph = ic(0xE70C), hl = "MiniIconsBlue"   },
        },
        filetype = {
          rust   = { glyph = ic(0xE7A8), hl = "MiniIconsOrange" },
          c      = { glyph = ic(0xE61E), hl = "MiniIconsBlue"   },
          cpp    = { glyph = ic(0xE61D), hl = "MiniIconsBlue"   },
          python = { glyph = "󰌠",        hl = "MiniIconsYellow" },
          lua    = { glyph = ic(0xE620), hl = "MiniIconsBlue"   },
          toml   = { glyph = ic(0xE615), hl = "MiniIconsOrange" },
        },
      })
    end,
  },

  {
    "szw/vim-maximizer",
    config = function()
      vim.keymap.set("n", "<leader>z", "<cmd>MaximizerToggle<CR>")
    end,
  },

  {
    "nvim-neo-tree/neo-tree.nvim",
    branch       = "v3.x",
    lazy         = false,
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim" },
    config       = function()
      require("neo-tree").setup({
        close_if_last_window = true,
        popup_border_style   = "rounded",
        enable_git_status    = true,
        window = {
          position = "left",
          width    = 30,
          mappings = {
            ["<CR>"] = "open",              ["l"] = "open",
            ["h"]    = "close_node",        ["a"] = "add",
            ["A"]    = "add_directory",     ["d"] = "delete",
            ["r"]    = "rename",            ["y"] = "copy_to_clipboard",
            ["x"]    = "cut_to_clipboard",  ["p"] = "paste_from_clipboard",
            ["q"]    = "close_window",      ["-"] = "navigate_up",
            ["."]    = "set_root",          ["H"] = "toggle_hidden",
          },
        },
        filesystem = {
          filtered_items         = { visible = false, hide_dotfiles = false, hide_gitignored = false },
          follow_current_file    = { enabled = true },
          use_libuv_file_watcher = true,
        },
        default_component_configs = {
          indent = { indent_size = 2, with_markers = true, indent_marker = "│", last_indent_marker = "└" },
          icon = {
            folder_closed = ic(0xF07B),
            folder_open   = ic(0xF07C),
            folder_empty  = ic(0xF114),
            default       = ic(0xF15B),
          },
          git_status = {
            symbols = {
              added     = ic(0xF067),
              modified  = ic(0xF040),
              deleted   = "✖",
              renamed   = "󰁕",
              untracked = ic(0xF128),
              ignored   = ic(0xF05E),
              unstaged  = "󰄱",
              staged    = ic(0xF00C),
              conflict  = ic(0xF071),
            },
          },
        },
      })
    end,
  },

  -- simple fuzzy finder: small split at the bottom, no preview, no popup
  {
    "ibhagwan/fzf-lua",
    config = function()
      require("fzf-lua").setup({
        winopts = {
          split = "belowright 10new",
          preview = { hidden = true },
        },
        files = {
          file_icons = false,
          git_icons = true,
          _fzf_nth_devicons = true,
        },
        grep = {
          file_icons = false,
          git_icons = false,
        },
        buffers = {
          file_icons = false,
          git_icons = true,
        },
        fzf_opts = {
          ["--layout"] = "default",
        },
      })
    end,
  },

  {
    "ThePrimeagen/harpoon",
    branch       = "harpoon2",
    keys         = { "<leader>a", "<leader>hh", "<leader>1", "<leader>2", "<leader>3", "<leader>4" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config       = function()
      local harpoon = require("harpoon")
      harpoon:setup()
      vim.keymap.set("n", "<leader>a",  function() harpoon:list():add() end)
      vim.keymap.set("n", "<leader>hh", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
      vim.keymap.set("n", "<leader>1",  function() harpoon:list():select(1) end)
      vim.keymap.set("n", "<leader>2",  function() harpoon:list():select(2) end)
      vim.keymap.set("n", "<leader>3",  function() harpoon:list():select(3) end)
      vim.keymap.set("n", "<leader>4",  function() harpoon:list():select(4) end)
    end,
  },

  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts  = { modes = { char = { enabled = false } } },
    keys  = { { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" } },
  },

  { "echasnovski/mini.ai", version = false, event = "VeryLazy", config = true },
  {
    "echasnovski/mini.surround",
    version = false,
    event   = "VeryLazy",
    opts    = { mappings = { add = "sa", delete = "sd", replace = "sr" } },
  },

  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts  = { signs = { add = { text = "│" }, change = { text = "│" }, delete = { text = "_" } } },
  },

  {
    "nvim-lualine/lualine.nvim",
    lazy         = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config       = function()
      require("lualine").setup({
        options = {
          theme                = "auto",
          component_separators = { left = "", right = "" },
          section_separators   = { left = "", right = "" },
          globalstatus         = true,
          disabled_filetypes   = { statusline = { "neo-tree" } },
        },
        sections = {
          lualine_a = { { "mode", fmt = function(s) return s:sub(1, 1) end } },
          lualine_b = {
            { "branch", icon = ic(0xE0A0) },
            { "diff", symbols = { added = "+", modified = "~", removed = "-" }, colored = true },
          },
          lualine_c = { { "filename", path = 1, symbols = { modified = "●", readonly = ic(0xF023), unnamed = "[No Name]" } } },
          lualine_x = { { "diagnostics", sources = { "nvim_lsp" }, symbols = { error = ic(0xF057) .. " ", warn = ic(0xF071) .. " ", hint = ic(0xF0EB) .. " ", info = ic(0xF05A) .. " " }, colored = true } },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
        inactive_sections = {
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "location" },
        },
      })
    end,
  },

  {
    "stevearc/aerial.nvim",
    event        = "LspAttach",
    keys         = { { "<leader>o", "<cmd>AerialToggle!<CR>", desc = "Toggle outline" } },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config       = function()
      require("aerial").setup({
        on_attach = function(bufnr)
          vim.keymap.set("n", "[[", "<cmd>AerialPrev<CR>", { buffer = bufnr })
          vim.keymap.set("n", "]]", "<cmd>AerialNext<CR>", { buffer = bufnr })
        end,
      })
    end,
  },

  {
    "mrcjkb/rustaceanvim",
    version = "^5",
    ft      = { "rust" },
    config  = function()
      vim.g.rustaceanvim = {
        server = {
          default_settings = {
            ["rust-analyzer"] = {
              cargo       = { allFeatures = true, buildScripts = { enable = true } },
              check       = { command = "clippy", extraArgs = { "--target-dir", "/tmp/rust-analyzer-check" } },
              procMacro   = { enable = true, attributes = { enable = true } },
              diagnostics = { enable = true, experimental = { enable = false } },
              completion  = { postfix = { enable = false }, autoimport = { enable = true } },
              inlayHints  = {
                bindingModeHints       = { enable = false },
                chainingHints          = { enable = true },
                closingBraceHints      = { minLines = 25 },
                closureReturnTypeHints = { enable = "never" },
                lifetimeElisionHints   = { enable = "never" },
                maxLength              = 25,
                parameterHints         = { enable = true },
                reborrowHints          = { enable = "never" },
                renderColons           = true,
                typeHints              = { enable = true, hideClosureInitialization = false, hideNamedConstructor = false },
              },
              cachePriming = { enable = false },
              lens         = { enable = false },
            },
          },
        },
      }
    end,
  },

  {
    "neovim/nvim-lspconfig",
    event  = { "BufReadPre", "BufNewFile" },
    config = function()
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(event)
          local opts = { buffer = event.buf }
          vim.keymap.set("n", "gd",         vim.lsp.buf.definition,    opts)
          vim.keymap.set("n", "K",          vim.lsp.buf.hover,         opts)
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename,        opts)
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action,   opts)
          vim.keymap.set("n", "<leader>e",  vim.diagnostic.open_float, opts)
          vim.keymap.set("n", "[d",         vim.diagnostic.goto_prev,  opts)
          vim.keymap.set("n", "]d",         vim.diagnostic.goto_next,  opts)
          vim.keymap.set("n", "<leader>ih", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
          end, opts)
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer   = event.buf,
            callback = function() vim.lsp.buf.format({ async = false }) end,
          })
          -- no semantic tokens: otherwise the LSP recolors variables via
          -- @lsp.type.* groups
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client then
            client.server_capabilities.semanticTokensProvider = nil
          end
        end,
      })
      vim.lsp.config("clangd", {
        cmd          = { "clangd" },
        filetypes    = { "c", "cpp", "objc", "objcpp" },
        root_markers = { "compile_commands.json", "compile_flags.txt", ".git" },
      })
      vim.lsp.enable("clangd")
      vim.lsp.config("pyright", {
        cmd          = { "pyright-langserver", "--stdio" },
        filetypes    = { "python" },
        root_markers = { "pyproject.toml", "setup.py", ".git" },
      })
      vim.lsp.enable("pyright")
    end,
  },

  {
    "hrsh7th/nvim-cmp",
    event        = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",     "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        performance = {
          debounce         = 80,
          throttle         = 30,
          fetching_timeout = 200,
          max_view_entries = 20,
        },
        snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
          ["<C-f>"]     = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]     = cmp.mapping.abort(),
          ["<CR>"]      = cmp.mapping.confirm({ select = true }),
          ["<Tab>"]     = cmp.mapping.select_next_item(),
          ["<S-Tab>"]   = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp", max_item_count = 15 },
          { name = "luasnip",  max_item_count = 5  },
        }, {
          { name = "buffer", max_item_count = 5, keyword_length = 3 },
          { name = "path",   max_item_count = 5 },
        }),
      })
    end,
  },

}, {
  checker          = { enabled = false },
  change_detection = { enabled = false },
})

-- MY THEME
vim.opt.background = "dark"
vim.opt.termguicolors = true
-- vim.cmd.colorscheme("zenburn")
vim.cmd.colorscheme("railscasts")

--Line number colors
--
vim.api.nvim_set_hl(0, "LineNr", {
    fg = "#6D9CBE",
    bg = "#2B2B2B",
})

vim.api.nvim_set_hl(0, "CursorLineNr", {
    fg = "#FFC66D",
    bg = "#2B2B2B",
    bold = true,
})

-- (treesitter autostart removed: this theme is meant to run on classic
--  regex syntax highlighting, where variables stay plain. With
--  treesitter on, the highlighting changes noticeably.)

vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  callback = function()
    vim.keymap.set({ "n", "i" }, "<F5>", function()
      vim.cmd("w")

      local cwd = vim.fn.getcwd()
      local cmd = "cd " .. vim.fn.shellescape(cwd)
        .. " && cargo run -q; echo; "
        .. "echo 'Press enter to close'; read; exit"

      vim.fn.system({
        "foot",
        "bash",
        "-c",
        cmd,
      })
    end, { buffer = true })

    vim.keymap.set("n", "<F4>", ":w<CR>:!cargo check<CR>", { buffer = true })
    vim.keymap.set("n", "<leader>ct", ":!cargo test<CR>", { buffer = true })
    vim.keymap.set("n", "<leader>cf", ":!cargo fmt<CR>", { buffer = true })
    vim.keymap.set("n", "<leader>cc", ":!cargo clippy<CR>", { buffer = true })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.keymap.set({ "n", "i" }, "<F5>", function()
      vim.cmd("w")

      local file = vim.fn.expand("%:p")
      local cwd = vim.fn.getcwd()

      local cmd = "cd " .. vim.fn.shellescape(cwd)
        .. " && python3 " .. vim.fn.shellescape(file)
        .. "; echo; read -rp 'Press enter to close'"

      vim.fn.jobstart({
        "foot",
        "bash",
        "-c",
        cmd,
      }, {
        detach = true,
      })
    end, { buffer = true })
  end,
})

vim.keymap.set("n", "<C-_>",     "gcc",  { remap = true, silent = true })
vim.keymap.set("v", "<C-_>",     "gc",   { remap = true, silent = true })
vim.keymap.set("n", "<leader>/", "gcc",  { remap = true, silent = true })
vim.keymap.set("v", "<leader>/", "gc",   { remap = true, silent = true })

vim.api.nvim_create_user_command("W",  "w",  {})
vim.api.nvim_create_user_command("Q",  "q",  {})
vim.api.nvim_create_user_command("Wq", "wq", {})
vim.api.nvim_create_user_command("WQ", "wq", {})

vim.keymap.set("v", "<D-c>", '"+y')
vim.keymap.set("v", "<C-c>", '"+y')
vim.keymap.set("n", "<D-v>", '"+p')
vim.keymap.set("i", "<D-v>", "<C-r>+")
vim.keymap.set("v", "<D-x>", '"+d')
vim.keymap.set("n", "<D-a>", "ggVG")
vim.keymap.set("i", "<D-a>", "<Esc>ggVG")

vim.keymap.set("n", "dd", '"_dd')
vim.keymap.set("n", "d",  '"_d')
vim.keymap.set("v", "d",  '"_d')

vim.keymap.set("n", "i", "a", { noremap = true })
vim.keymap.set("n", "a", "i", { noremap = true })
vim.keymap.set("n", "@", "i")
vim.keymap.set("n", "§", "i")
vim.keymap.set("n", "±", "i")

vim.keymap.set({ "n", "v" }, "e", "w",  { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "w", "b",  { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "E", "5w", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "W", "5b", { noremap = true, silent = true })

vim.keymap.set({ "n", "v" }, "H", "^", { noremap = true, silent = true })
vim.keymap.set({ "n", "v" }, "L", "$", { noremap = true, silent = true })

vim.keymap.set("x", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("x", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "<C-d>", "yyp",       { noremap = true, silent = true })
vim.keymap.set("i", "<C-d>", "<Esc>yypi", { noremap = true, silent = true })

vim.keymap.set("n", "<C-n>", "*Ncgn", { noremap = true, silent = true })

vim.keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true })
vim.keymap.set("n", "n",     "nzzzv",   { noremap = true, silent = true })
vim.keymap.set("n", "N",     "Nzzzv",   { noremap = true, silent = true })

vim.keymap.set("n", "J",  "mzJ`z", { noremap = true, silent = true })
vim.keymap.set("n", "gJ", "J",     { noremap = true, silent = true })

vim.keymap.set("x", "<leader>p", '"_dP', { noremap = true, silent = true })

vim.keymap.set("v", "<", "<gv", { noremap = true, silent = true })
vim.keymap.set("v", ">", ">gv", { noremap = true, silent = true })

vim.keymap.set("n", "<Esc>", ":noh<CR>", { noremap = true, silent = true })

vim.keymap.set("n", "<leader>r", ":%s/\\<<C-r><C-w>\\>//g<Left><Left>", { noremap = true })

vim.keymap.set("n", "<leader>;", "A;<Esc>", { noremap = true, silent = true })
vim.keymap.set("i", ";;",        "<Esc>A;", { noremap = true, silent = true })

vim.keymap.set("n", "Q", "@q", { noremap = true })

vim.keymap.set("n", "<C-h>", "<C-w>h", { noremap = true, silent = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { noremap = true, silent = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { noremap = true, silent = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { noremap = true, silent = true })

vim.keymap.set("n", "<C-s>", ":w<CR>")
vim.keymap.set("i", "<C-s>", "<Esc>:w<CR>a")

vim.keymap.set("n", "-",         "<cmd>Neotree toggle<CR>")
vim.keymap.set("n", "<leader>n", "<cmd>Neotree toggle<CR>")
vim.keymap.set("n", "<leader>N", "<cmd>Neotree toggle reveal_force_cwd<CR>")

-- file search: fd (+ proximity-sort if installed) piped into fzf
local function find_files()
  local opts = {}
  if vim.fn.executable("fd") == 1 then
    opts.cmd = "fd --color=never --hidden --type f --type l --exclude .git"
    local cur = vim.fn.expand("%")
    if cur ~= "" and vim.fn.fnamemodify(cur, ":h:.:S") ~= "." and vim.fn.executable("proximity-sort") == 1 then
      opts.cmd = opts.cmd .. (" | proximity-sort %s"):format(vim.fn.shellescape(cur))
    end
    opts.fzf_opts = {
      ["--scheme"]   = "path",
      ["--tiebreak"] = "index",
      ["--layout"]   = "default",
    }
  end
  require("fzf-lua").files(opts)
end

vim.keymap.set("n", "<C-p>",      find_files)
vim.keymap.set("n", "<leader>f",  find_files)
vim.keymap.set("n", "<leader>g",  function() require("fzf-lua").live_grep() end)
vim.keymap.set("n", "<leader>fr", function() require("fzf-lua").oldfiles() end)
vim.keymap.set("n", "<leader>fs", function() require("fzf-lua").lsp_document_symbols() end)
vim.keymap.set("n", "<leader>fb", function() require("fzf-lua").buffers() end)
vim.keymap.set("n", "<Tab>", "<cmd>bnext<CR>", { silent = true })
vim.keymap.set("n", "<S-Tab>", "<cmd>bprevious<CR>", { silent = true })
vim.keymap.set("n", "<leader>bd", "<cmd>bdelete<CR>")
vim.keymap.set("n", "<leader>bD", "<cmd>bdelete!<CR>")
vim.keymap.set("n", "<leader>bc", function()
  local bufs = vim.fn.getbufinfo({ buflisted = 1 })
  if #bufs > 1 then vim.cmd("bprevious"); vim.cmd("bdelete #")
  else vim.cmd("bdelete") end
end)

vim.keymap.set("n", "gt",         ":tabnext<CR>")
vim.keymap.set("n", "gT",         ":tabprevious<CR>")
vim.keymap.set("n", "<leader>tn", ":tabnew<CR>")
vim.keymap.set("n", "<leader>tc", ":tabclose<CR>")

vim.keymap.set({ "n", "v" }, "<S-CR>", "<Nop>", { noremap = true, silent = true })
vim.keymap.set("i",           "<S-CR>", "<CR>",  { noremap = true, silent = true })

vim.keymap.set("n", "vaf", "va{V", { noremap = true, silent = true })

vim.keymap.set("n", "<leader>dp", 'oprintln!("{:?}", );<Esc>hi', { noremap = true, silent = true })
vim.keymap.set("n", "<leader>dP", 'Oprintln!("{:?}", );<Esc>hi', { noremap = true, silent = true })

vim.keymap.set("n", "<leader>c", "gcc j", { remap = true, silent = true })

vim.keymap.set("n", "<leader>jf", "/fn <CR>:noh<CR>",    { noremap = true, silent = true })
vim.keymap.set("n", "<leader>jF", "?fn <CR>:noh<CR>",    { noremap = true, silent = true })
vim.keymap.set("n", "<leader>js", "/struct <CR>:noh<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>jS", "?struct <CR>:noh<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "<leader>ji", "/impl <CR>:noh<CR>",   { noremap = true, silent = true })
vim.keymap.set("n", "<leader>jI", "?impl <CR>:noh<CR>",   { noremap = true, silent = true })

vim.keymap.set("n", "[{", "?{<CR>:noh<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "]}", "/}<CR>:noh<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "[(", "?(<CR>:noh<CR>", { noremap = true, silent = true })
vim.keymap.set("n", "])", "/)<CR>:noh<CR>", { noremap = true, silent = true })

-- Rust: F5 runs the project in a new foot window (overrides the earlier
-- FileType rust autocmd's F5 because it is registered later)
vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  callback = function()
    vim.keymap.set({ "n", "i" }, "<F5>", function()
      vim.cmd("w")

      local cwd = vim.fn.getcwd()
      local cmd = "cd " .. vim.fn.shellescape(cwd)
        .. " && cargo run -q; echo; "
        .. "read -rp 'Press enter to close'; exit"

      vim.fn.jobstart({
        "foot",
        "bash",
        "-c",
        cmd,
      }, {
        detach = true,
      })
    end, { buffer = true })

    vim.keymap.set("n", "<F4>", ":w<CR>:!cargo check<CR>", { buffer = true })
    vim.keymap.set("n", "<leader>ct", ":!cargo test<CR>", { buffer = true })
    vim.keymap.set("n", "<leader>cf", ":!cargo fmt<CR>", { buffer = true })
    vim.keymap.set("n", "<leader>cc", ":!cargo clippy<CR>", { buffer = true })
  end,
})

