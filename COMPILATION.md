# Prompd Compilation & Context Preservation System

> **⚠️ READ-ONLY**: This file is maintained by the documentation system. Do not edit directly unless you are the repository owner with override permissions.

## Table of Contents
- [Overview](#overview)
- [Package-Time File Conversion](#package-time-file-conversion)
- [Compile-Time Context Integration](#compile-time-context-integration)
- [Format Detection System](#format-detection-system)
- [Code Block Mapping](#code-block-mapping)
- [Binary File Extraction](#binary-file-extraction)
- [Security Through Conversion](#security-through-conversion)
- [Examples](#examples)

## Overview

The Prompd compilation system implements a revolutionary two-stage approach to maximize context preservation for LLMs while maintaining absolute security:

1. **Package-Time Conversion**: All potentially executable or binary files are converted to safe `.ext.txt` formats
2. **Compile-Time Integration**: Original formats are detected and content is wrapped in appropriate markdown code blocks

This strategy provides **maximum context** (LLMs see full source code) with **zero execution risk** (no executable files exist).

## Package-Time File Conversion

### Security Through Renaming

When creating packages, all potentially dangerous or binary files are automatically converted:

```bash
# Original files in source directory:
src/
├── auth.js              # JavaScript file
├── styles.css           # CSS stylesheet  
├── config.html          # HTML template
├── data.xml             # XML data
├── report.pdf           # PDF document
└── analysis.cpp         # C++ source

# After package creation (.pdpkg contents):
src/
├── auth.js.txt          # Safe text version
├── styles.css.txt       # Safe text version
├── config.html.txt      # Safe text version  
├── data.xml.txt         # Safe text version
├── report.pdf.txt       # Extracted text content
└── analysis.cpp.txt     # Safe text version
```

### Filename Conflict Resolution

If conflicts exist between original files and converted names:

```bash
# Source has both:
report.txt               # Original text file
report.pdf               # PDF document

# Package creates:
report.txt               # Original kept as-is (already safe)
report-pdf.txt           # PDF converted with disambiguated name
```

### Binary File Processing

#### Document Extraction
```bash
document.pdf → document.pdf.txt        # Text extracted from PDF
presentation.pptx → presentation.pptx.txt   # Text extracted from slides
spreadsheet.xlsx → spreadsheet-sheet1.csv   # First sheet as CSV
                 → spreadsheet-sheet2.csv   # Second sheet as CSV
                 → spreadsheet-sheet3.csv   # Third sheet as CSV
```

#### Image Files
```bash
# Images kept as-is (safe for documentation)
diagram.png → diagram.png              # No conversion needed
logo.jpg → logo.jpg                    # No conversion needed
icon.gif → icon.gif                    # No conversion needed
```

## Compile-Time Context Integration

### Automatic Format Detection

During compilation, the system detects original formats from filenames:

```javascript
// File: auth.js.txt
function authenticate(user, password) {
    // Authentication logic here
    return jwt.sign({ id: user.id }, secret);
}
```

### Code Block Wrapping

Based on detected format, content is wrapped in appropriate markdown code blocks:

#### JavaScript Detection: `auth.js.txt` → ```javascript
````markdown
```javascript
function authenticate(user, password) {
    // Authentication logic here
    return jwt.sign({ id: user.id }, secret);
}
```
````

#### CSS Detection: `styles.css.txt` → ```css
````markdown
```css
.header {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    padding: 2rem;
}
```
````

#### HTML Detection: `template.html.txt` → ```html
````markdown
```html
<!DOCTYPE html>
<html>
<head>
    <title>Application Template</title>
</head>
<body>
    <header class="header">
        <h1>{{title}}</h1>
    </header>
</body>
</html>
```
````

## Format Detection System

### Detection Algorithm

The system uses filename patterns to detect original formats:

```typescript
function detectOriginalFormat(filename: string): string {
  // Pattern: filename.extension.txt
  const match = filename.match(/^(.+)\.([^.]+)\.txt$/);
  
  if (match) {
    const [_, baseName, extension] = match;
    return extension.toLowerCase();
  }
  
  return 'text';
}
```

### Supported Format Detection

| Filename Pattern | Detected Format | Code Block Language |
|------------------|-----------------|-------------------|
| `*.js.txt`       | JavaScript      | `javascript`      |
| `*.ts.txt`       | TypeScript      | `typescript`      |
| `*.cs.txt`       | C#              | `csharp`          |
| `*.cpp.txt`      | C++             | `cpp`             |
| `*.py.txt`       | Python          | `python`          |
| `*.go.txt`       | Go              | `go`              |
| `*.java.txt`     | Java            | `java`            |
| `*.php.txt`      | PHP             | `php`             |
| `*.rb.txt`       | Ruby            | `ruby`            |
| `*.rs.txt`       | Rust            | `rust`            |
| `*.html.txt`     | HTML            | `html`            |
| `*.css.txt`      | CSS             | `css`             |
| `*.xml.txt`      | XML             | `xml`             |
| `*.svg.txt`      | SVG             | `svg`             |
| `*.json.txt`     | JSON            | `json`            |
| `*.yaml.txt`     | YAML            | `yaml`            |

## Code Block Mapping

### Programming Languages

```typescript
const LANGUAGE_MAPPING = {
  'js': 'javascript',
  'mjs': 'javascript', 
  'ts': 'typescript',
  'tsx': 'typescript',
  'cs': 'csharp',
  'c': 'c',
  'cpp': 'cpp',
  'cc': 'cpp',
  'h': 'c',
  'hpp': 'cpp',
  'py': 'python',
  'go': 'go',
  'java': 'java',
  'kt': 'kotlin',
  'scala': 'scala',
  'php': 'php',
  'rb': 'ruby',
  'rs': 'rust',
  'swift': 'swift',
  'r': 'r',
  'jl': 'julia',
  'm': 'matlab',
  'lua': 'lua'
};
```

### Markup & Configuration

```typescript
const MARKUP_MAPPING = {
  'html': 'html',
  'htm': 'html',
  'xml': 'xml',
  'css': 'css',
  'scss': 'scss',
  'sass': 'sass',
  'less': 'less',
  'svg': 'svg',
  'json': 'json',
  'yaml': 'yaml',
  'yml': 'yaml',
  'toml': 'toml'
};
```

## Binary File Extraction

### PDF Text Extraction

```javascript
// During package creation:
import { extractTextFromPDF } from 'pdf-extraction-library';

async function convertPDF(pdfBuffer: Buffer, filename: string): Promise<string> {
  const extractedText = await extractTextFromPDF(pdfBuffer);
  
  return `# Extracted from ${filename}\n\n${extractedText}`;
}
```

### Excel Sheet Processing  

```javascript
// During package creation:
import { readExcelFile } from 'xlsx-processing-library';

async function convertExcel(xlsxBuffer: Buffer, filename: string): Promise<string[]> {
  const workbook = await readExcelFile(xlsxBuffer);
  const files = [];
  
  for (let i = 0; i < workbook.sheets.length; i++) {
    const sheetData = workbook.sheets[i];
    const csvContent = convertToCSV(sheetData);
    const outputFilename = `${filename}-sheet${i + 1}.csv`;
    files.push({ name: outputFilename, content: csvContent });
  }
  
  return files;
}
```

### Word Document Processing

```javascript
// During package creation:
import { extractTextFromDOCX } from 'docx-extraction-library';

async function convertDOCX(docxBuffer: Buffer, filename: string): Promise<string> {
  const extractedText = await extractTextFromDOCX(docxBuffer);
  const metadata = await extractMetadata(docxBuffer);
  
  return `# Extracted from ${filename}\n\n` +
         `**Document Title:** ${metadata.title}\n` +
         `**Author:** ${metadata.author}\n` +
         `**Created:** ${metadata.created}\n\n` +
         `## Content\n\n${extractedText}`;
}
```

## Security Through Conversion

### Zero Execution Risk

**Before Conversion (DANGEROUS):**
```bash
malicious-package.pdpkg/
├── legitimate.prmd      # Safe prompt file
├── exploit.js          # EXECUTABLE JavaScript - DANGER!
├── backdoor.php        # EXECUTABLE PHP - DANGER!
└── virus.exe           # EXECUTABLE binary - DANGER!
```

**After Conversion (SAFE):**
```bash
malicious-package.pdpkg/
├── legitimate.prmd      # Safe prompt file  
├── exploit.js.txt      # Safe text - cannot execute
├── backdoor.php.txt    # Safe text - cannot execute  
└── virus.exe.txt       # Safe text - cannot execute
```

### Context Preservation

LLMs still receive full context through code blocks:

````markdown
Based on the JavaScript authentication code:

```javascript
function authenticate(user, password) {
    if (!user || !password) {
        throw new Error('Missing credentials');
    }
    
    const hashedPassword = bcrypt.hashSync(password, 10);
    return jwt.sign({ 
        id: user.id, 
        role: user.role 
    }, process.env.JWT_SECRET);
}
```

I can see this code has a security vulnerability...
````

## Examples

### Multi-Language Project Package

**Source Directory:**
```
web-app/
├── frontend/
│   ├── app.js           # JavaScript application
│   ├── styles.css       # CSS styles
│   └── index.html       # HTML template
├── backend/
│   ├── server.py        # Python Flask server
│   ├── auth.py          # Python authentication
│   └── config.yaml      # Configuration
├── docs/
│   ├── api.md           # Documentation (safe)
│   └── architecture.pdf # PDF document
└── README.md            # Documentation (safe)
```

**Package Contents After Conversion:**
```
web-app.pdpkg/
├── frontend/
│   ├── app.js.txt       # Converted JavaScript
│   ├── styles.css.txt   # Converted CSS  
│   └── index.html.txt   # Converted HTML
├── backend/
│   ├── server.py.txt    # Converted Python
│   ├── auth.py.txt      # Converted Python
│   └── config.yaml      # Safe (kept as-is)
├── docs/
│   ├── api.md           # Safe (kept as-is)
│   └── architecture.pdf.txt # Extracted text
├── README.md            # Safe (kept as-is)
└── manifest.json        # Package metadata
```

### Compilation Output

When compiled, the prompt receives properly formatted context:

````markdown
## Frontend JavaScript Application

```javascript
// File: app.js
class AuthManager {
    constructor() {
        this.token = localStorage.getItem('auth_token');
        this.apiBase = 'https://api.example.com';
    }
    
    async login(username, password) {
        const response = await fetch(`${this.apiBase}/auth/login`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ username, password })
        });
        
        if (response.ok) {
            this.token = await response.json().token;
            localStorage.setItem('auth_token', this.token);
        }
    }
}
```

## Frontend Styles

```css
/* File: styles.css */
.auth-form {
    max-width: 400px;
    margin: 2rem auto;
    padding: 2rem;
    border: 1px solid #e1e5e9;
    border-radius: 8px;
    background: white;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

.auth-form input {
    width: 100%;
    padding: 0.75rem;
    margin-bottom: 1rem;
    border: 1px solid #d1d5db;
    border-radius: 4px;
}
```

## Backend Python Server

```python
# File: server.py
from flask import Flask, request, jsonify
from flask_jwt_extended import JWTManager, create_access_token
import bcrypt

app = Flask(__name__)
app.config['JWT_SECRET_KEY'] = 'your-secret-key'
jwt = JWTManager(app)

@app.route('/auth/login', methods=['POST'])
def login():
    username = request.json.get('username')
    password = request.json.get('password')
    
    if not username or not password:
        return jsonify({'error': 'Missing credentials'}), 400
    
    user = authenticate_user(username, password)
    if user:
        access_token = create_access_token(identity=user['id'])
        return jsonify({'token': access_token})
    
    return jsonify({'error': 'Invalid credentials'}), 401
```

## Documentation

Based on the extracted architecture document: The system implements OAuth 2.0 
authentication flow with JWT tokens for session management...
````

This approach provides LLMs with complete context about the codebase structure, implementation details, and documentation while maintaining absolute security through file conversion.

---

*This compilation system represents a breakthrough in AI prompt packaging - combining maximum context preservation with zero security risk through intelligent file conversion and compile-time integration.*