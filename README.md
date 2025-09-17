# Prompd Docs

Centralized documentation and runnable examples.

## Core Docs

- ECOSYSTEM: `./ECOSYSTEM.md`
- Registry API: `./REGISTRY-API.md`
- Format Spec: `./FORMAT.md`
- **Inheritance System**: `./INHERITANCE.md` - Complete guide to template inheritance and composition
- Consolidated Summary: `./prompd.md`
- Legacy Architecture (reference): `./COMPOSABLE-ARCHITECTURE.md`

## Examples

- Prompts: `./examples/prompds/`
- Params: `./examples/params/`
- Script: `./examples/run-get-user-info.sh`

## Editor

- Design Doc: `./editor/EDITOR.md`

### Quickstart

```bash
# Validate the included example
prompd validate ./examples/prompds/get-user-info-extended.prmd

# Compile to Markdown (resolves package refs automatically)
prompd compile ./examples/prompds/get-user-info-extended.prmd \
  --to-markdown -o ./examples/out.get-user-info.md

# Run with parameters
prompd run ./examples/prompds/get-user-info-extended.prmd \
  --params-file ./examples/params/get-user-info.json
```
