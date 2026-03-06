# PRD Section Templates

Detailed formatting guidance for each PRD section. Scale each section to the complexity of the feature — a few sentences for straightforward sections, more detail for nuanced ones.

## 1. Introduction/Overview

Brief description of the feature and the problem it solves. Keep to 2-3 sentences.

```markdown
## Introduction

Add priority levels to tasks so users can focus on what matters most. Tasks can be marked as high, medium, or low priority, with visual indicators and filtering to help users manage their workload effectively.
```

## 2. Goals

Specific, measurable objectives as a bullet list. Each goal should be independently verifiable.

```markdown
## Goals

- Allow assigning priority (high/medium/low) to any task
- Provide clear visual differentiation between priority levels
- Enable filtering and sorting by priority
- Default new tasks to medium priority
```

## 3. User Stories

Each story needs a title, user-story-format description, and verifiable acceptance criteria. Stories should be small enough to implement in one focused session.

### User Story Template

```markdown
### US-001: [Short Descriptive Title]
**Description:** As a [user role], I want [feature/action] so that [benefit/value].

**Acceptance Criteria:**
- [ ] Specific verifiable criterion
- [ ] Another criterion
- [ ] Typecheck/lint passes
- [ ] **[UI stories only]** Verify in browser using dev-browser skill
```

### Acceptance Criteria Guidelines

**Good criteria (verifiable):**
- [ ] Each task card shows colored priority badge (red=high, yellow=medium, gray=low)
- [ ] Priority visible without hovering or clicking
- [ ] Filter dropdown with options: All | High | Medium | Low
- [ ] Filter persists in URL params
- [ ] Empty state message when no tasks match filter

**Bad criteria (vague):**
- [ ] Works correctly
- [ ] Priority is displayed properly
- [ ] Filtering works as expected

### UI Stories

For any story with UI changes, always include browser verification as acceptance criteria:
```markdown
- [ ] Verify in browser using dev-browser skill
```

## 4. Functional Requirements

Numbered list of specific functionalities. Each requirement should be explicit, unambiguous, and independently implementable.

```markdown
## Functional Requirements

- FR-1: Add `priority` field to tasks table ('high' | 'medium' | 'low', default 'medium')
- FR-2: Display colored priority badge on each task card
- FR-3: Include priority selector in task edit modal
- FR-4: Add priority filter dropdown to task list header
- FR-5: Sort by priority within each status column (high to medium to low)
```

### Writing Good Requirements

- Start with "The system must..." or describe the specific action
- Be explicit about data types, defaults, and constraints
- Avoid ambiguous terms ("should", "might", "could")
- Each requirement should map to testable behavior

## 5. Non-Goals (Out of Scope)

Critical for managing scope. State explicitly what this feature will NOT include to prevent scope creep.

```markdown
## Non-Goals

- No priority-based notifications or reminders
- No automatic priority assignment based on due date
- No priority inheritance for subtasks
```

## 6. Design Considerations (Optional)

Include when the feature has UI/UX requirements. Link to mockups if available and note relevant existing components.

```markdown
## Design Considerations

- Reuse existing badge component with color variants
- Priority selector should follow existing dropdown pattern
- Mobile: priority badge should be visible in condensed task list view
```

## 7. Technical Considerations (Optional)

Include when there are known constraints, dependencies, or integration points.

```markdown
## Technical Considerations

- Filter state managed via URL search params
- Priority stored in database, not computed
- Migration needed for existing tasks (default to 'medium')
- Index on priority column for sort performance
```

## 8. Success Metrics

Measurable outcomes that define success. Include both quantitative and qualitative metrics where appropriate.

```markdown
## Success Metrics

- Users can change priority in under 2 clicks
- High-priority tasks immediately visible at top of lists
- No regression in task list performance
```

## 9. Open Questions

Remaining questions or areas needing clarification. Include responsible party and deadline if known.

```markdown
## Open Questions

- Should priority affect task ordering within a column?
- Should we add keyboard shortcuts for priority changes?
- Do we need analytics tracking for priority changes?
```
