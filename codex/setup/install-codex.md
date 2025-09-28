# OpenAI Codex Setup for Agent OS

This guide walks you through setting up OpenAI Codex to work with Agent OS workflows.

## Prerequisites

1. **OpenAI Account**: Ensure you have access to OpenAI Codex
2. **Node.js**: Required for MCP server adapters (v16+ recommended)
3. **Agent OS**: This repository cloned locally

## Installation Steps

### 1. Install OpenAI Codex CLI

```bash
# Install via npm
npm install -g @openai/codex-cli

# Or install via pip (if Python version available)
pip install openai-codex
```

### 2. Configure Authentication

```bash
# Set your OpenAI API key
export OPENAI_API_KEY="your-api-key-here"

# For Rube MCP integration (optional)
export RUBE_AUTH_TOKEN="your-rube-token-here"
export RUBE_ENDPOINT="https://api.rube.app"
```

### 3. Setup MCP Servers

```bash
# Navigate to your project directory
cd /path/to/your/project

# Copy Codex configuration
cp ./agent-os/codex/config/codex-config.toml ./codex-config.toml

# Install required MCP servers
npm install -g @modelcontextprotocol/server-filesystem
npm install -g @modelcontextprotocol/server-git
npm install -g @modelcontextprotocol/server-sqlite

# Make Rube adapter executable
chmod +x ./agent-os/codex/tools/rube-mcp-adapter.js
```

### 4. Initialize Codex with Agent OS

```bash
# Initialize Codex in your project
codex init --config ./codex-config.toml

# Verify MCP servers are working
codex mcp list
```

### 5. Enable Agent OS Codex Mode

Edit your `agent-os/config.yml`:

```yaml
agents:
  codex:
    enabled: true
    config_file: ./codex/config/codex-config.toml
```

## Usage

### Basic Task Execution

```bash
# Execute a task using Codex with Agent OS
codex run "Execute the user authentication task from tasks.md using Agent OS workflows"
```

### With Specific Instructions

```bash
# Use Codex-adapted instructions
codex run --instructions ./agent-os/codex/adapters/instructions/execute-task-codex.md "Implement the login feature"
```

### Parallel Task Execution

```bash
# Execute multiple tasks in parallel
codex run --parallel "Implement login feature, Create user dashboard, Set up database schema"
```

## Configuration Options

### Codex-Specific Settings

Edit `codex-config.toml` to customize:

```toml
[codex]
# Enable parallel task execution
parallel_execution = true

# Maximum concurrent tasks
max_concurrent_tasks = 3

# Use simplified instruction format
simplified_instructions = true

# Enable cloud sandbox mode
cloud_sandbox = false
```

### MCP Server Configuration

Add or modify MCP servers in the config:

```toml
[mcp_servers.your_custom_server]
command = "your-command"
args = ["arg1", "arg2"]
```

## Troubleshooting

### Common Issues

1. **MCP Server Not Found**
   ```bash
   # Reinstall MCP servers
   npm install -g @modelcontextprotocol/server-filesystem
   ```

2. **Authentication Errors**
   ```bash
   # Verify API key is set
   echo $OPENAI_API_KEY
   ```

3. **Rube Adapter Issues**
   ```bash
   # Check Rube token
   echo $RUBE_AUTH_TOKEN
   
   # Test adapter directly
   node ./agent-os/codex/tools/rube-mcp-adapter.js
   ```

### Debug Mode

```bash
# Run Codex with debug output
codex run --debug "your task"
```

## Differences from Claude Code

- **Execution Model**: Parallel vs sequential sub-agents
- **MCP Transport**: stdio/websocket only (no HTTP)
- **Instructions**: Simplified format vs XML workflows
- **Context**: Cloud sandboxes vs local awareness

## Next Steps

1. Try executing a simple task to verify setup
2. Review the adapted instructions in `./codex/adapters/instructions/`
3. Customize the configuration for your specific needs
4. Explore parallel task execution capabilities

For more advanced usage, see the Agent OS documentation and Codex-specific guides in this directory.
