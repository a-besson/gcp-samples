# Pre-commit & Quality Standards

Mandatory local quality and security checks for every project.

## Required Standards

1. **Systematic Usage**: Every project directory (especially Terraform) must be controlled via `pre-commit`.
2. **Standard Config**: A `.pre-commit-config.yaml` must exist at the project root.
3. **Required Hooks**:
   - *General*: `check-yaml`, `check-added-large-files`, `check-json`, `trailing-whitespace`, `detect-private-key`
   - *Security (Zero Tolerance)*: `gitleaks` — mandatory to prevent any cleartext secret from leaking.
   - *Terraform*: `terraform_fmt`, `terraform_validate`, `terraform_docs` (auto-generate `TFDOCS.md`), `terraform_tflint`
4. **Validation Before Completion**: No task can be declared "done" until `pre-commit run --all-files` passes successfully.
