---
description: Evaluate code quality, score each dimension, and document findings
argument-hint: [target-path-or-module]
allowed-tools: Read, Glob, Grep, Bash(find:*), Bash(wc:*), Bash(ls:*)
model: opus
---

Evaluate the code quality of the target specified by $ARGUMENTS. If no target is provided, evaluate the current working directory. If a previous quality report exists (quality-*.md in the project root), read it first and compare results to track improvement or regression.

## Phase 1: Scope Discovery

Identify the evaluation target and gather baseline metrics:
- Determine the root path, language(s), and build system
- Count source files, test files, and total lines of code
- Compute test-to-source file ratio
- Identify the primary frameworks and libraries in use

## Phase 2: Parallel Quality Assessment

Launch **4 parallel Explore agents** to evaluate different quality dimensions concurrently:

### Agent 1: Readability & Consistency
Evaluate and score:
- **Readability (0-100)**: Naming clarity, function/method length, code density, self-documenting patterns, comment quality. Read 5-8 representative files across different packages.
- **Consistency (0-100)**: Naming convention adherence, formatting uniformity, import ordering, error handling patterns. Check for style deviations across at least 3 different packages/directories.

Provide specific file:line examples for both strengths and weaknesses.

### Agent 2: Maintainability & Extensibility
Evaluate and score:
- **Maintainability (0-100)**: File size distribution, cyclomatic complexity indicators (deeply nested logic, long methods), code duplication patterns, coupling between modules. Identify the 5 most complex files.
- **Extensibility (0-100)**: Interface/abstraction usage, SOLID principle adherence, extension points (SPI, plugin, strategy patterns), dependency injection readiness. Check for sealed/final classes blocking extension unnecessarily.

Provide specific file:line examples for both strengths and weaknesses.

### Agent 3: Testability & Test Quality
Evaluate and score:
- **Testability (0-100)**: Constructor injection vs static coupling, mockability of dependencies, pure function ratio, separation of concerns. Identify hard-to-test patterns (singletons, static state, deep inheritance).
- **Test Quality (0-100)**: Test-to-source ratio, assertion quality (specific vs vague), test isolation, edge case coverage, test naming conventions. Read 3-4 test files to assess quality.

Provide specific file:line examples for both strengths and weaknesses.

### Agent 4: Performance, Security & Dependencies
Evaluate and score:
- **Performance (0-100)**: Caching strategies, algorithmic complexity concerns, resource management (stream/connection closing), concurrency patterns, unnecessary object allocation. Flag O(n²) or worse patterns.
- **Security (0-100)**: Input validation at system boundaries, injection vulnerability patterns (SQL, XSS, command), secret/credential handling, dependency vulnerability awareness. Check for hardcoded secrets.
- **Dependency Management (0-100)**: Version pinning, dependency freshness, unused dependencies, circular dependencies, license compatibility awareness.

Provide specific file:line examples for both strengths and weaknesses.

## Phase 3: Scoring & Synthesis

Compile all findings into a single Markdown file saved as `quality-{YYYYMMDD}.md` in the project root.

### Output Structure

```markdown
# [Target Name] Code Quality Report
**Date:** {date}  **Target:** {path}  **Scale:** {files} files, {LOC} LOC

## Score Summary

| Dimension            | Score | Grade | Trend |
|----------------------|-------|-------|-------|
| Readability          | xx    | A-F   | ↑↓→   |
| Consistency          | xx    | A-F   | ↑↓→   |
| Maintainability      | xx    | A-F   | ↑↓→   |
| Extensibility        | xx    | A-F   | ↑↓→   |
| Testability          | xx    | A-F   | ↑↓→   |
| Test Quality         | xx    | A-F   | ↑↓→   |
| Performance          | xx    | A-F   | ↑↓→   |
| Security             | xx    | A-F   | ↑↓→   |
| Dependency Mgmt      | xx    | A-F   | ↑↓→   |
| **Overall**          | **xx**| **X** | **X** |

## 1. Readability & Consistency
## 2. Maintainability & Extensibility
## 3. Testability & Test Quality
## 4. Performance, Security & Dependencies
## 5. LSP Diagnostics (if available)
## 6. Top Issues & Recommendations
## 7. Key Insights
```

### Grading Scale

| Grade | Score Range | Meaning |
|-------|-------------|---------|
| A     | 90-100      | Excellent — exemplary practices |
| B     | 75-89       | Good — minor improvements possible |
| C     | 60-74       | Acceptable — notable issues to address |
| D     | 40-59       | Below average — significant improvements needed |
| F     | 0-39        | Poor — critical issues requiring immediate attention |

### Trend Column
- **↑** Improved from previous report
- **↓** Regressed from previous report
- **→** No change or no previous report
- Leave as **→** if no previous `quality-*.md` exists

### Overall Score
Compute as a weighted average:
- Readability: 10%, Consistency: 10%, Maintainability: 15%, Extensibility: 10%
- Testability: 10%, Test Quality: 15%, Performance: 10%, Security: 15%, Dependency Mgmt: 5%

### Section 5: LSP Diagnostics
If LSP diagnostic data is available in the conversation context, include a summary table categorized by severity (Error, Warning, Info) with file locations and descriptions.

### Section 6: Top Issues & Recommendations
List the **top 5 most impactful issues** found, each with:
- Severity (Critical / High / Medium / Low)
- Affected files or packages
- Concrete recommendation with code example if applicable

### Section 7: Key Insights
Document 3-5 notable findings as educational insights. Format using:
```
★ Insight ─────────────────────────────────────
[Insight content referencing specific code]
─────────────────────────────────────────────────
```
