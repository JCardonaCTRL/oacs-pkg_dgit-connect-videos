<?xml version="1.0"?>
<queryset>
    <fullquery name="get_image_id">
        <querytext>
            select image_id
            from dgit_connect_videos
            where video_id = :video_id
        </querytext>
    </fullquery>
</queryset>
