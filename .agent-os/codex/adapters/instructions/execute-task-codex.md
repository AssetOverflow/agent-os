# Execute Task - Codex Adaptation

**Purpose**: Execute a specific task and its sub-tasks using OpenAI Codex's parallel execution model

## Overview

This instruction adapts Agent OS task execution for Codex's strengths:
- Parallel task processing
- Simplified instruction format  
- Efficient token usage
- Cloud sandbox compatibility

## Execution Flow

### 1. Task Understanding
```
Read and analyze the task from tasks.md:
- Parent task description and requirements
- All sub-task descriptions and dependencies
- Expected outcomes and deliverables
- Test requirements for each component
```

### 2. Context Gathering
```
Gather relevant context efficiently:
- Search technical-spec.md for task-relevant sections only
- Extract applicable best practices from standards/best-practices.md
- Get code style rules for languages being used
- Review existing codebase for integration points
```

### 3. Parallel Execution Planning
```
Analyze sub-tasks for parallelization opportunities:

Independent Tasks (can run in parallel):
- Writing tests for different features
- Creating documentation files
- Setting up configuration files
- Implementing isolated components

Dependent Tasks (must run sequentially):
- Tasks that depend on other task outputs
- Integration steps
- Final verification steps
```

### 4. Implementation Strategy

#### Phase 1: Parallel Foundation (Execute Simultaneously)
```
- Write all test files for the feature
- Create any new directories/file structure  
- Set up configuration files
- Create documentation templates
```

#### Phase 2: Parallel Implementation (Execute Simultaneously)
```
- Implement core functionality components
- Update related configuration
- Add integration code
- Update documentation content
```

#### Phase 3: Sequential Integration (Execute in Order)
```
1. Run all new tests to verify functionality
2. Run integration tests
3. Fix any test failures
4. Verify no regressions in existing tests
5. Update task status in tasks.md
```

### 5. File Operations
```
Use MCP filesystem tools efficiently:
- Read multiple files in parallel when possible
- Create file batches using templates
- Apply consistent formatting and structure
- Maintain proper file organization
```

### 6. Test Management
```
TDD approach optimized for parallel execution:
- Write comprehensive test suites first
- Implement features to satisfy tests
- Run focused test suites per component
- Perform final integration testing
```

### 7. Status Updates
```
Update tasks.md with completion status:
- [x] for completed tasks
- [ ] for incomplete tasks  
- ⚠️ for blocked tasks with clear reason
```

## Error Handling

```
When tasks fail:
1. Continue with other independent tasks
2. Try up to 3 different approaches for failed tasks
3. Document specific blocking issues
4. Mark as blocked with ⚠️ emoji if all attempts fail
5. Provide clear next steps for resolution
```

## Success Criteria

```
Task is complete when:
✅ All sub-tasks are implemented
✅ All tests pass (both new and existing)
✅ Code follows style guidelines
✅ Documentation is updated
✅ Task status is updated in tasks.md
✅ No regressions introduced
```

## Integration Notes

This Codex adaptation maintains Agent OS compatibility:
- Uses same file templates and standards
- Follows same documentation patterns
- Maintains same quality gates
- Produces same deliverable structure

The key difference is execution efficiency through parallelization and simplified instruction processing.
