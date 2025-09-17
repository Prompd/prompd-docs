# Prompd Domain Registry Architecture

## Overview

Prompd uses a comprehensive domain-based registry architecture that supports every deployment scenario from individual developers to enterprise on-premises installations. The system uses RFC 8615 compliant `.well-known/registry.json` discovery for seamless registry resolution.

## Registry Discovery Pattern

All registry discovery follows the `.well-known/registry.json` standard:

```
{domain}/.well-known/registry.json → {actual-registry-endpoint}
```

This enables flexible hosting, migration paths, and enterprise customization while maintaining a consistent client experience.

## Deployment Models

### 1. Public Community Registry

**Primary Domain**: `prompdhub.ai` or `registry.prompdhub.ai`

```
prompdhub.ai/.well-known/registry.json → registry.prompdhub.ai
```

**Package Patterns**:
- `registry.prompdhub.ai/@public/package` - Free community packages
- `registry.prompdhub.ai/@prompd.io/package` - Official Prompd packages

**Use Case**: Open source community, public package sharing

### 2. Professional Private Scopes

**Domain**: `registry.prompdhub.ai` 

```
registry.prompdhub.ai/.well-known/registry.json → registry.prompdhub.ai
```

**Package Patterns**:
- `registry.prompdhub.ai/@company/package` - Private company scope
- `registry.prompdhub.ai/@username/package` - Individual private packages

**Use Case**: Small teams, startups, individual developers with private packages

### 3. Enterprise Hosted (SaaS)

**Domain**: `company.prompdhub.ai`

```
company.prompdhub.ai/.well-known/registry.json → company.prompdhub.ai
```

**Package Patterns**:
- `company.prompdhub.ai/@department/package` - Department-scoped packages
- `company.prompdhub.ai/package` - **Auto-scoped to `@company/package`**

**Use Case**: Enterprise customers who want dedicated infrastructure but SaaS management

### 4. Enterprise On-Premises

**Domain**: `company.prompdhub.ai` (discovery) → `registry.company.com` (actual registry)

```
company.prompdhub.ai/.well-known/registry.json → registry.company.com
```

**Package Patterns**:
- `registry.company.com/@department/package` - Internal department packages  
- `registry.company.com/package` - **Auto-scoped to `@company/package`**

**Use Case**: Enterprises with strict data governance, air-gapped environments

## Auto-Scoping Behavior

### Enterprise Default Scoping

When using enterprise registries (`company.prompdhub.ai` or `registry.company.com`):

```bash
# User installs
prompd install security-toolkit

# System resolves to  
@company/security-toolkit
```

**Benefits**:
- Eliminates scope confusion
- Prevents accidental public package conflicts
- Maintains consistency across deployment models
- Simplifies enterprise package management

### Explicit Scoping Override

Users can always specify explicit scopes:

```bash
prompd install @department/security-toolkit  # Department scope
prompd install @public/common-utils          # Public package (if cross-registry enabled)
```

## Cross-Registry Package Resolution

### Enhanced Registry Discovery

Enterprise registries can specify fallback registries for accessing public packages:

```json
{
  "registry": "https://company.prompdhub.ai",
  "fallbacks": ["https://registry.prompdhub.ai"],
  "scopes": {
    "@company": "https://company.prompdhub.ai",
    "@department": "https://company.prompdhub.ai", 
    "@public": "https://registry.prompdhub.ai",
    "@prompd.io": "https://registry.prompdhub.ai"
  }
}
```

**Resolution Logic**:
1. Check local registry for package
2. If not found, check fallback registries
3. Respect scope-specific registry mappings
4. Cache resolution results

## Business Model Alignment

### Tier Structure

| Tier | Registry | Package Types | Features |
|------|----------|---------------|----------|
| **Free** | `registry.prompdhub.ai` | `@public/*` packages only | Community packages, public search |
| **Professional** | `registry.prompdhub.ai` | `@company/*` private scopes | Private packages, team sharing |
| **Enterprise SaaS** | `company.prompdhub.ai` | All private, auto-scoped | Dedicated subdomain, SSO, analytics |
| **Enterprise On-Prem** | `registry.company.com` | All private, air-gapped | Full control, compliance, security |

### Migration Paths

**Free → Professional**: Add private scope to same registry
**Professional → Enterprise SaaS**: DNS change + data migration
**Enterprise SaaS → On-Prem**: Registry software deployment + sync

## Implementation Details

### CLI Configuration

The CLI automatically handles registry discovery:

```yaml
# ~/.prmd/config.yaml
registries:
  default: company.prompdhub.ai
  registries:
    company.prompdhub.ai:
      url: https://company.prompdhub.ai  # Resolved from .well-known
      token: prompd_...
      username: user_...
```

### Registry Discovery Process

1. **Parse Package Reference**: `@scope/package@version`
2. **Determine Registry Domain**: Based on scope or default
3. **Fetch `.well-known/registry.json`**: Get actual registry endpoint
4. **Cache Discovery**: Store mapping for future requests
5. **Resolve Package**: Use actual registry endpoint

### Domain Validation

**Valid Registry Domains**:
- `*.prompdhub.ai` (managed SaaS)
- `registry.*.com` (enterprise on-prem)
- `npm.*.com` (npm-compatible enterprise)

**Security Considerations**:
- HTTPS required for all registry communication
- Domain ownership verification for enterprise subdomains
- Rate limiting per domain/organization
- API token scope validation

## Example Scenarios

### Startup Team
```bash
# Initial setup with professional plan
prompd configure registry registry.prompdhub.ai
prompd login

# Install public community package
prompd install @public/core-patterns

# Create private team package
prompd publish @acme/internal-tools
```

### Enterprise Migration
```bash
# Step 1: Professional tier
prompd install @acme/internal-tools

# Step 2: Enterprise SaaS (DNS change triggers migration)
prompd configure registry acme.prompdhub.ai
prompd install internal-tools  # Auto-scoped to @acme/internal-tools

# Step 3: On-premises (registry.json points to internal)
# No CLI changes needed - discovery handles routing
```

### Department Isolation
```bash
# Security team registry
company.prompdhub.ai/@security/threat-detection

# Engineering team registry  
company.prompdhub.ai/@engineering/code-review

# Company-wide registry
company.prompdhub.ai/common-utils  # → @company/common-utils
```

## Standards Compliance

### RFC 8615 Well-Known URIs
- Full compliance with `.well-known/registry.json`
- Cacheable discovery responses
- HTTP redirect support for registry migrations

### NPM Compatibility
- Package metadata follows npm registry API
- Semantic versioning (semver) compliance
- Compatible authentication patterns

### Container Registry Patterns
- Domain-based routing like Docker registries
- Hierarchical namespace support
- Enterprise-grade access controls

## Future Enhancements

### Federated Package Search
- Cross-registry package discovery
- Unified search across public and private packages
- Relevance ranking with access controls

### Advanced Enterprise Features
- SAML/OIDC integration for SSO
- Audit logging and compliance reports
- Package vulnerability scanning
- License compliance tracking

### Registry Mirroring
- Multi-region registry replicas
- Automatic failover and load balancing
- Offline/air-gapped registry synchronization

---

This domain architecture provides a **comprehensive, scalable, and standards-compliant** foundation for Prompd's registry ecosystem, supporting every deployment scenario from individual developers to global enterprises.