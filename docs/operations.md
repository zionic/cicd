# 운영 가이드

## 배포 이력 확인

- Git tag: `deploy-YYYYMMDD-HHMMSS`
- Actions 실행 이력: aggregate-and-deploy workflow
- site/manifest.json: 해당 배포 시점 프로젝트 목록

## 롤백 절차

1. Actions > `manual-rollback` 선택
2. `tag` 입력 (예: `deploy-20260325-120000`)
3. 실행 후 Pages/Vercel 반영 확인

## 권장 정책

- main 브랜치 보호 + required checks
- 배포 태그 삭제 금지
- 아티팩트 URL 만료 정책 최소 7일 이상

## 장애 대응

- 특정 프로젝트 아티팩트가 깨졌다면 `config/projects.json`에서 임시 제외 후 재배포
- Vercel만 실패 시 Pages를 우선 정상화하고 토큰/권한 재검증
