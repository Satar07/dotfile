
# User configuration

# custom paths (some placed at /etc/paths and /etc/paths.d/ for global access)

# /usr/local/bin
# /System/Cryptexes/App/usr/bin
# /usr/bin
# /bin
# /usr/sbin
# /sbin
# $HOME/bin
# $HOME/.local/bin
# /usr/local/bin

# export PATH="$HOME/bin:$PATH"                                           # User binaries
# export PATH="$HOME/.local/bin:$PATH"                                    # User binaries
# export PATH="/usr/local/bin:$PATH"                                      # Homebrew
# export PATH="/opt/homebrew/bin:$PATH"                                   # Homebrew
# export PATH="/opt/homebrew/sbin:$PATH"                                  # Homebrew system binaries
# export PATH="/Users/cyril/Library/Python/3.9/bin:$PATH"                 # Python
export PATH="/opt/homebrew/opt/llvm/bin:/opt/homebrew/opt/lld/bin:$PATH"  # llvm
export PATH="/Applications/010 Editor.app/Contents/CmdLine:$PATH"         # 010 Editor
export PATH="/Users/cyril/Library/Android/sdk/build-tools/36.0.0:$PATH"   # aapt
export PATH="/opt/homebrew/opt/libtool/libexec/gnubin:$PATH"              # libtool
export PATH="/opt/homebrew/opt/flex/bin:$PATH"                            # flex
export PATH="/opt/homebrew/opt/bison/bin:$PATH"                           # bison
export PATH="/opt/homebrew/opt/binutils/bin:$PATH"                        # binutils
export PATH="/Users/cyril/bin/flutter/bin:$PATH"                          # flutter
export PATH="$HOME/.pub-cache/bin:$PATH"                                  # dart/flutter pub cache



# Ensure paths are unique
typeset -U PATH

# ==============================================================================


# Custom var

# compilation flags for LLVM and Flex
export LDFLAGS="-L/opt/homebrew/opt/llvm/lib -L/opt/homebrew/opt/flex/lib"
export CPPFLAGS="-I/opt/homebrew/opt/llvm/include -I/opt/homebrew/opt/flex/include"
export CC=$(brew --prefix llvm)/bin/clang
export CXX=$(brew --prefix llvm)/bin/clang++
export CMAKE_PREFIX_PATH="/opt/homebrew/opt/llvm"
export LLDB_DEBUGSERVER_PATH='/opt/homebrew/opt/llvm/bin/lldb-server'
# export ARCHFLAGS="-arch $(uname -m)"


# Android Development Environment Variables
export ANDROID_HOME="/Users/cyril/Library/Android/sdk"
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
export NDK_HOME="/Users/cyril/Library/Android/sdk/ndk/27.0.12077973"
export ANDROID_NDK="/Users/cyril/Library/Android/sdk/ndk/27.0.12077973"

# Go Environment Variables
export GOPROXY="https://goproxy.cn,direct"
export GO111MODULE="on"

# Editor Settings
# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi
# just use VSCode everywhere XD
# export EDITOR="hx"

# IDA Pro Settings
export IDA_PATH='/Applications/IDA Professional 9.2.app/Contents/MacOS'
export IDA_APP='/Applications/IDA Professional 9.2.app/Contents/MacOS/ida'
export IDADIR="/Applications/IDA Professional 9.2.app/Contents/MacOS/"
export IDA_SDK="/Users/cyril/Dev/repo/ida-sdk"

# homebrew
export HOMEBREW_NO_ENV_HINTS=1

# Proxy
# export https_proxy=http://127.0.0.1:7893 http_proxy=http://127.0.0.1:7893 all_proxy=socks5://127.0.0.1:7893

# claude code
export ANTHROPIC_BASE_URL=https://api.deepseek.com/anthropic
export ANTHROPIC_AUTH_TOKEN=''
export API_TIMEOUT_MS=600000
export ANTHROPIC_MODEL=deepseek-chat
export ANTHROPIC_SMALL_FAST_MODEL=deepseek-chat
export CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1

# ==============================================================================

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
alias emu='/Users/cyril/Library/Android/sdk/emulator/emulator'
alias emu-list='/Users/cyril/Library/Android/sdk/emulator/emulator -list-avds'
alias emu-start='/Users/cyril/Library/Android/sdk/emulator/emulator -avd'
alias emu-stop='/Users/cyril/Library/Android/sdk/emulator/emulator -avd @'
alias ida="/Applications/IDA\ Professional\ 9.2.app/Contents/MacOS/ida"
alias cman='man -M /usr/local/share/man/zh_CN'
alias t='tldr'
alias ubuntu_emu='/Users/cyril/qemu_vms/ubuntu_x86_64/launch.sh'
alias pip-sys-install='pip3.12 install --break-system-packages'
alias dns_flush='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
alias p='popd'
alias adbk='adb kill-server'

# Use trash instead of rm
# well.. this may be dangerous if I forget it lol, so just remember to run
# script with /bin/sh
# alias rm='trash -s'


# ==============================================================================

# Custom Script

# Random TLDR Command
function random_tldr() {
    local cmd=$(tldr --list | shuf -n1)
    echo -e "Random Command: \033[1;33m$cmd\033[0m"
    # 尝试通过 glow 渲染内容 (需要 tldr 输出纯文本，glow 负责上色)
    tldr --color always "$cmd" | sed '/^\s*$/d'
}

# random_tldr

# Docker Rabbit Runner
run_in_rabbit() {
    docker run -it --rm \
        -v "$(pwd):/workspace" \
        -w /workspace \
        rabbit \
        "$@"
}

# Pwn Docker Environment
pwnenv() {
    ctf_name=${1:-$(basename "$PWD")}  # 使用当前目录名作为默认名称
    docker run -it --rm \
        -v "$(pwd):/ctf/work" \
        -w /ctf/work \
        --cap-add=SYS_PTRACE \
        --add-host=host.docker.internal:host-gateway\
        skysider/pwndocker \
        "$@"
}

# Pwn Docker Environment with Port Forwarding
pwnenv_port() {
  ctf_name=${1:-$(basename "$PWD")}  # 使用当前目录名作为默认名称
  docker run -it --rm \
    -p 23946:23946 \
    -v "$(pwd):/ctf/work" \
    -w /ctf/work \
    --cap-add=SYS_PTRACE \
    skysider/pwndocker \
    "$@"
}

# Run Command in Background (with alias expansion)
rbg() {
  if [ $# -eq 0 ]; then
    echo "Usage: rbg <command> [args...]"
    return 1
  fi

  # 保存原始命令用于显示
  local cmd="$1"
  shift

  # 展开别名
  local expanded_cmd=$(alias "$cmd" 2>/dev/null | sed "s/^.*=//;s/^[\'\"]\(.*\)[\'\"]/\1/")

  if [ -z "$expanded_cmd" ]; then
    # 如果不是别名，直接使用原始命令
    nohup "$cmd" "$@" > /dev/null 2>&1 &
  else
    # 如果是别名，使用展开后的命令
    # 处理可能包含的引号和转义字符
    eval "nohup $expanded_cmd $* > /dev/null 2>&1 &"
  fi

  echo "Started process with PID $!"
}


#  Zed & VSCode C/C++ Project Initializer Functions
#  - Place these functions in your ~/.zshrc file
#  - After adding, restart your shell or run `source ~/.zshrc`

# some CMakeLists.txt snippets for reference
# set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
# target_link_directories(\${PROJECT_NAME} PUBLIC /opt/homebrew/opt/llvm/lib/c++)

# _init_project <project_name> <language> <main_file> <main_content> <editor>
_init_project() {
    local PROJECT_NAME="$1"
    local LANGUAGE="$2"
    local MAIN_FILE="$3"
    local MAIN_CONTENT="$4"
    local EDITOR="$5"

    echo "Initializing $EDITOR $LANGUAGE project: $PROJECT_NAME in current directory..."

    # 安全检查：如果关键文件/目录已存在，则中止操作，防止覆盖
    if [ -f "CMakeLists.txt" ] || [ -d "src" ]; then
        echo "[x] Error: 'CMakeLists.txt' or 'src' directory already exists. Initialization aborted."
        return 1
    fi

    # --- 1. 创建通用文件和目录 ---
    mkdir -p "src"
    echo "  -> Created directory: src/"

    cat <<EOF > "./.gitignore"
# Build artifacts
build/
compile_commands.json

# IDE settings
.vscode/
.zed/

# CMake files
CMakeCache.txt
CMakeFiles/
cmake_install.cmake
Makefile
EOF
    echo "  -> Created .gitignore"

    cat <<EOF > "./CMakeLists.txt"
# Minimum CMake version required
cmake_minimum_required(VERSION 3.10)

# Project definition (name and language)
project($PROJECT_NAME $LANGUAGE)

# Enable 'compile_commands.json' for IDEs' LSP (clangd)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Set C++ standard if the project is C++
if(CMAKE_CXX_COMPILER)
    set(CMAKE_CXX_STANDARD 17)
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
endif()

# Automatically find all source files in the src directory
file(GLOB_RECURSE SOURCES "src/*.c" "src/*.cpp")

# Add the executable target
add_executable(\${PROJECT_NAME} \${SOURCES})

# Add modern compile options to our target
target_compile_options(\${PROJECT_NAME} PRIVATE -g -Wall -Wextra -Wpedantic)

# Homebrew deploys libc++ along with the llvm package. We must point to it
target_link_directories(\${PROJECT_NAME} PUBLIC /opt/homebrew/opt/llvm/lib/c++)

# Recommended: Set a consistent output directory for binaries
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY \${CMAKE_BINARY_DIR})
EOF
    echo "  -> Created CMakeLists.txt"

    echo "$MAIN_CONTENT" > "./src/$MAIN_FILE"
    echo "  -> Created src/$MAIN_FILE"


    # --- 2. 根据编辑器生成特定配置文件 ---
    # Replaced inline editor-specific block with a helper call
    _place_editor_tasks_and_debug "$EDITOR" "$PROJECT_NAME"

    echo ""
    echo "[+] Project '$PROJECT_NAME' for $EDITOR initialized successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Open with your editor (e.g., 'code .' or 'zed .')"
    echo "2. Run the 'CMake: Configure' task in the editor"
    echo "3. Happy coding!"
}

# helper to place tasks/launch/debug files for different editors
_place_editor_tasks_and_debug() {
    local EDITOR="$1"
    local PROJECT_NAME="$2"

    if [ "$EDITOR" = "zed" ]; then
        mkdir -p ".zed"
        # 生成 Zed Tasks
        cat <<EOF > "./.zed/tasks.json"
[
    {
        "label": "CMake: Configure",
        "command": "cmake",
        "args": ["-S", ".", "-B", "build"],
        "cwd": "\${ZED_WORKTREE_ROOT}"
    },
    {
        "label": "CMake: Build",
        "command": "cmake",
        "args": ["--build", "build", "-j8"],
        "cwd": "\${ZED_WORKTREE_ROOT}"
    },
    {
        "label": "Meson: setup build",
        "command": "meson",
        "args": ["setup", "build"],
        "cwd": "\${ZED_WORKTREE_ROOT}"
    },
    {
        "label": "Meson: compile",
        "command": "meson",
        "args": ["compile", "-C", "build"],
        "cwd": "\${ZED_WORKTREE_ROOT}"
    },
    {
        "label": "Run",
        "command": "./${PROJECT_NAME}",
        "args": ["arg1", "arg2"],
        "cwd": "\${ZED_WORKTREE_ROOT}/build"
    },
    {
        "label": "Clean",
        "command": "rm",
        "args": ["-rf", "build"],
        "cwd": "\${ZED_WORKTREE_ROOT}"
    }
]
EOF
        # 生成 Zed Debug Config
        cat <<EOF > "./.zed/debug.json"
[
  {
    "label": "Debug with CodeLLDB",
    "build": {
      "command": "cmake",
      "args": ["--build", "build"],
      "cwd": "\${ZED_WORKTREE_ROOT}"
    },
    "program": "\${ZED_WORKTREE_ROOT}/build/${PROJECT_NAME}",
    "request": "launch",
    "adapter": "CodeLLDB",
    "args": ["input_argument_for_debug"]
  }
]
EOF
        echo "  -> Created .zed/ directory with tasks and debug configs"

    elif [ "$EDITOR" = "vscode" ]; then
        mkdir -p ".vscode"
        # 生成 VSCode Tasks
        cat <<EOF > "./.vscode/tasks.json"
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "CMake: Configure",
            "type": "shell",
            "command": "cmake",
            "args": [
                "-S",
                ".",
                "-B",
                "build"
            ]
        },
        {
            "label": "CMake: Build",
            "type": "shell",
            "command": "cmake",
            "args": [
                "--build",
                "build",
                "-j8"
            ],
            "group": {
                "kind": "build",
            }
        },
        {
            "label": "Meson: setup build",
            "type": "shell",
            "command": "meson",
            "args": [
                "setup",
                "build"
            ],
            "group": {
                "kind": "build",
            }
        },
        {
            "label": "Meson: compile",
            "type": "shell",
            "command": "meson",
            "args": [
                "compile",
                "-C",
                "build"
            ],
            "group": {
                "kind": "build",
            }
        },
        {
            "label": "Run",
            "type": "shell",
            "command": "./${PROJECT_NAME}",
            "args": [
                "arg1",
                "arg2"
            ],
            "options": {
                "cwd": "\${workspaceFolder}/build"
            }
        },
        {
            "label": "Clean",
            "type": "shell",
            "command": "rm",
            "args": [
                "-rf",
                "build"
            ]
        }
    ]
}
EOF
        # 生成 VSCode Debug/Launch Config
        cat <<EOF > "./.vscode/launch.json"
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "(lldb) Debug",
            "type": "cppdbg",
            "request": "launch",
            "program": "\${workspaceFolder}/build/${PROJECT_NAME}",
            "args": ["input_argument_for_debug"],
            "stopAtEntry": false,
            "cwd": "\${workspaceFolder}",
            "environment": [],
            "externalConsole": false,
            "MIMode": "lldb",
            "preLaunchTask": "CMake: Build"
        }
    ]
}
EOF
        echo "  -> Created .vscode/ directory with tasks and launch configs"

    else
        echo "Unknown editor: $EDITOR. Supported: zed, vscode" >&2
        return 1
    fi
}


# Usage: zed-init-c | zed-init-cpp | code-init-c | code-init-cpp
# Initializes a C or C++ project in the current directory for Zed or VSCode.
zed-init-c() {
    local PROJECT_NAME=$(basename "$(pwd)")
    local MAIN_CONTENT=$(cat <<'EOF'
#include <stdio.h>

int main(int argc, char *argv[]) {
    printf("Hello, C World from %s!\\n", argv[0]);
    if (argc > 1) {
        printf("Received argument: %s\\n", argv[1]);
    }
    return 0;
}
EOF
)
    _init_project "$PROJECT_NAME" "C" "main.c" "$MAIN_CONTENT" "zed"
}

zed-init-cpp() {
    local PROJECT_NAME=$(basename "$(pwd)")
    local MAIN_CONTENT=$(cat <<'EOF'
#include <iostream>

int main(int argc, char* argv[]) {
    std::cout << "Hello, C++ World from " << argv[0] << "!" << std::endl;
    if (argc > 1) {
        std::cout << "Received argument: " << argv[1] << std::endl;
    }
    return 0;
}

EOF
)
    _init_project "$PROJECT_NAME" "CXX" "main.cpp" "$MAIN_CONTENT" "zed"
}

code-init-c() {
    local PROJECT_NAME=$(basename "$(pwd)")
    local MAIN_CONTENT=$(cat <<'EOF'
#include <stdio.h>

int main(int argc, char *argv[]) {
    printf("Hello, C World from %s!\\n", argv[0]);
    if (argc > 1) {
        printf("Received argument: %s\\n", argv[1]);
    }
    return 0;
}
EOF
)
    _init_project "$PROJECT_NAME" "C" "main.c" "$MAIN_CONTENT" "vscode"
}

code-init-cpp() {
    local PROJECT_NAME=$(basename "$(pwd)")
    local MAIN_CONTENT=$(cat <<'EOF'
#include <iostream>

int main(int argc, char* argv[]) {
    std::cout << "Hello, C++ World from " << argv[0] << "!" << std::endl;
    if (argc > 1) {
        std::cout << "Received argument: " << argv[1] << std::endl;
    }
    return 0;
}

EOF
)
    _init_project "$PROJECT_NAME" "CXX" "main.cpp" "$MAIN_CONTENT" "vscode"
}

# Usage: zed-init-tasks | code-init-tasks
# Places only the tasks and debug/launch configurations for Zed or VSCode in the current directory.
zed-init-tasks() {
    local PROJECT_NAME=${1:-$(basename "$(pwd)")}
    _place_editor_tasks_and_debug "zed" "$PROJECT_NAME"
}

code-init-tasks() {
    local PROJECT_NAME=${1:-$(basename "$(pwd)")}
    _place_editor_tasks_and_debug "vscode" "$PROJECT_NAME"
}

# Usage: git_untrack <path> [<path2> ...]
# Stops tracking one or more files/directories and suggests the string(s) to add to .gitignore.
git_untrack() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: git_untrack <path> [<path2> ...]" >&2
        return 1
    fi

    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        echo "Error: Not a git repository." >&2
        return 1
    fi

    local item clean_path
    local failed=0
    local -a entries_to_ignore=()

    for item in "$@"; do
        clean_path="${item#./}"

        if [[ -d "$item" ]] && [[ "$clean_path" != */ ]]; then
            clean_path="${clean_path}/"
        fi

        if git rm -r --cached --quiet --ignore-unmatch "$item"; then
            echo " [OK] Untracked: $item"
            entries_to_ignore+=("$clean_path")
        else
            echo " [!!] Failed:    $item" >&2
            failed=1
        fi
    done

    if [[ ${#entries_to_ignore[@]} -gt 0 ]]; then
        echo
        echo "Success! The files have been removed from the index."
        echo "Add the following lines to your .gitignore to ignore them permanently:"
        echo "----------------------------------------------------------------------"
        for entry in "${entries_to_ignore[@]}"; do
            echo "$entry"
        done
        echo "----------------------------------------------------------------------"
    fi

    return $failed
}

# ==============================================================================


# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Add completions to fpath
fpath=(~/.zsh/completions $fpath)

# To enable command-not-found
# Add the following lines to ~/.zshrc
HOMEBREW_COMMAND_NOT_FOUND_HANDLER="$(brew --repository)/Library/Homebrew/command-not-found/handler.sh"
if [ -f "$HOMEBREW_COMMAND_NOT_FOUND_HANDLER" ]; then
  source "$HOMEBREW_COMMAND_NOT_FOUND_HANDLER";
fi

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# trust me, you don't want this :(
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git z extract vscode sudo)

source $ZSH/oh-my-zsh.sh
# Load zsh-syntax-highlighting and zsh-autosuggestions
# if this failed, try installing via Homebrew:
# brew install zsh-syntax-highlighting zsh-autosuggestions
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# uv virtual env
source $(which uv-virtualenvwrapper.sh)


# ===============================================================================

# Auto generate configurations

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/cyril/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

# Flamegraph
fpath=(~/.zsh/completions $fpath)
autoload -Uz compinit
compinit

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# navi
# use ^g to trigger
eval "$(navi widget zsh)"

# Added by Antigravity
export PATH="/Users/cyril/.antigravity/antigravity/bin:$PATH"

source /Users/cyril/.config/broot/launcher/bash/br
