# Harness Use Case Prompts

Each use case below contains the full prompt to pass to the `harness:harness` skill.

## 1. Deep Research

```
Build a harness for deep research. I need an agent team that can investigate
any topic from multiple angles — web search, academic sources, community
sentiment — then cross-validate findings and produce a comprehensive report.
```

**Pattern:** Fan-out/Fan-in (parallel investigation, merged report)

## 2. Code Review & Refactoring

```
Build a harness for comprehensive code review. I want parallel agents
checking architecture, security vulnerabilities, performance bottlenecks,
and code style — then merging all findings into a single report.
```

**Pattern:** Fan-out/Fan-in (parallel analysis, merged findings)

## 3. Website Development

```
Build a harness for full-stack website development. The team should handle
design, frontend (React/Next.js), backend (API), and QA testing in a
coordinated pipeline from wireframe to deployment.
```

**Pattern:** Pipeline (sequential phases)

## 4. Webtoon Production

```
Build a harness for webtoon episode production. I need agents for story
writing, character design prompts, panel layout planning, and dialogue
editing. They should review each other's work for style consistency.
```

**Pattern:** Producer-Reviewer (generation + peer QA)

## 5. YouTube Content Planning

```
Build a harness for YouTube content creation. The team should research
trending topics, write scripts, optimize titles/tags for SEO, and plan
thumbnail concepts — all coordinated by a supervisor agent.
```

**Pattern:** Supervisor (central coordination)

## 6. Marketing Campaign

```
Build a harness for marketing campaign creation. The team should research
the target market, write ad copy, design visual concepts, and set up
A/B test plans with iterative quality review.
```

**Pattern:** Producer-Reviewer (iterative quality loop)

## 7. Technical Documentation

```
Build a harness that generates API documentation from this codebase.
Agents should analyze endpoints, write descriptions, generate usage
examples, and review for completeness.
```

**Pattern:** Pipeline (analyze → write → review)

## 8. Data Pipeline Design

```
Build a harness for designing data pipelines. I need agents for schema
design, ETL logic, data validation rules, and monitoring setup that
delegate sub-tasks hierarchically.
```

**Pattern:** Hierarchical Delegation (recursive sub-tasks)
