# CLI Tools Collection

Essential CLI tools for setting up development environments.

## Quick Start

Install all tools on a new development environment with one command:

```bash
curl -fsSL https://raw.githubusercontent.com/odb9402/tools/main/install.sh | bash
```

Or install individually:

```bash
cd dotfiles
./install_essential.sh  # Essential tools only
./install_optional.sh   # Optional tools (recommended)
```

## Essential Tools

### Terminal & Shell
- **tmux** - Terminal multiplexer for session management
- **fish** - User-friendly shell with autocompletion and syntax highlighting

### Monitoring
- **htop** - Interactive process viewer
- **nvtop** - GPU monitoring tool (NVIDIA, AMD, etc.)

### Development Tools
- **uv** - Ultra-fast Python package manager (pip/pip-tools replacement)
- **gh** - GitHub CLI for managing issues and PRs from terminal
- **lazygit** - Simple terminal UI for Git
- **claude** - Anthropic Claude CLI

### Data Processing
- **jq** - JSON processor
- **yq** - YAML processor (YAML version of jq)

## Optional Tools

Modern CLI tools that significantly boost productivity:

### Git Enhancement
- **delta** - Beautiful git diffs with syntax highlighting and side-by-side view

### Search & Navigation
- **fd** - Modern replacement for `find` (faster and more intuitive)
- **ripgrep (rg)** - Modern replacement for `grep` (blazing fast code search)
- **fzf** - Fuzzy finder for interactive file, history, and process search
- **zoxide** - Smart `cd` that learns your most-used directories

## Installation Details

### tmux
Terminal session management with multiple windows and panes.
```bash
# Ubuntu/Debian
sudo apt install tmux

# macOS
brew install tmux
```

### fish
Powerful shell with great autocompletion and syntax highlighting.
```bash
# Ubuntu/Debian
sudo apt install fish

# macOS
brew install fish

# Set as default shell
chsh -s $(which fish)
```

### htop
Real-time system resource monitoring.
```bash
# Ubuntu/Debian
sudo apt install htop

# macOS
brew install htop
```

### nvtop
Real-time GPU usage monitoring.
```bash
# Ubuntu/Debian
sudo apt install nvtop

# macOS
brew install nvtop
```

### uv
Ultra-fast Python package manager written in Rust.
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### gh (GitHub CLI)
Manage GitHub from your terminal.
```bash
# Ubuntu/Debian
(type -p wget >/dev/null || (sudo apt update && sudo apt-get install wget -y)) \
&& sudo mkdir -p -m 755 /etc/apt/keyrings \
&& wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
&& sudo apt update \
&& sudo apt install gh -y

# macOS
brew install gh
```

### lazygit
Simple terminal UI for Git.
```bash
# See dotfiles/install_lazygit.sh
```

### claude
Anthropic's Claude AI CLI tool.
```bash
# Install via npm
npm install -g @anthropic-ai/claude-cli

# Or use official install script
curl -fsSL https://claude.ai/install.sh | sh
```

### jq
Query and manipulate JSON data.
```bash
# Ubuntu/Debian
sudo apt install jq

# macOS
brew install jq
```

### yq
Query and manipulate YAML data.
```bash
# Ubuntu/Debian
sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
sudo chmod +x /usr/local/bin/yq

# macOS
brew install yq
```

### delta
Makes git diffs more readable and beautiful.
```bash
# Ubuntu/Debian
wget https://github.com/dandavison/delta/releases/download/0.17.0/git-delta_0.17.0_amd64.deb
sudo dpkg -i git-delta_0.17.0_amd64.deb

# macOS
brew install git-delta

# Configure git to use delta
git config --global core.pager delta
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate true
git config --global merge.conflictstyle diff3
git config --global diff.colorMoved default
```

### fd
Fast and user-friendly alternative to `find`.
```bash
# Ubuntu/Debian
sudo apt install fd-find

# macOS
brew install fd
```

### ripgrep (rg)
Blazing fast recursive search tool.
```bash
# Ubuntu/Debian
sudo apt install ripgrep

# macOS
brew install ripgrep
```

### fzf
Command-line fuzzy finder.
```bash
# Ubuntu/Debian & macOS
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# Or via package manager
# Ubuntu/Debian
sudo apt install fzf

# macOS
brew install fzf
$(brew --prefix)/opt/fzf/install
```

### zoxide
Smart directory navigation that learns your habits.
```bash
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

# Add to fish config (~/.config/fish/config.fish)
zoxide init fish | source
```

## Usage Examples

### Open files with fzf
```bash
vim $(fzf)
```

### Quick directory navigation with zoxide
```bash
z tools  # Jump to /path/to/tools
z doc    # Jump to /path/to/documents
```

### Combine ripgrep with fzf
```bash
rg "TODO" | fzf
```

### Find files with fd
```bash
fd test     # Files containing "test"
fd -e py    # Only .py files
```

## Configuration

See the `dotfiles/` directory for configuration file examples.

## License

MIT
