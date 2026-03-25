# Vercel 설정 가이드

## 1. Vercel 프로젝트 준비

- Framework preset: Other
- Root Directory: `/`
- Build Command: 비워둠(정적 결과물을 직접 배포)
- Output Directory: 비워둠

## 2. GitHub Actions Secrets 추가

Repository Settings > Secrets and variables > Actions 에 아래 등록

- `VERCEL_TOKEN`
- `VERCEL_ORG_ID`
- `VERCEL_PROJECT_ID`

## 3. Preview/Production 전략

- Production: `aggregate-and-deploy`가 `vercel deploy --prod`
- Preview: 필요 시 별도 workflow를 만들어 `--prebuilt` 또는 브랜치별 배포

## 4. 문제 해결

- 인증 실패: `vercel pull` 단계 로그 확인
- 프로젝트 불일치: ORG/PROJECT ID 재발급
- 경로 문제: `site/` 구조와 라우팅 확인
