# Claude — LLM-Specific Instructions

> Read @AGENT.md first. It contains the full project configuration (persona, rules, skills, coding standards, workflow).

## File References

Claude uses `@` syntax to import files. When referencing rules or skills, use:

- Rules: `@.agents/rules/<file>.md`
- Skills: `@.agents/skills/<folder>/SKILL.md`

## Auto-Loaded Rules

Claude Code automatically loads rules from `.claude/rules/`. These are symlinks to `.agents/rules/` (shared source of truth). Do not duplicate rule content.
