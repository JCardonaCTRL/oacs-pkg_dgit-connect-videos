-- -----------------------------------------------------------------------------
-- DGIT Connect Videos package tables-create
-- @author: Josue Cardona <jcardona@mednet.ucla.edu>
-- @creation-date: 2021-03-15
-- -----------------------------------------------------------------------------

create table dgit_connect_videos (
    video_id        integer not null
        constraint dgit_connect_videos_id_pk primary key,
    image_id        integer
        constraint dgit_connect_videos_image_fk references cr_items(item_id) on delete cascade,
    title           varchar(300)  not null,
    video_link      varchar (300),
    description     varchar (500),
    creation_user   integer  not null
        constraint dgit_connect_videos_creation_user_fk references users(user_id),
    creation_date   timestamptz  not null DEFAULT CURRENT_TIMESTAMP,
    modifying_user  integer
        constraint dgit_connect_videos_last_modified_fk references users(user_id),
    last_modified   timestamptz DEFAULT CURRENT_TIMESTAMP,
    package_id      integer not null
        constraint dgit_connect_videos_package_fk references apm_packages(package_id)
);
create sequence dgit_connect_videos_id_seq;
