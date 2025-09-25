# Section-Based Content Override

This document provides the complete specification for the section-based content override system in prompd template inheritance.

## Overview

Section-based content override allows you to selectively replace, remove, or modify specific sections of inherited template content while preserving the rest. This provides precise control over template specialization without requiring duplication of entire templates.

## Key Features

- **Selective Override**: Replace only specific sections from parent templates
- **Section Removal**: Remove sections that don't apply to specialized templates
- **File-Based Content**: Load override content from external files
- **Explicit Section IDs**: User-controlled section identification system
- **CLI Integration**: Complete tooling support for section discovery and validation
- **Error Prevention**: Comprehensive validation with typo detection and suggestions

## Basic Syntax

### YAML Declaration

```yaml
---
name: "Custom Security Audit"
inherits: "./base-security-audit.prmd"
override:
  system-prompt: "./healthcare-system-prompt.md"
  examples: null
  compliance-guidelines: "./hipaa-compliance.md"
---
```

### Section ID Format

Section IDs must follow **kebab-case** convention:
- Lowercase letters only
- Numbers allowed
- Hyphens for word separation
- No underscores, spaces, or special characters

**Valid Examples:**
- `system-prompt`
- `analysis-framework`
- `api-documentation`
- `security-guidelines-v2`

**Invalid Examples:**
- `System_Prompt` (uppercase, underscores)
- `system prompt` (spaces)
- `system@prompt` (special characters)

## Section Definition

### Automatic Section IDs

Sections are automatically created from **any markdown heading level** (# through ######):

```markdown
# System Prompt          → section ID: system-prompt
## Analysis Framework    → section ID: analysis-framework
### API Documentation    → section ID: api-documentation
#### Error Handling     → section ID: error-handling
##### Best Practices    → section ID: best-practices
###### Advanced Tips    → section ID: advanced-tips
```

**Important**: The section ID is generated from the **heading text only** - the heading level (number of #) doesn't affect the ID. All heading levels create overrideable sections.

### Explicit Section IDs

You can explicitly define section IDs using comments:

```markdown
<!-- section-id: custom-system -->
# System Prompt
You are a specialized security analyst...

<!-- section-id: analysis-method -->
# Analysis Framework
Follow this methodology...
```

## Override Operations

### 1. Section Replacement

Replace a section's content with content from another file:

```yaml
override:
  system-prompt: "./custom-system-prompt.md"
  analysis-framework: "./security-analysis-framework.md"
```

The referenced file can contain:
- Plain markdown content
- Complete sections with headings
- Any supported file format (see File Types section)

### 2. Section Removal

Remove a section entirely from the final output:

```yaml
override:
  examples: null
  general-guidelines: null
```

### 3. Section Preservation

Sections not mentioned in overrides are preserved from the parent template.

## File Types Support

Override content files support all formats supported by the prompd extraction system:

### Text-Based Files
```yaml
override:
  system-prompt: "./prompts/system.txt"
  guidelines: "./docs/guidelines.md"
  examples: "./examples/security-examples.txt"
```

### Structured Data Files
```yaml
override:
  data-context: "./context/threat-data.json"
  configuration: "./config/settings.yaml"
  examples: "./examples/test-cases.csv"
```

### Binary Document Files
```yaml
override:
  documentation: "./docs/security-manual.pdf"
  examples: "./examples/audit-checklist.xlsx"
  templates: "./templates/report-template.docx"
```

## Complete Example

### Parent Template: `base-security-audit.prmd`

```yaml
---
name: "Base Security Audit"
description: "Generic security audit template"
version: "1.0.0"
parameters:
  - name: target_system
    type: string
    required: true
    description: "System being audited"
---

<!-- section-id: system-prompt -->
# System Prompt
You are a security auditor. Analyze the provided system for vulnerabilities.

<!-- section-id: analysis-framework -->
# Analysis Framework
Follow these steps:
1. Review system architecture
2. Identify potential vulnerabilities
3. Assess risk levels
4. Provide recommendations

<!-- section-id: examples -->
# Examples
Generic security examples:
- SQL injection testing
- XSS vulnerability checks
- Authentication bypass attempts

<!-- section-id: compliance-requirements -->
# Compliance Requirements
General compliance considerations:
- Data protection requirements
- Access control standards
- Audit trail requirements
```

### Child Template: `healthcare-security-audit.prmd`

```yaml
---
name: "Healthcare Security Audit"
description: "HIPAA-compliant healthcare security audit"
inherits: "./base-security-audit.prmd"
override:
  system-prompt: "./healthcare-system-prompt.md"
  examples: "./healthcare-examples.md"
  compliance-requirements: null
version: "1.1.0"
---

# Healthcare-Specific Guidelines
Additional healthcare security considerations specific to this audit.
```

### Override Content Files

**File: `healthcare-system-prompt.md`**
```markdown
You are a healthcare security auditor specializing in HIPAA compliance.
When analyzing systems, pay special attention to:

- Protected Health Information (PHI) handling
- Access controls for medical records
- Encryption requirements for data at rest and in transit
- Audit logging for all PHI access
```

**File: `healthcare-examples.md`**
```markdown
Healthcare-specific security examples:
- PHI data exposure through unsecured APIs
- Medical device network segmentation
- Electronic Health Record (EHR) access controls
- Telemedicine platform security assessment
- Medical imaging system vulnerabilities (DICOM)
```

### Compiled Result

When `prompd compile healthcare-security-audit.prmd` is executed:

```markdown
# System Prompt
You are a healthcare security auditor specializing in HIPAA compliance.
When analyzing systems, pay special attention to:

- Protected Health Information (PHI) handling
- Access controls for medical records
- Encryption requirements for data at rest and in transit
- Audit logging for all PHI access

# Analysis Framework
Follow these steps:
1. Review system architecture
2. Identify potential vulnerabilities
3. Assess risk levels
4. Provide recommendations

# Examples
Healthcare-specific security examples:
- PHI data exposure through unsecured APIs
- Medical device network segmentation
- Electronic Health Record (EHR) access controls
- Telemedicine platform security assessment
- Medical imaging system vulnerabilities (DICOM)

# Healthcare-Specific Guidelines
Additional healthcare security considerations specific to this audit.
```

**Result Explanation:**
- `system-prompt`: Replaced with healthcare-specific content
- `analysis-framework`: Preserved from parent (not overridden)
- `examples`: Replaced with healthcare-specific examples
- `compliance-requirements`: Removed (set to null)
- `healthcare-specific-guidelines`: Added from child template

## CLI Commands

### Section Discovery

#### List Available Sections
```bash
# Show sections available for override
prompd show base-template.prmd --sections
```

**Output:**
```
Available Sections for Override
┌──────────────────────┬──────────────────────────────┐
│ Section ID           │ Heading Text                 │
├──────────────────────┼──────────────────────────────┤
│ analysis-framework   │ ## Analysis Framework        │
│ compliance-requirements │ ### Compliance Requirements │
│ examples             │ # Examples                   │
│ system-prompt        │ # System Prompt              │
└──────────────────────┴──────────────────────────────┘

Override Usage Example:
override:
  analysis-framework: "./custom-analysis-framework.md"
  another-section: null  # Remove section
```

#### Detailed Section Information
```bash
# Show sections with content length details
prompd show base-template.prmd --sections --verbose
```

**Output:**
```
Available Sections for Override
┌──────────────────────┬──────────────────────────────┬────────────────┐
│ Section ID           │ Heading Text                 │ Content Length │
├──────────────────────┼──────────────────────────────┼────────────────┤
│ analysis-framework   │ ## Analysis Framework        │          1,247 │
│ compliance-requirements │ ### Compliance Requirements │            892 │
│ examples             │ # Examples                   │            634 │
│ system-prompt        │ # System Prompt              │            312 │
└──────────────────────┴──────────────────────────────┴────────────────┘
```

### Override Validation

#### Basic Override Validation
```bash
# Validate override section IDs against parent template
prompd validate child-template.prmd --check-overrides
```

**Success Output:**
```
✓ child-template.prmd is valid
```

**Error Output:**
```
WARNINGS (2):
  - Override validation: Override section 'system-promtp' not found in parent template. Did you mean: system-prompt? Available sections: analysis-framework, compliance-requirements, examples, system-prompt
  - Override validation: Override section 'invalid-section' not found in parent template. Available sections: analysis-framework, compliance-requirements, examples, system-prompt
```

#### Verbose Override Validation
```bash
# Show detailed override validation information
prompd validate child-template.prmd --check-overrides --verbose
```

**Output:**
```
Override Validation Results:
  ! Override section 'system-promtp' not found in parent template. Did you mean: system-prompt?

✓ Override 'examples': ./healthcare-examples.md
✓ Override 'compliance-requirements': [REMOVED]

✓ child-template.prmd is valid
```

### Compilation with Override Tracing

```bash
# Show which overrides are applied during compilation
prompd compile child-template.prmd --verbose
```

**Output:**
```
Lexical Analysis: Processing child-template.prmd
Dependency Resolution: Resolved inheritance: ./base-template.prmd
Applied 3 section overrides from parent: ./base-template.prmd
  - Replacing section 'system-prompt' with content from ./healthcare-system-prompt.md
  - Removing section 'compliance-requirements'
  - Keeping section 'analysis-framework' from parent
  - Adding new section 'healthcare-guidelines' from child
Template Processing: Variable substitution complete
Code Generation: Generated markdown output
```

## Error Handling

### Invalid Section ID Format

**Error:**
```yaml
override:
  System_Prompt: "./custom.md"  # Invalid: uppercase and underscore
```

**Result:**
```
ValidationError: Override section ID must use kebab-case (lowercase letters, numbers, hyphens): System_Prompt
```

### Section Not Found in Parent

**Error:**
```yaml
override:
  nonexistent-section: "./custom.md"
```

**Result:**
```
Warning: Override section 'nonexistent-section' not found in parent template.
Available sections: system-prompt, analysis-framework, examples
```

### Override File Not Found

**Error:**
```yaml
override:
  system-prompt: "./missing-file.md"
```

**Result:**
```
ValidationError: Override content file not found: /path/to/missing-file.md
Referenced in override path: ./missing-file.md
```

### Path Traversal Prevention

**Error:**
```yaml
override:
  system-prompt: "../../../etc/passwd"
```

**Result:**
```
ValidationError: Override path '../../../etc/passwd' attempts to access files outside the base directory.
For security reasons, override files must be within the project directory.
```

## Best Practices

### 1. Organize Override Files

```
project/
├── templates/
│   ├── base-audit.prmd
│   ├── healthcare-audit.prmd
│   └── financial-audit.prmd
├── content/
│   ├── system-prompts/
│   │   ├── healthcare-system.md
│   │   └── financial-system.md
│   ├── examples/
│   │   ├── healthcare-examples.md
│   │   └── financial-examples.md
│   └── compliance/
│       ├── hipaa-requirements.md
│       └── sox-requirements.md
```

### 2. Use Descriptive Section IDs

```yaml
# ✅ GOOD - Clear, descriptive section IDs
override:
  system-prompt: "./content/healthcare-system-prompt.md"
  risk-assessment-framework: "./content/healthcare-risk-framework.md"
  compliance-requirements: "./content/hipaa-compliance.md"

# ❌ AVOID - Vague or unclear section IDs
override:
  section1: "./file1.md"
  prompt: "./prompt.md"
  stuff: "./content.md"
```

### 3. Document Section IDs in Parent Templates

```markdown
<!-- Templates should document their available sections -->
<!-- section-id: system-prompt -->
# System Prompt
<!-- Available for override: customize the system-level instructions -->

<!-- section-id: analysis-framework -->
# Analysis Framework
<!-- Available for override: replace with domain-specific methodology -->

<!-- section-id: examples -->
# Examples
<!-- Available for override: provide domain-specific examples -->
```

### 4. Validate Before Deployment

```bash
# Always validate overrides before using templates
prompd validate my-template.prmd --check-overrides --verbose

# Test compilation to ensure overrides work correctly
prompd compile my-template.prmd --verbose -o test-output.md
```

### 5. Use Relative Paths

```yaml
# ✅ GOOD - Relative paths are portable
override:
  system-prompt: "./content/system-prompt.md"
  examples: "../shared/examples.md"

# ❌ AVOID - Absolute paths break portability
override:
  system-prompt: "/home/user/project/content/system-prompt.md"
```

## Advanced Patterns

### 1. Multi-Level Inheritance with Overrides

```yaml
# base-audit.prmd (root)
---
name: "Base Audit"
---

# grandchild-audit.prmd
---
name: "Specialized Audit"
inherits: "./child-audit.prmd"  # Which inherits from base-audit.prmd
override:
  system-prompt: "./highly-specialized-system.md"
  # Overrides apply to the entire inheritance chain
---
```

### 2. Conditional Overrides with Parameters

```yaml
---
name: "Configurable Audit"
inherits: "./base-audit.prmd"
override:
  compliance-requirements: "./{compliance_standard}-requirements.md"
parameters:
  - name: compliance_standard
    type: string
    required: true
    description: "Compliance standard (hipaa, sox, pci)"
---
```

### 3. Section Reordering

```yaml
# Sections maintain the order from parent template
# Child sections are appended after parent sections
# Override replacements maintain original position
```

## Migration Guide

### From Simple Inheritance

**Before (simple concatenation):**
```yaml
---
inherits: "./parent.prmd"
---

# My Custom Content
This gets appended to parent content.
```

**After (section-based override):**
```yaml
---
inherits: "./parent.prmd"
override:
  specific-section: "./my-custom-content.md"
---

# Additional Content
This still gets appended as a new section.
```

### From Duplicated Templates

**Before (template duplication):**
```
base-template.prmd         (1000 lines)
healthcare-template.prmd   (1050 lines, 95% duplicate)
financial-template.prmd    (1020 lines, 98% duplicate)
```

**After (section-based inheritance):**
```
base-template.prmd            (1000 lines)
healthcare-template.prmd      (30 lines, inherits + overrides)
financial-template.prmd       (25 lines, inherits + overrides)
```

## Troubleshooting

### Common Issues

**1. Override Not Applied**
- Check section ID spelling and case sensitivity
- Verify parent template actually contains the section
- Use `prompd show parent.prmd --sections` to see available sections

**2. File Not Found Errors**
- Verify file paths are relative to the .prmd file location
- Check file exists and has proper permissions
- Ensure file extension is included in path

**3. Section ID Conflicts**
- Use explicit section ID comments for precise control
- Check for duplicate section IDs in content
- Use `prompd validate --check-overrides --verbose` for detailed errors

**4. Inheritance Chain Issues**
- Verify parent template exists and is valid
- Check for circular inheritance references
- Test each level of inheritance independently

### Debug Commands

```bash
# Show what sections are available for override
prompd show parent-template.prmd --sections --verbose

# Validate override configuration
prompd validate child-template.prmd --check-overrides --verbose

# See detailed compilation process
prompd compile child-template.prmd --verbose

# Test specific parameter combinations
prompd compile template.prmd -p compliance_standard=hipaa --verbose
```

## Performance Considerations

### File Loading Optimization

- Override files are loaded only during compilation
- Multiple templates can reference the same override files efficiently
- Large binary files (Excel, PDF) are processed on-demand

### Section Processing

- Section parsing is optimized for typical template sizes (< 100KB)
- Memory usage scales linearly with content size
- Compilation time is dominated by LLM provider calls, not section processing

### Caching

- Parsed sections are cached during compilation
- Override file contents are cached per compilation session
- Package references leverage the existing package cache system

## API Reference

### SectionOverrideProcessor

```python
from prompd.section_override_processor import SectionOverrideProcessor

processor = SectionOverrideProcessor()

# Extract sections from content
sections = processor.extract_sections(markdown_content)

# Apply overrides
result = processor.apply_overrides(
    parent_sections=parent_sections,
    child_sections=child_sections,
    overrides=override_dict,
    base_dir=Path("/project/dir"),
    verbose=True
)
```

### Parser Integration

```python
from prompd.parser import PrompdParser

parser = PrompdParser()

# Get section summary for CLI display
summary = parser.get_section_summary(Path("template.prmd"))

# Validate overrides against parent
warnings = parser.validate_overrides_against_parent(
    child_file=Path("child.prmd"),
    parent_file=Path("parent.prmd")
)
```

## Future Enhancements

### Planned Features

1. **Section Dependencies**: Declare dependencies between sections
2. **Conditional Sections**: Show/hide sections based on parameters
3. **Section Templates**: Reusable section patterns
4. **Visual Override Editor**: GUI for managing section overrides
5. **Override Conflicts**: Advanced conflict resolution for complex inheritance

### Backwards Compatibility

- Simple concatenation inheritance continues to work
- Existing templates without overrides are unaffected
- Migration is opt-in by adding `override:` field

This section-based override system transforms prompd inheritance from simple concatenation into a sophisticated template composition framework, enabling precise control over inherited content while maintaining simplicity for basic use cases.