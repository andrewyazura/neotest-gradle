# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

neotest-gradle is a Neotest adapter plugin for NeoVim that discovers and runs Gradle-based Java/Kotlin tests, parses JUnit XML results, and reports them back to the Neotest UI.

## Commands

- **Run tests:** `busted --verbose`
- **Lint:** `luacheck lua/ spec/`
- **Format:** `stylua lua/ spec/`
- **Format check:** `stylua --check lua/ spec/`

Tests use the Busted framework with Lua 5.4. The `.busted` config adds `lua/?.lua;lua/?/init.lua` to the load path so modules resolve correctly.

## Code Style

- **Formatter:** StyLua — 100 column width, 2-space indent, single quotes preferred (`stylua.toml`)
- **Linter:** luacheck — `vim` declared as global (`.luacheckrc`)
- **Naming:** snake_case for functions/variables, kebab-case for filenames
- **Documentation:** LDoc-style annotations (`--- @param`, `--- @return`) on all functions

## Architecture

The adapter exports five Neotest hooks from `lua/neotest-gradle/init.lua`, each in its own module under `hooks/`:

| Hook | Module | Purpose |
|---|---|---|
| `root` | `find_project_directory` | Locates project root via `build.gradle` / `build.gradle.kts` |
| `is_test_file` | `is_test_file` | Matches files ending in `Test.kt` or `Test.java` |
| `discover_positions` | `discover_positions/` | Uses Treesitter to parse test classes (namespaces) and `@Test` methods |
| `build_spec` | `build_run_specification` | Constructs `gradlew test --tests '...'` command; queries Gradle for `testResultsDir` |
| `results` | `collect_results` | Parses JUnit XML reports and matches results back to Neotest positions |

### Discovery pipeline (`discover_positions/`)

1. **Treesitter queries** (`position_queries/kotlin.lua`, `position_queries/java.lua`) find test classes and `@Test`-annotated methods in the AST. Queries also capture `@DisplayName` values.
2. **`build_position.lua`** beautifies display names — strips Kotlin backticks, converts camelCase to spaced lowercase.
3. **`build_position_identifier.lua`** constructs fully-qualified Java-style IDs (`package.Class.method`) used as Neotest position IDs and Gradle `--tests` filter values.

### Result matching (`collect_results.lua`)

JUnit XML `classname` attributes use `$` for nested classes (e.g., `Test$Inner`) while Neotest position IDs use `.`. The matcher generates candidate IDs with both separators. Method parameters like `(String)` are stripped before matching.

### Key dependency: `shared_utilities.get_package_name`

Extracts the Java/Kotlin package name from a source file by regex (`^%s*package%s+([%w%._]+)`). Used by both position identifier construction and stack trace parsing for error line numbers.

## Testing

Tests live in `spec/` and focus on the pure-logic modules that don't require NeoVim runtime APIs:
- `spec/shared_utilities_spec.lua` — package name extraction
- `spec/collect_results_spec.lua` — JUnit XML result parsing and position matching

When adding new hooks or utilities, prefer testing modules that operate on plain data rather than those coupled to `vim.*` or `neotest.lib`.
