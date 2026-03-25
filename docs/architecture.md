# 아키텍처 개요

## 배포 플로우

1. 외부 프로젝트에서 빌드 산출물(zip) 생성
2. 산출물을 접근 가능한 URL에 업로드
3. 이 저장소의 `aggregate-and-deploy` 워크플로우 실행
4. `scripts/aggregate_artifacts.sh`가 `site/`에 통합 배치
5. GitHub Pages + (선택) Vercel 동시 배포

## 지원 타입

- `react`: 일반 정적 번들(dist/build)
- `python`: docs/_build/html 패턴 정규화
- `java`: target/site 패턴 정규화

## repository_dispatch 연동 예시

외부 repo에서 빌드 완료 후 아래 이벤트를 보내면 본 저장소가 즉시 재배포됩니다.

```bash
curl -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer <GH_TOKEN>" \
  https://api.github.com/repos/<org>/<cicd-repo>/dispatches \
  -d '{"event_type":"artifact-ready"}'
```

## DB 연동 원칙

- 정적 페이지: 이 저장소에서 배포
- 동적 데이터/인증/트랜잭션: 별도 API 레이어
- CORS, 인증 토큰, 캐시 정책을 API 게이트웨이에서 통제
