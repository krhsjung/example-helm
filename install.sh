#!/bin/bash

# =============================================================================
# Helm Chart 설치 스크립트 (envsubst 방식)
#
# 사용법:
#   ./install.sh <chart-name>              # 설치
#   ./install.sh <chart-name> --uninstall  # 제거
#   ./install.sh <chart-name> --template   # 템플릿 미리보기
#
# 예시:
#   ./install.sh example-nestjs-api
#   ./install.sh example-nestjs-api --uninstall
#   ./install.sh example-nestjs-api --template
# =============================================================================

set -e

# 환경변수 업데이트
source ~/.zshenv 2>/dev/null || true

# 색상 코드
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

info() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# 인자 확인
if [ $# -lt 1 ]; then
  echo "사용법: $0 <chart-name> [--uninstall|--template]"
  echo ""
  echo "명령어:"
  echo "  (없음)       설치"
  echo "  --uninstall  제거"
  echo "  --template   템플릿 미리보기 (설치하지 않음)"
  echo ""
  echo "예시:"
  echo "  $0 example-nestjs-api"
  echo "  $0 example-nestjs-api --uninstall"
  echo "  $0 example-nestjs-api --template"
  exit 1
fi

CHART_NAME=$1
NAMESPACE="example"
ACTION="install"

if [ "$2" = "--uninstall" ]; then
  ACTION="uninstall"
elif [ "$2" = "--template" ]; then
  ACTION="template"
fi

# 차트 경로 확인
CHART_PATH="./charts/${CHART_NAME}"
if [ ! -d "$CHART_PATH" ]; then
  error "차트를 찾을 수 없습니다: $CHART_PATH"
fi

# 제거
if [ "$ACTION" = "uninstall" ]; then
  info "차트 제거 중: ${CHART_NAME}"
  helm uninstall "${CHART_NAME}" -n "${NAMESPACE}" 2>/dev/null || warn "이미 제거되었거나 존재하지 않음"
  info "제거 완료"
  exit 0
fi

# values.yaml 확인
VALUES_FILE="${CHART_PATH}/values.yaml"
if [ ! -f "$VALUES_FILE" ]; then
  error "values 파일을 찾을 수 없습니다: $VALUES_FILE"
fi

# 환경변수 치환 (${VAR:-default} 문법 지원)
info "환경변수를 values 파일에 주입 중..."
GENERATED_FILE="${CHART_PATH}/values.generated.yaml"
eval "cat <<EOF
$(cat "$VALUES_FILE")
EOF" > "$GENERATED_FILE"

# 템플릿 미리보기
if [ "$ACTION" = "template" ]; then
  info "생성된 values 파일:"
  echo "---"
  cat "$GENERATED_FILE"
  echo "---"
  info "Helm 템플릿 미리보기:"
  helm template "${CHART_NAME}" "${CHART_PATH}" -n "${NAMESPACE}" -f "$GENERATED_FILE"
  rm -f "$GENERATED_FILE"
  exit 0
fi

# 설치
info "차트 설치 중: ${CHART_NAME}"
helm install "${CHART_NAME}" "${CHART_PATH}" -n "${NAMESPACE}" -f "$GENERATED_FILE"

# 생성된 파일 삭제 (보안)
rm -f "$GENERATED_FILE"

info "설치 완료!"
info "상태 확인: helm status ${CHART_NAME} -n ${NAMESPACE}"
info "Pod 확인: kubectl get pods -n ${NAMESPACE} -l app.kubernetes.io/instance=${CHART_NAME}"
