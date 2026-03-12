#!/usr/bin/env bash
# Detect project tech stack from files and configuration
# Usage: detect-stack.sh [project-path]
# Output: JSON-like key=value pairs for easy parsing

set -euo pipefail

PROJECT_PATH="${1:-.}"

echo "=== STACK DETECTION ==="

# Package manager detection
if [ -f "$PROJECT_PATH/bun.lockb" ] || [ -f "$PROJECT_PATH/bun.lock" ]; then
  echo "PACKAGE_MANAGER=bun"
elif [ -f "$PROJECT_PATH/pnpm-lock.yaml" ]; then
  echo "PACKAGE_MANAGER=pnpm"
elif [ -f "$PROJECT_PATH/yarn.lock" ]; then
  echo "PACKAGE_MANAGER=yarn"
elif [ -f "$PROJECT_PATH/package-lock.json" ]; then
  echo "PACKAGE_MANAGER=npm"
elif [ -f "$PROJECT_PATH/Cargo.toml" ]; then
  echo "PACKAGE_MANAGER=cargo"
elif [ -f "$PROJECT_PATH/go.mod" ]; then
  echo "PACKAGE_MANAGER=go"
elif [ -f "$PROJECT_PATH/pyproject.toml" ] || [ -f "$PROJECT_PATH/requirements.txt" ]; then
  echo "PACKAGE_MANAGER=pip/uv"
else
  echo "PACKAGE_MANAGER=unknown"
fi

# Framework detection
if [ -f "$PROJECT_PATH/next.config.js" ] || [ -f "$PROJECT_PATH/next.config.ts" ] || [ -f "$PROJECT_PATH/next.config.mjs" ]; then
  NEXT_VERSION=$(grep -o '"next": "[^"]*"' "$PROJECT_PATH/package.json" 2>/dev/null | head -1 | cut -d'"' -f4)
  echo "FRAMEWORK=nextjs"
  echo "FRAMEWORK_VERSION=$NEXT_VERSION"
elif [ -f "$PROJECT_PATH/vite.config.ts" ] || [ -f "$PROJECT_PATH/vite.config.js" ]; then
  echo "FRAMEWORK=vite"
elif [ -f "$PROJECT_PATH/nuxt.config.ts" ]; then
  echo "FRAMEWORK=nuxt"
elif [ -f "$PROJECT_PATH/angular.json" ]; then
  echo "FRAMEWORK=angular"
elif [ -f "$PROJECT_PATH/Cargo.toml" ]; then
  echo "FRAMEWORK=rust"
elif [ -f "$PROJECT_PATH/go.mod" ]; then
  echo "FRAMEWORK=go"
elif [ -f "$PROJECT_PATH/pyproject.toml" ]; then
  echo "FRAMEWORK=python"
fi

# Language detection
if [ -f "$PROJECT_PATH/tsconfig.json" ]; then
  echo "LANGUAGE=typescript"
elif [ -f "$PROJECT_PATH/jsconfig.json" ] || [ -f "$PROJECT_PATH/package.json" ]; then
  echo "LANGUAGE=javascript"
elif [ -f "$PROJECT_PATH/Cargo.toml" ]; then
  echo "LANGUAGE=rust"
elif [ -f "$PROJECT_PATH/go.mod" ]; then
  echo "LANGUAGE=go"
elif [ -f "$PROJECT_PATH/pyproject.toml" ]; then
  echo "LANGUAGE=python"
fi

# Linter/Formatter detection
if [ -f "$PROJECT_PATH/biome.json" ] || [ -f "$PROJECT_PATH/biome.jsonc" ]; then
  echo "LINTER=biome"
elif [ -f "$PROJECT_PATH/.eslintrc.json" ] || [ -f "$PROJECT_PATH/.eslintrc.js" ] || [ -f "$PROJECT_PATH/eslint.config.js" ] || [ -f "$PROJECT_PATH/eslint.config.mjs" ]; then
  echo "LINTER=eslint"
fi

if [ -f "$PROJECT_PATH/.prettierrc" ] || [ -f "$PROJECT_PATH/.prettierrc.json" ] || [ -f "$PROJECT_PATH/prettier.config.js" ]; then
  echo "FORMATTER=prettier"
fi

# Test runner detection
if grep -q '"vitest"' "$PROJECT_PATH/package.json" 2>/dev/null; then
  echo "TEST_RUNNER=vitest"
elif grep -q '"jest"' "$PROJECT_PATH/package.json" 2>/dev/null; then
  echo "TEST_RUNNER=jest"
elif [ -f "$PROJECT_PATH/pytest.ini" ] || [ -f "$PROJECT_PATH/pyproject.toml" ] && grep -q "pytest" "$PROJECT_PATH/pyproject.toml" 2>/dev/null; then
  echo "TEST_RUNNER=pytest"
else
  echo "TEST_RUNNER=none"
fi

# Scripts detection from package.json
if [ -f "$PROJECT_PATH/package.json" ]; then
  echo "=== SCRIPTS ==="
  grep -A 20 '"scripts"' "$PROJECT_PATH/package.json" 2>/dev/null | head -25
fi

# Subproject detection (monorepo)
echo "=== SUBPROJECTS ==="
for dir in "$PROJECT_PATH"/*/; do
  if [ -f "${dir}package.json" ] || [ -f "${dir}Cargo.toml" ] || [ -f "${dir}go.mod" ]; then
    echo "SUBPROJECT=$(basename "$dir")"
  fi
done

echo "=== END ==="
