# MyAnki 프로젝트 요약

> 현재 상태: **1단계 완료 (덱·카드 관리)**. 다음은 2단계(TTS). 상세 계획은 `docs/PLAN.md` 참고.
> Firebase 프로젝트 `myanki-d5a19` · Android 패키지 `com.jwpark.myanki`
> 리전: Firestore·Functions는 서울 `asia-northeast3` / Storage는 미국 `us-east1` (무료 사용량이 미국 리전에만 있어서)

## 💡 1. 프로젝트 개요
* **목적:** Anki처럼 기억 주기에 맞춰 영어 문장 카드를 자동으로 복습시키고, 카드 앞면에는 Google TTS로 만든 자연스러운 음성을 자동으로 붙인다.
* **주요 타겟:** 개발자 본인 1명 (개인용, Android 폰). 출시는 나중에 검토.

## 🛠 2. 기술 스택
* **Frontend:** Flutter (Android 전용), Riverpod, go_router, audioplayers
* **Backend:** Firebase Auth(Google 로그인), Cloud Firestore(오프라인 캐시), Firebase Storage, Cloud Functions(TypeScript, Firestore 트리거)
* **TTS:** Google Cloud Text-to-Speech (Chirp 3 HD 음성)
* **복습 알고리즘:** FSRS (Dart `fsrs` 패키지 / 이전 스크립트는 py-fsrs)
* **기타 도구:** Anki 이전 스크립트(Python, firebase-admin)

## ✨ 3. 핵심 기능 목록
* **Google 로그인 (완료):** Google 계정으로 로그인하고, 로그인하지 않았으면 자동으로 로그인 화면으로 이동. 홈의 로그아웃 버튼은 Google·Firebase 세션을 모두 끊음
* **덱 관리 (완료):** 덱 만들기·이름 변경·삭제. 덱을 지우면 안의 카드도 함께 지워짐 (일괄 쓰기 450건씩 나눠 처리)
* **카드 관리 (완료):** 카드 추가·편집·삭제. 새 카드는 추가 후 입력칸이 비워져 연속 입력 가능. 길게 누르면 일시정지/해제·삭제. 덱별 목록과 모든 카드 보기에서 앞면·뒷면·태그 검색
* **자동 음성 (예정):** 카드를 저장하면 앞면 음성이 서버에서 자동 생성되고, 폰에 저장해 오프라인으로 재생
* **간격 반복 복습 (예정):** FSRS 기반, 다시/어려움/좋음/쉬움 4개 버튼, 하루 새 카드 한도, 하루 기준 새벽 4시
* **Anki 이전 (예정):** .colpkg의 카드·복습 이력·다음 복습일을 그대로 옮김 (일회성 스크립트)

## 📂 4. 디렉토리 구조 및 역할
`(예정)` 표시는 아직 만들지 않은 폴더다.
```
📦 myanki
 ┣ 📂 lib/
 ┃ ┣ 📜 main.dart          # Firebase 초기화 → ProviderScope → MyAnkiApp
 ┃ ┣ 📜 firebase_options.dart # flutterfire configure가 생성 (직접 수정 X)
 ┃ ┣ 📂 app/
 ┃ ┃ ┣ 📜 app.dart         # MaterialApp.router, 라이트/다크 테마
 ┃ ┃ ┗ 📜 router.dart      # go_router, 로그인 여부로 /login ↔ / 자동 이동
 ┃ ┣ 📂 features/
 ┃ ┃ ┣ 📂 auth/            # auth_repository(Google 로그인·로그아웃, Provider들), login_screen
 ┃ ┃ ┣ 📂 home/            # home_screen(덱 목록·새 덱·로그아웃), deck_tile(이름 변경·삭제 메뉴)
 ┃ ┃ ┣ 📂 cards/           # card_list_screen(검색), card_tile(일시정지·삭제), card_edit_screen(추가·편집)
 ┃ ┃ ┃ ┗ 📂 data/          # deck·flashcard 모델, deck/card_repository(Firestore), card_providers(Riverpod)
 ┃ ┃ ┣ 📂 review/          # (예정) 복습 화면, 오늘의 큐, FSRS 스케줄러
 ┃ ┃ ┗ 📂 settings/        # (예정) 목소리·속도·하루 한도 설정
 ┃ ┣ 📂 services/          # firestore_helpers(사용자 컬렉션 경로, 기다리지 않는 쓰기), (예정) 오디오 캐시·재생
 ┃ ┗ 📂 widgets/           # dialogs(한 줄 입력·확인 대화상자) 등 공통 UI
 ┣ 📂 test/                # 단위 테스트 (flashcard 모델 변환·검색)
 ┣ 📂 android/             # google-services.json 포함, 패키지 com.jwpark.myanki
 ┣ 📂 functions/           # Cloud Functions (TS, 서울 리전). 2단계에서 generateCardAudio 추가
 ┣ 📂 tools/anki_migrator/ # (예정) Anki .colpkg → Firestore 이전 스크립트 (Python)
 ┣ 📜 firestore.rules      # 본인 uid(users/{uid}/**)만 읽기/쓰기 — 배포됨
 ┣ 📜 storage.rules        # 본인만 읽기, 쓰기는 서버만 — 배포됨 (버킷 myanki-d5a19.firebasestorage.app)
 ┣ 📜 firebase.json / .firebaserc # Firebase CLI 설정 (기본 프로젝트 myanki-d5a19)
 ┗ 📂 docs/                # PLAN.md, APP_SUMMARY.md
```

## 🗺 5. 화면 구성 및 네비게이션
* **로그인 (`/login`):** Google 계정으로 로그인 -> 홈
* **홈 = 덱 목록 (`/`):** 덱 이름·카드 수, 새 덱, 덱 메뉴(이름 변경·삭제), 로그아웃 -> 카드 목록, 모든 카드. (예정) 덱마다 오늘 복습·새 카드 수 -> 복습
* **카드 목록 (`/decks/:deckId`, 모든 카드는 `/cards`):** 검색, 길게 눌러 일시정지·삭제 -> 카드 추가·편집
* **카드 추가 (`/cards/new?deckId=`) / 편집 (`/cards/:cardId`):** 덱 선택, 앞면(영어)·뒷면(뜻·메모) 입력. (예정) 음성 상태 확인과 미리듣기
* **(예정) 복습:** 앞면과 음성 자동 재생 → 정답 보기 → 4개 버튼으로 평가 -> 완료 후 홈
* **(예정) 설정:** 목소리, 속도, 자동 재생, 하루 새 카드 수

## 🔄 6. 데이터 흐름 및 아키텍처
* **카드 읽기:** 덱·카드 컬렉션 전체를 실시간 구독(`decksProvider`, `cardsProvider`)하고 화면에서 덱별 필터·검색·개수 계산을 한다. 개인용 규모라 쿼리나 인덱스를 두지 않는다
* **카드 저장:** 앱 → Firestore `users/{uid}/cards`. 쓰기는 응답을 기다리지 않는다(`fireAndForget`). 오프라인에서는 서버 응답이 연결될 때까지 오지 않기 때문이며, 로컬 캐시에 즉시 반영되고 연결되면 동기화된다. 수정은 바꾼 필드만 `update`해서 서버가 쓰는 `audio`·`srs` 필드를 덮어쓰지 않는다
* **음성 생성:** Function이 카드 변경을 감지 → 지문(앞면+목소리+속도)이 바뀌었으면 TTS 호출 → Storage에 mp3 저장 → `audio.status = ready`
* **음성 재생:** 앱이 지문 기준으로 폰에 저장된 파일을 먼저 찾고, 없으면 Storage에서 내려받음
* **복습:** 버튼 선택 → FSRS로 다음 복습일 계산 → 카드 `srs` 갱신과 `reviewLogs` 추가를 한 번에 저장(batch)
* **Anki 이전:** Mac 스크립트 → 점검 모드로 숫자 비교 → Admin SDK로 업로드(문서 ID `anki_{카드ID}`라 다시 실행해도 안전) → Function이 음성 일괄 생성

## 📝 7. 최근 주요 업데이트 내역
* [2026-11-01]: 1단계 완료. 덱·카드 추가/편집/삭제, 연속 입력, 일시정지, 검색. 덱 목록을 홈으로 하고 go_router 경로 4개를 추가했다.
* [2026-11-01]: 0단계 완료. Flutter 프로젝트를 만들고 Firebase를 연결했다(Auth·Firestore 서울·Functions 뼈대, 보안 규칙 배포). 로그인 여부에 따라 화면이 자동으로 바뀌는 Google 로그인을 구현했다.
* [2026-11-01]: 개발 계획 확정 (개인용, Android 전용, Anki 복습 이력 이전, 앞면은 모두 영어). `docs/PLAN.md` 작성.
