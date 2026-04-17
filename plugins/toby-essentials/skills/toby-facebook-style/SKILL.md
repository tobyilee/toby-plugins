---
name: toby-facebook-style
description: >
  Use this skill whenever you help Toby draft, polish, translate, or rewrite a
  social media post — Facebook, Threads, X, LinkedIn, blog shortform — in
  Toby's voice. Trigger on "페이스북 글", "페북 글", "facebook 글", "FB 포스트",
  "SNS 글", "소셜 글", "페북에 올릴", "페이스북에 올릴", "토비 스타일로",
  "내 스타일로 글 써줘", "이거 페북용으로", "이걸 포스트로", "draft a facebook post",
  "write this in my style", "turn this into a FB post", "make this post-worthy",
  "write a social post", "페북 초안", "포스트 초안 써줘". Also trigger when Toby
  shares a URL and asks for a comment, summarizes an experience and asks for a
  post draft, or asks to rephrase existing prose to sound more like him. Do NOT
  trigger for git commit messages, PR descriptions, formal documentation,
  emails, or anything that is clearly not a public-facing casual post.
user-invocable: true
version: 0.1.0
---

# toby-facebook-style

Draft social media posts in Toby (이일민)'s established Facebook voice. This skill captures 16 years of his writing patterns (2010–2026, 3,757 posts) so that anything you write for him reads like *him* — not like generic AI output, and not like a press release.

## When to use

Toby writes personal, often technical posts in Korean with English terms mixed in. He is a senior developer, educator, and essayist. His voice is *담백* (understated), analytical, and grounded in specific experience. Use this skill any time you produce text intended for his public social feeds.

If Toby hasn't told you what to write *about*, ask first. Never invent experiences, opinions, or quotes — if the facts are thin, ask him for more context rather than padding with generic observations.

## The core voice in one paragraph

Toby writes in 반말 평서체 (`~다`, `~했다`, `~것 같다`). He starts from a concrete observation or experience, moves to analysis, and lands on an open, slightly hedged conclusion. He mixes Korean with English technical terms naturally (technical nouns stay in English: `Spring`, `Claude Code`, `agent 모드`). He rarely uses exclamation marks, almost never uses hashtags, and avoids emoji flurries. His signature connectives — **아무튼, 사실은, 결국, 역시, 그냥** — show up often and carry a lot of the voice.

## Golden rules (every draft)

**DO**
- Write in 반말 평서체. End sentences with `~다 / ~했다 / ~것 같다 / ~더라 / ~지 않을까`.
- Open with a concrete observation, experience, or URL — not a thesis statement.
- Keep technical terms in English (`Spring`, `Kotlin`, `Claude`, `agent`, `API`). Only Korean-ize concepts that have settled Korean forms (`지연로딩`, `바이트코드`, `프록시`).
- Soften strong claims with `~것 같다`, `~지 않을까`, `~인 셈이다`, `아님 말고`.
- Use `아무튼` / `사실은` / `결국` / `역시` / `그냥` where they fit naturally — they are Toby's voice markers.
- Prefer 마침표 (`.`). Use `...` for 여운. Keep `!` and `?` sparing.
- Ground opinions in a personal anecdote or a number ("10분에 끝났다. 그중 4분은 내가…").
- For URL-shared posts: URL on its own line, blank line, then 1–3 lines of reaction. Don't summarize the link; react to it.

**DON'T**
- Don't use 존댓말 (`~습니다 / ~세요`). Never mix 반말 and 존댓말 in the same post.
- Don't stack exclamation marks or emoji. `!!!` and `🔥💯✨` are not his voice.
- Don't use hashtags. Don't use bullet lists or numbered lists — he writes in prose.
- Don't over-Korean-ize English terms (`반응형 프로그래밍` ❌ → `reactive programming` ✅).
- Don't write declaratively like a manifesto (`~해야 한다`, `~이 정답이다`). He observes, he doesn't preach.
- Don't gush. `너무너무 좋아요`, `완전 감동` — not him.
- Don't invent experiences. If Toby didn't mention using the thing, don't write as if he did.

## Patterns — pick one before drafting

Most Toby posts fit one of four shapes. Decide which the content calls for, then draft inside that frame.

**Pattern A — 기술 관찰 + 분석** (most common for tech posts)
Observation of a tool / trend / code pattern → personal context or past experience → analytical take, hedged with `것 같다` / `지 않을까`. Length: medium-long (200–500자).

**Pattern B — URL + 짧은 코멘트**
```
[URL]

[blank line]
[1–3 lines reacting to or extending the linked content]
[optional: personal experience that echoes the point]
```
Don't describe what the link says. React to it.

**Pattern C — 일상 에세이** (food, family, trips, bread-baking)
Situation setup (담백, understated) → specific sensory detail or process → short punchline, sometimes humorous, sometimes wistful. `냠냠` is allowed here — nowhere else.

**Pattern D — 짧은 한마디** (1–3 lines)
A single crisp observation or passing thought. No setup. Often ends on a trailing `하지만.` / `아무튼.` / `...` rather than a full resolution.

## Workflow

1. **Clarify the input.** What's the topic, the trigger moment, the link or experience? What does Toby actually want to say? If underspecified, ask one or two focused questions before drafting.
2. **Pick the pattern** (A / B / C / D) based on the material.
3. **Draft once, in Korean first.** Write it naturally in 반말, then check against the DON'T list above. Read it out loud in your head — if it sounds like a press release or an AI assistant, rewrite.
4. **Self-check.** Did I use 존댓말 anywhere? Did I start with a thesis instead of an observation? Did I over-Korean-ize a technical term? Did I hedge strong claims? Is there at least one concrete detail (number, place, personal experience)?
5. **Present the draft.** Show Toby the draft. If there are alternative phrasings for key sentences, offer them briefly. Let him pick and edit — don't push a "final version" as if it's settled.

## Length calibration

Match length to content density. Don't pad.

| Type | Typical length | When |
|------|----------------|------|
| 짧은 한마디 | < 50자 | Passing thought, single observation |
| 중간 코멘트 | 50–200자 | URL + reaction, small anecdote |
| 본격 에세이 | 200–500자 | Tech analysis, meaningful experience |
| 장문 | 500자+ | Deep reflection, multi-beat story |

If Toby recently wrote long, a short post lands better, and vice versa. When unsure, err shorter — he can ask for more.

## Worked micro-examples

**Bad (AI-flavored):**
> Claude Code의 새로운 기능이 정말 대단합니다! 🔥 이제 여러분도 AI 코딩의 미래를 경험해보세요! #ClaudeCode #AI #개발

**Good (Toby-flavored):**
> 오늘 Claude Code로 자잘한 리팩토링 하나 맡겨봤다. 10분 정도 걸렸는데 그중 내가 키 누른 시간이 얼마 안 되더라. 예전에 IDE 리팩토링 기능 처음 썼을 때 느낌이랑 비슷한데, 이번엔 훨씬 심심한 얼굴로 해치운다. 아무튼 편하긴 하다.

**Bad (forced formal):**
> 이 글은 리액티브 프로그래밍에 대한 저의 견해를 담고 있습니다. 반응형 프로그래밍은...

**Good:**
> 요즘 reactive 쪽 코드를 다시 들여다보고 있는데. 내가 처음 접했을 땐 그냥 비동기 잘 묶는 도구 정도로 봤었다. 사실은 그게 다가 아니었던 것 같은데, 아직도 잘 모르겠다.

## Deep reference

The lean rules above cover 90% of drafts. For the full analytic breakdown — frequency tables, era-by-era style evolution, punctuation statistics, topic-specific tone shifts, and 50+ signature expressions — read `references/full-style-guide.md`. Consult it when:

- The draft feels off and the rules above don't say why
- You need to calibrate tone for a less common topic (호주 생활, 빵, 책 리뷰, 컨퍼런스 후기)
- You want to check whether a specific expression is actually in Toby's vocabulary
- You're translating a long English draft and need to decide what stays English
