# Unified CI/CD Deployment Hub (GitHub Pages + Vercel)

이 저장소는 여러 프로젝트(React/Python/Java)의 빌드 산출물을 취합하여 정적 서비스 형태로 배포합니다.

- GitHub Pages: 기본 공개 배포 채널
- Vercel: 외부 자동 배포 채널(선택)
- GitHub Actions: 취합, 배포, 태깅, 롤백 자동화

## 1) 현재 배포 구조 점검 항목

아래 체크리스트를 통해 온보딩 시 구조를 표준화합니다.

1. 산출물 업로드 위치(사내 아티팩트 저장소, release asset, S3, 등)
2. 프로젝트별 아티팩트 압축 포맷(zip 권장)
3. 라우팅 경로(`pathPrefix`) 및 index 파일
4. 비밀값/토큰 구성(`VERCEL_TOKEN`, `VERCEL_ORG_ID`, `VERCEL_PROJECT_ID`)
5. 배포 트리거 방식(스케줄, 수동, repository_dispatch)

## 2) 자동 취합 + GitHub Pages 배포

- 워크플로우: `.github/workflows/aggregate-and-deploy.yml`
- 취합 스크립트: `scripts/aggregate_artifacts.sh`
- 프로젝트 매니페스트: `config/projects.json`

`config/projects.json`에 프로젝트를 등록하면, 취합 후 `site/`에 통합 배치되고 Pages로 배포됩니다.

## 3) Vercel 자동 배포

동일 워크플로우에서 `site/`를 다시 생성 후 Vercel CLI로 production 배포합니다.

필수 Secret:

- `VERCEL_TOKEN`
- `VERCEL_ORG_ID`
- `VERCEL_PROJECT_ID`

없으면 Vercel job은 자동 skip됩니다.

## 4) 롤백/버전 태깅/배포 이력

- 배포 성공 시 `deploy-YYYYMMDD-HHMMSS` 태그 자동 생성
- 수동 롤백 워크플로우: `.github/workflows/manual-rollback.yml`
- 입력된 태그의 `site/`를 Pages/Vercel에 재배포

## 빠른 시작

```bash
cp config/projects.example.json config/projects.json
# config/projects.json 내 URL/경로 수정
bash scripts/aggregate_artifacts.sh config/projects.json site
```

## DB가 필요한 프로젝트 대응

GitHub Pages/Vercel static 호스팅은 DB 직접 연결 계층이 아닙니다. 권장 방식:

1. DB 연동은 백엔드 API(예: FastAPI/Spring Boot/Node)로 분리
2. 프런트/문서는 이 저장소의 정적 배포를 사용
3. 민감 정보는 각 런타임의 Secret Manager에 저장
4. 필요 시 Vercel Serverless Functions를 API 계층으로 병행

자세한 운영 가이드는 `docs/`를 참고하세요.
