# Prompd CLI Reference

> **⚠️ READ-ONLY**: This file is maintained by the documentation system. Do not edit directly unless you are the repository owner with override permissions.

Prompd provides multiple CLI implementations with **100% feature parity**:

## Installation Options

### Python CLI (Full Featured)
```bash
# Install from PyPI
pip install prompd

# Or install from source
pip install -e cli/python/
```

### Go CLI (Full Parity, Zero Dependencies) ⭐ **NEW: 100% COMPLETE!**
```bash
# Use pre-built binaries from dist/
./dist/prompd-windows-amd64.exe    # Windows
./dist/prompd-linux-amd64          # Linux  
./dist/prompd-darwin-amd64         # macOS Intel
./dist/prompd-darwin-arm64         # macOS Apple Silicon

# Or build from source
cd cli/go
go build -o prompd ./cmd/prompd
```

### Node.js CLI (Developer Focused)
```bash
cd cli/npm
npm install
npm run build
```

**🎉 All CLIs now provide identical functionality with the same command syntax!** The Go CLI has achieved **100% feature parity** including execute, render, git operations, version management, provider management, and registry operations.

## Global Options

These options work with all commands:

- `--help` - Show help message
- `--version` - Show version number

## Commands

### `prompd run`

Run a .prmd file with an LLM provider.

```bash
prompd run <file> --provider <provider> --model <model> [options]
```

#### Required Arguments
- `file` - Path to .prmd file
- `--provider` - LLM provider (openai, anthropic, ollama)
- `--model` - Model name (gpt-4, claude-3-opus, etc.)

#### Options
- `-p, --param KEY=VALUE` - Set parameter value (can use multiple times)
- `-f, --param-file FILE` - Load parameters from JSON file (can use multiple)
- `--api-key KEY` - Override API key for provider
- `-o, --output FILE` - Save response to file
- `--version VERSION` - Execute a specific version (e.g., '1.2.3', 'HEAD', commit hash)
- `-v, --verbose` - Show detailed execution information

#### Examples

```bash
# Basic execution
prompd run prompt.prmd --provider openai --model gpt-4

# With parameters
prompd run prompt.prmd --provider openai --model gpt-4 \
  -p language=Python \
  -p style=detailed

# With parameter file
prompd run prompt.prmd --provider anthropic --model claude-3-opus \
  -f params.json

# Save output
prompd run prompt.prmd --provider openai --model gpt-4 \
  -o response.txt

# Override API key
prompd run prompt.prmd --provider openai --model gpt-4 \
  --api-key sk-...

# Execute a specific version
prompd run prompt.prmd --provider openai --model gpt-4 \
  --version 1.2.3 -p name=Alice

# Execute last committed version
prompd run prompt.prmd --provider openai --model gpt-4 \
  --version HEAD
```

### `prompd compile`

Compile a .prmd file with parameters and return the compiled prompt text.

```bash
prompd compile <file> [options]
```

#### Required Arguments
- `file` - Path to .prmd file

#### Options
- `-p, --param <key=value>` - Set parameter value
- `--param-file <file>` - Load parameters from JSON file  
- `-o, --output <file>` - Save compiled output to file

#### Examples
```bash
# compile with parameters
prompd compile prompt.prmd -p name=Alice -p style=formal

# Load parameters from file
prompd compile prompt.prmd --param-file params.json

# Save compiled output
prompd compile prompt.prmd -p name=Bob -o rendered.txt

# Combine command line and file parameters
prompd compile prompt.prmd --param-file params.json -p override=value
```

### `prompd validate`

Validate a .prmd file's syntax and structure.

```bash
prompd validate <file> [options]
```

#### Arguments
- `file` - Path to .prmd file

#### Options
- `-v, --verbose` - Show detailed validation results
- `--git` - Include git history consistency checks
- `--version-only` - Only validate version-related aspects
- `--check-overrides` - Validate section overrides against parent template

#### Examples

```bash
# Basic validation
prompd validate prompt.prmd

# Detailed validation
prompd validate prompt.prmd --verbose

# Check git consistency
prompd validate prompt.prmd --git

# Version validation only
prompd validate prompt.prmd --version-only

# Validate section overrides
prompd validate child-template.prmd --check-overrides

# Detailed override validation
prompd validate child-template.prmd --check-overrides --verbose
```

#### Validation Checks
- YAML syntax validity
- Required fields presence
- Name format (kebab-case)
- Version format (semantic)
- Parameter definitions
- Variable references
- Type consistency
- **Section override validation** (with `--check-overrides`):
  - Override section IDs exist in parent template
  - Override files exist and are accessible
  - Parent template file exists and is valid
  - Typo detection with suggestions

#### Override Validation Output

**Success:**
```
✓ child-template.prmd is valid
```

**With Warnings:**
```
WARNINGS (1):
  - Override validation: Override section 'system-promtp' not found in parent template. Did you mean: system-prompt?

✓ child-template.prmd has warnings
```

**Verbose Output:**
```
Override Validation Results:
  ! Override section 'examples-old' not found in parent template. Available sections: system-prompt, examples, analysis-framework
  ✓ Override 'system-prompt': ./healthcare-system.md
  ✓ Override 'examples': [REMOVED]

✓ child-template.prmd is valid
```

### `prompd git`

Git operations for .prmd files.

#### Subcommands

##### `prompd git add`

Add .prmd files to git staging area.

```bash
prompd git add <files...> [options]
```

Options:
- `-v, --verbose` - Show git output

Examples:
```bash
# Add single file
prompd git add prompts/my-prompt.prmd

# Add multiple files
prompd git add prompts/*.prmd
```

##### `prompd git remove`

Remove .prmd files from git tracking.

```bash
prompd git remove <files...> [options]
```

Options:
- `--cached` - Only remove from index, keep in working directory
- `-v, --verbose` - Show git output

Examples:
```bash
# Remove file completely
prompd git remove old-prompt.prmd

# Remove from tracking but keep file
prompd git remove old-prompt.prmd --cached
```

##### `prompd git status`

Show git status for .prmd files.

```bash
prompd git status [options]
```

Options:
- `-p, --path PATH` - Check status for specific path

Example:
```bash
prompd git status
```

##### `prompd git commit`

Commit staged .prmd files.

```bash
prompd git commit -m <message> [options]
```

Options:
- `-m, --message TEXT` - Commit message (required)
- `-a, --all` - Automatically stage all modified .prmd files

Examples:
```bash
# Commit staged files
prompd git commit -m "Update prompt parameters"

# Stage and commit all modified .prmd files
prompd git commit -m "Fix validation rules" --all
```

##### `prompd git checkout`

Checkout a specific version of a .prmd file.

```bash
prompd git checkout <file> <version> [options]
```

Arguments:
- `file` - Path to .prmd file
- `version` - Version to checkout (semantic version, tag, commit hash, HEAD, HEAD~1, etc.)

Options:
- `-o, --output FILE` - Output to different file instead of overwriting

Examples:
```bash
# Checkout version 1.2.3 (overwrites current file)
prompd git checkout prompts/my-prompt.prmd 1.2.3

# Checkout to a different file
prompd git checkout prompts/my-prompt.prmd 1.2.3 -o prompts/my-prompt.prmd

# Checkout last committed version
prompd git checkout prompts/my-prompt.prmd HEAD

# Checkout previous commit
prompd git checkout prompts/my-prompt.prmd HEAD~1

# Checkout specific commit
prompd git checkout prompts/my-prompt.prmd abc1234
```

### `prompd version`

Manage semantic versions with git integration.

#### Subcommands

##### `prompd version bump`

Increment version and create git tag.

```bash
prompd version bump <file> <bump_type> [options]
```

Arguments:
- `file` - Path to .prmd file
- `bump_type` - Version increment type (major, minor, patch)

Options:
- `-m, --message TEXT` - Commit message
- `--dry-run` - Preview changes without applying

Examples:
```bash
# Patch version (1.0.0 -> 1.0.1)
prompd version bump prompt.prmd patch

# Minor version (1.0.0 -> 1.1.0)
prompd version bump prompt.prmd minor -m "Add new feature"

# Major version (1.0.0 -> 2.0.0)
prompd version bump prompt.prmd major --dry-run
```

##### `prompd version history`

Show version history from git tags.

```bash
prompd version history <file> [options]
```

Options:
- `-n, --limit NUMBER` - Number of versions to show (default: 10)

Example:
```bash
prompd version history prompt.prmd --limit 5
```

##### `prompd version diff`

Compare versions of a file.

```bash
prompd version diff <file> <version1> [version2]
```

Arguments:
- `version1` - First version to compare
- `version2` - Second version (default: HEAD)

Example:
```bash
# Compare two versions
prompd version diff prompt.prmd 1.0.0 2.0.0

# Compare with current
prompd version diff prompt.prmd 1.0.0
```

##### `prompd version validate`

Validate version consistency.

```bash
prompd version validate <file> [options]
```

Options:
- `--git` - Validate against git history

Example:
```bash
prompd version validate prompt.prmd --git
```

##### `prompd version suggest`

Get intelligent version bump suggestions.

```bash
prompd version suggest <file> [options]
```

Options:
- `--changes TEXT` - Description of changes made

Examples:
```bash
# Get suggestion based on changes
prompd version suggest prompt.prmd --changes "Added new feature"

# Auto-detect suggestion
prompd version suggest prompt.prmd
```

### `prompd list`

List available .prmd files in a directory.

```bash
prompd list [options]
```

#### Options
- `-p, --path DIR` - Directory to search (default: prompts)
- `-d, --detailed` - Show detailed information

#### Examples

```bash
# List files in default directory
prompd list

# List files in specific directory
prompd list --path ./my-prompts

# Show detailed information
prompd list --detailed
```

### `prompd show`

Display the structure and parameters of a .prmd file.

```bash
prompd show <file> [options]
```

#### Options
- `--sections` - Show available section IDs for override reference
- `--verbose` - Show detailed section information including content length

#### Basic Output Includes
- Name and version
- Description
- Parameter definitions
- Content structure
- Required fields
- Inheritance information
- Section overrides (if present)

#### Section Discovery
```bash
# Show sections available for override
prompd show template.prmd --sections

# Show detailed section information
prompd show template.prmd --sections --verbose
```

**Example Output:**
```
Available Sections for Override
┌──────────────────────┬──────────────────────────────┬────────────────┐
│ Section ID           │ Heading Text                 │ Content Length │
├──────────────────────┼──────────────────────────────┼────────────────┤
│ system-prompt        │ # System Prompt              │            312 │
│ analysis-framework   │ ## Analysis Framework        │          1,247 │
│ examples             │ ### Examples                 │            634 │
└──────────────────────┴──────────────────────────────┴────────────────┘

Override Usage Example:
override:
  system-prompt: "./custom-system-prompt.md"
  examples: null  # Remove section
```

### `prompd config`

Configuration management commands for providers, registries, and settings.

#### Subcommands

##### `prompd config provider list`

List all available providers (built-in and custom).

```bash
prompd config provider list
```

Shows:
- Provider name and type (Built-in/Custom)
- Available models
- Connection status

Example output:
```
┌─ Provider ─────────────────────────────┐
│ openai (Built-in)                      │
│ Models: gpt-4, gpt-4-turbo, gpt-4o ... │
└────────────────────────────────────────┘
┌─ Provider ─────────────────────────────┐
│ local-ollama (Custom)                  │
│ Models: llama3.2, qwen2.5             │
└────────────────────────────────────────┘
```

##### `prompd config provider add`

Add a custom LLM provider with OpenAI-compatible API.

```bash
prompd config provider add <name> <base_url> <models...> [options]
```

**Arguments:**
- `name` - Provider name (e.g., 'local-ollama', 'groq-api')
- `base_url` - API endpoint URL (e.g., 'http://localhost:11434/v1')
- `models` - Space-separated list of model names

**Options:**
- `--api-key KEY` - API key for the provider (optional)
- `--type TYPE` - Provider type (default: openai-compatible)

**Examples:**

```bash
# Add local Ollama instance
prompd config provider add local-ollama http://localhost:11434/v1 \
  llama3.2 qwen2.5 mixtral

# Add Groq with API key
prompd config provider add groq https://api.groq.com/openai/v1 \
  llama-3.1-8b-instant mixtral-8x7b-32768 \
  --api-key gsk_...

# Add local LM Studio
prompd config provider add lmstudio http://localhost:1234/v1 \
  local-model

# Add Together AI
prompd config provider add together https://api.together.xyz/v1 \
  mistralai/Mixtral-8x7B-Instruct-v0.1 \
  --api-key your-api-key
```

##### `prompd config provider show`

Show detailed information about a specific provider.

```bash
prompd config provider show <name>
```

**Example:**
```bash
prompd config provider show local-ollama
```

Output includes:
- Provider type (Built-in/Custom)
- Base URL (for custom providers)
- API key status
- Available models
- Configuration details

##### `prompd config provider remove`

Remove a custom provider.

```bash
prompd config provider remove <name> [options]
```

**Options:**
- `-y, --yes` - Skip confirmation prompt

**Examples:**
```bash
# Remove with confirmation
prompd config provider remove local-ollama

# Remove without confirmation
prompd config provider remove groq-api --yes
```

#### Custom Provider Configuration

Custom providers are stored in `~/.prompd/config.yaml`:

```yaml
custom_providers:
  local-ollama:
    base_url: http://localhost:11434/v1
    models:
      - llama3.2
      - qwen2.5
    api_key: null
    type: openai-compatible
    enabled: true
```

#### Supported Provider Types

Currently supported provider types:
- `openai-compatible` - OpenAI Chat Completions API format

#### OpenAI-Compatible APIs

Many LLM providers support OpenAI's chat completions API format:

| Provider | Base URL | Example Models |
|----------|----------|----------------|
| Ollama | `http://localhost:11434/v1` | llama3.2, qwen2.5 |
| LM Studio | `http://localhost:1234/v1` | local-model |
| Groq | `https://api.groq.com/openai/v1` | llama-3.1-8b-instant |
| Together AI | `https://api.together.xyz/v1` | mistralai/Mixtral-8x7B |
| Perplexity | `https://api.perplexity.ai` | llama-3.1-sonar-small |
| Fireworks | `https://api.fireworks.ai/inference/v1` | accounts/fireworks/models/llama-v3p1-8b-instruct |

#### Using Custom Providers

Once added, custom providers work exactly like built-in providers:

```bash
# Execute with custom provider
prompd run prompt.prmd \
  --provider local-ollama \
  --model llama3.2 \
  -p topic="machine learning"

# Use with any prompd command
prompd validate prompt.prmd  # Works with any provider
```

#### Example

```bash
prompd show prompt.prmd
```

##### `prompd config provider setkey`

Set or update API key for a provider.

```bash
prompd config provider setkey <provider_name> <api_key>
```

**Examples:**
```bash
# Set API key for OpenAI
prompd config provider setkey openai sk-...

# Set API key for custom provider
prompd config provider setkey local-ollama your-api-key
```

##### `prompd config show`

Show all configuration settings.

```bash
prompd config show
```

Displays:
- Default provider and model settings
- All configured custom providers
- Registry configurations
- API key status (masked for security)
- Global settings (timeout, retries, etc.)

##### `prompd config registry list`

List all configured registries.

```bash
prompd config registry list
```

##### `prompd config registry add`

Add a new registry configuration.

```bash
prompd config registry add <name> <url> [options]
```

**Options:**
- `--api-key KEY` - Registry authentication API key
- `--set-default` - Set as default registry

**Examples:**
```bash
# Add local registry
prompd config registry add local http://localhost:4000

# Add private registry with API key
prompd config registry add company https://registry.company.com \
  --api-key prompd_... --set-default
```

##### `prompd config registry remove`

Remove a registry configuration.

```bash
prompd config registry remove <name>
```

##### `prompd config registry set-default`

Set the default registry.

```bash
prompd config registry set-default <name>
```

##### `prompd config registry show`

Show registry details.

```bash
prompd config registry show [name]
```

#### Alias Commands

For convenience, the following alias commands are available:

```bash
# These are equivalent:
prompd config providers     # Alias for 'prompd config provider list'
prompd config registries    # Alias for 'prompd config registry list'
```

### `prompd providers`

List available LLM providers and their models.

```bash
prompd providers
```

#### Output
- Available providers (openai, anthropic, ollama)
- Supported models for each provider
- Configuration status

## Configuration

### Environment Variables

```bash
# API Keys
export OPENAI_API_KEY="sk-..."
export ANTHROPIC_API_KEY="sk-ant-..."
export OLLAMA_HOST="http://localhost:11434"

# Defaults
export PROMPD_DEFAULT_PROVIDER="openai"
export PROMPD_DEFAULT_MODEL="gpt-4"
```

### Configuration File

Create `~/.prompd/config.yaml`:

```yaml
default_provider: openai
default_model: gpt-4
timeout: 30
max_retries: 3
verbose: false
api_keys:
  openai: sk-...
  anthropic: sk-ant-...
custom_providers:
  local-ollama:
    base_url: http://localhost:11434/v1
    models:
      - llama3.2
      - qwen2.5
    enabled: true
registry:
  default: prompdhub
  registries:
    prompdhub:
      url: https://registry.prompdhub.ai
      api_key: null
    local:
      url: http://localhost:4000
      api_key: prompd_...
```

### Parameter Files

JSON files for parameter values:

```json
{
  "language": "Python",
  "style": "detailed",
  "max_length": 500,
  "include_examples": true,
  "tags": ["web", "api", "security"]
}
```

Use with `-f` flag:
```bash
prompd run prompt.prmd --provider openai --model gpt-4 -f params.json
```

## Parameter Precedence

Parameters are resolved in this order (highest to lowest priority):

1. Command-line parameters (`-p key=value`)
2. Parameter files (`-f file.json`)
3. Default values in .prmd file
4. Environment variables

## Exit Codes

- `0` - Success
- `1` - General error
- `2` - Validation error
- `3` - Provider error
- `4` - Configuration error
- `5` - File not found

## Working with Versions

### Using Specific Versions

There are multiple ways to work with specific versions of `.prmd` files:

#### 1. Execute a Specific Version Directly
Run a specific version without modifying your working directory:

```bash
# Execute semantic version 1.2.3
prompd run my-prompt.prmd --provider openai --model gpt-4 \
  --version 1.2.3 -p name=Alice

# Execute the last committed version
prompd run my-prompt.prmd --provider openai --model gpt-4 \
  --version HEAD

# Execute a specific commit
prompd run my-prompt.prmd --provider openai --model gpt-4 \
  --version abc1234

# Execute previous commit
prompd run my-prompt.prmd --provider openai --model gpt-4 \
  --version HEAD~1
```

#### 2. Checkout a Version to Working Directory
Retrieve a specific version and save it to disk:

```bash
# Checkout and overwrite current file
prompd git checkout prompts/my-prompt.prmd 1.2.3

# Checkout to a different file (preserve current)
prompd git checkout prompts/my-prompt.prmd 1.2.3 \
  -o prompts/my-prompt-v1.2.3.prmd

# Revert to last committed version
prompd git checkout prompts/my-prompt.prmd HEAD
```

#### 3. Compare Versions
See what changed between versions:

```bash
# Compare two specific versions
prompd version diff prompts/my-prompt.prmd 1.0.0 2.0.0

# Compare version with current working copy
prompd version diff prompts/my-prompt.prmd 1.0.0
```

#### 4. View Version History
See all available versions:

```bash
# Show version history with tags
prompd version history prompts/my-prompt.prmd

# Show last 5 versions
prompd version history prompts/my-prompt.prmd -n 5
```

### Version Workflow Example

```bash
# 1. Check current version
prompd show my-prompt.prmd  # Shows version: 1.0.0

# 2. Make changes to the file
edit my-prompt.prmd

# 3. Test changes
prompd run my-prompt.prmd --provider openai --model gpt-4 \
  -p test=value

# 4. Compare with previous version
prompd version diff my-prompt.prmd 1.0.0

# 5. If changes are good, bump version
prompd version bump my-prompt.prmd minor -m "Add new parameters"
# Creates version 1.1.0 and git tag

# 6. If changes are bad, revert to previous
prompd git checkout my-prompt.prmd 1.0.0

# 7. Or test old version without changing files
prompd run my-prompt.prmd --provider openai --model gpt-4 \
  --version 1.0.0 -p test=value
```

## Examples

### Complete Workflow

```bash
# 1. Create a prompt
cat > code-review.prmd << 'EOF'
---
name: code-reviewer
version: 1.0.0
parameters:
  - name: language
    type: string
    required: true
  - name: code
    type: string
    required: true
---

# System
You are an expert {language} code reviewer.

# User
Review this code:
```{language}
{code}
```
EOF

# 2. Validate it
prompd validate code-review.prmd

# 3. Execute it
prompd run code-review.prmd \
  --provider openai \
  --model gpt-4 \
  -p language=Python \
  -p code="def add(a, b): return a + b"

# 4. Bump version after changes
prompd version bump code-review.prmd patch -m "Improve review criteria"

# 5. View history
prompd version history code-review.prmd
```

### Batch Processing

```bash
# Validate all prompts
for file in prompts/*.prmd; do
  echo "Validating $file"
  prompd validate "$file"
done

# Execute with same parameters
PARAMS="language=Python style=detailed"
for file in prompts/*.prmd; do
  prompd run "$file" \
    --provider openai \
    --model gpt-4 \
    -p $PARAMS \
    -o "outputs/$(basename $file .prmd).txt"
done
```

### CI/CD Integration

```yaml
# GitHub Actions example
name: Validate Prompts
on: [push, pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-python@v2
      - run: pip install prompd
      - run: |
          for file in prompts/*.prmd; do
            prompd validate "$file" --verbose
          done
```

## Troubleshooting

### Common Issues

#### "Missing required field 'name'"
The .prmd file must have a `name` field in the YAML frontmatter.

#### "Undefined variable 'X' referenced"
All variables used in content must be defined in the parameters section.

#### "Provider error: No API key"
Set the API key via environment variable or config file.

#### "Invalid semantic version"
Version must follow format: major.minor.patch (e.g., 1.2.3)

### Debug Mode

Use `-v/--verbose` flag for detailed output:

```bash
prompd run prompt.prmd --provider openai --model gpt-4 -v
```

### Getting Help

```bash
# General help
prompd --help

# Command help
prompd run --help
prompd version bump --help
```