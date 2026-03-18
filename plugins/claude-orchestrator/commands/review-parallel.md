---
name: review-parallel
description: Run a parallel code review with multiple AI agents
arguments:
  - name: target
    description: File, directory, or PR to review (default: current changes)
    required: false
---

# Parallel Code Review

Run a code review using multiple AI agents simultaneously.

## Instructions

1. Determine what to review:
   - If a target file/dir is specified, use that
   - If no target, use `git diff` to get current changes

2. Launch parallel reviews:
   - **Codex**: Focus on code style, bugs, patterns
   - **Gemini**: Focus on architecture, full-context analysis

3. Collect and synthesize results into a unified review.

Use the delegate-parallel Skill's execution pattern for the parallel launch.
