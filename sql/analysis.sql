-- 1.결함 종류별 검출 개수와 평균 신뢰도, 개수 많은 순
select defect_class, count(defect_class) AS count_de, avg(confidence) from detections
group by defect_class
order by count_de desc;


-- 2. 신뢰도 0.5 미만 검출을 파일 이름과 함꼐, 낮은순
select file_name, defect_class, confidence from detections
join images
on detections.image_id = images.id
where confidence < 0.5
order by confidence asc;

-- 3. 결함이 하나도 없는 이미지
select file_name from images
left join detections
on detections.image_id = images.id
where detections.id is null;


--4. 평균 신뢰도 0.6미만인 결함 종류만
select defect_class from detections
group by defect_class
having avg(confidence) < 0.6;

--5. 모델 버전별 검출 개수와 평균 신뢰도
select model_version, count(defect_class), avg(confidence) from detections
group by model_version;