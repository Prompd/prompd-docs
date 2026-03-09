# Prompd Documentation

Official documentation for the [Prompd](https://github.com/prompd) ecosystem — structured, composable prompt engineering for AI workflows.

Prompd treats prompts as versioned software artifacts with typed parameters, inheritance, and a package registry. These docs cover the file format, CLI usage, registry API, and composition system.

## Getting Started

1. **Install the CLI:** `pip install prompd`
2. **Read the format spec:** [FORMAT.md](./FORMAT.md) — how `.prmd` files work
3. **Try the examples:** see [Examples](#examples) below

## Core Documentation

| Document | Description |
|----------|-------------|
| [Format Spec](./FORMAT.md) | `.prmd` file format — YAML frontmatter + Markdown content |
| [CLI Reference](./CLI.md) | Command reference for the Prompd CLI |
| [Inheritance](./INHERITANCE.md) | Template inheritance and composition system |
| [Registry](./REGISTRY.md) | Registry API and package publishing |
| [Ecosystem](./ECOSYSTEM.md) | Overview of the Prompd platform |
| [Packages](./PACKAGE.md) | Package format and distribution |

## Examples

- **Prompts:** [`./examples/prompds/`](./examples/prompds/) — sample `.prmd` files
- **Parameters:** [`./examples/params/`](./examples/params/) — example parameter files
- **Run script:** [`./examples/run-get-user-info.sh`](./examples/run-get-user-info.sh)

```bash
# Validate an example prompt
prompd validate ./examples/prompds/get-user-info-extended.prmd

# Compile to Markdown
prompd compile ./examples/prompds/get-user-info-extended.prmd --to-markdown

# Run with parameters
prompd run ./examples/prompds/get-user-info-extended.prmd \
  --params-file ./examples/params/get-user-info.json
```

## Related

- [Prompd CLI](https://github.com/prompd/prompd-cli) — CLI tools (Python, Go, Node.js)
- [Prompd App](https://github.com/prompd/prompd-app) — Desktop IDE
- [Prompd API](https://github.com/prompd/prompd-api) — API integration packages
- [Community Prompts](https://github.com/prompd/prompds) — Example packages and templates
- [PrompdHub](https://prompdhub.ai) — Package registry

## License

Elastic License 2.0 (ELv2) — see [LICENSE](LICENSE) for details.
