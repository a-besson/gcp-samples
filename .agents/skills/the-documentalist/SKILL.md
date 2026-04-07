---
name: The Documentalist
description: Standards and guidelines for impeccable, developer-friendly documentation across the repository.
---

# 📚 The Documentalist

Documentation is as critical as code. A well-documented project reduces onboarding time, explicitly defines architectural boundaries, and serves as the single source of truth.

This skill ensures that all documentation respects industrial standards, remains continually in sync with the codebase, and incorporates best practices for Markdown writing.

## 🎯 Core Principles

1. **Automation First**: Never write documentation manually if it can be generated (e.g., Terraform outputs, variables).
2. **Contextual Completeness**: Every component must document its architectural intent, dependencies, and execution commands.
3. **Continuous Sync**: Documentation MUST be updated before finishing any task.

## 📂 Repository Documentation Structure

### 1. Root `README.md`
The global entry point of the project.
- Must include the project's overall description and tech stack.
- Must detail installation instructions for core tools (Terraform, Task, Pre-commit, Trivy, KICS).
- Must contain an up-to-date **Samples Table** listing all sub-projects inside `samples/` with formatting:
  - `| Name | Description | Link to README |`

### 2. Sample `README.md` (`samples/<name>/README.md`)
Every individual sample must contain its own detailed README with structural consistency.
- **Header**: Clear title, preferably with an emoji (e.g., `# 🚀 Cloud Run Service`).
- **TFDOCS Verification**: Must present a highly visible link to the auto-generated documentation right after the title:
  `> [📚 Consulter la documentation Terraform auto-générée (TFDOCS.md)](./TFDOCS.md)`
- **Architectural Diagram**: Include visual context, linking to `architecture.drawio` (using the `cloud-architecture-drawio` skill).
- **Features List**: A bulleted high-level summary of the implementation.
- **Getting Started**: Step-by-step guidance on how to deploy (`Init`, `Plan`, `Apply`).
- **Task Commands**: Explain the actions available via `Taskfile.yml`.
- **Project Structure**: A brief tree visualization (`tree`) of the sample configuration.

### 3. Terraform Documentation (`TFDOCS.md`)
- Must be auto-generated utilizing the `terraform-docs` pre-commit hook.
- Ensure all Terraform variables include a `description` and a `type`.
- Must reside at the **base** of each sample folder alongside the `Taskfile.yml` and `README.md` (e.g., `samples/base/TFDOCS.md`).

### 4. Specifications and Architecture Decisions (`SPECS.md`)
- Tracks architectural choices and technical syntheses.
- Must follow the daily log compressed syntax strictly:
  ```markdown
  ## [YYYY-MM-DD] - Daily Log - Un titre synthétique des aspects techniques apportés
  ```
- Group every architectural or configuration decision as a bullet point beneath the single daily log heading. Do NOT create multiple headings for the same date.

## ✍️ Markdown Writing Best Practices

- **Use Emojis Strategically**: Provide visual anchors for readability without cluttering.
- **Admonitions (GitHub standard)**: Isolate critical info with alerts:
  - `> [!NOTE]` for contextual details.
  - `> [!WARNING]` for destructive actions or important constraints.
  - `> [!IMPORTANT]` for core rules.
- **Brevity & Precision**: Write concise, developer-oriented documentation. Eliminate fluff. Emphasize commands and architectural choices.
- **Proper Code Blocks**: Always use language specifiers (e.g., `bash`, `hcl`, `yaml`) in Markdown code blocks for proper syntax highlighting.
