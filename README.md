# 마인드맵 (Mindmap) — 1단계 완료

XMind 스타일 마인드맵 서비스. Flutter (web + iOS + Android) + Supabase.

## 1단계 범위

- Flutter monorepo (web + android + ios)
- Supabase 연동 (Auth, DB, RLS 마이그레이션)
- Auth: 로그인 / 회원가입 / 홈
- 홈에서 **내 문서 목록** Supabase에서 조회 후 표시

---

## 사전 요구사항

- Flutter stable (3.16+)
- Supabase 프로젝트 1개

---

## 로컬 실행

### 1) 플랫폼 폴더 생성 (최초 1회)

프로젝트 루트에서:

```bash
flutter create . --org com.mindmap --platforms=web,android,ios
```

이미 `lib/`, `pubspec.yaml`, `web/` 등이 있으면 기존 파일을 유지한 채 플랫폼만 추가됩니다.

### 2) 환경 변수

```bash
cp .env.example .env
```

`.env` 편집:

- `SUPABASE_URL`: Supabase 대시보드 → Project Settings → API → Project URL
- `SUPABASE_ANON_KEY`: 동일 메뉴 → anon public key

### 3) Supabase 마이그레이션

**호스팅 프로젝트 사용 시**  
Supabase 대시보드 → SQL Editor에서 아래 파일 내용 순서대로 실행:

1. `supabase/migrations/20250219000001_initial_schema.sql`
2. (선택) `supabase/migrations/20250219000002_seed_sample.sql` — 첫 사용자에게 샘플 문서 1개 생성

**로컬 Supabase 사용 시:**

```bash
supabase start
supabase db reset
```

### 4) 패키지 설치 및 실행

```bash
flutter pub get
flutter run -d chrome
```

또는 기기/에뮬레이터 선택:

```bash
flutter run -d android
flutter run -d ios
```

---

## 1단계 체크리스트

- [ ] `flutter create . --platforms=web,android,ios` 실행
- [ ] `.env`에 `SUPABASE_URL`, `SUPABASE_ANON_KEY` 설정
- [ ] Supabase에서 마이그레이션 2개 실행 (스키마 + 선택 시드)
- [ ] `flutter pub get` 후 `flutter run -d chrome` (또는 모바일) 성공
- [ ] 회원가입 → 로그인 → 홈 진입
- [ ] 홈에서 "내 문서" 목록 표시 (비어 있거나 시드 1건)

---

## 프로젝트 구조 (1단계 기준)

```
mindmap/
├── lib/
│   ├── main.dart
│   ├── app.dart                    # go_router, MaterialApp
│   └── features/
│       ├── auth/
│       │   ├── providers/auth_provider.dart
│       │   └── screens/            # login, signup
│       └── home/
│           ├── models/document_model.dart
│           ├── providers/documents_provider.dart
│           └── screens/home_screen.dart   # 문서 목록
├── supabase/
│   ├── config.toml
│   └── migrations/
│       ├── 20250219000001_initial_schema.sql   # 테이블 + RLS
│       └── 20250219000002_seed_sample.sql      # 샘플 문서(선택)
├── web/
├── .env.example
├── pubspec.yaml
└── README.md
```

---

## 다음 단계 (2단계)

- 문서 생성/삭제
- 마인드맵 편집 MVP (노드 CRUD, 드래그, 접기)
