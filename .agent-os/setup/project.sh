#!/bin/bash

# Agent OS Project Installation Script
# This script installs Agent OS in a project directory

set -e  # Exit on error

# Initialize flags
NO_BASE=false
OVERWRITE_INSTRUCTIONS=false
OVERWRITE_STANDARDS=false
CLAUDE_CODE=false
CURSOR=false
CODEX=false
PROJECT_TYPE=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --no-base)
            NO_BASE=true
            shift
            ;;
        --overwrite-instructions)
            OVERWRITE_INSTRUCTIONS=true
            shift
            ;;
        --overwrite-standards)
            OVERWRITE_STANDARDS=true
            shift
            ;;
        --claude-code|--claude|--claude_code)
            CLAUDE_CODE=true
            shift
            ;;
        --cursor|--cursor-cli)
            CURSOR=true
            shift
            ;;
        --codex|--openai-codex)
            CODEX=true
            shift
            ;;
        --project-type=*)
            PROJECT_TYPE="${1#*=}"
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --no-base                   Install from GitHub (not from a base Agent OSinstallation on your system)"
            echo "  --overwrite-instructions    Overwrite existing instruction files"
            echo "  --overwrite-standards       Overwrite existing standards files"
            echo "  --claude-code               Add Claude Code support"
            echo "  --cursor                    Add Cursor support"
            echo "  --codex                     Add OpenAI Codex support"
            echo "  --project-type=TYPE         Use specific project type for installation"
            echo "  -h, --help                  Show this help message"
            echo ""
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

echo ""
echo "🚀 Agent OS Project Installation"
echo "================================"
echo ""

# Get project directory info
CURRENT_DIR=$(pwd)
PROJECT_NAME=$(basename "$CURRENT_DIR")
INSTALL_DIR="./.agent-os"

echo "📍 Installing Agent OS to this project's root directory ($PROJECT_NAME)"
echo ""

# Determine if running from base installation or GitHub
if [ "$NO_BASE" = true ]; then
    IS_FROM_BASE=false
    echo "📦 Installing directly from GitHub (no base installation)"
    # Set BASE_URL for GitHub downloads
    BASE_URL="https://raw.githubusercontent.com/AssetOverflow/agent-os/main"
    # Download and source functions when running from GitHub
    TEMP_FUNCTIONS="/tmp/agent-os-functions-$$.sh"
    curl -sSL "${BASE_URL}/setup/functions.sh" -o "$TEMP_FUNCTIONS"
    source "$TEMP_FUNCTIONS"
    rm "$TEMP_FUNCTIONS"
else
    IS_FROM_BASE=true
    # Get the base Agent OS directory
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
    BASE_AGENT_OS="$(dirname "$SCRIPT_DIR")"
    echo "✓ Using Agent OS base installation at $BASE_AGENT_OS"
    # Source shared functions from base installation
    source "$SCRIPT_DIR/functions.sh"
fi

echo ""
echo "📁 Creating project directories..."
echo ""
mkdir -p "$INSTALL_DIR"

# Configure tools and project type based on installation type
if [ "$IS_FROM_BASE" = true ]; then
    # Auto-enable tools based on base config if no flags provided
    if [ "$CLAUDE_CODE" = false ]; then
        # Check if claude_code is enabled in base config
        if grep -q "claude_code:" "$BASE_AGENT_OS/config.yml" && \
           grep -A1 "claude_code:" "$BASE_AGENT_OS/config.yml" | grep -q "enabled: true"; then
            CLAUDE_CODE=true
            echo "  ✓ Auto-enabling Claude Code support (from Agent OS config)"
        fi
    fi

    if [ "$CURSOR" = false ]; then
        # Check if cursor is enabled in base config
        if grep -q "cursor:" "$BASE_AGENT_OS/config.yml" && \
           grep -A1 "cursor:" "$BASE_AGENT_OS/config.yml" | grep -q "enabled: true"; then
            CURSOR=true
            echo "  ✓ Auto-enabling Cursor support (from Agent OS config)"
        fi
    fi

    # Read project type from config or use flag
    if [ -z "$PROJECT_TYPE" ] && [ -f "$BASE_AGENT_OS/config.yml" ]; then
        # Try to read default_project_type from config
        PROJECT_TYPE=$(grep "^default_project_type:" "$BASE_AGENT_OS/config.yml" | cut -d' ' -f2 | tr -d ' ')
        if [ -z "$PROJECT_TYPE" ]; then
            PROJECT_TYPE="default"
        fi
    elif [ -z "$PROJECT_TYPE" ]; then
        PROJECT_TYPE="default"
    fi

    echo ""
    echo "📦 Using project type: $PROJECT_TYPE"

    # Determine source paths based on project type
    INSTRUCTIONS_SOURCE=""
    STANDARDS_SOURCE=""

    if [ "$PROJECT_TYPE" = "default" ]; then
        INSTRUCTIONS_SOURCE="$BASE_AGENT_OS/instructions"
        STANDARDS_SOURCE="$BASE_AGENT_OS/standards"
    else
        # Look up project type in config
        if grep -q "^  $PROJECT_TYPE:" "$BASE_AGENT_OS/config.yml"; then
            # Extract paths for this project type
            INSTRUCTIONS_PATH=$(awk "/^  $PROJECT_TYPE:/{f=1} f&&/instructions:/{print \$2; exit}" "$BASE_AGENT_OS/config.yml")
            STANDARDS_PATH=$(awk "/^  $PROJECT_TYPE:/{f=1} f&&/standards:/{print \$2; exit}" "$BASE_AGENT_OS/config.yml")

            # Expand tilde in paths
            INSTRUCTIONS_SOURCE=$(eval echo "$INSTRUCTIONS_PATH")
            STANDARDS_SOURCE=$(eval echo "$STANDARDS_PATH")

            # Check if paths exist
            if [ ! -d "$INSTRUCTIONS_SOURCE" ] || [ ! -d "$STANDARDS_SOURCE" ]; then
                echo "  ⚠️  Project type '$PROJECT_TYPE' paths not found, falling back to default instructions and standards"
                INSTRUCTIONS_SOURCE="$BASE_AGENT_OS/instructions"
                STANDARDS_SOURCE="$BASE_AGENT_OS/standards"
            fi
        else
            echo "  ⚠️  Project type '$PROJECT_TYPE' not found in config, using default instructions and standards"
            INSTRUCTIONS_SOURCE="$BASE_AGENT_OS/instructions"
            STANDARDS_SOURCE="$BASE_AGENT_OS/standards"
        fi
    fi

    # Copy instructions and standards from determined sources
    echo ""
    echo "📥 Installing instruction files to $INSTALL_DIR/instructions/"
    copy_directory "$INSTRUCTIONS_SOURCE" "$INSTALL_DIR/instructions" "$OVERWRITE_INSTRUCTIONS"

    echo ""
    echo "📥 Installing standards files to $INSTALL_DIR/standards/"
    copy_directory "$STANDARDS_SOURCE" "$INSTALL_DIR/standards" "$OVERWRITE_STANDARDS"
else
    # Running directly from GitHub - download from GitHub
    if [ -z "$PROJECT_TYPE" ]; then
        PROJECT_TYPE="default"
    fi

    echo "📦 Using project type: $PROJECT_TYPE (default when installing from GitHub)"

    # Install instructions and standards from GitHub (no commands folder needed)
    install_from_github "$INSTALL_DIR" "$OVERWRITE_INSTRUCTIONS" "$OVERWRITE_STANDARDS" false
fi

# Handle Claude Code installation for project
if [ "$CLAUDE_CODE" = true ]; then
    echo ""
    echo "📥 Installing Claude Code support..."
    mkdir -p "./.claude/commands"
    mkdir -p "./.claude/agents"

    if [ "$IS_FROM_BASE" = true ]; then
        # Copy from base installation
        echo "  📂 Commands:"
        for cmd in plan-product create-spec create-tasks execute-tasks analyze-product; do
            if [ -f "$BASE_AGENT_OS/commands/${cmd}.md" ]; then
                copy_file "$BASE_AGENT_OS/commands/${cmd}.md" "./.claude/commands/${cmd}.md" "false" "commands/${cmd}.md"
            else
                echo "  ⚠️  Warning: ${cmd}.md not found in base installation"
            fi
        done

        echo ""
        echo "  📂 Agents:"
        for agent in context-fetcher date-checker file-creator git-workflow project-manager test-runner; do
            if [ -f "$BASE_AGENT_OS/claude-code/agents/${agent}.md" ]; then
                copy_file "$BASE_AGENT_OS/claude-code/agents/${agent}.md" "./.claude/agents/${agent}.md" "false" "agents/${agent}.md"
            else
                echo "  ⚠️  Warning: ${agent}.md not found in base installation"
            fi
        done
    else
        # Download from GitHub when using --no-base
        echo "  Downloading Claude Code files from GitHub..."
        echo ""
        echo "  📂 Commands:"
        for cmd in plan-product create-spec create-tasks execute-tasks analyze-product; do
            download_file "${BASE_URL}/commands/${cmd}.md" \
                "./.claude/commands/${cmd}.md" \
                "false" \
                "commands/${cmd}.md"
        done

        echo ""
        echo "  📂 Agents:"
        for agent in context-fetcher date-checker file-creator git-workflow project-manager test-runner; do
            download_file "${BASE_URL}/claude-code/agents/${agent}.md" \
                "./.claude/agents/${agent}.md" \
                "false" \
                "agents/${agent}.md"
        done
    fi
fi

# Handle Cursor installation for project
if [ "$CURSOR" = true ]; then
    echo ""
    echo "📥 Installing Cursor support..."
    mkdir -p "./.cursor/rules"

    echo "  📂 Rules:"

    if [ "$IS_FROM_BASE" = true ]; then
        # Convert commands from base installation to Cursor rules
        for cmd in plan-product create-spec create-tasks execute-tasks analyze-product; do
            if [ -f "$BASE_AGENT_OS/commands/${cmd}.md" ]; then
                convert_to_cursor_rule "$BASE_AGENT_OS/commands/${cmd}.md" "./.cursor/rules/${cmd}.mdc"
            else
                echo "  ⚠️  Warning: ${cmd}.md not found in base installation"
            fi
        done
    else
        # Download from GitHub and convert when using --no-base
        echo "  Downloading and converting from GitHub..."
        for cmd in plan-product create-spec create-tasks execute-tasks analyze-product; do
            TEMP_FILE="/tmp/${cmd}.md"
            curl -s -o "$TEMP_FILE" "${BASE_URL}/commands/${cmd}.md"
            if [ -f "$TEMP_FILE" ]; then
                convert_to_cursor_rule "$TEMP_FILE" "./.cursor/rules/${cmd}.mdc"
                rm "$TEMP_FILE"
            fi
        done
    fi
fi

# Handle Codex installation for project
if [ "$CODEX" = true ]; then
    echo ""
    echo "📥 Installing OpenAI Codex support..."
    mkdir -p "./.agent-os/codex"

    if [ "$IS_FROM_BASE" = true ]; then
        # Copy Codex files from base installation
        echo "  📂 Copying Codex integration files from base installation..."
        if [ -d "$BASE_AGENT_OS/codex" ]; then
            cp -r "$BASE_AGENT_OS/codex/"* "./.agent-os/codex/"
            echo "  ✓ Codex files copied to project"
        else
            echo "  ⚠️  Warning: Codex files not found in base installation"
            echo "  💡 Run base installation with --codex flag first"
        fi
        
        # Copy Codex integration documentation
        if [ -f "$BASE_AGENT_OS/CODEX_INTEGRATION.md" ]; then
            copy_file "$BASE_AGENT_OS/CODEX_INTEGRATION.md" "./CODEX_INTEGRATION.md" "false" "CODEX_INTEGRATION.md"
        fi
    else
        # Download Codex files from GitHub when using --no-base
        echo "  📂 Downloading Codex integration files from GitHub..."
        
        # Create directory structure
        mkdir -p "./.agent-os/codex/config"
        mkdir -p "./.agent-os/codex/agents"
        mkdir -p "./.agent-os/codex/adapters/instructions"
        mkdir -p "./.agent-os/codex/tools"
        mkdir -p "./.agent-os/codex/setup"
        
        # Download Codex files
        download_file "${BASE_URL}/codex/config/codex-config.toml" \
            "./.agent-os/codex/config/codex-config.toml" \
            "false" \
            "codex/config/codex-config.toml"
            
        download_file "${BASE_URL}/codex/agents/task-executor.md" \
            "./.agent-os/codex/agents/task-executor.md" \
            "false" \
            "codex/agents/task-executor.md"
            
        download_file "${BASE_URL}/codex/adapters/instructions/execute-task-codex.md" \
            "./.agent-os/codex/adapters/instructions/execute-task-codex.md" \
            "false" \
            "codex/adapters/instructions/execute-task-codex.md"
            
        download_file "${BASE_URL}/codex/adapters/workflow-adapter.md" \
            "./.agent-os/codex/adapters/workflow-adapter.md" \
            "false" \
            "codex/adapters/workflow-adapter.md"
            
        download_file "${BASE_URL}/codex/tools/rube-mcp-adapter.js" \
            "./.agent-os/codex/tools/rube-mcp-adapter.js" \
            "false" \
            "codex/tools/rube-mcp-adapter.js"
        chmod +x "./.agent-os/codex/tools/rube-mcp-adapter.js"
        
        download_file "${BASE_URL}/codex/setup/install-codex.md" \
            "./.agent-os/codex/setup/install-codex.md" \
            "false" \
            "codex/setup/install-codex.md"
            
        download_file "${BASE_URL}/CODEX_INTEGRATION.md" \
            "./CODEX_INTEGRATION.md" \
            "false" \
            "CODEX_INTEGRATION.md"
    fi
    
    # Copy the Codex configuration to project root for easy access
    if [ -f "./.agent-os/codex/config/codex-config.toml" ]; then
        copy_file "./.agent-os/codex/config/codex-config.toml" "./codex-config.toml" "false" "codex-config.toml"
        echo "  ✓ Codex configuration copied to project root (codex-config.toml)"
    fi
fi

# Success message
echo ""
echo "✅ Agent OS has been installed in your project ($PROJECT_NAME)!"
echo ""
echo "📍 Project-level files installed to:"
echo "   .agent-os/instructions/    - Agent OS instructions"
echo "   .agent-os/standards/       - Development standards"

if [ "$CLAUDE_CODE" = true ]; then
    echo "   .claude/commands/          - Claude Code commands"
    echo "   .claude/agents/            - Claude Code specialized agents"
fi

if [ "$CURSOR" = true ]; then
    echo "   .cursor/rules/             - Cursor command rules"
fi

if [ "$CODEX" = true ]; then
    echo "   .agent-os/codex/           - OpenAI Codex integration files"
    echo "   codex-config.toml          - Codex configuration"
    echo "   CODEX_INTEGRATION.md       - Codex setup and usage guide"
fi

echo ""
echo "--------------------------------"
echo ""
echo "Next steps:"
echo ""

if [ "$CLAUDE_CODE" = true ]; then
    echo "Claude Code useage:"
    echo "  /plan-product    - Set the mission & roadmap for a new product"
    echo "  /analyze-product - Set up the mission and roadmap for an existing product"
    echo "  /create-spec     - Create a spec for a new feature"
    echo "  /execute-tasks   - Build and ship code for a new feature"
    echo ""
fi

if [ "$CURSOR" = true ]; then
    echo "Cursor useage:"
    echo "  @plan-product    - Set the mission & roadmap for a new product"
    echo "  @analyze-product - Set up the mission and roadmap for an existing product"
    echo "  @create-spec     - Create a spec for a new feature"
    echo "  @execute-tasks   - Build and ship code for a new feature"
    echo ""
fi

if [ "$CODEX" = true ]; then
    echo "OpenAI Codex usage:"
    echo "  1. Install Codex CLI: npm install -g @openai/codex-cli"
    echo "  2. Set API key: export OPENAI_API_KEY=\"your-key\""
    echo "  3. Initialize: codex init --config ./codex-config.toml"
    echo "  4. Run tasks: codex run \"Execute the login task using Agent OS workflows\""
    echo ""
    echo "  See CODEX_INTEGRATION.md for detailed setup and usage instructions"
    echo ""
fi

echo "--------------------------------"
echo ""
echo "Refer to the official Agent OS docs at:"
echo "https://buildermethods.com/agent-os"
echo ""
echo "Keep building! 🚀"
echo ""
