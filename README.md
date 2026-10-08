# ros2-defect-detection-sql

표면 결함 이미지를 ROS2로 스트리밍해 결함을 검출하고, 결과를 SQLite에 저장·SQL로 분석하는 검사 라인 시뮬레이션 프로젝트입니다.

> 공개 데이터(NEU-DET)를 사용한 개인 학습 프로젝트입니다.

## 배경
농산물 외관 결함 검출 연구에서 모델 정확도만으로는 현장 적용이 끝나지 않았습니다. 실제 선별 라인에서는 **처리 속도, 판정 기준, 결과 관리, 재학습 데이터 확보**가 함께 해결돼야 합니다. 이 프로젝트는 그 문제들을 산업 표면 결함 데이터로 재현하고 직접 실험해 보는 것이 목적입니다.

## 핵심 고민
각 항목은 **질문 → 실험 → 결과 → 결정** 순서로 기록합니다.

### 1. 검출이 입력보다 느리면 어떻게 되는가
- **질문**: 이미지가 추론 속도보다 빨리 들어오면 대기열이 쌓여 지연이 계속 늘어난다. 최신 이미지만 처리(오래된 프레임 버림)할지, 전부 처리(지연 감수)할지?
- **실험**: 발행 주기와 QoS 설정(queue depth, reliable/best effort)을 바꿔가며 지연시간과 누락 건수를 DB에 기록하고 SQL로 비교
- **결과·결정**: 정리 예정

### 2. 결함 판정 기준(신뢰도 임계값)을 어떻게 정할 것인가
- **질문**: 임계값을 낮추면 결함을 덜 놓치지만 정상품을 버리고, 높이면 반대가 된다. 선별 라인에서는 두 오류의 비용이 다르다.
- **실험**: 임계값별·결함 유형별 미검출/오검출 건수를 SQL로 집계, 전체 단일 임계값과 유형별 임계값 비교
- **결과·결정**: 정리 예정

### 3. 어떤 데이터를 다시 학습시킬 것인가
- **질문**: 데이터를 무작위로 늘리는 것보다, 모델이 헷갈리는 샘플을 골라 보강하는 게 효과적인가?
- **실험**: 저신뢰 검출을 SQL로 추출해 재학습(v2) → v1과 결과를 같은 쿼리로 비교
- **결과·결정**: 정리 예정

### 4. DB 저장이 파이프라인을 느리게 만들지 않는가
- **질문**: 검출마다 바로 저장하면 쓰기 대기가 추론을 막을 수 있다.
- **실험**: 건별 저장 vs 묶음 저장(트랜잭션) 처리 시간 비교
- **결과·결정**: 정리 예정

## 파이프라인
```
[image_publisher]
        ↓ /image_raw
   [detector_node]
        ↓ /detections
 ┌──────┼──────────────┐
[db_logger] [visualizer]  [reject_node]
 SQLite     bbox 표시 영상  불량 배출 신호
```

| 노드 | 역할 |
|---|---|
| `image_publisher` | 이미지 폴더를 일정 주기로 읽어 카메라 입력처럼 발행 |
| `detector_node` | 결함 검출, 결과(클래스·신뢰도·bbox·처리 시간) 발행 |
| `db_logger_node` | 검출 결과를 SQLite에 저장 |
| `visualizer_node` | bbox를 그린 이미지 발행 (rqt_image_view로 확인) |
| `reject_node` | 임계값 이상 결함이면 `/reject` 신호 발행 (선별기 배출 동작 모사) |

검출 결과 하나를 저장·시각화·배출 판정 노드가 각각 구독하므로, 입력 장치나 후단 기능을 바꿔도 검출 노드는 수정하지 않는 구조입니다.

## 데이터
- **NEU-DET** (Northeastern University 강판 표면 결함 데이터셋)
- 결함 6종: crazing, inclusion, patches, pitted_surface, rolled-in_scale, scratches
- 원본 데이터는 `data/`에 두며 저장소에는 올리지 않습니다. (다운로드 방법 정리 예정)

## 기술 스택
- ROS2 Humble (rclpy), Python
- PyTorch (검출 모델)
- SQLite
- Docker, WSL2 (Ubuntu 22.04)

## DB 스키마 (초안)
```sql
CREATE TABLE images (
    id INTEGER PRIMARY KEY,
    file_name TEXT,
    published_at TIMESTAMP      -- 발행 시각 (지연 계산 기준)
);

CREATE TABLE detections (
    id INTEGER PRIMARY KEY,
    image_id INTEGER REFERENCES images(id),
    defect_class TEXT,
    confidence REAL,
    x1 REAL, y1 REAL, x2 REAL, y2 REAL,
    model_version TEXT,
    inference_ms REAL,          -- 모델 추론 시간
    detected_at TIMESTAMP       -- 검출 완료 시각
);
```

## 폴더 구조
```
data/        원본 데이터 (git 제외)
models/      학습된 가중치 (git 제외)
training/    모델 학습·평가 스크립트
ros2_ws/src/ ROS2 패키지 (노드, launch)
sql/         스키마·분석 쿼리
notebooks/   실험 결과 분석
docker/      Dockerfile
docs/        데모 영상·실험 그래프
```

## 진행 현황
- [ ] WSL2 + Docker + ROS2 Humble 환경 구성
- [ ] NEU-DET 다운로드 및 탐색
- [ ] 결함 검출 모델 학습 (v1)
- [ ] image_publisher / detector_node / db_logger_node
- [ ] visualizer_node / reject_node
- [ ] launch 파일로 전체 실행
- [ ] 고민 1: 지연·QoS 실험
- [ ] 고민 2: 임계값 실험
- [ ] 고민 3: 저신뢰 샘플 재학습 (v2)
- [ ] 고민 4: DB 저장 방식 비교
- [ ] 데모 영상·결과 정리

## 실행 방법
정리 예정
