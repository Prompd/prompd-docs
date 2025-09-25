# editor.prompdhub.ai — Design Doc (MVP → v1)

## Vision

A web editor for `.prmd` and `.pdflow` files with seamless validate/compile/run and registry integration. Opens any package asset directly from the registry, provides safe previews, and streamlines publish workflows.

## Goals (MVP)

- Edit `.prmd`/`.pdflow` with syntax help and schema hints
- Validate/compile/run via backend that wraps `prompd` CLI (Python-first)
- Session-scoped package cache and context uploads
- Registry browse/search and one-click “Open in Editor”
- Publish with manifest checks and preview

## Non‑Goals (MVP)

- Real-time multiuser collaboration
- Rich Git integrations beyond basic file import/export
- Custom model fine-tuning or provider account management

## Personas & Key Flows

- Author: iterates a prompt, validates, runs with params/context, and publishes
- Reviewer: opens from registry, compiles to markdown, inspects diffs, leaves comments (v1+)
- Consumer: searches packages, previews, and tests via run without editing

## Architecture Overview

- Frontend: Next.js/Vite + Monaco editor; Zod for form/params validation; Web Worker for linting
- Backend: Python FastAPI (or Flask) wrapping `prompd` CLI; WebSocket for stream output
- Registry Integration: calls `REGISTRY-API.md` endpoints (search/list/install/publish)
- Capability Negotiation: fetch registry `/v1/capabilities` and backend `prompd --version --features`
- MCP Bridge: optional; proxy to `prompd mcp serve` when enabled for remote runs

## Backend API (Editor Service)

Auth: Bearer token (registry PAT) for publish; LLM provider keys sent per request and never persisted.

- GET /health → { status, version }
- GET /capabilities → { prompd: { version, features }, registry: {...} }
- POST /validate { file, content } → { ok, errors[] }
- POST /compile { file, content, to, params, meta, version } → { ok, result, warnings?, usage? }
- POST /run { file, content, provider, model, params, meta, version } → { ok, content, usage, model }
- WS /run/stream → server streams tokens and usage updates
- POST /packages/install { name@version } → { ok, cachePath }
- GET /packages/search?q=term → passthrough to registry
- GET /packages/:name/versions → passthrough
- POST /packages/publish { artifact, token } → { ok, id, url }

Notes
- `file` is a virtual path shown in UI; `content` is authoritative
- `meta` supports `system/user/context/response` per ECOSYSTEM.md
- `to` supports `markdown`, `json`, `raw` (extend as CLI supports)

## Safety & Privacy

- Planner preview/confirm for “natural language → commands”; whitelist: compile, show, validate, list, provider_status, provider_switch, mkdir, create_file, move, copy
- Path policy: forbid absolute paths and `..` traversal; restrict to workspace/session roots
- Large file guard: context upload size limit with friendly errors
- Secrets: never persist provider API keys; keep only in encrypted session storage
- Transport: HTTPS; HSTS; CSRF protection for same-site ops

## Editor UX

- Monaco with `.prmd` grammar, lint markers, and format-on-save (optional)
- Split view: source | preview (validate/compile/run)
- Params panel: derived from `parameters` schema; supports JSON import/export
- Context manager: attach/remove files; shows effective meta and overrides
- Token footer: provider/model, per-turn tokens, session totals

## Registry UX

- Search/browse with install/open buttons
- “Open in Editor” deep link from registry UI
- Publish flow: artifact preview → manifest validation → confirm → publish → link to package page

## Deep Links

- Open package asset: `/open?pkg=@scope/pkg@1.2.3&path=prompts/x.prmd`
- New from template: `/new?template=greeting`
- Import GitHub: `/import?repo=owner/repo&path=prompds/x.prmd`

## Config & Defaults

- Backend honors `~/.prompd/config.yaml` defaults for provider/model
- Env vars: `OPENAI_API_KEY`, `ANTHROPIC_API_KEY` (optional, per-request preferred)
- Discovery: lazy registry capability fetch; can be disabled for offline/CI

## Domains & Naming

- Primary apps:
  - editor.prompdhub.ai: web editor for .prmd/.pdflow (MVP)
  - registry.prompdhub.ai: package browsing, search, publish
  - api.prompdhub.ai: shared backend APIs (registry/editor as needed)
  - docs.prmd.io: public docs/marketing (keep apex prompd.io minimal)
- Reserved/future:
  - studio.prompdhub.ai: umbrella workspace when tools unify (editor/designer/playground)
  - designer.prompdhub.ai: visual composition/graph editor (v1+)
  - playground.prompdhub.ai: quick run/try without persistence
  - lab.prompdhub.ai: experimental features/early access
  - id.prompdhub.ai: auth/SSO (OIDC provider)
- Environments:
  - editor.dev.prompdhub.ai, editor.stg.prompdhub.ai, pr-<num>.editor.stg.prompdhub.ai
  - Same pattern for registry/api/id subdomains

## Deployment (MVP)

Docker Compose (sketch)
```yaml
services:
  editor:
    image: promd/editor:latest
    ports: ["3000:3000"]
    environment:
      - REGISTRY_URL=https://registry.prompdhub.ai
    depends_on: [api]
  api:
    image: promd/editor-api:latest
    ports: ["3333:3333"]
    volumes:
      - ./cache:/app/cache
      - ./workspace:/app/workspace
```

## Ingress & DNS

- DNS:
  - Create A/AAAA or CNAME records for editor., registry., api., id., docs.
  - Wildcards for ephemeral envs (e.g., *.editor.stg.prompdhub.ai) if supported
- TLS:
  - ACM/Let’s Encrypt wildcard cert for *.prompdhub.ai (plus apex) or SAN per subdomain
  - HSTS on apex and subdomains; redirect http→https at edge
- Ingress (Kubernetes example):
  - NGINX/Traefik Ingress with host-based routing to services (editor, api, registry)
  - WebSocket support for /run streams; proxy timeouts tuned for LLM latency
  - Request size limits on API for context uploads (e.g., 10–25 MB), 413 handling
- Security:
  - Cookies scoped per-subdomain; editor gets short-lived tokens from id.
  - CORS restricted to known subdomains; CSRF on same-site state-changing routes
  - Rate limiting and per-session quotas on /run to prevent abuse

## Milestones

- M1 (MVP): editor, validate/compile/run, registry search/open, publish
- M2: diffs, version compare, dependency graph, params presets
- M3: comments, shareable previews, role-based access for teams
- M4: MCP sandbox runs, offline cache, install/publish analytics

## Open Questions

- Do we require SSO for read-only runs, or allow anonymous with local keys?
- Preferred backend: FastAPI vs Flask (streaming ease + typing suggests FastAPI)
- Storage limits and retention for session cache and context files

## Risks

- Provider key handling must be airtight; avoid accidental server-side persistence
- Running arbitrary prompts increases resource variance; implement quotas and per-session limits
- Registry coupling: ensure graceful degradation when registry is unreachable

## References

- See `prompd-docs/ECOSYSTEM.md` for capabilities, security, MCP, and packaging
- See `prompd-docs/REGISTRY-API.md` for registry contracts
- See `prompd-docs/FORMAT.md` for .prmd format and meta sections
