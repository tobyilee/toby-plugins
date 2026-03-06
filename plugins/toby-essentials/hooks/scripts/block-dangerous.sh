#!/bin/bash
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')

# rm -rf 차단 (현재 프로젝트 디렉토리 내부는 허용)
if echo "$COMMAND" | grep -qE 'rm\s+-(rf|fr|r)\s'; then
  PROJECT_DIR=$(pwd)
  BLOCKED=false
  # rm 명령어에서 옵션 이후의 경로 인자들을 추출
  TARGETS=$(echo "$COMMAND" | sed -E 's/^.*rm\s+(-[a-zA-Z]+\s+)+//' | tr ' ' '\n')
  for TARGET in $TARGETS; do
    [ -z "$TARGET" ] && continue
    # 절대 경로로 변환
    if [[ "$TARGET" = /* ]]; then
      ABS_PATH="$TARGET"
    else
      ABS_PATH="$PROJECT_DIR/$TARGET"
    fi
    # 심볼릭 링크 등을 해석하지 않고 경로 정규화 (.. 등 제거)
    ABS_PATH=$(python3 -c "import os,sys; print(os.path.normpath(sys.argv[1]))" "$ABS_PATH")
    # 프로젝트 디렉토리 내부가 아니면 차단
    if [[ "$ABS_PATH" != "$PROJECT_DIR"/* ]]; then
      BLOCKED=true
      break
    fi
  done
  if $BLOCKED; then
    echo "BLOCKED: rm -rf outside project directory ($ABS_PATH not under $PROJECT_DIR)" >&2
    exit 2
  fi
fi

# main/master 직접 push 차단
#if echo "$COMMAND" | grep -qE 'git\s+push.*\s+(main|master)'; then
#  echo "BLOCKED: Direct push to protected branch. Use a feature branch." >&2
#  exit 2
#fi

# .env 파일 접근 차단 (.env.local은 허용)
# 먼저 .env.local이 아닌 .env 파일 참조가 있는지 검사
ENV_REFS=$(echo "$COMMAND" | grep -oE '([a-zA-Z0-9_./-]*\.env[a-zA-Z0-9_.]*)')
if [ -n "$ENV_REFS" ]; then
  # .env.local을 제외한 .env 참조가 남아있으면 차단
  NON_LOCAL=$(echo "$ENV_REFS" | grep -vE '\.env\.local$')
  if [ -n "$NON_LOCAL" ]; then
    echo "BLOCKED: Access to .env files prohibited (found: $NON_LOCAL)" >&2
    exit 2
  fi
fi

exit 0
