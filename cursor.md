너는 시니어 Flutter 엔지니어 + 백엔드/클라우드 아키텍트다.
내 목표는 xmind.com과 최대한 유사한 “마인드맵 서비스”를 Flutter로 웹/모바일(iOS/Android) 동시 개발하여 MVP를 최대한 빠르게 완성하는 것이다.
데이터/인증/스토리지/실시간은 Supabase를 사용하고,
알림(리마인더) 스케줄링/발송 백엔드는 AWS Free Tier(서버리스)로 구축한다.

# 0) 필수 산출물
1) Flutter monorepo 구조(한 코드베이스로 web+mobile)
2) Supabase 프로젝트 연동(Auth/DB/Storage/Realtime)
3) AWS 서버리스 백엔드(리마인더 스케줄러 + 푸시 발송)
4) 로컬 실행 가이드 + 환경변수(.env.example)
5) 최소 테스트(변환 로직/데이터 모델) + 린트/포맷

# 1) 기능 요구사항(반드시)
## 1.1 XMind 유사 핵심 (MVP 범위로 구현)
- 문서(Document) 목록/생성/삭제/최근 정렬
- 마인드맵 편집: 노드 생성/삭제/이동, 드래그&드롭, 접기/펼치기
- 키보드 단축키(웹 우선): Enter=형제, Tab=자식, Delete=삭제, Space=접기/펼치기
- 마인드맵의 형태 변경 기능(기본, 로직, 우측, 좌측 등등)
- 노드 스타일(MVP): 색상/아이콘(간단 마커)
- 노드에 메모(텍스트) / 태그 / 링크(옵션)
- Export/Import(MVP): JSON export/import, PNG/PDF는 2차(가능하면 웹에서만)

## 1.2 추가 기능(반드시)
A) 알림/리마인더
- 대상: 노드/문서/노트에 리마인더 설정(시간/반복)
- 타임존: 사용자 설정, 기본 Asia/Seoul
- 모바일: 푸시 알림
- 웹: 인앱 알림 목록(브라우저 푸시는 2차 옵션)
- 알림 클릭 시 해당 노드/문서로 딥링크 이동

B) 블릿(아웃라이너) + 마인드맵 동시 편집
- 동일 데이터 모델 공유
- UI: 좌측 아웃라이너(블릿), 우측 마인드맵(또는 탭 전환)
- 한쪽 수정 시 다른쪽 즉시 반영(로컬 상태 동기화 + 저장)

C) 블릿 ↔ 마인드맵 변환
- 계층 유지, 순서 유지, 접기 상태 처리
- 변환 규칙 문서화 + 테스트 포함

D) 메모장(노트)
- 문서 전체 노트 + 노드별 노트
- MVP: Markdown 입력(간단)
- 노트에도 리마인더 설정 가능(권장)

# 2) 기술 스택 고정(변경하지 말 것)
## Frontend
- Flutter stable
- 상태관리: Riverpod(권장) 또는 Bloc(선택)
- 라우팅: go_router
- UI: Material3, 반응형 레이아웃(웹/모바일)
- 마인드맵 렌더링:
  - CustomPainter + GestureDetector(드래그/줌/팬)
  - 또는 graphview 패키지 + 커스텀 (단, 드래그/배치가 필수)
- 아웃라이너: ListView + ReorderableListView
- 로컬 캐시/오프라인: Hive 또는 Drift(선택)로 간단 캐시(필수는 아님, 가능하면 구현)

## Data / Auth / Realtime
- Supabase:
  - Auth(Email+Password)
  - Postgres DB
  - Storage(이미지 첨부는 2차)
  - Realtime(optional): 문서 변경 반영(협업은 MVP 제외)

## Backend (AWS Free Tier)
- AWS Lambda + API Gateway
- EventBridge Scheduler(또는 CloudWatch Events)로 분 단위 스케줄
- DynamoDB 또는 Supabase(DB) 중 택1:
  - 원칙: 리마인더 데이터는 Supabase에 저장
  - Lambda는 “다가오는 리마인더 조회 → 푸시 발송 → 발송 로그 기록”만 수행
- Push 발송:
  - MVP 권장: Firebase Cloud Messaging(FCM) 사용(안정/간단)
  - iOS는 APNs 토큰/FCM 설정 가이드 포함
  - 대안: AWS SNS Mobile Push(가능하면 옵션으로 문서만)

# 3) 데이터 모델(Supabase Postgres)
다음 테이블을 SQL로 생성해라(마이그레이션 파일 포함).
- profiles (user 확장)
- documents: id, user_id, title, root_node_id, created_at, updated_at
- nodes: id, document_id, parent_id, order_index, title, collapsed, style_json, note, created_at, updated_at
- notes: id, user_id, document_id nullable, node_id nullable, content_md, created_at, updated_at
- reminders: id, user_id, target_type('document'|'node'|'note'), target_id, fire_at(timestamptz), rrule(optional), timezone, enabled, created_at, updated_at
- notification_logs: id, reminder_id, user_id, status, sent_at, payload_json

보안(RLS) 필수:
- user는 자기 데이터만 접근
- documents/nodes/notes/reminders/logs 모두 RLS 정책 작성

# 4) API 설계
대부분은 Flutter가 Supabase SDK로 직접 접근한다(REST 서버 최소화).
AWS API는 아래만 제공:
- POST /push/register : (user_id, device_token, platform) 등록 (Supabase 테이블 device_tokens에 저장)
- POST /push/unregister
- POST /scheduler/run : (보안키로 보호) 현재 시각 기준 N분 이내 리마인더 조회 후 발송

Lambda는 Supabase에 접속해 reminders 조회/로그 기록한다.
Supabase 접속은 Service Role Key를 Lambda 환경변수로 넣고, “server-side only”로 사용한다.

# 5) UX 요구사항
- XMind 유사 심플 모던 UI
- 웹: 키보드 단축키 완성도 높게
- 모바일: 제스처(핀치 줌/팬), 길게 눌러 컨텍스트 메뉴
- 자동 저장(디바운스)

# 6) 개발 진행 방식(너의 작업 순서)
0) repo 스캐폴딩(Flutter) + Supabase 설정 파일 + AWS 폴더 생성
1) Supabase 스키마(SQL) + RLS 정책 + seed(샘플 문서)
2) Flutter Auth(로그인/회원가입/로그아웃) + 프로필
3) 문서 목록/생성/삭제
4) 마인드맵 편집 MVP(노드 CRUD, 드래그 이동, 접기)
5) 아웃라이너 뷰 + 양방향 동기화
6) 변환(블릿↔마인드맵) + 테스트
7) 노트 기능(문서/노드)
8) 리마인더 CRUD UI + AWS Lambda 스케줄러 + FCM 푸시
9) Export/Import(JSON) + 최소 안정화

각 단계마다:
- 생성/수정 파일 목록을 명시하고,
- 실행 방법(명령어 포함),
- 완료 기준(체크리스트)을 제공해라.
설계만 길게 하지 말고, “즉시 실행 가능한 코드”를 우선 생성해라.

# 7) 지금 바로 시작(1단계)
- Flutter 프로젝트 생성(web+android+ios)
- supabase_flutter 연결 + .env.example
- Supabase SQL 마이그레이션(테이블+RLS)
- Auth 화면 3개(로그인/회원가입/홈)까지 동작
- 홈에서 "내 문서 목록"을 supabase에서 불러와 표시

추가 질문은 최소화해라.
타임존 기본값은 Asia/Seoul로 하되, 사용자 설정 UI는 2차로 미룬다.
이제 코드 생성/수정을 시작해라.
