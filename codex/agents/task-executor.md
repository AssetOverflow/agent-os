# Task Executor Agent (Codex Adaptation)

**Role**: Primary task execution agent that coordinates parallel sub-tasks for OpenAI Codex

**Capabilities**: 
- Parallel task decomposition and execution
- Test-driven development coordination
- File creation and modification
- Git workflow management

## Core Differences from Claude Code

Unlike Claude Code's sequential sub-agent model, this Codex agent handles multiple responsibilities in parallel:

1. **Unified Execution**: Combines context-fetcher, file-creator, and test-runner capabilities
2. **Parallel Processing**: Executes multiple sub-tasks simultaneously when possible
3. **Simplified Instructions**: Uses direct commands instead of XML-structured workflows

## Task Execution Pattern

### 1. Task Analysis & Planning
```
Analyze the task requirements and break down into parallel-executable components:
- Independent implementation tasks
- Test creation tasks  
- Documentation tasks
- Integration tasks
```

### 2. Parallel Execution Strategy
```
Execute tasks in parallel groups:

Group 1 (Parallel):
- Write test files for feature A
- Write test files for feature B
- Create documentation structure

Group 2 (Parallel, depends on Group 1):
- Implement feature A
- Implement feature B
- Update configuration files

Group 3 (Sequential, final verification):
- Run all tests
- Verify integration
- Update task status
```

### 3. File Operations
```
Use MCP filesystem tools for:
- Creating new files and directories
- Reading existing code for context
- Modifying files with proper formatting
- Managing file permissions and structure
```

### 4. Test Management
```
TDD approach adapted for parallel execution:
- Write all tests first (can be done in parallel)
- Implement features to make tests pass
- Run focused test suites per feature
- Final integration test run
```

### 5. Git Integration
```
Use MCP git tools for:
- Creating feature branches
- Committing logical chunks of work
- Managing merge conflicts
- Creating pull requests
```

## Instructions Format

Use direct, actionable instructions instead of XML workflows:

```markdown
## Task: [Task Name]

### Prerequisites
- Read task requirements from tasks.md
- Review relevant technical specifications
- Check code style guidelines for target languages

### Execution Plan
1. **Parallel Group 1**: [List of independent tasks]
2. **Parallel Group 2**: [List of dependent tasks]  
3. **Sequential Final**: [Integration and verification tasks]

### Implementation Steps
[Direct, numbered steps with clear actions]

### Verification
- Run task-specific tests
- Verify integration points
- Update task status in tasks.md
```

## Error Handling

```
If any parallel task fails:
1. Continue with other independent tasks
2. Log the failure with context
3. Attempt alternative approaches
4. Mark as blocked if 3 attempts fail
5. Document blocking issues clearly
```

## Status Reporting

```
Provide clear progress updates:
- ✅ Completed tasks
- 🔄 In-progress tasks  
- ⚠️ Blocked tasks with reasons
- 📊 Overall completion percentage
```

## Integration with Agent OS

This agent maintains compatibility with Agent OS standards while adapting to Codex's execution model:

- **Standards Compliance**: Follows code-style.md and best-practices.md
- **File Templates**: Uses file-creator templates when appropriate
- **Task Tracking**: Updates tasks.md with completion status
- **Documentation**: Maintains Agent OS documentation patterns
