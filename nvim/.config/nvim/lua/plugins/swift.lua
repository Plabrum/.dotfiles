return {
  -- LSP Configuration for Swift
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        sourcekit = {
          -- sourcekit-lsp configuration
          -- The language server is provided by Xcode Command Line Tools
          cmd = {
            "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/sourcekit-lsp",
          },
          filetypes = { "swift", "objective-c", "objective-cpp" },
          root_dir = require("lspconfig.util").root_pattern(
            "buildServer.json", -- Created by xcode-build-server
            "*.xcodeproj",
            "*.xcworkspace",
            "Package.swift",
            "project.yml" -- XcodeGen
          ),
        },
      },
    },
  },

  -- xcodebuild.nvim - Build, run, test iOS/macOS apps
  {
    "wojciech-kulik/xcodebuild.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-treesitter/nvim-treesitter", -- (optional) for syntax highlighting in logs
    },
    config = function()
      require("xcodebuild").setup({
        -- Put some options here or leave empty to use defaults
        -- Refer to: https://github.com/wojciech-kulik/xcodebuild.nvim
        restore_on_start = true, -- Restore last build target on start
        auto_save = true, -- Auto-save files before building
        show_build_progress_bar = true,
        logs = {
          auto_open_on_success_tests = false,
          auto_open_on_failed_tests = true,
          auto_open_on_success_build = false,
          auto_open_on_failed_build = true,
          auto_close_on_app_launch = true,
        },
      })

      -- Keymaps for xcodebuild
      local wk = require("which-key")
      wk.add({
        { "<leader>x", group = "Xcode" },
        { "<leader>xb", "<cmd>XcodebuildBuild<cr>", desc = "Build Project" },
        { "<leader>xB", "<cmd>XcodebuildBuildForTesting<cr>", desc = "Build For Testing" },
        { "<leader>xr", "<cmd>XcodebuildBuildRun<cr>", desc = "Build & Run" },
        { "<leader>xt", "<cmd>XcodebuildTest<cr>", desc = "Run Tests" },
        { "<leader>xT", "<cmd>XcodebuildTestClass<cr>", desc = "Test Class" },
        { "<leader>x.", "<cmd>XcodebuildTestSelected<cr>", desc = "Test Selected" },
        { "<leader>xd", "<cmd>XcodebuildSelectDevice<cr>", desc = "Select Device" },
        { "<leader>xs", "<cmd>XcodebuildSelectScheme<cr>", desc = "Select Scheme" },
        { "<leader>xc", "<cmd>XcodebuildToggleCodeCoverage<cr>", desc = "Toggle Code Coverage" },
        { "<leader>xC", "<cmd>XcodebuildShowCodeCoverageReport<cr>", desc = "Show Code Coverage" },
        { "<leader>xl", "<cmd>XcodebuildToggleLogs<cr>", desc = "Toggle Logs" },
        { "<leader>xp", "<cmd>XcodebuildPicker<cr>", desc = "Show All Actions" },
        { "<leader>xq", "<cmd>Telescope quickfix<cr>", desc = "Show Quickfix List" },
      })
    end,
  },

  -- Treesitter for Swift syntax highlighting
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      if type(opts.ensure_installed) == "table" then
        vim.list_extend(opts.ensure_installed, { "swift" })
      end
    end,
  },
}
