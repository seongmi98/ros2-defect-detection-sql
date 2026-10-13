drop table if exists detections;
drop table if exists images;

create table if not exists images (
    id integer PRIMARY KEY,
    file_name text NOT NULL,
    published_at datetime
);

create table if not exists detections (
    id integer PRIMARY KEY,
    image_id integer NOT NULL references images(id),
    defect_class text NOT NULL,
    confidence float check (confidence between 0 and 1),
    model_version text default 'v1',
    detected_At datetime default current_timestamp
);