<?xml version="1.0"?>
<queryset>
    <fullquery name="get_videos">
        <querytext>
            select
                dcv.video_id,
                dcv.image_id,
                dcv.title,
                dcv.video_link,
                dcv.description,
                to_char(dcv.creation_date, 'MM/DD/YYYY HH24:MI') as creation_date,
                to_char(dcv.last_modified, 'MM/DD/YYYY HH24:MI') as last_modified,
                cu.first_names ||' '|| cu.last_name as creation_user,
                mu.first_names ||' '|| mu.last_name as modifying_user
            from dgit_connect_videos    dcv
                join persons            cu on cu.person_id = dcv.creation_user
                left join persons       mu on mu.person_id = dcv.modifying_user
            where dcv.package_id = :package_id
        </querytext>
    </fullquery>
</queryset>
