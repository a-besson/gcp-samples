---
name: Best Practice
description: "Core engineering standards for IaC, orchestration, pre-commit, and CI/CD quality gates."
---

# Best Practice — Core Engineering Standards

This skill defines the mandatory engineering standards applied to every task in this repository.

## Priority

This skill takes precedence over all community skills. In case of conflict, these rules always win.

## Required Reading

Before ANY task, the agent MUST read and apply:

1. **[common.md](../../rules/common.md)**: Base industrial standards.
2. **[terraform.md](./terraform.md)**: Strict IaC standards.
3. **[taskfile.md](./taskfile.md)**: Orchestration standards (zero Makefile).
4. **[pre-commit.md](./pre-commit.md)**: Pre-commit quality gates.

## Expected Behavior

- When using multiple skills, **best-practice** is the final authority.
- NEVER propose workarounds that violate the rules above.
- When another skill conflicts with these rules, **best-practice always wins**.
