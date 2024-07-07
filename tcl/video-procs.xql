<?xml version="1.0"?>
<queryset>
    <fullquery name="dgit::connect_videos::new.insert_video">
        <querytext>
            insert into dgit_connect_videos (
                video_id, image_id, title, video_link, description, creation_user, creation_date, modifying_user, last_modified, package_id
            ) values (
                :video_id, :image_id, :title, :video_link, :description, :creation_user, now(), :creation_user, now(), :package_id
            )
        </querytext>
    </fullquery>

    <fullquery name="dgit::connect_videos::edit.update_video">
        <querytext>
            update dgit_connect_videos
            set $sql_update_list,
                modifying_user  = :modifying_user,
                last_modified   = now()
            where video_id = :video_id
        </querytext>
    </fullquery>

    <fullquery name="dgit::connect_videos::get.get_video_info">
        <querytext>
            select *
            from dgit_connect_videos
            where video_id = :video_id
        </querytext>
    </fullquery>

    <fullquery name="dgit::connect_videos::delete.delete_video">
        <querytext>
            delete
            from dgit_connect_videos
            where video_id = :video_id
        </querytext>
    </fullquery>

</queryset>
