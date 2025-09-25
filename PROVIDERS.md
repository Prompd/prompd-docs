# Provider Management Guide

> **⚠️ READ-ONLY**: This file is maintained by the documentation system. Do not edit directly unless you are the repository owner with override permissions.

## Overview

Prompd supports multiple LLM providers through a unified interface, including built-in providers and custom OpenAI-compatible APIs. This enables seamless switching between different AI models while maintaining consistent prompt formats.

## Built-in Providers

Prompd comes with first-class support for major LLM providers:

### OpenAI
- **Provider ID**: `openai`
- **Models**: 
  - `gpt-4o` (GPT-4 Omni)
  - `gpt-4o-mini` (GPT-4 Omni Mini)
  - `gpt-4` (GPT-4)
  - `gpt-4-turbo` (GPT-4 Turbo)
  - `gpt-3.5-turbo` (GPT-3.5 Turbo)
- **Authentication**: Set `OPENAI_API_KEY` environment variable
- **API Endpoint**: `https://api.openai.com/v1`

```bash
# Set API key
export OPENAI_API_KEY="sk-your-openai-key"

# Execute prompt
prompd run example.prmd --provider openai --model gpt-4o
```

### Anthropic
- **Provider ID**: `anthropic`
- **Models**:
  - `claude-3-5-sonnet-20241022` (Claude 3.5 Sonnet)
  - `claude-3-opus-20240229` (Claude 3 Opus)
  - `claude-3-sonnet-20240229` (Claude 3 Sonnet)
  - `claude-3-haiku-20240307` (Claude 3 Haiku)
- **Authentication**: Set `ANTHROPIC_API_KEY` environment variable
- **API Endpoint**: `https://api.anthropic.com`

```bash
# Set API key
export ANTHROPIC_API_KEY="sk-ant-your-anthropic-key"

# Execute prompt
prompd run example.prmd --provider anthropic --model claude-3-5-sonnet-20241022
```

### Ollama (Local)
- **Provider ID**: `ollama`
- **Models**: Any model available in your local Ollama instance
  - `llama3.2` (Llama 3.2)
  - `qwen2.5` (Qwen 2.5)
  - `mixtral` (Mixtral)
  - `phi3` (Phi-3)
  - `codellama` (Code Llama)
  - Custom fine-tuned models
- **Setup**: Install and run Ollama locally
- **API Endpoint**: `http://localhost:11434/v1`

```bash
# Install and start Ollama
curl -fsSL https://ollama.ai/install.sh | sh
ollama serve &

# Pull a model
ollama pull llama3.2

# Execute prompt
prompd run example.prmd --provider ollama --model llama3.2
```

## Custom Provider Management

Add any OpenAI-compatible API as a custom provider for maximum flexibility.

### Adding Custom Providers

```bash
prompd config provider add <name> <base_url> <models...> [options]
```

**Parameters:**
- `name` - Unique provider name (alphanumeric, hyphens, underscores only)
- `base_url` - API endpoint URL (must support `/chat/completions`)
- `models` - Space-separated list of available model names

**Options:**
- `--api-key KEY` - API key for authentication
- `--type TYPE` - Provider type (default: `openai-compatible`)

### Provider Examples

#### Groq (Fast Inference)
```bash
# Add Groq with multiple models
prompd config provider add groq https://api.groq.com/openai/v1 \
  llama-3.1-8b-instant \
  llama-3.1-70b-versatile \
  mixtral-8x7b-32768 \
  --api-key gsk_your_groq_api_key

# Use Groq
prompd run prompt.prmd --provider groq --model llama-3.1-8b-instant
```

#### Together AI
```bash
# Add Together AI
prompd config provider add together https://api.together.xyz/v1 \
  "mistralai/Mixtral-8x7B-Instruct-v0.1" \
  "meta-llama/Llama-2-70b-chat-hf" \
  "NousResearch/Nous-Hermes-2-Mixtral-8x7B-DPO" \
  --api-key your_together_api_key

# Use Together AI
prompd run prompt.prmd --provider together \
  --model "mistralai/Mixtral-8x7B-Instruct-v0.1"
```

#### LM Studio (Local GUI)
```bash
# Add LM Studio local server
prompd config provider add lmstudio http://localhost:1234/v1 \
  local-model

# Use LM Studio
prompd run prompt.prmd --provider lmstudio --model local-model
```

#### Fireworks AI
```bash
# Add Fireworks AI
prompd config provider add fireworks https://api.fireworks.ai/inference/v1 \
  "accounts/fireworks/models/llama-v3-70b-instruct" \
  "accounts/fireworks/models/mixtral-8x7b-instruct" \
  --api-key fw_your_fireworks_key

# Use Fireworks AI
prompd run prompt.prmd --provider fireworks \
  --model "accounts/fireworks/models/llama-v3-70b-instruct"
```

#### OpenRouter (Multiple Models via One API)
```bash
# Add OpenRouter
prompd config provider add openrouter https://openrouter.ai/api/v1 \
  "anthropic/claude-3-sonnet" \
  "openai/gpt-4" \
  "meta-llama/llama-3-70b-instruct" \
  --api-key sk_or_your_openrouter_key

# Use OpenRouter
prompd run prompt.prmd --provider openrouter \
  --model "anthropic/claude-3-sonnet"
```

## Provider Management Commands

### List Providers
```bash
# Show all providers (built-in and custom)
prompd config provider list

# Example output:
# Built-in Providers:
#   openai (5 models) - OpenAI GPT models
#   anthropic (4 models) - Anthropic Claude models  
#   ollama (local) - Local Ollama instance
# 
# Custom Providers:
#   groq (3 models) - Fast inference API
#   together (2 models) - Open source models
```

### Show Provider Details
```bash
# Show detailed provider information
prompd config provider show <name>

# Example:
prompd config provider show groq
# Provider: groq
# Type: Custom (OpenAI-compatible)
# Base URL: https://api.groq.com/openai/v1
# API Key: ✓ Set (gsk_***...)
# Models:
#   - llama-3.1-8b-instant
#   - llama-3.1-70b-versatile
#   - mixtral-8x7b-32768
```

### Update Provider API Keys
```bash
# Update API key for existing provider
prompd config provider setkey <name> <api_key>

# Example:
prompd config provider setkey groq gsk_new_api_key_here
```

### Remove Custom Providers
```bash
# Remove with confirmation
prompd config provider remove <name>

# Remove without confirmation
prompd config provider remove <name> --yes

# Example:
prompd config provider remove old-provider --yes
```

## Configuration Management

### Configuration File
Provider settings are stored in `~/.prompd/config.yaml`:

```yaml
# Default provider and model
default_provider: openai
default_model: gpt-4o

# Built-in provider API keys
api_keys:
  openai: "sk-your-openai-key"
  anthropic: "sk-ant-your-anthropic-key"

# Custom provider configurations
custom_providers:
  groq:
    base_url: "https://api.groq.com/openai/v1"
    api_key: "gsk-your-groq-key"
    type: "openai-compatible"
    models:
      - "llama-3.1-8b-instant"
      - "llama-3.1-70b-versatile"
      - "mixtral-8x7b-32768"
    enabled: true
    
  together:
    base_url: "https://api.together.xyz/v1"
    api_key: "your-together-key"
    type: "openai-compatible"
    models:
      - "mistralai/Mixtral-8x7B-Instruct-v0.1"
      - "meta-llama/Llama-2-70b-chat-hf"
    enabled: true

# Registry settings
registry:
  default: prompdhub
  registries:
    prompdhub:
      url: "https://registry.prompdhub.ai"
      token: "prompd_your_registry_token"
```

### Environment Variables
API keys can be managed via environment variables:

```bash
# Built-in providers
export OPENAI_API_KEY="sk-your-openai-key"
export ANTHROPIC_API_KEY="sk-ant-your-anthropic-key"

# Custom providers (provider name in uppercase)
export GROQ_API_KEY="gsk-your-groq-key"
export TOGETHER_API_KEY="your-together-key"
export FIREWORKS_API_KEY="fw-your-fireworks-key"
```

### API Key Priority
When resolving API keys, Prompd checks in this order:
1. Command line `--api-key` parameter
2. Provider-specific key in config file
3. Environment variable `{PROVIDER_NAME}_API_KEY`
4. Built-in environment variables (for built-in providers)

## Provider-Specific Configurations

### Model Parameters
Configure provider-specific parameters in `.prmd` files:

```yaml
---
name: analysis-prompt
parameters:
  - name: code
    type: string
    required: true

# Provider-specific configurations
providers:
  openai:
    model: gpt-4o
    temperature: 0.1
    max_tokens: 2000
    top_p: 0.9
    
  anthropic:
    model: claude-3-5-sonnet-20241022
    temperature: 0.2
    max_tokens: 4000
    
  groq:
    model: llama-3.1-8b-instant
    temperature: 0.1
    max_tokens: 1000
---

Analyze this code: {code}
```

### Usage with Provider Override
```bash
# Use provider-specific configuration
prompd run analysis.prmd --provider anthropic -p code="function test() { return true; }"

# Override model for specific run
prompd run analysis.prmd --provider openai --model gpt-4-turbo -p code="..."
```

## OpenAI-Compatible APIs

Many providers support the OpenAI Chat Completions API format. Popular options:

| Provider | Base URL | Notes | Cost |
|----------|----------|--------|------|
| **Groq** | `https://api.groq.com/openai/v1` | Ultra-fast inference, limited models | Free tier + paid |
| **Together AI** | `https://api.together.xyz/v1` | Many open source models | Pay per token |
| **Fireworks AI** | `https://api.fireworks.ai/inference/v1` | Fast inference, curated models | Pay per token |
| **OpenRouter** | `https://openrouter.ai/api/v1` | Access many models via one API | Pay per token |
| **Anyscale** | `https://api.endpoints.anyscale.com/v1` | Open source models | Pay per token |
| **Perplexity** | `https://api.perplexity.ai` | Search-augmented models | Pay per token |
| **LM Studio** | `http://localhost:1234/v1` | Local models with GUI | Free (local) |
| **Ollama** | `http://localhost:11434/v1` | Local models, CLI-based | Free (local) |

### Testing Compatibility
Before adding a new provider, test compatibility:

```bash
# Test with curl
curl -X POST https://api.example.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your-api-key" \
  -d '{
    "model": "test-model",
    "messages": [{"role": "user", "content": "Hello"}],
    "max_tokens": 50
  }'

# Add if compatible
prompd config provider add test-provider https://api.example.com/v1 test-model \
  --api-key your-key

# Test with simple prompt
prompd run examples/basic/greeting.prmd \
  --provider test-provider \
  --model test-model
```

## Default Provider Configuration

### Set Global Defaults
```bash
# View current configuration
prompd config show

# Edit configuration file directly
# File location: ~/.prompd/config.yaml
# Set default_provider: anthropic
# Set default_model: claude-3-5-sonnet-20241022
```

### Project-Specific Defaults
Create a `.prompd/config.yaml` file in your project:

```yaml
# Project-specific defaults
default_provider: groq
default_model: llama-3.1-8b-instant

# Project-specific API keys (not recommended for security)
api_keys:
  groq: "project-specific-key"
```

### Execution Without Specifying Provider
```bash
# Uses default provider and model
prompd run analysis.prmd -p code="function test() { return true; }"

# Override just the model
prompd run analysis.prmd --model gpt-4-turbo -p code="..."

# Override just the provider (uses provider's default model)
prompd run analysis.prmd --provider anthropic -p code="..."
```

## Advanced Features

### Provider Fallbacks
Configure automatic fallbacks in `.prmd` files:

```yaml
---
name: robust-analysis
fallback_providers:
  - provider: openai
    model: gpt-4o
  - provider: anthropic  
    model: claude-3-5-sonnet-20241022
  - provider: groq
    model: llama-3.1-8b-instant
---

Analyze this code with automatic provider fallback.
```

### Batch Processing with Multiple Providers
```bash
# Run same prompt with multiple providers for comparison
prompd run analysis.prmd --providers openai,anthropic,groq \
  -p code="function unsafe(input) { return eval(input); }"

# Output includes results from all providers with performance metrics
```

### Provider Health Monitoring
```bash
# Check provider availability by listing providers
prompd config provider list

# Test connectivity by attempting to use provider
prompd run examples/basic/greeting.prmd --provider <name> --model <model>
```

## Troubleshooting

### Connection Issues
```bash
# Debug with verbose output
prompd run prompt.prmd --provider <name> --verbose

# Check network connectivity
curl -I https://api.provider.com/v1/chat/completions

# Verify provider configuration
prompd config provider show <name>
```

### Authentication Problems
```bash
# Verify API key is set
prompd config provider show <name>

# Test authentication by attempting a simple run
prompd run examples/basic/greeting.prmd --provider <name> --model <model>

# Re-add provider with new key
prompd config provider remove <name> --yes
prompd config provider add <name> <url> <models> --api-key <new-key>
```

### Model Not Available
```bash
# List available models for provider
prompd config provider show <name>

# Update provider model list
prompd config provider add <name> <url> <updated-models> --api-key <key>

# Check provider's API documentation for current model names
```

### Performance Issues
```bash
# Compare provider response times manually
time prompd run examples/basic/greeting.prmd --provider openai --model gpt-4o
time prompd run examples/basic/greeting.prmd --provider anthropic --model claude-3-5-sonnet-20241022
time prompd run examples/basic/greeting.prmd --provider groq --model llama-3.1-8b-instant

# Use faster providers for development
# Edit ~/.prompd/config.yaml and set:
# default_provider: groq
```

## Security Best Practices

### API Key Management
- **Environment Variables**: Store keys in environment variables for production
- **Config Files**: Use config files only for development/testing
- **Version Control**: Never commit API keys to repositories
- **Rotation**: Rotate API keys regularly
- **Permissions**: Use API keys with minimal required permissions

### Provider Trust
- **Verify Endpoints**: Ensure provider URLs are correct and trusted
- **Data Privacy**: Review provider data handling policies
- **Rate Limits**: Respect provider rate limits to avoid service disruption
- **Fallbacks**: Configure reliable fallback providers

### Network Security
- **HTTPS Only**: All provider endpoints must use HTTPS
- **Certificate Validation**: Enable SSL certificate validation
- **Proxy Support**: Configure proxy settings if required
- **Firewall Rules**: Allow outbound connections to provider endpoints

## Migration Guide

### From Other Tools
- **LangChain**: Map provider configurations to Prompd custom providers
- **OpenAI CLI**: Replace direct API calls with `prompd run`
- **Custom Scripts**: Convert to `.prmd` files with provider abstraction

### Updating Provider Configurations
```bash
# View current configuration
prompd config show

# Edit configuration file directly
# File location: ~/.prompd/config.yaml

# Verify changes
prompd config provider list
```

---

*Provider management is implemented in the Python CLI (`prompd-cli/cli/python/prompd/providers/`) with built-in support for major LLMs and extensible custom provider system.*