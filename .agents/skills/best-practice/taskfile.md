# Taskfile Orchestration Standards

Mandatory standards for local command orchestration.

## Required Standards

1. **Zero Makefile**: `Makefile` usage is strictly forbidden. All orchestration must use `Taskfile.yml` (see https://taskfile.dev).
2. **Version**: Every `Taskfile.yml` must start with `version: '3'`.
3. **Centralized Variables**: All global inputs must be defined in a `vars:` block (using `{{.VAR_NAME}}` syntax).
4. **Self-Documentation**: Every `task:` must include an explicit `desc:` property for readable `task --list` output.
5. **Explicit Dependencies**: Always use `deps:` to chain required tasks (`deps: [task1, task2]`) instead of calling them in `cmds`.
6. **Execution Directory**: Prefer the `dir: <path>` attribute on the task config instead of `cd <path> && <command>` in bash.
