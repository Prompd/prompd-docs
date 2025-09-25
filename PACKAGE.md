# Prompd Package Management System

> **⚠️ READ-ONLY**: This file is maintained by the documentation system. Do not edit directly unless you are the repository owner with override permissions.

## Table of Contents
- [Overview](#overview)
- [Package Creation](#package-creation)
- [Package Validation](#package-validation)
- [Package Publishing](#package-publishing)
- [Package Installation](#package-installation)
- [Package Structure](#package-structure)
- [Working Examples](#working-examples)
- [Best Practices](#best-practices)
- [Troubleshooting](#troubleshooting)

## Overview

The Prompd package management system enables distribution and reuse of AI prompt templates through a registry-based ecosystem. Similar to npm for JavaScript or PyPI for Python, Prompd packages allow developers to share, version, and manage prompt components systematically.

### Key Features
- **Package Creation**: Bundle multiple `.prmd` files into distributable `.pdpkg` archives
- **Registry Distribution**: Publish packages to public or private registries
- **Dependency Management**: Install and manage package dependencies
- **Version Control**: Semantic versioning with dependency resolution
- **Namespace Support**: Scoped packages for organization and collision avoidance

### Package Formats
- **`.prmd`** - Individual prompt files (prompt markdown - renamed from `.prmd`)
- **`.pdpkg`** - Package archives (ZIP format with manifest)
- **`manifest.json`** - Package metadata and file listings

## Package Creation

### Using the CLI

Create packages from directories containing `.prmd` files:

```bash
# Create package from directory
prompd package create <source-directory> [output-file] [options]

# Example: Create from security toolkit directory
prompd package create "./security-toolkit" "security-toolkit-v1.0.0.pdpkg" \
  --name "Security Toolkit" \
  --version "1.0.0" \
  --description "Comprehensive security audit templates" \
  --author "Security Team"

# Create from current directory with auto-generated name
prompd package create . \
  --name "API Security Tools" \
  --version "2.1.0" \
  --description "API-specific security testing templates"
```

### Package Creation Options

```bash
Options:
  --name TEXT         Package name (required if no manifest.json)
  --version TEXT      Package version (required if no manifest.json) 
  --description TEXT  Package description
  --author TEXT       Package author/organization
  --help             Show help information
```

### Directory Structure for Package Creation

```
security-toolkit/
├── manifest.json           # Package metadata (optional - CLI can generate)
├── prompts/               # Main prompt files
│   ├── security-audit.prmd
│   ├── vulnerability-scan.prmd
│   └── penetration-test.prmd
├── templates/             # Base templates
│   └── analysis-framework.prmd
├── contexts/              # Context files
│   ├── owasp-top-10.md
│   └── security-checklist.json
├── systems/               # System personas
│   └── security-expert.md
└── README.md             # Package documentation
```

**Files Included in Package:**

### Native Safe Files (Stored As-Is)
- All `.prmd` files (prompt markdown - renamed from `.prmd`)
- All `.md` files (markdown documentation)
- All `.txt` files (plain text)
- All `.json`, `.yaml`, `.yml` files (structured data)
- All `.csv`, `.tsv` files (tabular data)
- `manifest.json` (generated if not present)
- Image files: `.png`, `.jpg`, `.jpeg`, `.gif` (for documentation)

### Package-Time File Conversion (Security Through Renaming)
All potentially executable or binary files are automatically converted to safe `.ext.txt` format during package creation:

#### Programming Language Files → `.ext.txt`
- **JavaScript**: `.js` → `.js.txt`, `.mjs` → `.mjs.txt`
- **TypeScript**: `.ts` → `.ts.txt`, `.tsx` → `.tsx.txt`
- **C#**: `.cs` → `.cs.txt`
- **C/C++**: `.c` → `.c.txt`, `.cpp` → `.cpp.txt`, `.h` → `.h.txt`, `.hpp` → `.hpp.txt`
- **Python**: `.py` → `.py.txt`
- **Go**: `.go` → `.go.txt`
- **Java**: `.java` → `.java.txt`
- **PHP**: `.php` → `.php.txt`
- **Ruby**: `.rb` → `.rb.txt`
- **Rust**: `.rs` → `.rs.txt`
- **Swift**: `.swift` → `.swift.txt`

#### Markup & Configuration Files → `.ext.txt`
- **Web**: `.html` → `.html.txt`, `.css` → `.css.txt`, `.xml` → `.xml.txt`
- **SVG**: `.svg` → `.svg.txt` (preserves vector data as text)
- **Sass/Less**: `.scss` → `.scss.txt`, `.sass` → `.sass.txt`, `.less` → `.less.txt`

#### Document Files → Text Extraction
- **PDF**: `.pdf` → `.pdf.txt` (text extracted from PDF)
- **Word**: `.docx` → `.docx.txt` (text extracted from document)
- **Excel**: `.xlsx` → multiple files: `filename-sheet1.csv`, `filename-sheet2.csv`, etc.
- **PowerPoint**: `.pptx` → `.pptx.txt` (text extracted from slides)

#### Benefits of This Strategy
- **Maximum Security**: No executable files can exist in packages
- **Maximum Context**: LLMs receive full source code and markup content
- **Self-Documenting**: Original format preserved in filename (`.js.txt`, `.cs.txt`)
- **Zero Execution Risk**: All content stored as safe text files

**Files Excluded:**
- `.pdproj` files (project metadata, not for distribution)
- `.git/` directories and files
- `node_modules/`, `.venv/`, etc.
- Temporary and cache files

## Package Validation

### Validating Packages

```bash
# Validate a package file
prompd package validate security-toolkit-v1.0.0.pdpkg

# Example output:
INFO Validating package: security-toolkit-v1.0.0.pdpkg
SUCCESS Package validation passed!
   Package: Security Toolkit
   Version: 1.0.0
   Description: Comprehensive security audit templates
   Files: 8 prompt files, 3 context files
```

### Validation Checks

1. **Archive Structure**
   - Valid ZIP file format
   - Contains `manifest.json`
   - File paths are safe (no directory traversal)

2. **Manifest Validation**
   - Required fields present (`name`, `version`, `description`)
   - Semantic versioning format
   - File listings are accurate

3. **Content Validation**
   - All `.prmd` files have valid YAML frontmatter
   - Parameter definitions are consistent
   - No circular inheritance dependencies

4. **Security Checks**
   - No malicious file paths
   - File size limits enforced
   - Package size within limits

## Package Publishing

### Authentication Setup

```bash
# Login to registry (interactive)
prompd login

# Login with API token
prompd login your-api-token-here

# Verify authentication
prompd config show
# Output shows current registry configuration and authentication status
```

### Publishing Packages

```bash
# Publish package to default registry
prompd publish security-toolkit-v1.0.0.pdpkg

# Example output:
SUCCESS Published Security Toolkit@1.0.0
  Registry: prompdhub
  Package URL: https://registry.prompdhub.ai/packages/@security/toolkit
  Download: https://registry.prompdhub.ai/@security/toolkit/-/toolkit-1.0.0.pdpkg

# Publish with dry-run (test without uploading)
prompd publish security-toolkit-v1.0.0.pdpkg --dry-run
# Output: DRY RUN: Would publish security-toolkit-v1.0.0.pdpkg

# Check if package name/version already exists
prompd versions @security/toolkit
# Output: Available versions: 1.0.0, 1.0.1, 1.1.0
```

### Publishing Requirements

1. **Authentication**: Must be logged in with valid credentials
2. **Unique Version**: Package version must not already exist
3. **Valid Package**: Must pass validation checks
4. **Permissions**: Must have publish rights to namespace (for scoped packages)

## Package Installation

### Installing Packages

```bash
# Install latest version
prompd install @security/toolkit

# Install specific version
prompd install @security/toolkit@1.0.0

# Install version range
prompd install "@security/toolkit@^1.0.0"  # Compatible versions (1.x.x)
prompd install "@security/toolkit@~1.0.0"  # Patch versions (1.0.x)

# Install to specific directory
prompd install @security/toolkit --target ./packages/

# Install with dependencies
prompd deps-install @security/toolkit  # Installs package + all dependencies
```

### Package Cache

```bash
# View cache information
prompd cache info
# Output:
# Cache location: ~/.prompd/cache/
# Cached packages: 15
# Total cache size: 2.3 MB

# List cached packages
prompd cache list
# Output:
# @security/toolkit@1.0.0
# @api/testing-framework@2.1.0
# @analysis/code-review@1.0.0

# Clear cache
prompd cache clear

# Clear specific package
prompd cache remove @security/toolkit@1.0.0
```

## Package Structure

### Manifest.json Format

```json
{
  "id": "@security/toolkit",
  "name": "Security Toolkit",
  "version": "1.0.0", 
  "description": "Comprehensive security audit templates with OWASP standards",
  "author": "@security-team",
  "license": "MIT",
  "tags": ["security", "audit", "owasp", "penetration-testing"],
  "categories": ["Security", "Testing", "Compliance"],
  "homepage": "https://security-tools.company.com",
  "repository": {
    "type": "git",
    "url": "https://github.com/company/security-toolkit"
  },
  "dependencies": {
    "@prompd.io/core-patterns": "^2.0.0",
    "@analysis/frameworks": "^1.2.0"
  },
  "exports": {
    "security-audit": "./prompts/security-audit.prmd",
    "vulnerability-scan": "./prompts/vulnerability-scan.prmd",
    "penetration-test": "./prompts/penetration-test.prmd",
    "analysis-base": "./templates/analysis-framework.prmd"
  },
  "files": {
    "prompts": [
      "prompts/security-audit.prmd",
      "prompts/vulnerability-scan.prmd", 
      "prompts/penetration-test.prmd"
    ],
    "templates": [
      "templates/analysis-framework.prmd"
    ],
    "contexts": [
      "contexts/owasp-top-10.md",
      "contexts/security-checklist.json"
    ],
    "systems": [
      "systems/security-expert.md"
    ]
  },
  "engines": {
    "prompd": ">=0.3.0"
  },
  "keywords": ["security", "owasp", "penetration-testing", "vulnerability"],
  "maintainers": [
    {
      "name": "Security Team",
      "email": "security@company.com"
    }
  ]
}
```

### Package Archive Structure

```
security-toolkit-v1.0.0.pdpkg (ZIP file)
├── manifest.json
├── prompts/
│   ├── security-audit.prmd
│   ├── vulnerability-scan.prmd
│   └── penetration-test.prmd
├── templates/
│   └── analysis-framework.prmd
├── contexts/
│   ├── owasp-top-10.md
│   └── security-checklist.json
├── systems/
│   └── security-expert.md
└── README.md
```

## Working Examples

### Example 1: Creating a Security Package

**Step 1: Prepare Directory Structure**
```bash
mkdir security-toolkit
cd security-toolkit
```

**Step 2: Create Base Template**
```yaml
# templates/security-base.prmd
---
id: security-base
name: "Security Analysis Base"
version: "1.0.0"
description: "Base template for security analysis tasks"
author: "@security-team"
parameters:
  - name: target_name
    type: string
    required: true
    description: "Name of the system being analyzed"
  - name: analysis_scope
    type: string
    enum: [basic, comprehensive, compliance]
    default: comprehensive
    description: "Scope of the security analysis"
---

# Security Analysis: {target_name}

## Analysis Scope: {analysis_scope}

You are conducting a security analysis of {target_name}. Follow industry best practices and provide detailed, actionable recommendations.

{% if analysis_scope %}
{% elif analysis_scope == "basic" %}
### Basic Security Review
- Review authentication mechanisms
- Check for common vulnerabilities
- Validate input handling
{% elif analysis_scope == "comprehensive" %}
### Comprehensive Security Assessment
- Complete threat modeling
- OWASP Top 10 evaluation
- Penetration testing approach
- Risk assessment and prioritization
{% elif analysis_scope == "compliance" %}
### Compliance-Focused Analysis
- Regulatory requirement verification
- Control effectiveness assessment
- Gap analysis and remediation planning
{% endif %}
```

**Step 3: Create Specialized Prompts**
```yaml
# prompts/web-security-audit.prmd
---
id: web-security-audit
name: "Web Application Security Audit"
version: "1.0.0"
description: "Comprehensive web application security assessment"
inherits: "../templates/security-base.prmd"
author: "@security-team"
tags: [web-security, owasp, audit]
context:
  - "../contexts/owasp-top-10.md"
parameters:
  - name: application_url
    type: string
    required: true
    pattern: "^https?://.+"
    description: "URL of the web application"
  - name: technology_stack
    type: string
    required: true
    description: "Technology stack used (e.g., 'React + Node.js + MongoDB')"
  - name: authentication_type
    type: string
    enum: [session-based, jwt, oauth2, custom]
    default: session-based
    description: "Type of authentication mechanism"
---

## Web Application Security Audit: {target_name}

### Application Details
- **URL**: {application_url}
- **Technology Stack**: {technology_stack}  
- **Authentication**: {authentication_type}

### OWASP Top 10 Assessment

Conduct systematic evaluation against OWASP Top 10 vulnerabilities:

1. **A01:2021 – Broken Access Control**
   - Test vertical and horizontal privilege escalation
   - Verify authorization controls on {application_url}
   - Check for direct object references

2. **A02:2021 – Cryptographic Failures**
   - Analyze encryption implementation in {technology_stack}
   - Review data transmission security
   - Validate certificate configuration

{% if authentication_type %}
{% elif authentication_type == "jwt" %}
3. **Authentication Security (JWT Focus)**
   - JWT token validation and signature verification
   - Token expiration and refresh mechanism review
   - Algorithm security assessment
{% elif authentication_type == "oauth2" %}
3. **Authentication Security (OAuth 2.0 Focus)**  
   - OAuth flow security assessment
   - Scope validation and privilege management
   - Authorization code security
{% else %}
3. **Authentication Security ({authentication_type})**
   - Authentication mechanism security review
   - Session management assessment
   - Password policy validation
{% endif %}

### Technology-Specific Testing

For {technology_stack} applications:
- Framework-specific vulnerability assessment
- Dependency security analysis  
- Configuration security review
- Performance and DoS testing

### Deliverables
- Executive summary with risk ratings
- Technical findings with proof-of-concept
- Prioritized remediation roadmap
- Security best practices recommendations
```

**Step 4: Add Context Files**
```markdown
# contexts/owasp-top-10.md
# OWASP Top 10 2021

## A01:2021 – Broken Access Control
Failures related to authorization. Common weaknesses include:
- Violation of the principle of least privilege
- Bypassing access control checks
- Metadata manipulation (JWT tokens, cookies)
- CORS misconfiguration

## A02:2021 – Cryptographic Failures  
Previously known as Sensitive Data Exposure. Focus on failures related to cryptography:
- Data transmitted in clear text
- Weak or deprecated cryptographic algorithms
- Weak random number generators
- Improper certificate validation

## A03:2021 – Injection
Application vulnerable to injection attacks including:
- SQL injection
- NoSQL injection
- OS command injection
- LDAP injection
```

**Step 5: Create Package**
```bash
# Create the package
prompd package create . security-toolkit-v1.0.0.pdpkg \
  --name "@security/toolkit" \
  --version "1.0.0" \
  --description "Comprehensive security audit templates with OWASP standards" \
  --author "@security-team"

# Validate package
prompd package validate security-toolkit-v1.0.0.pdpkg

# Output:
# SUCCESS Package validation passed!
#    Package: @security/toolkit
#    Version: 1.0.0
#    Description: Comprehensive security audit templates with OWASP standards
#    Files: 2 prompt files, 1 template file, 1 context file
```

**Step 6: Publish Package**
```bash
# Login to registry
prompd login

# Publish package
prompd publish security-toolkit-v1.0.0.pdpkg

# Output:
# SUCCESS Published @security/toolkit@1.0.0
#   Registry: prompdhub
#   Package URL: https://registry.prompdhub.ai/@security/toolkit
```

### Example 2: Using Published Packages

**Install and Use Package:**
```bash
# Install the security toolkit
prompd install @security/toolkit@1.0.0

# Check installation location
prompd cache info
# Package installed to: ~/.prompd/cache/@security/toolkit/1.0.0/

# Use package in new prompt
```

```yaml
# my-security-audit.prmd
---
id: my-security-audit
name: "Custom Security Audit"
inherits: "@security/toolkit@1.0.0/prompts/web-security-audit.prmd"
parameters:
  - name: custom_checks
    type: array
    items:
      enum: [api-security, mobile-security, cloud-security]
    default: [api-security]
    description: "Additional security checks to perform"
---

## Additional Security Checks

{% for item in custom_checks %}
### {item} Assessment
- Specialized testing for {item}
- Industry-specific best practices
{% endfor %}
```

**Compile with Package Dependencies:**
```bash
# Compile prompt with package inheritance
prompd compile my-security-audit.prmd \
  --to-markdown \
  -o audit-report.md \
  -p target_name="MyApp" \
  -p application_url="https://myapp.example.com" \
  -p technology_stack="React + Express + PostgreSQL"
```

## Best Practices

### Package Design

1. **Clear Structure**
   ```
   package/
   ├── prompts/          # Main prompt files
   ├── templates/        # Reusable base templates  
   ├── contexts/         # Data and reference files
   ├── systems/          # Personas and system messages
   └── README.md         # Usage documentation
   ```

2. **Meaningful Names**
   - Use scoped names: `@organization/package-name`
   - Descriptive package names: `@security/web-audit-toolkit`
   - Semantic versioning: `1.2.3` (major.minor.patch)

3. **Dependencies**
   - Minimize dependencies
   - Pin to specific major versions: `^1.0.0` (1.x.x compatible)
   - Document dependency requirements

4. **Documentation**
   - Include comprehensive README.md
   - Document all exported prompts
   - Provide usage examples
   - List prerequisites and requirements

### Version Management

1. **Semantic Versioning**
   - **Major** (1.0.0 → 2.0.0): Breaking changes, incompatible updates
   - **Minor** (1.0.0 → 1.1.0): New features, backward compatible
   - **Patch** (1.0.0 → 1.0.1): Bug fixes, no new features

2. **Version Strategy**
   ```bash
   # Development versions
   1.0.0-alpha.1    # Pre-release testing
   1.0.0-beta.1     # Feature-complete testing  
   1.0.0-rc.1       # Release candidate
   
   # Release versions
   1.0.0            # Stable release
   1.0.1            # Bug fix release
   1.1.0            # Feature release
   2.0.0            # Breaking change release
   ```

3. **Dependency Ranges**
   ```json
   {
     "dependencies": {
       "@prompd.io/core": "^2.0.0",      # 2.x.x compatible
       "@security/base": "~1.0.0",       # 1.0.x patch updates only
       "@analysis/tools": "1.2.3",       # Exact version
       "@utils/common": ">=1.0.0 <2.0.0" # Range specification
     }
   }
   ```

### Security Considerations

1. **Package Validation**
   - Always validate packages before publishing
   - Review dependencies for security issues
   - Check for sensitive data in package files

2. **Access Control**
   - Use scoped packages for organization control
   - Implement proper authentication for private registries
   - Regular security audits of published packages

3. **Content Security**
   - No hardcoded credentials or secrets
   - Validate all external references
   - Sanitize user inputs in templates

## Troubleshooting

### Common Package Creation Issues

**Error: "No .prmd files found"**
```bash
# Ensure directory contains .prmd files
find . -name "*.prmd"

# Create at least one .prmd file before packaging
```

**Error: "Invalid package name"**
```bash
# Package names must follow format:
# - Simple: "package-name" 
# - Scoped: "@scope/package-name"
# - Use kebab-case, no spaces or special characters
```

**Error: "Version already exists"**
```bash
# Check existing versions
prompd versions @scope/package-name

# Increment version number
prompd package create . new-package-v1.0.1.pdpkg --version "1.0.1"
```

### Publishing Issues

**Error: "Authentication required"**
```bash
# Login to registry
prompd login

# Or set API token
export PROMPD_REGISTRY_TOKEN=your-token-here
```

**Error: "Permission denied"**
```bash
# For scoped packages (@scope/name), you must have access to the scope
# Contact registry administrator or use different scope
```

**Error: "Package too large"**
```bash
# Check package size
ls -lh package.pdpkg

# Remove unnecessary files before packaging
# Package size limit is typically 10MB
```

### Installation Issues

**Error: "Package not found"**
```bash
# Verify package exists
prompd search package-name

# Check exact package name and version
prompd versions @scope/package-name
```

**Error: "Registry connection failed"**
```bash
# Check registry configuration
prompd config registry list

# Test connection  
curl -f https://registry.prompdhub.ai/health
```

**Error: "Cache corruption"**
```bash
# Clear cache and reinstall
prompd cache clear
prompd install @scope/package-name@version
```

### Package Usage Issues

**Error: "Package reference not found"**
```yaml
# Ensure package is installed
# Use exact path to file within package
inherits: "@security/toolkit@1.0.0/prompts/security-audit.prmd"

# Not just the package name
# inherits: "@security/toolkit@1.0.0"  # ❌ Wrong
```

**Error: "Circular dependency detected"**
```bash
# Check dependency tree
prompd deps my-prompt.prmd

# Remove circular references in inheritance chains
```

This package management system enables powerful distribution and reuse of AI prompt templates across teams and organizations.

## Real Working Examples

Practice package management with functional examples:
- **Complete Workflow**: `prompd-base/examples/CLI-USAGE-EXAMPLES.md`
- **API Development Package**: `prompd-base/examples/api-development.prmd`

```bash
# Create package from examples
cd prompd-base/examples
prompd package create . -o examples-toolkit.pdpkg

# Validate the package
prompd package validate examples-toolkit.pdpkg

# Test with actual examples directory
prompd validate examples/base-prompt.prmd
prompd validate examples/api-development.prmd

# Publish workflow (requires authentication)
prompd login
prompd publish examples-toolkit.pdpkg
```