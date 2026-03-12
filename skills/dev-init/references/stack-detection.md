# Tech Stack Detection Rules

## Detection Priority

When multiple signals exist, use this priority order:

1. **Lock files** → definitive package manager
2. **Config files** → definitive framework
3. **package.json dependencies** → supplementary tech stack info
4. **Directory structure** → architecture patterns

## Package Manager Signals

| Signal | Package Manager |
|--------|----------------|
| `bun.lockb` or `bun.lock` | bun |
| `pnpm-lock.yaml` | pnpm |
| `yarn.lock` | yarn |
| `package-lock.json` | npm |
| `Cargo.lock` | cargo (Rust) |
| `go.sum` | go |
| `uv.lock` or `poetry.lock` | uv/poetry (Python) |

## Framework Signals

| Signal | Framework |
|--------|-----------|
| `next.config.*` | Next.js |
| `vite.config.*` | Vite |
| `nuxt.config.*` | Nuxt |
| `angular.json` | Angular |
| `remix.config.*` | Remix |
| `astro.config.*` | Astro |
| `svelte.config.*` | SvelteKit |

## Monorepo Detection

A directory is a subproject if it contains its own:
- `package.json` (Node.js)
- `Cargo.toml` (Rust)
- `go.mod` (Go)
- `pyproject.toml` (Python)

For each subproject, run detection independently and generate a separate rule file.

## CLAUDE.md Template Variables

After detection, map results to CLAUDE.md template:

| Variable | Source |
|----------|--------|
| `dev_command` | `scripts.dev` from package.json |
| `build_command` | `scripts.build` from package.json |
| `lint_command` | `scripts.lint` from package.json, or framework default |
| `test_command` | `scripts.test` from package.json |
| `framework_desc` | Framework name + version + key dependencies |
