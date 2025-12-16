# Example Helm Charts

Kubernetes 환경에서 애플리케이션을 배포하기 위한 Helm Chart 모음입니다.

## 프로젝트 구조

```
example-helm/
├── charts/
│   └── example-nestjs-api/     # NestJS API 서버 차트
│       ├── Chart.yaml
│       ├── values.yaml
│       └── templates/
│           ├── _helpers.tpl
│           ├── deployment.yaml
│           ├── service.yaml
│           ├── secret.yaml
│           └── ingress.yaml
├── install.sh                   # 설치 스크립트
└── README.md
```

## 사전 요구사항

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [KInD](https://krhsjung.notion.site/KInD-Kubernetes-In-Docker-setting-On-MacOS-1b368c4d323d80c8ab68cc6e05554c1f/) (Kubernetes in Docker)
- [Helm](https://krhsjung.notion.site/Helm-2cb68c4d323d806c916ce03b16855719/) 3.x
- [kubectl](https://krhsjung.notion.site/kubectl-command-1b668c4d323d803485fddba2801a3060/)

### 설치 확인

```bash
docker --version
kind --version
helm version
kubectl version --client
```

## 빠른 시작

### 1. Kind 클러스터 생성

```bash
kind create cluster --name example-cluster
```

### 2. 환경변수 설정

`~/.zshenv` 또는 `~/.bashrc`에 필요한 환경변수를 설정합니다:

```bash
# PostgreSQL
export EXAMPLE_POSTGRES_DATABASE_NAME="example_db"
export EXAMPLE_POSTGRES_PRIMARY_HOST="host.docker.internal"
export EXAMPLE_POSTGRES_STANDBY_HOST="host.docker.internal"
export POSTGRES_PRIMARY_PORT="5432"
export POSTGRES_STANDBY_PORT="5432"
export EXAMPLE_NESTJS_POSTGRES_USER="postgres"
export EXAMPLE_NESTJS_POSTGRES_PASSWORD="your_password"

# Redis
export REDIS_MODE="standalone"
export EXAMPLE_REDIS_HOST="host.docker.internal"
export REDIS_PORT="6379"
export REDIS_USERNAME=""
export REDIS_PASSWORD=""
export REDIS_DB_INDEX="0"

# JWT
export EXAMPLE_JWT_ACCESS_TOKEN_EXPIRES_IN="1h"
export EXAMPLE_JWT_REFRESH_TOKEN_EXPIRES_IN="7d"
export EXAMPLE_JWT_SECRET_KEY="your_jwt_secret"
export EXAMPLE_JWT_REFRESH_SECRET_KEY="your_refresh_secret"

# Service
export EXAMPLE_SERVICE_DOMAIN="your_service_domain"
```

### 3. Helm Chart 설치

```bash
# 설치
./install.sh example-nestjs-api

# 또는 직접 helm 명령어 사용
helm install example-nestjs-api ./charts/example-nestjs-api
```

### 4. 배포 확인

```bash
# Pod 상태 확인
kubectl get pods

# 서비스 확인
kubectl get svc

# 로그 확인
kubectl logs -l app.kubernetes.io/name=example-nestjs-api -f
```

### 5. API 접속

```
http://localhost:30000
```

## install.sh 사용법

환경변수를 자동으로 values.yaml에 주입하는 설치 스크립트입니다.

```bash
# 설치
./install.sh <chart-name>

# 제거
./install.sh <chart-name> --uninstall

# 템플릿 미리보기 (설치하지 않음)
./install.sh <chart-name> --template
```

### 예시

```bash
# NestJS API 설치
./install.sh example-nestjs-api

# 템플릿 확인
./install.sh example-nestjs-api --template

# 제거
./install.sh example-nestjs-api --uninstall
```

## 차트 목록

### example-nestjs-api

NestJS 기반 API 서버 배포를 위한 Helm 차트입니다.

| 설정                      | 기본값   | 설명           |
| ------------------------- | -------- | -------------- |
| replicaCount              | 1        | Pod 복제본 수  |
| service.type              | NodePort | 서비스 타입    |
| service.nodePort          | 30000    | 외부 접근 포트 |
| resources.requests.cpu    | 250m     | CPU 요청       |
| resources.requests.memory | 256Mi    | 메모리 요청    |
| resources.limits.cpu      | 500m     | CPU 상한       |
| resources.limits.memory   | 512Mi    | 메모리 상한    |

자세한 설정은 [charts/example-nestjs-api/README.md](charts/example-nestjs-api/README.md)를 참조하세요.

## 주요 명령어

```bash
# 클러스터 정보
kubectl cluster-info

# 모든 리소스 확인
kubectl get all

# Helm 릴리스 목록
helm list

# 릴리스 상태 확인
helm status example-nestjs-api

# 릴리스 업그레이드
helm upgrade example-nestjs-api ./charts/example-nestjs-api

# Pod 로그 확인
kubectl logs -l app.kubernetes.io/name=example-nestjs-api -f

# Pod 재시작
kubectl rollout restart deployment/example-nestjs-api

# Pod 내부 접속
kubectl exec -it <pod-name> -- /bin/sh
```

## 트러블슈팅

### Pod가 시작되지 않는 경우

```bash
# Pod 상태 확인
kubectl describe pod <pod-name>

# 이벤트 확인
kubectl get events --sort-by='.lastTimestamp'
```

### 이미지를 찾을 수 없는 경우

```bash
# Kind 클러스터에 이미지 로드 확인
docker exec -it kind-control-plane crictl images | grep example
```

### 서비스에 접속할 수 없는 경우

```bash
# 서비스 상태 확인
kubectl get svc example-nestjs-api

# Endpoint 확인
kubectl get endpoints example-nestjs-api

# Port Forward로 직접 테스트
kubectl port-forward svc/example-nestjs-api 3000:3000
```

## 아키텍처

```
┌─────────────────────────────────────────────────────┐
│  Host Machine                                       │
│                                                     │
│  ┌─────────────────┐    ┌─────────────────────────┐ │
│  │ Docker Compose  │    │ Kind Cluster            │ │
│  │                 │    │                         │ │
│  │  PostgreSQL     │◄───│  ┌─────────────────┐    │ │
│  │  (5432)         │    │  │ NestJS API Pod  │    │ │
│  │                 │    │  │ Port: 3000      │    │ │
│  │  Redis          │◄───│  └────────┬────────┘    │ │
│  │  (6379)         │    │           │             │ │
│  │                 │    │  ┌────────▼────────┐    │ │
│  └─────────────────┘    │  │ Service         │    │ │
│                         │  │ NodePort: 30000 │    │ │
│                         │  └────────┬────────┘    │ │
│                         └───────────┼─────────────┘ │
│                                     │               │
│                         ┌───────────▼───────────┐   │
│                         │ localhost:30000       │   │
│                         └───────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

## 문서

- [Kubernetes PV/PVC 가이드](https://krhsjung.notion.site/Kubernetes-PV-PVC-2c168c4d323d801c809ae1e0670cf078) - 스토리지 설정 및 제약사항
