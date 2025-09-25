# Prompd Ecosystem Overview

> **⚠️ READ-ONLY**: This file is maintained by the documentation system. Do not edit directly unless you are the repository owner with override permissions.

This document aligns the three core projects and their integration contracts.

## Components
- prompd-cli: Command-line engine for `compile`, `run`, `validate`, and package verbs `install|publish|list|search|cache`.
- prompd-ide: IDE integration (enhanced shell, previews, context composition, completions) built on the CLI.
- registry.prmd.ai: Package registry implementing the HTTP API in `REGISTRY-API.md`.

## Responsibilities
- CLI: Single source of truth for compilation, validation, packaging, signing, and interacting with the registry.
- IDE: UX layer invoking the CLI; surfaces search/install, previews compiled prompts, manages context files.
- Registry: Stores and serves `.pdpkg` artifacts and metadata; validates publish; enforces auth and integrity.

## Compatibility and Versioning
- Registry API: `/v1` stable; minor additions are backward compatible.
- CLI: Supports current and N-1 registry API versions; warns on deprecations.
- IDE: Targets a specific CLI major version; forwards `prompd --features` to surface capabilities.
- Capability negotiation:
  - `GET /v1/capabilities` (registry)
  - `prompd --version --features` (CLI)

Note: Do not use the legacy OpenAPI file that lives in early registry scaffolds. REGISTRY-API.md is the canonical v1 contract; a formal OpenAPI 3.1 export will follow.

## Security Model
- Auth: Bearer tokens with scopes (`packages:read`, `packages:write`, `registry:admin`).
- Integrity: SHA256 on `.pdpkg`; optional package signatures (e.g., ed25519) validated by CLI.
- Transport: HTTPS only; recommend optional TLS pinning in clients.
- Policy: Org-level allow/deny lists enforced by CLI and IDE settings; registry can reject publish by policy.

## Core Flows

Author & Publish
```bash
# Author a prompt or package
prompd validate prompds/code-implementation.prmd

# Create a package artifact
prompd package create composable-packages/@prompd.io--security-toolkit@1.0.1 \
  packages-new/@prompd.io-security-toolkit@1.0.1.pdpkg \
  --name @prompd.io/security-toolkit \
  --version 1.0.1 \
  --description "Security audit components"

# Publish to registry
prompd publish packages-new/@prompd.io-security-toolkit@1.0.1.pdpkg
```

Discover & Install
```bash
prompd search security
prompd list --scope @prompd.io
prompd install @prompd.io/security-toolkit@1.0.1
```

Compile/Run with Context
```bash
prompd compile prompds/code-implementation.prmd \
  --params component_name="Registry Auth Middleware" language="nodejs" security_level="critical"

prompd run real-world-prompts/security/owasp-security-audit.prmd \
  --params-file security-params.json \
  --meta:context ./src/auth.js \
  --meta:context ./config/database.yml
```

## LLM Command Planner (Python)

The Python shell integrates a planner .prmd that converts natural language into safe CLI commands.

- Prompt asset: packaged at `prompd/assets/prompts/cli/python/command-planner.prmd` (bundled in the PyPI wheel)
- Behavior:
  - Chat text → compile+run planner prompt (system/user roles) using configured provider/model
  - Returns strict JSON: `{ intent, summary, commands: [{cmd, args, reason}], clarifying_question }`
  - CLI validates a whitelist of commands and safe relative paths, previews the plan, and asks for confirmation
  - On “yes” it executes via existing interactive handlers (no raw shell)
- Allowed commands (initial set): `compile`, `show`, `validate`, `list`, `provider_status`, `provider_switch`, `mkdir`, `create_file`, `move`, `copy`

Example (chat)
```text
You: help me compile the api prompt and then show it
Assistant (preview):
  Plan: Compile and show the API prompt
  - compile api-builder.prmd  # compile with defaults
  - show api-builder.prmd     # display structure
Run this plan? (Y/n)
```

Implementation notes
- Python-only initial implementation; Node/Go parity will follow after behavior stabilizes
- Packaged assets are loaded via `importlib.resources`; local overrides can be used for iteration
- Provider/model defaults: shell and run honor `~/.prompd/config.yaml` (`default_provider`, `default_model`)
- Meta overrides: `--meta:{section}` supported for execution (system/user/context/response or custom sections)

## Shell & Chat UI (Python)

- Chat panels: user messages (bright cyan), assistant messages (dark blue) with a single token line per turn
- Status footer: provider/model + session token totals printed discreetly after each turn
- Natural language intents: compile/show/validate/list, provider status/switch, prompt creation, and light file ops
- Defaults honored: resolves `default_provider`/`default_model` from config when flags are omitted
- Meta overrides: `--meta:{section}` at runtime for surgical edits (system/user/context/response or custom sections)
- Performance: registry discovery is lazy; shell pings in background after startup and never blocks input

Chat UI behaviors
- Input rendering: your message appears in a cyan “You” panel; assistant replies render in a dark blue panel
- Token usage: prints “Tokens this turn: prompt+completion=total | Session: P+C=T”; only shows when a provider call occurred
- Status footer: shows `[provider/model] | Tokens: P+C=T` after each turn for quick situational awareness
- Suggest/confirm: on ambiguous requests the assistant proposes a command (e.g., “provider status”); replying “yes” executes it
- Fuzzy show: `show <name>` suggests closest `.prmd` names and prints a brief prompt list when no exact match is found
- Creation flow: “help me create a new prompd …” or “create a prompd named …” previews a generated template and asks to confirm
- Explain intent: “what is a prompd” (and similar) replies with a concise primer instead of trying to open a file
- LLM fallback: when intent is unclear and not a simple command, the request is forwarded to the configured provider and the reply is displayed

Supported chat commands (quick reference)
- `compile <file.prmd> [key=value …]` – compile with inline params
- `show <file.prmd>` – show summary + parameters
- `validate <file|package>` – validate prompt or .pdpkg
- `list` – brief prompt list in current directory
- `provider status` / `switch provider <openai|anthropic|ollama>` – manage providers
- `cd <path>` / `cat <file>` / `open <file>` – basic navigation
- `chat` / `/exit` / `/clear` – switch modes and control chat

Provider & defaults
- Provider: CLI flag → `default_provider` → first provider with an API key (openai|anthropic|ollama)
- Model: CLI flag → `default_model` → sensible provider default (openai=gpt‑3.5‑turbo, anthropic=claude‑3‑haiku‑20240307)
- The chat prompt and planner/exec paths honor these defaults consistently

Notes
- Hidden/dotfiles are excluded from fuzzy suggestions and brief lists
- The shell avoids printing giant directory listings (home dir edge case) and prefers short, actionable output
- The input prompt no longer prints an inline “You:” label; only the cyan panel displays your message

Quick tips
```text
chat                          # enter chat mode
help me create a new prompd   # routes to creation preview and confirmation
manage providers              # shows provider status, offers quick switch
show api-builder              # shows details or suggests closest match + brief prompt list
```

## MCP Server (Python)

Serve `.prmd`/`.pdflow` over HTTP with simple MCP‑style endpoints.

- CLI:
  - `prompd mcp serve <path> [--host 0.0.0.0 --port 3333 --oauth-client-id … --auth-url … --token-url … --scopes …]`
- Endpoints (JSON):
  - `GET /health` → `{ status, file }`
  - `GET /validate` → validate the file
  - `GET /compile?to=markdown&params=…` → compiled result
  - `POST /run { provider, model, params, meta, version }` → execute and return `{ content, usage, model }`
- Auth: optional bearer presence check when OAuth flags supplied (extendable to JWT validation)
- Defaults/meta: honors `~/.prompd/config.yaml` & meta section overrides (system/user/context)

Install extras (local):
```bash
pip install -e .[mcp]            # from prompd-cli/cli/python
prompd mcp serve ./prompt.prmd --port 3333
```

## Docker Scaffold (Python MCP)

Generate Dockerfile + Compose with one command:
```bash
prompd mcp dockerize
docker compose -f docker-compose.prmd-mcp.yml up --build
```

What it does
- Builds an image that installs `prompd[mcp]`, exposes port 3333, and serves any mounted `/data/*.prmd` or `.pdflow`
- Mount `./prompds:/data`; set `OPENAI_API_KEY` (and/or `ANTHROPIC_API_KEY`)

## Configuration

`~/.prompd/config.yaml`
```yaml
default_provider: openai
default_model: gpt-4o
api_keys:
  openai: sk-...
  anthropic: sk-ant-...
registry:
  default: prompdhub
  registries:
    prompdhub:
      url: https://registry.prompdhub.ai
      token: null
      username: null
```

Resolution order
- Provider: CLI flag → `default_provider` → first provider with API key (openai|anthropic|ollama)
- Model: CLI flag → `default_model` → sensible provider default

## Packaging & Assets

- Python bundles planner prompts under `prompd/assets/prompts/**` and loads via `importlib.resources`
- Local overrides: prefer local files when present; fall back to packaged assets for stability
- Node/Go parity: will embed/copy assets (Go `//go:embed`, Node `files` in `package.json`) after Python stabilizes

## Package Manifest (manifest.json)

Every `.pdpkg` archive must include a root‐level `manifest.json`. The CLI validates this before publish/install.

Required fields
- `name` (string): package identifier (may include scope, e.g. `@org/security-toolkit`)
- `version` (string): semantic version `x.y.z`
- `description` (string): short description for discovery

Common optional fields
- `id` (string): stable internal ID (if different from `name`)
- `author` (string)
- `type` (string): typically `"package"`
- `files` (object): optional file index, e.g. lists of prompts/contexts
- `dependencies` (object): `{ "@scope/pkg": "^1.2.3" }`
- `exports` (object): logical entrypoints (e.g., `{ "default": "prompts/main.prmd" }`)
- `metadata` (object): freeform, publisher‑defined keys

Example manifest.json
```json
{
  "name": "@prompd.io/security-toolkit",
  "version": "1.0.1",
  "description": "Security audit components for code, API, and infrastructure",
  "author": "Logikbug",
  "type": "package",
  "files": {
    "prompts": [
      "prompts/security-audit.prmd",
      "prompts/owasp-checklist.prmd"
    ],
    "contexts": [
      "docs/owasp-top-10.md"
    ]
  },
  "dependencies": {
    "@prompd.io/core-patterns": "^2.0.0"
  },
  "exports": {
    "default": "prompts/security-audit.prmd"
  }
}
```

Validation & safety
- The CLI checks for `manifest.json`, required fields, and a valid semantic version
- ZIP slip prevention: all archive entries must be relative, no absolute or `..` traversal paths
- Recommended: deterministic archives (stable file ordering), exclude secrets (e.g., `.env*`, keys)

Create packages
```bash
# From .pdproj (sources next to .pdproj)
prompd package create ./engineering-prompts.pdproj

# From a directory (explicit metadata)
prompd package create ./composable-packages/security-toolkit \
  ./packages/@prompd.io-security-toolkit@1.0.1.pdpkg \
  --name @prompd.io/security-toolkit --version 1.0.1 \
  --description "Security audit components"

# Validate a .pdpkg
prompd package validate ./packages/@prompd.io-security-toolkit@1.0.1.pdpkg
```

## Registry Discovery & Performance

- Lazy discovery: registry & package resolver postpone `/.well-known` calls until needed
- Background ping: shell performs a non‑blocking discovery ping and prints a dim note if unreachable
- Full disable: `PROMPD_DISABLE_REGISTRY_DISCOVERY=true` for offline/CI

## Node/Go Parity Roadmap

- Planner & assets: package planner prompt; implement plan→preview→confirm→execute flow
- Chat UX: panelized output + token line; defaults/meta parity; status footer
- HTTP servers:
  - Node: `prompd-express` package exposing `compileRoute/runRoute/loadWorkflow`
  - Go: embedded assets + simple HTTP server exposing health/compile/run/validate

## Quickstarts

Python CLI
```bash
prompd compile prompds/code-implementation.prmd --to-markdown -o out.md
prompd run prompds/architecture-review.prmd --provider openai --model gpt-4o \
  --meta:context ./README.md -p system_component="Package Versioning"
```

Shell/Chat (Python)
```bash
prompd shell        # full UI
prompd chat         # start directly in chat
```

MCP Server
```bash
pip install -e .[mcp]
prompd mcp serve prompds/code-implementation.prmd --port 3333
# Docker
prompd mcp dockerize
docker compose -f docker-compose.prmd-mcp.yml up --build
```

## Examples

Minimal greeting prompt (.prmd)
```yaml
---
id: greeting
name: Greeting
version: 1.0.0
description: Generate a short, friendly greeting
parameters:
  - name: name
    type: string
    default: Steve
  - name: tone
    type: string
    default: friendly
---

# System
You create short, warm greetings.

# User
Write a {tone} greeting for {name}.
```

Compile and run
```bash
# Compile to markdown
prompd compile prompds/greeting.prmd --to-markdown -o greeting.md

# Run with defaults from ~/.prompd/config.yaml
prompd run prompds/greeting.prmd -p name="Alex" -p tone=formal --format json
```

Meta overrides at runtime
```bash
# Replace the System section with content from a file
prompd run prompds/greeting.prmd \
  --meta:system ./system-overrides.md \
  -p name=Jordan -p tone=casual
```

Story prompt (quick creation via chat)
```text
You: help me create a new prompd named time-twist that tells a story
Assistant: (shows preview)
You: yes, create time-twist.prmd
```

MCP: curl examples
```bash
# Health
curl http://localhost:3333/health

# Compile
# Option 1: readable with --get and --data-urlencode
curl --get "http://localhost:3333/compile" \
  --data-urlencode "to=markdown" \
  --data-urlencode 'params={"name":"Alex"}'

# Option 2: direct URL with encoded JSON
curl "http://localhost:3333/compile?to=markdown&params=%7B%22name%22%3A%22Alex%22%7D"

# Run
curl -X POST http://localhost:3333/run \
  -H "Content-Type: application/json" \
  -d '{
        "provider": "openai",
        "model": "gpt-4o",
        "params": {"name": "Alex", "tone": "friendly"},
        "meta": {"system": "You are a helpful greeter."}
      }'
```

Express-style usage (Node – upcoming package)
```js
// npm install prompd-express (planned)
const express = require('express');
const { loadWorkflow, compileRoute, runRoute } = require('prompd-express');

const app = express();
app.use(express.json());

const wf = loadWorkflow('./prompds/greeting.prmd');
app.get('/compile', compileRoute(wf, { format: 'markdown' }));
app.post('/run', runRoute(wf, { provider: 'openai', model: 'gpt-4o' }));

app.listen(3000, () => console.log('prompd-express on 3000'));
```

Go HTTP (planned)
```go
// Embed .prmd assets and expose /health, /compile, /run, /validate
// via net/http; parity after Python/Node stabilize.
```

## prompd.io

- Domain control: prompd.io
- Plan: host product docs and quickstarts at https://prompd.io with links to registry.prompdhub.ai
- Content to include:
  - 90‑second quickstart (install → compile → run)
  - Shell/chat overview (panels, tokens, footer)
  - MCP + Docker one‑liner
  - Link to examples and planner safety model

## Launch Checklist (Python‑first, then Node/Go)

Release artifacts
- [ ] PyPI: publish `prompd` and `prompd[mcp]` extra (version bump, wheels/sdist, README badges)
- [ ] Docker: build/push MCP image (tagged), include compose example (`prompds:/data` mount)
- [ ] Docs: mirror this ECOSYSTEM.md to registry.prompdhub.ai and prompd.io (Quickstart, Chat UI, Planner, MCP, Docker, Examples, Manifest)
- [ ] Examples: repo folder with ready‑to‑run `.prmd` and `params.json` (used in docs/screens)
- [ ] Screenshots/GIF: shell/chat panels, tokens/footer, planner preview/confirm, MCP curl

Quality gates
- [ ] run/compile/meta parity verified; defaults honored without flags
- [ ] Chat: no duplicate lines; token totals correct; footer shows provider/model and session tokens
- [ ] Planner (optional path): validates whitelist + paths; preview + confirm; cancels safely
- [ ] MCP: /health, /validate, /compile, /run work locally and in Docker
- [ ] Package validation: `manifest.json` checks; ZIP slip prevention; secrets excluded

Rollout plan
- [ ] Publish PyPI + Docker; tag release (e.g., v0.3.0), write concise release notes
- [ ] prompd.io landing: quickstart + one‑liners; link to registry docs and examples
- [ ] Announce: HN, r/programming, r/MachineLearning, X/LinkedIn (include GIF + examples)
- [ ] Invite early adopters for feedback (bugs, feature requests, integrations)

Parity (post‑launch)
- [ ] Node: `prompd-express` (compileRoute/runRoute/loadWorkflow); planner/assets packaging; chat UX parity
- [ ] Go: embed assets; add HTTP server endpoints; defaults/meta; basic REPL outputs
- [ ] Registry SDKs (optional): thin clients to call MCP endpoints from Node/Go

## Why this matters (and it already helps)

- Prompts as first‑class artifacts: composable, versioned, validated, portable across providers
- One mental model: write `.prmd` once; compile/run locally, in CI, or via MCP/HTTP
- Developer experience: chat UI that understands intent, panels for clarity, token transparency
- Safety: planner validation + confirm; meta overrides for surgical changes; registry/package integrity
- Speed: with defaults, a single CLI line runs everywhere; Docker + MCP makes deployment trivial

It’s already shaving time from routine tasks even before parity is complete. With docs, Docker, and MCP in place,
teams can adopt today while Node/Go catch up. Let’s ship it.


## Planner (optional) and Safety

- The packaged planner `.prmd` can convert natural language into a plan of safe CLI commands
- The CLI validates commands (whitelist) and paths (no absolute/.. traversal) before previewing and asking for confirmation
- You can favor LLM‑first or planner‑first flows; current shell defaults to LLM for unclear requests and uses suggestions/confirmations for simple command intents

## Startup & Registry Discovery

To minimize latency:
- Lazy discovery: registry and package resolver delay `/.well-known` calls until a registry/package command is used
- Background ping: the shell pings registry discovery after startup and prints a non-blocking note if unreachable
- Config override: set `PROMPD_DISABLE_REGISTRY_DISCOVERY=true` to fully suppress discovery in offline/CI runs

IDE Integration
- Invokes CLI for all operations (compile/run/validate/install/publish/search/list/cache info).
- Provides enhanced shell, preview panes, context selector, and quick fixes for validation errors.
- Uses local CLI cache for offline installs; surfaces registry capability info.

## Operational Contracts
- Errors: CLI surfaces registry errors using the JSON shape in `REGISTRY-API.md` with stable exit codes (1 internal, 2 user error).
- Telemetry: Optional; redact PII; off by default in OSS builds.
- Logging: CLI uses structured logs in verbose mode; IDE renders summaries.

## References
- REGISTRY-API.md
- prompd.md
