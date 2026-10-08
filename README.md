# ros2-defect-detection-sql

표면 결함 이미지를 ROS2 토픽으로 스트리밍하고, 딥러닝 모델로 결함을 검출한 뒤 결과를 SQLite에 저장·SQL로 분석하는 파이프라인입니다.

> 공개 데이터(NEU-DET)를 사용한 개인 학습 프로젝트입니다.

## 목표
- 결함 검출 모델을 ROS2 노드로 통합해 이미지 입력 → 추론 → 저장 흐름을 구현한다.
- 검출 결과를 DB로 관리하고, SQL로 결함 통계와 재검토 대상을 추출한다.
- Docker로 실행 환경을 재현 가능하게 만든다.

## 파이프라인
```
[image_publisher] --/image_raw--> [detector_node] --/detections--> [db_logger_node] --> SQLite --> SQL 분석
 이미지 폴더를        결함 검출 모델        검출 결과 저장
 순서대로 발행        추론
```

| 노드 | 역할 |
|---|---|
| `image_publisher` | 데이터 폴더의 이미지를 일정 주기로 읽어 카메라 영상처럼 발행 |
| `detector_node` | 이미지를 받아 결함 검출, 결과(클래스·신뢰도·bbox) 발행 |
| `db_logger_node` | 검출 결과를 SQLite에 저장 |

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
    published_at TIMESTAMP
);

CREATE TABLE detections (
    id INTEGER PRIMARY KEY,
    image_id INTEGER REFERENCES images(id),
    defect_class TEXT,
    confidence REAL,
    x1 REAL, y1 REAL, x2 REAL, y2 REAL,
    model_version TEXT,
    detected_at TIMESTAMP
);
```

## 분석 쿼리 (예정)
- 결함 유형별 검출 건수·평균 신뢰도
- 신뢰도 낮은 검출 추출 (재검토·재라벨링 후보)
- 모델 버전별 검출 결과 비교

## 폴더 구조
```
data/        원본 데이터 (git 제외)
models/      학습된 가중치 (git 제외)
training/    모델 학습·평가 스크립트
ros2_ws/src/ ROS2 패키지 (노드, launch)
sql/         스키마·분석 쿼리
notebooks/   데이터 탐색·결과 분석
docker/      Dockerfile
docs/        데모 영상·이미지
```

## 진행 현황
- [ ] WSL2 + Docker + ROS2 Humble 환경 구성
- [ ] NEU-DET 다운로드 및 탐색
- [ ] 결함 검출 모델 학습
- [ ] image_publisher 노드
- [ ] detector_node 노드
- [ ] db_logger_node 노드 + SQLite 저장
- [ ] SQL 분석 쿼리
- [ ] launch 파일로 전체 실행
- [ ] 데모 영상·README 정리

## 실행 방법
정리 예정

## 결과·한계
정리 예정
