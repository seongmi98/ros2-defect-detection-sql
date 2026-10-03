# semiconductor-sensor-sql-analysis

반도체 공정 센서 데이터를 SQLite에 적재하고 SQL로 분석한 뒤, 불량 예측·이상 탐지 모델을 비교한 학습 프로젝트입니다.

> 공개 데이터(UCI SECOM)를 사용한 학습 프로젝트이며, 실무 프로젝트가 아닙니다.

## 목표
- 센서 데이터를 DB에 적재하고 SQL로 불량 패턴을 분석한다.
- 시간순 분할로 모델을 평가해 데이터 누수를 피한다.

## 진행 현황
- [ ] 1일차: SQL 기초 학습
- [ ] 2일차: CSV → SQLite 적재
- [ ] 3일차: SQL 분석 쿼리
- [ ] 4일차: 모델링 (불량 예측, 이상 탐지)
- [ ] 5일차: README 정리

## 데이터
- 출처: UCI Machine Learning Repository, SECOM (다운로드 방법은 정리 예정)
- 원본 파일은 `data/`에 두며 저장소에는 올리지 않습니다.

## 폴더 구조
```
data/        원본 데이터 (git 제외)
src/         적재·모델링 스크립트
sql/         분석 쿼리
notebooks/   분석 노트북
```

## 결과·한계
정리 예정
