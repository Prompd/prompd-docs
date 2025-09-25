# Prompd File Format Specification

> **⚠️ READ-ONLY**: This file is maintained by the documentation system. Do not edit directly unless you are the repository owner with override permissions.

## Table of Contents
- [Overview](#overview)
- [File Structure](#file-structure)
- [YAML Frontmatter](#yaml-frontmatter)
- [Markdown Content](#markdown-content)
- [Template Syntax](#template-syntax)
- [Working Examples](#working-examples)
- [Validation Rules](#validation-rules)
- [Best Practices](#best-practices)

## Overview

Prompd files (`.prmd`) are structured prompt definitions that combine YAML frontmatter with Markdown content. They enable parameterized, versionable, and reusable AI prompts with inheritance and composition capabilities.

### Key Features
- **YAML Frontmatter**: Structured metadata and parameters
- **Markdown Content**: Human-readable prompt template
- **Parameter Substitution**: Jinja2 templating with single braces (`{parameter}`)
- **Inheritance**: Extend other templates via `inherits` field
- **Package References**: Import from registry packages
- **Context Files**: Include external data sources
- **Validation**: Built-in parameter type checking and constraints

## File Structure

Every `.prmd` file follows this structure:

```
---
# YAML Frontmatter (required)
id: unique-prompt-identifier
name: "Human Readable Name"
version: 1.0.0
description: "Brief description of what this prompt does"
parameters:
  - name: parameter_name
    type: string
    required: true
# ... other metadata fields
---

# Markdown Content (optional if all content is in YAML fields)
Your prompt content with {parameter_name} substitution...
```

## YAML Frontmatter

### Required Fields

#### `id` (string, required)
Unique identifier for the prompt. Used for referencing and inheritance.

```yaml
id: security-audit
id: code-review-comprehensive
id: data-analysis-pipeline
```

**Rules:**
- Must be unique within its scope
- Use kebab-case or snake_case
- No spaces or special characters except hyphens and underscores
- Maximum 64 characters

#### `name` (string, required)
Human-readable name for the prompt.

```yaml
name: "Security Audit Template"
name: "Comprehensive Code Review"
name: "Data Analysis Pipeline"
```

### Core Optional Fields

#### `version` (string)
Semantic version number (major.minor.patch).

```yaml
version: "1.0.0"
version: "2.1.3"
```

#### `description` (string)
Brief description of the prompt's purpose.

```yaml
description: "Performs comprehensive security audit using OWASP standards"
description: "Reviews code for security vulnerabilities and best practices"
```

#### `author` (string)
Author or organization name.

```yaml
author: "@prompd.io"
author: "Security Team"
author: "jane.doe@company.com"
```

### Parameters

The `parameters` array defines input variables for the prompt:

```yaml
parameters:
  - name: application_name
    type: string
    required: true
    description: "Name of the application being analyzed"
  
  - name: technology_stack
    type: string
    required: true
    description: "Technology stack (e.g., 'React + Node.js + PostgreSQL')"
    
  - name: audit_scope
    type: string
    enum: [basic, comprehensive, compliance]
    default: comprehensive
    description: "Scope of the audit to perform"
    
  - name: compliance_requirements
    type: array
    items:
      enum: [SOC2, PCI-DSS, HIPAA, GDPR, SOX]
    required: false
    description: "Specific compliance frameworks to evaluate"
    
  - name: confidence_threshold
    type: number
    minimum: 0.0
    maximum: 1.0
    default: 0.8
    description: "Minimum confidence level for findings"
```

#### Parameter Types

**String Parameters:**
```yaml
- name: input_text
  type: string
  required: true
  minLength: 10
  maxLength: 1000
  pattern: "^[a-zA-Z0-9\\s]+$"  # Regex validation
```

**Number Parameters:**
```yaml
- name: temperature
  type: number
  minimum: 0.0
  maximum: 2.0
  default: 0.7
  
- name: max_tokens
  type: integer
  minimum: 1
  maximum: 4096
  default: 2000
```

**Boolean Parameters:**
```yaml
- name: include_examples
  type: boolean
  default: true
```

**Array Parameters:**
```yaml
- name: target_languages
  type: array
  items:
    type: string
    enum: [javascript, python, java, go, rust]
  minItems: 1
  maxItems: 5
  default: [javascript]
```

**Object Parameters:**
```yaml
- name: model_config
  type: object
  properties:
    provider:
      type: string
      enum: [openai, anthropic, ollama]
    model:
      type: string
    temperature:
      type: number
  required: [provider, model]
  default:
    provider: openai
    model: gpt-4o
    temperature: 0.7
```

**Enum Parameters:**
```yaml
- name: output_format
  type: string
  enum: [markdown, json, xml, yaml]
  default: markdown
```

### Inheritance

#### `inherits` (string)
Path to parent template to inherit from.

```yaml
# Local file inheritance
inherits: "./base-security-audit.prmd"
inherits: "../templates/analysis-base.prmd"

# Package inheritance (must be quoted)
inherits: "@prompd.io/security-toolkit@1.0.0/prompts/base-audit.prmd"
```

#### `override` (object)
Section-based content overrides for inherited templates. Provides precise control over which sections are replaced, removed, or preserved from the parent template.

```yaml
override:
  system-prompt: "./custom-system-prompt.md"     # Replace section with file content
  examples: "./domain-specific-examples.md"     # Replace section with file content
  legacy-section: null                          # Remove section completely
  # Sections not mentioned are preserved from parent
```

**Key Features:**
- **Section IDs**: Must use kebab-case format (lowercase, hyphens only)
- **File References**: Relative paths to content files containing replacement content
- **Section Removal**: Set to `null` to remove sections entirely
- **Selective Override**: Only specified sections are affected, others preserved
- **File Types**: Supports all file types supported by the extraction system (markdown, text, JSON, YAML, PDF, Excel, etc.)

**Section ID Discovery:**
```bash
# Discover available section IDs for override
prompd show parent-template.prmd --sections
```

**Complete Documentation**: See [SECTION-OVERRIDE.md](./SECTION-OVERRIDE.md) for comprehensive examples and usage patterns.

### Context and References

#### `context` (array)
External files to include as context.

```yaml
context:
  - "./threat-model.md"
  - "../data/owasp-top-10.json"
  - "@prompd.io/security@1.0.0/contexts/security-checklist.md"
```

#### `system` (string)
System message or persona definition.

```yaml
system: "You are a senior security engineer with 15+ years of experience"
system: "./personas/security-expert.md"
system: "@prompd.io/personas@1.0.0/experts/cybersecurity.md"
```

#### `assistant` (string)
Assistant personality or role definition.

```yaml
assistant: "You are a helpful assistant specializing in code analysis"
assistant: "./roles/code-reviewer.md"
```

### Advanced Fields

#### `using` (array)
Package dependencies with optional aliases.

```yaml
using:
  - name: "@prompd.io/api-toolkit@1.2.1"
    prefix: "@api"
  - name: "@prompd.io/security-patterns@2.0.0"
    prefix: "@security"
```

#### `tags` (array)
Searchable tags for categorization.

```yaml
tags: [security, audit, owasp, compliance]
```

#### `categories` (array)
Hierarchical categories.

```yaml
categories: ["Security", "Code Analysis", "Compliance"]
```

## Markdown Content

The Markdown section contains the actual prompt template with parameter substitution:

```markdown
# Security Audit for {application_name}

## Application Profile
- **Name:** {application_name}
- **Technology Stack:** {technology_stack}
- **Audit Scope:** {audit_scope}

{% if compliance_requirements %}
## Compliance Requirements
{% for requirement in compliance_requirements %}
- **{requirement}**: Evaluate against {requirement} security controls
{% endfor %}
{% endif %}

## Analysis Instructions

Perform a comprehensive security analysis of {application_name} built with {technology_stack}.

{% if audit_scope == "basic" %}
### Basic Security Review
- Input validation assessment
- Authentication mechanism review
- Basic vulnerability scan
{% elif audit_scope == "comprehensive" %}
### Comprehensive Security Audit
- Complete OWASP Top 10 assessment
- Penetration testing simulation
- Code security review
- Infrastructure security evaluation
{% elif audit_scope == "compliance" %}
### Compliance-Focused Audit
{% for requirement in compliance_requirements %}
- **{requirement} Compliance Assessment**
{% endfor %}
{% endif %}
```

## Template Syntax

Prompd uses Jinja2 templating with single braces for variables:

### Variable Substitution
```jinja2
{parameter_name}            # Simple substitution (single braces)
{user.name}                 # Object property access
{items[0]}                  # Array access
{name|upper}                # Filter: converts to uppercase
{name|default('Anonymous')} # Default value if undefined
{balance|default(0)}        # Default with numeric value
```

### Conditionals
```jinja2
{% if condition %}
  Content when condition is true
{% else %}
  Content when condition is false
{% endif %}

{% if premium_user %}
  Premium content here
{% elif regular_user %}
  Regular content here
{% else %}
  Guest content here
{% endif %}
```

### Loops
```jinja2
{% for item in items %}
- {item}
{% endfor %}

{% for key, value in object.items() %}
- {key}: {value}
{% endfor %}

{% for feature in premium_features %}
- {feature}
{% else %}
  No features available
{% endfor %}
```

### Filters
```jinja2
{name|upper}                # Convert to uppercase
{name|lower}                # Convert to lowercase
{name|title}                # Title Case
{description|truncate(100)} # Truncate to 100 characters
{price|round(2)}            # Round to 2 decimal places
{items|length}              # Get length of array/string
{text|escape}               # HTML escape
```

### Comments
```jinja2
{# This is a comment and won't appear in output #}
{#
  Multi-line comment
  Can span multiple lines
#}
```

## Working Examples

### Example 1: Basic Security Audit

**security-audit-basic.prmd:**
```yaml
---
id: security-audit-basic
name: "Basic Security Audit"
version: "1.0.0"
description: "Performs a basic security assessment of web applications"
author: "Security Team"
tags: [security, audit, basic]
categories: ["Security", "Web Applications"]

parameters:
  - name: application_name
    type: string
    required: true
    description: "Name of the application being audited"
    
  - name: application_url
    type: string
    required: true
    pattern: "^https?://.+"
    description: "URL of the application (must start with http:// or https://)"
    
  - name: technology_stack
    type: string
    required: true
    description: "Primary technologies used (e.g., 'React + Express + MongoDB')"
    
  - name: include_owasp_check
    type: boolean
    default: true
    description: "Include OWASP Top 10 assessment"
    
  - name: priority_areas
    type: array
    items:
      enum: [authentication, authorization, input-validation, data-protection, session-management]
    minItems: 1
    default: [authentication, input-validation]
    description: "Security areas to prioritize"

context:
  - "./security-checklist.md"
---

# Security Audit Report for {application_name}

## Application Overview
- **Application:** {application_name}
- **URL:** {application_url}
- **Technology Stack:** {technology_stack}
- **Audit Date:** {current_date}

## Audit Scope

This basic security audit focuses on the following priority areas:
{% for item in priority_areas %}
- **{item}**: Critical security assessment
{% endfor %}

## Security Assessment

### 1. Authentication Analysis
Review the authentication mechanisms for {application_name}:

- **Login Process**: Analyze the login flow for {application_url}
- **Password Policies**: Evaluate password strength requirements
- **Session Management**: Review session handling and timeout policies
- **Multi-Factor Authentication**: Check for MFA implementation

{% if include_owasp_check %}
### 2. OWASP Top 10 Assessment

Systematic evaluation of {application_name} against OWASP Top 10:

1. **A01:2021 – Broken Access Control**
   - Test authorization mechanisms in {application_name}
   - Verify user role separation and privilege escalation protection

2. **A02:2021 – Cryptographic Failures**
   - Analyze data encryption in transit and at rest
   - Review cryptographic implementations in {technology_stack}

3. **A03:2021 – Injection**
   - Test for SQL, NoSQL, and command injection vulnerabilities
   - Analyze input validation for {technology_stack} components

4. **A04:2021 – Insecure Design**
   - Review the security architecture of {application_name}
   - Assess threat modeling and secure design principles

5. **A05:2021 – Security Misconfiguration**
   - Evaluate server and application configuration
   - Check for unnecessary features, default accounts, and verbose error messages

{% for item in priority_areas %}
**Priority Focus on {item}:**
- Conduct enhanced testing for {item} vulnerabilities
- Document specific findings and remediation steps
{% endfor %}
{% endif %}

### 3. Technology-Specific Analysis

For applications built with {technology_stack}:

{% if technology_stack %}
{% elif technology_stack == "React + Express + MongoDB" %}
**Frontend Security (React):**
- XSS prevention and Content Security Policy
- Secure handling of sensitive data in client-side code
- Third-party dependency vulnerability assessment

**Backend Security (Express):**
- Input validation and sanitization middleware
- Authentication and session management
- API security and rate limiting
- Error handling and information disclosure prevention

**Database Security (MongoDB):**
- NoSQL injection prevention
- Database access controls and connection security
- Data validation and schema enforcement
{% else %}
**Technology Stack Security for {technology_stack}:**
- Component-specific security considerations
- Common vulnerabilities for this technology stack
- Security best practices implementation review
{% endif %}

## Deliverables

### Security Findings Summary
- **Critical Issues**: Immediate attention required
- **High Priority**: Address within 30 days
- **Medium Priority**: Address within 90 days
- **Informational**: Best practice recommendations

### Remediation Roadmap
1. **Immediate Actions** (0-7 days)
   - Critical security vulnerabilities
   - Access control fixes

2. **Short-term Improvements** (1-4 weeks)
   - Input validation enhancements
   - Security configuration updates

3. **Long-term Enhancements** (1-3 months)
   - Security monitoring implementation
   - Security training and documentation

## Testing Methodology

This audit of {application_name} includes:

1. **Automated Security Scanning**
   - Web application vulnerability scanning of {application_url}
   - Dependency vulnerability assessment
   - Configuration security review

2. **Manual Security Testing**
   - Business logic testing
   - Authentication and session management testing
   - Input validation testing for {technology_stack} components

3. **Code Review** (if source code available)
   - Security-focused static analysis
   - Review of security controls implementation
   - Cryptographic usage assessment

---

**Audit Standards:** This assessment follows industry best practices and OWASP guidelines for web application security testing.
```

### Example 2: Advanced API Security Audit

**api-security-audit.prmd:**
```yaml
---
id: api-security-comprehensive
name: "Comprehensive API Security Audit"
version: "2.1.0"
description: "Advanced security audit specifically designed for REST APIs and GraphQL endpoints"
author: "API Security Team"
inherits: "./security-audit-basic.prmd"
tags: [api, security, rest, graphql, comprehensive]
categories: ["Security", "API", "Advanced"]

parameters:
  - name: api_type
    type: string
    enum: [rest, graphql, grpc, websocket]
    default: rest
    description: "Type of API being audited"
    
  - name: authentication_methods
    type: array
    items:
      enum: [jwt, oauth2, api-key, basic-auth, bearer-token, custom]
    minItems: 1
    description: "Authentication methods used by the API"
    
  - name: rate_limiting_enabled
    type: boolean
    required: true
    description: "Whether the API implements rate limiting"
    
  - name: api_endpoints
    type: array
    items:
      type: object
      properties:
        path:
          type: string
        method:
          type: string
          enum: [GET, POST, PUT, DELETE, PATCH]
        authentication_required:
          type: boolean
        sensitive_data:
          type: boolean
      required: [path, method]
    minItems: 1
    description: "List of API endpoints to audit"
    
  - name: data_sensitivity_level
    type: string
    enum: [public, internal, confidential, restricted]
    default: internal
    description: "Sensitivity level of data handled by the API"

context:
  - "./api-security-checklist.md"
  - "./owasp-api-top-10.json"
  - "@prompd.io/api-security@1.0.0/contexts/api-threat-model.md"

system: |
  You are a senior API security specialist with expertise in:
  - OWASP API Security Top 10
  - OAuth 2.0 and OpenID Connect security
  - API gateway security architecture
  - Microservices security patterns
  - GraphQL security best practices
---

# Comprehensive API Security Audit: {application_name}

## API Security Profile
- **Application:** {application_name}
- **API Type:** {api_type}
- **Base URL:** {application_url}
- **Technology Stack:** {technology_stack}
- **Data Sensitivity:** {data_sensitivity_level}
- **Rate Limiting:** {% if rate_limiting_enabled %}Enabled{% else %}⚠️ Not Implemented{% endif %}

## Authentication Architecture Analysis

{% for method in authentication_methods %}
### {method} Authentication Analysis
{% if method %}
{% elif method == "jwt" %}
**JWT Token Security Review:**
- Token signature verification and algorithm security
- Token expiration and refresh mechanisms
- Claim validation and authorization logic
- Token storage and transmission security
{% elif method == "oauth2" %}
**OAuth 2.0 Implementation Review:**
- Authorization server security configuration
- Grant type usage and security implications
- Scope definition and enforcement
- PKCE implementation for public clients
{% elif method == "api-key" %}
**API Key Management Review:**
- Key generation entropy and uniqueness
- Key rotation and lifecycle management
- Key transmission and storage security
- Rate limiting per API key
{% else %}
**{item} Security Assessment:**
- Implementation security review
- Authentication bypass testing
- Session management analysis
{% endif %}
{% endfor %}

## OWASP API Security Top 10 Assessment

### API1:2023 Broken Object Level Authorization (BOLA)
**Testing Focus for {api_type} API:**
{% for endpoint in api_endpoints %}
- **{method} {path}**: 
  {% if authentication_required %}✓ Authentication Required{% else %}⚠️ Public Endpoint{% endif %}
  {% if sensitive_data %}🔒 Sensitive Data{% endif %}
  - Test object-level authorization controls
  - Verify user can only access their own resources
  - Check for horizontal privilege escalation
{% endfor %}

### API2:2023 Broken Authentication
**Authentication Security Review:**
- Multi-factor authentication implementation
- Password/credential policies
- Account lockout mechanisms
- Session management security

### API3:2023 Broken Object Property Level Authorization
**Data Exposure Analysis:**
{% if data_sensitivity_level %}
{% elif data_sensitivity_level == "restricted" %}
**CRITICAL**: Restricted data requires enhanced protection
- Field-level authorization implementation
- Sensitive data masking in responses
- Audit logging for all data access
{% elif data_sensitivity_level == "confidential" %}
**HIGH PRIORITY**: Confidential data security review
- Data classification and handling procedures
- Encryption for sensitive fields
- Access control granularity
{% else %}
**Standard data protection assessment:**
- Response data filtering
- Unnecessary data exposure prevention
{% endif %}

### API4:2023 Unrestricted Resource Consumption
**Rate Limiting and Resource Protection:**
{% if rate_limiting_enabled %}
✅ **Rate Limiting Enabled** - Verify implementation:
- Per-user/per-IP rate limits
- Different limits for different endpoints
- Rate limit bypass testing
- Resource-intensive operation protection
{% else %}
❌ **CRITICAL VULNERABILITY**: No rate limiting detected
- Implement rate limiting immediately
- Protect against DoS attacks
- Monitor resource consumption
- Set up alerting for unusual usage patterns
{% endif %}

{% if api_type == "graphql" %}
### GraphQL-Specific Security Testing
**Query Complexity Analysis:**
- Query depth limiting implementation
- Query complexity scoring and limits
- Introspection endpoint security
- Batch query abuse prevention

**GraphQL Authorization:**
- Field-level authorization implementation
- Type-based access controls
- Mutation authorization security
{% endif %}

{% if api_type == "rest" %}
### REST API Specific Testing
**HTTP Method Security:**
{% for endpoint in api_endpoints %}
- **{method} {path}**: Method-specific security testing
  - Proper HTTP method usage
  - CORS configuration review
  - HTTP header security analysis
{% endfor %}

**Content-Type Security:**
- Content-Type validation
- XML/JSON parsing security
- File upload security (if applicable)
{% endif %}

## API Endpoint Security Analysis

{% for endpoint in api_endpoints %}
### {method} {path}

**Endpoint Risk Assessment:**
- **Authentication Required:** {% if authentication_required %}Yes{% else %}No (Public){% endif %}
- **Sensitive Data:** {% if sensitive_data %}Yes - Enhanced Testing{% else %}No{% endif %}
- **Risk Level:** {% if sensitive_data %}{% if authentication_required %}Medium{% else %}HIGH{% endif %}{% else %}Low{% endif %}

**Security Testing Plan:**
1. **Input Validation Testing**
   - Parameter injection attacks (SQL, NoSQL, Command)
   - Input fuzzing and boundary testing
   - Content-type confusion attacks

2. **Authorization Testing**
   {% if authentication_required %}
   - Valid token with insufficient privileges
   - Expired or invalid token handling
   - Token manipulation attempts
   {% else %}
   - Public endpoint abuse testing
   - Excessive usage without authentication
   {% endif %}

3. **Data Security Testing**
   {% if sensitive_data %}
   - Sensitive data exposure in responses
   - Data leakage through error messages
   - Unauthorized data modification attempts
   {% endif %}

{% endfor %}

## Technology Stack Security Assessment

**{technology_stack} Security Review:**

{% if technology_stack %}
{% elif technology_stack == "Node.js + Express + MongoDB" %}
**Node.js/Express API Security:**
- Express middleware security configuration
- Helmet.js security headers implementation
- Input validation with express-validator
- Error handling and information disclosure

**MongoDB Security:**
- NoSQL injection prevention
- Connection string security
- Database user privilege review
- Query performance and DoS protection
{% elif technology_stack == "Python + FastAPI + PostgreSQL" %}
**FastAPI Security Features:**
- Automatic OpenAPI documentation security
- Dependency injection security
- Pydantic model validation
- CORS middleware configuration

**PostgreSQL Security:**
- SQL injection prevention with parameterized queries
- Database user access controls
- Connection pooling security
- Query performance monitoring
{% else %}
**{technology_stack} Security Analysis:**
- Framework-specific security features review
- Common vulnerabilities for this technology stack
- Security best practices implementation
- Third-party dependency security assessment
{% endif %}

## Compliance and Standards Assessment

{% if data_sensitivity_level %}
{% elif data_sensitivity_level == "restricted" %}
### Regulatory Compliance Review
**Enhanced compliance requirements for restricted data:**
- Data residency and sovereignty requirements
- Access logging and audit trails
- Incident response procedures
- Data retention and deletion policies
{% elif data_sensitivity_level == "confidential" %}
### Confidential Data Protection Standards
- Encryption in transit and at rest
- Key management security
- Access control documentation
- Regular security assessments
{% endif %}

## Security Testing Methodology

### Automated Testing Tools
1. **API Security Scanners**
   - OWASP ZAP API testing
   - Postman security test collections
   - Custom fuzzing tools for {api_type} APIs

2. **Static Code Analysis** (if source code available)
   - Security-focused SAST tools
   - Dependency vulnerability scanning
   - Secret detection in codebase

### Manual Testing Procedures
1. **Business Logic Testing**
   - Workflow security validation
   - Race condition testing
   - State manipulation attempts

2. **Authentication Bypass Testing**
   {% for method in authentication_methods %}
   - {item} specific bypass attempts
   {% endfor %}

3. **Data Validation Testing**
   - Boundary value testing
   - Format string vulnerabilities
   - Type confusion attacks

## Recommendations and Remediation

### Immediate Actions (Critical - 0-7 days)
{% if not rate_limiting_enabled %}
- **URGENT**: Implement rate limiting across all endpoints
{% endif %}
- Review and test all authentication mechanisms
- Validate input sanitization for all endpoints

### Short-term Improvements (High Priority - 1-4 weeks)
- Implement comprehensive logging and monitoring
- Enhance error handling to prevent information disclosure
- Review and update API documentation with security considerations

### Long-term Security Enhancements (1-3 months)
- Implement automated security testing in CI/CD pipeline
- Regular penetration testing schedule
- Security awareness training for development team
- API security governance and policies

---

**Assessment Standards:** This audit follows OWASP API Security Top 10, NIST API Security guidelines, and industry-specific compliance requirements for {data_sensitivity_level} data handling.
```

## Validation Rules

### File Validation
- File must have `.prmd` extension
- File must contain YAML frontmatter (between `---` markers)
- YAML must be valid syntax
- Required fields must be present

### Parameter Validation
- Parameter names must be valid identifiers
- Types must be supported (`string`, `number`, `integer`, `boolean`, `array`, `object`)
- Enum values must be arrays of strings
- Default values must match parameter type
- Required parameters cannot have `null` defaults

### Template Validation
- Handlebars syntax must be valid
- Referenced parameters must be defined in frontmatter
- Context files must exist (during compilation)
- Package references must be properly quoted

### Common Validation Errors

```yaml
# ❌ INVALID - Missing required quotes
inherits: @prompd.io/package@1.0.0

# ✅ VALID - Properly quoted
inherits: "@prompd.io/package@1.0.0/prompts/base.prmd"

# ❌ INVALID - Parameter type mismatch
parameters:
  - name: count
    type: number
    default: "not-a-number"  # String default for number type

# ✅ VALID - Correct type
parameters:
  - name: count
    type: number
    default: 42

# ❌ INVALID - Undefined parameter in template
# No 'undefined_param' in parameters array
{undefined_param}

# ✅ VALID - Parameter defined in frontmatter
parameters:
  - name: defined_param
    type: string
{defined_param}
```

## Best Practices

### File Organization
```
project/
├── prompts/
│   ├── security/
│   │   ├── base-audit.prmd
│   │   ├── web-security.prmd
│   │   └── api-security.prmd
│   ├── analysis/
│   │   ├── code-review.prmd
│   │   └── performance-analysis.prmd
│   └── generation/
│       ├── documentation.prmd
│       └── test-generation.prmd
├── contexts/
│   ├── security-checklist.md
│   └── coding-standards.md
└── systems/
    ├── security-expert.md
    └── code-reviewer.md
```

### Naming Conventions
- **Files**: `kebab-case.prmd` (e.g., `security-audit-comprehensive.prmd`)
- **IDs**: `kebab-case` or `snake_case` (e.g., `security_audit_v2`)
- **Parameters**: `snake_case` (e.g., `application_name`, `max_tokens`)
- **Template variables**: `{snake_case}` (e.g., `{application_name}`)

### Parameter Design
- Use descriptive names and descriptions
- Provide sensible defaults where possible
- Use enums for limited choice parameters
- Validate input ranges and formats
- Group related parameters logically

### Template Design
- Keep templates readable and well-structured
- Use conditional logic sparingly
- Provide clear section headers
- Include helpful comments
- Test with various parameter combinations

### Version Management
- Use semantic versioning (major.minor.patch)
- Increment major for breaking changes
- Increment minor for new features
- Increment patch for bug fixes
- Document changes in description or comments

This format specification enables powerful, reusable, and maintainable AI prompts that can be composed, shared, and evolved systematically.

## Real Working Examples

For practical examples that demonstrate these concepts, see the working prompts in:
- **Basic Templates**: `prompd-base/examples/base-prompt.prmd`
- **Local Inheritance**: `prompd-base/examples/basic-inheritance.prmd` 
- **Package Inheritance**: `prompd-base/examples/package-inheritance.prmd`
- **API Development**: `prompd-base/examples/api-development.prmd`
- **CLI Usage Guide**: `prompd-base/examples/CLI-USAGE-EXAMPLES.md`

These examples are fully functional and can be tested with:
```bash
# Validate examples
prompd validate prompd-base/examples/base-prompt.prmd

# Compile with parameters
prompd compile prompd-base/examples/api-development.prmd \
  --params endpoint_name="User Management" \
  --params framework="express"

# Execute with AI provider
prompd run prompd-base/examples/base-prompt.prmd \
  --provider openai \
  --params topic="machine learning"
```