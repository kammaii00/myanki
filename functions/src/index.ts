import {setGlobalOptions} from "firebase-functions/v2";

// 모든 함수의 기본 리전(서울, Firestore와 같은 곳)과 동시 실행 한도
setGlobalOptions({region: "asia-northeast3", maxInstances: 5});

// 2단계에서 추가: generateCardAudio (카드 저장 → Google TTS → Storage)
