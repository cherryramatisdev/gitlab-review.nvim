> [!CAUTION]
> This plugin is pre-alpha and it was just on my personal config, so it's in working progress to port into something sufficient generic.

# gitlab-review.nvim

This [NeoVim](https://github.com/neovim/neovim) plugin is designed to offer a minimal yet practical way to manage gitlab merge request review process. The main philosophy that guides this plugin is:

- Provide a clean API that can be attached with any other diffing plugin (or no plugin at all)
- Don't get in your way too much, mount your own workflow
- Straightforward and minimal API integration, not complex UIs
- No external dependencies

## Features

1. Creating a new regular comment for the current line or visual selection.
2. Creating a new suggestion comment for the current line or visual selection.
3. List the unresolved threads/discussions
    1. Reply to any comment in the hierarchy
    2. Resolve a thread/discussion from the root comment.

## Requirements

- Minimum Nvim 0.12+ version
- Treesitter with `diff` parser available
- [`glab` CLI](https://gitlab.com/gitlab-org/cli) — **temporary**: future versions will integrate directly with the GitLab API, removing the need for `glab`

## Installation

> Optionally, you could use the [diffs.nvim](https://github.com/barrettruth/diffs.nvim) for a better experience with the `:Greview` command.

With `vim.pack` (or feel free to use your favorite package manager)

```lua
vim.pack.add({
    "https://github.com/cherryramatisdev/gitlab-review.nvim"
})

if not pcall(require, 'gitlab-review') then
    return
end

require'gitlab-review'.setup {
    default_keybindings = true
}
```


## Available API

```lua
require'gitlab-review.actions'.comment()
require'gitlab-review.actions'.multiline_comment()
require'gitlab-review.actions'.suggestion()
require'gitlab-review.actions'.multiline_suggestion()
require'gitlab-review.actions'.list_discussions()
```


## Future plan

- [ ] Improve API to be more modular (export individual actions to resolve a discussion and reply a comment respectively)
- [ ] Support more actions for MRs
    - [ ] Approving a MR
    - [ ] Merging/Rebasing a MR
    - [ ] Visualize CI outputs
    - [ ] Open MR on browser
- [ ] Support github (a big maybe, would be necessary to rename the plugin)
