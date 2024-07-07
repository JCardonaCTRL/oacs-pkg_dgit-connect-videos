<?xml version="1.0"?>
<queryset>
   <fullquery name="dgit::connect_videos::api::get_videos.select">
        <querytext>
            select
               dcv.*,
               ci.storage_area_key
            from dgit_connect_videos    dcv
               left join cr_items       ci on ci.item_id = dcv.image_id
            where dcv.package_id = :package_id
            order by dcv.last_modified desc
        </querytext>
    </fullquery>
    <fullquery name="dgit::connect_videos::api::get_videos.select_filename">
        <querytext>
            select :path || content
            from cr_revisions
            where revision_id = :version_id
        </querytext>
    </fullquery>
</queryset>
