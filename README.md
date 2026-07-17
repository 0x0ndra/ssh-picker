# ssh-picker

An interactive SSH server picker for Zsh, powered by [fzf](https://github.com/junegunn/fzf).

Type `ssh` with no arguments to open a fuzzy-searchable list of your servers. Servers are read directly from `~/.ssh/config` — no separate config file needed.

![demo](https://raw.githubusercontent.com/0x0ndra/ssh-picker/main/demo.gif)

## Features

- Fuzzy search across all your SSH hosts
- Displays the IP / hostname next to each entry
- Add, delete, and edit servers without leaving the terminal
- Copy the full `ssh user@host` command to clipboard

## Keybindings

| Key | Action |
|-----|--------|
| `enter` | Connect to selected server |
| `ctrl-a` | Add a new server (prompts for name, IP, user) |
| `ctrl-d` | Delete selected server |
| `ctrl-e` | Edit selected server in `$EDITOR` |
| `ctrl-y` | Copy `ssh user@ip` to clipboard |
| `esc` | Close picker |

## Requirements

- [fzf](https://github.com/junegunn/fzf) — `brew install fzf`
- macOS (uses `pbcopy` for clipboard — on Linux replace with `xclip` or `xsel`)

## Installation

Add the following line to your `~/.zshrc`:

```zsh
source /path/to/ssh-picker.zsh
```

Or paste the contents of `ssh-picker.zsh` directly into your `~/.zshrc`.

Then reload your shell:

```zsh
exec zsh
```

## How it works

Servers are stored in `~/.ssh/config` in the standard format:

```
Host my-server
  HostName 1.2.3.4
  User john
```

The picker reads this file on every open, so any manual edits are reflected immediately.

## License

[MIT](LICENSE)
