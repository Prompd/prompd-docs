# Prompd Composite Documentation (Latest Summary)

Last consolidated: 2025-08-29

This single document aggregates current, actionable information from repo Markdown files to reduce duplication and drift. Each section cites its source and incorporates the latest dated notes where available.

## Composable Packages Published
- Source: COMPOSABLE-PACKAGES-PUBLISHED.md
- Date: August 29, 2025
- Highlights:
  - Status: COMPLETE — Initial composable registry live at http://localhost:4001.
  - Published packages (foundation → advanced):
    - @prompd.io/core-patterns@2.0.1
    - @prompd.io/security-toolkit@1.0.1
    - @prompd.io/data-science-toolkit@1.0.1
    - @prompd.io/api-toolkit@1.0.1
    - @prompd.io/devops-toolkit@1.0.1
    - @prompd.io/finance-toolkit@1.0.1
  - Notes: Package versions have been patch-bumped and rebuilt/validated locally as .pdpkg artifacts (packages/ and packages-new/).

## Canonical Verbs and Agent Guidelines
- Source: AGENTS.md
- Latest: Use only compile, run, validate (plus install|publish|list|search|cache). Replace generate/execute/render accordingly. Keep changes minimal and aligned with composable architecture.
- Key conventions:
  - Parameters should have type/required/enum/default.
  - Security levels: standard, high, critical.
  - Provide Bash examples; PowerShell only on request.
  - Place referenced params files under nearby params/.

## CLI Usage Patterns
- Sources: README.md, HOW-TO-USE.md
- Latest commands:
  - Validate: `prompd validate <path/to/file.prmd>`
  - Compile: `prompd compile <prompt|flow> --params ...` or `--params-file ...`
  - Run with context: `prompd run <prompt> --params-file ... --meta:context <file>`
- Scripted workflows: prefer “compiled” terminology and `compile-*` script names.

## Engineering Workflow
- Source: pdflows/engineering-workflow.pdflow
- Normalized to compile/run verbs:
  - Architecture: `prompd compile prompds/architecture-review.prmd` with system_component, review_type, scale.
  - Implementation: `prompd compile prompds/code-implementation.prmd` with component_name, language, security_level.
  - Testing: `prompd compile prompds/integration-testing.prmd` with test_scope, component, coverage_target.
  - Bug fix: `prompd compile prompds/bug-fix.prmd`.

## Security Notes (OWASP)
- Sources: real-world-prompts/security/owasp-security-audit.prmd, composable-packages/.../owasp-top-10.md
- Current reference: OWASP Top 10 (2021) categories included and mapped for audits.
- Run security audit with context files:
  - `prompd run real-world-prompts/security/owasp-security-audit.prmd --params-file security-params.json --meta:context <files>`

## Composable Architecture Overview
- Source: COMPOSABLE-ARCHITECTURE.md
- Core elements:
  - .prmd = YAML frontmatter + Markdown (Jinja2/Handlebars templating allowed).
  - Composition: using (imports), inherits (override/extend).
  - Packaging: .pdpkg with manifest.json; publish/install via Registry; support multiple registries.
  - Versioning: semantic x.y.z; Git tags per file stem.

## Current Local Packaging State
- Built locally via Prompd CLI (`prompd package create`) and validated (`prompd package validate`).
- Output locations:
  - Scoped: packages-new/@prompd.io-<name>@<version>.pdpkg
  - Simple: packages/<name>-<version>.pdpkg
- Manifests reflect available files only (exports/contexts pruned where missing) to pass validation.

## Next Documentation Actions
- Unify examples to canonical verbs across any remaining docs.
- Backfill missing exported prompt files in composable packages, then restore exports in manifests.
- Optionally package root library via engineering-prompts.pdproj for distribution.

## Ecosystem Docs
- For the cross-project overview, see `ECOSYSTEM.md`.
- For the registry contract used by CLI/IDE, see `REGISTRY-API.md`.

---

Appendix: Source Inventory
- AGENTS.md — agent operating model, verbs, editing conventions.
- README.md — quick start; compile/run usage; workflow examples.
- HOW-TO-USE.md — detailed CLI workflows; troubleshooting; scripts.
- COMPOSABLE-ARCHITECTURE.md — format, composition, packaging, registry.
- COMPOSABLE-PACKAGES-PUBLISHED.md — status log (August 29, 2025) of package publication.
- ARCHITECTURE-SUCCESS.md — success criteria and readiness signals.
- PACKAGE-UPLOAD-ORDER.md — dependency-ordered publish plan and test commands.
- UPLOAD-STATUS.md — operational notes (if present).
