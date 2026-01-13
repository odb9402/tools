# CLI Tools Collection

개발 환경 세팅을 위한 필수 CLI 도구 모음입니다.

## Quick Start

새로운 개발 환경에서 한 번에 모든 도구를 설치:

```bash
curl -fsSL https://raw.githubusercontent.com/YOUR_USERNAME/tools/main/install.sh | bash
```

또는 개별 설치:

```bash
cd dotfiles
./install_essential.sh  # 필수 도구만
./install_optional.sh   # 선택적 도구 (추천)
```

## Essential Tools (필수 도구)

### Terminal & Shell
- **tmux** - 터미널 멀티플렉서, 세션 관리
- **fish** - 사용자 친화적인 쉘 (자동완성, syntax highlighting)

### Monitoring
- **htop** - 인터랙티브 프로세스 뷰어
- **nvtop** - GPU 모니터링 도구 (NVIDIA, AMD 등)

### Development Tools
- **uv** - 초고속 Python 패키지 매니저 (pip/pip-tools 대체)
- **gh** - GitHub CLI - 이슈, PR 등을 터미널에서 관리
- **lazygit** - Git을 위한 심플한 터미널 UI
- **claude** - Anthropic Claude CLI

### Data Processing
- **jq** - JSON 프로세서
- **yq** - YAML 프로세서 (jq의 YAML 버전)

## Optional Tools (추천 도구)

현대적인 CLI 도구들로 생산성을 크게 향상시킵니다:

### Git Enhancement
- **delta** - Git diff를 아름답게 표시 (syntax highlighting, side-by-side)

### Search & Navigation
- **fd** - `find`의 현대적 대체품 (더 빠르고 직관적)
- **ripgrep (rg)** - `grep`의 현대적 대체품 (초고속 코드 검색)
- **fzf** - 퍼지 파인더 (파일, 히스토리, 프로세스 인터랙티브 검색)
- **zoxide** - 스마트한 `cd` (자주 가는 디렉토리 학습 및 빠른 이동)

## Installation Details

### tmux
터미널 세션을 분리하고 여러 윈도우/패널을 관리할 수 있습니다.
```bash
# Ubuntu/Debian
sudo apt install tmux

# macOS
brew install tmux
```

### fish
강력한 자동완성과 syntax highlighting을 제공하는 쉘입니다.
```bash
# Ubuntu/Debian
sudo apt install fish

# macOS
brew install fish

# 기본 쉘로 설정
chsh -s $(which fish)
```

### htop
시스템 리소스를 실시간으로 모니터링합니다.
```bash
# Ubuntu/Debian
sudo apt install htop

# macOS
brew install htop
```

### nvtop
GPU 사용량을 실시간으로 모니터링합니다.
```bash
# Ubuntu/Debian
sudo apt install nvtop

# macOS
brew install nvtop
```

### uv
Rust로 작성된 초고속 Python 패키지 매니저입니다.
```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
```

### gh (GitHub CLI)
터미널에서 GitHub를 관리합니다.
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
Git을 위한 심플한 터미널 UI입니다.
```bash
# See dotfiles/install_lazygit.sh
```

### claude
Anthropic의 Claude AI CLI 도구입니다.
```bash
# npm을 통한 설치
npm install -g @anthropic-ai/claude-cli

# 또는 공식 설치 스크립트
curl -fsSL https://claude.ai/install.sh | sh
```

### jq
JSON 데이터를 쿼리하고 조작합니다.
```bash
# Ubuntu/Debian
sudo apt install jq

# macOS
brew install jq
```

### yq
YAML 데이터를 쿼리하고 조작합니다.
```bash
# Ubuntu/Debian
sudo wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64
sudo chmod +x /usr/local/bin/yq

# macOS
brew install yq
```

### delta
Git diff를 더 읽기 쉽게 만듭니다.
```bash
# Ubuntu/Debian
wget https://github.com/dandavison/delta/releases/download/0.17.0/git-delta_0.17.0_amd64.deb
sudo dpkg -i git-delta_0.17.0_amd64.deb

# macOS
brew install git-delta

# .gitconfig에 추가
git config --global core.pager delta
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate true
git config --global merge.conflictstyle diff3
git config --global diff.colorMoved default
```

### fd
빠르고 사용자 친화적인 `find` 대체품입니다.
```bash
# Ubuntu/Debian
sudo apt install fd-find

# macOS
brew install fd
```

### ripgrep (rg)
초고속 재귀 검색 도구입니다.
```bash
# Ubuntu/Debian
sudo apt install ripgrep

# macOS
brew install ripgrep
```

### fzf
커맨드라인 퍼지 파인더입니다.
```bash
# Ubuntu/Debian & macOS
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# 또는
# Ubuntu/Debian
sudo apt install fzf

# macOS
brew install fzf
$(brew --prefix)/opt/fzf/install
```

### zoxide
스마트한 디렉토리 네비게이션입니다.
```bash
curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash

# fish 쉘 설정 (~/.config/fish/config.fish에 추가)
zoxide init fish | source
```

## Usage Examples

### fzf로 파일 열기
```bash
vim $(fzf)
```

### zoxide로 빠른 디렉토리 이동
```bash
z tools  # /path/to/tools로 점프
z doc    # /path/to/documents로 점프
```

### ripgrep + fzf 조합
```bash
rg "TODO" | fzf
```

### fd로 파일 찾기
```bash
fd test     # test가 포함된 파일
fd -e py    # .py 확장자 파일만
```

## Configuration

각 도구의 설정 파일 예시는 `dotfiles/` 디렉토리를 참고하세요.

## License

MIT
