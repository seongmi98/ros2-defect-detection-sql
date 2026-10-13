INSERT INTO images (file_name)
values ('image1'),
('image2'),
('image3'),
('image4'),
('image5');

INSERT INTO detections (image_id, defect_class, confidence)
values (1, 'pitted_surface', 0.8),
(1, 'inclusion', 0.9),
(1, 'inclusion', 0.3),
(1, 'scratches', 0.7),
(3, 'crazing', 0.2),
(3, 'scratches', 0.86),
(3, 'patches', 0.9),
(3, 'scratches', 0.4),
(5, 'patches', 0.7),
(5, 'patches', 0.9);


INSERT INTO detections (image_id, defect_class, confidence, model_version)
values (1, 'crazing', 0.3, 'v2'),
(3, 'crazing', 0.7, 'v2'),
(2, 'patches', 0.6, 'v2'),
(5, 'rolled-in_scale', 0.6, 'v2'),
(5, 'inclusion', 0.3, 'v2');