# PrompdHub Registry API

> **Status**: Production-Ready (v1.0.0)
> **Last Updated**: January 2025
> **Base URL**: https://registry.prompdhub.ai

The PrompdHub Registry is the official package registry for AI workflow components (.prmd files). This document provides the complete API specification for integrating with the registry.

## Overview

- **Base URL**: `https://registry.prompdhub.ai`
- **API Format**: REST with JSON responses
- **Package Format**: `.pdpkg` (ZIP archives containing .prmd files)
- **Authentication**: Clerk OAuth + API tokens
- **Rate Limiting**: 100 requests/minute per IP
- **Content-Type**: `application/json` (metadata), `application/zip` (packages)

## API Discovery

All available endpoints are dynamically published via the registry discovery protocol:

```bash
GET /.well-known/registry.json
```

**Response:**
```json
{
  "name": "PrompdHub Registry",
  "version": "1.0.0",
  "description": "The GitHub for AI Workflows - Package registry for .prmd AI workflow components",
  "capabilities": {
    "formats": ["pdpkg"],
    "features": ["search", "versioning", "private-packages", "scoped-packages", "dist-tags"],
    "authentication": ["oauth", "api-token"]
  },
  "endpoints": {
    "packages": "/packages",
    "package": "/packages/{package}",
    "scopedPackage": "/packages/@{scope}/{package}",
    "download": "/packages/{package}/download/{version}",
    "downloadLatest": "/packages/{package}/download",
    "downloadWithVersion": "/packages/{package}@{version}",
    "publish": "/packages/{package}",
    "login": "/auth/login",
    "userInfo": "/auth/me",
    "tokens": "/auth/tokens"
  }
}
```

## Authentication

### API Tokens (Recommended for CLI)

1. **Create Token:**
```bash
POST /auth/tokens
Authorization: Bearer {clerk-jwt-token}
Content-Type: application/json

{
  "label": "My CLI Token"
}
```

**Response:**
```json
{
  "id": "token_123",
  "label": "My CLI Token",
  "token": "prompd_1234567890abcdef",
  "createdAt": "2025-01-22T10:30:00Z"
}
```

2. **Use Token:**
```bash
Authorization: Bearer prompd_1234567890abcdef
```

### OAuth via Clerk

For web applications, use Clerk OAuth integration. The CLI will redirect users to the web interface for authentication.

## Package Operations

### Search Packages

```bash
GET /packages?search={query}&limit={limit}&offset={offset}
```

**Parameters:**
- `search` (optional): Search query text
- `tags` (optional): Comma-separated tags
- `type` (optional): Package type filter
- `scope` (optional): Package scope filter
- `author` (optional): Package author filter
- `limit` (optional): Results per page (default: 20, max: 100)
- `offset` (optional): Pagination offset (default: 0)

**Response:**
```json
{
  "packages": [
    {
      "name": "prompd.io/security-toolkit",
      "scope": "@prompd.io",
      "version": "1.0.0",
      "description": "Security audit components",
      "tags": ["security", "owasp"],
      "type": "package",
      "downloads": 1542,
      "publishedAt": "2025-01-22T10:30:00Z"
    }
  ],
  "pagination": {
    "total": 25,
    "limit": 20,
    "offset": 0,
    "hasMore": true
  }
}
```

### Get Package Metadata

```bash
# Unscoped packages
GET /packages/{package}

# Scoped packages
GET /packages/@{scope}/{package}
```

**Example:**
```bash
GET /packages/@prompd.io/security-toolkit
```

**Response:**
```json
{
  "name": "prompd.io/security-toolkit",
  "description": "Security audit components",
  "version": "1.0.0",
  "tags": ["security", "owasp"],
  "type": "package",
  "downloads": 1542,
  "publishedAt": "2025-01-22T10:30:00Z",
  "files": [],
  "fileCount": 0,
  "owner": {
    "id": "user_123",
    "handle": "prompd-admin"
  }
}
```

### Get Package Versions

```bash
# Unscoped packages
GET /packages/{package}/versions

# Scoped packages
GET /packages/@{scope}/{package}/versions
```

**Response:**
```json
{
  "versions": [
    {
      "version": "1.0.0",
      "publishedAt": "2025-01-22T10:30:00Z",
      "description": "Security audit components",
      "downloads": 1542
    }
  ]
}
```

## Package Downloads

### Download Specific Version

```bash
# Unscoped packages
GET /packages/{package}/download/{version}

# Scoped packages
GET /packages/@{scope}/{package}/download/{version}
```

### Download Latest Version

```bash
# Unscoped packages
GET /packages/{package}/download

# Scoped packages
GET /packages/@{scope}/{package}/download
```

### Download with @version Syntax

```bash
# Unscoped packages
GET /packages/{package}@{version}

# Scoped packages
GET /packages/@{scope}/{package}@{version}
```

**Example:**
```bash
GET /packages/@prompd.io/security-toolkit@1.0.0
```

All download endpoints return:
- **Content-Type**: `application/zip`
- **Content-Disposition**: `attachment; filename="{package}-{version}.pdpkg"`
- Binary .pdpkg file content

## Package Publishing

### Publish Package

```bash
# Unscoped packages
PUT /packages/{package}

# Scoped packages
PUT /packages/@{scope}/{package}
```

**Headers:**
```
Authorization: Bearer {api-token}
Content-Type: application/octet-stream
```

**Body:** Binary .pdpkg file content

**Response (201 Created):**
```json
{
  "message": "Package published successfully",
  "package": "@prompd.io/security-toolkit",
  "version": "1.0.0",
  "published": true
}
```

### Unpublish Package

```bash
# Unscoped packages
DELETE /packages/{package}/-rev/{revision}

# Scoped packages
DELETE /packages/@{scope}/{package}/-rev/{revision}
```

## User & Organization Management

### Get Current User

```bash
GET /auth/me
Authorization: Bearer {token}
```

**Response:**
```json
{
  "id": "user_123",
  "handle": "johndoe",
  "username": "johndoe",
  "name": "John Doe",
  "avatarUrl": "https://..."
}
```

### Organizations

#### List Public Organizations
```bash
GET /organizations
```

#### Get User's Organizations
```bash
GET /user/organizations
Authorization: Bearer {token}
```

#### Create Organization
```bash
POST /organizations
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "My Organization",
  "description": "Organization description"
}
```

#### Organization Members
```bash
GET /organizations/{orgId}/members
Authorization: Bearer {token}
```

### Namespaces

#### List Namespaces
```bash
GET /namespaces
```

#### Get User's Namespaces
```bash
GET /user/namespaces
Authorization: Bearer {token}
```

#### Create Namespace
```bash
POST /namespaces
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "@my-namespace",
  "description": "Namespace description"
}
```

## Token Management

### List Tokens
```bash
GET /auth/tokens
Authorization: Bearer {clerk-jwt-token}
```

### Create Token
```bash
POST /auth/tokens
Authorization: Bearer {clerk-jwt-token}
Content-Type: application/json

{
  "label": "CLI Token"
}
```

### Delete Token
```bash
DELETE /auth/tokens/{tokenId}
Authorization: Bearer {clerk-jwt-token}
```

## System Endpoints

### Health Check
```bash
GET /health
```

**Response:**
```json
{
  "status": "ok"
}
```

### Login Information
```bash
POST /auth/login
```

**Response:**
```json
{
  "message": "Authentication is handled via Clerk OAuth",
  "loginUrl": "https://registry.prompdhub.ai/auth/clerk",
  "supportedMethods": ["oauth", "api-token"],
  "apiTokens": {
    "create": "/auth/tokens",
    "manage": "/auth/tokens",
    "documentation": "Use API tokens for CLI authentication"
  }
}
```

## Error Handling

All errors return JSON with consistent structure:

```json
{
  "error": "Error type",
  "message": "Human readable error message"
}
```

**Common HTTP Status Codes:**
- `200` - Success
- `201` - Created (for publish)
- `400` - Bad Request (invalid input)
- `401` - Unauthorized (missing/invalid token)
- `403` - Forbidden (insufficient permissions)
- `404` - Not Found (package/user not found)
- `409` - Conflict (package version already exists)
- `429` - Rate Limited
- `500` - Internal Server Error

## CLI Integration

The Prompd CLI uses these endpoints:

```bash
# Search packages
prompd search security

# Install packages
prompd install @prompd.io/security-toolkit
prompd install @prompd.io/security-toolkit@1.0.0

# Publish packages
prompd publish my-package.pdpkg

# Login and token management
prompd login
prompd logout
```

## Package Format

Packages are distributed as `.pdpkg` files (ZIP archives) containing:
- `.prmd` files (AI workflow components)
- `manifest.json` (package metadata)
- Optional assets and documentation

For complete package format specification, see [PACKAGE.md](PACKAGE.md).

## Rate Limiting

- **Limit**: 100 requests per minute per IP address
- **Headers**:
  - `X-RateLimit-Limit`: Request limit
  - `X-RateLimit-Remaining`: Remaining requests
  - `X-RateLimit-Reset`: Reset timestamp
- **Status**: 429 Too Many Requests when exceeded

## Examples

### Complete Package Workflow

1. **Search for packages:**
```bash
curl "https://registry.prompdhub.ai/packages?search=security"
```

2. **Get package details:**
```bash
curl "https://registry.prompdhub.ai/packages/@prompd.io/security-toolkit"
```

3. **Download package:**
```bash
curl -L "https://registry.prompdhub.ai/packages/@prompd.io/security-toolkit/download/1.0.0" \
     -o security-toolkit-1.0.0.pdpkg
```

4. **Publish new package:**
```bash
curl -X PUT "https://registry.prompdhub.ai/packages/@my-org/my-package" \
     -H "Authorization: Bearer prompd_your_token_here" \
     -H "Content-Type: application/octet-stream" \
     --data-binary @my-package-1.0.0.pdpkg
```

## Version History

- **v1.0.0** (January 2025) - Production release with complete API coverage
- Full backward compatibility maintained
- All endpoints tested and documented

---

**Note**: This documentation reflects the actual implementation of registry.prompdhub.ai. For SDK and library development, see [PROMPD-API.md](PROMPD-API.md).