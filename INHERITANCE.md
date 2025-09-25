# Prompd Inheritance System Documentation

> **⚠️ READ-ONLY**: This file is maintained by the documentation system. Do not edit directly unless you are the repository owner with override permissions.

## Table of Contents
- [Overview](#overview)
- [Basic Inheritance Syntax](#basic-inheritance-syntax)
- [What Gets Inherited](#what-gets-inherited)
- [Override Behavior](#override-behavior)
- [Package References](#package-references)
- [File Type Support and References](#file-type-support-and-references)
- [Working Examples](#working-examples)
- [Advanced Patterns](#advanced-patterns)
- [Troubleshooting](#troubleshooting)

## Overview

The Prompd inheritance system allows prompt templates to extend and build upon other templates, similar to object-oriented programming inheritance. This enables code reuse, standardization, and composition of complex AI workflows from simpler components.

### Key Inheritance Rules

1. **File Path Resolution**: You can inherit from:
   - **Local files**: `./base-template.prmd` (relative paths)
   - **Package files**: `"@scope/package@version/path/to/file.prmd"` (must be quoted and include full path)

2. **Content Merging**: Child content is **appended** after parent content (not merged)

3. **Parameter Merging**: Child parameters **override** parent parameters by name

4. **Context Merging**: Child context arrays are **merged** with parent context

5. **Package References**: All `@` references must be quoted for valid YAML

## Basic Inheritance Syntax

### Local File Inheritance

To inherit from a local file, use the `inherits` field in your YAML frontmatter:

```yaml
---
id: child-template
name: "Child Template"
inherits: "./base-template.prmd"
parameters:
  - name: model
    type: string
    default: "gpt-4o"  # Override parent value
---

Child-specific content is appended after parent content.
```

**EXACT SYNTAX REQUIREMENTS:**
- Use forward slashes `/` even on Windows
- Relative paths start with `./` (current directory) or `../` (parent directory)
- File extension `.prmd` is required
- Path can be quoted or unquoted unless it contains special characters

### Package Reference Inheritance

To inherit from a package file in the registry:

```yaml
---
id: security-audit-specialized
name: "Fintech Security Audit"
inherits: "@prompd.io/security-toolkit@1.0.0/prompts/security-audit.prmd"
parameters:
  - name: compliance_requirements
    type: array
    default: ["PCI-DSS", "SOX", "FFIEC"]
---

Additional fintech-specific security requirements...
```

**CRITICAL SYNTAX REQUIREMENTS:**
- Package references starting with `@` **MUST** be quoted in YAML
- Must include the **full file path** within the package
- Format: `"@namespace/package-name@version/path/to/file.prmd"`
- The quotes are **REQUIRED** because `@` is reserved in YAML

### Section-Based Content Override

For **precise control** over inherited content, use section-based overrides to selectively replace, remove, or modify specific sections:

```yaml
---
name: "Healthcare Security Audit"
inherits: "./base-security-audit.prmd"
override:
  system-prompt: "./healthcare-system-prompt.md"
  examples: null                                    # Remove section
  compliance-requirements: "./hipaa-compliance.md" # Replace section
---
```

**Key Benefits:**
- **Selective Replacement**: Override only specific sections, not entire content
- **Section Removal**: Remove sections that don't apply (set to `null`)
- **File-Based Content**: Load override content from external files
- **Backward Compatible**: Works alongside traditional inheritance

**Section ID Discovery:**
```bash
# See available sections for override
prompd show base-template.prmd --sections
```

**Complete Documentation**: See [SECTION-OVERRIDE.md](./SECTION-OVERRIDE.md) for full specification, examples, and CLI commands.

## What Gets Inherited

### 1. Parameters
- Parent parameters are inherited
- Child parameters with same `name` override parent parameters
- Child can add new parameters

**Example:**
```yaml
# Parent template parameters
parameters:
  - name: temperature
    type: number
    default: 0.7
  - name: model
    type: string
    default: "gpt-3.5-turbo"

# Child template parameters
parameters:
  - name: model
    type: string
    default: "gpt-4o"    # Overrides parent
  - name: system_role   # New parameter
    type: string
    default: "security expert"
```

### 2. Content
- Parent content is included first
- Child content is **appended** after parent content
- No content merging - purely additive

### 3. Metadata Fields
- `id`, `name`, `description`, `version` can be overridden
- `author` is inherited unless overridden
- Custom fields are merged

### 4. Context Arrays
- Parent context files are included
- Child context files are appended to the list
- No deduplication occurs

### 5. System/Assistant/Other References
- All reference fields are inherited and can be overridden
- File paths are resolved relative to the child template

## Override Behavior

### Parameter Override Rules

Child parameters override parent parameters by **exact name match**:

```yaml
# Parent template
---
parameters:
  - name: temperature
    type: number
    default: 0.7
    description: "Controls randomness"
---

# Child template
---
inherits: "./parent.prmd"
parameters:
  - name: temperature
    type: number
    default: 0.1      # Overrides parent default
    description: "Conservative temperature for analysis"  # Overrides description
  - name: max_tokens  # New parameter, not an override
    type: number
    default: 2000
---
```

### Content Override Pattern

Traditional content inheritance is **additive** (child content appends to parent). For precise content control, use section-based overrides or template syntax:

```yaml
---
id: custom-audit
inherits: "./base-audit.prmd"
---

## Custom Requirements

Additional analysis specific to this use case:

{{ parent.content  %}

## Post-Analysis Steps

Follow-up actions after the base audit completes.
```

### YAML Fields vs Markdown Content

**IMPORTANT**: YAML frontmatter fields and markdown content are completely separate systems:

#### ✅ YAML Field Override (Works)
```yaml
# parent.prmd
---
system: "You are a general analyst"
user: "Analyze the provided data"
---
# System Notes
General analysis guidelines here.

# User Instructions
Follow standard procedures.
```

```yaml
# child.prmd
---
inherits: "./parent.prmd"
system: "You are a security expert"     # ✅ OVERRIDES parent YAML field
user: "./users/security-analyst.prmd"   # ✅ OVERRIDES parent YAML field
---
# System Notes
Security-specific guidelines here.

# Additional Context
Use advanced security frameworks.
```

**Result**: Child gets `system: "You are a security expert"` (YAML override) AND both parent + child markdown content (both `# System Notes` sections appear).

#### ❌ Markdown Headers Don't Override YAML (Doesn't Work)
```yaml
# child.prmd
---
inherits: "./parent.prmd"
# No system: field in YAML frontmatter
---
# System
You are a security expert  # ❌ Does NOT override YAML system: field
```

**Result**: Child keeps parent's `system: "You are a general analyst"` from YAML. The `# System` markdown is just content.

#### 🔄 Override Rules Summary
- **YAML → YAML**: Child YAML fields completely override parent YAML fields ✅
- **Markdown → Markdown**: Child markdown is appended to parent markdown ✅
- **YAML → Markdown**: No interaction - completely separate ❌
- **Markdown → YAML**: No interaction - completely separate ❌

### No Partial Replacement

**There is NO mechanism for partial replacement of markdown sections:**

```yaml
# parent.prmd with multiple sections
---
system: "You are an analyst"
---
# System Guidelines
- Be thorough
- Use data-driven approaches

# User Instructions
1. Read the document
2. Identify key points
3. Write summary

# Quality Standards
- Accuracy is critical
- Cite sources
```

```yaml
# child.prmd - CANNOT selectively replace sections
---
inherits: "./parent.prmd"
---
# System Guidelines
- Focus on security vulnerabilities  # This gets ADDED, not REPLACED
- Use security frameworks

# New Section
Additional child content here.
```

**Result**: Child gets ALL parent sections + ALL child sections. The child's `# System Guidelines` does NOT replace the parent's `# System Guidelines` - both appear in the final output.

**To replace content, you must override at the YAML level:**
```yaml
# child.prmd - proper override
---
inherits: "./parent.prmd"
system: "./systems/security-expert.prmd"  # ✅ REPLACES parent system YAML field
---
# Child-specific content only
```

### YAML Override Reference

The Python CLI is the source of truth for inheritance and overrides. There is no special `override:` key; you override simply by redefining fields in the child.

- Scalars: redefining `id`, `name`, `description`, `version` in the child overrides the parent.
- Parameters: same `name` in the child overrides that parent parameter; new child params are added.
- Content: parent markdown is included first; child content is appended. No “replace parent content” directive exists.
- Contexts: provide the full desired list in the child’s `context`. Parent contexts are not automatically merged by the Python compiler.
- Using/packages: declare under `using:` in the child; references like `@prefix/...` in the child resolve from those imports.

Example:

```yaml
---
id: api-audit
name: "API Security Audit"
inherits: "./base-security-audit.prmd"
parameters:
  - name: temperature   # overrides parent by exact name
    type: number
    default: 0.1

# Include all contexts needed by the child
context:
  - "./checklists/owasp-api-top10.md"
  - "./assets/schema.json"
---

## Additional Checks
Add API-specific checks here.
```

## Package References

Package references can appear in **any YAML field** and must include the full file path:

```yaml
---
id: comprehensive-security-audit
using:
  - name: "@prompd.io/api-toolkit@1.2.1"
    prefix: "@api"
  - name: "@prompd.io/ml-toolkit@3.0.0"
    prefix: "@ml"
  - name: "@prompd.io/security-toolkit@1.0.0"
    prefix: "@security"
inherits: "@prompd.io/core-patterns@2.0.0/templates/analysis-framework.prmd"
system: "@security/systems/security-expert.prmd"
assistant: "@security/assistants/penetration-tester.prmd"
context:
  - "@security/contexts/owasp-top-10.md"
  - "./local-context.md"
---
```

**CRITICAL: All `@` references MUST be quoted to be valid YAML!**

## Working Examples

### Example 1: Basic Local Inheritance

**base-security-audit.prmd:**
```yaml
---
id: base-security-audit
name: "Base Security Audit"
parameters:
  - name: application_name
    type: string
    required: true
  - name: technology_stack
    type: string
    required: true
  - name: audit_scope
    type: string
    enum: [basic, comprehensive]
    default: basic
---

# Security Audit for {application_name}

## Technology Stack
- **Stack:** {technology_stack}
- **Audit Scope:** {audit_scope}

## Base Security Assessment

Perform standard security evaluation including:
- Input validation review
- Authentication mechanism analysis
- Authorization control verification
- Data protection assessment
```

**security-audit.prmd (inherits from base):**
```yaml
---
id: security-audit
name: "Comprehensive Security Audit"
inherits: "./base-security-audit.prmd"
system: "../systems/security-expert.md"
assistant: "../assistants/penetration-tester.md"
context:
  - "../contexts/owasp-top-10.md"
parameters:
  - name: audit_scope
    type: string
    enum: [basic, comprehensive, compliance]
    default: comprehensive  # Overrides parent default
  - name: compliance_requirements  # New parameter
    type: array
    items: 
      enum: [SOC2, PCI-DSS, HIPAA, GDPR]
    required: false
---

## Advanced Security Testing

{% if imports.system %}Using {imports.system} methodology:{% endif %}

### OWASP Top 10 Assessment
{% if imports.context.owasp-top-10 %}
Systematic evaluation against OWASP standards from {imports.context['owasp-top-10']}.
{% endif %}

### Penetration Testing Simulation
{% if imports.assistant %}
{imports.assistant} approach to vulnerability discovery:
{% endif %}

1. **Reconnaissance**
   - Information gathering about {application_name}
   - Technology fingerprinting for {technology_stack}

2. **Vulnerability Discovery** 
   - Automated security scanning
   - Manual security testing specific to {technology_stack}

3. **Exploitation Assessment**
   - Safe proof-of-concept demonstrations
   - Risk scoring and impact analysis

{% if compliance_requirements %}
### Compliance Validation
**Requirements Assessment:**
{% for item in compliance_requirements %}
- **{item} Compliance:** Evaluate against {item} security controls
{% endfor %}
{% endif %}
```

### Example 2: Package Inheritance

```yaml
---
id: fintech-security-audit
name: "Fintech Security Audit"
inherits: "@prompd.io/security-toolkit@1.0.0/prompts/security-audit.prmd"
parameters:
  - name: compliance_requirements
    type: array
    default: ["PCI-DSS", "SOX", "FFIEC"]  # Override for fintech
  - name: financial_data_types  # New parameter
    type: array
    items:
      enum: [card_data, account_numbers, transaction_data, pii]
    required: true
context:
  - "@prompd.io/fintech-context@1.2.0/contexts/pci-requirements.md"
  - "./fintech-specific-rules.md"
---

## Financial Services Specific Requirements

### Regulatory Context
Financial services require strict data protection standards including:

{% for item in financial_data_types %}
- **{item}**: Enhanced protection requirements
{% endfor %}

### PCI-DSS Compliance Focus
- Card data encryption verification
- Transaction integrity audit
- Access control validation
- Network security assessment

## Enhanced Risk Assessment

For financial applications, evaluate additional risks:
- Fraud detection bypass attempts
- Transaction manipulation vectors
- Customer data exposure risks
- Regulatory compliance gaps
```

## Advanced Patterns

### Chained Inheritance

You can create inheritance chains where each level adds specialization:

```yaml
# Level 1: Base analysis framework
base-analysis.prmd:
---
id: base-analysis
name: "Base Analysis Framework"
---

# Level 2: Security-focused analysis
security-analysis.prmd:
---
id: security-analysis
inherits: "./base-analysis.prmd"
---

# Level 3: Compliance-focused security
compliance-security.prmd:
---
id: compliance-security
inherits: "./security-analysis.prmd"
---
```

### Multiple Context Sources

```yaml
---
inherits: "@prompd.io/base@1.0.0/templates/analysis.prmd"
context:
  - "@prompd.io/security@1.0.0/contexts/owasp-top-10.md"
  - "@prompd.io/compliance@1.0.0/contexts/pci-requirements.md"
  - "./local-threat-model.md"
  - "./previous-audit-findings.json"
---
```

## Troubleshooting

### Common Errors

#### 1. YAML Syntax Errors with Package References

**❌ WRONG - Will cause YAML parsing errors:**
```yaml
inherits: @prompd.io/package@1.0.0/prompts/base.prmd    # FAILS!
system: @systems/expert@1.0.0/systems/expert.prmd      # YAML ERROR!
```

**✅ CORRECT - Valid YAML syntax:**
```yaml
inherits: "@prompd.io/package@1.0.0/prompts/base.prmd"  # Quoted properly
system: "@systems/expert@1.0.0/systems/expert.prmd"    # Valid YAML
```

#### 2. File Not Found Errors

**Error:**
```
Context file not found: ./missing-file.md
```

**Solution:** Verify relative paths are correct from the child file's location:
```yaml
# If child is in ./specialized/audit.prmd
# and base is in ./base.prmd
inherits: "../base.prmd"  # Up one level
context:
  - "../contexts/shared.md"  # Up one level to contexts
```

#### 3. Package Path Errors

**Error:**
```
Package file not found: @prompd.io/toolkit@1.0.0
```

**Solution:** Include the full file path within the package:
```yaml
# WRONG - Missing file path
inherits: "@prompd.io/toolkit@1.0.0"

# CORRECT - Include full path
inherits: "@prompd.io/toolkit@1.0.0/prompts/base-tool.prmd"
```

#### 4. Parameter Override Not Working

**Problem:** Child parameter not overriding parent parameter.

**Solution:** Ensure exact name match:
```yaml
# Parent has parameter named "model"
# Child must use exactly "model" to override
parameters:
  - name: model  # Exact match required
    default: "new-value"
```

### Testing Inheritance

To verify inheritance is working correctly:

1. **Compile the template:**
   ```bash
   prompd compile ./child-template.prmd --to-markdown -o output.md
   ```

2. **Check parameter resolution:**
   ```bash
   prompd show ./child-template.prmd
   ```

3. **Validate package references:**
   ```bash
   prompd deps ./child-template.prmd
   ```

### Best Practices

1. **Use descriptive inheritance hierarchies:**
   ```
   base-analysis.prmd
   ├── security-analysis.prmd
   │   ├── web-security-audit.prmd
   │   └── api-security-audit.prmd
   └── performance-analysis.prmd
   ```

2. **Document inheritance relationships:**
   ```yaml
   ---
   id: specialized-audit
   name: "API Security Audit"
   description: "Extends base security audit with API-specific checks"
   inherits: "./security-analysis.prmd"
   ---
   ```

3. **Keep inheritance chains shallow:**
   - Maximum 3-4 levels deep
   - Prefer composition over deep inheritance

4. **Use package references for shared components:**
   ```yaml
   # Good - shared base from registry
   inherits: "@prompd.io/standards@1.0.0/templates/analysis-base.prmd"
   
   # Avoid - duplicating common patterns locally
   inherits: "./duplicated-common-pattern.prmd"
   ```

This inheritance system enables powerful composition while maintaining clear, traceable relationships between templates.

## File Type Support and References

### Supported File Types in YAML Fields

You can reference external files in any YAML field (`system:`, `user:`, `assistant:`, `response:`, `context:`, `inherits:`). The system supports a wide range of file types with automatic processing:

#### ✅ **Text Files (Direct Content)**
```yaml
system: "./prompts/system-prompt.txt"      # Plain text
user: "./instructions/user-guide.md"       # Markdown
assistant: "./responses/template.txt"      # Plain text
context:
  - "./data/sample-code.py"                # Python code
  - "./config/settings.env"                # Environment file
  - "./data/export.csv"                    # CSV data
```

#### ✅ **Structured Data (Formatted Output)**
```yaml
context:
  - "./config/api-settings.json"           # → Pretty JSON with markdown
  - "./deployment/k8s-config.yaml"         # → Formatted YAML with markdown
  - "./data/database-schema.yml"           # → Structured YAML display
```

**Example Output:**
```markdown
## Context from api-settings.json

# JSON Data from api-settings.json

```json
{
  "base_url": "https://api.example.com",
  "timeout": 30,
  "retry_count": 3
}
```
```

#### ✅ **Binary Files (Automatic Extraction)**
```yaml
context:
  - "./reports/analysis.xlsx"              # → Extracted as CSV/tabular data
  - "./docs/manual.docx"                   # → Plain text extraction
  - "./presentations/overview.pptx"        # → Slide text extraction
  - "./documents/policy.pdf"               # → OCR text extraction
  - "./assets/diagram.png"                 # → Metadata + description
```

**Supported Binary Formats:**
- **Excel**: `.xlsx`, `.xlsm` → CSV/tabular data
- **Word**: `.docx` → Plain text
- **PowerPoint**: `.pptx`, `.pptm` → Slide text
- **PDF**: `.pdf` → OCR text extraction
- **Images**: `.png`, `.jpg`, `.jpeg`, `.gif`, `.bmp`, `.webp` → Metadata

#### ✅ **Package File References**
```yaml
using:
  - name: "@company/data-toolkit@1.0.0"
    prefix: "@data"
system: "@data/prompts/analyst.txt"        # Text from package
context:
  - "@data/samples/example.xlsx"           # Excel from package
  - "@data/configs/settings.json"          # JSON from package
  - "@prompd.io/security@1.0.0/contexts/owasp-guidelines.md"  # Direct package ref
```

### File Processing Behavior

#### **Context Field (Multi-File)**
Files in `context:` arrays are automatically extracted and included as separate sections:

```yaml
context:
  - "./data/users.csv"
  - "./config/settings.json"
  - "./docs/README.md"
```

**Result:** Each file gets its own markdown section with extracted content.

#### **Single Field References**
Files in single fields (`system:`, `user:`, etc.) replace the field value:

```yaml
system: "./prompts/security-expert.txt"    # Field contains file content
user: "./config/api-spec.json"             # Field contains formatted JSON
```

#### **Mixed Content**
You can combine inline content with file references:

```yaml
system: |
  You are a security analyst.

  Use these API settings:

context:
  - "./config/api-settings.json"           # Auto-extracted in context section
  - "./guidelines/security-checklist.md"   # Auto-extracted in context section
---

# Additional inline instructions here
```

### Error Handling

#### **Missing Files**
```yaml
context:
  - "./missing-file.txt"                   # → Warning: file not found
  - "./existing-file.json"                 # → Processed normally
```

#### **Unsupported Binary Files**
```yaml
context:
  - "./video.mp4"                          # → Included as filename reference
  - "./archive.zip"                        # → Listed but not extracted
```

#### **Permission Errors**
```yaml
system: "./restricted-file.txt"            # → Error message in output
```

### Best Practices

#### **File Organization**
```
project/
├── prompts/
│   ├── main.prmd
│   ├── system-prompts/
│   │   ├── analyst.txt
│   │   └── reviewer.txt
│   └── contexts/
│       ├── guidelines.md
│       ├── examples.json
│       └── data.xlsx
```

#### **Relative Paths**
Always use relative paths from the `.prmd` file location:
```yaml
# ✅ GOOD - relative to .prmd file
system: "./system-prompts/analyst.txt"
context: ["../shared/guidelines.md"]

# ❌ AVOID - absolute paths
system: "/full/path/to/file.txt"
```

#### **Package Organization**
```yaml
# ✅ GOOD - organized package structure
using:
  - name: "@company/security-toolkit@2.0.0"
    prefix: "@sec"
system: "@sec/prompts/security-analyst.txt"
context:
  - "@sec/checklists/owasp-top-10.md"
  - "@sec/examples/vulnerability-report.json"
```

## Real Working Examples

Test these inheritance concepts with functional examples:
- **Basic Inheritance**: `prompd-base/examples/basic-inheritance.prmd` (extends `base-prompt.prmd`)
- **Package Inheritance**: `prompd-base/examples/package-inheritance.prmd` (extends `@prompd.io/core-patterns@2.0.0`)
- **Complete Usage Guide**: `prompd-base/examples/CLI-USAGE-EXAMPLES.md`

```bash
# Test local inheritance
prompd validate prompd-base/examples/basic-inheritance.prmd
prompd compile prompd-base/examples/basic-inheritance.prmd \
  --params topic="blockchain technology" \
  --params analysis_depth="comprehensive"

# Test package inheritance (requires package to be available)
prompd validate prompd-base/examples/package-inheritance.prmd
prompd compile prompd-base/examples/package-inheritance.prmd \
  --params domain="healthcare"
```

## Future Enhancement: Section-Based Content Override

### Current Limitation

Currently, markdown content inheritance works by **simple concatenation** - parent content is placed first, followed by child content:

```markdown
<!-- Parent content -->
# System Guidelines
Follow these core principles...

# Analysis Framework
Use this structured approach...

<!-- Child content (appended) -->
# Custom Instructions
Additional specific requirements...
```

This means you **cannot selectively override** specific markdown sections from the parent.

### Proposed Section-Based Override Feature

A future enhancement could enable **section-level content override** using markdown heading anchors:

#### **Potential Syntax**
```yaml
---
inherits: "./base-security-audit.prmd"
override:
  "#system-guidelines": "./custom-security-guidelines.md"
  "#analysis-framework": null  # Remove this section
  "#examples": "./domain-specific-examples.md"
---

# Additional Custom Sections
This content would still be appended normally.
```

#### **Use Cases This Would Enable**

1. **Template Specialization**:
   ```yaml
   # base-analysis.prmd has generic analysis framework
   # child-security-analysis.prmd overrides with security-specific framework
   override:
     "#analysis-framework": "./security-analysis-framework.md"
   ```

2. **Section Removal**:
   ```yaml
   # Remove sections that don't apply to this specialization
   override:
     "#general-examples": null
     "#common-pitfalls": null
   ```

3. **Multi-Domain Customization**:
   ```yaml
   # Same base template, different domain implementations
   override:
     "#domain-context": "./healthcare-context.md"
     "#compliance-requirements": "./hipaa-requirements.md"
   ```

#### **Technical Implementation Notes**

This feature would require:

1. **Markdown Section Parsing**: Parse content into identified sections based on heading structure
2. **Section ID Generation**: Convert headings to anchor IDs (`# System Guidelines` → `#system-guidelines`)
3. **Merge Strategy**: Replace/remove specific sections while preserving others
4. **Content Order Preservation**: Maintain logical section ordering from parent template

#### **Current Workaround**

Until this feature exists, use **YAML field overrides** for section-like content:

```yaml
# Parent defines generic sections
system: "./base-system-prompt.txt"
analysis: "./base-analysis-framework.md"

# Child overrides specific sections
system: "./specialized-system-prompt.txt"  # Overrides parent system
# analysis: inherited from parent (not specified)
additional: "./child-specific-content.md"
```

This provides similar functionality but requires structuring content as separate YAML fields rather than unified markdown content.

### Impact

Section-based override would make the inheritance system significantly more powerful for:
- **Template specialization** across domains/industries
- **Modular content management** with selective replacement
- **Content library reuse** with precise customization

However, it adds complexity to the compilation pipeline and requires careful consideration of section ordering, ID conflicts, and merge semantics.
