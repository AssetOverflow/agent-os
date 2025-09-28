# Agent OS Workflow Adapter for Codex

This adapter translates Agent OS's Claude Code workflows into Codex-compatible execution patterns.

## Core Adaptations

### 1. Sub-Agent Translation

**Claude Code Sub-Agents** → **Codex Unified Execution**

| Claude Code Sub-Agent | Codex Equivalent | Implementation |
|----------------------|------------------|----------------|
| `context-fetcher` | Direct MCP calls | Use filesystem/git MCP servers |
| `file-creator` | Batch file operations | Parallel file creation with templates |
| `test-runner` | Integrated testing | Direct test execution with result parsing |
| `project-manager` | Status tracking | Automated task status updates |
| `git-workflow` | Git MCP integration | Use git MCP server for operations |
| `date-checker` | Built-in functions | Use standard date/time functions |

### 2. Instruction Format Translation

**From Claude Code XML Format:**
```xml
<step number="1" subagent="context-fetcher" name="best_practices_review">
  <instructions>
    ACTION: Use context-fetcher subagent
    REQUEST: "Find best practices sections relevant to..."
  </instructions>
</step>
```

**To Codex Direct Format:**
```markdown
## Step 1: Best Practices Review
Use MCP filesystem server to read relevant sections from standards/best-practices.md:
- Search for sections matching current technology stack
- Extract applicable patterns and guidelines
- Apply to current implementation approach
```

### 3. Parallel Execution Mapping

**Sequential Claude Code Flow:**
```
Step 1: context-fetcher → 
Step 2: file-creator → 
Step 3: test-runner → 
Step 4: project-manager
```

**Parallel Codex Flow:**
```
Parallel Group 1:
├── Read context (filesystem MCP)
├── Create file structure (filesystem MCP)
└── Set up test framework

Parallel Group 2:
├── Implement features
├── Write tests
└── Update documentation

Sequential Final:
├── Run all tests
├── Update task status
└── Commit changes (git MCP)
```

## Workflow Patterns

### 1. Task Execution Pattern

```markdown
# Codex Task Execution

## Phase 1: Preparation (Parallel)
- Read task requirements from tasks.md
- Extract relevant technical specifications
- Gather applicable code style guidelines
- Review existing codebase for context

## Phase 2: Implementation (Parallel)
- Create necessary file structures
- Implement core functionality
- Write comprehensive tests
- Update documentation

## Phase 3: Verification (Sequential)
- Run all tests and verify results
- Check integration points
- Update task completion status
- Commit changes with proper messages
```

### 2. File Creation Pattern

```markdown
# Codex File Creation

## Batch File Operations
Instead of sequential file creation, use parallel operations:

```javascript
// Parallel file creation
const fileOperations = [
  createFile('spec.md', specTemplate),
  createFile('tasks.md', tasksTemplate),
  createFile('technical-spec.md', techSpecTemplate)
];

await Promise.all(fileOperations);
```

### 3. Test Execution Pattern

```markdown
# Codex Test Management

## Integrated Testing Approach
- Write all tests first (TDD approach)
- Run tests in parallel when possible
- Provide detailed failure analysis
- Integrate with CI/CD workflows
```

## MCP Integration Patterns

### 1. Filesystem Operations

```javascript
// Read multiple files in parallel
const contextFiles = await Promise.all([
  mcpFilesystem.read('standards/best-practices.md'),
  mcpFilesystem.read('standards/code-style.md'),
  mcpFilesystem.read('specs/current-spec/technical-spec.md')
]);
```

### 2. Git Operations

```javascript
// Git workflow integration
await mcpGit.createBranch('feature/new-task');
await mcpGit.commit('Implement task: ' + taskName);
await mcpGit.push('origin', 'feature/new-task');
```

### 3. Rube Toolkit Integration

```javascript
// Use Rube adapter for extended capabilities
const rubeTools = await mcpRube.listTools();
const figmaData = await mcpRube.callTool('figma', 'get-design', {
  fileId: 'design-file-id'
});
```

## Error Handling Adaptations

### 1. Parallel Task Failure

```markdown
# Codex Error Handling

When parallel tasks fail:
1. Continue with successful tasks
2. Retry failed tasks with alternative approaches
3. Escalate to sequential execution if needed
4. Document failures with clear context
```

### 2. MCP Server Issues

```markdown
# MCP Server Error Recovery

If MCP servers fail:
1. Attempt reconnection
2. Fall back to direct file operations
3. Use alternative MCP servers if available
4. Gracefully degrade functionality
```

## Performance Optimizations

### 1. Token Efficiency

```markdown
# Optimized for Codex Token Usage

- Use concise, direct instructions
- Minimize repetitive context
- Batch related operations
- Cache frequently accessed data
```

### 2. Execution Speed

```markdown
# Faster Execution Patterns

- Parallel task processing
- Efficient MCP server usage
- Reduced context switching
- Streamlined verification steps
```

## Compatibility Matrix

| Agent OS Feature | Claude Code | Codex Support | Notes |
|------------------|-------------|---------------|-------|
| XML Workflows | ✅ Native | 🔄 Adapted | Converted to markdown |
| Sub-Agents | ✅ Native | 🔄 Unified | Combined into single agent |
| MCP HTTP | ✅ Native | ❌ Not supported | Use stdio adapter |
| MCP stdio | ✅ Supported | ✅ Native | Direct compatibility |
| Parallel Execution | ❌ Sequential | ✅ Native | Codex advantage |
| Cloud Sandboxes | ❌ Local only | ✅ Supported | Codex advantage |

## Migration Guide

### 1. Converting Existing Workflows

1. **Identify Sub-Agent Dependencies**: Map which sub-agents are used
2. **Extract Core Logic**: Remove XML wrapper, keep core instructions
3. **Identify Parallelization**: Find independent operations
4. **Update MCP Calls**: Convert HTTP to stdio where needed
5. **Test Thoroughly**: Verify equivalent functionality

### 2. Best Practices

- Start with simple workflows and gradually add complexity
- Test both local and cloud sandbox modes
- Monitor token usage and optimize accordingly
- Maintain compatibility with existing Agent OS standards

This adapter ensures that Agent OS workflows can leverage Codex's strengths while maintaining the structured approach and quality standards of the original system.
