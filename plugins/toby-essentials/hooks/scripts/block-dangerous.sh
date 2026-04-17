#!/bin/bash
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""')
HOOK_CWD=$(echo "$INPUT" | jq -r '.cwd // ""')

# 간접 실행을 통한 rm -rf 우회 차단 (bash -c, sh -c, eval 등)
if echo "$COMMAND" | grep -qiE '(bash|sh|zsh)\s+-c\s+.*rm\s+-(rf|fr|r)\b'; then
  echo "BLOCKED: Indirect rm -rf via shell -c is not allowed" >&2
  exit 2
fi
if echo "$COMMAND" | grep -qiE 'eval\s+.*rm\s+-(rf|fr|r)\b'; then
  echo "BLOCKED: Indirect rm -rf via eval is not allowed" >&2
  exit 2
fi

# rm -rf 차단 (현재 프로젝트 디렉토리 내부는 허용)
# -rf, -fr, -r, -r -f, -f -r 등 다양한 플래그 조합 감지
if echo "$COMMAND" | grep -qE 'rm\s+-(rf|fr|r|f)\b'; then
  # -f만 단독 사용은 디렉토리 삭제가 아니므로 제외
  if echo "$COMMAND" | grep -qE 'rm\s+-(rf|fr|r)\b' || echo "$COMMAND" | grep -qE 'rm\s+(-[a-zA-Z]+\s+)+.*-[a-zA-Z]*r'; then
    # Hook JSON의 cwd를 우선 사용 (실행 시점 pwd 보다 신뢰 가능), 없으면 pwd 폴백
    PROJECT_DIR="${HOOK_CWD:-$(pwd)}"
    # PROJECT_DIR 자체가 symlink를 포함할 수 있으므로 realpath로 해석 — 비교 기준 통일
    PROJECT_DIR=$(python3 -c "import os,sys; print(os.path.realpath(sys.argv[1]))" "$PROJECT_DIR")
    BLOCKED=false
    # rm 명령어에서 옵션 이후의 경로 인자들을 추출
    TARGETS=$(echo "$COMMAND" | sed -E 's/^.*rm\s+(-[a-zA-Z]+\s+)+//' | tr ' ' '\n')
    while IFS= read -r TARGET; do
      [ -z "$TARGET" ] && continue
      # 따옴표 제거
      TARGET=$(echo "$TARGET" | sed -E "s/^['\"]|['\"]$//g")
      [ -z "$TARGET" ] && continue
      # 절대 경로로 변환
      if [[ "$TARGET" = /* ]]; then
        ABS_PATH="$TARGET"
      else
        ABS_PATH="$PROJECT_DIR/$TARGET"
      fi
      # realpath로 symlink까지 모두 해석 — symlink가 프로젝트 밖을 가리키는 우회 차단
      ABS_PATH=$(python3 -c "import os,sys; print(os.path.realpath(sys.argv[1]))" "$ABS_PATH")
      # 프로젝트 디렉토리 내부가 아니면 차단 (프로젝트 루트 자체 삭제도 차단)
      if [[ "$ABS_PATH" != "$PROJECT_DIR"/* ]]; then
        BLOCKED=true
        break
      fi
    done <<< "$TARGETS"
    if $BLOCKED; then
      echo "BLOCKED: rm -rf outside project directory ($ABS_PATH not under $PROJECT_DIR)" >&2
      exit 2
    fi
  fi
fi

# main/master 직접 push 차단
#if echo "$COMMAND" | grep -qE 'git\s+push.*\s+(main|master)'; then
#  echo "BLOCKED: Direct push to protected branch. Use a feature branch." >&2
#  exit 2
#fi

exit 0
