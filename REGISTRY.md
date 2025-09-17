# Prompd Registry HTTP API (v1)

> **⚠️ READ-ONLY**: This file is maintained by the documentation system. Do not edit directly unless you are the repository owner with override permissions.

Status: draft, minimal and stable-by-default. Uses canonical verbs (install|publish|list|search|cache via CLI), mapped to HTTP endpoints here.

## Overview
- Base URL: https://registry.prmd.ai
- API base path: /v1
- Content types: application/json (JSON), application/octet-stream (.pdpkg)
- Auth: Bearer token in `Authorization: Bearer <token>` with scopes
  - packages:read, packages:write, registry:admin
- Versioning: Semantic API versions per base path (v1). Minor additions are backward compatible.
- Rate limits: Standard 429 with `Retry-After` seconds header.
- Idempotency: `Idempotency-Key` header supported for publish.
- User-Agent: `prompd-cli/<version> (+<os>)`

## Error Format
All errors return JSON with a stable shape.

```json
{
  "error": "invalid_request",
  "message": "human readable detail",
  "request_id": "df9e5a1f-..."
}
```

## Capabilities

- GET /v1/capabilities
  - 200
  - Response:
    ```json
    {
      "api_version": "1.0",
      "features": ["publish", "search", "download", "signatures", "namespaces"],
      "auth_methods": ["pat", "oidc"],
      "limits": {"max_package_size": 104857600}
    }
    ```

## Packages

Identifiers:
- Package ID: `@scope/name` or `name` (unscoped)
- Version: SemVer `x.y.z`

Common package fields:
```json
{
  "id": "@prompd.io/security-toolkit",
  "name": "security-toolkit",
  "scope": "@prompd.io",
  "version": "1.0.1",
  "description": "Security audit components",
  "sha256": "<hex>",
  "size": 123456,
  "tags": ["security", "owasp"],
  "created_at": "2025-08-29T12:34:56Z",
  "signature": {"alg": "ed25519", "key_id": "kid-123", "sig": "base64"}
}
```

### Search
- GET /v1/packages?query=security&scope=@prompd.io&offset=0&limit=20
  - Auth: optional (public results). Private packages require `packages:read`.
  - 200
  - Response:
    ```json
    {
      "items": [{"id": "@prompd.io/security-toolkit", "latest": "1.0.1", "description": "..."}],
      "total": 3,
      "offset": 0,
      "limit": 20
    }
    ```

### List by namespace
- GET /v1/namespaces/{scope}/packages?offset=0&limit=50
  - 200 → same shape as search.

### Package metadata
- GET /v1/packages/{packageId}
  - 200
  - Response:
    ```json
    {
      "id": "@prompd.io/security-toolkit",
      "description": "...",
      "latest": "1.0.1",
      "versions": ["1.0.1", "1.0.0"],
      "tags": ["security", "owasp"]
    }
    ```

### Version metadata
- GET /v1/packages/{packageId}/versions/{version}
  - 200 → package fields for the specific version (see common fields).

### Download (.pdpkg)
- GET /v1/packages/{packageId}/versions/{version}/download
  - Headers: `Accept: application/octet-stream`
  - 200: binary stream
  - Response headers: `X-Checksum-Sha256: <hex>`, `Content-Length`

## Publish

- POST /v1/packages
  - Auth: `packages:write`
  - Content-Type: multipart/form-data
  - Parts:
    - `manifest` (application/json): minimal manifest
      ```json
      {
        "id": "@prompd.io/security-toolkit",
        "version": "1.0.1",
        "description": "...",
        "exports": ["prompts/security-audit.prmd"],
        "sha256": "<hex>"
      }
      ```
    - `package` (application/octet-stream): .pdpkg file
    - `signature` (application/json, optional):
      ```json
      {"alg": "ed25519", "key_id": "kid-123", "sig": "base64"}
      ```
  - Headers: optional `Idempotency-Key: <uuid>`
  - 201
  - Response:
    ```json
    {
      "id": "@prompd.io/security-toolkit",
      "version": "1.0.1",
      "published_at": "2025-08-29T12:34:56Z"
    }
    ```
  - Errors:
    - 409 if (id,version) already exists
    - 400 if invalid SemVer/manifest mismatch/checksum mismatch

## Cache and Health
- GET /v1/health → 200 `{ "status": "ok" }`
- GET /v1/time → 200 `{ "now": "2025-08-29T12:34:56Z" }`

## Auth Notes
- Recommended: PAT (personal access token) with scopes, or OIDC token exchange outside this API.
- CLI reads token from environment (e.g., `PROMPD_REGISTRY_TOKEN`) or config file.
- All state-changing requests require TLS; suggest TLS pinning support in clients.

## HTTP Examples

Search:
```bash
curl -s "https://registry.prmd.ai/v1/packages?query=security&scope=@prompd.io"
```

Download specific version:
```bash
curl -fL \
  -H "Accept: application/octet-stream" \
  "https://registry.prmd.ai/v1/packages/@prompd.io/security-toolkit/versions/1.0.1/download" \
  -o security-toolkit-1.0.1.pdpkg
```

Publish (multipart):
```bash
curl -f -X POST "https://registry.prmd.ai/v1/packages" \
  -H "Authorization: Bearer $PROMPD_REGISTRY_TOKEN" \
  -H "Idempotency-Key: $(uuidgen)" \
  -F manifest=@manifest.json;type=application/json \
  -F package=@security-toolkit-1.0.1.pdpkg;type=application/octet-stream \
  -F signature=@signature.json;type=application/json
```

## Mapping to CLI Verbs
- search → `prompd search <query>`
- list → `prompd list --scope @org`
- install (download) → `prompd install @scope/name@x.y.z`
- publish → `prompd publish <file.pdpkg>`
- cache info (client-side) → `prompd cache info` (not a server endpoint)

## Compatibility
- Canonical spec: This document is the authoritative v1 contract for the Prompd Registry.
- Deprecated spec: Any older OpenAPI files (for example, early scaffolds in the registry repository) are considered obsolete and must not be used for new client/server work.
- Future OpenAPI: A generated OpenAPI 3.1 file will be produced from this spec and published alongside the registry release; until then, treat this Markdown as source of truth.
