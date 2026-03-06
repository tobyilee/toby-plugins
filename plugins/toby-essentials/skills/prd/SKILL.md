---
name: prd
description: "This skill should be used when the user asks to 'create a prd', 'write prd for', 'plan this feature', 'write requirements', 'spec out a feature', 'product requirements document', 'feature spec', 'define user stories', or needs guidance on structured feature planning and requirements documentation."
user-invocable: true
version: 1.0.0
---

# PRD Generator

Generate clear, actionable Product Requirements Documents suitable for implementation by developers or AI agents.

## Overview

Create structured PRDs through a collaborative process: gather context, ask clarifying questions, then produce a comprehensive requirements document. The PRD serves as the bridge between an idea and implementation.

**Important:** Do NOT start implementing. Only create the PRD.

## Process

### Step 1: Gather Context

Before asking questions, explore the project:

- Check existing files, docs, and recent commits
- Identify the tech stack and existing patterns
- Note relevant existing components or systems

### Step 2: Ask Clarifying Questions

Ask 3-5 essential questions where the initial prompt is ambiguous. Focus on:

- **Problem/Goal** - What problem does this solve?
- **Core Functionality** - What are the key actions?
- **Scope/Boundaries** - What should it NOT do?
- **Success Criteria** - How to know it's done?

Format questions with lettered options for quick response:

```
1. What is the primary goal of this feature?
   A. Improve user onboarding experience
   B. Increase user retention
   C. Reduce support burden
   D. Other: [please specify]

2. What is the scope?
   A. Minimal viable version
   B. Full-featured implementation
   C. Just the backend/API
   D. Just the UI
```

This enables responses like "1A, 2C, 3B" for rapid iteration. Indent the options under each question.

### Step 3: Generate PRD

Produce the PRD with these sections (scale each section to its complexity):

1. **Introduction/Overview** - Brief description of the feature and the problem it solves
2. **Goals** - Specific, measurable objectives (bullet list)
3. **User Stories** - Small, implementable stories with acceptance criteria
4. **Functional Requirements** - Numbered, explicit, unambiguous requirements
5. **Non-Goals (Out of Scope)** - What this feature will NOT include
6. **Design Considerations** (optional) - UI/UX requirements, mockup links, reusable components
7. **Technical Considerations** (optional) - Constraints, dependencies, integration points
8. **Success Metrics** - How success will be measured
9. **Open Questions** - Remaining areas needing clarification

For detailed section templates and formatting guidance, consult `references/section-templates.md`.

### Step 4: Save and Validate

Save the PRD to `tasks/prd-[feature-name].md` (kebab-case).

Before saving, verify:
- [ ] Clarifying questions asked with lettered options
- [ ] User answers incorporated
- [ ] User stories are small and specific
- [ ] Acceptance criteria are verifiable (not vague)
- [ ] Functional requirements are numbered and unambiguous
- [ ] Non-goals section defines clear boundaries

## Writing Guidelines

The PRD reader may be a junior developer or AI agent:

- Be explicit and unambiguous
- Avoid jargon or explain it inline
- Number requirements for easy reference
- Use concrete examples where helpful
- Keep each user story small enough to implement in one focused session

## User Story Format

Each story follows this structure:

```markdown
### US-001: [Title]
**Description:** As a [user], I want [feature] so that [benefit].

**Acceptance Criteria:**
- [ ] Specific verifiable criterion
- [ ] Another criterion
- [ ] Typecheck/lint passes
- [ ] **[UI stories only]** Verify in browser
```

Acceptance criteria must be verifiable. "Works correctly" is bad. "Button shows confirmation dialog before deleting" is good.

## Key Principles

- **YAGNI** - Only include requirements for what's actually needed now
- **Verifiable** - Every acceptance criterion must be testable
- **Scoped** - Non-goals are as important as goals
- **Actionable** - A developer should be able to start implementing immediately from the PRD

## Additional Resources

### Reference Files

- **`references/section-templates.md`** - Detailed section templates with formatting guidance
- **`examples/task-priority-prd.md`** - Complete example PRD for reference
