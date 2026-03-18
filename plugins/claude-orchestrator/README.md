# Claude Code Multi-Agent Orchestrator

Claude Code 플러그인으로, 작업을 외부 AI 에이전트(OpenAI Codex CLI, Google Gemini CLI, Claude 서브에이전트)에 위임하여 병렬 실행, 자동 라우팅, 폴백 처리, 결과 통합을 수행합니다.

## 왜 멀티 에이전트인가?

각 AI 모델은 고유한 강점을 가지고 있습니다:

| 에이전트 | 강점 | 적합한 작업 |
|---------|------|-----------|
| **Claude** | 복잡한 추론, 고품질 문서화 | 아키텍처 설계, 문서 작성, 복잡한 리팩토링 |
| **Codex** | 빠른 코드 생성, 저비용 | 단순 편집, 빠른 코드 생성, 보일러플레이트 |
| **Gemini** | 긴 컨텍스트 윈도우 | 대규모 코드 분석, 전체 코드베이스 리뷰 |

오케스트레이터는 작업 유형을 분석하여 최적의 에이전트를 자동 선택합니다.

## 설치

### npm으로 설치

```bash
npm install -g @anthropic-ai/claude-orchestrator
```

### 로컬 설치

```bash
cd claude-orchestrator
node bin/install.js
```

설치 후 Claude Code를 재시작하면 플러그인이 자동 로드됩니다.

## 빠른 시작

```bash
# 1. 설정 초기화
/orchestrator-init

# 2. 에이전트 상태 확인
/doctor

# 3. 작업 위임
/delegate "이 코드베이스의 구조를 분석해줘"

# 4. 특정 에이전트에 위임
/codex-delegate "이 함수를 TypeScript로 변환해줘"
/gemini-delegate "전체 프로젝트 아키텍처를 리뷰해줘"
```

## 주요 기능

### Skills (작업 위임)

| 스킬 | 설명 |
|------|------|
| `/delegate` | 작업을 분석하여 최적 에이전트에 자동 라우팅 |
| `/delegate-orchestrate` | 복잡한 요구사항을 자동 분해 → DAG → 병렬/순차 혼합 실행 |
| `/codex-delegate` | OpenAI Codex CLI에 직접 위임 |
| `/gemini-delegate` | Google Gemini CLI에 직접 위임 |
| `/claude-subagent` | Claude 서브프로세스에 위임 |
| `/delegate-parallel` | 여러 에이전트를 동시에 실행 (읽기 전용) |
| `/pipeline` | 여러 에이전트를 순차적으로 체이닝 |

### Commands (CLI 명령)

| 명령 | 설명 |
|------|------|
| `/doctor` | 에이전트 설치 상태 확인 |
| `/agents-status` | 에이전트 상세 상태 표시 |
| `/orchestrator-init` | 설정 파일 초기화 |
| `/review-parallel` | 병렬 코드 리뷰 실행 |

### Hooks (자동화)

- **Stop Hook** — Rate limit 감지 시 대체 에이전트로 자동 폴백 (읽기 작업) 또는 사용자 확인 (쓰기 작업)
- **PostToolUse Hook** — Edit/Write 작업 후 자문 리뷰 제공

## 자동 라우팅 로직

`/delegate`를 사용하면 작업 유형에 따라 최적의 에이전트가 자동 선택됩니다:

```
대규모 컨텍스트 분석  → Gemini (긴 컨텍스트 윈도우)
빠른 코드 생성       → Codex (속도)
복잡한 추론          → Claude (품질)
코드 리뷰            → Gemini (전체 컨텍스트)
단순 편집            → Codex (비용)
문서 작성            → Claude (문서 품질)
기본값              → Claude (최고 범용 품질)
```

## 설정

`.claude/orchestrator.local.md` 파일로 동작을 커스터마이징할 수 있습니다:

```yaml
---
agents:
  codex:
    enabled: true
    binary: codex
    timeout: 300
    sandbox: full
  gemini:
    enabled: true
    binary: gemini
    timeout: 300
routing:
  code_generation: codex
  code_review: gemini
  complex_reasoning: claude
  documentation: claude
fallback_chain:
  - claude
  - codex
  - gemini
budget:
  max_concurrent_agents: 3
  max_delegation_depth: 2
---
```

`/orchestrator-init` 명령으로 기본 설정 파일을 생성할 수 있습니다.

## 프로젝트 구조

```
claude-orchestrator/
├── .claude-plugin/
│   └── plugin.json          # 플러그인 매니페스트
├── skills/                  # 위임 스킬 (8개)
│   ├── delegate/            # 자동 라우팅
│   ├── delegate-orchestrate/# 작업 분해 + DAG 기반 오케스트레이션
│   ├── codex-delegate/      # Codex 위임
│   ├── gemini-delegate/     # Gemini 위임
│   ├── claude-subagent/     # Claude 서브에이전트
│   ├── delegate-parallel/   # 병렬 실행
│   ├── pipeline/            # 순차 파이프라인
│   └── custom-agent-template/
├── commands/                # CLI 명령 (4개)
├── hooks/                   # 자동화 훅 (2개)
│   └── scripts/
├── agents/                  # 오케스트레이터 에이전트
├── lib/                     # 유틸리티 라이브러리
│   ├── config-loader.js     # YAML 설정 파싱
│   ├── agent-checker.js     # 에이전트 가용성 확인
│   └── output-parser.js     # 에이전트 출력 파싱
├── bin/
│   └── install.js           # 설치 스크립트
├── tests/                   # 테스트
└── package.json
```

## 사전 요구사항

- **Node.js** >= 20
- **Claude Code** CLI 설치 필요
- 위임할 에이전트 중 하나 이상 설치:
  - [OpenAI Codex CLI](https://github.com/openai/codex) — `npm install -g @openai/codex`
  - [Google Gemini CLI](https://github.com/google-gemini/gemini-cli) — `npm install -g @google/gemini-cli`

## 테스트

```bash
npm test
```

## 사용 예시

### 작업 분해 + 오케스트레이션

```
/delegate-orchestrate "Auth 모듈 리팩토링하고, 테스트 추가하고, 문서도 업데이트해줘"

→ Workflow Plan:
  Wave 1 (parallel):
    ├─ task-1: [codex] Auth 모듈 구조 분석
    └─ task-2: [gemini] Auth 사용처 전체 스캔
  Wave 2 (parallel):
    ├─ task-3: [codex] Auth 리팩토링 (← task-1, task-2)
    └─ task-4: [codex] 유닛 테스트 작성 (← task-1)
  Wave 3:
    └─ task-5: [claude] 문서 업데이트 (← task-3, task-4)

→ 5 tasks, 3 waves, 병렬화로 ~1.3x 속도 향상
```

### 병렬 코드 리뷰

```
/review-parallel
→ Codex: 코드 스타일 및 버그 검사
→ Gemini: 아키텍처 및 컨텍스트 리뷰
→ 결과 통합하여 제시
```

### Rate Limit 자동 폴백

```
사용자: "이 함수를 리팩토링해줘"
→ Claude가 리팩토링 시도
→ Rate limit 감지 (Stop Hook)
→ 사용자에게 확인: "Codex로 계속할까요?"
→ Codex가 리팩토링 완료
```

### 파이프라인 실행

```
/pipeline
→ Step 1: Gemini로 전체 코드 분석
→ Step 2: Claude로 리팩토링 계획 수립
→ Step 3: Codex로 코드 변경 실행
```

## 라이선스

MIT

