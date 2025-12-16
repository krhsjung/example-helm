# NestJS API Helm Chart

NestJS API 서버를 Kubernetes에 배포하기 위한 Helm 차트입니다.

## 사전 요구사항

1. **Docker 이미지 빌드**

2. **Kind 클러스터에 이미지 로드**

   ```bash
   kind load docker-image example-nestjs-api:development
   ```

3. **Redis 실행**

4. **PostgreSQL 실행**

## 설치

```bash
# 기본 설치
helm install example-nestjs-api ./charts/example-nestjs-api

```

## 제거

```bash
helm uninstall example-nestjs-api
```

## 설정값

설정값은 환경변수를 통해 주입됩니다. `~/.zshenv` 파일에 환경변수를 설정하세요.

### 기본 설정

| 파라미터           | 설명           | 기본값                |
| ------------------ | -------------- | --------------------- |
| `replicaCount`     | Pod 복제본 수  | `1`                   |
| `image.repository` | Docker 이미지  | `example-nestjs-api`  |
| `image.tag`        | 이미지 태그    | `development`         |
| `image.pullPolicy` | 이미지 풀 정책 | `Never` (로컬 이미지) |
| `service.type`     | 서비스 타입    | `NodePort`            |
| `service.port`     | 서비스 포트    | `3000`                |
| `service.nodePort` | 외부 노출 포트 | `30000`               |

### 환경변수 (PostgreSQL)

| 환경변수                           | 설명              |
| ---------------------------------- | ----------------- |
| `EXAMPLE_POSTGRES_DATABASE_NAME`   | 데이터베이스 이름 |
| `EXAMPLE_NESTJS_POSTGRES_USER`     | DB 사용자         |
| `EXAMPLE_NESTJS_POSTGRES_PASSWORD` | DB 비밀번호       |
| `EXAMPLE_POSTGRES_PRIMARY_HOST`    | Primary DB 호스트 |
| `POSTGRES_PRIMARY_PORT`            | Primary DB 포트   |
| `EXAMPLE_POSTGRES_STANDBY_HOST`    | Standby DB 호스트 |
| `POSTGRES_STANDBY_PORT`            | Standby DB 포트   |

### 환경변수 (Redis)

| 환경변수             | 설명            |
| -------------------- | --------------- |
| `REDIS_MODE`         | Redis 모드      |
| `EXAMPLE_REDIS_HOST` | Redis 호스트    |
| `REDIS_PORT`         | Redis 포트      |
| `REDIS_USERNAME`     | Redis 사용자    |
| `REDIS_PASSWORD`     | Redis 비밀번호  |
| `REDIS_DB_INDEX`     | Redis DB 인덱스 |

### 환경변수 (JWT)

| 환경변수                               | 설명                    |
| -------------------------------------- | ----------------------- |
| `EXAMPLE_JWT_ACCESS_TOKEN_EXPIRES_IN`  | Access Token 만료 시간  |
| `EXAMPLE_JWT_REFRESH_TOKEN_EXPIRES_IN` | Refresh Token 만료 시간 |
| `EXAMPLE_JWT_SECRET_KEY`               | JWT 시크릿 키           |
| `EXAMPLE_JWT_REFRESH_SECRET_KEY`       | Refresh Token 시크릿 키 |

### 환경변수 (OAuth - 선택사항)

| 환경변수                       | 설명                   |
| ------------------------------ | ---------------------- |
| `EXAMPLE_GOOGLE_CLIENT_ID`     | Google OAuth Client ID |
| `EXAMPLE_GOOGLE_CLIENT_SECRET` | Google OAuth Secret    |
| `EXAMPLE_APPLE_TEAM_ID`        | Apple Team ID          |
| `EXAMPLE_APPLE_CLIENT_ID`      | Apple Client ID        |
| `EXAMPLE_APPLE_KEY_ID`         | Apple Key ID           |
| `EXAMPLE_APPLE_PRIVATE_KEY`    | Apple Private Key      |

### 환경변수 (기타)

| 환경변수                 | 설명          |
| ------------------------ | ------------- |
| `EXAMPLE_SERVICE_DOMAIN` | 서비스 도메인 |

## 아키텍처

```
┌───────────────────────────────────────────────────┐
│ Host (macOS)                                      │
│                                                   │
│  ┌──────────────────┐    ┌───────────────────┐    │
│  │  Docker Compose  │    │  Kubernetes       │    │
│  │                  │    │                   │    │
│  │  Redis:6379      │◄───│  NestJS API Pod   │    │
│  │  PostgreSQL:5432 │◄───│  (NodePort:30000) │    │
│  │                  │    │                   │    │
│  └──────────────────┘    └───────────────────┘    │
│                                    │              │
│                                    ▼              │
│                            localhost:30000        │
└───────────────────────────────────────────────────┘
```
