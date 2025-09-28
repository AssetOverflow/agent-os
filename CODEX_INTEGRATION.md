# OpenAI Codex Integration for Agent OS

Agent OS now supports OpenAI Codex in addition to Claude Code, enabling you to leverage Codex's parallel execution capabilities while maintaining Agent OS's structured workflow approach.

## Quick Start

### 1. Installation
```bash
# Install Codex CLI
npm install -g @openai/codex-cli

# Set up MCP servers
npm install -g @modelcontextprotocol/server-filesystem
npm install -g @modelcontextprotocol/server-git

# Configure authentication
export OPENAI_API_KEY="your-api-key-here"
```

### 2. Enable Codex Support
Edit `config.yml`:
```yaml
agents:
  codex:
    enabled: true
    config_file: ./codex/config/codex-config.toml
```

### 3. Initialize Your Project
```bash
# Copy Codex configuration
cp ./agent-os/codex/config/codex-config.toml ./codex-config.toml

# Initialize Codex
codex init --config ./codex-config.toml
```

## Key Differences from Claude Code

| Feature | Claude Code | OpenAI Codex |
|---------|-------------|--------------|
| **Execution Model** | Sequential sub-agents | Parallel task execution |
| **Instruction Format** | XML-structured workflows | Direct markdown instructions |
| **MCP Support** | HTTP + stdio | stdio + websocket only |
| **Context Management** | Local codebase awareness | Cloud sandboxes + local CLI |
| **Token Efficiency** | Detailed reasoning | Optimized for efficiency |

## Architecture Overview

### Claude Code Sub-Agents → Codex Unified Agent

Agent OS's Claude Code sub-agents are consolidated into a unified Codex agent:

- **context-fetcher** → Direct MCP filesystem calls
- **file-creator** → Batch file operations with templates
- **test-runner** → Integrated test execution
- **project-manager** → Automated status tracking
- **git-workflow** → Git MCP server integration

### Parallel Execution Model

Codex executes Agent OS workflows in parallel phases:

```
Phase 1 (Parallel):
├── Read task requirements
├── Gather context from specs
└── Set up file structures

Phase 2 (Parallel):
├── Implement features
├── Write tests
└── Update documentation

Phase 3 (Sequential):
├── Run all tests
├── Verify integration
└── Update task status
```

## Workflow Adaptations

### Task Execution

**Claude Code Style:**
```xml
<step number="1" subagent="context-fetcher">
  <instructions>ACTION: Use context-fetcher subagent</instructions>
</step>
```

**Codex Style:**
```markdown
## Step 1: Context Gathering
Use MCP filesystem server to read relevant context:
- Extract task requirements from tasks.md
- Review applicable standards and best practices
```

### File Creation

**Claude Code:** Sequential file creation via file-creator sub-agent
**Codex:** Parallel batch file operations with template system

### Testing

**Claude Code:** Dedicated test-runner sub-agent
**Codex:** Integrated TDD approach with parallel test execution

## MCP Integration

### Supported Transports

- ✅ **stdio**: Native Codex support
- ✅ **websocket**: Native Codex support  
- 🔄 **HTTP**: Via adapter (for Rube integration)

### MCP Server Configuration

```toml
[mcp_servers.filesystem]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-filesystem", "."]

[mcp_servers.git]
command = "npx"
args = ["-y", "@modelcontextprotocol/server-git"]

[mcp_servers.rube]
command = "node"
args = ["./codex/tools/rube-mcp-adapter.js"]
```

## Usage Examples

### Basic Task Execution
```bash
codex run "Execute the user authentication task from tasks.md"
```

### With Agent OS Instructions
```bash
codex run --instructions ./agent-os/codex/adapters/instructions/execute-task-codex.md "Implement login feature"
```

### Parallel Task Execution
```bash
codex run --parallel "Implement login, Create dashboard, Set up database"
```

## Configuration Options

### Codex-Specific Settings

```toml
[codex]
parallel_execution = true
max_concurrent_tasks = 3
simplified_instructions = true
cloud_sandbox = false  # Set to true for cloud execution
```

### Agent OS Integration

```toml
[agent_os]
version = "1.4.1"
mode = "codex"
instructions_path = "./instructions"
standards_path = "./standards"
codex_adapters_path = "./codex/adapters"
```

## Migration from Claude Code

### Automatic Workflow Conversion

The Codex adapter automatically converts Agent OS workflows:

1. **XML to Markdown**: Converts structured XML workflows to direct markdown instructions
2. **Sub-Agent Consolidation**: Combines multiple sub-agents into unified execution
3. **Parallel Optimization**: Identifies and parallelizes independent operations
4. **MCP Adaptation**: Converts HTTP MCP calls to stdio equivalents

### Manual Customization

For advanced use cases, you can customize workflows:

1. **Create Custom Instructions**: Add files to `./codex/adapters/instructions/`
2. **Modify Agent Configuration**: Edit `./codex/agents/` files
3. **Extend MCP Integration**: Add custom MCP servers to config
4. **Optimize for Parallel Execution**: Identify additional parallelization opportunities

## Best Practices

### Performance Optimization

- **Batch Operations**: Group related file operations
- **Parallel Execution**: Leverage Codex's parallel capabilities
- **Token Efficiency**: Use concise, direct instructions
- **MCP Caching**: Cache frequently accessed MCP data

### Error Handling

- **Graceful Degradation**: Fall back to sequential execution if parallel fails
- **Retry Logic**: Implement retry mechanisms for failed operations
- **Clear Error Messages**: Provide actionable error information
- **Status Tracking**: Maintain clear task completion status

### Compatibility

- **Standards Compliance**: Follow existing Agent OS code style and best practices
- **Template Consistency**: Use Agent OS file templates and patterns
- **Documentation**: Maintain Agent OS documentation standards
- **Quality Gates**: Preserve Agent OS quality verification steps

## Troubleshooting

### Common Issues

1. **MCP Server Connection**: Verify MCP servers are installed and accessible
2. **Authentication**: Ensure OPENAI_API_KEY is set correctly
3. **Parallel Execution**: Some tasks may need sequential execution
4. **Token Limits**: Monitor token usage with complex workflows

### Debug Mode

```bash
codex run --debug --verbose "your task"
```

### Support

- **Agent OS Documentation**: [buildermethods.com/agent-os](https://buildermethods.com/agent-os)
- **Codex Documentation**: Check OpenAI's official Codex documentation
- **MCP Protocol**: [modelcontextprotocol.io](https://modelcontextprotocol.io)

## Roadmap

### Current Features ✅
- Basic workflow adaptation
- MCP integration (stdio/websocket)
- Parallel task execution
- File template system

### Planned Features 🚧
- Enhanced cloud sandbox support
- Advanced parallel optimization
- Custom workflow designer
- Performance analytics

### Future Considerations 💭
- Multi-agent coordination
- Advanced error recovery
- Workflow visualization
- Team collaboration features

---

This integration brings the best of both worlds: Agent OS's structured approach to development workflows and Codex's efficient parallel execution capabilities.
