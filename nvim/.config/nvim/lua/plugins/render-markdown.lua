return {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 
        'nvim-treesitter/nvim-treesitter',
        'nvim-tree/nvim-web-devicons' -- Optional: for file icons
    },
    ft = { 'markdown', 'quarto', 'rmd' }, -- Load only for markdown files
    config = function()
        require('render-markdown').setup({
            -- General settings
            enabled = true,
            max_file_size = 10.0, -- MB
            debounce = 100,
            render_modes = { 'n', 'c', 't' },
            anti_conceal = {
                enabled = true,
                above = 1,
                below = 1,
                ignore = {
                    code_background = true,
                    sign = true,
                },
            },
            
            -- Heading configuration
            heading = {
                enabled = true,
                sign = true,
                position = 'overlay',
                icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
                signs = { '󰫎 ' },
                width = 'full',
                left_pad = 0,
                right_pad = 0,
                min_width = 0,
                border = false,
                border_prefix = false,
                above = '▄',
                below = '▀',
                backgrounds = {
                    'RenderMarkdownH1Bg',
                    'RenderMarkdownH2Bg',
                    'RenderMarkdownH3Bg',
                    'RenderMarkdownH4Bg',
                    'RenderMarkdownH5Bg',
                    'RenderMarkdownH6Bg',
                },
                foregrounds = {
                    'RenderMarkdownH1',
                    'RenderMarkdownH2',
                    'RenderMarkdownH3',
                    'RenderMarkdownH4',
                    'RenderMarkdownH5',
                    'RenderMarkdownH6',
                },
            },
            
            -- Code block configuration
            code = {
                enabled = true,
                sign = true,
                style = 'full',
                position = 'left',
                language_pad = 0,
                disable_background = { 'diff' },
                width = 'full',
                left_pad = 0,
                right_pad = 0,
                min_width = 0,
                border = 'thin',
                above = '▄',
                below = '▀',
                highlight = 'RenderMarkdownCode',
                highlight_inline = 'RenderMarkdownCodeInline',
            },
            
            -- Dash configuration for thematic breaks
            dash = {
                enabled = true,
                icon = '─',
                width = 'full',
                highlight = 'RenderMarkdownDash',
            },
            
            -- Bullet list configuration
            bullet = {
                enabled = true,
                icons = { '●', '○', '◆', '◇' },
                ordered_icons = function(ctx)
                    local value = vim.trim(ctx.value)
                    local index = tonumber(value:sub(1, #value - 1))
                    return ('%d.'):format(index > 1 and index or ctx.index)
                end,
                left_pad = 0,
                right_pad = 0,
                highlight = 'RenderMarkdownBullet',
            },
            
            -- Checkbox configuration
            checkbox = {
                enabled = true,
                position = 'inline',
                unchecked = {
                    icon = '󰄱 ',
                    highlight = 'RenderMarkdownUnchecked',
                    scope_highlight = nil,
                },
                checked = {
                    icon = '󰱒 ',
                    highlight = 'RenderMarkdownChecked',
                    scope_highlight = nil,
                },
                custom = {
                    todo = { raw = '[-]', rendered = '󰥔 ', highlight = 'RenderMarkdownTodo' },
                },
            },
            
            -- Quote configuration
            quote = {
                enabled = true,
                icon = '▋',
                repeat_linebreak = false,
                highlight = 'RenderMarkdownQuote',
            },
            
            -- Pipe table configuration
            pipe_table = {
                enabled = true,
                preset = 'none',
                style = 'full',
                cell = 'padded',
                padding = 1,
                border = {
                    '┌', '┬', '┐',
                    '├', '┼', '┤',
                    '└', '┴', '┘',
                    '│', '─',
                },
                alignment_indicator = '━',
                head = 'RenderMarkdownTableHead',
                row = 'RenderMarkdownTableRow',
                filler = 'RenderMarkdownTableFill',
            },
            
            -- Callout configuration (GitHub-style alerts)
            callout = {
                note      = { raw = '[!NOTE]',      rendered = '󰋽 Note',      highlight = 'RenderMarkdownInfo'},
                tip       = { raw = '[!TIP]',       rendered = '󰌶 Tip',       highlight = 'RenderMarkdownSuccess'},
                important = { raw = '[!IMPORTANT]', rendered = '󰅾 Important', highlight = 'RenderMarkdownHint'},
                warning   = { raw = '[!WARNING]',   rendered = '󰀪 Warning',   highlight = 'RenderMarkdownWarn'},
                caution   = { raw = '[!CAUTION]',   rendered = '󰳦 Caution',   highlight = 'RenderMarkdownError'},
                abstract  = { raw = '[!ABSTRACT]',  rendered = '󰨸 Abstract',  highlight = 'RenderMarkdownInfo'},
                summary   = { raw = '[!SUMMARY]',   rendered = '󰨸 Summary',   highlight = 'RenderMarkdownInfo'},
                tldr      = { raw = '[!TLDR]',      rendered = '󰨸 Tldr',      highlight = 'RenderMarkdownInfo'},
                info      = { raw = '[!INFO]',      rendered = '󰋽 Info',      highlight = 'RenderMarkdownInfo'},
                todo      = { raw = '[!TODO]',      rendered = '󰗡 Todo',      highlight = 'RenderMarkdownInfo'},
                hint      = { raw = '[!HINT]',      rendered = '󰌶 Hint',      highlight = 'RenderMarkdownSuccess'},
                success   = { raw = '[!SUCCESS]',   rendered = '󰄬 Success',   highlight = 'RenderMarkdownSuccess'},
                check     = { raw = '[!CHECK]',     rendered = '󰄬 Check',     highlight = 'RenderMarkdownSuccess'},
                done      = { raw = '[!DONE]',      rendered = '󰄬 Done',      highlight = 'RenderMarkdownSuccess'},
                question  = { raw = '[!QUESTION]',  rendered = '󰘥 Question',  highlight = 'RenderMarkdownWarn'},
                help      = { raw = '[!HELP]',      rendered = '󰘥 Help',      highlight = 'RenderMarkdownWarn'},
                faq       = { raw = '[!FAQ]',       rendered = '󰘥 Faq',       highlight = 'RenderMarkdownWarn'},
                attention = { raw = '[!ATTENTION]', rendered = '󰀪 Attention', highlight = 'RenderMarkdownWarn'},
                failure   = { raw = '[!FAILURE]',   rendered = '󰅖 Failure',   highlight = 'RenderMarkdownError'},
                fail      = { raw = '[!FAIL]',      rendered = '󰅖 Fail',      highlight = 'RenderMarkdownError'},
                missing   = { raw = '[!MISSING]',   rendered = '󰅖 Missing',   highlight = 'RenderMarkdownError'},
                danger    = { raw = '[!DANGER]',    rendered = '󱐌 Danger',    highlight = 'RenderMarkdownError'},
                error     = { raw = '[!ERROR]',     rendered = '󱐌 Error',     highlight = 'RenderMarkdownError'},
                bug       = { raw = '[!BUG]',       rendered = '󰨰 Bug',       highlight = 'RenderMarkdownError'},
                example   = { raw = '[!EXAMPLE]',   rendered = '󰉹 Example',   highlight = 'RenderMarkdownHint' },
                quote     = { raw = '[!QUOTE]',     rendered = '󱆨 Quote',     highlight = 'RenderMarkdownQuote'},
                cite      = { raw = '[!CITE]',      rendered = '󱆨 Cite',      highlight = 'RenderMarkdownQuote'},
            },
            
            -- Link configuration
            link = {
                enabled = true,
                image = '󰥶 ',
                email = '󰀓 ',
                hyperlink = '󰌹 ',
                highlight = 'RenderMarkdownLink',
                wiki = {
                    icon = '󱗖 ',
                    highlight = 'RenderMarkdownWikiLink',
                },
                custom = {
                    web = { pattern = '^http', icon = '󰖟 ' },
                    github = { pattern = 'github%.com', icon = '󰊤 ' },
                    gitlab = { pattern = 'gitlab%.com', icon = '󰮠 ' },
                    stackoverflow = { pattern = 'stackoverflow%.com', icon = '󰓌 ' },
                    wikipedia = { pattern = 'wikipedia%.org', icon = '󰖬 ' },
                    youtube = { pattern = 'youtube%.com', icon = '󰗃 ' },
                },
            },
            
            -- Sign column configuration
            sign = {
                enabled = true,
                highlight = 'RenderMarkdownSign',
            },
            
            -- Math configuration (LaTeX)
            latex = {
                enabled = true,
                converter = 'latex2text',
                highlight = 'RenderMarkdownMath',
                top_pad = 0,
                bottom_pad = 0,
            },
            
            -- Win configuration for floating windows
            win = {
                padding = {
                    highlight = 'RenderMarkdownWinSep',
                },
            },
        })
        
        -- Add keymaps for render-markdown
        vim.keymap.set('n', '<leader>mr', '<cmd>RenderMarkdown toggle<CR>', { desc = 'Toggle Render Markdown' })
        vim.keymap.set('n', '<leader>me', '<cmd>RenderMarkdown enable<CR>', { desc = 'Enable Render Markdown' })
        vim.keymap.set('n', '<leader>md', '<cmd>RenderMarkdown disable<CR>', { desc = 'Disable Render Markdown' })
    end,
}
