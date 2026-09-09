#!/usr/bin/env bash
# 최신 팩트 시트를 깃헙에서 받아온다. 실패하면 번들된 로컬 사본을 쓴다.
# 사용: bash sync.sh   (스킬 디렉토리 안에서 실행)

REPO="hollylee-creator/movingplanner-consulting-skill"
BRANCH="main"
BASE="https://raw.githubusercontent.com/${REPO}/${BRANCH}"
DEST="$(cd "$(dirname "$0")" && pwd)/.live"
mkdir -p "$DEST"

# ?t= 로 CDN 캐시를 우회한다 (raw는 최대 5분 캐시)
STAMP=$(date +%s)
OK=0
FAIL=0

for f in service-facts.md case-scripts.md; do
  if curl -sfL --max-time 10 "${BASE}/references/${f}?t=${STAMP}" -o "${DEST}/${f}.tmp" \
     && [ -s "${DEST}/${f}.tmp" ] \
     && head -1 "${DEST}/${f}.tmp" | grep -q '^#'; then
    mv "${DEST}/${f}.tmp" "${DEST}/${f}"
    echo "LIVE  ${f}"
    OK=$((OK+1))
  else
    rm -f "${DEST}/${f}.tmp"
    cp "$(dirname "$0")/references/${f}" "${DEST}/${f}" 2>/dev/null
    echo "FALLBACK  ${f}  (번들 사본 사용 — 값이 최신이 아닐 수 있음)"
    FAIL=$((FAIL+1))
  fi
done

echo "---"
echo "live=${OK} fallback=${FAIL}  dir=${DEST}"
[ "$FAIL" -gt 0 ] && echo "주의: fallback이 있으면 마감일·적립률을 사용자에게 확인받을 것."
exit 0
