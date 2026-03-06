---
description: Analyze codebase in depth and document findings
argument-hint: [target-path-or-module]
allowed-tools: Read, Glob, Grep, Bash(find:*), Bash(wc:*), Bash(ls:*)
model: opus
---

Analyze the target specified by $ARGUMENTS in depth. If no target is provided, analyze the current working directory.

## Phase 1: Scope Discovery

Identify the analysis target and gather initial context:
- Determine the root path, language(s), and build system
- Count source files and total lines of code
- Map the top-level directory and package structure (3 levels deep)
- Read key build/config files (build.gradle, pom.xml, package.json, Cargo.toml, etc.)

## Phase 2: Parallel Deep Analysis

Launch **5 parallel Explore agents** to analyze different dimensions concurrently:

### Agent 1: Structure & Dependencies
- Folder/module organization and packaging
- Dependency graph (internal modules + external libraries)
- Build configuration and plugin usage
- Multi-module or monorepo structure if applicable
- Resource and configuration file organization

### Agent 2: Language, Style & Key Abstractions
- Naming conventions (classes, methods, variables, constants, tests)
- Coding style patterns (utility class idiom, null handling, functional style)
- Comment and Javadoc/docstring quality
- Top 10 largest files by line count
- Key interfaces and abstract classes that define the architecture

### Agent 3: Design Patterns & Architecture
- Identify all GoF patterns with concrete examples (class names, file paths)
- Detect architectural patterns (layered, hexagonal, DDD, CQRS, etc.)
- SOLID principle adherence with specific examples
- SPI/extension point mechanisms
- Novel or domain-specific patterns unique to this codebase

### Agent 4: Complexity & Maintainability
- File size distribution and outliers
- Coupling analysis (package dependencies, circular references)
- Cohesion assessment per package/module
- Caching strategies and thread-safety patterns
- Error handling and exception hierarchy patterns

### Agent 5: Testing Strategy
- Test framework stack and assertion libraries
- Test directory structure and naming conventions
- Test-to-source ratio and coverage breadth
- Read 3-4 representative test files to assess quality and style
- Test patterns (Template Method in tests, parameterized tests, fixtures)
- Integration vs unit test separation strategy

## Phase 3: Synthesis & Output

Compile all findings into a single Markdown file saved as `code-{YYYYMMDD}.md` in the project root.

### Output Structure

```markdown
# [Target Name] Codebase Analysis
**Date:** {date}  **Target:** {path}  **Scale:** {files} files, {LOC} LOC

## 1. Structure & Dependencies
## 2. Language & Style
## 3. Design Patterns & Architecture
## 4. Complexity & Maintainability
## 5. Testing
## 6. LSP Diagnostics (if available)
## 7. Key Insights
```

### Section 6: LSP Diagnostics
If LSP diagnostic data is available in the conversation context, include a summary table categorized by severity (Error, Warning, Info) with file locations and descriptions.

### Section 7: Key Insights
Document 5-8 key learnings as educational insights for junior developers. Each insight should:
- Reference specific classes, patterns, or architectural decisions from the codebase
- Explain **why** a design choice was made, not just **what** it is
- Connect codebase-specific findings to general software engineering principles

Format insights using:
```
★ Insight ─────────────────────────────────────
[Insight content]
─────────────────────────────────────────────────
```
