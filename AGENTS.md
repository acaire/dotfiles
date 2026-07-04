# AGENTS.md

## Repository Overview

Dotfiles managed with [chezmoi](https://www.chezmoi.io/). macOS (darwin) only.

## Conventions

### File Naming
- Config files: `dot_<filename>` (e.g., `dot_vimrc`, `dot_gitconfig`)
- Run scripts: `run_once_<phase>-<description>.sh.tmpl` (always `.tmpl` extension)
- Directories: `dot_<dirname>` for dotdirs (e.g., `dot_hammerspoon` → `~/.hammerspoon`)
- External git repos: managed via `.chezmoiexternal.toml`

### Templating
- Use chezmoi templates (`{{ ... }}`) for OS-specific logic
- Guard darwin-only content with `{{- if eq .chezmoi.os "darwin" -}}`
- All shell scripts are `.tmpl` files

### Structure
```
dot_gitconfig            → ~/.gitconfig
dot_vimrc                → ~/.vimrc
dot_hammerspoon/         → ~/.hammerspoon/
private_Library/         → ~/Library/
code/                    → ~/code/ (external repos)
run_once_*.sh.tmpl       → one-time install scripts
.chezmoiexternal.toml    → external git repo mounts (e.g., llama.cpp)
.chezmoiignore           → files chezmoi should ignore
```

### Packages
Defined in `run_once_before_install-packages-darwin.sh.tmpl` via `brew bundle`.

### Testing
Before pushing, verify changes with:
```bash
chezmoi --source=. diff
```

### Key Tools & Apps
- **Editor**: Vim (minimal config in `dot_vimrc`)
- **Terminal**: Ghostty
- **Window management**: Hammerspoon (`dot_hammerspoon/init.lua`, `hyper.lua`)
- **Browser**: Orion
- **Password manager**: 1Password
- **CLI**: git, jq, ripgrep, tig, yq, cmake
