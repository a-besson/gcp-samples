# Common Infrastructure Standards

Base standards applicable to all agent tasks in this repository.

## Industrial Standards

- **Absolute Priority**: Every agent action must be validated against the rules in `.agents/rules/` and the skill `.agents/skills/best-practice/`.
- **Zero Placeholder**: Never propose incomplete code or placeholders.
- **Security by Design**: All exposed resources must be private by default.
- **Auto-Documentation**: Every Terraform or Task orchestration code must include its associated documentation (TFDOCS.md, descriptions).
