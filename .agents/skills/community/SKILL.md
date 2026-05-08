---
name: Community Skills Orchestrator
description: "Guidelines and index for third-party skills stored in the community folder."
---

# 🌐 Community Skills Guidelines

This skill orchestrates all third-party skills downloaded via CLI.

## Skill Discovery

The agent MUST scan all subdirectories of `.agents/skills/community/` to identify and load available skills before acting on the corresponding domains:

- **Draw.io Diagrams**: see [drawio/SKILL.md](./drawio/SKILL.md)
- **Terraform Stacks**: see [terraform-stacks/SKILL.md](./terraform-stacks/SKILL.md)
- **Terraform Test**: see [terraform-test/SKILL.md](./terraform-test/SKILL.md)
- **Style Guide**: see [terraform-style-guide/SKILL.md](./terraform-style-guide/SKILL.md)
- **Provider Actions**: see [provider-actions/SKILL.md](./provider-actions/SKILL.md)
- **Refactor Module**: see [refactor-module/SKILL.md](./refactor-module/SKILL.md)
- **Provider Resources**: see [provider-resources/SKILL.md](./provider-resources/SKILL.md)
- **New Provider Creation**: see [new-terraform-provider/SKILL.md](./new-terraform-provider/SKILL.md)

## Priority

All skills listed here are subject to the authority of the **best-practice** skill. In case of technical or behavioral conflict, rules in `.agents/skills/best-practice/` prevail.
